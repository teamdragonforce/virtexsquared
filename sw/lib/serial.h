#ifndef _SERIAL_H
#define _SERIAL_H

#define SERIAL_BASE 0x80000000

extern int putchar(int c);
extern int getc(void);
extern int puts(const unsigned char *s);
extern void puthex(unsigned int x);

#endif
