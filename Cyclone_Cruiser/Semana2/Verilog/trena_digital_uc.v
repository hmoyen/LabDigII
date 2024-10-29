module trena_digital_uc(
    input clock,
    input reset,
    input mensurar,
    input ligar,
    input silencio,
    input medida_pronto,
    input envio_pronto,
    input fim_transmissao,
	 input detecta,
    output reg medir,
	 output reg timeout_conta,
    output reg transmitir,
    output reg pronto,
	 output reg alerta,
	 output reg registra_alerta,
    output reg [2:0] db_estado // Using 3 bits for the state
);

    // Tipos e sinais
    reg [2:0] Eatual, Eprox; // 3 bits are sufficient

    // Parâmetros para os estados
    parameter inicial             = 3'b000;
    parameter faz_medida          = 3'b001;
    parameter aguarda_medida      = 3'b010;
    parameter transmite_caractere = 3'b011;
    parameter espera_transmissao  = 3'b100;
    parameter fim                 = 3'b101;
	 parameter transmite_alerta    = 3'b111;

    // Estado
    always @(posedge clock or posedge reset) begin
        if (reset) 
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            inicial:              Eprox = ligar ? (mensurar ? faz_medida : inicial) : inicial;
            faz_medida:           Eprox = aguarda_medida;
            aguarda_medida:       Eprox = medida_pronto ? (detecta ? transmite_alerta : transmite_caractere) : aguarda_medida;
				transmite_alerta:		 Eprox = espera_transmissao; 
            transmite_caractere:  Eprox = espera_transmissao;
            espera_transmissao:   Eprox = fim_transmissao ? fim : (envio_pronto ? transmite_caractere : espera_transmissao);
            fim:                  Eprox = inicial;
            default:              Eprox = inicial;
        endcase
    end

    // Saídas de controle
    always @(*) begin
        medir       = (Eatual == faz_medida) ? 1'b1 : 1'b0;
        transmitir  = (Eatual == transmite_caractere || Eatual == transmite_alerta) ? 1'b1 : 1'b0;
		  registra_alerta  = (Eatual == transmite_caractere || Eatual == transmite_alerta) ? 1'b1 : 1'b0;
        pronto      = (Eatual == fim) ? 1'b1 : 1'b0;
		timeout_conta = (Eatual == aguarda_medida) ? 1'b1 : 1'b0;
		alerta        = (Eatual == transmite_alerta) ? 1'b1 : 1'b0;

        case (Eatual)
            inicial:              db_estado = 3'b000; // 0
            faz_medida:           db_estado = 3'b001; // 1
            aguarda_medida:       db_estado = 3'b010; // 2
            transmite_caractere:  db_estado = 3'b011; // 3
				transmite_alerta:     db_estado = 3'b111; // 7
            espera_transmissao:   db_estado = 3'b100; // 4
            fim:                  db_estado = 3'b101; // 5
            default:              db_estado = 3'b110; // Error state
        endcase
    end

endmodule
