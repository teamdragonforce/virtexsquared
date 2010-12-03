#ifndef _ACCEL_H
#define _ACCEL_H

#define ACCEL_BASE  0x87000000

#define FILL_BASE   (ACCEL_BASE + 0x000000)
#define FILL_VALUE  (FILL_BASE + 0x0)
#define FILL_ADDR   (FILL_BASE + 0x4)
#define FILL_LENREM (FILL_BASE + 0x8)

#define BLIT_BASE   (ACCEL_BASE + 0x100000)
#define BLIT_RDADDR (BLIT_BASE + 0x0)
#define BLIT_RDLEN  (BLIT_BASE + 0x4)
#define BLIT_WRADDR (BLIT_BASE + 0x8)
#define BLIT_WRROWL (BLIT_BASE + 0xC)
#define BLIT_WRROWS (BLIT_BASE + 0x10)
#define BLIT_WRDONE (BLIT_BASE + 0x14)

extern void accel_fill(unsigned int *base, unsigned int value, unsigned int words);
extern void accel_blit(unsigned int *dest, unsigned int *src, unsigned int w, unsigned int h); 

#endif
