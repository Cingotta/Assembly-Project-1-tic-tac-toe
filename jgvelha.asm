TITLE JogoDaVelha
.MODEL SMALL
.STACK 100h

; LEMBRETES:
; colocar o arquivo macros.inc na mesma pasta desse arquivo
; use a extencao MASM/TASM do VSCode para rodar esse programa
; nas opções da extencao, ter 'Masmtasm.ASM: Mode' como 'workspace' para reconhecer o INCLUDE

INCLUDE macros.inc

.DATA
    ;variaveis durante ou antes jogo
    titulo_menu   DB '=== JOGO DA VELHA ===$'
    opcao1        DB '1. Jogar contra Amigo$'
    opcao2        DB '2. Jogar contra PC (IA)$'
    opcao3        DB '3. Sair$'
    txt_escolha   DB 'Escolha: $'
                  
    pede_jogada   DB 'Sua vez! Digite posicao (1-9): $'
    erro_msg      DB 'Jogada invalida ou ocupada. Tente denovo.$'
    
    ; msgs de quando acaba o jogo
    msg_ganhou    DB 'PARABENS! VOCE GANHOU! $'
    msg_perdeu    DB 'QUE PENA! VOCE PERDEU! $' 
    msg_velha     DB 'DEU VELHA... NINGUEM GANHOU $'
    msg_sair      DB 'Obrigado por jogar! $'
    
    ; outras msgs
    msg_vez       DB 'Vez do Jogador: $'
    msg_vit_x     DB 'VITORIA JOGADOR X!  ' 
    msg_vit_o     DB 'VITORIA JOGADOR O!  '
    msg_vit_player DB 'VITORIA DO PLAYER!  '
    msg_perdeu_ai DB 'PERDEU TENTE NOVAMENTE'
    msg_wait      DB 'Pressione qualquer tecla para voltar ao menu...$'
    
    ; a matris do jogo (3x3)
    ; 1-9 = vazio, X = player 1, O = player 2
    tabuleiro     DB 3 DUP (3 DUP (?))
    
    ; variaveis pra controlar o jogo
    modo_jogo     DB 0  ; 1 eh pvp, 2 eh contra pc
    jogador_vez   DB 'X'    ; x sempre comeca
    jogadas_count DB 0  ; conta as jogadas pra ver se deu velha
    char_temp     DB ?  ; variavel auxiliar
    
    ; linhas q ganham o jogo (trios)
    linhas_ganha  DB 0,1,2, 3,4,5, 6,7,8
                  DB 0,3,6, 1,4,7, 2,5,8
                  DB 0,4,8, 2,4,6
    
    ; cores
    cores         DB 0Ah, 0Bh, 0Ch, 0Dh, 0Eh, 0Fh, 09h
    msg_anim      DB 'VITORIA!!!' 
    tam_msg       EQU 10

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

MENU_PRINCIPAL:
    ; coloca no modo de video pra ficar colorido (não agr so quando rpecisar msm)
    MOV AX, 03h
    INT 10h

    ; mostra o titulo
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 8   ; linha
    MOV DL, 29  ; coluna  
    INT 10h
    LEA DX, titulo_menu
    MOV AH, 09h
    INT 21h

    ; mostra opcao 1
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 10
    MOV DL, 28
    INT 10h
    LEA DX, opcao1
    MOV AH, 09h
    INT 21h

    ; mostra opcao 2
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 11
    MOV DL, 28
    INT 10h
    LEA DX, opcao2
    MOV AH, 09h
    INT 21h

    ; mostra opcao 3
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 12
    MOV DL, 28
    INT 10h
    LEA DX, opcao3
    MOV AH, 09h
    INT 21h

    ; pede pra escolher
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 14
    MOV DL, 35
    INT 10h
    LEA DX, txt_escolha
    MOV AH, 09h
    INT 21h
    
