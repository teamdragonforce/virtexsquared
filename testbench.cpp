#include "Vsystem.h"
#include <stdio.h>

Vsystem *top;

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
