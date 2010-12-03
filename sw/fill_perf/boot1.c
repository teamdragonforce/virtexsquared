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

struct img_resource
{
	unsigned int w;
	unsigned int h;
	unsigned int *pixels;
};

struct img_resource *img_load(struct fat16_handle *h, char *name)
{
	int rv;
	struct fat16_file fd;
	struct img_resource *r;
	
	printf("Loading image resource %s... ", name);
	if (fat16_open_by_name(h, &fd, name) == -1)
	{
		printf("not found?\r\n");
		return NULL;
	} 
	
	r = malloc(sizeof(*r));
	if (!r)
	{
		printf("out of memory?\r\n");
		return NULL;
	}
	
	r->pixels = malloc(fd.len + 64);
	if (!r->pixels)
	{
		printf("out of memory?\r\n");
		return NULL;
	}
	
	r->pixels = (unsigned int *)(((unsigned int)r->pixels + 63) & ~63);

	rv = fat16_read(&fd, (void *)r, 8);
	
	rv = fat16_read(&fd, (void *)r->pixels, fd.len - 8);
	if (rv != fd.len - 8) {
		printf("short read (%d)\r\n", rv);
		free(r);
		return NULL;
	}

	printf("%dx%d image (pixels at %08x)\r\n", r->w, r->h, r->pixels);
	
	return r;
}


void main()
{
	int i = 0;
	int x;
	struct img_resource *r;
	
	volatile unsigned int *num_clock_cycles = 0x86000000;
	unsigned int **frame_start = 0x82000000;
	unsigned int *start = 0x00600000;
	
	int fat16_start;
	struct fat16_handle h;

	printf("Reading partition table... ");
	fat16_start = fat16_find_partition();
	if (fat16_start < 0)
	{
		puts("no FAT16 partition found!");
		return;
	}
	printf("found starting at sector %d.\r\n", fat16_start);
	
	printf("Opening FAT16 partition... ");
	if (fat16_open(&h, fat16_start) < 0)
	{
		puts("FAT16 boot sector read failed!");
		return;
	}
	puts("OK");

	
	*frame_start = start;
	r = img_load(&h, "LEFT_4  RES");
	
	printf("in main...\r\n");
	x = 0;
	accel_fill(start, 0x80808080, 640*480);
	while (1)
	{
		int y;
		if ((i % 64) == 0)
			printf("iters: %d, i %% 100 = %d, clock cycles: %d\r\n", i, ((unsigned int)i) % 100U, *num_clock_cycles);
		for (y = 0; y < 448; y += 64)
			accel_blit(start + y * 640 + x, r->pixels, r->w, r->h);
		x += 16;
		if (x == 512)
			x = 0;	
		i++;
	}
}

