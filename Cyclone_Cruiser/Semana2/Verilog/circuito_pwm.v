/*
 * circuito_pwm.v - descrição comportamental
 *
 * gera saída com modulacao pwm conforme parametros do modulo
 *
 * parametros: valores definidos para clock de 50MHz (periodo=20ns)
 * ------------------------------------------------------------------------
 * Revisoes  :
 *     Data        Versao  Autor             Descricao
 *     26/09/2021  1.0     Edson Midorikawa  criacao do componente VHDL
 *     17/08/2024  2.0     Edson Midorikawa  componente em Verilog
 * ------------------------------------------------------------------------
 */
 
module circuito_pwm #(    // valores default
    parameter conf_periodo = 1000000, // Período do sinal PWM [1250 => f= (25us)]
    parameter largura_000   = 35000,    // Largura do pulso p/ 00 [0 => 0]
    parameter largura_001   = 45700,   // Largura do pulso p/ 01 [50 => 1us]
    parameter largura_010   = 56450,  // Largura do pulso p/ 10 [500 => 10us]
    parameter largura_011   = 67150,  // Largura do pulso p/ 11 [1000 => 20us]
	 parameter largura_100   = 77850,  // Largura do pulso p/ 11 [1000 => 20us]
	 parameter largura_101   = 88550,  // Largura do pulso p/ 11 [1000 => 20us]
	 parameter largura_110   = 99300,  // Largura do pulso p/ 11 [1000 => 20us]
	 parameter largura_111   = 110000  // Largura do pulso p/ 11 [1000 => 20us]

) (
    input        clock,
    input        reset,
    input  [2:0] largura,
    output reg   pwm,
	 output wire db_reset,
	 output wire db_controle,
	 output wire [2:0] db_posicao
);

reg [31:0] contagem; // Contador interno (32 bits) para acomodar conf_periodo
reg [31:0] largura_pwm;

always @(posedge clock or posedge reset) begin
    if (reset) begin
        contagem <= 0;
//        pwm <= 0;
        largura_pwm <= largura_000; // Valor inicial da largura do pulso
    end else begin
        // Saída PWM
        pwm <= (contagem < largura_pwm);

        // Atualização do contador e da largura do pulso
        if (contagem == conf_periodo - 1) begin
            contagem <= 0;
            case (largura)
                3'b000: largura_pwm <= largura_000;
                3'b001: largura_pwm <= largura_001;
                3'b010: largura_pwm <= largura_010;
                3'b011: largura_pwm <= largura_011;
					 
					 3'b100: largura_pwm <= largura_100;
                3'b101: largura_pwm <= largura_101;
                3'b110: largura_pwm <= largura_110;
                3'b111: largura_pwm <= largura_111;
					 
                default: largura_pwm <= largura_000; // Valor padrão
            endcase
        end else begin
            contagem <= contagem + 1;
        end
    end
end

assign db_reset = reset;
assign db_controle = pwm;
assign db_posicao = largura;

endmodule
