#include "Vsystem.h"
#include <stdio.h>
#define _XOPEN_SOURCE
#include <stdlib.h>
#include <fcntl.h>
#include <termios.h>

Vsystem *top;

int ptyfd = -1;

void openpty()
{
	int fd = posix_openpt(O_RDWR);
	char b[128];
	struct termios kbdios;
	
	grantpt(fd);  
	fcntl(fd, F_SETFD, 0);	/* clear close-on-exec */
	tcgetattr(fd, &kbdios);
	kbdios.c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
	tcsetattr(fd, TCSANOW, &kbdios);
	sprintf(b, "urxvt -pty-fd %d -bg black -fg white -title \"Output terminal\" &", fd);
	system(b);
	unlockpt(fd);
	ptyfd = open(ptsname(fd), O_RDWR | O_NONBLOCK);
	close(fd);
}

unsigned int term_input()
{
	int rv;
	unsigned char c;
	if (ptyfd == -1)
		openpty();
	rv = read(ptyfd, &c, 1);
	if (rv < 0)
		return 0;
	return 0x100 | c;
}

void term_output(unsigned char d)
{
	int fd = posix_openpt(O_RDWR);
	static int fd2 = -1;
	char b[128];

	if (ptyfd == -1)
		openpty();
	write(ptyfd, &d, 1);
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
		top->rst = 0;
		top->eval();
//		if (top->clk == 1)
//			printf("%d: Bubble: %d. PC: %08x. Ins'n: %08x\n", main_time/2, top->bubbleshield, top->pc, top->insn);
		
		main_time++;
	}
}
