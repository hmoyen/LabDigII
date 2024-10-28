module interface_wheel_fd (
    input wire clk,          // Clock do sistema
    input wire reset,      // Sinal de reset
    input wire registra,  // Estado da unidade de controle
	input wire conta_CW,      // Sinal de reset
    input wire conta_CCW,
    output [7:0] count,   // Saída do contador
	 output CW,
	 output CCW
);

wire [7:0]s_count_cw;
wire [7:0]s_count_ccw;
wire [7:0]s_cw, s_ccw;
wire [7:0]s_count;
wire s_cw_menor;

   
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
        .M(256),
        .N(8)
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
        .M(256),
        .N(8)
    ) CONT_ccw (
        .clock(clk),
        .zera_as(1'b0),
        .zera_s(reset),
        .conta(conta_CCW),
        .Q(s_ccw),
        .fim(),
        .meio()
    );	
	
	

mux_4x1_n # (
		.BITS(8)
	)	mux_sentido (
		.D3(),
		.D2(),
		.D0(s_count_cw),
		.D1(s_count_ccw),
		.SEL({1'b0,s_cw_menor}),
		.MUX_OUT(s_count)
);

comparador_8bit comp(
		.A(s_cw),
		.B(s_ccw),
		.menor(s_cw_menor)
	 );
	 
assign s_count_cw = s_cw - s_ccw;
assign s_count_ccw = s_ccw - s_cw;
assign CCW = s_cw_menor;
assign CW = ~s_cw_menor; 

endmodule
