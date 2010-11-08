#ifndef _SYSACE_H
#define _SYSACE_H

#define SYSACE_BASE ((volatile unsigned int *)0x83000000)

#define SYSACE_BUSMODE (0x0 << 1)
#define SYSACE_BUSMODE_WORD 0x1

#define SYSACE_CONTROLREG_0 (0xC << 1)
#define SYSACE_CONTROLREG_0_LOCKREQ 0x2

#define SYSACE_STATUSREG_0 (0x2 << 1)
#define SYSACE_STATUSREG_0_MPULOCK 0x2
#define SYSACE_STATUSREG_0_CFDETECT 0x10
#define SYSACE_STATUSREG_0_RDYFORCFCMD 0x100
#define SYSACE_STATUSREG_0_DATABUFRDY 0x20

#define SYSACE_MPULBA_0 (0x8 << 1)
#define SYSACE_MPULBA_1 (0x9 << 1)

#define SYSACE_SECCNTCMDREG (0xA << 1)
#define SYSACE_SECCNTCMDREG_READ (0x3 << 8)
#define SYSACE_SECCNTCMDREG_SECTORS(x) ((x) & 0xFF)

#define SYSACE_DATABUFREG (0x20 << 1)

extern void sysace_init();
extern int sysace_getcflock();
extern int sysace_waitready();
extern int sysace_readsec(unsigned int lbasect, unsigned int *dest);

#endif
