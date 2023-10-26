     DominosLarge
     14
     7.99
     DominosMedium
     12
     6.99 
    DONE
Your program should prompt the user each expected input. For example, if you’re expecting the user to input a pizza name, print to console something like “Pizza name: ”.
Your program should output a number of lines equal to the number of pizzas, and each line is the pizza name and pizza-per-dollar (in2/USD) , which should be set to zero if either diameter or price are
zero). The lines should be sorted in descending order of pizza-per-dollar, and in the case of a tie, ascending order by pizza name. An example execution of the above input is shown below:
IMPORTANT: There is no constraint on the number of pizzas, so you may not just allocate space for, say, 10 pizza records; you must accommodate an arbitrary number of pizzas. You must allocate space on the heap for this data. Code that does not accommodate an arbitrary number of pizzas will be penalized (- 75% penalty)! Furthermore, you may NOT first input all names and data into the program to first find out how many pizzas there are and *then* do a single dynamic allocation of heap space.
      
may not ask the user at the start how many player records will be typed. Instead, you must dynamically allocate memory on-the-fly as you receive names. To perform dynamic allocation in MIPS assembly, I recommend looking here.
You’ll also be using floating-point MIPS instructions, which are different from the integer ones we learned. Like many processors, MIPS considers floating point separate from the “real” CPU; it’s instead “co-processor 1”. You can find floating-point-specific operations are here, but if you want to get data in/out of the floating point unit or to take branching decisions based on floating point comparisons, you’ll need instructions like mtc1 (move to coprocessor 1), bc1t (branch if coprocessor 1 comparison is true), etc., which are described here. Also, the different floating point registers have different roles similar to the integer registers (caller-saved, callee-saved, etc.); these are distinguished on the second page of this document. Lastly, as there is no load-immediate instruction for floats, the easiest way to specify a floating point constant such as 𝜋 is to put it in memory as shown below and load it with 1.s

.data
    name: .space 64
    number: .word 10
    message1: .asciiz "Enter a Pizza Name: "
    message2: .asciiz "Enter a Diameter: "
    message3: .asciiz "Enter a Cost: "
    done: .asciiz "DONE\n"
    enter: .asciiz "\n"
    space: .asciiz " "

#s1 is head


.text
.globl main
    main:
     subu $sp, $sp, 4
     sw $ra, 0($sp)

        jal addnode
        #jal sort
        jal Display

    addi $sp, $sp, 4
    jr $ra


.globl addnode
addnode:
    li.s $f9,0.0
    #t0 is the address to the current node
    #t1 is the value of the insertion

    li $v0,9 #malloc(sizeof(struct))
    li $a0,72
    syscall
    move $s1,$v0 # s1=v0

    # getting text from the user

    li $v0, 4
    la $a0, message1
    syscall
    li $v0,8
    move $a0,$s1
    li $a1,64
    syscall
    #move $s1, $a0

    la $a1,done
    done1:
    lb $t5, 0($a0)
    lb $t6, 0($a1)
    bne $t5,$t6, diameter0
    beq $t5,10,exit
    addi $a0,$a0,1
    addi $a1,$a1,1
    j done1


    diameter0:
    #diameter
    li $v0, 4
    la $a0, message2
    syscall
    li $v0, 6
    syscall
    mov.s $f3, $f0


    #cost
    li $v0, 4
    la $a0, message3
    syscall
    li $v0, 6
    syscall
    c.eq.s $f0,$f9
    bc1t zero1
    mov.s $f4, $f0

    li.s $f27, 2.0
    li.s $f25, 3.14159265358979323846
    div.s $f3, $f3, $f27
    mul.s $f3, $f3, $f3
    mul.s $f3, $f3, $f25
    div.s $f4, $f3, $f4
    s.s $f4, 64($s1)
    sw $0, 68($s1)
    j hello1

    zero1:
    s.s $f9, 64($s1)

    # getting the number

    #li $v0,5
    #syscall
    #sw $v0, 64($s1)
    #sw $0, 68($s1)

    hello1:
    li $s0,0


