msg     db "Please provide a word: ",0
len     equ $ - msg

palindrome  db  'The word is a palindrome'
lenP        equ $ - palindrome

notPalindrome   db  'The word is not a palindrome'
lenNP           equ $ - notPalindrome

segment .bss
input   resb  10        ; reserve 10 bytes for input
length  equ $ - input

section .text
    global main
    
main:
    mov     edx, len        ; number of bytes to write
    mov     ecx, msg        ; ECX will point to the address of the string msg
    mov     ebx, 1          ; write to the STDOUT file
    mov     eax, 4          ; invoke SYS_WRITE (kernel opcode 4)
    int     0x80
    
    mov     edx, 10         ; number of bytes to read
    mov     ecx, input      ; reserve space for the user's input
    mov     ebx, 0          ; write to the STDIN file
    mov     eax, 3          ; invoke SYS_READ (kernel opcode 3)
    int     0x80            ; start of word  

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
    jmp capitalizer
    
finished:
    mov     edx, lenP         
    mov     ecx, palindrome      
    mov     ebx, 1          
    mov     eax, 4
    int     0x80  
    jmp     exit
    
fail:
    mov     edx, lenNP         
    mov     ecx, notPalindrome      
    mov     ebx, 1          
    mov     eax, 4
    int     0x80  
  
 exit:
    mov     eax, 1
    mov     ebx, 0
    int     0x80
