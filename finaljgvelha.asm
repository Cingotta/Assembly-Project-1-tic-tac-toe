TITLE JogoDaVelha
.MODEL SMALL
.STACK 100h

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
    
    ; outras msgs
    msg_vez       DB 'Vez do Jogador: $'
    msg_vit_x     DB 'VITORIA JOGADOR X!  ' 
    msg_vit_o     DB 'VITORIA JOGADOR O!  '
    msg_vit_player DB 'VITORIA DO PLAYER!  '
    msg_perdeu_ai DB 'PERDEU TENTE NOVAMENTE'
    msg_wait      DB 'Pressione qualquer tecla para voltar ao menu...$'
    
    ; a matris do jogo (3x3)
    ; 1-9 = vazio, X = player 1, O = player 2
    tabuleiro     DB '1', '2', '3'
                  DB '4', '5', '6'
                  DB '7', '8', '9'
    
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
    MOV AH, 07h ; Usa 07h pq 01h imprime o caracter que foi mostrado, ja 07h ele não mostra
    INT 21h
    
    ; valida se eh 1 ou 2
    CMP AL, '1'
    JE OPCAO_VALIDA
    CMP AL, '2'
    JE OPCAO_VALIDA
    CMP AL, '3'
    JNE LER_OPCAO_MENU
    JMP SAIR  ; se nao for 1, 2 OU 3 le de novo

RELAY_SAIR:
    ; isso é necessário pq o JE é um pulo curte e ele não consegue chegar no fim do mais
    ; antes de dar errado, então precisa de um relay para ele conseguir chegar la
    ;pq jmp tem alcance no arquivo inteiro  
    JMP SAIR
OPCAO_VALIDA:


    SUB AL, '0' ; transforma letra em numero
    MOV modo_jogo, AL
    
    ; --- RESET DO JOGO
    ; zera o tabuleiro tudo pra 1-9 de novo
    MOV CX, 9
    MOV BX, 0



ZERAR_TUDO:
    MOV AL, BL
    ADD AL, '1'
    MOV tabuleiro[BX], AL
    INC BX
    LOOP ZERAR_TUDO
    
    MOV jogadas_count, 0
    MOV jogador_vez, 'X'
    
    ; limpa a tela pra comecar
    CALL LIMPA_TELA







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

    MOV AH, 07h
    INT 21h
    

    
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
    
    ; --- CONTA DA MATRIS ---
    ; AL tem o indice (0-8)
    MOV AH, 0
    MOV CL, 3
    DIV CL  ; divide por 3 pra achar linha e coluna
    
    MOV DL, AH  ; guarda a coluna em DL 
    
    ; calcula linha * 3
    MOV BL, AL
    MOV AL, 3
    MUL BL      
    MOV BX, AX  ; BX eh a linha
    
    ; calcula coluna
    MOV AL, DL  ; pega a coluna de volta
    MOV AH, 0
    MOV SI, AX  ; SI eh a coluna
    
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
    MOV BX, 0 
    
PROCURA_VAZIO_LIN:
    MOV SI, 0 
    
PROCURA_VAZIO_COL:
    CMP tabuleiro[BX][SI], '9'
    JBE ACHOU_VAZIO_DIRETO ; achou um lugar vago
    
    INC SI
    CMP SI, 3
    JL PROCURA_VAZIO_COL
    
    ADD BX, 3
    CMP BX, 9
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
    MOV AH, 07h 
    INT 21h
    
    CMP AL, 0   ; se for tecla especial (tipo setinha)
    JE LIMPA_BUFFER_MENU
    JMP MENU_PRINCIPAL

LIMPA_BUFFER_MENU:
    MOV AH, 07h ; le o segundo byte pra nao bugar o menu
    INT 21h
    JMP MENU_PRINCIPAL

SAIR:

    CALL LIMPA_TELA

    ; sai do jogo
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; ------------------------------------------------
; funcao q desenha a matris na tela
; usa loops pra percorrer a matris 3x3
; ------------------------------------------------
DESENHA_MATRIZ PROC
    CALL LIMPA_TELA
    
    MOV BX, 0   ; linha (0, 1, 2)
    MOV DH, 10  ; posicao na tela
    
LOOP_LINHA:
    ; poe o cursor no comeco da linha
    MOV AH, 02h
    MOV BH, 0
    MOV DL, 37
    INT 10h
    
    MOV SI, 0   ; coluna (0, 1, 2)
    
LOOP_COLUNA:
    ; conta pra achar o indice: (Linha * 3) + Coluna
    PUSH DX     ; salva DX pq o MUL estraga ele
    MOV AX, BX
    MOV CX, 3
    MUL CX
    ADD AX, SI
    MOV DI, AX
    POP DX  ; volta DX
    
    ; imprime o valor da matris
    MOV DL, tabuleiro[DI]
    MOV AH, 02h
    INT 21h
    
    ; desenha  |
    CMP SI, 2
    JE PULA_SEPARADOR
    MOV DL, '|'
    INT 21h
PULA_SEPARADOR:

    INC SI  ; proxima coluna
    CMP SI, 3
    JL LOOP_COLUNA
    
    ; desce uma linha na tela
    INC DH
    
    CMP BX, 2 ; se for a ultima nao desenha o traco
    JE PROXIMA_LINHA_MATRIS
    
    ; desenha o separador horizontal
    MOV AH, 02h
    MOV BH, 0
    MOV DL, 37
    INT 10h
    
    ; desenha -+-+-
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
    
    INC DH

PROXIMA_LINHA_MATRIS:
    INC BX  ; proxima linha
    CMP BX, 3
    JL LOOP_LINHA
    
    RET
DESENHA_MATRIZ ENDP

