;====================================================================
; Experiment 6: AT89C51 + DAC0832 waveform generator
; Compiler: ASEM-51 (Proteus)
;
; P0.0-P0.7 -> DAC0832 DI0-DI7
; P1.0      -> square wave select, low active
; P1.1      -> sawtooth wave select, low active
; P1.2      -> triangle wave select, low active
; P1.3      -> sine wave select, low active
; P1.4      -> square wave LED, low active
; P1.5      -> sawtooth wave LED, low active
; P1.6      -> triangle wave LED, low active
; P1.7      -> sine wave LED, low active
; P2        -> frequency input, larger value means higher frequency
;====================================================================

$NOMOD51
$INCLUDE (8051.MCU)

;====================================================================
; Reset vector
;====================================================================

        ORG 0000H
        LJMP START

;====================================================================
; Main program
;====================================================================

        ORG 0100H

START:
        MOV SP,#60H
        MOV P0,#00H
        MOV P2,#0FFH        ; release P2 input latch
        MOV P1,#0FFH        ; release P1.0-P1.3 and turn LEDs off

MAIN:
        ACALL SCAN_KEY

        CJNE A,#00H,CHK_SAW
        ACALL SQUARE_WAVE
        SJMP MAIN

CHK_SAW:
        CJNE A,#01H,CHK_TRI
        ACALL SAW_WAVE
        SJMP MAIN

CHK_TRI:
        CJNE A,#02H,CHK_SIN
        ACALL TRI_WAVE
        SJMP MAIN

CHK_SIN:
        ACALL SINE_WAVE
        SJMP MAIN

;====================================================================
; Scan waveform select key
; Return A:
;   00H square, 01H sawtooth, 02H triangle, 03H sine
; If no key is pressed, square wave is selected by default.
;====================================================================

SCAN_KEY:
        MOV A,P1
        ANL A,#0FH
        JNB ACC.0,KEY_SQUARE
        JNB ACC.1,KEY_SAW
        JNB ACC.2,KEY_TRI
        JNB ACC.3,KEY_SIN

KEY_SQUARE:
        MOV A,#00H
        RET

KEY_SAW:
        MOV A,#01H
        RET

KEY_TRI:
        MOV A,#02H
        RET

KEY_SIN:
        MOV A,#03H
        RET

;====================================================================
; Waveform output routines
; Each routine outputs one cycle, then returns to MAIN to rescan keys.
;====================================================================

SQUARE_WAVE:
        MOV P1,#0EFH        ; P1.4 LED on, P1.0-P1.3 stay high
        MOV P0,#00H
        ACALL HALF_DELAY
        MOV P0,#0FFH
        ACALL HALF_DELAY
        RET

SAW_WAVE:
        MOV P1,#0DFH        ; P1.5 LED on
        MOV A,#00H
SAW_LOOP:
        MOV P0,A
        ACALL STEP_DELAY
        INC A
        JNZ SAW_LOOP
        RET

TRI_WAVE:
        MOV P1,#0BFH        ; P1.6 LED on
        MOV A,#00H
TRI_UP:
        MOV P0,A
        ACALL STEP_DELAY
        INC A
        JNZ TRI_UP

        MOV A,#0FFH
TRI_DOWN:
        MOV P0,A
        ACALL STEP_DELAY
        DEC A
        JNZ TRI_DOWN
        MOV P0,#00H
        ACALL STEP_DELAY
        RET

SINE_WAVE:
        MOV P1,#07FH        ; P1.7 LED on

        MOV DPTR,#SINE_TAB
        MOV R0,#00H
SIN_UP:
        MOV A,R0
        MOVC A,@A+DPTR
        ADD A,#80H
        MOV P0,A
        ACALL STEP_DELAY
        INC R0
        CJNE R0,#5CH,SIN_UP ; 92 table values

SIN_BACK_MID:
        DEC R0
        MOV A,R0
        MOVC A,@A+DPTR
        ADD A,#80H
        MOV P0,A
        ACALL STEP_DELAY
        CJNE R0,#00H,SIN_BACK_MID

        MOV R0,#00H
SIN_DOWN:
        MOV A,R0
        MOVC A,@A+DPTR
        MOV B,A
        MOV A,#80H
        CLR C
        SUBB A,B
        MOV P0,A
        ACALL STEP_DELAY
        INC R0
        CJNE R0,#5CH,SIN_DOWN

SIN_BACK_ZERO:
        DEC R0
        MOV A,R0
        MOVC A,@A+DPTR
        MOV B,A
        MOV A,#80H
        CLR C
        SUBB A,B
        MOV P0,A
        ACALL STEP_DELAY
        CJNE R0,#00H,SIN_BACK_ZERO
        RET

;====================================================================
; Delay routines
; P2 = 255 gives the shortest delay, P2 = 0 gives the longest delay.
;====================================================================

STEP_DELAY:
        PUSH ACC
        MOV A,P2
        CPL A               ; A = 255 - P2
        JNZ STEP_SET
        INC A               ; minimum delay when P2 = 255
STEP_SET:
        MOV R6,A
STEP_D1:
        NOP
        DJNZ R6,STEP_D1
        POP ACC
        RET

HALF_DELAY:
        MOV R5,#80
HALF_D1:
        ACALL STEP_DELAY
        DJNZ R5,HALF_D1
        RET

;====================================================================
; 92-point quarter sine amplitude table, 0 -> 127.
; One full sine cycle is generated around code 80H.
;====================================================================

SINE_TAB:
        DB 00H,02H,04H,07H,09H,0BH,0DH,0FH
        DB 11H,14H,16H,18H,1AH,1CH,1EH,21H
        DB 23H,25H,27H,29H,2BH,2DH,2FH,31H
        DB 33H,35H,37H,39H,3BH,3DH,3FH,41H
        DB 43H,44H,46H,48H,4AH,4CH,4DH,4FH
        DB 51H,53H,54H,56H,57H,59H,5BH,5CH
        DB 5EH,5FH,61H,62H,63H,65H,66H,67H
        DB 69H,6AH,6BH,6CH,6DH,6EH,6FH,70H
        DB 71H,72H,73H,74H,75H,76H,77H,78H
        DB 78H,79H,7AH,7AH,7BH,7BH,7CH,7CH
        DB 7DH,7DH,7DH,7EH,7EH,7EH,7FH,7FH
        DB 7FH,7FH,7FH,7FH

;====================================================================
        END
