; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
; PIC16F684 Configuration Bit Settings

; Assembly source line config statements

#include "p16f684.inc"

; CONFIG
; __config 0xFFE5
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON

;RES_VECT  CODE    0x0000            ; processor reset vector

 org 0 ; Org 0 Tells the assembler where to start generating code.

delay	equ 20h	; delay label address
de500	equ 21h	; to use for a 500ms delay
l0a3	equ 22h	; to store level 0 from AN3
flags	equ 23h	; flags to avoid some code lines
    
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

START
    call geta3

    ; delay
    bcf STATUS,RP0  ; select bank 0 to access GPR memory space
    movlw d'10'	    ; w=10
    movwf de500	    ; de500=10
    bsf STATUS,RP0  ; select bank 1 where OPTION_REG is
    movlw b'00000111'; prescaler rate:256
    movwf OPTION_REG; T0CS:internal(Fosc/4), prescaler to TMR0
d50 bcf INTCON,T0IF ; Timer0 interrupt flag cleared for a new overflow
    bcf STATUS,RP0  ; select bank 0 for TMR0 register
    movlw d'60'	    ; TMR0=60 for a 50ms delay
    movwf TMR0	    ; w=60=TMR0
    btfss INTCON,T0IF; if T0IF isn't 0,
    goto $-1	    ; go to previous line until T0IF sets
    decfsz de500    ; to repeat 10 times the 50ms delay
    goto d50	    ; go to d50 label to repeat the 50ms delay
    
    ; setting horizontal level
    btfsc flags,0   ; if flags<0> is 0, set the horizontal level
    goto la1	    ; else, avoid setting horizontal level again
    btfss PORTA,RA2 ; if RA2 is 1
    goto START	    ; do not go to START and store ADRESL in file register l0a3
    bsf STATUS,RP0  ; select bank 1
    movf ADRESL,0   ; move ADRESL to w
    bcf STATUS,RP0  ; select bank 0
    movwf l0a3	    ; stores ADRESL in file register l0a3 (memory)
    bsf flags,0	    ; flag to indicate that horizontal level is set
    goto START
    
la1
    ; comparing with horizontal level
    bcf STATUS,RP0  ; select bank 0
    movf l0a3,0	    ; move l0a3 to w
    bsf STATUS,RP0  ; select bank 1
    xorwf ADRESL,0  ; ADRESL XOR W --> W
    btfss STATUS,Z  ; if Z=1, turn on green led
    goto yrl	    ; else, turn on yellow or red leds
    ; turn on green led from here
    bcf STATUS,RP0  ; select bank 0
    movlw b'00001000'
    movwf PORTC	    ; RC3=1 turn on green led
    goto START
    
yrl
    goto START

geta3
    ; Starting A/D convertion (configuring analog input 3 AN3/RA4
    bsf STATUS,5    ; select bank 1 to access ADCON1 register
    movlw 0x0	    ; move 0x0 to w register
    movwf ADCON1    ; move 0x0 to ADCON1 register for an A/D conversion clock = Fosc/2
    bsf TRISA,4	    ; setting RA4/AN3 as input
    movlw b'00000001'; RC0/AN4 as analog input
    movwf TRISC	    ; RC1-5 as outputs
;    bsf ANSEL,3	    ; set pin RA4/AN3 as analog input
;    bcf ANSEL,2	    ; set pin RA2/AN2 as digital I/O
    movlw b'00011000'; analog inputs: AN3, AN4
    movwf ANSEL	    ; digital I/O: AN2, AN5, AN6, AN7
    clrf WPUA	    ; all PORTA pins without weak pull-up resistor
    bcf STATUS,RP0  ; select bank 0 to access ADCON0 register
    movlw b'10001101'; Right justified, Vref=Vref pin, AN3, ADON=1
    movwf ADCON0    ; w to ADCON0 register, configures and turn on AD converter
    movlw 0x7
    movwf CMCON0    ; set RA<2:0> to digital I/O
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
    return
    
sTim movlw d'12'    ; w=12
    movwf delay	    ; delay = 12
    decfsz delay,1  ; decrement delay, if it's 0, skip next line
    goto $-1	    ; go to previous line
    return	    ; end of procedure

    END