; ------------------------------------------------
; ve se alguem ganhou
; retorna 1 se ganhou, 0 se nao
; fiz testando um por um pq eh mais facil
; ------------------------------------------------
VERIFICA_VITORIA PROC
    ; --- Linhas ---
    ; Linha 1
    MOV AL, tabuleiro[0]
    CMP AL, '9'
    JBE CHECK_L2
    CMP AL, tabuleiro[1]
    JNE CHECK_L2
    CMP AL, tabuleiro[2]
    JNE CHECK_L2
    JMP GANHOU
    
CHECK_L2:
    MOV AL, tabuleiro[3]
    CMP AL, '9'
    JBE CHECK_L3
    CMP AL, tabuleiro[4]
    JNE CHECK_L3
    CMP AL, tabuleiro[5]
    JNE CHECK_L3
    JMP GANHOU

CHECK_L3:
    MOV AL, tabuleiro[6]
    CMP AL, '9'
    JBE CHECK_C1
    CMP AL, tabuleiro[7]
    JNE CHECK_C1
    CMP AL, tabuleiro[8]
    JNE CHECK_C1
    JMP GANHOU

    ; --- Colunas 
CHECK_C1:
    MOV AL, tabuleiro[0]
    CMP AL, '9'
    JBE CHECK_C2
    CMP AL, tabuleiro[3]
    JNE CHECK_C2
    CMP AL, tabuleiro[6]
    JNE CHECK_C2
    JMP GANHOU

CHECK_C2:
    MOV AL, tabuleiro[1]
    CMP AL, '9'
    JBE CHECK_C3
    CMP AL, tabuleiro[4]
    JNE CHECK_C3
    CMP AL, tabuleiro[7]
    JNE CHECK_C3
    JMP GANHOU

CHECK_C3:
    MOV AL, tabuleiro[2]
    CMP AL, '9'
    JBE CHECK_D1
    CMP AL, tabuleiro[5]
    JNE CHECK_D1
    CMP AL, tabuleiro[8]
    JNE CHECK_D1
    JMP GANHOU

    ; --- Diagonais 
CHECK_D1:
    MOV AL, tabuleiro[0]
    CMP AL, '9'
    JBE CHECK_D2
    CMP AL, tabuleiro[4]
    JNE CHECK_D2
    CMP AL, tabuleiro[8]
    JNE CHECK_D2
    JMP GANHOU

CHECK_D2:
    MOV AL, tabuleiro[2]
    CMP AL, '9'
    JBE NAO_GANHOU
    CMP AL, tabuleiro[4]
    JNE NAO_GANHOU
    CMP AL, tabuleiro[6]
    JNE NAO_GANHOU
    JMP GANHOU

NAO_GANHOU:
    MOV AL, 0
    RET
    
GANHOU:
    MOV AL, 1
    RET
VERIFICA_VITORIA ENDP

; ------------------------------------------------
; limpa a tela toda
; ------------------------------------------------
LIMPA_TELA PROC
    MOV AX, 03h
    INT 10h
    RET
LIMPA_TELA ENDP

; ------------------------------------------------
; animação quando ganha, ele faz tudo piscar em colocrido mas como so tem na tela agora o txto de vitoria, é so ele que pisca colorido
; ------------------------------------------------
EFEITO_PISCA PROC
    ; configura video dnv
    MOV AX, 3h
    INT 10h
    
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

; ------------------------------------------------
; msg de derrota em vermelho
; ------------------------------------------------
MENSAGEM_PERDEU PROC
    MOV AX, 3h
    INT 10h
    
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

; ------------------------------------------------
; tenta fechar uma linha (ganhar ou bloquear)
; ------------------------------------------------
TENTA_FECHAR PROC
    MOV char_temp, AL ; salva quem a gente ta procurando (X ou O)
    LEA SI, linhas_ganha
    MOV CX, 8

LOOP_LINHAS:
    PUSH CX
    
    MOV CH, 0       ; conta quantos tem
    MOV DX, 0FFFFh  ; guarda o vazio
    
    ; --- Verifica Posicao 1 ---
    MOV BL, [SI]
    MOV BH, 0
    CALL ANALISA_LUGAR
    
    ; --- Verifica Posicao 2 ---
    MOV BL, [SI+1]
    MOV BH, 0
    CALL ANALISA_LUGAR
    
    ; --- Verifica Posicao 3 ---
    MOV BL, [SI+2]
    MOV BH, 0
    CALL ANALISA_LUGAR
    
    ; --- Analisa se deve jogar ---
    CMP CH, 2   ; verifica se tem 2 iguais
    JNE PROXIMA_LINHA
    CMP DX, 0FFFFh  ; verifica tem espaco vazio
    JE PROXIMA_LINHA
    
    ; achou onde jogar
    MOV SI, DX
    MOV BYTE PTR tabuleiro[SI], 'O'
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

; ------------------------------------------------
; ajuda a ver se a posicao ta boa
; ------------------------------------------------
ANALISA_LUGAR PROC
    PUSH BX 
    PUSH SI 
    PUSH AX
    
    MOV SI, BX  ; usa o indice linear direto (0-8)
    
    ; compara
    MOV AL, char_temp
    CMP tabuleiro[SI], AL
    JE EH_IGUAL
    
    CMP tabuleiro[SI], '9'
    JBE EH_LIVRE
    
    JMP SAI_DA_ANALISE

EH_IGUAL:
    INC CH
    JMP SAI_DA_ANALISE

EH_LIVRE:
    MOV DX, BX  ; achou vazio, guarda o indice em DX
    JMP SAI_DA_ANALISE

SAI_DA_ANALISE:
    POP AX
    POP SI
    POP BX
    RET
ANALISA_LUGAR ENDP

END MAIN

