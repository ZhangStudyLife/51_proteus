;====================================================================
; AT89C51 + ADC0808
; Proteus ASEM-51
;====================================================================

$NOMOD51
$INCLUDE (8051.MCU)

ADC_OE  EQU 0A1H       ; P2.1
ADC_ST  EQU 0A2H       ; P2.2 START + ALE
ADC_EOC EQU 0B4H       ; P3.4

SEG_LE  EQU 0A6H       ; P2.6
BIT_LE  EQU 0A7H       ; P2.7

CNT     EQU 30H
TEN     EQU 31H
ONE     EQU 32H

        ORG 0000H
        LJMP START

        ORG 000BH
        LJMP T0_INT

        ORG 0100H

START:
        MOV SP,#60H

        MOV P0,#00H
        MOV P1,#0FFH
        MOV P2,#0FFH

        CLR ADC_OE
        CLR ADC_ST

        MOV CNT,#20
        MOV TEN,#2
        MOV ONE,#5

        MOV TMOD,#01H
        MOV TH0,#3CH        ; 50 ms, 12 MHz
        MOV TL0,#0B0H

        SETB ET0
        SETB EA
        SETB TR0

MAIN:
        ; close all digits
        MOV P0,#0FFH
        SETB BIT_LE
        CLR BIT_LE

        ; show ten
        MOV DPTR,#TAB
        MOV A,TEN
        MOVC A,@A+DPTR
        MOV P0,A
        SETB SEG_LE
        CLR SEG_LE

        MOV P0,#0FEH        ; left first digit
        SETB BIT_LE
        CLR BIT_LE
        LCALL DELAY

        ; close all digits
        MOV P0,#0FFH
        SETB BIT_LE
        CLR BIT_LE

        ; show one
        MOV DPTR,#TAB
        MOV A,ONE
        MOVC A,@A+DPTR
        MOV P0,A
        SETB SEG_LE
        CLR SEG_LE

        MOV P0,#0FDH        ; left second digit
        SETB BIT_LE
        CLR BIT_LE
        LCALL DELAY

        SJMP MAIN

;====================================================================
; Timer0 interrupt: 50 ms once, read ADC every 1 s
;====================================================================

T0_INT:
        PUSH ACC
        PUSH B
        PUSH PSW

        MOV TH0,#3CH
        MOV TL0,#0B0H

        DJNZ CNT,T0_EXIT
        MOV CNT,#20

        ; start ADC0808
        MOV P1,#0FFH
        CLR ADC_OE

        SETB ADC_ST
        NOP
        NOP
        CLR ADC_ST

WAIT0:
        JB ADC_EOC,WAIT0

WAIT1:
        JNB ADC_EOC,WAIT1

        SETB ADC_OE
        NOP
        MOV A,P1
        CLR ADC_OE

        ; A = ADC value
        ; if ADC < 85, temperature is higher than 25
        CJNE A,#85,CHK_ADC
        SJMP COLD

CHK_ADC:
        JC HOT

COLD:
        ; temp = (160 - ADC) / 3
        MOV B,A
        MOV A,#160
        CLR C
        SUBB A,B
        JNC COLD_OK
        MOV A,#0
        SJMP SPLIT

COLD_OK:
        MOV B,#3
        DIV AB
        SJMP SPLIT

HOT:
        ; temp = 25 + (85 - ADC) * 2 / 3
        MOV B,A
        MOV A,#85
        CLR C
        SUBB A,B
        MOV B,#2
        MUL AB
        MOV B,#3
        DIV AB
        ADD A,#25

SPLIT:
        ; split temperature to ten and one
        MOV B,#10
        DIV AB
        MOV TEN,A
        MOV ONE,B

T0_EXIT:
        POP PSW
        POP B
        POP ACC
        RETI

;====================================================================

DELAY:
        MOV R6,#2
D1:
        MOV R7,#250
D2:
        DJNZ R7,D2
        DJNZ R6,D1
        RET

TAB:
        DB 3FH,06H,5BH,4FH,66H
        DB 6DH,7DH,07H,7FH,6FH

        END