LER_OPCAO_MENU:
    ; le a opcao que o usuario digitou
    SCANCHAR
    
    ; valida se eh 1 ou 2
    CMP AL, '1'
    JE OPCAO_VALIDA
    CMP AL, '2'
    JE OPCAO_VALIDA
    CMP AL, '3'
    JNE LER_OPCAO_MENU
    JMP SAIR  ; se nao for 1, 2 OU 3 le de novo


OPCAO_VALIDA:


    SUB AL, '0' ; transforma letra em numero
    MOV modo_jogo, AL
    
    ; zera o tabuleiro tudo pra 1-9 de novo
    CLEARMAT tabuleiro

    
    MOV jogadas_count, 0
    MOV jogador_vez, 'X'
    
    ; limpa a tela pra comecar
    LIMPATELA







LOOP_PRINCIPAL:   ;esse aq é o loop q tudo roda, (exeto o menu claro), ele tem o vs human o e o vs ai junto
    ; desenha a matris atualizada na tela
    CALL DESENHA_MATRIZ 
    
    ; mostra de quem e a vez  
    ;detalhe, tudo isso ainda é mostrado na ai, mas como o computador é mto rapido n da pra ver, talvez mudar isso em uma proxima versão 
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 5
    MOV DL, 30
    INT 10h
    
    LEA DX, msg_vez
    MOV AH, 09h
    INT 21h
    MOV DL, jogador_vez
    MOV AH, 02h
    INT 21h
    
    ; ve se eh vez do pc jogar
    CMP modo_jogo, 2
    JNE VEZ_HUMANO
    CMP jogador_vez, 'O'
    JE VEZ_CPU
    








VEZ_HUMANO:
    ; pede pro usuario digitar onde quer jogar
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 18
    MOV DL, 25
    INT 10h
    
    LEA DX, pede_jogada
    MOV AH, 09h
    INT 21h
    
LER_INPUT:
    ; essa função 07h é para pegar o caracter igal o 01h mas ele não da "echo", (ele n mostra o caracter na tela) ai fica mais bonito

    SCANCHAR
    

    
    ; ve se ta entre 1 e 9
    CMP AL, '1'
    JL LER_INPUT 
    CMP AL, '9'
    JG LER_INPUT 
    
    ; imprime o numero q digitou, acontece meio rapido dms, aparece so quando a jogara é invalida
    PUSH AX
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    POP AX
    





    ; transforma o numero q digitou em numero de vdd (0-8)
    SUB AL, '1'
    
    ; CONTA DA MATRIZ
    ; AL tem o indice (0-8)
    MOV AH, 0
    MOV CL, 3
    DIV CL  ; divide por 3 pra achar linha e coluna
    
    MOV DL, AH  ; guarda a coluna em DL 
    
    ; calcula linha * 3
    MOV BL, AL
    MOV AL, 3
    MUL BL      
    MOV SI, AX  ; SI eh a linha
    
    ; calcula coluna
    MOV AL, DL  ; pega a coluna de volta
    MOV AH, 0
    MOV BX, AX  ; BX eh a coluna
    
    ; ve se o lugar ta vazio ou se ja tem uma jogada feita la
    ; acessa matris[BX][SI]
    CMP tabuleiro[BX][SI], '9'
    JA TRATA_INVALIDA   ; se for maior q 9 ta ocupado, pq O e X é maisr em ascii
    
    ; salva a jogada na matris
    MOV AL, jogador_vez
    MOV tabuleiro[BX][SI], AL
    JMP FIM_JOGADA





TRATA_INVALIDA:
    JMP JOGADA_INVALIDA



VEZ_CPU:
    ; --- IA DO COMPUTADOR
    ; 1. tenta ganhar logo
    MOV AL, 'O'
    CALL TENTA_FECHAR
    CMP AH, 1
    JE CPU_JOGOU

    ; 2. tenta bloquear o jogador pra nao perder
    MOV AL, 'X'
    CALL TENTA_FECHAR
    CMP AH, 1
    JE CPU_JOGOU

    ; 3. tenta pegar o meio q eh bom
    MOV BX, 3
    MOV SI, 1
    CMP tabuleiro[BX][SI], '9'
    JBE ACHOU_VAZIO_DIRETO
    
    ; 4. se nao der nada, pega o primeiro q tiver livre
    XOR SI,SI
    
