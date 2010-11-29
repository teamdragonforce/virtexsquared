#ifndef _ACCEL_H
#define _ACCEL_H

#define ACCEL_BASE  0x87000000

#define FILL_BASE   (ACCEL_BASE + 0x000000)
#define FILL_VALUE  (FILL_BASE + 0x0)
#define FILL_ADDR   (FILL_BASE + 0x4)
#define FILL_LENREM (FILL_BASE + 0x8)

extern void accel_fill(unsigned int *base, unsigned int value, unsigned int words);

#endif
