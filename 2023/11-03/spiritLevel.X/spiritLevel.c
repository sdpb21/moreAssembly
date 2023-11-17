/*
 * File:   spiritLevel.c
 * Author: 
 *
 * Created on November 16, 2023, 8:31 PM
 */

// PIC16F684 Configuration Bit Settings

// 'C' source line config statements

// CONFIG
#pragma config FOSC = INTOSCCLK // Oscillator Selection bits (INTOSC oscillator: CLKOUT function on RA4/OSC2/CLKOUT pin, I/O function on RA5/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled)
#pragma config PWRTE = ON       // Power-up Timer Enable bit (PWRT enabled)
#pragma config MCLRE = ON       // MCLR Pin Function Select bit (MCLR pin function is MCLR)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = ON       // Brown Out Detect (BOR enabled)
#pragma config IESO = ON        // Internal External Switchover bit (Internal External Switchover mode is enabled)
#pragma config FCMEN = ON       // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>

#define _XTAL_FREQ 4000000
#define greenLedLowLim_HA   508 // 1.49 V
#define greenLedHighLim_HA  515 // 1.51 V
#define yelLefLedHiLim_HA   529 // 1.55 V
#define yelRigLedLowLim_HA  495 // 1.45 V
unsigned int adc, yLevel0;
__bit flag = 0;

void main(void) {
    
    while(1){
        ADCON1 = 0b00010000;    // A/D conversion clock set to Fosc/8
        TRISAbits.TRISA4 = 1;   // setting RA4/AN3 as input
        TRISC = 0b00000001;     // RC0/AN4 as analog input, others as outputs
        ANSEL = 0b00011000;     // analog inputs: AN3, AN4, digital I/O: AN2, AN5, AN6, AN7
        ADCON0 = 0b11001101;    // Right justified, Vref=Vref pin, AN3, ADON=1
        ADCON0bits.GO = 1;      // Starts an A/D conversion cycle
        while( ADCON0bits.GO == 1 ){    // waiting for the conversion
            ;
        }
        adc = (ADRESH << 8) + ADRESL;   // conversion result to adc var
        __delay_ms(500);        // 500ms delay
        
        // setting 0 level for Y axis
        if( !flag && PORTAbits.RA2 == 1 ){
            yLevel0 = adc;      // storing Y zero level
            flag = 1;           // flag to indicate that Y zero level is set
            PORTC = 0b00001000; // turn on green led (center)
            continue;
        }
        
        // turn on green, yellow o red led
        if( flag ){
            // turn on green led
            if( adc >= greenLedLowLim_HA && adc <= greenLedHighLim_HA ){
                PORTC = 0b00001000;
            }
            // turn on yellow left led
            if( adc > greenLedHighLim_HA && adc <= yelLefLedHiLim_HA ){
                PORTC = 0b00010000;
            }
            // turn on yellow right led
            if( adc >= yelRigLedLowLim_HA && adc < greenLedLowLim_HA ){
                PORTC = 0b00000100;
            }
            // turn on red left led
            if( adc > yelLefLedHiLim_HA ){
                PORTC = 0b00100000;
            }
            // turn on red right led
            if( adc < yelRigLedLowLim_HA ){
                PORTC = 0b00000010;
            }
        }
    }
    //return;
}
