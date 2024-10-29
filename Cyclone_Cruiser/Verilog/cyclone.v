module cyclone(
	 input clk,
	 input echo,
	 input sel_mux,
	 input ligar,
	 output trigger,
    output saida_serial
	 output fim_posicao,
	 output pwm,
    output [6:0] hex1_out,
	 output [6:0] hex0_out,
	 output [6:0] hex2_out,
	 output [6:0] hex3_out,
	 output [6:0] hex4_out,
	 output [6:0] hex5_out,
	 output db_echo,
	 output alerta_proximidade,
	 output [3:0]motores
	
);

motor_ctr mtr(
.clk(clk),
.reset(reset),
.frente(frent_w),
.tras(tras_w),
.direita(direita_w), 
.esquerda(esquerda_w), 
.motores(motores)

);

sonar son(
.clock(clk),
.reset(reset),
.parar(),//
.ligar(ligar),
.echo(echo),
.detecta(),// 
.silencio(), //
.sel_mux(sel_mux),
.trigger(trigger),
.saida_serial(saida_serial),
.fim_posicao(fim_posicao),
.pwm(pwm),
.db_timeout(),//
.db_mensurar(),//
.db_saida_serial(),//
.db_trigger(),//
.db_pwm(),//
.hex1_out(hex1_out),
.hex0_out(hex0_out),
.hex2_out(hex2_out),
.hex3_out(hex3_out),
.hex4_out(hex4_out),
.hex5_out(hex5_out),
.db_echo(),//
.alerta_proximidade(alerta_proximidade)
)