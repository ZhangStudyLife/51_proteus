ORG 0000H
LJMP MAIN

ORG 0030H
MAIN:
    MOV A, #0FEH        ; active-low start at P1.0
LOOP:
    MOV P1, A           ; output one-hot low pattern
    ACALL DELAY
    RL A                ; circular left shift
    SJMP LOOP

DELAY:
    MOV R7, #200
D1:
    MOV R6, #250
D2:
    DJNZ R6, D2
    DJNZ R7, D1
    RET

END
