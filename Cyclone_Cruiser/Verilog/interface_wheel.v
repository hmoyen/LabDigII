module interface_wheel (

    input wire clk,         // Clock do sistema
    input wire reset,       // Sinal de reset
    input wire A,           // Canal A do encoder
    input wire B,           // Canal B do encoder
    output wire [7:0] count, // Saída do contador
	 output CW,
	 output CWW
);

    // Fios para interconexão entre UC e FD
    reg A_prev;                    // Armazena o valor anterior de A
    wire conta_cw, conta_cww;      // Sinais de controle para rotação CW e CCW
    wire registra;                 // Sinal para armazenar o valor no registrador

    // Instancia o módulo da Unidade de Controle (UC)
    interface_wheel_uc UC (
        .clk(clk),
        .reset(reset),
        .A_prev(A_prev),
        .A(A),
        .B(B),
        .conta_cw(conta_cw),
        .conta_cww(conta_cww),
        .registra(registra)
    );

    // Instancia o módulo do Fluxo de Dados (FD)
    interface_wheel_fd FD (
        .clk(clk),
        .reset(reset),
        .registra(registra),
        .conta_CW(conta_cw),
        .conta_CWW(conta_cww),
        .count(count)
    );
	 
	 
registrador_n #(
        .N(1)
    ) regs_cw (
        .clock  (clock    ),
        .clear  (reset     ),
        .enable (registra ),
        .D      (conta_cw ),
        .Q      (CW)
    );
	 
registrador_n #(
        .N(1)
    ) regs_cww (
        .clock  (clock    ),
        .clear  (reset     ),
        .enable (registra ),
        .D      (conta_cww ),
        .Q      (CWW)
    );

    // Sempre armazena o valor anterior de A para passar para a UC
    always @(posedge clk or posedge reset) begin
        if (reset)
            A_prev <= 0;
        else
            A_prev <= A;  // Armazena o valor anterior de A
    end

endmodule


