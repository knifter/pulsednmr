#include "nmrcore.h"
#include "config.h"

#include "log.h"

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <sys/mman.h>
#include <sys/time.h>


#define MEM_DEVICE			"/dev/mem"
#define MMAP_CONFIG 		0x40000000
#define MMAP_STATUS 		0x40001000
#define MMAP_RXDATA 		0x40010000
#define MMAP_TXDATA 		0x40020000
#define DAC_SAMPLE_RATE     125000000		// 125 MSPS
#define TX_BUFSIZE          50000           // Configures buffer size (PL)
#define FREQ_MIN            (DAC_SAMPLE_RATE/TX_BUFSIZE)    
#define FREQ_MAX            (DAC_SAMPLE_RATE/2)

NMRCore::NMRCore()
{
	printf("-> Min/Max Freq: %d/%d\n", FREQ_MIN, FREQ_MAX);

	// Memory Map PL Registers
	if((_map_fd = open(MEM_DEVICE, O_RDWR)) < 0)
	{
		ERROR("ERROR: opening mem-device");
		return;
	}; 
	_config = (PL_ConfigRegister*) mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, _map_fd, MMAP_CONFIG);
	_status = (PL_StatusRegister*) mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, _map_fd, MMAP_STATUS);
	_map_rxdata = mmap(NULL, 16*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, _map_fd, MMAP_RXDATA);
	_map_txdata = (uint16_t*) mmap(NULL, 16*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, _map_fd, MMAP_TXDATA);
  	// sysconf(_SC_PAGESIZE) = 4096, 16*=65536 bytes
  	if(_config == NULL)
  	{
  		ERROR("ERROR: mmap(CONFIG) failed.");
  		return;
  	}
  	if(_status == NULL)
  	{
  		ERROR("ERROR: mmap(STATUS) failed.");
  		return;
  	}

	/* fill tx buffer with zeros */
	memset(_map_txdata, 0, 65536);

	// Put us in reset
	// *_reg_rx_rst |= 1; *_reg_tx_rst |= 1;

	// Set some defaults
	setFrequency(1E6);
	setRxRate(RATE_2500K);
	setTxPeriods(2000);
	setRxSize(50000);
}

NMRCore::~NMRCore()
{
	if(_map_fd)
		close(_map_fd);
	_config = NULL;
	_status = NULL;
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
	if(!_config)
	{
		ERROR("setRxFrequency: _config == NULL\n");
		return 1;
	};
	if(freq < FREQ_MIN | freq > FREQ_MAX)
	{
		ERROR("setRxFrequency: Rx Freq out of range.\n");
		return 2;
	};

	uint32_t pir = floor((float)freq / DAC_SAMPLE_RATE * (1<<30) + 0.5);
	DBG("setRxFrequency: %u Hz -> DDS phase-incr-reg: %u\n", freq, pir);
	_config->rx_pir = pir;

	return 0;
}

int NMRCore::setTxFrequency(uint32_t freq)
{
	if(freq < FREQ_MIN | freq > FREQ_MAX)
	{
		ERROR("Tx Freq out of range.");
		return 2;
	};

	DBG("setTxFrequency: %u Hz\n", freq);
	_tx_freq = freq;
	_needs_generate = true;
	return 0;
}

int NMRCore::setTxPeriods(uint32_t periods10)
{
	printf("setTxPeriods: %d/10\n", periods10);
	_tx_periods = periods10;
	_needs_generate = true;
	return 0;
}

int NMRCore::setRxRate(NMRDecimationRate rate)
{
	DBG("setRxRate: idx = %d\n", rate);
	if(!_config)
	{
		ERROR("setRxRate: _config == NULL\n");
		return 1;
	};
	// rx_rate = DAC_SAMPLE_RATE / divider / 2 [CIC(rx_rate) + FIR(2)]
	switch(rate)
	{
		// DAC_SAMPLE_RATE / 2500 = 50ksmps
		case RATE_25K:
			_config->rx_rate = DAC_SAMPLE_RATE/2 / 25E3;
			break;
		case RATE_50K:
			_config->rx_rate = DAC_SAMPLE_RATE/2 / 50E3;
			break;
		case RATE_125K:
			_config->rx_rate = DAC_SAMPLE_RATE/2 / 125E3;
			break;
		case RATE_250K:
			_config->rx_rate = DAC_SAMPLE_RATE/2 / 250E3;
			break;
		case RATE_500K:
			_config->rx_rate = DAC_SAMPLE_RATE/2 / 500E3;
			break;
		case RATE_1250K:
			_config->rx_rate = DAC_SAMPLE_RATE/2 / 1250E3;
			break;
		case RATE_2500K:
			_config->rx_rate = DAC_SAMPLE_RATE/2 / 2500E3;
			break;
		// case RATE_5000K:
		// 	_config->rx_rate = DAC_SAMPLE_RATE/2 / 5000E3;
		// 	break;
		default: 
			printf("ERROR: Received an incorrect rate-index: %d", rate);
			return 1;
	}
	return 0;
}

int NMRCore::getRxRate()
{
	 return DAC_SAMPLE_RATE/2 / _config->rx_rate;
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
		ERROR("Failed to allocate RxBuffer of %u bytes for %u samples.");
		_rx_size = 0;
		return 1;
	}
	_rx_size = size;

	return 0;
}

