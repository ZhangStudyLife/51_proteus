;====================================================================
; Experiment 5: Pulse Counter
; Compiler: ASEM-51 (Proteus)
;
; P0.0-P0.7 -> two 74HC573 D0-D7
; P2.6      -> segment latch LE
; P2.7      -> digit latch LE
; P3.5/T1   -> pulse input
; P3.2/INT0 -> start/stop key
; P3.3/INT1 -> clear key
;====================================================================

$NOMOD51
$INCLUDE (8051.MCU)

RUNFLAG EQU 30H
SCAN    EQU 31H

        ORG 0000H
        LJMP MAIN

        ORG 0003H
        LJMP INT0_ISR

        ORG 0013H
        LJMP INT1_ISR

        ORG 001BH
        LJMP T1_ISR

        ORG 0100H

MAIN:
        MOV SP, #5FH
        LCALL CLEAR_NUM

        CLR RUNFLAG
        CLR P2.6
        CLR P2.7

        SETB P3.2
        SETB P3.3
        SETB P3.5

        MOV TMOD, #60H
        MOV TH1, #0FFH
        MOV TL1, #0FFH

        SETB IT0
        SETB IT1
        MOV IP, #05H
        MOV IE, #8DH
        CLR TR1

DISP:
        MOV R0, #50H
        MOV SCAN, #0FEH
        MOV R5, #06H

NEXT:
        MOV P0, #0FFH
        SETB P2.7
        NOP
        CLR P2.7

        MOV DPTR, #TABLE
        MOV A, @R0
        MOVC A, @A+DPTR
        MOV P0, A
        SETB P2.6
        NOP
        CLR P2.6

        MOV A, SCAN
        MOV P0, A
        SETB P2.7
        NOP
        CLR P2.7

        MOV R6, #02H
DLY1:   MOV R7, #00H
DLY2:   DJNZ R7, DLY2
        DJNZ R6, DLY1

        INC R0
        MOV A, SCAN
        RL A
        MOV SCAN, A
        DJNZ R5, NEXT

        MOV P0, #0FFH
        SETB P2.7
        NOP
        CLR P2.7

        MOV P0, #00H
        SETB P2.6
        NOP
        CLR P2.6

        LJMP DISP

INT0_ISR:
        PUSH ACC
        PUSH PSW

        MOV A, RUNFLAG
        JZ START_COUNT

STOP_COUNT:
        CLR TR1
        CLR RUNFLAG
        SJMP INT0_EXIT

START_COUNT:
        SETB TR1
        MOV RUNFLAG, #01H

INT0_EXIT:
        POP PSW
        POP ACC
        RETI

INT1_ISR:
        PUSH ACC
        PUSH PSW
        PUSH 00H

        CLR TR1
        CLR RUNFLAG
        LCALL CLEAR_NUM
        MOV TH1, #0FFH
        MOV TL1, #0FFH

        POP 00H
        POP PSW
        POP ACC
        RETI

T1_ISR:
        PUSH ACC
        PUSH PSW
        PUSH 00H

        MOV TL1, #0FFH
        LCALL INC_NUM

        POP 00H
        POP PSW
        POP ACC
        RETI

CLEAR_NUM:
        MOV R0, #50H
        MOV R7, #06H
CLR_LOOP:
        MOV @R0, #00H
        INC R0
        DJNZ R7, CLR_LOOP
        RET

INC_NUM:
        MOV R0, #55H

ADD_ONE:
        INC @R0
        MOV A, @R0
        CJNE A, #10, ADD_DONE

        MOV @R0, #00H
        CJNE R0, #50H, CARRY_NEXT
        RET

CARRY_NEXT:
        DEC R0
        SJMP ADD_ONE

ADD_DONE:
        RET

TABLE:
        DB 3FH, 06H, 5BH, 4FH, 66H
        DB 6DH, 7DH, 07H, 7FH, 6FH

        END
