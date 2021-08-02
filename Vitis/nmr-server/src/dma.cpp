#ifdef DO_NOT_COMPILE

#include "dma.h"

#include <stdlib.h>
#include "xaxidma.h"

#define DMA_DEVICE_ID		XPAR_AXIDMA_0_DEVICE_ID

// Private data
typedef struct dma_passthrough_periphs
{
	XAxiDma dma_inst;
} dma_passthrough_periphs_t;

typedef struct dma_passthrough
{
	dma_passthrough_periphs_t periphs;
	void*                     p_rcv_buf;
	void*                     p_snd_buf;
	int                       buf_length;
	int                       sample_size_bytes;
} dma_passthrough_t;

DMAEngine::DMAEngine()
{
	init();
};

DMAEngine::~DMAEngine()
{
	
};


// Private functions
static int DMAEngine::init()
{
	LOG("DMA: Lookup hardware..\n");
	// Look up hardware configuration for device
	XAxiDma_Config* cfg_ptr = XAxiDma_LookupConfig(DMA_DEVICE_ID);
	if (!cfg_ptr)
	{
		ERROR("ERROR! No hardware configuration found for AXI DMA with device id %d.\r\n", dma_device_id);
		return -1;
	};

	// Initialize driver
	LOG("DMA: init driver..\n");
	int status = XAxiDma_CfgInitialize(&_dma_inst, cfg_ptr);
	if (status != XST_SUCCESS)
	{
		ERROR("ERROR! Initialization of AXI DMA failed with %d\r\n", status);
		return -2;
	}

	// Test for Scatter Gather
	LOG("DMA: checking mode..\n");
	if (XAxiDma_HasSg(_dma_inst))
	{
		ERROR("ERROR! Device configured as SG mode.\r\n");
		return -3;
	};

	// Disable interrupts for both channels
	LOG("DMA: disabling intr...\n");
	XAxiDma_IntrDisable(_dma_inst, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
	XAxiDma_IntrDisable(_dma_inst, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

	// Reset DMA
	reset();

	return 0;
};

void DMAEngine::reset()
{
	LOG("DMA: Resetting DMA controller..\n");
	XAxiDma_Reset(&_dma_inst);
	while (!XAxiDma_ResetIsDone(_dma_inst)) {}
};

void DMAEngine::set_rcv_buf(void* rcv_buf)
{
	_rcv_buf = rcv_buf;
};

void* DMAEngine::get_rcv_buf()
{
	return (_rcv_buf);
};

void DMAEngine::set_buf_length(int buf_length)
{
	_buf_length = buf_length;
};

int DMAEngine::get_buf_length()
{
	return _buf_length;
};

void DMAEngine::set_sample_size_bytes(int sample_size_bytes)
{
	_sample_size_bytes = sample_size_bytes;
}

int DMAEngine::get_sample_size_bytes()
{
	return _ample_size_bytes;
}

int DMAEngine::receive()
{
	// Local variables
	int       status    = 0;
	const int num_bytes = _buf_length * _sample_size_bytes;

	// Flush cache
	#if (!DMA_PASSTHROUGH_IS_CACHE_COHERENT)
		Xil_DCacheFlushRange((int)_rcv_buf, num_bytes);
	#endif

	// Kick off S2MM transfer
	status = XAxiDma_SimpleTransfer
	(
		&_dma_inst,
		(int)_rcv_buf,
		num_bytes,
		XAXIDMA_DEVICE_TO_DMA
	);

	if (status != XST_SUCCESS)
	{
		ERROR("ERROR! Failed to kick off S2MM transfer!\n\r");
		return -1;
	};

	// Wait for transfer to complete
	while (XAxiDma_Busy(&_dma_inst, XAXIDMA_DEVICE_TO_DMA)) 
	{
		// TODO: CHECK TIMEOUT
	};

	// Check DMA for errors
	if ((XAxiDma_ReadReg(_dma_inst.RegBase, XAXIDMA_RX_OFFSET+XAXIDMA_SR_OFFSET) & XAXIDMA_IRQ_ERROR_MASK) != 0)
	{
		ERROR("ERROR! AXI DMA returned an error during the S2MM transfer.\n\r");
		return -2;
	};

	return 0;
};

#endif