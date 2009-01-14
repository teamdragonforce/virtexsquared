	.text
	.globl _start
_start:
	ldr sp, =0x3FFC
	bl main
1:	b 1b

	.globl putc
putc:
	mcr 5, 0, r0, c0, c0
	mov pc, lr
