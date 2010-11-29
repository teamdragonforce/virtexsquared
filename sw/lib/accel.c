#include "minilib.h"
#include "accel.h"

void accel_fill(unsigned int *base, unsigned int value, unsigned int words)
{
	if (words % 8)
		printf("ACCEL: fill word count not multiple of 2\r\n");
	
	*(volatile unsigned int *)FILL_VALUE = value;
	*(volatile unsigned int *)FILL_ADDR = (unsigned int)base;
	*(volatile unsigned int *)FILL_LENREM = words / 2;
	
	while (*(volatile unsigned int *)FILL_LENREM != 0)
	{
		int i;
		
		for (i = 0; i < 100; i++)
			*(volatile unsigned int *)FILL_VALUE; /* times out */
	}
}