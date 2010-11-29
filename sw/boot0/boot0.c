#include "minilib.h"

#define FB_START 0x800000

void show_smpte_color_bars()
{
	volatile unsigned int *frame_start = (unsigned int *)0x82000000;
	volatile unsigned int *frame_autotrigger = (unsigned int *)0x82000008;
	unsigned int *d = (unsigned int *)FB_START;
	int x,y;

	*frame_start = FB_START;
	*frame_autotrigger = 2;


	for (y = 0; y < 480; y++) {
		for (x = 0; x < 640; x++) {
			if (y < 300) {
				if (x < 91) {
					*(d++) = 0xc0c0c000;
				}
				else if (x < 183) {
					*(d++) = 0xc0c00000;
				}
				else if (x < 274) {
					*(d++) = 0x00c0c000;
				}
				else if (x < 365) {
					*(d++) = 0x00c00000;
				}
				else if (x < 456) {
					*(d++) = 0xc000c000;
				}
				else if (x < 548) {
					*(d++) = 0xc0000000;
				}
				else {
					*(d++) = 0x0000c000;
				}
			}
			else if (y < 330) {
				if (x < 91) {
					*(d++) = 0x0000c000;
				}
				else if (x < 183) {
					*(d++) = 0x13131300;
				}
				else if (x < 274) {
					*(d++) = 0xc000c000;
				}
				else if (x < 365) {
					*(d++) = 0x13131300;
				}
				else if (x < 456) {
					*(d++) = 0x00c0c000;
				}
				else if (x < 548) {
					*(d++) = 0x13131300;
				}
				else {
					*(d++) = 0xc0c0c000;
				}
			}
			else {
				if (x < 114) {
					*(d++) = 0x00214c00;
				}
				else if (x < 228) {
					*(d++) = 0xffffff00;
				}
				else if (x < 342) {
					*(d++) = 0x32006a00;
				}
				else if (x < 456) {
					*(d++) = 0x13131300;
				}
				else if (x < 487) {
					*(d++) = 0x09090900;
				}
				else if (x < 518) {
					*(d++) = 0x13131300;
				}
				else if (x < 548) {
					*(d++) = 0x1d1d1d00;
				}
				else {
					*(d++) = 0x13131300;
				}
			}
		}
        }

}

/* XXX: If this is 'char' then the world ends.  This is probably a core bug
 * that needs to be intoed.  */
int pixels[][2] = {
#include "charset.h"
};

int r_int[] = { 1, 1, 0, 0, 0, 1, 0, 1, 1 };
int g_int[] = { 0, 1, 1, 1, 0, 0, 0, 1, 0 };
int b_int[] = { 0, 0, 0, 1, 1, 1, 0, 1, 0 };

unsigned char color_r(int t)
{
	int offs = (t >> 8) & 0x7;
	int c1 = r_int[offs];
	int c2 = r_int[offs+1];
	int tt = t & 0xFF;
	
	return (255-tt)*c1 + tt*c2;
}

unsigned char color_g(int t)
{
	int offs = (t >> 8) & 0x7;
	int c1 = g_int[offs];
	int c2 = g_int[offs+1];
	int tt = t & 0xFF;
	
	return (255-tt)*c1 + tt*c2;
}

unsigned char color_b(int t)
{
	int offs = (t >> 8) & 0x7;
	int c1 = b_int[offs];
	int c2 = b_int[offs+1];
	int tt = t & 0xFF;
	
	return (255-tt)*c1 + tt*c2;
}

void make_chars()
{
	int c;
	static int t = 0;
	int p;
	int tofs = 0;
	unsigned int *d = (unsigned int *)FB_START;
	
	t += 2;
	
	p = (color_r(t) << 24) | (color_g(t) << 16) | (color_b(t) << 8);
	
	for (c = 0; pixels[c][0] != -1; c++)
	{
		int x,y;
		int xofs, yofs;
		
		if (pixels[c][1] == -1)
		{
                	tofs += 10;
                	p = (color_r(t+tofs) << 24) | (color_g(t+tofs) << 16) | (color_b(t+tofs) << 8);
			continue;
		}
		
		xofs = pixels[c][0] * 8 + (640 - 536) / 2;
		yofs = (9-pixels[c][1]) * 8 + 280;
		
		for (x = 0; x < 8; x++)
			for (y = 0; y < 8; y++)
				d[(y+yofs) * 640 + (x+xofs)] = p;
	}
}

void systemace_boot()
{
	unsigned char ptab[512];
	void *dest = (void *)0x00004000;
	unsigned int lbastart = 0;
	unsigned int lbasize = 0;
	int part, i;
	int rv;
	
	puts("Attempting to boot from CompactFlash.");
	
	if (sysace_init() < 0)
	{
		puts("  no CompactFlash card; aborting boot");
		return;
	}
	
	if (sysace_readsec(0, (unsigned char *)ptab) < 0)
	{
		puts("  partition table read failed; aborting boot");
		return;
	}
	
	for (part = 0; part < 4; part++)
	{
		if (ptab[446 + 16 * part] & 0x80)
		{
			/* Found bootable partition. */
			
			lbastart = ptab[446 + 16*part + 8] |
			           ptab[446 + 16*part + 9] << 8 |
			           ptab[446 + 16*part + 10] << 16 |
			           ptab[446 + 16*part + 11] << 24;
			lbasize = ptab[446 + 16*part + 12] |
			          ptab[446 + 16*part + 13] << 8 |
			          ptab[446 + 16*part + 14] << 16 |
			          ptab[446 + 16*part + 15] << 24;
			
			break;
		}
	}
	
	if (part == 4)
	{
		puts("no bootable partition found; aborting boot");
		return;
	}
	
	puts("  boot1 partition start: ");
	putchar(' ');
	putchar(' ');
	putchar(' ');
	putchar(' ');
	puthex(lbastart);
	puts("");
	puts("  boot1 partition size: ");
	putchar(' ');
	putchar(' ');
	putchar(' ');
	putchar(' ');
	puthex(lbasize);
	puts("");
	
	if (lbasize > 1024)	/* 512kbyte max */
		lbasize = 1024;
	
	for (i = 0; i < lbasize; i++)
	{
		if (sysace_readsec(lbastart + i, dest) < 0)
		{
			puts("  sector read failed; aborting boot");
			return;
		}
		dest += 512;
	}
	
	puts("Starting boot1.");
	((void (*)())0x00004000)();
}

int main()
{
	struct tests *t;
	
	puts("\r\nvirtexsquared BIOS\r\n");
	
	show_smpte_color_bars();
	make_chars();
	systemace_boot();

	puts("Control returned to boot0; press reset to retry boot");
	
	while (1)
		make_chars();

	return 0;
}
