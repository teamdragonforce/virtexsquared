extern void putc(unsigned char c);

int serial_getc (void)
{
	int c;
	do
		asm volatile("mrc 5, 0, %0, c1, c1, 1" : "=r"(c));
	while (!(c & 0x100));
	return c & 0xFF;
}

void puts(unsigned char *s)
{
	while (*s)
		putc(*(s++));
}

void puthex(unsigned int x)
{
	unsigned char *hex = "0123456789ABCDEF";
	int i;
	
	for (i = 7; i >= 0; i--)
		putc(hex[(x >> (i * 4)) & 0xF]);
}

#define putchar putc
#include "ack.c"
#include "j4cbo.c"
#include "corecurse.c"
#include "miniblarg.c"

int fact(int n)
{
	if (n == 0)
		return 1;
	else
		return n * fact(n-1);
}

void facttest()
{
	if (fact(10) != 3628800)
		puts("FAIL\n");
	else
		puts("PASS\n");
}

struct tests {
	char *name;
	void (*test)();
};

extern int ldm_bonehead();

#ifndef X86
int shnasto()
{
__asm__ volatile(
".globl ldm_bonehead\n"
"ldm_bonehead:;"
"mov r3, lr;"
"bl 1f;"
"nop;"
"nop;"
"nop;"
"nop;"
"nop;"
"nop;"
"nop;"
"nop;"
"nop;"
"mov pc, r3\n;"
"1:\n"
"mov r2, #0x00002F00;"
"orr r2, r2, #0x000000E0;"
"mov r1, #0x0000004C;"
"mov ip, sp;"
"stmdb sp!, {fp, ip, lr, pc};"
"mov r0, #0x00880000;"
"ldmia sp, {fp, sp, pc};"
"mul r0, r1, r2;"
"nop;"
"nop;\n"
);
}
#endif

void ldm_tester()
{
#ifdef X86
	int x = 0x00880000;
#else
	int x = ldm_bonehead();
#endif
	if (x != 0x00880000)
	{
		puts("FAIL: result was ");
		puthex(x);
		puts("\n");
	} else
		puts("PASS\n");
}

struct tests tlist[] = {
	{"ldm pc/mul", ldm_tester},
	{"fact", facttest},
	{"j4cbo", j4cbo},
	{"ack", acktest},
	{"miniblarg", testmain},
	{"corecurse", corecurse},
	{0, 0}};

int main()
{
	struct tests *t;
	
	puts("Testbench running\n");
	
	for (t = tlist; t->name; t++)
	{
		puts("Running ");
		puts(t->name);
		puts(": ");
		t->test();
	}
	puts("Done! Echoing characters.\n");
	
	while (1)
		putc(serial_getc());
	return 0;
}
