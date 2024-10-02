module sonar (
    input clock,
    input reset,
	 input parar,
	 input ligar,
    input mensurar,
    input echo,
    output trigger,
    output saida_serial,
    output [6:0] medida0,
    output [6:0] medida1,
    output [6:0] medida2,
    output pronto,
	 output fim_posicao,
	 output pwm,
    output [6:0] db_estado,
	 output db_mensurar,
	 output db_saida_serial,
	 output db_trigger,
     output [6:0] angulo_unidade,
     output [6:0] angulo_dezena,
     output [6:0] angulo_centena,
	 output db_echo
);

wire s_medida_pronto, s_envio_pronto;
wire s_medir, s_transmitir;
wire [2:0] s_largura;
wire s_pronto;
wire [3:0] unidade, dezena, centena;
wire [4:0] s_db_estado;
wire s_saida_serial, s_trigger, s_mensurar;
wire [6:0] angulo_unidade, angulo_dezena, angulo_centena;

contador_m #(.N(27), .M(100000000)) ctd (
    .clock(clock),
    .zera_as(reset),
    .zera_s(),
    .conta(ligar),
    .Q(),
    .fim(s_mensurar),
    .meio()
);

contador_m #(.N(3), .M(8)) ctd_largura (
    .clock(clock),
    .zera_as(reset),
    .zera_s(),
    .conta(s_pronto),
    .Q(s_largura),
    .fim(),
    .meio()
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
    .centena(centena)
);

trena_digital_uc UC(
    .clock(clock),
    .reset(reset),
	 .ligar(ligar),
    .mensurar(s_mensurar),
    .medida_pronto(s_medida_pronto),
    .envio_pronto(s_envio_pronto),
    .medir(s_medir),
    .transmitir(s_transmitir),
    .pronto(s_pronto),
    .db_estado(s_db_estado)
);

hexa7seg HEX_UNIDADE (
    .hexa(unidade),
    .display(medida0)
);

hexa7seg HEX_DEZENA (
    .hexa(dezena),
    .display(medida1)
);

hexa7seg HEX_CENTENA (
    .hexa(centena),
    .display(medida2)
);

// hexa7seg HEX_DB_ESTADO(
//     .hexa(s_db_estado),
//     .display(db_estado)
// );

assign db_mensurar = mensurar;

assign db_saida_serial = s_saida_serial;
assign saida_serial = s_saida_serial;

assign db_trigger = s_trigger;
assign trigger = s_trigger;

assign db_echo = echo;
assign pronto = s_pronto;

assign fim_posicao = pronto;

assign angulo_unidade = angulo[0:6];
assign angulo_dezena = angulo[8:14];
assign angulo_centena = angulo[16:22];



endmodule