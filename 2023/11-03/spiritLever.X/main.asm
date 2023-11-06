; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
; PIC16F684 Configuration Bit Settings

; Assembly source line config statements

#include "p16f684.inc"

; CONFIG
; __config 0xFFE5
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

START

    GOTO $                          ; loop forever

    END