;	nasm -felf64 scanf2.asm && gcc -no-pie scanf2.o && ./a.out

;	for debugging:  nasm -f elf64 -g -F dwarf -o scanf2.o scanf2.asm

;	gcc -no-pie -o scanf2 scanf2.o


section .data

slashn		db	10
int_inMsg:	db	"Input:" , 10, 0 ;10 for new line, 0 for null
outputMsg:	db	"Output:", 10, 0
intFormat	db	"%d", 0

section .bss
index:		resd	1
numbers:	resq	10	; to store 64 bits integers
buffer 		resb	10

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

	mov r15, [index]	; moving index stored in memory to r15 register
	xor r14, r14		; r14 = 0

	; to capture the numbers:

add_number:

	lea rdi, [intFormat]	; first arg for scanf
        lea rsi, [numbers + r14*8]	; second arg for scanf
        xor rax, rax
        call scanf

	; to repeat an index number of times

	inc r14			; counting repetitions
	cmp r14, r15		; comparing with index
	jne add_number		; if not equal, repeat

	; to print Output:

	lea rdi, [outputMsg]    ; first argument for printf - prints "Output:"
        xor rax, rax
        call printf

	; reading numbers stored on memory

	xor r14, r14            ; r14 = 0
next_number:
	mov r13, [numbers + r14*8]	; copy the number stored to r13 register

find_palindrome:
	inc r13			; 

	; int to string conversion //////////////////////////////////////////////

	mov rax, r13
	mov esi, buffer
	call int_to_string
	mov edx, eax		; using edx as a temp variable
	mov r11, rcx		; storing the string length in case of finding the palindrome number
	mov r10, rax		; address with number in string format to print in palindrome case

;**************************************************************
; palindromo

    mov     eax, ecx	; length         ; number of bytes to read
    mov     ecx, edx	; string address
    ;mov     ebx, 0          ; write to the STDIN file
    ;mov     eax, 3          ; invoke SYS_READ (kernel opcode 3)
    ;int     0x80            ; start of word

    add     eax, ecx
    dec     eax

capitalizer:
    cmp byte[ecx], 0
    je  finished

    mov bl, byte[ecx]           ;start
    mov dl, byte[eax]           ;end

    cmp bl, 90
    jle uppercase         ;start is uppercase

    sub bl, 32

uppercase:
    cmp dl, 90
    jle check               ;end is uppercase

    sub dl, 32

check:
    cmp dl, bl
    jne fail

    inc ecx
    dec eax
	mov r12, rax
	sub r12, rcx	; end - start
	cmp r12, 0
	jle finished
    jmp capitalizer

finished:

    mov     rdx, r11
    mov     rcx, r10
    mov     ebx, 1
    mov     eax, 4
    int     0x80

	mov edx, 1
    	mov ecx, slashn
    	mov ebx, 1
    	mov eax, 4
    	int 0x80

	inc r14		; next number stored in memory
	cmp r14, r15	; comparing with the counter of numbers introduced to finish execution
	je exit
    jmp     next_number

fail:
    ;mov     edx, lenNP
    ;mov     ecx, notPalindrome
    ;mov     ebx, 1
    ;mov     eax, 4
    ;int     0x80
	jmp find_palindrome

 exit:
;**************************************************************
        ; return

        pop rbp ;restore stack
        mov rax, 0 ;normal exit
        ret

; Input:
; eax = integer value to convert
; esi = pointer to buffer to store the string in (must have room for at least 10 bytes)
; Output:
; eax = pointer to the first character of the generated string
; ecx = length of the generated string

int_to_string:
            add esi, 9
            mov byte [esi], 0  ; String terminator
            mov ebx, 10
		xor ecx, ecx	; ecx = 0
.next_digit:
            xor edx, edx        ; Clear edx prior to dividing edx:eax by ebx
		inc ecx		; count the number of characters
            div ebx             ; eax /= 10
            add dl, '0'         ; Convert the remainder to ASCII
            dec esi            ; store characters in reverse order
            mov [esi], dl
            test eax, eax
            jnz .next_digit    ; Repeat until eax==0

            ; return a pointer to the first digit (not necessarily the start of the provided buffer)
            mov eax, esi
            ret
