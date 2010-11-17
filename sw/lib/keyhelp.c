
#include "keyhelp.h"


#define KHS_SHIFT(c, s, u) \
	{ c = (key_internal_state & KH_SHIFT) ? s : u; }


#define KH_SHIFT	0x0001
static short key_internal_state = 0;

#define KH_RELEASING	0x0001
static short key_state = 0;

kh_type process_scancode(int scancode) {

	char key;
	kh_type result;

	switch(scancode & 0xFF) 
	{
		case 0xF0:
			/* Release signal */
			key_state |= KH_RELEASING;
			return 0;
		case 0x1C:
			KHS_SHIFT(key, 'A', 'a');
			break;
		case 0x32:
			KHS_SHIFT(key, 'B', 'b');
			break;
		case 0x21:
			KHS_SHIFT(key, 'C', 'c');
			break;
		case 0x23:
			KHS_SHIFT(key, 'D', 'd');
			break;
		case 0x24:
			KHS_SHIFT(key, 'E', 'e');
			break;
		case 0x2B:
			KHS_SHIFT(key, 'F', 'f');
			break;
		case 0x34:
			KHS_SHIFT(key, 'G', 'g');
			break;
		case 0x33:
			KHS_SHIFT(key, 'H', 'h');
			break;
		case 0x43:
			KHS_SHIFT(key, 'I', 'i');
			break;
		case 0x3B:
			KHS_SHIFT(key, 'J', 'j');
			break;
		case 0x42:
			KHS_SHIFT(key, 'K', 'k');
			break;
		case 0x4B:
			KHS_SHIFT(key, 'L', 'l');
			break;
		case 0x3A:
			KHS_SHIFT(key, 'M', 'm');
			break;
		case 0x31:
			KHS_SHIFT(key, 'N', 'n');
			break;
		case 0x44:
			KHS_SHIFT(key, 'O', 'o');
			break;
		case 0x4D:
			KHS_SHIFT(key, 'P', 'p');
			break;
		case 0x15:
			KHS_SHIFT(key, 'Q', 'q');
			break;
		case 0x2D:
			KHS_SHIFT(key, 'R', 'r');
			break;
		case 0x1B:
			KHS_SHIFT(key, 'S', 's');
			break;
		case 0x2C:
			KHS_SHIFT(key, 'T', 't');
			break;
		case 0x3C:
			KHS_SHIFT(key, 'U', 'u');
			break;
		case 0x2A:
			KHS_SHIFT(key, 'V', 'v');
			break;
		case 0x1D:
			KHS_SHIFT(key, 'W', 'w');
			break;
		case 0x22:
			KHS_SHIFT(key, 'X', 'x');
			break;
		case 0x35:
			KHS_SHIFT(key, 'Y', 'y');
			break;
		case 0x1A:
			KHS_SHIFT(key, 'Z', 'z');
			break;
		case 0x16:
			KHS_SHIFT(key, '!', '1');
			break;
		case 0x1E:
			KHS_SHIFT(key, '@', '2');
			break;
		case 0x26:
			KHS_SHIFT(key, '#', '3');
			break;
		case 0x25:
			KHS_SHIFT(key, '$', '4');
			break;
		case 0x2E:
			KHS_SHIFT(key, '%', '5');
			break;
		case 0x36:
			KHS_SHIFT(key, '^', '6');
			break;
		case 0x3D:
			KHS_SHIFT(key, '&', '7');
			break;
		case 0x3E:
			KHS_SHIFT(key, '*', '8');
			break;
		case 0x46:
			KHS_SHIFT(key, '(', '9');
			break;
		case 0x45:
			KHS_SHIFT(key, ')', '0');
			break;
		case 0x5A:
			key = '\n';
			break;
		case 0x29:
			key = ' ';
			break;
		case 0x12:
		case 0x59:
			if (key_state & KH_RELEASING) 
				key_internal_state &= ~KH_SHIFT;
			else
				key_internal_state |= KH_SHIFT;
			return 0;
		default:
			return 0;
	}
	result = (key_state << KH_STATE_SHIFT) | key;
	key_state &= ~KH_RELEASING;
	return result;	
}



