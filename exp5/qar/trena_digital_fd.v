module trena_digital_fd(
    input clock,
    input reset,
    input medir,
    input transmitir,
    input echo,
    output medida_pronto,
    output envio_pronto,
    output trigger,
    output saida_serial,
    output [3:0] unidade,
    output [3:0] dezena,
    output [3:0] centena
);

    wire [11:0] s_medida;
    wire s_trigger, s_medida_pronto, s_envio_pronto;
    wire [1:0] seletor_mux;
    wire [6:0] dados_ascii, s_unidade, s_dezena, s_centena;

    // Circuito de interface com sensor
    interface_hcsr04 INT (
        .clock    (clock    ),
        .reset    (reset    ),
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
    mux_4x1_n SEL_CHAR (
        .D3(7'b0100011), // # (23 em Hexa)
        .D2(s_unidade), //3Unidade
        .D1(s_dezena), //3Dezena
        .D0(s_centena), //3Centena
        .SEL(seletor_mux),
        .MUX_OUT(dados_ascii)
    );

    contador_m # (
        .M(4),
        .N(2)
    ) CONT_CHAR (
        .clock(clock),
        .zera_as(1'b0),
        .zera_s(reset),
        .conta(s_envio_pronto),
        .Q(seletor_mux),
        .fim(),
        .meio()
    );

assign s_unidade = {3'b011, s_medida[3:0]}; //unidade
assign s_dezena = {3'b011, s_medida[7:4]};//dezena
assign s_centena = {3'b011, s_medida[11:8]};//centena
assign trigger = s_trigger;
assign medida_pronto = s_medida_pronto;
assign envio_pronto = s_envio_pronto;

assign unidade = s_unidade[3:0];
assign dezena = s_dezena[3:0];
assign centena = s_centena[3:0];

endmodule
