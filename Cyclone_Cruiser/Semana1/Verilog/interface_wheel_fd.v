module interface_wheel_fd (
    input wire clk,          // Clock do sistema
    input wire reset,      // Sinal de reset
    input wire registra,  // Estado da unidade de controle
	 input wire conta_CW,      
    input wire conta_CWW,
    output [3:0] count   // Saída do contador
);

wire [3:0] s_count_cw;
wire [3:0] s_count_cww;
wire [3:0] s_cw, s_cww;
wire [3:0] s_count;
wire [1:0] s_cw_menor;
wire cw_menor;

   
registrador_n #(
        .N(8)
    ) regs1 (
        .clock  (clk    ),
        .clear  (reset     ),
        .enable (registra ),
        .D      (s_count ),
        .Q      (count)
    );
	
	
contador_m # (
        .M(8),
        .N(4)
    ) CONT_CW (
        .clock(clk),
        .zera_as(1'b0),
        .zera_s(reset),
        .conta(conta_CW),
        .Q(s_cw),
        .fim(),
        .meio()
    );
	
contador_m # (
        .M(8),
        .N(4)
    ) CONT_CWW (
        .clock(clk),
        .zera_as(1'b0),
        .zera_s(reset),
        .conta(conta_CWW),
        .Q(s_cww),
        .fim(),
        .meio()
    );	
	
	

mux_4x1_n # (
		.BITS(4)
	)	mux_sentido (
		.D3(),
		.D2(),
		.D0(s_count_cw),
		.D1(s_count_cww),
		.SEL(s_cw_menor),
		.MUX_OUT(count)
);

comparador_4bit comp(
		.A(s_cw),
		.B(s_cww),
		.menor(cw_menor)
	 );
	 
assign s_count_cw = s_cw - s_cww;
assign s_cw_menor = {1'b0,cw_menor};
assign s_count_cww = s_cww - s_cw;

endmodule