PROCURA_VAZIO_LIN:
    XOR BX,BX 
    
PROCURA_VAZIO_COL:
    CMP tabuleiro[BX][SI], '9'
    JBE ACHOU_VAZIO_DIRETO ; achou um lugar vago
    
    INC BX
    CMP BX, 3
    JL PROCURA_VAZIO_COL
    
    ADD SI, 3
    CMP SI, 9
    JL PROCURA_VAZIO_LIN
    
    JMP PULO_AJUDA

PULO_AJUDA:
    JMP FIM_VELHA
    
ACHOU_VAZIO_DIRETO:
    MOV AL, 'O'
    MOV tabuleiro[BX][SI], AL

CPU_JOGOU:
    ; da um tempo pro pc fingir q ta pensando
    MOV CX, 0FFFFh
ESPERA_PC:
    NOP 
    NOP
    NOP
    LOOP ESPERA_PC
    
FIM_JOGADA:
    INC jogadas_count ; conta mais uma jogada
    
    ; ve se alguem ganhou o jogo
    CALL VERIFICA_VITORIA
    CMP AL, 1 
    JE FIM_COM_VITORIA
    
    ; ve se deu velha (ninguem ganhou em 9 jogadas)
    CMP jogadas_count, 9
    JE FIM_VELHA
    
    ; troca a vez do jogador
    CMP jogador_vez, 'X'
    JE TROCA_PRA_O
    MOV jogador_vez, 'X' 
    JMP LOOP_PRINCIPAL
    
TROCA_PRA_O:
    MOV jogador_vez, 'O' 
    JMP LOOP_PRINCIPAL

JOGADA_INVALIDA:
    ; mostra erro e volta
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 20
    MOV DL, 20
    INT 10h
    
    LEA DX, erro_msg
    MOV AH, 09h
    INT 21h
    JMP VEZ_HUMANO

FIM_COM_VITORIA:
    CALL DESENHA_MATRIZ ; mostra como ficou no final
    
    CMP modo_jogo, 2
    JE VER_QUEM_GANHOU_IA
    
    ; se for pvp
    CMP jogador_vez, 'X'
    JE MOSTRA_X
    JMP MOSTRA_O
    
MOSTRA_X:
    LEA SI, msg_vit_x
    MOV CX, 18 
    JMP EXIBE_VITORIA
    
MOSTRA_O:
    LEA SI, msg_vit_o
    MOV CX, 18
    JMP EXIBE_VITORIA

VER_QUEM_GANHOU_IA:
    CMP jogador_vez, 'X'
    JE MOSTRA_PLAYER
    JMP MOSTRA_PERDEU
    
MOSTRA_PLAYER:
    LEA SI, msg_vit_player
    MOV CX, 18
    JMP EXIBE_VITORIA

MOSTRA_PERDEU:
    ; perdeu pro pc - vermelho
    CALL MENSAGEM_PERDEU
    JMP ESPERA_VOLTAR

EXIBE_VITORIA:
    CALL EFEITO_PISCA    ; faz a animacao
    JMP ESPERA_VOLTAR

FIM_VELHA:
    CALL DESENHA_MATRIZ
    
    ; msg de velha
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 16 
    MOV DL, 25 
    INT 10h
    
    LEA DX, msg_velha
    MOV AH, 09h
    INT 21h
    JMP ESPERA_VOLTAR

ESPERA_VOLTAR:
    ; espera apertar algo pra voltar
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 20 
    MOV DL, 15 
    INT 10h

    LEA DX, msg_wait
    MOV AH, 09h
    INT 21h
    
