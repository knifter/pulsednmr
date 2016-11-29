#include "nmrcore.h"
#include "config.h"

#include "log.h"

#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <sys/mman.h>
#include <sys/time.h>


#define MEM_DEVICE			"/dev/mem"
#define MMAP_RXCONFIG 		0x40000000
#define RESET_NONE	0x00
#define RESET_RX 	0x01
#define RESET_TX 	0x02
#define MMAP_RXSTATUS 		0x40001000
#define MMAP_TXCONFIG 		0x40002000
#define MMAP_RXDATA 		0x40010000
#define DAC_SAMPLE_RATE     125000000		// 125 MSPS
#define TX_BUFSIZE          50000           // Configures buffer size (PL)
#define RX_DDS_PIR_WIDTH	30				// bit-width of DDS Phase register
#define TX_DDS_PIR_WIDTH	30				// bit-width of DDS Phase register
#define FREQ_MIN            (DAC_SAMPLE_RATE/TX_BUFSIZE)
#define FREQ_MAX            (DAC_SAMPLE_RATE/2)

#define PULSE_LEN_MIN		0
#define PULSE_LEN_MAX		1000
#define PULSE_DLY_MIN		100
#define PULSE_DLY_MAX		64000
#define PULSE_BCNT_MIN		0
#define PULSE_BCNT_MAX		10
#define RX_DELAY_MIN		0
#define	RX_DELAY_MAX		5000000 // 5 sec


NMRCore::NMRCore()
{
	printf("-> Min/Max Freq: %d/%d\n", FREQ_MIN, FREQ_MAX);

	// Memory Map PL Registers
	if((_map_fd = open(MEM_DEVICE, O_RDWR)) < 0)
	{
		ERROR("ERROR: opening mem-device\n");
		return;
	}; 
	_rxconfig = (PL_RxConfigRegister*) mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, _map_fd, MMAP_RXCONFIG);
	_status =   (PL_StatusRegister*) mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, _map_fd, MMAP_RXSTATUS);
	_txconfig = (PL_TxConfigRegister*) mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, _map_fd, MMAP_TXCONFIG);
	_map_rxdata = mmap(NULL, 16*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, _map_fd, MMAP_RXDATA);
  	// sysconf(_SC_PAGESIZE) = 4096, 16*=65536 bytes
  	if(_rxconfig == NULL)
  	{
  		ERROR("mmap(RXCONFIG) failed.\n");
  		return;
  	}
  	if(_status == NULL)
  	{
  		ERROR("mmap(TXSTATUS) failed.\n");
  		return;
  	}
  	if(_txconfig == NULL)
  	{
  		ERROR("mmap(TXCONFIG) failed.\n");
  		return;
  	}

  	// Alignment checking
#ifdef DEBUG_ALIGNMENT
	printf("RxConfig at: %p\n", _rxconfig);
	printf("\treset: %p\n", &(_rxconfig->reset));
	printf("\trate: %p\n", &(_rxconfig->rate));
	printf("\tpir: %p\n", &(_rxconfig->pir));
	printf("SizeOf(PL_ConfigRxRegister: %d\n", sizeof(*_rxconfig));

	printf("TxConfig at: %p\n", _txconfig);
	printf("\tpir: %p\n", &(_txconfig->pir));
	printf("\talen: %p\n", &(_txconfig->a_len));
	printf("\tbleb: %p\n", &(_txconfig->b_len));
	printf("\tabdly: %p\n", &(_txconfig->ab_dly));
	printf("\tbbdly: %p\n", &(_txconfig->bb_dly));
	printf("\tbbcnt: %p\n", &(_txconfig->bb_cnt));
	printf("SizeOf(PL_ConfigTxRegister: %d\n", sizeof(*_txconfig));
#endif

	// Put us in reset
	// *_reg_rx_rst |= 1; *_reg_tx_rst |= 1;

	// Set some defaults
	setFrequency(1E6);
	setRxRate(RATE_2500K);
	setRxSize(50000);
	setRxDelay(0);

	setTxAlen(100);
	setTxBlen(100);
	setTxABdly(200);
	setTxBBdly(200);
	setTxBBcnt(0);
}

NMRCore::~NMRCore()
{
	if(_map_fd)
		close(_map_fd);
	_rxconfig = NULL;
	_status = NULL;
	_txconfig = NULL;
}

int NMRCore::setFrequency(uint32_t freq)
{
	int res = setRxFrequency(freq);
	if(res)
		return res;
	return setTxFrequency(freq);
}

int NMRCore::setRxFrequency(uint32_t freq)
{
	if(!_rxconfig)
	{
		ERROR("setRxFrequency: _rxconfig == NULL\n");
		return 1;
	};
	if(freq < FREQ_MIN | freq > FREQ_MAX)
	{
		ERROR("setRxFrequency: Rx Freq out of range.\n");
		return 2;
	};

	uint32_t pir = floor((float)freq / DAC_SAMPLE_RATE * (1<<RX_DDS_PIR_WIDTH) + 0.5);
	DBG("%u Hz -> DDS phase-incr-reg: %u\n", freq, pir);
	_rxconfig->pir = pir;

	return 0;
}

