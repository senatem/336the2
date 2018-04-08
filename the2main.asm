list P=18F8722

#include <p18f8722.inc>
config OSC = HSPLL, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF, WDT = OFF, MCLRE = ON, LPT1OSC = OFF, LVP = OFF, XINST = OFF, DEBUG = OFF
    ;variable but0,but1,but2,but3
temp   udata 0x20
temp
    
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
 
stateA udata 0x36
stateA
 
stateB udata 0x37
stateB
 
stateC udata 0x38
stateC
 
stateD udata 0x39
stateD
 
stateE udata 0x3A
stateE
 
stateF udata 0x3B
stateF 
 
value_of_paddle udata 0x3C
value_of_paddle  
 
value_of_ball udata 0x3D
value_of_ball 
 
scoreA udata 0x40
scoreA
 
scoreB udata 0x41
scoreB 

t udata 0x42
t
    
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
    CLRF direction
    
    CLRF scoreA
    CLRF scoreB
    
    ;Initialize 7-segment display
    CLRF PORTH
    BSF PORTH,0
    MOVLW 0x3F
    MOVWF PORTJ
    CALL DELAY
    BCF PORTH,0
    BSF PORTH,2
    CALL DELAY
    BCF PORTH,2
    
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

    bsf T0CON, 7    ;Enable Timer0 by setting TMR0ON to 1
    bsf T1CON,0
    bsf PIE1,0
    BSF stateD,0
    
DELAY ;7-segment init delay
    MOVLW 0x0F
    MOVWF t
    _loop:
        DECFSZ t,F
	GOTO _loop
    RETURN
MAIN
    CALL BUTTON0
    CALL BUTTON1
    CALL BUTTON2
    CALL BUTTON3
    GOTO MAIN

BUTTON0    ; Button Task for RG0
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

BUTTON1   ; Button Task for RG1
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
BUTTON2 ; Button Task for RG2
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
BUTTON3   ; Button Task for RG0
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
;OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOoo	
ISRMAIN
    btfss   INTCON, 2       
    goto    ISR1
    goto    ISR0
ISR0
    bcf     INTCON, 2
    INCF timehelper
    MOVLW 0x2E
    CPFSEQ timehelper
    RETFIE
    ;---------------------------------------
    CLRF timehelper
    BTFSC direction,0
    GOTO path_right
    path_left:
    onA:
    BTFSS stateA,0
    GOTO onB
    MOVF value_of_ball,0
    ANDWF value_of_paddle,0
    SUBLW 0x00
    BTFSC STATUS,Z
    GOTO score_for_B
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxA
    BTFSS value_of_ball,0
    RRNCF value_of_ball,1
    GOTO decideA
    azxA:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO decideA
    BTFSS value_of_ball,5
    RLNCF value_of_ball,1
    decideA:
    MOVFF value_of_paddle,PORTA ; put paddle value to PORTA
    MOVFF value_of_ball,PORTB
    CLRF stateA
    BSF stateB,0
    BSF direction,0  ;change the direction so it will choose path_right for next interrupt
    GOTO _update7segment
    ;--------------  
    score_for_B:
    INCF scoreB
    BTFSS scoreB,2
    GOTO below_five
    BTFSS scoreB,0
    GOTO below_five
    GOTO B_equal_five
    below_five:
    CLRF stateA
    MOVLW b'00011100'
    MOVWF PORTA
    MOVWF PORTF
    BSF PORTD,3
    BSF stateD,0
    GOTO _update7segment
   
    B_equal_five:
    MOVLW b'00011100'
    MOVWF PORTA
    MOVWF PORTF
    BSF PORTD,3
    MOVLW b'00000000'
    MOVWF INTCON
    onB:
    BTFSS stateB,0
    GOTO onC
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxB
    BTFSS PORTB,0
    RRNCF PORTB,1
    GOTO decideB
    azxB:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO decideB
    BTFSS PORTB,5
    RLNCF PORTB,1
    decideB:  
    MOVFF PORTB,value_of_ball  ;topun de?erini tut
    MOVFF PORTA,value_of_paddle  ; PORTA n?n de?erini tut
    MOVF PORTA,0
    IORWF PORTB,1
    MOVFF PORTB,PORTA
    CLRF PORTB
    CLRF stateB
    BSF stateA,0
    GOTO _update7segment


    onC:
    BTFSS stateC,0
    GOTO onD
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxC
    BTFSS PORTC,0
    RRNCF PORTC,1
    GOTO decideC
    azxC:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO decideC
    BTFSS PORTC,5
    RLNCF PORTC,1
    decideC:
    MOVFF PORTC,PORTB
    CLRF PORTC
    CLRF stateC
    BSF stateB,0
    GOTO _update7segment
    
    onD:
    BTFSS stateD,0
    GOTO onE
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxD
    BTFSS PORTD,0
    RRNCF PORTD,1
    GOTO decideD
    azxD:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO decideD
    BTFSS PORTD,5
    RLNCF PORTD,1
    decideD:
    MOVFF PORTD,PORTC
    CLRF PORTD
    CLRF stateD
    BSF stateC,0
    GOTO _update7segment

    onE:
    BTFSS stateE,0
    RETFIE
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxE
    BTFSS PORTE,0
    RRNCF PORTE,1
    GOTO decideE
    azxE:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO decideE
    BTFSS PORTE,5
    RLNCF PORTE,1
    decideE:
    MOVFF PORTE,PORTD
    CLRF PORTE
    CLRF stateE
    BSF stateD,0
    GOTO _update7segment
    