ESPERA_TECLA:
    SCANCHAR 
    
    CMP AL, 0   ; se for tecla especial (tipo setinha)
    JE LIMPA_BUFFER_MENU
    JMP MENU_PRINCIPAL

LIMPA_BUFFER_MENU:
    SCANCHAR ; le o segundo byte pra nao bugar o menu
    JMP MENU_PRINCIPAL

SAIR:

    ; configura video dnv que limpa a tela
    MOV AX, 3h
    INT 10h

    ; mostra a msg de sair
    MOV AH, 13h
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0Eh ; cor amarelo
    MOV CX, 19 ; tamanho da msg
    PUSH DS
    POP ES
    LEA BP, msg_sair

    MOV DH, 12
    MOV DL, 30

    INT 10h

    ; loop duplo para dar tempo o bastante de ler a mensagem
    ; tomar cuidado, qualquer alteração, emsmo pequena muda o mto o tempo de espera
    MOV CX, 06FFh
LOOP_ESPERA_SAIR:
    PUSH CX
    NOP
LOOP_ESPERA_INTERNA:
    NOP
    LOOP LOOP_ESPERA_INTERNA
    POP CX
    LOOP LOOP_ESPERA_SAIR

    LIMPATELA
    ; sai do jogo
    MOV AH, 4Ch
    INT 21h
MAIN ENDP


DESENHA_MATRIZ PROC
    ; procedimento - funcao que desenha a matriz na tela, usa loops pra percorrer a matriz 3x3
    ; entrada - os valores definidos no tabuleiro
    ; saida - a matriz desenhada na tela
    LIMPATELA
   
    XOR SI,SI   ; offset linha (0, 3, 6)
    XOR BX,BX  ; coluna (0, 1, 2)
    MOV DH, 10  ; posicao na tela
    
LOOP_LINHA:
    ; poe o cursor no comeco da linha
    MOV AH, 02h
    MOV BH, 0
    MOV DL, 37
    INT 10h
    
    XOR BX,BX   ; coluna (0, 1, 2)
    
LOOP_COLUNA:
    ; simplifica a impressao do valor, usando DL direto
    MOV DL, tabuleiro[BX][SI]
    MOV AH, 02h
    INT 21h
    
    ; desenha  |
    CMP BX, 2
    JE PULA_SEPARADOR
    MOV DL, '|'
    INT 21h
PULA_SEPARADOR:

    INC BX  ; proxima coluna
    CMP BX, 3
    JL LOOP_COLUNA
    
    ; desce uma linha na tela
    INC DH
    
    CMP SI, 6 ; se for a ultima nao desenha o traco
    JE PROXIMA_LINHA_MATRIS
    
    ; desenha o separador horizontal
    MOV AH, 02h
    MOV BH, 0
    MOV DL, 37
    INT 10h
    
    ; desenha -+-+-
    SEPHOR
    
    INC DH

PROXIMA_LINHA_MATRIS:
    ADD SI, 3  ; proxima linha
    CMP SI, 9
    JL LOOP_LINHA
    
    RET
DESENHA_MATRIZ ENDP

VERIFICA_VITORIA PROC
    ;procedimento para verificar a vitória que retorna o valor 1 se ganhou ou 0 se perdeu, 
    ;entrada - valores salvos na matriz tabuleiro
    ;saida - valor booleano salvo em AL
    PUSH BX
    PUSH SI

    ; --- Linhas ---
    MOV BX, 0   ; offset linha (0, 3, 6)

CHECK_LINHAS_LOOP:
    MOV SI, 0
    MOV AL, tabuleiro[BX][SI]
    CMP AL, '9'
    JBE PROX_LINHA
    
    MOV SI, 1
    CMP AL, tabuleiro[BX][SI]
    JNE PROX_LINHA
    
    MOV SI, 2
    CMP AL, tabuleiro[BX][SI]
    JNE PROX_LINHA
    
    JMP GANHOU