int NMRCore::setTxFrequency(uint32_t freq)
{
	if(!_txconfig)
	{
		ERROR("_txconfig == NULL\n");
		return 1;
	};
	if(freq < FREQ_MIN | freq > FREQ_MAX)
	{
		ERROR("Tx Freq out of range.");
		return 2;
	};

	uint32_t pir = floor((float)freq / DAC_SAMPLE_RATE * (1<<TX_DDS_PIR_WIDTH) + 0.5);
	DBG("%u Hz -> DDS phase-incr-reg: %u\n", freq, pir);
	_txconfig->pir = pir;

	return 0;
}

int NMRCore::setTxAlen(uint32_t usec)
{
	if(!_txconfig)
	{
		ERROR("_txconfig == NULL\n");
		return 1;
	};
	if(usec > PULSE_LEN_MAX | usec < PULSE_LEN_MIN)
	{
		ERROR("A-length %u out of range (%d, %d)\n", usec, PULSE_LEN_MIN, PULSE_LEN_MAX);
		return 2;
	}

	DBG("A-length: %u us pulse.\n", usec);

	_txconfig->a_len = usec;
}

int NMRCore::setTxBlen(uint32_t usec)
{
	if(!_txconfig)
	{
		ERROR("_txconfig == NULL\n");
		return 1;
	};
	if(usec > PULSE_LEN_MAX | usec < PULSE_LEN_MIN)
	{
		ERROR("B-length %u out of range (%d, %d)\n", usec, PULSE_LEN_MIN, PULSE_LEN_MAX);
		return 2;
	}

	DBG("B-length: %u us pulse.\n", usec);

	_txconfig->b_len = usec;
}

int NMRCore::setTxABdly(uint32_t usec)
{
	if(!_txconfig)
	{
		ERROR("_txconfig == NULL\n");
		return 1;
	};
	if(usec > PULSE_DLY_MAX | usec < PULSE_DLY_MIN)
	{
		ERROR("A-to-B-Delay %u out of range (%d, %d)\n", usec, PULSE_DLY_MIN, PULSE_DLY_MAX);
		return 2;
	}

	DBG("A-to-B-Delay: %u us.\n", usec);

	_txconfig->ab_dly = usec;
}

int NMRCore::setTxBBdly(uint32_t usec)
{
	if(!_txconfig)
	{
		ERROR("_txconfig == NULL\n");
		return 1;
	};
	if(usec > PULSE_DLY_MAX | usec < PULSE_DLY_MIN)
	{
		ERROR("B-to-B-Delay %u out of range (%d, %d)\n", usec, PULSE_DLY_MIN, PULSE_DLY_MAX);
		return 2;
	}

	DBG("B-to-B-Delay: %u us.\n", usec);

	_txconfig->bb_dly = usec;
}

int NMRCore::setTxBBcnt(uint32_t count)
{
	if(!_txconfig)
	{
		ERROR("_txconfig == NULL\n");
		return 1;
	};
	if(count > PULSE_BCNT_MAX | count < PULSE_BCNT_MIN)
	{
		ERROR("B-Count %u out of range (%d, %d)\n", count, PULSE_BCNT_MIN, PULSE_BCNT_MAX);
		return 2;
	}

	DBG("B-Count: %u pulses.\n", count);

	_txconfig->bb_cnt = count;
}


int NMRCore::setRxRate(NMRDecimationRate rate)
{
	DBG("setRxRate: idx = %d\n", rate);
	if(!_rxconfig)
	{
		ERROR("setRxRate: _rxconfig == NULL\n");
		return 1;
	};
	// rx_rate = DAC_SAMPLE_RATE / divider / 2 [CIC(rx_rate) + FIR(2)]
	switch(rate)
	{
		// DAC_SAMPLE_RATE / 2500 = 50ksmps
		case RATE_25K:
			_rxconfig->rate = DAC_SAMPLE_RATE/2 / 25E3;
			break;
		case RATE_50K:
			_rxconfig->rate = DAC_SAMPLE_RATE/2 / 50E3;
			break;
		case RATE_125K:
			_rxconfig->rate = DAC_SAMPLE_RATE/2 / 125E3;
			break;
		case RATE_250K:
			_rxconfig->rate = DAC_SAMPLE_RATE/2 / 250E3;
			break;
		case RATE_500K:
			_rxconfig->rate = DAC_SAMPLE_RATE/2 / 500E3;
			break;
		case RATE_1250K:
			_rxconfig->rate = DAC_SAMPLE_RATE/2 / 1250E3;
			break;
		case RATE_2500K:
			_rxconfig->rate = DAC_SAMPLE_RATE/2 / 2500E3;
			break;
		// case RATE_5000K:
		// 	_rxconfig->rate = DAC_SAMPLE_RATE/2 / 5000E3;
		// 	break;
		default: 
			ERROR("Received an incorrect rate-index: %d\n", rate);
			return 1;
	}
	return 0;
}

int NMRCore::getRxRate()
{
	 return DAC_SAMPLE_RATE / (2*_rxconfig->rate);
}

