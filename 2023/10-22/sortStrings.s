.globl main


.data 
	new_line : .asciiz "\n" 
		   .align 5
		   
	space_char: .asciiz " "
		    .align 5
		    
	bracket1: .asciiz "["
		  .align 5
		  
	bracket2: .asciiz " ]"
		  .align 5
		  
	str_pointers: .space 96 # more than: number of names(17) * 4bytes each address = 68
	
	str_data: 
	#  char * data[] = {"Joe", "Jenny", "Jill", "John", "Jeff", "Joyce", "Jerry", "Janice", "Jake", "Jonna", "Jack", "Jocelyn", "Jessie", "Jess", "Janet", "Jane"};

		  .asciiz "Joe",
		  .align 5,
		  .asciiz "Jenny",
		  .align 5,
		  .asciiz "Jill",
		  .align 5,
		  .asciiz "John",
		  .align 5,
		  .asciiz "Jeff",
		  .align 5,
		  .asciiz "Joyce",
		  .align 5,
		  .asciiz "Jerry",
		  .align 5,
		  .asciiz "Janice",
		  .align 5,
		  		  
		  .asciiz "Jake",
		  .align 5,
		  .asciiz "Jona",
		  .align 5,
		  .asciiz "Jack",
		  .align 5,
		  .asciiz "Jocelyn",
		  .align 5,
		  .asciiz "Janice",
		  .align 5,	  
		  .asciiz "Jessie",
		  .align 5,
		  .asciiz "Jess",
		  .align 5,
		  .asciiz "Janet",
		  .align 5,
		  .asciiz "Jane",
		  .align 5,
		  		  
		  			  		  
		  		  

.text 

main: 


#We will assign each string's address into a 1word length pointer str_pointers in the next to labels.
set_pointers:
	#t0 is counter: i=0...12
	#t1 used for beginning of the string which we want to set the corresponding pointer
	#t2 the place where we should store the address of a string.
	# After this point: i'th value in str_pointers, point to the i'th string(the address of it)
	li $t0, 0 #i=0
	la $t1, str_data #t1=*str
	la $t2, str_pointers #t2=str_ptr
	
pointer_loop:
	sw $t1, ($t2) #str_ptr[i]=&str[i]
	
	add $t2, $t2, 4 # move to next pointer
	addi $t1, $t1, 32 #move to next string
	add $t0, $t0, 1 #i++

	ble $t0, 16, pointer_loop #while(i<16)
	
	li $t0, 0
	la $t2, str_pointers 



#Loop two for loops inside each other, 

#t1: first str t2: second str
#t0: str_pointers
#t3: i, $t4: j
#t5: accounting for 4*j, t6: 4j+4
loop_init:
	li $t3, 1 #i
	li $t4, 0 #j
	b loop



# Look at the j value(t4) and based on that, retrieves  str[j] and str[j+1] and put them in t1 and t2
set_two_names: 
	la $t0, str_pointers
	mul $t5, $t4, 4 #t5=4*j
	add $t5, $t5, $t0 #t5=str_pointer[j]
	add $t6, $t5, 4 #t6=str_pointer[j+1]
	lw $t1, ($t5) #t1=str[j]
	lw $t2, ($t6) #t2=str[j+1]

	jr $ra
	
loop:

	jal set_two_names # set t1 = str[j], t2=str[j+1]
	jal compare_init # compare str[j] and str[j+1], and if str[j]>str[j+1] set register t7 to 0.
	jal if_swap #if(a[j+1]<a[j]) {a[j+1]=a[j]; a[j]=a[i];} // swap a[j], a[j+1]. It know from value of t7 from previous part.
	
	sub $t4, $t4, 1 #j--

	bge $t4, 0, loop #while (j>=0)
	
	add $t3, $t3, 1 #i++;
	move $t4, $t3	#j=i;
	sub $t4, $t4, 1 #j=i-1;
	ble $t3, 16, loop #while(i<=16)
	jal print_init # print the names based on their pointers in str_pointers
	b exit
	
if_swap:
	beqz $t7, swap #if (t7==0) swap();
	jr $ra
	
swap:
	la $t0, str_pointers
	mul $t5, $t4, 4 #t5=4*j
	add $t5, $t5, $t0 #t5=str_pointer[j]
	add $t6, $t5, 4 #t6=str_pointer[j+1]
	
	lw $s5, ($t5) #s5=str[j]
	lw $s6, ($t6) #s6=str[j+1]
	sw $s6, ($t5) #str_pointers[j] = str_pointers[j+1]
	sw $s5, ($t6) #str_pointers[j+1] = str_pointers[j]
	jr $ra
	
	
#str_lt returns 1 if first is less than second. t1 points to first string, and t2 to second one	
compare_init: 
	la $t0, str_pointers
	li $t6, 0 #counter for going through each character in string: c
	li $t7, 1 #return value. Initialy 1, it would be set to 0 if s1>s2
	b compare

 # it compares two strings s1 and s2 through pointers p1 and p2, and if s2 should come before s1, swap the values of pointers	
compare:
	#t1: first string address, t2: second string address. t0 is str_pointers
	# t6:counter starting from 0
	# s1 is the t3'th byte of t1
	# s2 is the t3'th byte of t2
	#t5 is temprorary
	
	add $t5, $t1, $t6 
	lb $s1, ($t5) # s1=t1[c]
	add $t5, $t2, $t6 
	lb $s2, ($t5) #s2=t2[c]
	bgt $s1, $s2, second_smaller #t2<t1
	blt $s1, $s2, finish_compare #t1<t2
	add $t6, $t6, 1 #c++
	bnez $s1, compare#while (t1[c]!=0)
	b finish_compare
second_smaller:
	li $t7, 0 #set t7 to zero.
	b finish_compare
finish_compare:
	jr $ra


print_init:
	#t2 is counter:i
	#t0 is str_pointers
	#t5 is new_address = 4*i
	li $v0, 4 #print character syscall
	li $t2, 0 #i=0

	la $t0, str_pointers
	
	
	la $s0, bracket1 #print [
	move $a0, $s0
	syscall

print_names:

	la $s0, space_char #print " " after [
	move $a0, $s0
	syscall

	lw $a0, ($t0) #print str[i]
	syscall
	
	
	add $t2, $t2, 1 #i++
	add $t0, $t0, 4 #4*i
	
	ble $t2, 16, print_names #while(i<=16)
	
	la $s0, bracket2 #print ]
	move $a0, $s0
	syscall
	
	jr $ra


	
	
	
exit:
	#exit
	li $v0, 10
	syscall	
	
