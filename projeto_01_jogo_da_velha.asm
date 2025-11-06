TITLE Projeto_01_Jogo_da_velha
.MODEL SMALL
.STACK 100h
PULALINHA MACRO
    MOV AH,02
    MOV DL,10
    INT 21h
    MOV DL,13
    INT 21h
ENDM

.DATA
    MENU DB "BEM VINDO AO JOGO DA VELHA EM ASSEMBLY",10,13,'---<MENU>---',10,13,'1 - JvJ',10,13,'2 - JvC',10,13,'3 - SAIR','$'
    INPERR DB 'ERRO DE INPUT!',10,13,'TENTE NOVMENTE $'
.CODE
MAIN PROC
    ; Inicializa o segmento de dados
    MOV AX, @DATA
    MOV DS, AX
    MOV AH,09
    LEA DX,MENU
    INT 21h
    CALL ESCOLHAMENU
    
    ;finalização do programa
    MOV AH,4Ch
    INT 21h
MAIN ENDP
ESCOLHAMENU PROC 
    ; procedimento para o input da escolha do usuário
    ; entrada - mensagens do .DATA
    ; saida - valor da escolha em BX
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    PULALINHA
    MOV AH,01
    @LMENU:
        INT 21h
        MOV BL,AL
        CMP BL,'1'
        JB @ERROESCO
        CMP BL,'3'
        JA @ERROESCO
        JMP @FIMESC
    @ERROESCO:
    PULALINHA
    MOV AH,09
    LEA DX,INPERR
    INT 21h
    PULALINHA
    MOV AH,01
    JMP @LMENU
    @FIMESC:
    POP DI
    POP SI
    POP DX
    POP CX
    POP AX
    RET
ESCOLHAMENU ENDP
END MAIN
