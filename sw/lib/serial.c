#include "serial.h"

int putchar(int c)
{
	*(volatile unsigned int*)SERIAL_BASE = c;
	
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
	
	return l;
}

void puthex(unsigned int x)
{
	unsigned char *hex = "0123456789ABCDEF";
	int i;
	
	for (i = 7; i >= 0; i--)
		putchar(hex[(x >> (i * 4)) & 0xF]);
}
