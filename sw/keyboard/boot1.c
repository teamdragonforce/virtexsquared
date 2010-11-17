#include "serial.h"
#include "sysace.h"
#include "keyhelp.h"
#include "minilib.h"

void main()
{

	volatile unsigned int *scancodeaddr = 0x85000000;
	unsigned int scancode;

	kh_type k;
	char new_char;

	while(1) {
		scancode = *scancodeaddr;
		if (scancode == 0xffffffff)
			continue;
		k = process_scancode(scancode);
		if (KH_HAS_CHAR(k)) {
			if (KH_IS_RELEASING(k)) 
				printf("Releasing ");
			new_char = KH_GET_CHAR(k);
			switch(new_char)
			{
				case KHE_ARROW_UP:
					printf("Up");
					break;
				case KHE_ARROW_DOWN:
					printf("Down");
					break;
				case KHE_ARROW_LEFT:
					printf("Left");
					break;
				case KHE_ARROW_RIGHT:
					printf("Right");
					break;
				default:
					printf("%c", new_char);
			}	
			printf("\r\n\n");
		}
	}

}
