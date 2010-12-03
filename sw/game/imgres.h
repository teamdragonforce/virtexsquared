#ifndef IMGRES_H
#define IMGRES_H

struct img_resource
{
	unsigned int w;
	unsigned int h;
	unsigned int *pixels;
	unsigned int *pixels_orig;
};

extern struct img_resource *img_load(struct fat16_handle *h, char *name);
extern void bitblt(unsigned int *fb, unsigned int x0, unsigned int y0, struct img_resource *r);

#endif