PROX_LINHA:
    ADD BX, 3
    CMP BX, 9
    JL CHECK_LINHAS_LOOP

    ; --- Colunas ---
    MOV SI, 0   ; coluna (0, 1, 2)

CHECK_COLUNAS_LOOP:
    MOV BX, 0
    MOV AL, tabuleiro[BX][SI]
    CMP AL, '9'
    JBE PROX_COLUNA
    
    MOV BX, 3
    CMP AL, tabuleiro[BX][SI]
    JNE PROX_COLUNA
    
    MOV BX, 6
    CMP AL, tabuleiro[BX][SI]
    JNE PROX_COLUNA
    
    JMP GANHOU

PROX_COLUNA:
    INC SI
    CMP SI, 3
    JL CHECK_COLUNAS_LOOP

    ; --- Diagonais ---
    ; Diagonal 1
    MOV BX, 0
    MOV SI, 0
    MOV AL, tabuleiro[BX][SI]
    CMP AL, '9'
    JBE CHECK_D2
    
    MOV BX, 3
    MOV SI, 1
    CMP AL, tabuleiro[BX][SI]
    JNE CHECK_D2
    
    MOV BX, 6
    MOV SI, 2
    CMP AL, tabuleiro[BX][SI]
    JNE CHECK_D2
    JMP GANHOU

CHECK_D2:
    ; Diagonal 2
    MOV BX, 0
    MOV SI, 2
    MOV AL, tabuleiro[BX][SI]
    CMP AL, '9'
    JBE NAO_GANHOU
    
    MOV BX, 3
    MOV SI, 1
    CMP AL, tabuleiro[BX][SI]
    JNE NAO_GANHOU
    
    MOV BX, 6
    MOV SI, 0
    CMP AL, tabuleiro[BX][SI]
    JNE NAO_GANHOU
    JMP GANHOU

NAO_GANHOU:
    POP SI
    POP BX
    MOV AL, 0
    RET
    
GANHOU:
    POP SI
    POP BX
    MOV AL, 1
    RET
VERIFICA_VITORIA ENDP


EFEITO_PISCA PROC
    ;função - procedimento responsavel por criar o efeito multicor do fim de jogo
    ;entrada - vetor mensagem de vitória no .DATA
    ;saida - impressão da animação na tela
    ;limpaa tela e reinicia a configuração de video
    LIMPATELA
    
    MOV DI, 0   ; cor atual
    MOV DX, CX  ; salva tamanho
    MOV CX, 30  ; repete 30 vezes

LOOP_CORES:
    PUSH CX       
    PUSH DX       
    
    ; poe no meio da tela
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 12 
    MOV DL, 30 
    INT 10h
    
    ; pega a cor do array
    LEA BX, cores
    MOV AX, DI    
    ADD BX, AX    
    MOV BL, [BX]  
    
    ; imprime colorido
    MOV AH, 13h
    MOV AL, 1
    MOV BH, 0
    POP CX        
    PUSH CX       
    MOV BP, SI    
    
    ; --- CORRECAO DO BUG DO SEGMENTO ---
    ; tive q fazer isso pq tava dando pau no segmento
    PUSH DS
    POP ES
    
    INT 10h
    
    ; delay pra ver a cor
    MOV CX, 0FFFFh
DELAY_COR:
    NOP
    NOP
    LOOP DELAY_COR
    
    ; proxima cor
    INC DI
    CMP DI, 7
    JB PROX_COR
    MOV DI, 0 
PROX_COR:
    POP DX        
    POP CX        
    LOOP LOOP_CORES
    
    RET
EFEITO_PISCA ENDP


