module sonar (
    input clock,
    input reset,
	 input parar,
	 input ligar,
    input echo,
	 input silencio,
	 input [1:0]sel_mux,
    output trigger,
    output saida_serial,
    //output [6:0] medida0,
    //output [6:0] medida1,
    //output [6:0] medida2,
	 //output [6:0] angulo0,
    //output [6:0] angulo1,
    //output [6:0] angulo2,
	 output fim_posicao,
	 output pwm,
	 output db_timeout,
	 output db_mensurar,
	 output db_saida_serial,
	 output db_trigger,
	 output db_pwm,
    output [6:0] hex1_out,
	 output [6:0] hex0_out,
	 output [6:0] hex2_out,
	 output [6:0] hex3_out,
	 output [6:0] hex4_out,
	 output [6:0] hex5_out,
	 output db_echo
);

wire s_medida_pronto, s_envio_pronto;
wire s_medir, s_transmitir, s_timeout_conta;
wire s_timeout, s_termina_medida;
wire [2:0] s_largura;
wire s_pronto;
wire [3:0] unidade, dezena, centena;
wire [3:0] s_db_estado;
wire s_saida_serial, s_trigger, s_mensurar;
wire [23:0] angulo;
wire s_fim_transmissao;
wire [6:0] angulo_centena, angulo_dezena, angulo_unidade;
wire [23:0] hexa7seg_db;
wire [23:0] opt_0, opt_1;
wire [7:0]db_estado_secundario;

contador_m #(.N(27), .M(100000000)) ctd (
    .clock(clock),
    .zera_as(reset),
    .zera_s(),
    .conta(ligar),
    .Q(),
    .fim(s_mensurar),
    .meio()
);

contador_m #(.N(28), .M(150000000)) ctd_timeout (
    .clock(clock),
    .zera_as(s_medida_pronto),
    .zera_s(),
    .conta(s_timeout_conta),
    .Q(),
    .fim(s_timeout),
    .meio()
);

//contador_m #(.N(3), .M(8)) ctd_largura (
//    .clock(clock),
//    .zera_as(reset),
//    .zera_s(),
//    .conta(s_pronto),
//    .Q(s_largura),
//    .fim(),
//    .meio()
//);

contadorg_updown_m #(
    .M(8),  // Modulus of the counter
    .N(3)     // Number of bits for the output
) ctd_largura (
    .clock(clock),
    .zera_as(reset),
    .zera_s(),
    .conta(s_pronto),
    .Q(s_largura),
    .inicio(),
    .fim(),
    .meio(),
    .direcao()
	 
);

circuito_pwm PWM (

	  .clock(clock),
	  .reset(reset),
	  .largura(s_largura),
	  .pwm(pwm),
	  .db_reset(),
	  .db_controle(),
	  .db_posicao()

);

rom_angulos_8x24 rom(

    .endereco(s_largura),
    .saida(angulo)

);

trena_digital_fd FD (
	 .angulo_centena(angulo_centena),
	 .angulo_dezena(angulo_dezena),
	 .angulo_unidade(angulo_unidade),
    .clock(clock),
    .reset(reset),
    .medir(s_medir),
    .transmitir(s_transmitir),
    .echo(echo),
    .medida_pronto(s_medida_pronto),
    .envio_pronto(s_envio_pronto),
    .trigger(s_trigger),
    .saida_serial(s_saida_serial),
    .unidade(unidade),
    .dezena(dezena),
    .centena(centena),
	 .fim_transmissao(s_fim_transmissao)
);

trena_digital_uc UC(
    .clock(clock),
    .reset(reset),
	 .ligar(ligar),
    .mensurar(s_mensurar),
    .medida_pronto(s_termina_medida),
    .envio_pronto(s_envio_pronto),
	 .timeout_conta(s_timeout_conta),
    .medir(s_medir),
    .transmitir(s_transmitir),
    .pronto(s_pronto),
	 .silencio(silencio),
    .db_estado(s_db_estado),
	 .fim_transmissao(s_fim_transmissao)
);

hexa7seg HEX_0 (
    .hexa(hex7seg_db[3:0]),
    .display(hex0_out)
);

hexa7seg HEX_1 (
    .hexa(hex7seg_db[7:4]),
    .display(hex1_out)
);

hexa7seg HEX_2 (
    .hexa(hex7seg_db[11:8]),
    .display(hex2_out)
);

hexa7seg HEX_3(
    .hexa(hex7seg_db[15:12]),
    .display(hex3_out)
);

hexa7seg HEX_4(
    .hexa(hex7seg_db[19:16]),
    .display(hex4_out)
);

hexa7seg HEX_5(
    .hexa(hex7seg_db[23:20]),
    .display(hex5_out)
);

mux_4x1_n # (
		.BITS(24)
	)	mux_db (
		.D3(),
		.D2(),
		.D1(opt_1),
		.D0(opt_0),
		.SEL(sel_mux),
		.MUX_OUT(hex7seg_db)
);


assign db_estado_secundário [7:5] = 3'b000;

assign opt_0 [3:0] = unidade;
assign opt_0 [3:0] = dezena;
assign opt_0 [3:0] = centena;
assign opt_0 [3:0] = db_estado_secundario[3:0];
assign opt_0 [3:0] = db_estado_secundario[7:4];
assign opt_0 [3:0] = db_estado;


assign db_mensurar = s_mensurar;

assign db_saida_serial = s_saida_serial;
assign saida_serial = s_saida_serial;

assign db_trigger = s_trigger;
assign trigger = s_trigger;
assign s_termina_medida = s_medida_pronto || s_timeout;
assign db_echo = echo;

assign fim_posicao = s_pronto;
assign db_timeout = s_timeout;
assign db_pwm = pwm;

assign angulo_unidade = angulo[6:0];
assign angulo_dezena = angulo[14:8];
assign angulo_centena = angulo[22:16];



endmodule