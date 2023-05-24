.386                     ; Define a arquitetura do processador como 80386 (x86)
.model flat, stdcall     ; Define o modelo de memória como "flat" e a convenção de chamada como "stdcall"
option casemap:none      ; Desativa a conversão automática de maiúsculas/minúsculas para nomes de símbolos

include \masm32\include\windows.inc      ; (essencioal) Inclui o arquivo de cabeçalho do Windows
include \masm32\include\kernel32.inc     ; Inclui o arquivo de cabeçalho do kernel32
includelib \masm32\lib\kernel32.lib      ; Importa a biblioteca kernel32.lib :D

;---------------------------------------------------------------------------------------------------------------------
.data
    ; Strings utilizadas no programa

    ; Professor, prefixo "sz" é uma convenção comum usada em muitas linguagens 
    ; de programação para indicar que uma variável é uma string de caracteres 
    ; (zero-terminated string), onde o "sz" significa "string zero-terminated
    ; strings zero-terminated também evita confusões com outros tipos de dados,
    ; como números inteiros ou variáveis de outros tipos.
    ; sz é adotado como um bom hábito de programação.
    
    szTitulo                    db 'BEM VINDO A CIFRA DE CESAR', 0Dh, 0Ah, 0            ; Título do programa exibido no console
    szOpcao1                    db '1. Criptografar', 0Dh, 0Ah, 0                       ; Opção 1: Criptografar
    szOpcao2                    db '2. Descriptografar', 0Dh, 0Ah, 0                    ; Opção 2: Descriptografar
    szOpcao3                    db '3. Sair', 0Dh, 0Ah, 0                               ; Opção 3: Sair
    szPrompt                    db 'Selecione uma opcao: ', 0Dh, 0Ah, 0                 ; Prompt para selecionar uma opção
    szDigiteNomeArquivoEntrada  db 'Digite o nome do arquivo de entrada:', 0Dh, 0Ah, 0  ; Prompt para digitar o nome do arquivo de entrada
    szDigiteNomeArquivoSaida    db 'Digite o nome do arquivo de saida:', 0Dh, 0Ah, 0    ; Prompt para digitar o nome do arquivo de saída
    szDigiteValorChave          db 'Digite o valor chave da criptografia (de 1 a 20):', 0Dh, 0Ah, 0   ; Prompt para digitar o valor da chave de criptografia
    szArquivoEncontrado         db 'Arquivo encontrado.', 0Dh, 0Ah, 0                   ; Mensagem exibida quando o arquivo é encontrado
    szArquivoNaoEncontrado      db 'Arquivo nao encontrado.', 0Dh, 0Ah, 0               ; Mensagem exibida quando o arquivo não é encontrado
    szNomeArquivoEntrada        db 512 dup(0)       ; Nome do arquivo de entrada fornecido pelo usuário
    szNomeArquivoSaida          db 512 dup(0)        ; Nome do arquivo de saída fornecido pelo usuário
    szChave                     db 4 dup(0)          ; Valor da chave de criptografia fornecido pelo usuário
    szMensagem                  db 512 dup(0)        ; Mensagem de texto exibida no console
;-------------------------------------------------------------------------------------------------------------------------

.data
hStdOut dd ?            ; Handle de saída padrão
hStdIn dd ?             ; Handle de entrada padrão
bytesRead dd ?          ; Número de bytes lidos
hArquivoEntrada dd ?    ; Handle do arquivo de entrada
hArquivoSaida dd ?      ; Handle do arquivo de saída
    ; um handle é um valor que representa um recurso do sistema operacional e é usado para realizar
    ; operações nesse recurso por meio de funções específicas fornecidas pelas bibliotecas ou APIs do sistema operacional.

;--------------------------------------------------------------------------------------------------------------------------
.code
start:
    invoke GetStdHandle, STD_OUTPUT_HANDLE       ; Obtem o identificador do console de saída padrão
    mov hStdOut, eax                             ; Armazena o handle de saída em hStdOut

    invoke GetStdHandle, STD_INPUT_HANDLE        ; Obtem o identificador do console de entrada padrão
    mov hStdIn, eax                              ; Armazena o handle de entrada em hStdIn

    ; Mostra o título e as opções do menu
    invoke WriteConsole, hStdOut, offset szTitulo, sizeof szTitulo - 1, NULL, NULL
    invoke WriteConsole, hStdOut, offset szOpcao1, sizeof szOpcao1 - 1, NULL, NULL
    invoke WriteConsole, hStdOut, offset szOpcao2, sizeof szOpcao2 - 1, NULL, NULL
    invoke WriteConsole, hStdOut, offset szOpcao3, sizeof szOpcao3 - 1, NULL, NULL

        ; O comando invoke é usado para chamar uma função definida em uma biblioteca externa
        ; A função WriteConsole é chamada para escrever um texto no console de saída padrão

        ; Parâmetros:
            ; - hStdOut: Handle do console de saída padrão
            ; - offset szTitulo: Pega o endereço da string szTitulo (ponteiro para a string)
            ; - sizeof szTitulo - 1: Tamanho da string szTitulo, descontando o caractere nulo de terminação
            ;                       sizeof retorna o tamanho em bytes e é descontado 1 para excluir o caractere nulo
            ; - NULL, NULL: Parâmetros opcionais que não estão sendo usados neste caso


