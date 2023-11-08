; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
; PIC16F684 Configuration Bit Settings

; Assembly source line config statements

#include "p16f684.inc"

; CONFIG
; __config 0xFFE5
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON

;RES_VECT  CODE    0x0000            ; processor reset vector

 org 0 ; Org 0 Tells the assembler where to start generating code.

delay equ 20h	; delay label address

    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

START

    ;GOTO $                          ; loop forever
    ; Starting A/D convertion (configuring analog input 3 AN3/RA4
    bsf STATUS,5    ; select bank 1 to access ADCON1 register
    movlw 0x0	    ; move 0x0 to w register
    movwf ADCON1    ; move 0x0 to ADCON1 register for an A/D conversion clock = Fosc/2
    bsf TRISA,4	    ; setting RA4 as input
    bsf ANSEL,3	    ; set pin RA4/AN3 as analog input
    bcf STATUS,RP0  ; select bank 0 to access ADCON0 register
    movlw b'10001101'; Right justified, Vref=Vref pin, AN3, ADON=1
    movwf ADCON0    ; w to ADCON0 register, configures and turn on AD converter
    call sTim	    ; delay to take a sample
    bsf ADCON0,1    ; Starts A/D conversion
    btfsc ADCON0,1  ; is conversion done?
    goto $-1	    ; no, test again
    
    ; conversion/4 --> ADRESL
    rrf ADRESH,1    ; rotate 1 bit to the right
    bsf STATUS,RP0  ; select bank 1 to access bank 1 registers
    rrf ADRESL,1    ; rotate all bits of adresl to the right
    bcf STATUS,0    ; clearing carry bit, don't need it
    bcf STATUS,RP0  ; select bank 0
    rrf ADRESH,1    ; rotate 1 bit to the right
    bsf STATUS,RP0  ; select bank 1 to access bank 1 registers
    rrf ADRESL,1    ; rotate all bits of adresl to the right
    
    ;movf ADRESL,0   ; w=ADRESL
    
    ; for testing purposes
    
;    clrf TRISA	    ; all pins as digital outputs
;    clrf ANSEL	    ; all pins as digital I/O
;    clrf TRISC	    ; all PORTC pins as outputs
;    movf ADRESL,0   ; move adresl to w register
;    bcf STATUS,5    ; select bank 0 to access bank 0 registers
;    movwf PORTC	    ; moves adresl to portc
;    movf ADRESH,0   ; move ADRESH to w register
;    movwf PORTA	    ; adresh to porta

    goto START
    
sTim movlw d'12'    ; w=12
    movwf delay	    ; delay = 12
    decfsz delay,1  ; decrement delay, if it's 0, skip next line
    goto $-1	    ; go to previous line
    return	    ; end of procedure

    END
