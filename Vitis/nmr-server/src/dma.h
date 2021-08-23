#ifdef DO_NOT_COMPILE

#ifndef __DMA_H
#define __DMA_H

#include <stdint.h>
#include <stdlib.h>

#include "xaxidma.h"

class DMAEngine
{
	public:
		DMAEngine();
		~DMAEngine();
		static int init();
		void  reset();
		void  set_rcv_buf(void* rcv_buf);
		void* get_rcv_buf();
		void set_buf_length(int buf_length);
		int get_buf_length();
		void set_sample_size_bytes(int sample_size_bytes);
		int get_sample_size_bytes();
		int receive();

	private:
		XAxiDma _dma_inst;
		void* _rcv_buf;
		int _buf_length;
		int _sample_size_bytes;
};


#endif // __DMA_H

#endif