;------------------------------------------------------------------------------------------------------------------------

    ; Exibe o prompt
    invoke WriteConsole, hStdOut, offset szPrompt, sizeof szPrompt - 1, NULL, NULL

    ; Lê a opção escolhida pelo amado usuario
    invoke ReadConsole, hStdIn, offset szMensagem, sizeof szMensagem - 1, offset bytesRead, NULL

    ; analisa a opção escolhida
    cmp byte ptr [szMensagem], '1'  ; Compara o valor do primeiro byte da variável szMensagem com o caractere '1'
    je Criptografar                 ; Se a comparação anterior for verdadeira (igual a '1'), pula para a etiqueta "Criptografar"
    cmp byte ptr [szMensagem], '2'  ; O prefixo "byte ptr" indica que estamos comparando apenas um byte
    je Descriptografar              ; "je" é uma instrução de salto condicional que significa "jump if equal"
    cmp byte ptr [szMensagem], '3'
    je Sair

    ; Se nenhuma opção válida for escolhida, reinicia o programa
    jmp start
;-------------------------------------------------------------------------------------------------------------------------
; A ideia e lógica de criptografar nesse trecho de código são as seguintes:
;
; 1. Limpar a mensagem: O código começa limpando a variável `szMensagem`, preenchendo-a com zeros.
; 2. Solicitar o nome do arquivo de entrada: O programa exibe uma mensagem para o usuário digitar o nome do arquivo de entrada.
; 3. Ler o nome do arquivo de entrada: O programa lê o nome do arquivo de entrada fornecido pelo usuário.
; 4. Remover caracteres de nova linha: O programa remove os caracteres de nova linha (\r\n) do final do nome do arquivo de entrada,
;    para evitar problemas de processamento posterior.
; 5. Verificar se o arquivo de entrada existe: O programa verifica se o arquivo de entrada especificado existe. Se não existir, 
;    exibe uma mensagem correspondente e reinicia o programa.
; 6. Exibir mensagem de arquivo de entrada encontrado: Se o arquivo de entrada existir, o programa exibe uma mensagem informando 
;    que o arquivo foi encontrado.
; 7. Solicitar o nome do arquivo de saída: O programa exibe uma mensagem para o usuário digitar o nome do arquivo de saída.
; 8. Ler o nome do arquivo de saída: O programa lê o nome do arquivo de saída fornecido pelo usuário.
; 9. Exibir mensagem para digitar o valor da chave: O programa exibe uma mensagem solicitando ao usuário que digite o valor da 
;    chave de criptografia.
; 10. Ler o valor da chave: O programa lê o valor da chave fornecido pelo usuário.
; 11. Converter a chave para um valor numérico: O programa converte o valor da chave, que é um caractere, para um valor numérico.
; 12. Abrir o arquivo de entrada: O programa abre o arquivo de entrada especificado para leitura.
; 13. Abrir o arquivo de saída: O programa abre o arquivo de saída especificado para escrita. Se o arquivo já existir, seu conteúdo
;     anterior será descartado.
; 14. Ler o conteúdo do arquivo de entrada: O programa lê o conteúdo do arquivo de entrada e armazena-o na variável `szMensagem`.
; 15. Criptografar a mensagem: O programa percorre cada caractere da mensagem e realiza uma operação de criptografia nele. 
;     A criptografia é realizada somando o valor do caractere com o valor da chave convertida. O resultado é armazenado de volta na mensagem.
; 16. Escrever a mensagem criptografada no arquivo de saída: O programa escreve a mensagem criptografada no arquivo de saída.
; 17. Fechar os arquivos: O programa fecha os arquivos de entrada e saída.
; 18. Reiniciar o programa: O programa retorna para o início, permitindo ao usuário escolher uma nova opção do menu.

