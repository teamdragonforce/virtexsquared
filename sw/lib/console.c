#include "console.h"

static unsigned char chars[] = {
#include "chars.inc"
};

static int _cx = 0, _cy = 0, _cfg = 0xFFFFFFFF, _cbg = 0x00000000;

void cons_drawchar(int c, int x, int y, int fg, int bg)
{
	volatile unsigned int *fb = (volatile unsigned int *)(0x00100000 + (y * 8 * 640 + x * 8) * 4);
	int xx, yy;
	
	for (yy = 0; yy < 8; yy++)
		for (xx = 0; xx < 8; xx++)
			fb[yy * 640 + (7 - xx)] = ((chars[c*8 + yy] >> xx) & 1) ? fg : bg;
}

void cons_set_position(int x, int y)
{
	_cx = x;
	_cy = y;
}

void cons_set_color(int fg, int bg)
{
	_cfg = fg;
	_cbg = bg;
}

static void _inv_block(int x, int y)
{
	volatile unsigned int *fb = (volatile unsigned int *)(0x00100000 + (y * 8 * 640 + x * 8) * 4);
	int xx, yy;
	
	for (yy = 0; yy < 8; yy++)
		for (xx = 0; xx < 8; xx++)
			if (fb[yy * 640 + (7 - xx)] == _cbg)
				fb[yy * 640 + (7 - xx)] = _cfg;
			else
				fb[yy * 640 + (7 - xx)] = _cbg;
}

void cons_putchar(int c)
{
	_inv_block(_cx, _cy);

	switch (c)
	{
	case '\n':
		_cy++;
		_cx = 0;
		if (_cy == 60)
		{
			cons_clear();
			return;	/* to avoid _inv_block at the end */
		}
		break;
	case '\r':
		_cx = 0;
		break;
	case '\b':
		if (_cx == 0)
			break;
		_cx--;
		break;
	default:
		cons_drawchar(c, _cx, _cy, _cfg, _cbg);
		_cx++;
		if (_cx == 80)
		{
			/* Inline this to avoid inv_block brain damage. */
			_cy++;
			_cx = 0;
			if (_cy == 60)
			{
				cons_clear();
				return;	/* to avoid _inv_block at the end */
			}
		}
		break;
	}
	
	_inv_block(_cx, _cy);
}

void cons_clear()
{
	volatile unsigned int *fb = (volatile unsigned int *)0x00100000;
	int p;
	
	for (p = 0; p < 640*480; p++)
		fb[p] = _cbg;
	
	_cx = 0;
	_cy = 0;
	
	_inv_block(_cx, _cy);
}
