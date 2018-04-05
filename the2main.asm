#include "p18f8722.inc"

UDATA_ACS
  t1	res 1	; used in delay
  t2	res 1	; used in delay
  t3	res 1	; used in delay

ORG    0x00            ; processor reset vector
    GOTO    INIT                  ; go to beginning of program
    
ORG     0x08
    GOTO    ISR             ;go to interrupt service routine
    
INIT
    CLRF TRISA
    CLRF TRISB
    CLRF TRISC
    CLRF TRISD
    CLRF TRISE
    CLRF TRISF
    CLRF TRISH
    CLRF TRISJ
    CLRF PORTF
    CLRF PORTG
    MOVLW 0x0F
    MOVWF TRISG
    CLRF PORTB
    CLRF PORTC
    MOVLW 0x08
    MOVWF PORTD    
    MOVLW 0x1C
    MOVWF PORTA
    MOVWF PORTE
    MOVLW 0x01
    MOVWF PORTH
    MOVLW 0x3F
    MOVWF PORTJ
    MOVLW 0xC3
    MOVWF T0CON
    MOVLW 0x45
    MOVWF TMR0L
    BSF INTCON,7
    BSF INTCON,5

MAIN
    CALL BUTTON1
    CALL BUTTON2
    CALL BUTTON3
    CALL BUTTON4
    GOTO MAIN

BUTTON1
    ; Button Task for RG0
BUTTON2
    ; Button Task for RG1
BUTTON3
    ; Button Task for RG2
BUTTON4
    ; Button Task for RG3
ISR
    ; Reset Timer
    ; Move Ball
    ; Check Score
    
    
    
    
    GOTO $                          ; loop forever

    END


