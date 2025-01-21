;	nasm -felf64 scanf2.asm && gcc -no-pie scanf2.o && ./a.out

;	for debugging:  nasm -f elf64 -g -F dwarf -o scanf2.o scanf2.asm

section .data

int_inMsg:    db        "Input:" , 10, 0 ;10 for new line, 0 for null
intFormat     db        "%d", 0

        section .bss
index:		resd	1
numbers:	resd	10


global main
extern printf
extern scanf
default rel

section .text

main: 

        push rbp ;setup stack - store old value of sp

        ;printf("Enter blah blah\n");

        lea rdi, [int_inMsg]	; first argument for printf - prints "Input:"
        xor rax, rax
        call printf


        ;take input from the user
        ;scanf("%d", &index);

        lea rdi, [intFormat]	; first arg for scanf
        lea rsi, [index]	; second arg for scanf
        xor rax, rax
        call scanf

	mov rsi, [index]	; moving index stored in memory to rsi register
	mov r15, rsi		; store rsi value in r15
	xor r14, r14		; r14 = 0

	; to capture the numbers:

add_number:

	lea rdi, [intFormat]	; first arg for scanf
        lea rsi, [numbers]	; second arg for scanf
        xor rax, rax
        call scanf

	; to repeat an index number of times

	inc r14
	cmp r14, r15
	jne add_number

        ; return
        pop rbp ;restore stack
        mov rax, 0 ;normal exit
        ret
