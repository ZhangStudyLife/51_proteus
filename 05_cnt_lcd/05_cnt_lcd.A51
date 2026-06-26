;====================================================================
; Experiment 5: Pulse Counter
; Compiler: ASEM-51 (Proteus)
;
; P0.0-P0.7 -> 两片74HC573的D0-D7
; P2.6      -> 段码锁存器 LE
; P2.7      -> 位选锁存器 LE
; P3.5/T1   -> 外部脉冲输入
; P3.2/INT0 -> 启动/停止
; P3.3/INT1 -> 清零
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

        ; 50H-55H 保存6位十进制数字
        LCALL CLEAR_NUM

        MOV RUNFLAG, #00H
        CLR P2.6
        CLR P2.7

        ; P3输入口先写1
        SETB P3.2
        SETB P3.3
        SETB P3.5

        ; Timer1方式2，计数器模式
        ; C/T1=1，M1=1，M0=0 -> 0110 0000B = 60H
        MOV TMOD, #60H

        ; TH1/TL1 = FFH，每来一个脉冲就溢出中断一次
        MOV TH1, #0FFH
        MOV TL1, #0FFH

        ; INT0、INT1下降沿触发
        SETB IT0
        SETB IT1

        ; 外部中断优先级设高
        MOV IP, #05H

        ; EA=1, ET1=1, EX1=1, EX0=1
        MOV IE, #8DH

        CLR TR1

DISP:
        MOV R0, #50H
        MOV SCAN, #0FEH
        MOV R5, #06H

NEXT:
        ; 关闭所有位，防止重影
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
        MOV A, SCAN
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
        MOV A, SCAN
        RL A
        MOV SCAN, A
        DJNZ R5, NEXT

        ; 一轮显示结束，清显示
        MOV P0, #0FFH
        SETB P2.7
        NOP
        CLR P2.7

        MOV P0, #00H
        SETB P2.6
        NOP
        CLR P2.6

        LJMP DISP

;====================================================================
; INT0：启动 / 停止
;====================================================================
INT0_ISR:
        PUSH ACC
        PUSH PSW

        MOV A, RUNFLAG
        JZ START_COUNT

STOP_COUNT:
        CLR TR1
        MOV RUNFLAG, #00H
        SJMP INT0_EXIT

START_COUNT:
        SETB TR1
        MOV RUNFLAG, #01H

INT0_EXIT:
        POP PSW
        POP ACC
        RETI

;====================================================================
; INT1：清零，并停止计数
;====================================================================
INT1_ISR:
        PUSH ACC
        PUSH PSW
        PUSH 00H

        CLR TR1
        MOV RUNFLAG, #00H
        LCALL CLEAR_NUM
        MOV TH1, #0FFH
        MOV TL1, #0FFH

        POP 00H
        POP PSW
        POP ACC
        RETI

;====================================================================
; Timer1：每来一个外部脉冲，中断一次，十进制加1
;====================================================================
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

;====================================================================
; 清零：显示 000000
;====================================================================
CLEAR_NUM:
        MOV R0, #50H
        MOV R7, #06H

CLR_LOOP:
        MOV @R0, #00H
        INC R0
        DJNZ R7, CLR_LOOP
        RET

;====================================================================
; 六位十进制加1
; 50H 51H 52H 53H 54H 55H
; 最高位                  个位
;====================================================================
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
        ; 0 1 2 3 4
        DB 3FH, 06H, 5BH, 4FH, 66H
        ; 5 6 7 8 9
        DB 6DH, 7DH, 07H, 7FH, 6FH

        END