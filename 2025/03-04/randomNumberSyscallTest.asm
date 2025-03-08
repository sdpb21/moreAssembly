.eqv genID 1  # PRNG id
.data
Message: .asciiz "\n The random number you generated was: "
seed:    .word 1
.text
.globl main

main:	addi $v0, $zero, 40	# Syscall 40: Random seed
	add $a0, $zero, 1	# Set RNG ID to 0
	addi $a1, $zero, 1	# Set Random seed to
	syscall

	addi $v0, $zero, 42	# Syscall 42: Random int range
	add $a0, $zero, $zero	# Set RNG ID to 0
	addi $a1, $zero, 9	# Set upper bound to 4 (exclusive)
	syscall			# Generate a random number and put it in $a0
	add $s1, $zero, $a0	# Copy the random number to $s1
	j main

	#li $a1, 9	#Here you set $a1 to the max bound.
	#li $v0, 42	#generates the random number.
	#syscall

	#add $a0, $a0, 100  #Here you add the lowest bound
	#li $v0, 1	#1 print integer
	#syscall
	#j main

	li $a0, genID	########################################
	lw $a1, seed
	li $v0, 40
	syscall

	# li $a0, genID  # $a0 still has genID, 
	li $v0, 42
	li $a1, 9  # upper bound (not includes this number)
	syscall
	move $t0, $a0

	li $v0, 4
	la $a0, Message
	syscall

	move $a0, $t0
	li $v0, 1
	syscall  # print PRNG number
	j main

	li $v0, 10
	syscall  # terminate
