


typedef int kh_type;

#define KH_STATE_SHIFT 16
#define KH_STATE_SMASK 0xF

enum kh_extended_e {

	KHE_ARROW_UP = 0x81,
	KHE_ARROW_LEFT,
	KHE_ARROW_DOWN,
	KHE_ARROW_RIGHT,

	/* Modifiers */
	KHE_LALT,
	KHE_RALT,
	KHE_LCTL,
	KHE_RCTL,
	KHE_LSHIFT,
	KHE_RSHIFT,
	/* KHE_LGUI, */
	/* KHE_RGUI, */
	KHE_CAPSLOCK,
	KHE_NUMLOCK,

	/* F keys */
	KHE_F1,
	KHE_F2,
	KHE_F3,
	KHE_F4,
	KHE_F5,
	KHE_F6,
	KHE_F7,
	KHE_F8,
	KHE_F9,
	KHE_F10,
	KHE_F11,
	KHE_F12,

	/* Sequenced characters */
	KHE_PAUSE,
	KHE_PRINT_SCREEN,

};


