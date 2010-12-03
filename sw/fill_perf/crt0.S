	.text
	.globl _start
_start:
	ldr r0, .bss_start
	ldr r1, .end
	mov r2, #0
1:	cmp r0, r1
	beq 2f
	str r2, [r0], #4
	b 1b
2:
	b main

.bss_start:
	.word __bss_start
.end:
	.word _end