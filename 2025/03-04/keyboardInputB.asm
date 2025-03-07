    .data

gays:	.ascii	"gays"

    .eqv    MMIOBASE    0xffff0000

    # Receiver Control Register (Ready Bit)
    .eqv    RCR_        0x0000
    .eqv    RCR         RCR_($s0)

    # Receiver Data Register (Key Pressed - ASCII)
    .eqv    RDR_        0x0004
    .eqv    RDR         RDR_($s0)

    # Transmitter Control Register (Ready Bit)
    .eqv    TCR_        0x0008
    .eqv    TCR         TCR_($s0)

    # Transmitter Data Register (Key Displayed- ASCII)
    .eqv    TDR_        0x000c
    .eqv    TDR         TDR_($s0)

    .text
    .globl  main
main:
    li      $s0,MMIOBASE            # get base address of MMIO area

keyWait: lw      $t0,RCR                 # get control reg
    andi    $t0,$t0,1               # isolate ready bit
    beq     $t0,$zero,keyWait       # is key available? if no, loop

    lbu     $a0,RDR                 # get key value

	beq $a0,'z',ze	#jump to ze label if $a0=z
	beq $a0,'s',es	#jump to es label if $a0=s
	beq $a0,'q',qu	#jump to qu label if $a0=q
	beq $a0,'d',di	#jump to di label if $a0=d
	beq $a0,'x',ex	#jump to ex label if $a0=x

lab:	li      $v0,11
	syscall

	j keyWait	#jump to keyWait label
ex:	li $v0,10	#store 10 on $v0
	syscall		#call system

displayWait: lw $t1,TCR	# get control reg
	andi $t1,$t1,1	# isolate ready bit
	beq $t1,$zero,displayWait	# is display ready? if no, loop

	sw $a0,TDR	# send key to display
	jr $ra		#jump to the next line where displayWait was called

ze:	lw $a0, gays	#to print "up"
	jal displayWait
	li $a0,'p'
	jal displayWait
	li $a0,'\n'
	jal displayWait
	j lab	#jump to lab label
	
es:	li $a0,'d'	#to print "down"
	jal displayWait
	li $a0,'o'
	jal displayWait
	li $a0,'w'
	jal displayWait
	li $a0,'n'
	jal displayWait
	li $a0,'\n'
	jal displayWait
	j lab	#jump to lab label

qu:	li $a0,'l'	#to print "left"
	jal displayWait
	li $a0,'e'
	jal displayWait
	li $a0,'f'
	jal displayWait
	li $a0,'t'
	jal displayWait
	li $a0,'\n'
	jal displayWait
	j lab	#jump to lab label

di:	li $a0,'r'	#to print "right"
	jal displayWait
	li $a0,'i'
	jal displayWait
	li $a0,'g'
	jal displayWait
	li $a0,'h'
	jal displayWait
	li $a0,'t'
	jal displayWait
	li $a0,'\n'
	jal displayWait
	j lab	#jump to lab label