int NMRCore::singleShot()
{
	DBG("Start.\n");

	if(!_config)
	{
		DBG("singleShot: _config == NULL\n");
		return 1;
	};
	if(!_rx_buffer)
	{
		ERROR("No Rx buffer allocated.");
		return 2;
	};

	if(_needs_generate)
		if(generatePulse())
		{
			ERROR("generatePulse failed.\n");
			return 3;
		};

	// un-reset Rx&Tx cores
	// Reset Rx
	_config->rx_reset |= 1;		// RESET Rx

	// Reset cycle Tx
	_config->tx_resetn &= ~1;	// RESET Tx
	_config->tx_resetn |= 1;	// UN-RESET Tx

#ifdef WAIT_RX_FOR_TX
	// Wait until TX pulse is over before enabling receiver
	uint32_t wait_time = (_tx_size * 1E6) / DAC_SAMPLE_RATE
	usleep(wait_time);
	DBG("Waiting %u usec.\n", wait_time);
#endif

	// enable Rx
	_config->rx_reset &= ~1; 	// UN-RESET Rx

	// Get FIFO data into buffer

#ifdef DEBUG_READLOOP
	DBG("read loop start\n");
	struct timeval tv;
	gettimeofday(&tv,NULL);
	uint64_t start = 1E6*tv.tv_sec + tv.tv_usec;
#endif // DEBUG_READLOOP

	/* transfer 10 * 5k = 50k samples, or 50k * 8 bytes */
	// static uint8_t buffer[40000]; // 5k complex float samples
	// for(int i = 0; i < 10; ++i)
	// {
	// 	// TODO: Doesnt this send 10 times the same data?
	// 	// max rx_counter = 16386
	// 	while(_status->rx_counter < 10000) 
	// 		usleep(100);
	// 	// printf("%u\n", _status->rx_counter);
	// 	memcpy(buffer, _map_rxdata, 40000);
	// 	// send(sock_client, buffer, 40000, MSG_NOSIGNAL);
	// };

	uint32_t rx_total = 0;
	uint16_t len;
	uint32_t needed;
	while(rx_total < _rx_size)
	{
		// throttle polling
		while(_status->rx_counter < 5000)
			usleep(100);

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
	_config->rx_reset |= 1;

	DBG("Total %d complex-floats read. %d Bytes.\n", rx_total, rx_total*2*sizeof(float));

	// TODO: put core in reset?
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

int NMRCore::generatePulse()
{
	if(!_map_txdata)
	{
		perror("generatePulse: _reg_tx_data == NULL");
		return 1;
	};
	if(!_config)
	{
		perror("generatePulse: _config == NULL");
		return 2;
	};

    // Check periods fit in buffer
    // 50k samples @ 125 MSPS = 400 uS
    // samples per period = 125 MSPS / freq
    // periods = 400 uS / samples per period
    uint16_t half_periods = _tx_periods / 5;

    // half_period_time = 1/(2*freq)
    // buffer_time = TX_BUFSIZE / DAC_SAMPLE_RATE
    // half_periods_max = buffer_time / half_period_time
    uint32_t half_periods_max = 2.0*TX_BUFSIZE/DAC_SAMPLE_RATE * _tx_freq;
    // Generate <freq> sine in buffer
    // samples per period = DAC_SAMPLE_RATE / freq
    // samples needed = half_periods * samples per period / 2
    _tx_pulse_size = floor((1.0*half_periods * DAC_SAMPLE_RATE) / (_tx_freq*2) + 0.5);

    // increase _tx_pulse_size by 1 to include the last zero
    _tx_pulse_size++;

    // pulse time = sample per period / 2 * half_periods
    // printf("generatePulse: Max half-periods that fit in buffer: %d\n", half_periods_max);
	printf("generatePulse: %u half-periods, %.2f usecs.\n", half_periods, (_tx_pulse_size*1.0E6)/DAC_SAMPLE_RATE);
    printf("generatePulse: %u samples needed for %u half-periods.\n", _tx_pulse_size, half_periods);
    
    // check that this frequency and periods fit in tx_data
    if(_tx_pulse_size > TX_BUFSIZE)
    {
    	printf("generatePulse: ERROR: Too many half-periods to fit in buffer (max %u half periods)", half_periods_max);
    	return 2;
    };

    // Synthesize the sine the tx_buffer
    printf("generatePulse: generating %u samples (%u bytes)\n", 
    	_tx_pulse_size, _tx_pulse_size*sizeof(uint16_t));
    // int16_t* data = (int16_t*) _map_txdata;
    int16_t sample;
    float pirc = 2.0*M_PI * _tx_freq/DAC_SAMPLE_RATE;
    for(int i = 0; i < _tx_pulse_size; i++)
    {
    	sample = floor(8191.0 * sin(i*pirc) + 0.5);
        // printf("%d, %d\n", i, sample);
        _map_txdata[i] = sample;
    };

    // TODO: Somehow we still need to keep copying it, 32-bits bus the cause?
    // memcpy(data, buf, _tx_pulse_size*sizeof(uint16_t));

    // written _tx_pulse_size*2 bytes
    _config->tx_size = _tx_pulse_size;

    // done
    _needs_generate = false;
    return 0;        
}

