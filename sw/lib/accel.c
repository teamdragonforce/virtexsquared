#include "minilib.h"
#include "accel.h"

#define P(x) (*(volatile unsigned int *)(x))

void accel_fill(unsigned int *base, unsigned int value, unsigned int words)
{
	if (words % 8)
		printf("ACCEL: fill word count not multiple of 2\r\n");
	
	P(FILL_VALUE) = value;
	P(FILL_ADDR) = (unsigned int)base;
	P(FILL_LENREM) = words / 2;
	
	while (P(FILL_LENREM) != 0)
	{
		int i;
		
		for (i = 0; i < 100; i++)
			P(FILL_VALUE); /* times out */
	}
}

void accel_blit(unsigned int *dest, unsigned int *src, unsigned int w, unsigned int h)
{
	int packets = (w / 16) * h;
	
	if (w % 16)
		printf("ACCEL: blit width not multiple of 16 pxls\r\n");
	if ((unsigned int)dest & 63)
		printf("ACCEL: destination alignment for blit incorrect\r\n");
	if ((unsigned int)src & 63)
		printf("ACCEL: source alignment for blit incorrect\r\n");
	
	P(BLIT_WRADDR) = (unsigned int)dest;
	P(BLIT_WRROWL) = w / 16;
	P(BLIT_WRROWS) = 640 * 4;
	P(BLIT_WRDONE) = 0;
	
	P(BLIT_RDADDR) = (unsigned int)src;
	P(BLIT_RDLEN) = packets;
	
	while (P(BLIT_WRDONE) != packets)
	{
		int i;
		for (i = 0; i < 10; i++)
			P(BLIT_RDADDR);	/* times out */
	}
}
