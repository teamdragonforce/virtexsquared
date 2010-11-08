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

#define SACE_CONTROLREG_0 (0xC << 1)
#define SACE_CONTROLREG_0_LOCKREQ 0x2

#define SACE_STATUSREG_0 (0x2 << 1)
#define SACE_STATUSREG_0_MPULOCK 0x2
#define SACE_STATUSREG_0_RDYFORCFCMD 0x100
#define SACE_STATUSREG_0_DATABUFRDY 0x20

#define SACE_MPULBA_0 (0x8 << 1)
#define SACE_MPULBA_1 (0x9 << 1)

#define SACE_SECCNTCMDREG (0xA << 1)
#define SACE_SECCNTCMDREG_READ (0x3 << 8)
#define SACE_SECCNTCMDREG_SECTORS(x) ((x) & 0xFF)

#define SACE_DATABUFREG (0x20 << 1)

void systemace()
{
	unsigned int *sace = 0x83000000;

	sace[0x0] = 0x1;	/* Put the SystemACE in word-wide mode */

	puts("[status: ");
	puthex(sace[0x2 << 1]);
	puts("] [error: ");
	puthex(sace[0x4 << 1]);
	puts("] [version: ");
	puthex(sace[0xB << 1]);
	puts("] [fatstat: ");
	puthex(sace[0xE << 1]);
	puts("]\n");
}

/* CF = ClusterFuck */
void systemace_getcflock()
{
	volatile unsigned int *sace = 0x83000000;
	int timeout = 10000;
	
	sace[SACE_CONTROLREG_0] = SACE_CONTROLREG_0_LOCKREQ;
	
	while (!(sace[SACE_STATUSREG_0] & SACE_STATUSREG_0_MPULOCK))
		if ((timeout--) == 0)
		{
			puts("CF lock timed out!\n");
			return;
		}
}

void systemace_waitready()
{
	volatile unsigned int *sace = 0x83000000;
	int timeout = 10000;
	
	while (!(sace[SACE_STATUSREG_0] & SACE_STATUSREG_0_RDYFORCFCMD))
		if ((timeout--) == 0)
		{
			puts("CF ready wait timed out!\n");
			return;
		}
}

void systemace_waitbufready()
{
	volatile unsigned int *sace = 0x83000000;
	int timeout = 250000;
	
	while (!(sace[SACE_STATUSREG_0] & SACE_STATUSREG_0_DATABUFRDY))
		if ((timeout--) == 0)
		{
			puts("CF buffer ready wait timed out!\n");
			return;
		}
}


void systemace_cfread()
{
	volatile unsigned int *sace = 0x83000000;
	volatile unsigned int *dest = 0x00200000;	/* +2MB */
	
	int i;
	
	systemace_getcflock();
	systemace_waitready();
	
	sace[SACE_MPULBA_0] = 0x0;
	sace[SACE_MPULBA_1] = 0x0;
	
	sace[SACE_SECCNTCMDREG] = SACE_SECCNTCMDREG_READ | SACE_SECCNTCMDREG_SECTORS(1);
		
	puts("[read: ");
	/* XXX they say I must hold the config controller in reset, but
	 * their source indicates that "This breaks mvl, beware!". ???
	 */
	for(i = 0; i < 512; i += 32)
	{
		int j;
		
		/* Every 16 words (32 bytes), we must wait for buffer ready. */
		systemace_waitbufready();
		
		for (j = 0; j < 32; j += 4)
		{
			unsigned int word;
			word = sace[SACE_DATABUFREG] & 0xFFFF;
			word |= sace[SACE_DATABUFREG] << 16;
			
			dest[(i+j) >> 2] = word;
		}
		puts("B");
	}
	puts("] [first word: ");
	
	puthex(dest[0]);
	puts("]");
	
	sace[SACE_CONTROLREG_0] = 0;
	
	puts("[jump: ");
	puthex(((int (*)())dest)());
	puts("]\n");
}

struct tests tlist[] = {
	{"SystemACE", systemace},
	{"ldm pc/mul", ldm_tester},
	{"fact", facttest},
	{"j4cbo", j4cbo},
	//{"lcd", lcd},
	// Disabled to avoid slowing down the testbench.
	{"ack", acktest},
	{"miniblarg", testmain},
	{"corecurse", corecurse},
	{"systemace_cfread", systemace_cfread},
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
