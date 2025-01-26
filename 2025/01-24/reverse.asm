; nasm -f elf32 reverse.asm -o reverse.o

; ld -m elf_i386 -o reverse reverse.o

; ./reverse

; for debugging:

; nasm -felf32 -g -F dwarf -o reverse.o reverse.asm

; ld -m elf_i386 -o reverse reverse.o

; gdb reverse

section .data

; We'll use these for output
newline: db 10, 0 ; A single newline character

section .bss

;buf_in: resb 256 ; Buffer for reading lines
s1: resb 128 ; Buffer for first reversed number
s2: resb 128 ; Buffer for second reversed number
buf_sum: resb 256 ; Buffer for the reversed sum
index:	resd	1
buf_in:	resd	10000

section .text
global _start

; -------------------------------------------------------------------------
; sys_read( fd=0, buf=buf_in, count=255 )
; Return value: number of bytes read in EAX
; -------------------------------------------------------------------------

read_line: mov eax, 3	; sys_read
	mov ebx, 0	; stdin (file descriptor 0)
	lea ecx, [buf_in + edi*4]
	mov edx, 4
	int 0x80
	ret

; -------------------------------------------------------------------------
; print_string( ecx=pointer, edx=length )
; -------------------------------------------------------------------------

print_string: mov eax, 4	; sys_write
	mov ebx, 1		; stdout
	int 0x80
	ret

; -------------------------------------------------------------------------
; print_newline()
; -------------------------------------------------------------------------

print_newline: mov eax, 4	; sys_write
	mov ebx, 1		; stdout
	mov ecx, newline
	mov edx, 1
	int 0x80
	ret

; -------------------------------------------------------------------------
; remove_leading_zeros_in_reversed( buf_sum )
;
; Our summed result is in reversed form in buf_sum:
; e.g. "000123" means actual number is 321000 if reversed again
; We want to remove leftmost zeros (in the buffer) so that "000123"
; becomes "123". If everything is zeros, leave just one '0'.
; -------------------------------------------------------------------------

remove_leading_zeros_in_reversed: push ebp
	mov ebp, esp
	mov esi, buf_sum

.strip_loop: mov al, [esi] ; If we've reached the end (all zeros?), break
	cmp al, 0
	je .all_zero	; we found 0 terminator => entire string was empty
	cmp al, '0'
	jne .done_stripping	; if first non-zero => done
				; Otherwise, it's a '0' at the front => shift the string left
				; We'll shift everything from [esi+1..end] left by one
	mov edi, esi

.shift_left: mov al, [edi + 1]
	mov [edi], al
	cmp al, 0
	je .strip_loop		; once we place 0, start over
	inc edi
	jmp .shift_left

.all_zero: mov byte [esi], '0' ; That means all got stripped => set the string to "0"
	mov byte [esi+1], 0
	jmp .done_stripping

.done_stripping: pop ebp
	ret

; -------------------------------------------------------------------------
; add_reversed( s1, s2, buf_sum )
; Both s1, s2 are reversed decimal strings (e.g. "123" representing 321).
; We do digit-wise addition from left to right:
;
; carry = 0
; i = 0
; while s1[i] != 0 or s2[i] != 0 or carry != 0:
; d1 = ( s1[i]? s1[i]-'0' : 0 )
; d2 = ( s2[i]? s2[i]-'0' : 0 )
; sum = d1 + d2 + carry
; carry = sum / 10
; sum = sum % 10
; buf_sum[i] = sum + '0'
; i++
; buf_sum[i] = 0
; -------------------------------------------------------------------------

add_reversed: push ebp
	mov ebp, esp
	; ESI -> s1, EDI -> s2, EBX -> buf_sum
	mov esi, s1
	mov edi, s2
	mov ebx, buf_sum
	xor ecx, ecx ; ecx = carry

.add_loop: mov al, [esi] ; Read digit from s1
	cmp al, 0
	je .use_zero_s1
	sub al, '0'		; convert from ascii
	jmp .got_d1

.use_zero_s1: xor eax, eax

.got_d1: mov dl, [edi] ; Read digit from s2
	cmp dl, 0
	je .use_zero_s2
	sub dl, '0'
	jmp .got_d2

.use_zero_s2: xor edx, edx

.got_d2: add al, dl		; d1 + d2
	add al, cl		; + carry in ecx's low byte
				; sum is now in AL
				; Compute new carry
	cmp al, 9
	jle .no_carry
	sub al, 10		; mod 10
	mov cl, 1		; carry = 1
	jmp .store_digit

.no_carry: xor ecx, ecx		; carry = 0

