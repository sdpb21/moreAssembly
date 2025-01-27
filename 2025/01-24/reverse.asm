; nasm -f elf32 reverse.asm -o reverse.o

; ld -m elf_i386 -o reverse reverse.o

; ./reverse

; for debugging:

; nasm -felf32 -g -F dwarf -o reverse.o reverse.asm

; ld -m elf_i386 -o reverse reverse.o

; gdb reverse

section .data

newline:	db	10, 0 
input:		db	"Input:" , 10, 0
output:		db	"Output:", 10, 0

section .bss

input_buf:	resb	256
str1:		resb	128
str2:		resb	128
sum_buf:	resb	256
index:		resd	1
cases:		resd	10000

section .text
global _start

readLine: mov eax, 3
	mov ebx, 0
	mov ecx, input_buf
	mov edx, 255
	int 0x80
	ret

printString: mov eax, 4
	mov ebx, 1
	int 0x80
	ret

printNewLine: mov eax, 4
	mov ebx, 1
	mov ecx, newline
	mov edx, 1
	int 0x80
	ret

removeZeros: push ebp
	mov ebp, esp
	mov esi, sum_buf

.removeLoop: mov al, [esi]
	cmp al, 0
	je .allZeros
	cmp al, '0'
	jne .doneRemoving
	mov edi, esi

.shiftLeft: mov al, [edi + 1]
	mov [edi], al
	cmp al, 0
	je .removeLoop
	inc edi
	jmp .shiftLeft

.allZeros: mov byte [esi], '0'
	mov byte [esi+1], 0
	jmp .doneRemoving

.doneRemoving: pop ebp
	ret

sumReversed: push ebp
	mov ebp, esp
	mov esi, str1
	mov edi, str2
	mov ebx, sum_buf
	xor ecx, ecx ; ecx = carry

.loopSum: mov al, [esi]
	cmp al, 0
	je .zeroStr1
	sub al, '0'
	jmp .digit1Ready

.zeroStr1: xor eax, eax

.digit1Ready: mov dl, [edi]
	cmp dl, 0
	je .zeroStr2
	sub dl, '0'
	jmp .digit2Found

.zeroStr2: xor edx, edx

.digit2Found: add al, dl
	add al, cl
	cmp al, 9
	jle .carryZero
	sub al, 10
	mov cl, 1
	jmp .saveDigit

.carryZero: xor ecx, ecx

.saveDigit: add al, '0'
	mov [ebx], al
	inc ebx

	cmp byte [esi], 0
	je .noIncStr1
	inc esi

.noIncStr1: cmp byte [edi], 0
	je .noIncStr2
	inc edi

.noIncStr2: mov al, [esi]
	mov dl, [edi]
	or al, dl
	or al, cl
	jne .loopSum

	cmp cl, 0
	je .addDone

	mov byte [ebx], '1'
	inc ebx

.addDone: mov byte [ebx], 0
	pop ebp
	ret

extractNumbers: push ebp
	mov ebp, esp

	mov edi, str1
	mov ecx, 128

.clrStr1: mov byte [edi], 0
	inc edi
	loop .clrStr1

	mov edi, str2
	mov ecx, 128

.clrStr2: mov byte [edi], 0
	inc edi
	loop .clrStr2

	mov esi, input_buf
	mov edi, str1

.nextStr1: mov al, [esi]
	cmp al, ' '
	je .str1Complete
	mov [edi], al
	inc edi
	inc esi
	jmp .nextStr1

.str1Complete: cmp al, ' '
	jne .noSpace
	inc esi

.noSpace: mov edi, str2

.nextStr2: mov al, [esi]
	cmp al, 10
	je .str2Complete
	mov [edi], al
	inc edi
	inc esi
	jmp .nextStr2

.str2Complete: pop ebp
	ret

stringToInt: push ebp
	mov ebp, esp
	mov ebx, 0

.nextCh: mov al, [esi]
	cmp al, 10
	je .finish
	cmp al, 0
	je .finish
	sub al, '0'
	imul ebx, ebx, 10
	add ebx, eax
	inc esi
	jmp .nextCh

.finish: pop ebp
	ret

intToString:
	add esi, 9
	mov byte [esi], 0
	mov ebx, 10
	xor ecx, ecx

.nextDigit:
	xor edx, edx
	inc ecx
	div ebx
	add dl, '0'
	dec esi
	mov [esi], dl
	test eax, eax
	jnz .nextDigit

	mov eax, esi
	ret

_start:
	mov edx, 8
    	mov ecx, input
    	call printString

	call readLine
	mov esi, input_buf
	call stringToInt
	mov [index], ebx
	mov esi, ebx
	xor ecx, ecx

.nLoop: cmp esi, 0
	push esi
	push ecx
	je .printCases

	call readLine

	cmp eax, 1
	jl .completed

	call extractNumbers

	call sumReversed

	call removeZeros

	mov esi, sum_buf
	call stringToInt

	pop ecx
	mov [cases + 4*ecx], ebx
	inc ecx

	pop esi
	dec esi
	jmp .nLoop

.printCases: mov edx, 9
    	mov ecx, output
    	call printString

	xor ecx, ecx
	mov esi, [index]

.printLoop: cmp esi, 0
	push esi
	je .completed

	mov eax, [cases + 4*ecx]
	mov esi, sum_buf
	inc ecx
	push ecx
	call intToString

	mov edx, ecx
    	mov ecx, eax
    	call printString

	call printNewLine

	pop ecx
	pop esi
	dec esi
	jmp .printLoop

.completed: mov eax, 1
	xor ebx, ebx
	int 0x80
