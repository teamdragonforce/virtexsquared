#include "serial.h"

#define TIME ((62500000 / 57600) * 9)

static void delay()
{
	volatile unsigned int *num_clock_cycles = 0x86000000;
	unsigned int ncc = *num_clock_cycles + TIME;
	while (*num_clock_cycles < ncc)
		;
}

int putchar(int c)
{
	*(volatile unsigned int*)SERIAL_BASE = c;
	delay();
	
	return c;
}

int getc(void)
{
	unsigned int c;
	do
		c = *(volatile unsigned int*)SERIAL_BASE;
	while (!(c & 0x100));
	return c & 0xFF;
}

int puts(const unsigned char *s)
{
	int l = 0;
	
	while (*s)
	{
		putchar(*(s++));
		l++;
	}
	putchar('\r');
	putchar('\n');
	
	return l;
}

void puthex(unsigned int x)
{
	unsigned char *hex = "0123456789ABCDEF";
	int i;
	
	for (i = 7; i >= 0; i--)
		putchar(hex[(x >> (i * 4)) & 0xF]);
}