.store_digit: add al, '0'
	mov [ebx], al		; store result digit in buf_sum
	inc ebx

	cmp byte [esi], 0	; Advance pointer in s1 if not at zero
	je .skip_inc_s1
	inc esi

.skip_inc_s1: cmp byte [edi], 0 ; Advance pointer in s2 if not at zero
	je .skip_inc_s2
	inc edi

.skip_inc_s2: mov al, [esi]	; Check if we should continue:
	mov dl, [edi]		; We continue if either s1[i] or s2[i] is nonzero OR carry != 0
	or al, dl		; if both are zero => result = 0 in AL
	or al, cl		; also check carry
	jne .add_loop

	cmp cl, 0		; If carry is still set after we exit, we add one more digit
	je .done_adding

	mov byte [ebx], '1'	; carry = 1 => put one more '1'
	inc ebx

.done_adding: mov byte [ebx], 0	; Null-terminate
	pop ebp
	ret

; -------------------------------------------------------------------------
; parse_two_reversed:
; From the line in buf_in, extract two reversed strings into s1, s2.
; We'll copy until we hit space or newline for the first number,
; then the rest (until newline) for the second.
; Because input is e.g. "24 1" (both are reversed),
; we just store them as-is into s1, s2.
; -------------------------------------------------------------------------

parse_two_reversed: push ebp
	mov ebp, esp

	mov edi, s1	; Zero out s1 and s2 first
	mov ecx, 128

.clear_s1: mov byte [edi], 0
	inc edi
	loop .clear_s1

	mov edi, s2
	mov ecx, 128

.clear_s2: mov byte [edi], 0
	inc edi
	loop .clear_s2

	; Now parse from buf_in
	mov esi, buf_in		; read pointer
	mov edi, s1		; write pointer for s1

.next_char_s1: mov al, [esi]
	cmp al, ' '
	je .done_s1
	mov [edi], al
	inc edi
	inc esi
	jmp .next_char_s1

.done_s1: cmp al, ' '		; skip the space if that was a space
	jne .skip_space
	inc esi

.skip_space: mov edi, s2	; now parse s2

.next_char_s2: mov al, [esi]
	cmp al, 10
	je .done_s2
	mov [edi], al
	inc edi
	inc esi
	jmp .next_char_s2

.done_s2: pop ebp
	ret

; -------------------------------------------------------------------------
; convert_string_to_int_in_EBX( buf_in )
; Reads ASCII digits from buf_in until newline and places
; the integer result in EBX.
; -------------------------------------------------------------------------

convert_string_to_int_in_EBX: push ebp
	mov ebp, esp
	mov ebx, 0	; EBX will hold the integer
	;mov esi, buf_in

.next_char: mov al, [esi]
	cmp al, 10	; newline?
	je .done
	cmp al, 0
	je .done
	sub al, '0'
	imul ebx, ebx, 10	; EBX = EBX*10 + (al)
	add ebx, eax
	inc esi
	jmp .next_char

.done: pop ebp
	ret

; -------------------------------------------------------------------------
; print_buf_sum:
; Print buf_sum as is (which is the reversed sum after zero-stripping),
; then print a newline.
; -------------------------------------------------------------------------
print_buf_sum: push ebp
	mov ebp, esp
	mov esi, buf_sum
	xor edx, edx		; length in EDX

.len_loop: mov al, [esi + edx]
	cmp al, 0
	je .got_len
	inc edx
	jmp .len_loop

.got_len: mov ecx, buf_sum	; Now EDX = length
	mov eax, 4 ; sys_write
	mov ebx, 1
	int 0x80

	; Print newline
	call print_newline
	pop ebp
	ret

; -------------------------------------------------------------------------
; _start
; -------------------------------------------------------------------------
_start:
	; 1) Read the first line => N
	call read_line
	mov esi, buf_in
	call convert_string_to_int_in_EBX	; result in EBX
	mov [index], ebx
	mov esi, ebx				; store N in ESI (we'll decrement ESI each loop)
	xor edi, edi

.loop_cases: cmp esi, 0
	push esi
	je .done_all

	; read next line
	call read_line
	inc edi

	;cmp eax, 1	; if EAX <= 0, no more input (unexpected), just end
	;jl .done_all

	; parse into s1, s2
	;call parse_two_reversed

	; add them -> buf_sum
	;call add_reversed

	; remove leading zeros from reversed sum
	;call remove_leading_zeros_in_reversed

	mov esi, buf_sum
	call convert_string_to_int_in_EBX

	; print the result
	;call print_buf_sum
	pop esi
	dec esi
	jmp .loop_cases

.done_all: mov eax, 1		; Normal exit
	xor ebx, ebx
	int 0x80
