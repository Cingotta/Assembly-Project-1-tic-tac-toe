;colocar aqui qualuqer macro que for usar no codigo

    SCANCHAR MACRO
        MOV AH, 07h ; Usa 07h pq 01h imprime o caracter que foi mostrado, ja 07h ele não mostra
        INT 21h
    ENDM

    LIMPATELA MACRO
    ;função que inicializa a tela de video, também serve para limpara a tela
        MOV AX, 03h
        INT 10h
    ENDM

SEPHOR MACRO
    MOV DL, '-'
    MOV AH, 02h
    INT 21h
    MOV DL, '+'
    INT 21h
    MOV DL, '-'
    INT 21h
    MOV DL, '+'
    INT 21h
    MOV DL, '-'
    INT 21h
ENDM

CLEARMAT MACRO MAT
    LOCAL ZERAR_MAT
    MOV CH,3
    MOV CL,3
    XOR SI,SI;zera o ponteiro de linha
    LEA BX,MAT;atribui endereço da matriz ao ponteiro BX
    MOV DL,'1'
ZERAR_MAT:
    MOV [BX][SI],DL
    INC DL
    INC BX
    DEC CL
    CMP CL,0
    JNZ ZERAR_MAT
    SUB BX,3
    ADD SI,3
    MOV CL,3
    DEC CH
    CMP CH,0
    JNZ ZERAR_MAT
ENDM