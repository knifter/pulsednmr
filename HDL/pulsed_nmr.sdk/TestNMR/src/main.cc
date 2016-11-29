/*
 * Empty C++ Application
 */

#include "xil_printf.h"

typedef struct {
	uint8_t  reset;
	uint16_t rate;
	uint32_t pir;
} PL_ConfigRxRegister;
#define RXCONFIG_RESET_RX	0x00
#define RXCONFIG_RESET_TX	0x01
#define RXCONFIG_PULSE_ON	0x80

typedef struct {
	uint32_t pir;
	uint16_t a_len;
	uint16_t b_len;
	uint16_t ab_dly;
	uint16_t bb_dly;
	uint16_t bb_cnt;
	uint16_t _unused;
} PL_ConfigTxRegister;

#define MMAP_RXCONFIG 		0x40000000
#define MMAP_RXSTATUS 		0X40001000
#define MMAP_TXCONFIG 		0x40002000

#define CPU_CLK				666666687 // Hz
#define DAC_SAMPLE_RATE		125000000 // Hz
#define TX_DDS_PIR_WIDTH	30
#define LOOP_DELAY			CPU_CLK / 50 // ~100ms

#include <math.h>

int main()
{
	xil_printf("Start.\n");

	PL_ConfigRxRegister* rxconfig = (PL_ConfigRxRegister*) MMAP_RXCONFIG;
	PL_ConfigTxRegister* txconfig = (PL_ConfigTxRegister*) MMAP_TXCONFIG;

	int freq = 22E6;
	uint32_t pir = floor((float)freq / DAC_SAMPLE_RATE * (1<<TX_DDS_PIR_WIDTH) + 0.5);

	txconfig->a_len = (uint16_t) 100;
	txconfig->b_len = (uint16_t) 100;
	txconfig->ab_dly = (uint16_t) 200;
	txconfig->bb_dly = (uint16_t) 200;
	txconfig->bb_cnt = (uint16_t) 2;
	txconfig->pir	 = pir;

	xil_printf("TxConfig at: %p\n", txconfig);
	xil_printf("\tpir: %p\n", &(txconfig->pir));
	xil_printf("\talen: %p\n", &(txconfig->a_len));
	xil_printf("\tbleb: %p\n", &(txconfig->b_len));
	xil_printf("\tabdly: %p\n", &(txconfig->ab_dly));
	xil_printf("\tbbdly: %p\n", &(txconfig->bb_dly));
	xil_printf("\tbbcnt: %p\n", &(txconfig->bb_cnt));
	xil_printf("SizeOf(PL_ConfigRxRegister: %d\n", sizeof(*rxconfig));
	xil_printf("SizeOf(PL_ConfigTxRegister: %d\n", sizeof(*txconfig));

	xil_printf("Frequency: %d, pir = %d\n", freq, pir);

	while(1)
	{
		// delay
		for(int i = LOOP_DELAY; i>0; i--) { };
		xil_printf(".");

		rxconfig->reset = 0x03;
		rxconfig->reset = 0x01;
	}
	return 0;
}
