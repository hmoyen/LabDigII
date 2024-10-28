`timescale 1ns / 1ps

module wheel_distance_calculator_tb;

    // Declaração das entradas e saídas do DUT (Design Under Test)
    reg clk;
    reg reset;
    reg A;
    reg B;
    wire [31:0] total_distance;

    // Instancia o módulo top-level como DUT
    wheel_distance_calculator DUT (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .total_distance(total_distance)

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
        A = 0;
        B = 0;

        // Aplica o reset no início
        #60 reset = 0;  // Desativa o reset após 20ns

        // Simulação do comportamento do encoder sem bounce (2 voltas CW)
        repeat(2) begin
            #60 A = 1; B = 0;  // Canal A sobe, Canal B está em 0 (movimento CW)
            #60 A = 1; B = 1;
            #60 A = 0; B = 1;
            #60 A = 0; B = 0;
        end

        // Simulação do comportamento do encoder com bounce no sinal A (2 voltas CW com bounce)
        repeat(2) begin
            #60 A = 1; B = 0;  // Canal A sobe, Canal B está em 0 (movimento CW)
            #5  A = 0;  // Bounce em A
            #5  A = 1;  // Bounce resolvido
            #60 A = 1; B = 1;
            #60 A = 0; B = 1;
            #60 A = 0; B = 0;
        end

        // Simulação do comportamento do encoder sem bounce (2 voltas CCW)
        repeat(2) begin
            #60 A = 0; B = 1;  // Canal B sobe, Canal A está em 0 (movimento CCW)
            #60 A = 1; B = 1;
            #60 A = 1; B = 0;
            #60 A = 0; B = 0;
        end

        // Simulação do comportamento do encoder com bounce no sinal B (2 voltas CCW com bounce)
        repeat(6) begin
            #60 A = 0; B = 1;  // Canal B sobe, Canal A está em 0 (movimento CCW)
            #5  B = 0;  // Bounce em B
            #5  B = 1;  // Bounce resolvido
            #60 A = 0; B = 1;
            #60 A = 1; B = 1;
            #60 A = 1; B = 0;
            #60 A = 0; B = 0;
        end

        // Simulação para contar até mais de 8 voltas sem bounce (CW)
        repeat(5) begin  // 5 voltas CW sem bounce
            #60 A = 1; B = 0;
            #60 A = 1; B = 1;
            #60 A = 0; B = 1;
            #60 A = 0; B = 0;
        end

        // Simulação para contar até mais de 8 voltas com bounce (CW)
        repeat(2) begin  // 2 voltas CW com bounce
            #60 A = 1; B = 0;
            #5  A = 0;  // Bounce em A
            #5  A = 1;
            #60 A = 1; B = 1;
            #60 A = 0; B = 1;
            #60 A = 0; B = 0;
        end

        // Simulação para contar até mais de 8 voltas com bounce (CCW)
        repeat(2) begin  // 2 voltas CCW com bounce
            #60 A = 0; B = 1;
            #5  B = 0;  // Bounce em B
            #5  B = 1;
            #60 A = 0; B = 1;
            #60 A = 1; B = 1;
            #60 A = 1; B = 0;
        end

        // Termina a simulação após mais voltas
        #400 $finish;
    end

    // Monitorar os sinais durante a simulação
    initial begin
        $monitor("Tempo = %0dns, A = %b, B = %b, Reset = %b, Distancia = %d", 
                  $time, A, B, reset, total_distance);
    end

endmodule