MENSAGEM_PERDEU PROC
    ;procedimento - função responsavel por atribuir a cor vermelha a mensagem de derrota por IA
    ;entrada - mensagem de derrota no .DATA
    ;saida - impressão na tela da mensagem de derreota com a cor vermelha
    LIMPATELA
    
    ; poe cursor
    MOV AH, 02h
    MOV BH, 0
    MOV DH, 12
    MOV DL, 30
    INT 10h
    
    ; imprime vermelho
    MOV AH, 13h
    MOV AL, 1
    MOV BH, 0
    MOV BL, 0Ch     ; vermelho claro
    MOV CX, 22      
    LEA BP, msg_perdeu_ai
    
    PUSH DS
    POP ES
    
    INT 10h
    RET
MENSAGEM_PERDEU ENDP

TENTA_FECHAR PROC
    ; procedimento - funcao que indentifica a posição para fechar o jogo do jogador
    ;entrada - valor de al como circulo
    ;saida - jogada do computador se for fechar o caminho
    MOV char_temp, AL ; salva quem a gente ta procurando (X ou O)
    LEA SI, linhas_ganha
    MOV CX, 8

LOOP_LINHAS:
    PUSH CX
    
    MOV CH, 0       ; conta quantos tem
    MOV DX, 0FFFFh  ; guarda o vazio
    
    ; Verifica Posicao 1
    MOV BL, [SI]
    MOV BH, 0
    CALL ANALISA_LUGAR
    
    ; Verifica Posicao 2
    MOV BL, [SI+1]
    MOV BH, 0
    CALL ANALISA_LUGAR
    
    ; Verifica Posicao 3 
    MOV BL, [SI+2]
    MOV BH, 0
    CALL ANALISA_LUGAR
    
    ; Analisa se deve jogar
    CMP CH, 2   ; verifica se tem 2 iguais
    JNE PROXIMA_LINHA
    CMP DX, 0FFFFh  ; verifica tem espaco vazio
    JE PROXIMA_LINHA
    
    ; achou onde jogar

    MOV AX, DX
    MOV CL, 3
    DIV CL      ; AL = Linha, AH = Coluna
    
    ; Configura BX (Coluna)
    MOV CL, AH
    MOV CH, 0
    MOV BX, CX
    
    ; Configura BX Offset Linha = Linha * 3
    PUSH BX
    MOV BL, AL
    MOV AL, 3
    MUL BL
    MOV SI, AX
    POP BX
    
    MOV AL, 'O'
    MOV tabuleiro[BX][SI], AL
    POP CX
    MOV AH, 1
    RET

PROXIMA_LINHA:
    ADD SI, 3
    POP CX
    LOOP LOOP_LINHAS
    
    MOV AH, 0
    RET
TENTA_FECHAR ENDP


ANALISA_LUGAR PROC
    ;peocedimento - função para erificar viabilidade da posição que a IA ira jogar
    ;entrada - valor dos ponteiros das posições usadas na verificação
    ;saida - conclusão da verificação de posição
    PUSH BX 
    PUSH SI 
    PUSH AX
    
    MOV AX, BX
    MOV CL, 3
    DIV CL   ; AL = linha, AH = coluna
    
    ; Configura BX (Coluna) 
    PUSH CX
    MOV CL, AH
    MOV CH, 0
    MOV BX, CX
    POP CX
    
    ; Configura SI (Offset Linha = Linha * 3)
    PUSH BX
    MOV BL, AL
    MOV AL, 3
    MUL BL
    MOV SI, AX
    POP BX

    ; Agora compara usando a notacao de matriz [BX][SI]
    MOV AL, char_temp
    CMP tabuleiro[BX][SI], AL
    JE EH_IGUAL

    CMP tabuleiro[BX][SI], '9'
    JBE EH_LIVRE
    
    JMP SAI_DA_ANALISE

EH_IGUAL:
    INC CH
    JMP SAI_DA_ANALISE

EH_LIVRE:
    MOV DX, BX
    ADD DX, SI
    JMP SAI_DA_ANALISE

SAI_DA_ANALISE:
    POP AX
    POP SI
    POP BX
    RET
ANALISA_LUGAR ENDP

END MAIN