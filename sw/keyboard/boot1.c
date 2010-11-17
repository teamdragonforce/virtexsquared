#include "serial.h"
#include "sysace.h"
#include "keyhelp.h"
#include "minilib.h"

void main()
{

	volatile unsigned int *scancodeaddr = 0x85000000;
	unsigned int scancode;

	kh_type k;

	while(1) {
		scancode = *scancodeaddr;
		if (scancode == 0xffffffff)
			continue;
		k = process_scancode(scancode);
		if (k) {
			if (k & 0x10000) 
				printf("Releasing ");
			printf(" %c\r\n", (char)(k & 0xFF));
		}
	}

}
