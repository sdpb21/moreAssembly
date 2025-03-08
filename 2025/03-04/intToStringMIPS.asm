.data
str:   .space 128         # bytes for string version of the number

.text

main:

	li $a0, 1102	# $a0 = int to convert
	la $a1, str	# $a1 = address of string where converted number will be kept
	jal int2str	# call int2str

	la $a0, str	# once returned, str has the string version. Print it.
	li $v0, 4	# $v0 = 4 for printing string pointed to by $a0
	syscall		# after this, the console has '-1102'

	li $v0,10	#store 10 on $v0 to exit
	syscall		#call system

# inputs : $a0 -> integer to convert
#          $a1 -> address of string where converted number will be kept
# outputs: none

int2str: addi $sp, $sp, -4	# to avoid headaches save $t- registers used in this procedure on stack
	sw $t0, ($sp)	# so the values don't change in the caller. We used only $t0 here, so save that.
	bltz $a0, neg_num	# is num < 0 ?
	j next0		# else, goto 'next0'

neg_num: li   $t0, '-'	# body of "if num < 0:"
	sb $t0, ($a1)	# *str = ASCII of '-' 
	addi $a1, $a1, 1	# str++
	li $t0, -1
	mul $a0, $a0, $t0	# num *= -1

next0: li $t0, -1
	addi $sp, $sp, -4	# make space on stack
	sw $t0, ($sp)	# and save -1 (end of stack marker) on MIPS stack

push_digits: blez $a0, next1	# num < 0? If yes, end loop (goto 'next1')
	li $t0, 10	# else, body of while loop here
	div $a0, $t0	# do num / 10. LO = Quotient, HI = remainder
	mfhi $t0	# $t0 = num % 10
	mflo $a0	# num = num // 10

	addi $sp, $sp, -4	# make space on stack
	sw $t0, ($sp)	# store num % 10 calculated above on it
	j push_digits	# and loop

next1:	lw $t0, ($sp)	# $t0 = pop off "digit" from MIPS stack
	addi $sp, $sp, 4	# and 'restore' stack

	bltz $t0, neg_digit	# if digit <= 0, goto neg_digit (i.e, num = 0)
	j pop_digits	# else goto popping in a loop

neg_digit: li   $t0, '0'
	sb $t0, ($a1)	# *str = ASCII of '0'
	addi $a1, $a1, 1	# str++
	j next2		# jump to next2

pop_digits: bltz $t0, next2	# if digit <= 0 goto next2 (end of loop)
	addi $t0, $t0, '0'	# else, $t0 = ASCII of digit
	sb $t0, ($a1)	# *str = ASCII of digit
	addi $a1, $a1, 1	# str++

	lw $t0, ($sp)	# digit = pop off from MIPS stack 
	addi $sp, $sp, 4	# restore stack
	j pop_digits	# and loop

next2:	sb  $zero, ($a1)	# *str = 0 (end of string marker)
	lw $t0, ($sp)	# restore $t0 value before function was called
	addi $sp, $sp, 4	# restore stack
	jr $ra		# jump to caller
