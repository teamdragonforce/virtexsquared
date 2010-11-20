#ifndef _CONSOLE_H
#define _CONSOLE_H

#include <stdarg.h>

extern void cons_drawchar(int c, int x, int y, int fg, int bg);
extern void cons_set_position(int _x, int _y);
extern void cons_set_color(int _fg, int _bg);
extern void cons_putchar(int c);
extern void cons_clear();
int cons_vprintf(const char *fmt, va_list args);
int cons_printf(const char *fmt, ...);

#endif
