.data

score:	.asciiz	"Score: 0\n"
field:	.ascii	"#########\n"
	.ascii	"#  R    #\n"
	.ascii	"#       #\n"
	.ascii	"#  P    #\n"
	.ascii	"#       #\n"
	.ascii	"#       #\n"
	.ascii	"#########\n!"

.text

	li $s0, 0xffff0000	# load the base address of MMIO area in $s0
	addi $t2, $t2, 3	# player's current row
	addi $t3, $t3, 3	# player's current column

	# printing the score
start:	andi $t1, 0		# clear $t1
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

	# where to move according to keyboard input
	beq $a0, 'w', up	# go to up label if $a0 is equal to 'w'
	beq $a0, 'a', left	# go to left label if $a0 is equal to 'a'
	beq $a0, 's', down	# go to down label if $a0 is equal to 's'
	beq $a0, 'd', right	# go to right label if $a0 is equal to 'd'
	j keyboardReady		# if $a0 is none of the above, read again

up:	jal clrPosition		# clear the current player position

	# moving to up the actual player position
	addi $t2, $t2, -1	# decrements the row for player's position
	jal newPosition		# puts 'P' in the new player's position
	j start			# jump to start label to repeat all again

left:	jal clrPosition		# clear the current player position

	# move to the left the actual player's position
	addi $t3, $t3, -1	# decrements the column for player's position
	jal newPosition		# puts 'P' in the new player's position
	j start			# jumps to start label to repeat all again

down:	jal clrPosition		# clear the current player's position

	# moves to down the actual player's position
	addi $t2, $t2, 1	# increments the row for player's position
	jal newPosition		# puts 'P' in the new player's position
	j start			# jumps to start label to repeat all again

right:	jal clrPosition		# clear the current player's position

	# move to the right the actual player's position
	addi $t3, $t3, 1	# increments the column for player's position
	jal newPosition		# puts 'P' in the new player's position
	j start			# jumps to start label to repeat all again

	# procedures to reduce code lines
clrPosition: mul $t4, $t2, 10	# $t4 = player's current row * number of field columns
	add $t4, $t4, $t3	# $t4 = $t4 + player's current column
	addi $t5, $zero, ' '	# $t5 = ' '
	sb $t5, field($t4)	# clear current player position
	jr $ra			# go to the next line of jal clrPosition

newPosition: mul $t4, $t2, 10	# $t4 = player's new row * number of field columns
	add $t4, $t4, $t3	# $t4 = $t4 + player's current column
	addi $t5,$zero, 'P'	# $t5 = 'P' , player byte
	sb $t5, field($t4)	# stores 'P' in new player's position
	jr $ra			# go to the next line of jal newPosition

	j stop			# jumps to stop label to stop the program

	# to print on MMIO display
displayReady: lw $t0, 8($s0)	# load the display control register in $t0
	andi $t0, $t0, 1	# check if bit 0 in display control register is 1
	beq $t0, $zero, displayReady # if display control register bit 0 is 0 check again
	sb $a0, 12($s0)		# store data to print in display data register
	jr $ra			# jump to the next line where displayReady was called

stop:	li $v0, 10		# load 10 in $v0 to stop program from running
	syscall			# stop program from running
