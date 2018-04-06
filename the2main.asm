#include "p18f8722.inc"

    ;variable but0,but1,but2,but3
    
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
    
    ;Disable interrupts
    clrf    INTCON
    clrf    INTCON2


    ;Initialize Timer0
    movlw   b'01000111' ;Disable Timer0 by setting TMR0ON to 0 (for now)
                        ;Configure Timer0 as an 8-bit timer/counter by setting T08BIT to 1
                        ;Timer0 increment from internal clock with a prescaler of 1:256.
    movwf   T0CON ; T0CON = b'01000111'

    ;Enable interrupts
    movlw   b'11100000' ;Enable Global, peripheral, Timer0 and RB interrupts by setting GIE, PEIE, TMR0IE and RBIE bits to 1
    movwf   INTCON

    bsf     T0CON, 7    ;Enable Timer0 by setting TMR0ON to 1

MAIN
    CALL BUTTON1
    CALL BUTTON2
    CALL BUTTON3
    CALL BUTTON4
    GOTO MAIN

BUTTON0
    ; Button Task for RG0
    BTFSS PORTG,0
    goto _isoff
    goto _ison
    _isoff:
	BTFSS but0,0
	return
	BTFSC PORTF,0
	return
	RLCF PORTF ;move right paddle down
	BCF but0,0
    _ison:
	BTFSS but0,0
	BSF but0,0
	return
  

BUTTON1
    ; Button Task for RG1
    BTFSS PORTG,1
    goto _isoff
    goto _ison
    _isoff:
	BTFSS but1,0
	return
	BTFSC PORTF,5
	return
	RRCF PORTF ;move right paddle up
	BCF but1,0
    _ison:
	BTFSS but1,0
	BSF but1,0
	return
BUTTON2
    ; Button Task for RG2
    BTFSS PORTG,2
    goto _isoff
    goto _ison
    _isoff:
	BTFSS but2,0
	return
	BTFSC PORTA,0
	return
	RLCF PORTA ;move left paddle down
	BCF but2,0
    _ison:
	BTFSS but2,0
	BSF but2,0
	return
BUTTON3
    ; Button Task for RG0
    BTFSS PORTG,3
    goto _isoff
    goto _ison
    _isoff:
	BTFSS but3,0
	return
	BTFSC PORTA,5
	return
	RRCF PORTA;move left paddle up
	BCF but3,0
    _ison:
	BTFSS but3,0
	BSF but3,0
	return
ISR
    MOVLW 0x45
    MOVWF TMR0L
    MOVLW 0x0F
    MOVWF PORTA
    RETFIE
    ; Reset Timer
    ; Move Ball
    ; Check Score
    
    
    
    
    GOTO $                          ; loop forever

    END


