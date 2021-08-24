#ifndef _NMRCORE_H
#define _NMRCORE_H

#include <stdint.h>
#include <stdlib.h>

typedef enum : uint8_t {
	RATE_25K = 0,
	RATE_50K,
	RATE_125K,
	RATE_250K,
	RATE_500K,
	RATE_1250K,
	RATE_2500K = 6
} NMRDecimationRate;

typedef struct {
	uint8_t  control;
		// 0: DDSReset (rx&tx!)
		// 1: TxReset
		// 7: TxForceOn
	uint8_t _align;
	uint16_t rate;
	uint32_t pir;
}  PL_RxConfigRegister;

typedef struct {
	uint32_t pir;		//   0..31
	uint32_t a_len; 	//  32..63
	uint32_t b_len; 	//  64..95
	uint32_t ab_dly;	//  96..127
	uint32_t bb_dly;	// 128..159
	uint16_t bb_cnt;	// 160..175
	uint16_t power_out;	// 176..191
	uint32_t blank_len; // 192..223
} PL_TxConfigRegister;

typedef struct{
	uint16_t rx_counter;
} PL_RxStatusRegister;

class NMRCore
{
public:
	NMRCore();
	virtual ~NMRCore();

	int configure_fclk0();
	int reset_pl();

	int setFrequency(uint32_t freq);
	int setRxFrequency(uint32_t freq);
	int setRxRate(NMRDecimationRate rate);
	int getRxRate();
	int setRxSize(uint32_t size);
	int setRxDelay(uint32_t delay);
	int getRxBuffer(void** data_target, uint32_t* len_target);

	int setTxFrequency(uint32_t freq);
	int setTxAlen(uint32_t usec);
	int setTxBlen(uint32_t usec);
	int setTxABdly(uint32_t usec);
	int setTxBBdly(uint32_t usec);
	int setTxBBcnt(uint32_t count);
	int setTxPower(uint16_t power);
	int setTxBlankLen(uint32_t usec);

	int singleShot();
	int forceOn(bool on);
	int Reset();
	int TestFunction();

protected:
	int generatePulse();

private:
	// Disable Copy Constructor/Assignment Operator
	NMRCore(const NMRCore&) = delete;
	NMRCore & operator=(const NMRCore&) = delete;

	// mappings
	uint32_t _map_fd;
	volatile uint32_t*				_slcr;
	volatile PL_RxConfigRegister* 	_rxconfig;
	volatile PL_RxStatusRegister* 	_rxstatus;
	volatile PL_TxConfigRegister* 	_txconfig;
	volatile uint64_t*				_map_rxdata;

	// member vars
	uint32_t _rx_freq;
	uint32_t _rx_size;
	uint64_t* _rx_buffer = NULL;
	uint32_t _rx_delay = 0;
};


#endif // _NMRCORE_H
