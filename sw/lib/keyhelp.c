
#include "keyhelp.h"


#define KHS_SHIFT(c, s, u) \
	{ c = (key_internal_state & KH_SHIFT) ? s : u; }

/* I wish these could be shorts (instead of ints) and be initialized to zero */
#define KH_EXTENDED     0x0002
#define KH_SHIFT	0x0001
static int key_internal_state = -1;

#define KH_RELEASING	0x0001
static int key_state = -1;

kh_type process_scancode(int scancode) {

	char key;
	kh_type result;

	if (key_internal_state == -1)
		key_internal_state = 0;
	if (key_state == -1)
		key_state = 0;

	switch(scancode & 0xFF) 
	{
		case 0xE0:
			key_internal_state |= KH_EXTENDED;
			return 0;
		case 0xF0:
			/* Release signal */
			key_state |= KH_RELEASING;
			return 0;
		case 0x74:
			if (key_internal_state & KH_EXTENDED) {
				key = KHE_ARROW_RIGHT;
				break; 
			}
			return 0;
		case 0x6B:
			if (key_internal_state & KH_EXTENDED) {
				key = KHE_ARROW_LEFT;
				break; 
			}
			return 0;
		case 0x72:
			if (key_internal_state & KH_EXTENDED) {
				key = KHE_ARROW_DOWN;
				break; 
			}
			return 0;
		case 0x75:
			if (key_internal_state & KH_EXTENDED) {
				key = KHE_ARROW_UP;
				break; 
			}
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
		case 0x4E:
			KHS_SHIFT(key, '_', '-');
			break;
		case 0x55:
			KHS_SHIFT(key, '+', '=');
			break;
		case 0x54:
			KHS_SHIFT(key, '{', '[');
			break;
		case 0x5B:
			KHS_SHIFT(key, '}', ']');
			break;
		case 0x5D:
			KHS_SHIFT(key, '|', '\\');
			break;
		case 0x4C:
			KHS_SHIFT(key, ':', ';');
			break;
		case 0x52:
			KHS_SHIFT(key, '"', '\'');
			break;
		case 0x0E:
			KHS_SHIFT(key, '~', '`');
			break;
		case 0x41:
			KHS_SHIFT(key, '<', ',');
			break;
		case 0x49:
			KHS_SHIFT(key, '>', '.');
			break;
		case 0x4A:
			KHS_SHIFT(key, '?', '/');
			break;
		case 0x5A:
			key = '\n';
			break;
		case 0x29:
			key = ' ';
			break;
		case 0x66:
			key = '\b';
			break;
		case 0x0D:
			key = '\t';
			break;
		/* Left shift, Right Shift. 
		   Treating them the same causes a bug when you hold both shifts and let go of one of them
		   but that isn't really normal typing... So... */
		case 0x12:
		case 0x59:
			if (key_state & KH_RELEASING) 
			{ 
				key_internal_state &= ~KH_SHIFT;
				key_state &= ~KH_RELEASING;
			}
			else 
			{
				key_internal_state |= KH_SHIFT;
			}
			return 0;
		default:
			key_internal_state &= ~KH_EXTENDED; 
			key_state &= ~KH_RELEASING;	
			return 0;
	}
	result = (key_state << KH_STATE_SHIFT) | key;
	key_internal_state &= ~KH_EXTENDED; 
	key_state &= ~KH_RELEASING;
	return result;	
}