path_right:
    
    onrB:
    BTFSS stateB,0
    GOTO onrC
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxrB
    BTFSS PORTB,0
    RRNCF PORTB,1
    GOTO deciderB
    azxrB:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO deciderB
    BTFSS PORTB,5
    RLNCF PORTB,1
    deciderB:
    MOVFF PORTB,PORTC
    CLRF PORTB
    CLRF stateB
    BSF stateC,0
    GOTO _update7segment
    
    onrC:
    BTFSS stateC,0
    GOTO onrD
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxrC
    BTFSS PORTC,0
    RRNCF PORTC,1
    GOTO deciderC
    azxrC:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO deciderC
    BTFSS PORTC,5
    RLNCF PORTC,1
    deciderC:
    MOVFF PORTC,PORTD
    CLRF PORTC
    CLRF stateC
    BSF stateD,0
    GOTO _update7segment
    
    onrD:
    BTFSS stateD,0
    GOTO onrE
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxrD
    BTFSS PORTD,0
    RRNCF PORTD,1
    GOTO deciderD
    azxrD:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO deciderD
    BTFSS PORTD,5
    RLNCF PORTD,1
    deciderD:
    MOVFF PORTD,PORTE
    CLRF PORTD
    CLRF stateD
    BSF stateE,0
    GOTO _update7segment
    
    onrE:
    BTFSS stateE,0
    GOTO onrF
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxrE
    BTFSS PORTE,0
    RRNCF PORTE,1
    GOTO deciderE
    azxrE:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO deciderE
    BTFSS PORTE,5
    RLNCF PORTE,1
    deciderE: 
    MOVFF PORTE,value_of_ball  ;topun de?erini tut
    MOVFF PORTF,value_of_paddle
    MOVF PORTF,0  ; PORTF n?n de?erini tut
    IORWF PORTE,1
    MOVFF PORTE,PORTF
    CLRF PORTE
    CLRF stateE
    BSF stateF,0
    GOTO _update7segment
    
    onrF:
    BTFSS stateF,0
    RETFIE
    MOVF value_of_ball,0
    ANDWF value_of_paddle,0
    SUBLW 0x00
    BTFSC STATUS,Z    
    GOTO score_for_A
    BTFSS TMR1L,1    
    BTFSS TMR1L,0
    GOTO azxrF
    BTFSS value_of_ball,0
    RRNCF value_of_ball,1
    GOTO deciderF
    azxrF:
    BTFSC TMR1L,1    
    BTFSC TMR1L,0
    GOTO deciderF
    BTFSS value_of_ball,5
    RLNCF value_of_ball,1
    deciderF:
    MOVFF value_of_paddle,PORTF ; put paddle value to PORTF
    MOVFF value_of_ball,PORTE
    CLRF stateF
    BSF stateE,0
    BCF direction,0  ;change the direction so it will choose path_right for next interrupt
    GOTO _update7segment
    
    score_for_A:
    BCF direction,0
    INCF scoreA
    BTFSS scoreA,2
    GOTO below_fiveR
    BTFSS scoreA,0
    GOTO below_fiveR
    GOTO A_equal_five
    below_fiveR:
    CLRF stateF
    MOVLW b'00011100'
    MOVWF PORTA
    MOVWF PORTF
    BSF PORTD,3
    BSF stateD,0
    GOTO _update7segment
   
    A_equal_five:
    MOVLW b'00011100'
    MOVWF PORTA
    MOVWF PORTF
    BSF PORTD,3
    CLRF INTCON
    GOTO _update7segment
    
    _update7segment:
	MOVF scoreA,0
	ADDWF   PCL, F  ; modify program counter
	MOVLW b'00111111'
	MOVLW b'00000110'
	MOVLW b'01011011'
	MOVLW b'01001111'
	MOVLW b'01100110'
	MOVLW b'01101101'
	BSF PORTH,0
	MOVWF PORTJ
	
	MOVF scoreB,0
	ADDWF   PCL, F  ; modify program counter
	MOVLW b'00111111'
	MOVLW b'00000110'
	MOVLW b'01011011'
	MOVLW b'01001111'
	MOVLW b'01100110'
	MOVLW b'01101101'
	BSF PORTH,2
	MOVWF PORTJ
	RETFIE
    
ISR1
    bcf PIR1,0
    MOVLW 0x8F
    MOVWF TMR1L
    BCF PORTH,0
    BCF PORTH,2
    RETFIE
    
    GOTO $                          ; loop forever    
    END