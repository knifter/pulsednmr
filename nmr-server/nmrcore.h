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
	uint8_t rx_reset; 
	uint8_t tx_resetn;
	uint16_t _align;
	uint32_t rx_pir;
	uint32_t rx_rate; 
	uint16_t tx_size; 
} PL_ConfigRegister;

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
	int setTxPeriods(uint32_t periods);

	int singleShot();
protected:
	int generatePulse();

private:
	// Disable Copy Constructor/Assignment Operator
	NMRCore(const NMRCore&) = delete;
	NMRCore & operator=(const NMRCore&) = delete;

	// mappings
	uint32_t _map_fd;
	PL_ConfigRegister* _config;
	PL_StatusRegister* _status;
	void	 *_map_rxdata = NULL;
	uint16_t *_map_txdata = NULL;

	// member vars
	uint32_t _rx_freq;
	uint32_t _rx_size;
	uint32_t _tx_freq, _tx_periods;
	bool _needs_generate = true;
	uint16_t _tx_pulse_size = 0;
	void* _rx_buffer = NULL;
};


#endif // _NMRCORE_H
