#include "Vsystem.h"
#include <stdio.h>
#define _XOPEN_SOURCE
#include <stdlib.h>
#include <fcntl.h>

Vsystem *top;

void term_output(unsigned char d)
{
	int fd = posix_openpt(O_RDWR);
	static int fd2 = -1;
	char b[128];

	if (fd2 == -1)
	{
		grantpt(fd);  
		fcntl(fd, F_SETFD, 0);	/* clear close-on-exec */
		sprintf(b, "rxvt -pty-fd %d -bg black -fg white -title \"Output terminal\" &", fd);
		system(b);
		unlockpt(fd);
		fd2 = open(ptsname(fd), O_RDWR);
		close(fd);
	}
	write(fd2, &d, 1);
}

unsigned int main_time = 0;

double sc_time_stamp ()
{
	return main_time;
}

int main()
{
	top = new Vsystem;
	
	top->clk = 0;
	while (!Verilated::gotFinish())
	{
		top->clk = !top->clk;
		
		top->eval();
//		if (top->clk == 1)
//			printf("%d: Bubble: %d. PC: %08x. Ins'n: %08x\n", main_time/2, top->bubbleshield, top->pc, top->insn);
		
		main_time++;
	}
}
