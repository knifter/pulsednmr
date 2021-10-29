#ifndef CONFIG_H
#define CONFIG_H

#define VERSION				"20211027"

#define SERVER_PORT			1001
#define DEBUG
#define DEBUGLOG			// enabled DBG() macro messages in log
#define DEBUG_READLOOP
// #define DEBUG_ALIGNMENT

#define FREQ_MIN            (10)
#define FREQ_MAX            (DAC_SAMPLE_RATE/2)
#define NMR_CORE_CLK		125000000
#define NMR_PG_CLK			(NMR_CORE_CLK / 125.0)
#define PULSE_LEN_MIN		1
#define PULSE_LEN_MAX		(100000)		// 10 mS
#define PULSE_DLY_MIN		100				// >10 uS
#define PULSE_DLY_MAX		((int)2E7)		// >2E6 uS
#define PULSE_BCNT_MIN		0
#define PULSE_BCNT_MAX		10
#define PULSE_POWER_MIN		0
#define PULSE_POWER_MAX		65535
#define RX_DELAY_MIN		0
#define	RX_DELAY_MAX		5000000 		// 5 sec
#define BLANK_LEN_MIN		0
#define BLANK_LEN_MAX		5000000			// 5 sec
#define BLANK_RECOVER_US	500				// 0.5ms, datasheet says 3ms recover time..

#endif // CONFIG_H
