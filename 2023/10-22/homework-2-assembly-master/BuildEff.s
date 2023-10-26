.data

name: 		.asciiz "Building name: "
squareFootMsg:	.asciiz "Square footage of building: "
kWhPerYearMsg:	.asciiz "kWh per year: "
done:		.asciiz "DONE"
#nameInput:	.space 64

.text

main:	addi $sp, $sp, -4
	sw $ra, ($sp)
	
start:	li $v0, 4 		# code in $v0 to print a string
	la $a0, name 		# load address of string to be printed into $a0
	syscall 		# call operating system to perform operation specified in $v0
	
	# storing the building name on the heap
	li $v0, 9		# code in $v0 to for dynamic memory allocation
	li $a0, 64		# number of bytes
	syscall			# return the address for allocation on $v0
	
	# getting building name from console
	add $a0, $0, $v0	# copy to $a0 memory address of memory space to store the building name
	li $v0, 8		# code in $v0 to read a string
	li $a1, 64		# load to $a1 the maximum length of string to input
	syscall			# read the building name
	
	# comparing with the DONE string
	la $t0, done		# load address of DONE string to $t0 register
	add $t1, $0, $a0	# stores the building name address on $t1 register
nextCh:	lb $t2, ($t0)		# loading in $t2 the byte pointed by $t0 register
	lb $t3, ($t1)		# loading in $t3 the byte pointed by $t1 register
	beq $t2, $t3, equals	# if the bytes are equal jump to equals label
	j contin		# if string is not equal to DONE, jump to contin label to continue with the program
equals:	addi $t4, $t4, 1	# to count the equal bytes
	beq $t4, 4, end		# if $t4 is 4 means that string is DONE, program must jump to end label
	addi $t0, $t0, 1	# next character address on DONE string to compare
	addi $t1, $t1, 1	# next character address on introduced string
	j nextCh		# jump to nextCh label to compare next character
	
	# getting square footage of the building
contin:	li $v0, 4		# code in $v0 to print a string
	la $a0, squareFootMsg	# load the string address to be printed in $a0
	syscall			# prints "Square footage of building"
	
	li $v0, 5		# code in $v0 to read an integer
	syscall			# wait for the integer number and returns it on $v0
	add $t0, $0, $v0	# integer to $t0 to avoid division by zero
	mtc1 $v0, $f1		# move integer to float register to achieve the conversion
	cvt.s.w $f1, $f1	# conversion from integer ($v0) to float single precision ($f1)
	
	# getting the kWh per year
	li $v0, 4		# code in $v0 to print a string
	la $a0, kWhPerYearMsg	# load string address to print on $a0 register
	syscall			# prints "kWh per year:"
	
	li $v0, 6		# code in $v0 to read a float (single precision)
	syscall			# wait for a floating point number and stores it on $f0
	
	# getting the energy efficiency
	beq $t0, $0, is0	# if denominator is zero jump to is0 label
	div.s $f0, $f0, $f1	# $f0 = $f0 / $f1
	j not0			# if denominator is not zero jump to not0 label
is0:	mtc1 $t0, $f0		# $f0 == 0
	cvt.s.w $f0, $f0	# $f0 == 0.0
	
	# storing the energy efficiency on heap
not0:	li $v0, 9		# code in $v0 for dynamic memory allocation
	li $a0, 4		# number of bytes to store
	syscall			# address to store the energy efficiency to $v0
	s.s $f0, ($v0)		# store energy efficiency on heap
	
	addi $t9, $t9, 1	# buildings counter
	j start			# jump to start label to get another building data
	
	# creating an energy array for sorting
end:	li $t0, 0x10020000	# to access the heap
	add $t8, $0, $t9	# a copy of buildings counter
enLoop:	addi $t1, $t0, 64	# get the energy address on $t1
	lw $t2, ($t1)		# load the energy from heap
	li $v0, 9		# code in $v0 for dynamic memory allocation
	li $a0, 4		# number of bytes to store
	syscall			# address to store energy on $v0
	sw $t2, ($v0)		# stores the energy on heap
	addi $t0, $t1, 4
	addi $t9, $t9, -1	# decrements buildings counter
	bne $t9, $0, enLoop	# if counter is not 0, jump to enLoop label
	
	addi $t8, $t8, -1
	mul $t7, $t8, 4		# gettin' first element address of energy new array
	sub $t7, $v0, $t7	# energy array first element address on $t7 register
	
#***********************************************************************************************
	# calling to quicksort to sort the energy array
	add $a0, $0, $t7	# load the address of array into $a0
	add $a1, $0, $0		# set $a1 to low
	add $a2, $0, $t8	# set $a2 to high
	jal quicksort		# jump and link quicksort
	
	addi $t8 $t8, 1
	add $t9, $0, $t8	# copy buildings counter to $t9
	li $v0, 9		# code in $v0 for dynamic memory allocation
	li $a0, 4		# number of bytes to store
	syscall			# address to store energy on $v0
	addi $t0, $v0, -4	# last heap element address to $t0
	
	# printing sorted
sort:	add $t4, $0, $t9	# copy buildings counter to $t4
	lw $t1, ($t0)		# load energy sorted
	#
	li $t2, 0x10020000	# heap address
find:	addi $t2, $t2, 64	# go to energy address fron original list
	lw $t3, ($t2)		# get energy from original list
	beq $t3, $t5, label	# if actual energy == to past, jump to label
	beq $t1, $t3, found	# energy found in original list
