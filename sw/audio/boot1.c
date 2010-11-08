#include "serial.h"
#include "sysace.h"

#define SAMPLE_RATE 48000
#define F 1000
#define T (SAMPLE_RATE / F)

void main()
{
	int *dma_start  = (int*) 0x84000000;
	int *dma_length = (int*) 0x84000004;
	int *dma_cmd    = (int*) 0x84000008;
	int *dma_nREad  = (int*) 0x8400000c;
	short *mem = (short*) (6 * (1<<20));
	int sample;
	int count;
	int state = 0;
	puts("Generating samples... ");
	for (sample = 0; sample < 2*SAMPLE_RATE; sample++, count++) {
		if (count == (T >> 1)) {
			state = ~state;
			count = 0;
		}
		//if ((sample / T) % 2 == 0) {
		if (state) {
			mem[2*sample]   = -10000;
			mem[2*sample+1] = -10000;
		}
		else {
			mem[2*sample]   = 10000;
			mem[2*sample+1] = 10000;
		}
	}
	puts("done!\r\n");

	puts("Launching audio DMA...\r\n");
	*dma_start = mem;
	*dma_length = SAMPLE_RATE*2*2*2;
	*dma_cmd = 1;
	return 0;
}
