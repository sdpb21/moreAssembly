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
#include <stdlib.h>

#define _XTAL_FREQ 4000000

#define greenLedLowLim_HA   508 // 1.49 V
#define greenLedHighLim_HA  515 // 1.51 V
#define yelLefLedHiLim_HA   529 // 1.55 V
#define yelRigLedLowLim_HA  495 // 1.45 V

#define greenLedLowLim_LA   505 // 1.48 V
#define greenLedHighLim_LA  518 // 1.52 V
#define yelLefLedHiLim_LA   546 // 1.60 V
#define yelRigLedLowLim_LA  477 // 1.40 V

#define adcM                511 // 1.50 V

unsigned int adc3, adc4, adc, yLevel0;
__bit flag = 0;
int difY, difZ;

void main(void) {
    
    while(1){
        ADCON1 = 0b00010000;    // A/D conversion clock set to Fosc/8
        TRISAbits.TRISA4 = 1;   // setting RA4/AN3 as input
        TRISC = 0b00000001;     // RC0/AN4 as analog input, others as outputs
        ANSEL = 0b00011000;     // analog inputs: AN3, AN4, digital I/O: AN2, AN5, AN6, AN7
        
        // reading analog input AN3 (Y axis)
        ADCON0 = 0b11001101;    // Right justified, Vref=Vref pin, AN3, ADON=1
        ADCON0bits.GO = 1;      // Starts an A/D conversion cycle
        while( ADCON0bits.GO == 1 ){    // waiting for the conversion
            ;
        }
        adc3 = (ADRESH << 8) + ADRESL;   // conversion result to adc3 var
        difY = adc3 - adcM;     // difference between analog read Y and middle point
        difY = abs(difY);       // difference absolute value
        
        // reading analog input AN4 (Z axis)
        ADCON0 = 0b11010001;    // Right justified, Vref=Vref pin, AN4, ADON=1
        ADCON0bits.GO = 1;      // Starts an A/D conversion cycle
        while( ADCON0bits.GO == 1 ){    // waiting for the conversion
            ;
        }
        adc4 = (ADRESH << 8) + ADRESL;   // conversion result to adc4 var
        difZ = adc4 - adcM;     // difference between analog read Z and middle point
        difZ = abs(difZ);       // difference absolute value to compare
        
        // if difY < difZ, Y axis is horizontal or close to
        // else Z axis is horizontal or close to that position
        if( difY < difZ ){
            adc = adc3;         // Y axis converted value to adc variable to compare
        }else{
            adc = adc4;         // Z axis converted value to adc var to compare below
        }
        
        __delay_ms(500);        // 500ms delay
        
        // setting 0 level for Y axis
        if( !flag && PORTAbits.RA2 == 1 ){
            yLevel0 = adc;      // storing Y zero level
            flag = 1;           // flag to indicate that Y zero level is set
            PORTC = 0b00001000; // turn on green led (center)
            continue;
        }
        
        // turn on green, yellow o red led (High Accuracy)
        if( flag && PORTAbits.RA5 == 0 ){
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
        
        // turn on green, yellow o red led (Low Accuracy)
        if( flag && PORTAbits.RA5 == 1 ){
            // turn on green led
            if( adc >= greenLedLowLim_LA && adc <= greenLedHighLim_LA ){
                PORTC = 0b00001000;
            }
            // turn on yellow left led
            if( adc > greenLedHighLim_LA && adc <= yelLefLedHiLim_LA ){
                PORTC = 0b00010000;
            }
            // turn on yellow right led
            if( adc >= yelRigLedLowLim_LA && adc < greenLedLowLim_LA ){
                PORTC = 0b00000100;
            }
            // turn on red left led
            if( adc > yelLefLedHiLim_LA ){
                PORTC = 0b00100000;
            }
            // turn on red right led
            if( adc < yelRigLedLowLim_LA ){
                PORTC = 0b00000010;
            }
        }
    }
    //return;
}
