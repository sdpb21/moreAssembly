.data

score:	.asciiz	"Score: 0"

.text

	li $s0, 0xffff0000	# load the base address of MMIO area in $s0

	# printing the score
printScore: lb $a0, score($t1)	# load the byte on $t1 position in $a0
	jal displayReady	# print the byte loaded on MMIO display
	addi $t1, $t1, 1	# increments $t1 to go for the next byte in score string
	bne $a0, $zero, printScore # if char is not null, repeat
	j stop			# jumps to stop label to stop the program

	# to print on MMIO display
displayReady: lw $t0, 8($s0)	# load the display control register in $t0
	andi $t0, $t0, 1	# check if bit 0 in display control register is 1
	beq $t0, $zero, displayReady # if display control register bit 0 is 0 check again
	sb $a0, 12($s0)		# store data to print in display data register
	jr $ra			# jump to the next line where displayReady was called

stop:	li $v0, 10		# load 10 in $v0 to stop program from running
	syscall			# stop program from running
