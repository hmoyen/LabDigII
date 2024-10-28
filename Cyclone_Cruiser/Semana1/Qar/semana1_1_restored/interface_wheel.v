module interface_wheel (

    input wire clk,         // Clock do sistema
    input wire reset,       // Sinal de reset
    input wire A,           // Canal A do encoder
    input wire B,           // Canal B do encoder
    output wire [3:0] count, // Saída do contador
	 output CW_db, //sentido em que está girando no momento 
	 output CWW_db,
	 output CW, // "sinal" do count
	 output CWW,
	 output [6:0]hex0_out,
	 output [6:0]hex1_out
	 
);

    // Fios para interconexão entre UC e FD
    reg A_prev;                    // Armazena o valor anterior de A
    wire conta_cw, conta_cww;      // Sinais de controle para rotação CW e CCW
    wire registra;                 // Sinal para armazenar o valor no registrador

    // Instancia o módulo da Unidade de Controle (UC)
    interface_wheel_uc UC (
        .clk(clk),
        .reset(reset),
        // .A_prev(A_prev),
        .pin1(A),
        .pin2(B),
        .dir_cw(conta_cw),
        .dir_ccw(conta_cww),
        .registra(registra)
    );

    // Instancia o módulo do Fluxo de Dados (FD)
    interface_wheel_fd FD (
        .clk(clk),
        .reset(reset),
        .registra(registra),
        .conta_CW(conta_cw),
        .conta_CWW(conta_cww),
        .count(count),
		  .CW(CW),
		  .CWW(CWW)
		  
    );
	 
	 
registrador_n #(
        .N(1)
    ) regs_cw (
        .clock  (clk    ),
        .clear  (reset     ),
        .enable (registra ),
        .D      (conta_cw ),
        .Q      (CW_db)
    );
	 
registrador_n #(
        .N(1)
    ) regs_cww (
        .clock  (clk    ),
        .clear  (reset     ),
        .enable (registra ),
        .D      (conta_cww ),
        .Q      (CWW_db)
    );
	 
hexa7seg HEX_0 (
    .hexa(count[3:0]),
    .display(hex0_out)
);

//hexa7seg HEX_1 (
//    .hexa(count[7:4]),
//    .display(hex1_out)
//);

    // Sempre armazena o valor anterior de A para passar para a UC
    always @(posedge clk or posedge reset) begin
        if (reset)
            A_prev <= 0;
        else
            A_prev <= A;  // Armazena o valor anterior de A
    end

endmodule