Criptografar:
    ; Limpa a mensagem
    mov ecx, sizeof szMensagem  ; move o tamanho da variável szMensagem para o registrador ecx
    mov edi, offset szMensagem  ; move o endereço base da variável szMensagem para o registrador edi.
                                ; offset retorna o deslocamento da variável em relação ao segmento de dados.
    xor eax, eax                ; executa uma operação XOR entre o eax e ele mesmo. O efeito é de zerar o valor do registrador eax

    rep stosb                   ; repete a operação de armazenamento de um byte (stosb) várias vezes, de acordo com o valor
                                ; contido no registrador ecx. A operação stosb armazena o valor contido no registrador al
                                ; (parte inferior do registrador eax) na posição de memória apontada por edi e incrementa
                                ; o registrador edi. Portanto, nesse caso, a instrução rep stosb é usada para preencher
                                ; a região de memória referente à variável 
;...............................................................................................................................
    ; Exibe mensagem para digitar o nome do arquivo de entrada
    invoke WriteConsole, hStdOut, offset szDigiteNomeArquivoEntrada, sizeof szDigiteNomeArquivoEntrada - 1, NULL, NULL

    ; Lê o nome do arquivo de entrada
    invoke ReadConsole, hStdIn, offset szNomeArquivoEntrada, sizeof szNomeArquivoEntrada - 1, offset bytesRead, NULL
;.......................................................................................................................
    ; Remove o caractere de nova linha (\r\n) do nome do arquivo de entrada
    ; garante que o nome do arquivo de saída não contenha os caracteres de nova linha, o que poderia causar 
    ; problemas ao acessar ou manipular o arquivo posteriormente

    mov ecx, bytesRead                              ; Move o valor de bytesRead para o registrador ecx:
    sub ecx, 2                                      ; Subtrai 2 do valor em ecx para ajustar o contador e considerar apenas os bytes correspondentes ao nome do arquivo
    mov byte ptr [szNomeArquivoEntrada + ecx], 0    ; Coloca o valor zero no byte localizado no deslocamento [szNomeArquivoEntrada + ecx], substituindo o caractere de nova linha
;......................................................................................................................

    ; Verifica se o nome do arquivo de entrada existe, se eme ta na pasta onde ta o arquivo asm
    invoke CreateFile, offset szNomeArquivoEntrada, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    jne ArquivoEntradaEncontrado

    ; Se o arquivo de entrada não for encontrado, ai vai mostrar a mensagem que está em .data e reinicia o programa
    invoke WriteConsole, hStdOut, offset szArquivoNaoEncontrado, sizeof szArquivoNaoEncontrado - 1, NULL, NULL
    jmp start

ArquivoEntradaEncontrado:
    ; Exibe a mensagem de arquivo de entrada encontrado
    invoke WriteConsole, hStdOut, offset szArquivoEncontrado, sizeof szArquivoEncontrado - 1, NULL, NULL

    ; Exibe mensagem para digitar o nome do arquivo de saída
    invoke WriteConsole, hStdOut, offset szDigiteNomeArquivoSaida, sizeof szDigiteNomeArquivoSaida - 1, NULL, NULL

    ; Lê o nome do arquivo de saída
    invoke ReadConsole, hStdIn, offset szNomeArquivoSaida, sizeof szNomeArquivoSaida - 1, offset bytesRead, NULL
;.................................................................................................................
    ; Remove o caractere de nova linha (\r\n) do nome do arquivo de saída
    mov ecx, bytesRead
    sub ecx, 2
    mov byte ptr [szNomeArquivoSaida + ecx], 0
;...................................................................................................................
    ; Exibe a mensagem para digitar o valor da chave
    invoke WriteConsole, hStdOut, offset szDigiteValorChave, sizeof szDigiteValorChave - 1, NULL, NULL

    ; Lê o valor da chave
    invoke ReadConsole, hStdIn, offset szChave, sizeof szChave - 1, offset bytesRead, NULL

    ; Converte a chave para um valor numérico
    xor edx, edx
    mov dl, byte ptr [szChave]
    sub edx, '0'

    ; Abre o arquivo de entrada
    invoke CreateFile, offset szNomeArquivoEntrada, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hArquivoEntrada, eax

    ; Abre o arquivo de saída
    invoke CreateFile, offset szNomeArquivoSaida, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov hArquivoSaida, eax

    ; Lê o conteúdo do arquivo de entrada
    invoke ReadFile, hArquivoEntrada, offset szMensagem, sizeof szMensagem, offset bytesRead, NULL

    ; Criptografa a mensagem
    mov ecx, bytesRead
    mov esi, offset szMensagem
    xor eax, eax
    xor ebx, ebx
    mov bl, dl
    xor edx, edx
    @@Loop:
        mov al, [esi]
        add al, bl
        mov [esi], al
        inc esi
        inc edx
        cmp edx, ecx
        jl @@Loop

    ; Escreve a mensagem criptografada no arquivo de saída
    invoke WriteFile, hArquivoSaida, offset szMensagem, ecx, offset bytesRead, NULL

    ; Fecha os arquivos
    invoke CloseHandle, hArquivoEntrada
    invoke CloseHandle, hArquivoSaida

    ; Reinicia o programa
    jmp start

