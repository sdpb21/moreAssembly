.data

score:	.asciiz	"Score: 0\n"
field:	.asciiz	"#########\n"
	.asciiz	"#  R    #\n"
	.asciiz	"#       #\n"
	.asciiz	"#  P    #\n"
	.asciiz	"#       #\n"
	.asciiz	"#       #\n"
	.asciiz	"#########\n!"

.text

	li $s0, 0xffff0000	# load the base address of MMIO area in $s0

	# printing the score
	andi $t1, 0		# clear $t1
printScore: lb $a0, score($t1)	# load the byte on $t1 position from score, in $a0
	jal displayReady	# print the byte loaded on MMIO display
	addi $t1, $t1, 1	# increments $t1 to go for the next byte in score string
	bne $a0, $zero, printScore # if char is not null, repeat

	# printing the field
	andi $t1, 0		# clear $t1 again
printField: lb $a0, field($t1)	# load the byte on $t1 position from field, in $a0
	beq $a0,'!', fieldEnd	# field end byte found, do not print, jump to fieldEnd label
	jal displayReady	# print the byte loaded on MMIO display
	addi $t1, $t1, 1	# go to the next byte to print
fieldEnd: bne $a0, '!', printField # if byte isn't '!', repeat

	# get input on MMIO keyboard simulator
keyboardReady:lw $t0, 0($s0)	# load the keyboard control register in $t0
	andi $t0, $t0, 1	# check if bit 0 in keyboard control register is 1
	beq $t0, $zero, keyboardReady # if bit 0 of keyboard control register is 0, check again
	lb $a0, 4($s0)		# load byte readed from keyboard data register

	beq $a0, 'w', up	# go to up label if $a0 is equal to 'w'
	beq $a0, 'a', left	# go to left label if $a0 is equal to 'a'
	beq $a0, 's', down	# go to down label if $a0 is equal to 's'
	beq $a0, 'd', right	# go to right label if $a0 is equal to 'd'
	j keyboardReady		# if $a0 is none of the above, read again

up:
left:
down:
right:

	j stop			# jumps to stop label to stop the program

	# to print on MMIO display
displayReady: lw $t0, 8($s0)	# load the display control register in $t0
	andi $t0, $t0, 1	# check if bit 0 in display control register is 1
	beq $t0, $zero, displayReady # if display control register bit 0 is 0 check again
	sb $a0, 12($s0)		# store data to print in display data register
	jr $ra			# jump to the next line where displayReady was called

stop:	li $v0, 10		# load 10 in $v0 to stop program from running
	syscall			# stop program from running
