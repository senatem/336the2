list P=18F8722

#include <p18f8722.inc>
config OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF
    ;variable but0,but1,but2,but3
but0   udata 0x30
but0
   
but1   udata 0x31
but1
   
but2   udata 0x32
but2
   
but3   udata 0x33
but3
    
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
    MOVWF ADCON1
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
    movlw   b'00000111' ;Disable Timer0 by setting TMR0ON to 0 (for now)
                        ;Configure Timer0 as an 8-bit timer/counter by setting T08BIT to 1
                        ;Timer0 increment from internal clock with a prescaler of 1:256.
    movwf   T0CON ; T0CON = b'01000111'
    MOVLW 0xD2
    MOVWF TMR0H
    MOVLW 0x3A
    MOVWF TMR0L

    ;Enable interrupts
    movlw   b'11100000' ;Enable Global, peripheral, Timer0 and RB interrupts by setting GIE, PEIE, TMR0IE and RBIE bits to 1
    movwf   INTCON

    bsf     T0CON, 7    ;Enable Timer0 by setting TMR0ON to 1

MAIN
    CALL BUTTON0
    CALL BUTTON1
    CALL BUTTON2
    CALL BUTTON3
    GOTO MAIN

BUTTON0
    ; Button Task for RG0
    BTFSS PORTG,0
    goto _isoff0
    goto _ison0
    _isoff0:
	BTFSS but0,0
	return
	BTFSC PORTF,0
	return
	RLCF PORTF ;move right paddle down
	BCF but0,0
    _ison0:
	BTFSS but0,0
	BSF but0,0
	return
  

BUTTON1
    ; Button Task for RG1
    BTFSS PORTG,1
    goto _isoff1
    goto _ison1
    _isoff1:
	BTFSS but1,0
	return
	BTFSC PORTF,5
	return
	RRCF PORTF ;move right paddle up
	BCF but1,0
    _ison1:
	BTFSS but1,0
	BSF but1,0
	return
BUTTON2
    ; Button Task for RG2
    BTFSS PORTG,2
    goto _isoff2
    goto _ison2
    _isoff2:
	BTFSS but2,0
	return
	BTFSC PORTA,0
	return
	RLCF PORTA ;move left paddle down
	BCF but2,0
    _ison2:
	BTFSS but2,0
	BSF but2,0
	return
BUTTON3
    ; Button Task for RG0
    BTFSS PORTG,3
    goto _isoff3
    goto _ison3
    _isoff3:
	BTFSS but3,0
	return
	BTFSC PORTA,5
	return
	RRCF PORTA;move left paddle up
	BCF but3,0
    _ison3:
	BTFSS but3,0
	BSF but3,0
	return
ISR
    bcf     INTCON, 2
    MOVLW 0x00
    MOVWF TMR0L ; Reset Timer
    ; Move Ball
    ; Check Score
    RETFIE
    
    
    
    GOTO $                          ; loop forever

    END


