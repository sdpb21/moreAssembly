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
    move    $t0, $v0            # store N in $t0

    # Call the recursive function to print binary patterns
    li      $t1, 0              # initialize index to 0
    jal     printBinaryPatterns  # call the function

    # Exit program
    li      $v0, 10             # syscall for exit
    syscall

# Recursive function to print binary patterns
# Arguments:
#   $t0 - length of binary pattern (N)
#   $t1 - current index (depth of recursion)
printBinaryPatterns:
    # Base case: if index equals N, print the current pattern
    beq     $t1, $t0, printPattern

    # Recursive case: generate binary patterns
    # First, add '0' at current index
    li      $t2, 0              # load 0
    sb      $t2, ($sp)          # store '0' in stack
    addi    $sp, $sp, -1        # move stack pointer
    addi    $t1, $t1, 1         # increment index
    jal     printBinaryPatterns  # recursive call
    addi    $t1, $t1, -1        # backtrack index
    addi    $sp, $sp, 1         # restore stack pointer

    # Now add '1' at current index
    li      $t2, 1              # load 1
    sb      $t2, ($sp)          # store '1' in stack
    addi    $sp, $sp, -1        # move stack pointer
    addi    $t1, $t1, 1         # increment index
    jal     printBinaryPatterns  # recursive call
    addi    $t1, $t1, -1        # backtrack index
    addi    $sp, $sp, 1         # restore stack pointer
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
    jr      $ra                  # return from function