Descriptografar:
    ; Limpa a mensagem
    mov ecx, sizeof szMensagem
    mov edi, offset szMensagem
    xor eax, eax
    rep stosb

    ; Exibe mensagem para digitar o nome do arquivo de entrada
    invoke WriteConsole, hStdOut, offset szDigiteNomeArquivoEntrada, sizeof szDigiteNomeArquivoEntrada - 1, NULL, NULL

    ; Lê o nome do arquivo de entrada
    invoke ReadConsole, hStdIn, offset szNomeArquivoEntrada, sizeof szNomeArquivoEntrada - 1, offset bytesRead, NULL

    ; Remove o caractere de nova linha (\r\n) do nome do arquivo de entrada
    mov ecx, bytesRead
    sub ecx, 2
    mov byte ptr [szNomeArquivoEntrada + ecx], 0

    ; Verifica se o arquivo de entrada existe
    invoke CreateFile, offset szNomeArquivoEntrada, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    jne ArquivoEntradaEncontradoDescriptografar

    ; Se o arquivo de entrada não for encontrado, exibe a mensagem correspondente e reinicia o programa
    invoke WriteConsole, hStdOut, offset szArquivoNaoEncontrado, sizeof szArquivoNaoEncontrado - 1, NULL, NULL
    jmp start

ArquivoEntradaEncontradoDescriptografar:
    ; Exibe a mensagem de arquivo de entrada encontrado
    invoke WriteConsole, hStdOut, offset szArquivoEncontrado, sizeof szArquivoEncontrado - 1, NULL, NULL

    ; Exibe mensagem para digitar o nome do arquivo de saída
    invoke WriteConsole, hStdOut, offset szDigiteNomeArquivoSaida, sizeof szDigiteNomeArquivoSaida - 1, NULL, NULL

    ; Lê o nome do arquivo de saída
    invoke ReadConsole, hStdIn, offset szNomeArquivoSaida, sizeof szNomeArquivoSaida - 1, offset bytesRead, NULL

    ; Remove o caractere de nova linha (\r\n) do nome do arquivo de saída
    mov ecx, bytesRead
    sub ecx, 2
    mov byte ptr [szNomeArquivoSaida + ecx], 0

    ; Exibe a mensagem para digitar o valor da chave
    invoke WriteConsole, hStdOut, offset szDigiteValorChave, sizeof szDigiteValorChave - 1, NULL, NULL

    ; Lê o valor da chave
    invoke ReadConsole, hStdIn, offset szChave, sizeof szChave - 1, offset bytesRead, NULL

    ; Converte a chave para um valor numérico
    xor edx, edx
    mov dl, byte ptr [szChave]
    sub edx, '0'

    ; Abre o arquivo de entrada
    invoke CreateFile, offset szNomeArquivoEntrada, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov hArquivoEntrada, eax

    ; Abre o arquivo de saída
    invoke CreateFile, offset szNomeArquivoSaida, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    mov hArquivoSaida, eax

    ; Lê o conteúdo do arquivo de entrada
    invoke ReadFile, hArquivoEntrada, offset szMensagem, sizeof szMensagem, offset bytesRead, NULL

    ; Descriptografa a mensagem
    mov ecx, bytesRead
    mov esi, offset szMensagem
    xor eax, eax
    xor ebx, ebx
    mov bl, dl
    xor edx, edx
    @@LoopDescriptografar:
        mov al, [esi]
        sub al, bl
        mov [esi], al
        inc esi
        inc edx
        cmp edx, ecx
        jl @@LoopDescriptografar

    ; Escreve a mensagem descriptografada no arquivo de saída
    invoke WriteFile, hArquivoSaida, offset szMensagem, ecx, offset bytesRead, NULL

    ; Fecha os arquivos
    invoke CloseHandle, hArquivoEntrada
    invoke CloseHandle, hArquivoSaida

    ; Reinicia o programa
    jmp start

Sair:
    invoke ExitProcess, 0

end start
