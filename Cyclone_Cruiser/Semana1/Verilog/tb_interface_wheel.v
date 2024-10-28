`timescale 1ns / 1ps

module tb_interface_wheel;

    // Declaração das entradas e saídas do DUT (Design Under Test)
    reg clk;
    reg reset;
    reg A;
    reg B;
    wire [3:0] count;
    wire CW;
    wire CWW;

    // Instancia o módulo top-level como DUT
    interface_wheel DUT (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .count(count),
        .CW(CW),
        .CWW(CWW)
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
        #200 reset = 0;  // Desativa o reset após 20ns

        // Simulação do comportamento do encoder (sentido horário - CW)
        #20 A = 1; B = 0;  // Canal A sobe, Canal B está em 0 (movimento CW)
        #20 A = 1; B = 1;
		  #20 A = 0; B = 1;
		  #20 A = 0; B = 0;
		

        #20 A = 1; B = 0;  // Novamente Canal A sobe (CW continua)
        #20 A = 1; B = 1;  
		  #20 A = 0; B = 1;
		  #20 A = 0; B = 0;

        // Simulação de rotação anti-horária (CCW)
        #20 A = 0; B = 1;  // Canal A sobe, Canal B está em 1 (movimento CCW)
        #20 A = 1; B = 1;  
		  #20 A = 1; B = 0;
		  #20 A = 0; B = 0;

        #20 A = 0; B = 1;  // Canal A sobe, Canal B está em 1 (movimento CCW)
        #20 A = 1; B = 1;  
		  #20 A = 1; B = 0;
		  #20 A = 0; B = 0;

        // Simulação de um reset para reiniciar a contagem
        #200 reset = 1;
        #20 reset = 0;

        // Simulação contínua de rotação alternada entre CW e CCW


        // Termina a simulação após 400ns
        #400 $finish;
    end

    // Monitorar os sinais durante a simulação
    initial begin
        $monitor("Tempo = %0dns, A = %b, B = %b, Reset = %b, Count = %d, CW = %b, CWW = %b", 
                  $time, A, B, reset, count, CW, CWW);
    end

endmodule
