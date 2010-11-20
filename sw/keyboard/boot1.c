#include "serial.h"
#include "sysace.h"
#include "keyhelp.h"
#include "minilib.h"
#include "console.h"

void main()
{
	volatile unsigned int *scancodeaddr = 0x85000000;

	unsigned int scancode;
	unsigned int x = 0, y = 0;

	kh_type k;
	char new_char;
	
	cons_clear();
	cons_printf("virtexsquared keyboard demo\n\n");
	cons_printf("here we go!\n\n");
	
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
				case '\b':
					printf("Backspace");
					if (KH_IS_RELEASING(k))
						break;
					
					cons_putchar('\b');
					break;
				case '\n':
					printf("Enter");
					if (KH_IS_RELEASING(k))
						break;
					
					cons_putchar('\n');
					break;
				default:
					printf("%c", new_char);
					if (KH_IS_RELEASING(k))
						break;
					
					cons_putchar(new_char);
					break;
			}	
			printf("\r\n\n");
		}
	}

}