int NMRCore::setRxSize(uint32_t size)
{
	if(_rx_buffer)
		free(_rx_buffer);

	// We need <size> complex floats
	uint32_t bsize = size * 2 * sizeof(float);
	DBG("Reserving %u bytes for a %u sample Rx Buffer.\n", bsize, size);
	_rx_buffer = malloc(bsize);
	if(_rx_buffer == NULL)
	{
		ERROR("Failed to allocate RxBuffer of %u bytes for %u samples.", bsize, size);
		_rx_size = 0;
		return 1;
	}
	_rx_size = size;

	return 0;
}

int NMRCore::setRxDelay(uint32_t usec)
{
	if(!_rxconfig)
	{
		ERROR("_rxconfig == NULL\n");
		return 1;
	};
	if(usec > RX_DELAY_MAX | usec < RX_DELAY_MIN)
	{
		ERROR("Rx-Delay %u us out of range (%d, %d)\n", usec, RX_DELAY_MIN, RX_DELAY_MAX);
		return 2;
	}
	uint32_t samples = ((uint64_t)getRxRate() * (uint64_t)usec) / 1E6;
	DBG("Rx-Delay %u us, %u samples.\n", usec, samples);
	_rx_delay = samples;

	return 0;
}


int NMRCore::singleShot()
{

	if(!_rxconfig)
	{
		DBG("singleShot: _rxconfig == NULL\n");
		return 1;
	};
	if(!_rx_buffer)
	{
		ERROR("No Rx buffer allocated.");
		return 2;
	};

	// reset Rx&Tx cores
	DBG("Start Tx.\n");
	_rxconfig->reset = RESET_RX | RESET_TX;


	// enable Rx & Tx
	_rxconfig->reset = RESET_NONE;
	DBG("Start Rx.\n");

	// Discard _rxdelay samples
	uint16_t len;
#ifdef DEBUG_READLOOP
	DBG("RxDelay discarding %u samples.\n", _rx_delay);
#endif // DEBUG_READLOOP
	uint32_t needed = _rx_delay;
	float dummy[2];
	uint32_t check = 0;
	while(needed)
	{
		// throttle polling
		while(_status->rx_counter < 1000)
			usleep(100);
		
		// rx_counter is our total number of floats waiting, twice the amount of samples
		// read it once and cache it locally, it's updated by the PL
		len = _status->rx_counter >> 1;

		// There is probably more in the fifo then we need at some point
		if(len > needed)
			len = needed;
#ifdef DEBUG_READLOOP
		DBG(" ... %u/%u/%u samples.\n", len, needed, _rx_delay);
#endif // DEBUG_READLOOP
		needed -= len;
	
		// discard fifo values by reading into a dummy
		while(len)
		{
			//dummy = *(float*)_map_rxdata; // I
			//dummy = *(float*)_map_rxdata; // Q
			memcpy((uint8_t*) dummy, _map_rxdata, 2*sizeof(float));
			len--;
			check++;
		}
	};
	DBG("RxDelay: Discarded %u samples.\n", check);

	// Get FIFO data into buffer
#ifdef DEBUG_READLOOP
	DBG("read loop start\n");
	struct timeval tv;
	gettimeofday(&tv,NULL);
	uint64_t start = 1E6*tv.tv_sec + tv.tv_usec;
#endif // DEBUG_READLOOP

	// Read rx_size samples into rxbuffer
	uint32_t rx_total = 0;
	while(rx_total < _rx_size)
	{
		// throttle polling
		while(_status->rx_counter < 5000)
		{
			usleep(100);
		};

		// rx_counter is our total number of floats waiting, twice the amount of samples
		// read it once and cache it locally, it's updated by the PL
		len = _status->rx_counter >> 1;
		// now len is the amount of 'samples', complex floats waiting (even)

		// read min(len, needed)
		needed = _rx_size - rx_total;
#ifdef DEBUG_READLOOP
		DBG("%d float pairs waiting. %d still needed.\n", len, needed);
#endif
		if(len > needed)
			len = needed;
		memcpy((uint8_t*)_rx_buffer + rx_total*2*sizeof(float), _map_rxdata, len*2*sizeof(float));
		rx_total += len;
	};
#ifdef DEBUG_READLOOP
	gettimeofday(&tv,NULL);
	uint64_t stop = 1E6*tv.tv_sec + tv.tv_usec;
	uint32_t tim = stop - start;
	DBG("read loop done. Time = %u, Rate > %.0f smps\n", tim, rx_total*(1.0E6/tim) );
#endif // DEBUG_READLOOP

	// stop the receiver
	_rxconfig->reset = RESET_RX | RESET_TX;

	DBG("Total %d complex-floats read. %d Bytes.\n", rx_total, rx_total*2*sizeof(float));

	return 0;
}

int NMRCore::getRxBuffer(void** data_target, uint32_t* len_target)
{
	if(_rx_size == 0)
	{
		ERROR("No RxBuffer size. Nothing to return.\n");
		return 1;
	}
	if(!_rx_buffer)
	{
		ERROR("No Rx buffer allocated.\n");
		return 2;
	};

	*data_target = _rx_buffer;
	*len_target = _rx_size * 2 * sizeof(float);
	return 0;
}

