`timescale 1ns/1ns

module odometry_tb;

    // Parâmetros
    parameter integer DIST_PER_PULSE = 314159; // Distância por pulso em mm

    // Declaração das entradas e saídas do DUT (Design Under Test)
    reg clk;
    reg reset;
    reg A_left;
    reg B_left;
    reg A_right;
    reg B_right;
    wire [31:0] x;
    wire [31:0] y;
    wire signed [63:0] theta; // Saída distância média

    // Instancia o módulo dual_wheel_interface como DUT
    odometry #(
        .DIST_PER_PULSE(DIST_PER_PULSE)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .A_left(A_left),
        .B_left(B_left),
        .A_right(A_right),
        .B_right(B_right),
        .x(x),
        .y(y),
        .theta(theta)
    );

    // Gera o clock (50 MHz)
    always begin
        #10 clk = ~clk;  // Clock com período de 20ns (50 MHz)
    end

    // Teste de estímulos
    initial begin
        // Inicializa os sinais
        clk = 0;
        reset = 1;
        A_left = 0;
        B_left = 0;
        A_right = 0;
        B_right = 0;

        // Aplica o reset no início
        #60 reset = 0;  // Desativa o reset após 60ns
        // 1

        // Simulação de comportamento do encoder para a roda esquerda (1 volta CW)
        repeat(1) begin
            #60 A_left = 1; B_left = 0;
            #60 A_left = 1; B_left = 1;
            #60 A_left = 0; B_left = 1;
            #60 A_left = 0; B_left = 0;
        end

        // Simulação de comportamento do encoder para a roda direita (1 volta CCW)
        repeat(1) begin
            #30000 A_right = 0; B_right = 1;
            #60 A_right = 1; B_right = 1;
            #60 A_right = 1; B_right = 0;
            #60 A_right = 0; B_right = 0;
            
        end

        // Simulação de comportamento com bounce no sinal A da roda esquerda (1 volta CW com bounce)
        repeat(1) begin
            #30000 A_left = 1; B_left = 0;
            #5  A_left = 0;  // Bounce em A_left
            #5  A_left = 1;  // Bounce resolvido
            #60 A_left = 1; B_left = 1;
            #60 A_left = 0; B_left = 1;
            #60 A_left = 0; B_left = 0;
        end

        // Simulação para comportamento com bounce no sinal B da roda direita (1 volta CCW com bounce)
        repeat(1) begin
            #30000 A_right = 0; B_right = 1;
            #5  B_right = 0;  // Bounce em B_right
            #5  B_right = 1;  // Bounce resolvido
            #60 A_right = 1; B_right = 1;
            #60 A_right = 1; B_right = 0;
            #60 A_right = 0; B_right = 0;
        end
        
        // Simulação para contar voltas adicionais (2 voltas CW na roda esquerda e 2 voltas CW na roda direita)
        repeat(2) begin
            // Movimento CW na roda esquerda
            #30000 A_left = 1; B_left = 0; A_right = 1; B_right = 0;     // Canal A da roda esquerda sobe
            #60 A_left = 1; B_left = 1; A_right = 1; B_right = 1;    // Ambos os canais da roda esquerda altos
            #60 A_left = 0; B_left = 1; A_right = 0; B_right = 1;    // Canal B da roda esquerda sobe
            #60 A_left = 0; B_left = 0; A_right = 0; B_right = 0;    // Ambos os canais da roda esquerda baixos
        end

        // Termina a simulação
        #40000 $finish;
    end

    // Monitorar os sinais durante a simulação
    initial begin
        $monitor("Tempo = %0dns | A_left = %b, B_left = %b | A_right = %b, B_right = %b | Delta Theta = %d ", 
                  $time, A_left, B_left, A_right, B_right, theta);
    end

endmodule
