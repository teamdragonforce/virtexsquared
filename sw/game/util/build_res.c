#include <stdio.h>
#include <stdlib.h>

void main()
{
	unsigned int i, *p;
	
	if (IMG.bytes_per_pixel != 4)
	{
		fprintf(stderr, "error: not RGBA? :fu -100\n");
		exit(1);
	}

	write(1, &IMG.width, 4);
	write(1, &IMG.height, 4);
	
#define FROB(x) (((x>>24) & 0xff) | ((x >> 8) & 0xff00) | ((x << 8) & 0xff0000) | ((x << 24) & 0xff000000))
	
	p = (unsigned int *)IMG.pixel_data;
	for (i = 0; i < IMG.width * IMG.height; i++)
	{
		unsigned int p2;
		p2 = FROB(p[i]);
		write(1, &p2, 4);
	}
	exit(0);
}
