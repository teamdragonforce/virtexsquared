	.text
	.globl _start
_start:
	mov sp, #0x3000
	bl main
1:	b 1b

	.globl putc
putc:
	mcr 5, 0, r0, c0, c0
	mov pc, lr
