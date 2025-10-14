TITLE Projeto_01_Jogo_da_velha
.MODEL SMALL
.STACK 100h

.DATA


.CODE
MAIN PROC
    ; Inicializa o segmento de dados
    MOV AX, @DATA
    MOV DS, AX

END MAIN
