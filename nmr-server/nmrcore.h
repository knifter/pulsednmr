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
	uint8_t  reset;
	uint8_t _align;
	uint16_t rate;
	uint32_t pir;
}  PL_RxConfigRegister;

typedef struct {
	uint32_t pir;
	uint16_t a_len;
	uint16_t b_len; 
	uint16_t ab_dly;
	uint16_t bb_dly;
	uint16_t bb_cnt;
	uint16_t _unused;
} PL_TxConfigRegister;
 

typedef struct{
	uint16_t rx_counter;
} PL_StatusRegister;

class NMRCore
{
public:
	NMRCore();
	~NMRCore();

	int setFrequency(uint32_t freq);
	int setRxFrequency(uint32_t freq);
	int setRxRate(NMRDecimationRate rate);
	int getRxRate();
	int setRxSize(uint32_t size);
	int getRxBuffer(void** data_target, uint32_t* len_target);

	int setTxFrequency(uint32_t freq);
	int setTxAlen(uint32_t usec);
	int setTxBlen(uint32_t usec);
	int setTxABdly(uint32_t usec);
	int setTxBBdly(uint32_t usec);
	int setTxBBcnt(uint32_t count);

	int singleShot();
protected:
	int generatePulse();

private:
	// Disable Copy Constructor/Assignment Operator
	NMRCore(const NMRCore&) = delete;
	NMRCore & operator=(const NMRCore&) = delete;

	// mappings
	uint32_t _map_fd;
	PL_RxConfigRegister* _rxconfig;
	PL_StatusRegister* 	 _status;
	PL_TxConfigRegister* _txconfig;
	void	 *_map_rxdata = NULL;
	uint16_t *_map_txdata = NULL;

	// member vars
	uint32_t _rx_freq;
	uint32_t _rx_size;
	void* _rx_buffer = NULL;
};


#endif // _NMRCORE_H
