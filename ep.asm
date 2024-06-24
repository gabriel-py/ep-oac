.globl main

main:
    # Inicializar registradores
    li $t0, 0             # $t0 é o contador do loop para as linhas
    la $t1, matriz        # $t1 é o endereço base da matriz
    lw $t2, tam_matriz    # Carregar o tamanho da matriz em $t2

    # Chamada da função para verificar se é uma matriz identidade
    jal verifica_identidade

    # O resultado da função está em $v0
    # Se $v0 == 1, é uma matriz identidade
    # Se $v0 == 0, não é uma matriz identidade

    # Se $v0 for 1, imprime "É uma matriz identidade"
    beq $v0, $zero, nao_identidade # se o resultado da função verifica_identidade, que fica armazenado em $v0, for zero, então transferimos para o bloco que trata este cenário
    la $a0, mensagem_identidade # $a0 é o primeiro parâmetro da função syscall que printa elementos na tela, por isso transferimos o conteúdo da mensagem que queremos exibir para ele
    li $v0, 4              # 4 é o código da syscall para imprimir string
    syscall
    j fim_programa

nao_identidade:
    # Se $v0 for 0, imprime "Não é uma matriz identidade"
    la $a0, mensagem_nao_identidade
    li $v0, 4              # 4 é o código da syscall para imprimir string
    syscall

fim_programa:
    # Encerrar o programa
    li $v0, 10             # 10 é o código da syscall para encerrar o programa
    syscall

verifica_identidade:
    # Empilha registradores usados
    addi $sp, $sp, -20     # Cria espaço na pilha para 5 registradores ($ra, $t0, $t3, $t4, $t5)
    sw $ra, 16($sp)        # Empilha o registrador $ra
    sw $t0, 12($sp)        # Empilha o registrador $t0
    sw $t3, 8($sp)         # Empilha o registrador $t3
    sw $t4, 4($sp)         # Empilha o registrador $t4
    sw $t5, 0($sp)         # Empilha o registrador $t5

    # Inicializar registradores
    li $t4, 1             # $t4 é o valor esperado para os elementos da diagonal principal

loop_linha:
    # Verificar se o contador do loop para as linhas atingiu o tamanho da matriz
    bge $t0, $t2, fim_verificacao

    # Inicializar contador de coluna
    li $t3, 0             # $t3 é o contador do loop para as colunas

loop_coluna:
    # Verificar se o contador do loop para as colunas atingiu o tamanho da matriz
    bge $t3, $t2, proxima_linha

    # Calcular o deslocamento para acessar o elemento atual da matriz
    mul $t5, $t0, $t2     # Calcular o deslocamento da linha
    add $t5, $t5, $t3     # Adicionar o deslocamento da coluna
    sll $t5, $t5, 2       # Multiplicar o deslocamento por 4 para obter o deslocamento em bytes
    add $t5, $t1, $t5     # Adicionar o deslocamento ao endereço base da matriz

    # Carregar o valor do elemento atual da matriz em $t6
    lw $t6, 0($t5)

    # Se o elemento está na diagonal principal (i == j), deve ser igual a 1
    # Se não, deve ser igual a 0
    beq $t0, $t3, verifica_1

    # se o elemento que não está na diagonal prinicpal da matriz for 0, ainda está dentro dos requisitos e vamos avançar para o próximo elemento;
    # caso não seja 0, podemos afirmar que não é identidade
    beq $t6, $zero, incremento_coluna
    j nao_identidade

verifica_1:
    # Se o elemento na diagonal principal não é igual a 1, não é uma matriz identidade
    bne $t6, $t4, nao_identidade

incremento_coluna:
    # Incrementar o contador do loop para as colunas
    addi $t3, $t3, 1
    j loop_coluna

proxima_linha:
    # Incrementar o contador do loop para as linhas
    addi $t0, $t0, 1
    j loop_linha

fim_verificacao:
    # Se todos os elementos estão de acordo com a definição de uma matriz identidade, retorna 1 (true)
    li $v0, 1 # move para o registrador $v0, o qual armazena o retorno da função, o valor 1

fim:
    # Desempilha registradores usados
    lw $t5, 0($sp)         # Desempilha o registrador $t5
    lw $t4, 4($sp)         # Desempilha o registrador $t4
    lw $t3, 8($sp)         # Desempilha o registrador $t3
    lw $t0, 12($sp)        # Desempilha o registrador $t0
    lw $ra, 16($sp)        # Desempilha o registrador $ra
    addi $sp, $sp, 20      # Ajusta o ponteiro da pilha

    jr $ra                 # Retorna

.data
matriz: .word 1, 0, 0, 0
        .word 0, 1, 0, 0
        .word 0, 0, 1, 0
        .word 0, 0, 0, 1
tam_matriz: .word 4  # Tamanho da matriz
mensagem_identidade: .asciiz "É uma matriz identidade\n"
mensagem_nao_identidade: .asciiz "Não é uma matriz identidade\n"
