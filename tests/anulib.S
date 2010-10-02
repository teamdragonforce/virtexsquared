	.text
	.globl _start
_start:
	ldr sp, =0x3FFC
	bl main
1:	b 1b

