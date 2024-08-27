.data
prompt: .asciiz "Enter the value of N: "
newline: .asciiz "\n"

.text
.globl main
main:
    # Prompt the user for the value of N
    la $a0, prompt
    li $v0, 4
    syscall

    # Read the value of N from the user
    li $v0, 5
    syscall
    move $s0, $v0  # Store the value of N in $s0

    # Call the recursive function to print the binary patterns
    move $a0, $s0
    jal print_binary_patterns
    li $v0, 10
    syscall

print_binary_patterns:
    # Base case: if N is 0, print a newline and return
    beq $a0, $zero, print_newline
    
    # Recursive case: print 0 and 1 for the current position
    li $t0, 0
    move $a0, $t0
    jal print_bit
    li $t0, 1
    move $a0, $t0
    jal print_bit
    
    # Recursive call for the remaining positions
    addi $a0, $a0, -1
    jal print_binary_patterns
    
    # Return from the function
    jr $ra

print_bit:
    # Print the current bit
    move $a0, $t0
    li $v0, 1
    syscall
    
    # Print a space
    la $a0, newline
    li $v0, 4
    syscall
    
    # Return from the function
    jr $ra

print_newline:
    # Print a newline
    la $a0, newline
    li $v0, 4
    syscall
    
    # Return from the function
    jr $ra
