;====================================================================
; AT89C51 traffic light experiment with INT0 emergency mode
; Compiler: ASEM-51 (Proteus)
;====================================================================

$NOMOD51
$INCLUDE (8051.MCU)

;====================================================================
; Interrupt vectors
;====================================================================

        ORG 0000H
        LJMP START

        ORG 0003H          ; INT0 external interrupt vector
        LJMP INT0_ISR

;====================================================================
; Main program
;====================================================================

        ORG 0100H

START:
        MOV SP,#60H

        SETB P3.2          ; keep INT0 input latch high
        SETB IT0           ; falling-edge trigger for INT0
        SETB EX0           ; enable INT0
        SETB EA            ; enable global interrupt

        ; Initial state: all red
        MOV P1,#09H        ; east-west red + north-south red
        MOV R5,#5
        ACALL DELAY

MAIN:
        ; State 1: north-south green, east-west red
        MOV P1,#11H        ; P1.4 + P1.0
        MOV R5,#15
        ACALL DELAY

        ; North-south green flashes three times
        MOV P1,#01H
        MOV R5,#2
        ACALL DELAY

        MOV P1,#11H
        MOV R5,#2
        ACALL DELAY

        MOV P1,#01H
        MOV R5,#2
        ACALL DELAY

        MOV P1,#11H
        MOV R5,#2
        ACALL DELAY

        MOV P1,#01H
        MOV R5,#2
        ACALL DELAY

        MOV P1,#11H
        MOV R5,#2
        ACALL DELAY

        ; North-south yellow, east-west red
        MOV P1,#21H        ; P1.5 + P1.0
        MOV R5,#5
        ACALL DELAY

        ; State 3: east-west green, north-south red
        MOV P1,#0AH        ; P1.1 + P1.3
        MOV R5,#15
        ACALL DELAY

        ; East-west green flashes three times
        MOV P1,#08H
        MOV R5,#2
        ACALL DELAY

        MOV P1,#0AH
        MOV R5,#2
        ACALL DELAY

        MOV P1,#08H
        MOV R5,#2
        ACALL DELAY

        MOV P1,#0AH
        MOV R5,#2
        ACALL DELAY

        MOV P1,#08H
        MOV R5,#2
        ACALL DELAY

        MOV P1,#0AH
        MOV R5,#2
        ACALL DELAY

        ; East-west yellow, north-south red
        MOV P1,#0CH        ; P1.2 + P1.3
        MOV R5,#5
        ACALL DELAY

        SJMP MAIN

;====================================================================
; INT0 emergency interrupt
; After the emergency key is pressed, all directions stay red briefly.
;====================================================================

INT0_ISR:
        PUSH ACC
        PUSH 05H
        PUSH 06H
        PUSH 07H

        MOV A,P1
        MOV 30H,A          ; save current P1 state

        MOV P1,#09H        ; emergency state: all red
        MOV R5,#10
        ACALL DELAY

        MOV A,30H
        MOV P1,A           ; restore previous traffic state

        POP 07H
        POP 06H
        POP 05H
        POP ACC
        RETI

;====================================================================
; Delay subroutine
; R5 = delay multiplier
;====================================================================

DELAY:
D1:
        MOV R6,#200
D2:
        MOV R7,#250
D3:
        DJNZ R7,D3
        DJNZ R6,D2
        DJNZ R5,D1
        RET

;====================================================================
        END
