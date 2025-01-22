section .text

global main

main:
       mov eax, 0       
       mov ebx, array         
       mov ecx, 5  
loop:
       cmp ecx, 0   
       je print 
       add eax, [ebx]
       add ebx, 4   
       sub ecx, 1
       jmp loop
print:
       ; convert integer to string
       mov  esi, buffer
       call int_to_string   
       ; eax now holds the address to pass to sys_write
       
       ; call write syscall
       mov edx, ecx   ; length of the string
       mov ecx, eax   ; address of the string
       mov ebx, 1     ; file descriptor, in this case stdout
       mov eax, 4     ; Syscall number:  write
       int 0x80

       ; call exit syscall
       mov eax, 1
       int 0x80

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
  
section .data
            array dd 10, 20, 30, 40, 50  
    
section .bss
            buffer resb 10
