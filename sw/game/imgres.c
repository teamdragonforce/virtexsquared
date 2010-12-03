#include "fat16.h"
#include "imgres.h"
#include "minilib.h"

#define SCREEN_WIDTH 640

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
	
	r->pixels_orig = malloc(fd.len + 64);
	if (!r->pixels_orig)
	{
		printf("out of memory?\r\n");
		return NULL;
	}
	
	r->pixels = (unsigned int *)(((unsigned int)r->pixels_orig + 63) & ~63);

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

void bitblt(unsigned int *fb, unsigned int x0, unsigned int y0, struct img_resource *r) {
	int x, y;
	unsigned int *buf;
	
	if (((x0 + r->w) > 640) || ((y0 + r->h) > 480))
	{
		/*printf("BOUNDS CHECK!\r\n");*/
		return;
	}
	
	if (((r->w & 63) == 0) && ((x0 & 15) == 0))
	{
		/* we can take the fast path! */
		accel_blit(fb + y0 * 640 + x0, r->pixels, r->w, r->h);
		return;
	}
	
	printf("*** had to take the slow path (%d, %d)\r\n", r->w & 63, x0 & 15);
	
	buf = r->pixels;
	for (y = 0; y < r->h; y++) {
		for (x = 0; x < r->w; x+=8) {
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+0)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+1)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+2)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+3)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+4)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+5)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+6)] = *buf;
			buf++;
			
			if (*buf & 0x000000FF)
				fb[SCREEN_WIDTH*(y0+y)+(x0+x+7)] = *buf;
			buf++;
		}
	}
}
