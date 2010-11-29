#include "qalloc.h"

#define TOP_OF_MEMORY (128*1024*1024)

static int _arena_initialized = 0;

extern void _end;

static qarena_t *_arena;

static void _malloc_init()
{
	if (_arena_initialized)
		return;
	
	_arena_initialized = 1;
	_arena = qinit(&_end, TOP_OF_MEMORY - (unsigned int)&_end);
}

void *malloc(unsigned int size)
{
	_malloc_init();
	
	return qalloc(_arena, size);
}

void free(void *ptr)
{
	_malloc_init();
	
	qfree(_arena, ptr);
}
