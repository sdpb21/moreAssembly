.data
prompt:      .asciiz "Enter the length of binary patterns (N): "
newline:     .asciiz "\n"

.text
main:
    # Print prompt
    li      $v0, 4              # syscall for print string
    la      $a0, prompt         # load address of prompt
    syscall

    # Read integer N
    li      $v0, 5              # syscall for read integer
    syscall
    move    $a0, $v0            # store N in $a0

    # Call the recursive function to print binary patterns
    li      $t0, 0              # initialize index to 0
    jal     printBinaryPatterns  # call the function

    # Exit program
    li      $v0, 10             # syscall for exit
    syscall

# Recursive function to print binary patterns
# Arguments:
#   $a0 - length of binary pattern (N)
#   $t0 - current index (depth of recursion)
printBinaryPatterns:
    # Save the return address and registers
    addi    $sp, $sp, -8        # make space on the stack
    sw      $ra, 4($sp)         # save return address
    sw      $t0, 0($sp)         # save current index

    # Base case: if index equals N, print the current pattern
    beq     $t0, $a0, printPattern

    # Recursive case: generate binary patterns
    # First, add '0' at current index
    li      $t1, 0              # load 0
    sb      $t1, ($sp)          # store '0' in stack
    addi    $sp, $sp, -1        # move stack pointer
    addi    $t0, $t0, 1         # increment index
    jal     printBinaryPatterns  # recursive call
    addi    $t0, $t0, -1        # backtrack index
    addi    $sp, $sp, 1         # restore stack pointer

    # Now add '1' at current index
    li      $t1, 1              # load 1
    sb      $t1, ($sp)          # store '1' in stack
    addi    $sp, $sp, -1        # move stack pointer
    addi    $t0, $t0, 1         # increment index
    jal     printBinaryPatterns  # recursive call
    addi    $t0, $t0, -1        # backtrack index
    addi    $sp, $sp, 1         # restore stack pointer

    # Restore registers and return
    lw      $t0, 0($sp)         # restore current index
    lw      $ra, 4($sp)         # restore return address
    addi    $sp, $sp, 8         # restore stack pointer
    jr      $ra                  # return from function

printPattern:
    # Print the binary pattern stored in the stack
    addi    $sp, $sp, 1         # adjust stack pointer to point to the start of the pattern
    li      $v0, 4              # syscall for print string
    move    $a0, $sp            # load address of the pattern
    syscall
    li      $v0, 4              # syscall for print newline
    la      $a0, newline
    syscall
    addi    $sp, $sp, -1        # restore stack pointer
    # Restore registers and return
    lw      $t0, 0($sp)         # restore current index
    lw      $ra, 4($sp)         # restore return address
    addi    $sp, $sp, 8         # restore stack pointer
    jr      $ra                  # return from function