loop:

    move $t0,$s1

    li $v0,9 #malloc(sizeof(struct))
    li $a0,72
    syscall
    move $t4,$v0 # s1=v0

    sw $0, 68($t4)

    li $v0, 4
    la $a0, message1
    syscall

    # getting text from the user
    li $v0,8
    move $a0,$t4
    li $a1,64
    syscall
    #move $t4, $a0

    la $a1,done
    done2:
    lb $t5, 0($a0)
    lb $t6, 0($a1)
    bne $t5,$t6, diameter1
    beq $t5,0,exit
    addi $a0,$a0,1
    addi $a1,$a1,1
    j done2


    diameter1:
    #diameter
    li $v0, 4
    la $a0, message2
    syscall
    li $v0, 6
    syscall
    mov.s $f3, $f0

    #cost
    li $v0, 4
    la $a0, message3
    syscall
    li $v0, 6
    syscall
    c.eq.s $f0,$f9
    bc1t zero2
    mov.s $f4, $f0

    div.s $f3, $f3, $f27
    mul.s $f3, $f3, $f3
    mul.s $f3, $f3, $f25
    div.s $f4, $f3, $f4

    mov.s $f13, $f4
    #s.s $f4, 64($t4)
    j hello2

    zero2:
    mov.s $f13,$f9


    hello2:


    li $t2,0

loop1:



    FindLoop:
    beq $t0,$0, Exitaddnodeloop
    l.s $f3, 64($t0)
    c.eq.s $f13,$f3
    bc1t strcmp
    c.lt.s $f3,$f13
    bc1t Exitaddnodeloop
    #beq $t1, $t3, strcmp
    #bne $t5, $0, Exitaddnodeloop
    move $t2,$t0
    lw $t0, 68($t0)
    j FindLoop

    strcmp:
    move $t5, $t4
    move $t6, $t0
    strcmp1:
    bnez $s0, compare1
    lb $t7, 0($t5)
    lb $t8, 0($t6)
    sgt $t9,$t7,$t8
    bnez $t9, greater
    slt $t9,$t7,$t8
    bnez $t9, Exitaddnodeloop
    addi $t5,$t5,1
    addi $t6,$t6,1
    j strcmp1

    compare1:
    lw $a2, 68($t6)
    beqz $a2, last
    l.s $f7, 64($t0)
    l.s $f8, 64($a2)
    c.eq.s $f7, $f8
    bc1t compare
    loop8:
    lb $t7, 0($t5)
    lb $t8, 0($t6)
    sgt $t9,$t7,$t8
    bnez $t9, greater
    slt $a3, $t7, $t8
    bnez $a3, Exitaddnodeloop
    addi $t5,$t5,1
    addi $t6,$t6,1
    j loop8


    compare:

    lb $s3, 0($t6)
    lb $t7, 0($t5)
    lb $t8, 0($a2)
    sgt $t9,$t7,$t8
    bnez $t9, loop2
    slt $t9,$t7,$t8
    bnez $t9, greaterbefore
    addi $t5,$t5,1
    addi $t6,$t6,1
    addi $a2,$a2,1
    j compare

    greaterbefore:
    slt $t9, $t7,$s3
    bnez $t9 Exitaddnodeloop
    j greater


    loop2:
    move $t2, $t0
    lw $t0,68($t0)
    j loop1

    last:
    l.s $f7, 64($t0)
    l.s $f8, 64($t2)
    c.eq.s $f7, $f8
    bc1t greater
    loop7:
    lb $t7, 0($t5)
    lb $t8, 0($t6)
    sgt $t9,$t7,$t8
    bnez $t9, greater
    slt $a3, $t7, $t8
    bnez $a3, Exitaddnodeloop
    addi $t5,$t5,1
    addi $t6,$t6,1
    j loop7



    greater:

    move $t2,$t0
    lw $t0, 68($t0)

    Exitaddnodeloop:

    li $s0,1
    move $v0,$t4
    sw $t0, 68($v0)
    s.s $f13, 64($v0)
    beq $t2,$0, Previouswasnull
    sw $v0,68($t2)
    j loop



    Previouswasnull:

    move $s1, $v0
    j loop

    exit:
    jr $ra




Display:

    move $t0, $s1


    DisplayLoop:
    beq $t0, $0, ReturnFromDisplay

    #print the name of the pizza

    li $v0,4
    la $a0, 0($t0)
    next1:
    li $t1,10
    lb $t2, 0($a0)
    beq $t1,$t2, replace
    addi $a0,$a0,1
    j next1

    next:
    la $a0, 0($t0)
    syscall

    li $v0,4
    la $a0, space
    syscall

    li $v0, 2
    l.s $f12, 64($t0)
    syscall


    li $v0, 4
    la $a0, enter
    syscall



    lw $t0, 68($t0)
    j DisplayLoop

    replace:
    sb $0, ($a0)
    j next


    ReturnFromDisplay:
    li $v0, 4
    la $a0, enter
    syscall
    jr $ra

