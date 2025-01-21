section .data
    promptInput db "Enter the number of test cases: ", 0
    promptNumbers db "Enter two numbers: ", 0
    resultMsg db "Result: %d", 10, 0
    outputMsg db 10, "Output is:", 10, 0
    scanFmt db "%d %d", 0

section .bss
    n resd 1 ; Store the number of test cases
    num1 resd 1 ; First input number
    num2 resd 1 ; Second input number
    revNum1 resd 1 ; Reversed first number
    revNum2 resd 1 ; Reversed second number
    result resd 1 ; Final result

section .text
    global _start
    extern _printf, _scanf, _exit

_start:
    ; Ask for number of test cases
    push promptInput
    call _printf
    add esp, 4

    ; Read the number of test cases
    lea eax, [n]
    push eax
    push scanFmt
    call _scanf
    add esp, 8

    ; Initialize loop counter
    mov ecx, [n] ; Number of test cases in ECX for the loop
    jecxz exit ; If there are no test cases, exit

loop_start:
    ; Prompt for two numbers
    push promptNumbers
    call _printf
    add esp, 4

    ; Read two numbers
    lea eax, [num2]
    push eax
    lea eax, [num1]
    push eax
    push scanFmt
    call _scanf
    add esp, 12

    ; Reverse num1
    mov eax, [num1]
    call reverse_number
    mov [revNum1], eax ; Store reversed num1

    ; Reverse num2
    mov eax, [num2]
    call reverse_number
    mov [revNum2], eax ; Store reversed num2

    ; Add the reversed numbers
    mov eax, [revNum1]
    add eax, [revNum2]
    call reverse_number ; Reverse the sum
    mov [result], eax ; Store the final result

    ; Output the result
    push dword [result]
    push resultMsg
    call _printf
    add esp, 8

    ; Decrement loop counter and repeat if necessary
    dec ecx
    jnz loop_start

exit:
    ; Print output message and exit
    push outputMsg
    call _printf
    add esp, 4

    push 0
    call _exit

; Subroutine to reverse a number
; Input: Number in EAX
; Output: Reversed number in EAX
reverse_number:
    xor edx, edx ; Clear remainder
    mov ebx, 10 ; Divisor for base 10
    xor ecx, ecx ; Clear reversed number

reverse_loop:
    cmp eax, 0 ; Check if the number is 0
    je reverse_done ; If 0, we're done reversing

    xor edx, edx ; Clear remainder
    div ebx ; Divide EAX by 10, remainder in EDX
    imul ecx, ecx, 10 ; Multiply reversed number by 10
    add ecx, edx ; Add remainder to the reversed number
    jmp reverse_loop ; Continue the loop
    