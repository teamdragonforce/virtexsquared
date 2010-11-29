/** @file libqalloc/qalloc.h
 *  @brief Fixed-heap allocator.
 *  @author elly1 S2009
 *  @author mjsulliv S2010
 */

#ifndef QALLOC_H
#define QALLOC_H

typedef struct _qarena_t {
	unsigned int size;
	/* ...fill in more stuff... */
} qarena_t;

extern qarena_t *qinit(void *start, unsigned size);
extern void *qalloc(qarena_t *arena, unsigned size);
extern void qfree(qarena_t *arena, void *ptr);

#endif /* !QALLOC_H */
