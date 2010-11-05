#ifdef X86
extern void putchar(unsigned int c);
void putc(unsigned char c)
{
	putchar(c);
}

#else
void putc(unsigned char c)
{
	*(volatile unsigned int*)0x80000000 = c;
}
#endif

int serial_getc (void)
{
	int c;
	do
		c = *(volatile unsigned int*)0x80000000;
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

void cellularram()
{
	volatile int *p = 0x80010000;
	
	puts("[writing] ");
	p[0] = 0x12345678;
	p[1] = 0x87654321;
	p[2] = 0xAAAA5555;
	p[3] = 0x5555AAAA;
	puts("[cache flush] ");
	p[0x1000] = 0x00000000;
	puts("[reading: ");
	puthex(p[0]);
	puthex(p[1]);
	puthex(p[2]);
	puthex(p[3]);
	puts("]\n");
}

void show_on_screen()
{
	int *frame_start = 0x82000000;
	
	*frame_start = 0x00100000;
	
	unsigned int *d = 0x00100000;
	int x,y;

	puts("Painting screen...\n");
	for (y = 0; y < 480; y++) {
		for (x = 0; x < 640; x++)
			*(d++) = ((x >> 1) ^ (x << 10) ^ (x << 20)) ^ ((y >> 1) ^ (y << 10) ^ (y << 20));
        }


	int *frame_autotrigger = 0x82000008;
	*frame_autotrigger = 2;

	puts("You should now see bullshit on the screen.\n");
}

void waitok()
{
	volatile unsigned int *lcd_insn = 0x81000000;
	volatile unsigned int *lcd_data = 0x81000004;

	int i;
	
	for (i = 0; i < 512; i++)
	{
		int a,b;
		a = *lcd_insn;
		b = *lcd_insn;
		
		if (a & 0x8) {
			puts("[ok] ");
			puthex(a);
			break;
		}
	}

}

void lcd()
{
	volatile unsigned int *lcd_insn = 0x81000000;
	volatile unsigned int *lcd_data = 0x81000004;
	int i;
	volatile unsigned int *j = &i;
	
	puts("[func] ");
	*lcd_insn = 0x2;	/* init, 4 bit */
	
	for (i = 0; i < 8192; i++)
		*j;
	
	*lcd_insn = 0x2;	/* 4 bit */
	*lcd_insn = 0x8;	/* 2 lines */
	
	for (i = 0; i < 8192; i++)
		*j;

//	waitok();
	
	puts("[enabling] ");
	*lcd_insn = 0x0;	/* display on */
	*lcd_insn = 0xC;
	for (i = 0; i < 8192; i++)
		*j;

//	waitok();
	
	puts("[char] ");
	*lcd_data = 0x4;
	*lcd_data = 0x1;
	for (i = 0; i < 4096; i++)
		*j;

	*lcd_data = 0x5;
	*lcd_data = 0x3;
	for (i = 0; i < 8192; i++)
		*j;

	*lcd_data = 0x5;
	*lcd_data = 0x3;
	for (i = 0; i < 8192; i++)
		*j;

//	waitok();
	
	puts("\n");
}

struct tests tlist[] = {
	{"screen", show_on_screen},
	/*{"ldm pc/mul", ldm_tester},
	{"fact", facttest},
	{"j4cbo", j4cbo},
	//{"lcd", lcd},
	// Disabled to avoid slowing down the testbench.
	{"ack", acktest},
	{"miniblarg", testmain},
	{"corecurse", corecurse},*/
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