lab2:	addi $t2, $t2, 4	# next 68 bytes on heap
	addi $t4, $t4, -1	# decrement buildings counter
	bne $t4, $0, find	# if not found, repeat
ok:	addi $t0, $t0, -4	# address of previous energy
	addi $t8, $t8, -1	# decrement buidings counter
	#bne $t8, $0, sort	# to print buildings sorted
	#j finish
	j sort

label:	addi $t5, $t5, -1	# set to another value to avoid freeze
	j lab2			# continue to print the next
	
	# print building name
found:	addi $t2, $t2, -64	# get the building name address from heap
	add $t5, $0, $t1	# store energy to compare with next for repetitions
print:	li $v0, 11 		# code in $v0 to print a char
	lb $a0, ($t2)
	beq $a0, 10, showF
	addi $t2, $t2, 1	# next character
	syscall 		# call operating system to perform operation specified in $v0
	j print
	
	# print a blank space
showF:	li $v0, 11		# code in $v0 to print a char
	addi $a0, $0, 0x20
	syscall			# prints a blank space

	# print energy
	li $v0, 2		# code in $v0 to print a floating point number
	#mtc1 $t1, $f1		# move integer to float register to achieve the conversion
	#cvt.s.w $f12, $f1	# conversion from integer ($v0) to float single precision ($f1)
	lwc1 $f12, ($t0)
	syscall			# prints the energy
	beq $t8, 0x1, finish	# all printed, finish program
	
	li $v0, 11		# code in $v0 to print a char
	addi $a0, $0, 10
	syscall			# prints a \n
	
	j ok
	
finish:	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra			# jump to register address stored on $ra
	
	# quicksort procedures
swap:	addi $sp, $sp, -12	#Make stack of 3 bytes
	sw $a0, 0($sp)		#Store $a0
	sw $a1, 4($sp)		#Store $a1
	sw $a2, 8($sp)		#Store $a2
	
	lw $t6, 0($a1)		#$t6=array[left]
	lw $t7, 0($a2)		#$t7=array[right]
	sw $t6, 0($a2)		#array[right]=$t6
	sw $t7, 0($a1)		#array[left]=$t7
	
	
	
	addi $sp,$sp,12		#restore stack
	jr $ra			#return to $ra
	

partition: addi $sp, $sp, -16
	sw $a0, 0($sp)		#address of array
	sw $a1, 4($sp)		#low
	sw $a2, 8($sp)		#high
	sw $ra, 12($sp)		#Return address
	mul $t0, $a1, 4		#$t0 = 4*low
	add $t1, $t0, $a0	#$t1 = address of array plus $t0
	move $s0, $a1		#left = low
	move $s1, $a2		#right = high
	lw $s3, 0($t1)		#pivot =array[low]
	lw $t3, 0($sp)		#$t3 = address of array
	
while: 	bge $s0, $s1, endwhile
while1: mul $t2, $s1, 4		#$t2= right *4
	add $s6, $t2, $t3	#$t3= $t2+array address
	lw $s4, 0($s6)		#$s4 = array[right]
	ble $s4,$s3, endwhile1	#end while1 if array[right]<= pivot
	addi $s1,$s1,-1		#right = right -1
	j while1
endwhile1: nop
		
while2:	mul $t4, $s0, 4		#$t4 = left*4
	add $s7, $t4, $t3	#$t5= $t4+array address
	lw $s5, 0($s7)		#$s5=array[left]
	bge $s0, $s1, endwhile2	#branch if left>=right to endwhile2
	bgt $s5, $s3, endwhile2	#branch if aray[left]>pivot to endwhile2
	addi $s0,$s0,1		#left = left+1
	j while2
endwhile2: nop
		
if:	bge $s0, $s1, end_if	#if left>=right branch to end_if
	move $a0, $t3		#move $t3 to $a0
	move $a1, $s7		#move array[left] into $a1
	move $a2, $s6		#move array[right] into $a2
	jal swap		#jump and link swap
			
			
end_if:	j while
		
endwhile: lw $s5, 0($s7)	#set $s5 to array[left]
	lw $s4, 0($s6)		#set $s4 to array[right]
	sw $s4 0($t1)		#array[low]=array[right]
	sw $s3, 0($s6)		#array[right]=pivot
		
		
	move $v0, $s1		#set $v0 to right
		
	lw $ra 12($sp)		#restore $ra
	addi $sp, $sp,16	#restore stack
	jr $ra			#return to $ra
	
quicksort: addi $sp, $sp, -16	# Create stack for 4 bytes

	sw $a0, 0($sp)		#store address in stack
	sw $a1, 4($sp)		#store low in stack	
	sw $a2, 8($sp)		#store high in stack
	sw $ra, 12($sp)		#store return address in stack

	move $t0, $a2		#saving high in t0
	
checkCond: slt $t1, $a1, $t0	# t1=1 if low < high, else 0
	beq $t1, $zero, end_check	# if low >= high, endcheck

	jal partition		# call partition 
	move $s0, $v0		# pivot, s0= v0

	lw $a1, 4($sp)		#a1 = low
	addi $a2, $s0, -1	#a2 = pi -1
	jal quicksort		#call quicksort

	addi $a1, $s0, 1	#a1 = pi + 1
	lw $a2, 8($sp)		#a2 = high
	jal quicksort		#call quicksort
		
end_check: lw $a0, 0($sp)	#restore a0
 	lw $a1, 4($sp)		#restore a1
 	lw $a2, 8($sp)		#restore $a2
	lw $ra 12($sp)		#load return adress into ra
	addi $sp, $sp, 16	#restore stack
	jr $ra			#return to $ra
