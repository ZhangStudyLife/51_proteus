;====================================================================
; Experiment 4: LED数码管显示 (74HC573动态扫描)
; Compiler: ASEM-51 (Proteus)
;
; P0.0-P0.7 -> 两片74HC573的D0-D7
; P2.6      -> 段码锁存器 LE
; P2.7      -> 位选锁存器 LE
;====================================================================

$NOMOD51
$INCLUDE (8051.MCU)

        ORG 0000H
        LJMP MAIN

        ORG 0100H
MAIN:
        MOV SP, #5FH

        ; 显示缓冲区：H E L L O - 8 8
        MOV 50H, #11H      ; H
        MOV 51H, #0EH      ; E
        MOV 52H, #12H      ; L
        MOV 53H, #12H      ; L
        MOV 54H, #00H      ; O，用数字0近似
        MOV 55H, #13H      ; -
        MOV 56H, #08H      ; 8
        MOV 57H, #08H      ; 8

        CLR P2.6
        CLR P2.7

DISP:
        MOV R0, #50H
        MOV 30H, #0FEH

NEXT:
        ; 先关闭所有位，防止重影
        MOV P0, #0FFH
        SETB P2.7
        NOP
        CLR P2.7

        ; 查段码并锁存
        MOV DPTR, #TABLE
        MOV A, @R0
        MOVC A, @A+DPTR
        MOV P0, A
        SETB P2.6
        NOP
        CLR P2.6

        ; 送位码并锁存
        MOV A, 30H
        MOV P0, A
        SETB P2.7
        NOP
        CLR P2.7

        ; 延时
        MOV R6, #02H
DLY1:   MOV R7, #00H
DLY2:   DJNZ R7, DLY2
        DJNZ R6, DLY1

        ; 下一位
        INC R0
        MOV A, 30H
        JNB ACC.7, DONE
        RL A
        MOV 30H, A
        AJMP NEXT

DONE:
        ; 先关闭位选，再清段码
        MOV P0, #0FFH
        SETB P2.7
        NOP
        CLR P2.7

        MOV P0, #00H
        SETB P2.6
        NOP
        CLR P2.6

        LJMP DISP

TABLE:
        ; 0 1 2 3 4
        DB 3FH, 06H, 5BH, 4FH, 66H
        ; 5 6 7 8 9
        DB 6DH, 7DH, 07H, 7FH, 6FH
        ; A b C d E
        DB 77H, 7CH, 39H, 5EH, 79H
        ; F blank H L -
        DB 71H, 00H, 76H, 38H, 40H

        END