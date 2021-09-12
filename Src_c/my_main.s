	.file	"my_main.c"
	.option nopic
	.text
	.globl	A
	.section	.sdata,"aw"
	.align	2
	.type	A, @object
	.size	A, 4
A:
	.word	5
	.globl	B
	.align	2
	.type	B, @object
	.size	B, 4
B:
	.word	10
	.globl	C
	.section	.sbss,"aw",@nobits
	.align	2
	.type	C, @object
	.size	C, 4
C:
	.zero	4
	.text
	.align	2
	.globl	_start
	.type	_start, @function
_start:
	addi	sp,sp,-16
	sw	s0,12(sp)
	addi	s0,sp,16
	lui	a5,%hi(A)
	lw	a4,%lo(A)(a5)
	lui	a5,%hi(B)
	lw	a5,%lo(B)(a5)
	add	a4,a4,a5
	lui	a5,%hi(C)
	sw	a4,%lo(C)(a5)
	nop
	lw	s0,12(sp)
	addi	sp,sp,16
	jr	ra
	.size	_start, .-_start
	.ident	"GCC: (GNU) 11.1.0"
	.section	.note.GNU-stack,"",@progbits
