#include "keyhelp.h"
#include "audio.h"
#include "fat16.h"
#include "minilib.h"
#include "accel.h"

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

unsigned int getp(int t)
{
	return (color_r(t) << 24) | (color_g(t) << 16) | (color_b(t) << 8);
}

void main()
{
	int i = 0;
	
	volatile unsigned int *num_clock_cycles = 0x86000000;
	unsigned int **frame_start = 0x82000000;
	unsigned int *start = 0x00600000;
	
	*frame_start = start;
	
	printf("in main...\r\n");
	while (1)
	{
		if ((i % 64) == 0)
			printf("iters: %d, i %% 100 = %d, clock cycles: %d\r\n", i, ((unsigned int)i) % 100U, *num_clock_cycles);
		accel_fill(start, getp(i), 640*480);
		i++;
	}
}

