#include "sysace.h"
#include "serial.h"

void sysace_init()
{
	volatile unsigned int *sace = SYSACE_BASE;

	sace[SYSACE_BUSMODE] = SYSACE_BUSMODE_WORD;	/* Put the SystemACE in word-wide mode */
}

int sysace_getcflock()
{
	volatile unsigned int *sace = SYSACE_BASE;
	int timeout = 100000;
	
	sace[SYSACE_CONTROLREG_0] = SYSACE_CONTROLREG_0_LOCKREQ;
	
	while (!(sace[SYSACE_STATUSREG_0] & SYSACE_STATUSREG_0_MPULOCK))
		if ((timeout--) == 0)
		{
			puts("CF lock timed out!");
			return -1;
		}
	
	return 0;
}

int sysace_waitready()
{
	volatile unsigned int *sace = SYSACE_BASE;
	int timeout = 10000;
	
	while (!(sace[SYSACE_STATUSREG_0] & SYSACE_STATUSREG_0_RDYFORCFCMD))
		if ((timeout--) == 0)
		{
			puts("CF ready wait timed out!");
			return -1;
		}
	
	return 0;
}

int sysace_waitbufready()
{
	volatile unsigned int *sace = SYSACE_BASE;
	int timeout = 250000;
	
	while (!(sace[SYSACE_STATUSREG_0] & SYSACE_STATUSREG_0_DATABUFRDY))
		if ((timeout--) == 0)
		{
			puts("CF buffer ready wait timed out!");
			return -1;
		}
	
	return 0;
}


int sysace_readsec(unsigned int lbasect, unsigned int *dest)
{
	volatile unsigned int *sace = SYSACE_BASE;
	
	int i;
	
	if (sysace_getcflock() < 0)
		return -1;
	if (sysace_waitready() < 0)
		return -1;
	
	sace[SYSACE_MPULBA_0] = lbasect & 0xFFFF;
	sace[SYSACE_MPULBA_1] = lbasect >> 16;
	
	sace[SYSACE_SECCNTCMDREG] = SYSACE_SECCNTCMDREG_READ | SYSACE_SECCNTCMDREG_SECTORS(1);
		
	/* XXX they say I must hold the config controller in reset, but
	 * their source indicates that "This breaks mvl, beware!". ???
	 */
	for(i = 0; i < 512; i += 32)
	{
		int j;
		
		/* Every 16 words (32 bytes), we must wait for buffer ready. */
		if (sysace_waitbufready() < 0)
			return -1;
		
		for (j = 0; j < 32; j += 4)
		{
			unsigned int word;
			word = sace[SYSACE_DATABUFREG] & 0xFFFF;
			word |= sace[SYSACE_DATABUFREG] << 16;
			
			dest[(i+j) >> 2] = word;
		}
	}
	
	sace[SYSACE_CONTROLREG_0] = 0;
	
	return 0;
}
