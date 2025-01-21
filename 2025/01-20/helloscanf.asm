section .text
  global main
  extern printf
  extern scanf

section .data
  message: db "The result is = %d", 10, 0
  request: db "Enter the number: ", 0
  integer1: times 4 db 0 ; 32-bits integer = 4 bytes
  formatin: db "%d", 0

main:
  ;  Ask for an integer
  push request
  call printf
  add esp, 4    ; remove the parameter

  push integer1 ; address of integer1, where the input is going to be stored (second parameter)
  push formatin ; arguments are right to left (first  parameter)
  call scanf
  add esp, 8    ; remove the parameters

  ; Move the value under the address integer1 to EAX
  mov eax, [integer1]

  ; Print out the content of eax register
  push rax
  push message
  call printf
  add esp, 8

  ;  Linux terminate the app
  MOV AL, 1
  MOV EBX, 0 
  INT 80h 
