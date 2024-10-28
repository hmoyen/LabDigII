module trena_digital_fd(
    input clock,
    input reset,
    input medir,
    input timeout,
    input transmitir,
    input echo,
	 input detecta,
	 input registra,
    input [6:0] angulo_centena,
    input [6:0] angulo_dezena,
    input [6:0] angulo_unidade,
    output medida_pronto,
    output envio_pronto,
    output trigger,
    output saida_serial,
    output [3:0] unidade,
    output [3:0] dezena,
    output [3:0] centena,
	 output fim_transmissao,
	 output alerta_proximidade
);

    wire [11:0] s_medida;
    wire s_reset_int;
    wire [3:0] s_seletor_mux;
	 wire s_fim_transmissao;
    wire s_trigger, s_medida_pronto, s_envio_pronto;
    wire [2:0] seletor_mux;
    wire [6:0] dados_ascii, s_unidade, s_dezena, s_centena;
    wire [6:0] dados_ascii_med, dados_ascii_ang;
	 wire s_alerta, s_detecta;

    // Circuito de interface com sensor
    interface_hcsr04 INT (
        .clock    (clock    ),
        .reset    (s_reset_int    ),
        .medir    (medir    ),
        .echo     (echo     ),
        .trigger  (s_trigger),
        .medida   (s_medida ),
        .pronto   (s_medida_pronto  ),
        .db_estado()
    );

    tx_serial_7O1 SER(
        .clock(clock),
        .reset(reset),
        .partida(transmitir),
        .dados_ascii(dados_ascii),
        .saida_serial(saida_serial),
        .pronto(s_envio_pronto),
        .db_clock(),
        .db_tick(),
        .db_partida(),
        .db_saida_serial(),
        .db_estado()
    );

    // MUX que seleciona o dado de saída
    mux_4x1_n SEL_CHAR1 (
        .D3(7'b0100011), // # (23 em Hexa)
        .D2(s_unidade), //3Unidade
        .D1(s_dezena), //3Dezena
        .D0(s_centena), //3Centena
        .SEL(seletor_mux[1:0]),
        .MUX_OUT(dados_ascii_med)
    );

    // MUX que seleciona o dado de saída
    mux_4x1_n SEL_CHAR2 (
        .D3(7'b0101100), // , (2C em Hexa)
        .D2(angulo_unidade), //3Unidade
        .D1(angulo_dezena), //3Dezena
        .D0(angulo_centena), //3Centena
        .SEL(seletor_mux[1:0]),
        .MUX_OUT(dados_ascii_ang)
    );

    // MUX que seleciona o dado de saída
    mux_4x1_n SEL_CHAR3 (
        .D3(dados_ascii_med), // , (2C em Hexa)
        .D2(dados_ascii_med), //3Unidade
        .D1(dados_ascii_ang), //3Dezena
        .D0(dados_ascii_ang), //3Centena
        .SEL(seletor_mux[2:1]),
        .MUX_OUT(dados_ascii)
    );
	 
	  registrador_n #(
        .N(1)
    ) U3 (
        .clock  (clock    ),
        .clear  (zera     ),
        .enable (registra),
        .D      (detecta ),
        .Q      (s_detecta)
    );
	 
	 comparador_4bit(
		.A(s_dezena),
		.B(4'b0001),
		.menor(s_alerta)
	 );


    // 000
    // 001
    // 010
    // 011

    // 100
    // 101
    // 110
    // 111
    // 1000

    contador_m # (
        .M(8),
        .N(4)
    ) CONT_CHAR (
        .clock(clock),
        .zera_as(1'b0),
        .zera_s(reset),
        .conta(s_envio_pronto),
        .Q(s_seletor_mux),
        .fim(s_fim_transmissao),
        .meio()
    );

assign seletor_mux = s_seletor_mux[2:0];
assign s_unidade = {3'b011, s_medida[3:0]}; //unidade
assign s_dezena = {3'b011, s_medida[7:4]};//dezena
assign s_centena = {3'b011, s_medida[11:8]};//centena
assign trigger = s_trigger;
assign medida_pronto = s_medida_pronto;
assign envio_pronto = s_envio_pronto;
assign s_reset_int = (timeout === 1'b1) ? 1'b1 : reset;
assign alerta_proximidade = s_alerta & detecta; 

assign unidade = s_unidade[3:0];
assign dezena = s_dezena[3:0];
assign centena = s_centena[3:0];
assign fim_transmissao = s_fim_transmissao;

endmodule
