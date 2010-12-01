/* multibuf.h
 * Declarations for triple buffering
 */

#ifndef MULTIBUF_H
#define MULTIBUF_H

typedef struct {
	unsigned int *bufs[3];
	unsigned int *bufs_orig[3];
	int which;
} multibuf_t;

unsigned int *multibuf_init(multibuf_t *bufs, unsigned int width, unsigned int height);
unsigned int *multibuf_flip(multibuf_t *bufs);

#endif
