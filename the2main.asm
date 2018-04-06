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
   
timehelper udata 0x34
timehelper
 
direction udata 0x35
direction
 
    
ORG    0x00            ; processor reset vector
    GOTO    INIT                  ; go to beginning of program
    
ORG     0x08
    GOTO    ISRMAIN             ;go to interrupt service routine
    
INIT
    CLRF TRISA
    CLRF TRISB
    CLRF TRISC
    CLRF TRISD
    CLRF TRISE
    CLRF TRISF
    MOVLW 0x0F
    MOVWF TRISG
    CLRF TRISH
    CLRF TRISJ
    MOVWF ADCON1
    MOVLW 0x1C
    MOVWF PORTA
    CLRF PORTB
    CLRF PORTC
    MOVLW 0x08
    MOVWF PORTD
    CLRF PORTE
    MOVLW 0x1C
    MOVWF PORTF
    CLRF PORTG
    
    ;Disable interrupts
    clrf    INTCON
    clrf    INTCON2


    ;Initialize Timer0
    movlw   b'01000111' ;Disable Timer0 by setting TMR0ON to 0 (for now)
                        ;Configure Timer0 as an 8-bit timer/counter by setting T08BIT to 1
                        ;Timer0 increment from internal clock with a prescaler of 1:256.
    movwf   T0CON ; T0CON = b'01000111'
    
    ;Initialize Timer1
    CLRF T1CON
    CLRF PIE1
    CLRF IPR1
    CLRF PIR1
    MOVLW 0x8F
    MOVWF TMR1L
    
    ;Enable interrupts
    movlw   b'11100000' ;Enable Global, peripheral, Timer0 interrupts by setting GIE, PEIE, TMR0IE and bits to 1
    movwf   INTCON

    bsf     T0CON, 7    ;Enable Timer0 by setting TMR0ON to 1
    bsf T1CON,0
    bsf PIE1,0

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
	BTFSC PORTF,5
	return
	RLNCF PORTF ;move right paddle down
	BCF but0,0
	return
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
	BTFSC PORTF,0
	return
	RRNCF PORTF ;move right paddle up
	BCF but1,0
	return
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
	BTFSC PORTA,5
	return
	RLNCF PORTA ;move left paddle down
	BCF but2,0
	return
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
	BTFSC PORTA,0
	return
	RRNCF PORTA ;move left paddle up
	BCF but3,0
	return
    _ison3:
	BTFSS but3,0
	BSF but3,0
	return
ISRMAIN
    btfss   INTCON, 2       
    goto    ISR1
    goto    ISR0
ISR0
    bcf     INTCON, 2
    INCF timehelper
    MOVFF TMR1L,direction
    MOVLW 0x2E
    CPFSEQ timehelper
    RETFIE
    ; Move Ball
    ; Check Score
    CLRF timehelper
    RETFIE
    
ISR1
    bcf PIR1,0
    MOVLW 0x8F
    MOVWF TMR1L
    RETFIE
    
    
    
    GOTO $                          ; loop forever

    END


