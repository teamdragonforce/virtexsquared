/* multibuf.c
 * Definitions for triple buffering
 */

#include "malloc.h"
#include "multibuf.h"

/* Utility function because we don't trust % on this system */
static unsigned int getnext_mod3(unsigned int x){
	if (x == 0)
		return 1;
	if (x == 1)
		return 2;
	if (x == 2)
		return 0;
}

unsigned int *multibuf_init(multibuf_t *tbuf, unsigned int width, unsigned int height)
{
	tbuf->bufs_orig[0] = malloc(width*height*4 + 64);
	tbuf->bufs_orig[1] = malloc(width*height*4 + 64);
	tbuf->bufs_orig[2] = malloc(width*height*4 + 64);
	tbuf->bufs[0] = (unsigned int *) (((unsigned int) tbuf->bufs_orig[0] + 64) & ~63U);
	tbuf->bufs[1] = (unsigned int *) (((unsigned int) tbuf->bufs_orig[1] + 64) & ~63U);
	tbuf->bufs[2] = (unsigned int *) (((unsigned int) tbuf->bufs_orig[2] + 64) & ~63U);
	accel_fill(tbuf->bufs[0], 0x00000000, width*height);
	accel_fill(tbuf->bufs[1], 0x00000000, width*height);
	accel_fill(tbuf->bufs[2], 0x00000000, width*height);
	printf("tbuf: origs %08x %08x %08x, bufs %08x %08x %08x\r\n", tbuf->bufs_orig[0], tbuf->bufs_orig[1], tbuf->bufs_orig[2], tbuf->bufs[0], tbuf->bufs[1], tbuf->bufs[2]);
	tbuf->which = 0;

	return multibuf_flip(tbuf);
}

unsigned int *multibuf_flip(multibuf_t *tbuf)
{
	volatile unsigned int *frame_start = 0x82000000;
	volatile unsigned int *frame_nread = 0x8200000c;
	volatile unsigned int *frame_currread = 0x82000014;

	int* buffer_curr_reading = (int*)(*frame_currread);
	*frame_start = tbuf->bufs[tbuf->which];

	unsigned int next_which = getnext_mod3(tbuf->which);

	if (tbuf->bufs[next_which] != buffer_curr_reading)
		tbuf->which = next_which;
	else
		tbuf->which = getnext_mod3(next_which);

	return tbuf->bufs[tbuf->which];
}
