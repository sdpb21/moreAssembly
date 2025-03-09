.data

scoreMsg:.asciiz"Score: "
scoreNum:.space 5
field:	.ascii	"#########\n"
	.ascii	"#  R    #\n"
	.ascii	"#       #\n"
	.ascii	"#  P    #\n"
	.ascii	"#       #\n"
	.ascii	"#       #\n"
	.ascii	"#########\n!"
gameOver: .asciiz "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\nGAME OVER!! "

.text

	li $s0, 0xffff0000	# load the base address of MMIO area in $s0
	addi $t2, $t2, 3	# player's current row
	addi $t3, $t3, 3	# player's current column
	andi $t6, 0		# rewards counter clearing

	# reward int to string conversion
	add $a0, $zero, $t6	# $a0 = int to convert
	la $a1, scoreNum	# $a1 = address of string where converted number will be kept
	jal intToString		# call intToString procedure

	# printing the score
start:	jal printSc

	jal printNum

	# printing the field
	andi $t1, 0		# clear $t1 again
printField: lb $a0, field($t1)	# load the byte on $t1 position from field, in $a0
	beq $a0,'!', fieldEnd	# field end byte found, do not print, jump to fieldEnd label
	jal displayReady	# print the byte loaded on MMIO display
	addi $t1, $t1, 1	# go to the next byte to print
fieldEnd: bne $a0, '!', printField # if byte isn't '!', repeat

	# if Score is 100 end the game and prints GAME OVER
	beq $t6, 100, stop	# if score is 100 jumps to stop label

	# looking for the players position, if it has collide with a wall then prints GAME OVER
	beq $t2, 0, stop	# if $t2=0 player has collide with upper wall
	beq $t2, 6, stop	# if $t2=6 player has collide with lower wall
	beq $t3, 0, stop	# if $t3=0 player has collide with left wall
	beq $t3, 8, stop	# if $t3=0 player has colide with right wall

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
###########
# printSc #
###########
printSc: addi $sp, $sp, -4	# making space in the stack for a word
	sw $ra, 0($sp)		# store the return address in the stack

	andi $t1, 0		# clear $t1
printScore: lb $a0, scoreMsg($t1) # load the byte on $t1 position from scoreMsg, in $a0
	jal displayReady	# print the byte loaded on MMIO display
	addi $t1, $t1, 1	# increments $t1 to go for the next byte in scoreMsg string
	bne $a0, $zero, printScore # if char is not null, repeat

	lw $ra, 0($sp)		# load the return address from the stack
	addi $sp, $sp, 4	# return the stack pointer to it's original value
	jr $ra			# go to the next line where printSc was called

############
# printNum #
############
printNum: addi $sp, $sp, -4	# making space in the stack for a word
	sw $ra, 0($sp)		# store the return address in the stack

	andi $t1, 0		# clear $t1 again
printNumber: lb $a0, scoreNum($t1) # load the byte on $t1 position from scoreNum, in $a0
	jal displayReady	# print the byte loaded on MMIO display
	addi $t1, $t1, 1	# increments $t1 to go for the next byte in scoreNum string
	bne $a0, $zero, printNumber # if char is not null, repeat

	lw $ra, 0($sp)		# load the return address from the stack
	addi $sp, $sp, 4	# return the stack pointer to it's original value
	jr $ra			# go to the next line where printNum was called

###############
# clrPosition #
###############
clrPosition: mul $t4, $t2, 10	# $t4 = player's current row * number of field columns
	add $t4, $t4, $t3	# $t4 = $t4 + player's current column
	addi $t5, $zero, ' '	# $t5 = ' '
	sb $t5, field($t4)	# clear current player position
	jr $ra			# go to the next line of jal clrPosition

###############
# newPosition #
###############
newPosition: mul $t4, $t2, 10	# $t4 = player's new row * number of field columns
	add $t4, $t4, $t3	# $t4 = $t4 + player's current column
	addi $t5,$zero, 'P'	# $t5 = 'P' , player byte
	sb $t5, field($t4)	# stores 'P' in new player's position
	jr $ra			# go to the next line of jal newPosition

############
# isReward #
############
isReward: addi $sp, $sp, -4	# making space in the stack for a word
	sw $ra, 0($sp)		# store the return address in the stack

	mul $t4, $t2, 10	# $t4 = player's new row * number of field columns
	add $t4, $t4, $t3	# $t4 = $t4 + player's current column
	lbu $t5, field($t4)	# load byte in $t5 to look for the reward
	bne $t5, 'R', notReward	# not reward in actual field position
	addi $t6, $t6, 5	# reward found, increment counter in 5

	# reward int to string conversion
	add $a0, $zero, $t6	# $a0 = int to convert
	la $a1, scoreNum	# $a1 = address of string where converted number will be kept
	jal intToString		# call intToString procedure

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

################
# genRandomNum #
################
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
################
# displayReady #
################
displayReady: lw $t0, 8($s0)	# load the display control register in $t0
	andi $t0, $t0, 1	# check if bit 0 in display control register is 1
	beq $t0, $zero, displayReady # if display control register bit 0 is 0 check again
	sb $a0, 12($s0)		# store data to print in display data register
	jr $ra			# jump to the next line where displayReady was called

###############
# intToString #
###############
intToString: addi $sp, $sp, -4	
	sw $t0, ($sp)
	bltz $a0, negativeNum
	j step0		# go to step0

negativeNum: li   $t0, '-'
	sb $t0, ($a1)
	addi $a1, $a1, 1
	li $t0, -1
	mul $a0, $a0, $t0

step0: li $t0, -1
	addi $sp, $sp, -4	# make space in stack
	sw $t0, ($sp)

storeDigit: blez $a0, step1
	li $t0, 10
	div $a0, $t0
	mfhi $t0	# $t0 = remainder
	mflo $a0	# num = quotient

	addi $sp, $sp, -4	# make space in the stack
	sw $t0, ($sp)
	j storeDigit

step1:	lw $t0, ($sp)
	addi $sp, $sp, 4

	bltz $t0, negativeDigit
	j loadDigit

negativeDigit: li   $t0, '0'
	sb $t0, ($a1)
	addi $a1, $a1, 1
	j step2

loadDigit: bltz $t0, step2
	addi $t0, $t0, '0'
	sb $t0, ($a1)
	addi $a1, $a1, 1

	lw $t0, ($sp)
	addi $sp, $sp, 4
	j loadDigit

step2:	addi $t0, $zero, '\n'	# add a jump to a new line char
	sb $t0, ($a1)	# store '\n' in the string
	addi $a1, $a1, 1	# next byte address
	sb $zero, ($a1)
	lw $t0, ($sp)
	addi $sp, $sp, 4
	jr $ra		# jump to next line where was called

stop:	andi $t1, 0		# clear $t1
printGameO: lb $a0, gameOver($t1) # load the byte on $t1 position from gameOver, in $a0
	jal displayReady	# print the byte loaded on MMIO display
	addi $t1, $t1, 1	# increments $t1 to go for the next byte in gameOver string
	bne $a0, $zero, printGameO # if char is not null, repeat

	jal printSc

	jal printNum

	li $v0, 10		# load 10 in $v0 to stop program from running
	syscall			# stop program from running
