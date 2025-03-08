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
	andi $t6, 0		# rewards counter clearing

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
	jal isReward		# looking for the reward
	jal newPosition		# puts 'P' in the new player's position
	j start			# jump to start label to repeat all again

left:	jal clrPosition		# clear the current player position

	# move to the left the actual player's position
	addi $t3, $t3, -1	# decrements the column for player's position
	jal isReward		# looking for the reward
	jal newPosition		# puts 'P' in the new player's position
	j start			# jumps to start label to repeat all again

down:	jal clrPosition		# clear the current player's position

	# moves to down the actual player's position
	addi $t2, $t2, 1	# increments the row for player's position
	jal isReward		# looking for the reward
	jal newPosition		# puts 'P' in the new player's position
	j start			# jumps to start label to repeat all again

right:	jal clrPosition		# clear the current player's position

	# move to the right the actual player's position
	addi $t3, $t3, 1	# increments the column for player's position
	jal isReward		# looking for the reward
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

isReward: addi $sp, $sp, -4	# making space in the stack for a word
	sw $ra, 0($sp)		# store the return address in the stack

	mul $t4, $t2, 10	# $t4 = player's new row * number of field columns
	add $t4, $t4, $t3	# $t4 = $t4 + player's current column
	lbu $t5, field($t4)	# load byte in $t5 to look for the reward
	bne $t5, 'R', notReward	# not reward in actual field position
	addi $t6, $t6, 5	# reward found, increment counter in 5

	# generating random row for new reward
	addi $a2, $zero, 6	# Set upper bound to 6, for 5 rows max
	jal genRandomNum	# generate random number procedure
	add $t7, $zero, $a0	# Copy the random number to $t7

	# generating random colum for new reward
	addi $a2, $zero, 8	# Set upper bound to 8, for 7 columns max
	jal genRandomNum	# generate random number procedure
	add $t8, $zero, $a0	# Copy the random number to $t8

	# storing the new reward in the generated position
	mul $t4, $t7, 10	# $t4 = reward's new row * number of field columns
	add $t4, $t4, $t8	# $t4 = $t4 + reward's new column
	addi $t5,$zero, 'R'	# $t5 = 'R' , reward byte
	sb $t5, field($t4)	# stores 'R' in new reward's position

	lw $ra, 0($sp)		# load the return address from the stack
	addi $sp, $sp, 4	# return the stack pointer to it's original value

	notReward: jr $ra	# no reward found, return

genRandomNum: addi $v0, $zero, 40 # Syscall 40: Random seed
	add $a0, $zero, 1	# Set RNG ID to 1
	addi $a1, $zero, 1	# Set Random seed to 1
	syscall

	addi $v0, $zero, 42	# Syscall 42: Random int range
	add $a0, $zero, $zero	# Set RNG ID to 0
	add $a1, $zero, $a2	# Set upper bound to $a2, for $a2-1 columns max
	syscall			# Generate a random number and put it in $a0
	beq $a0, $zero, genRandomNum # if number generated is 0, repeat
	jr $ra

	j stop			# jumps to stop label to stop the program

	# to print on MMIO display
displayReady: lw $t0, 8($s0)	# load the display control register in $t0
	andi $t0, $t0, 1	# check if bit 0 in display control register is 1
	beq $t0, $zero, displayReady # if display control register bit 0 is 0 check again
	sb $a0, 12($s0)		# store data to print in display data register
	jr $ra			# jump to the next line where displayReady was called

stop:	li $v0, 10		# load 10 in $v0 to stop program from running
	syscall			# stop program from running
