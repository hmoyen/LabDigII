module trena_digital_uc(
    input clock,
    input reset,
    input mensurar,
	 input ligar,
    input medida_pronto,
    input envio_pronto,
    output reg medir,
    output reg transmitir,
    output reg pronto,
    output reg [3:0] db_estado
);

    // Tipos e sinais
    reg [3:0] Eatual, Eprox; // 3 bits são suficientes para 7 estados

    // Parâmetros para os estados
    parameter inicial                           = 4'b0000;
    parameter faz_medida                        = 4'b0001;
    parameter aguarda_medida                    = 4'b0010;
    parameter transmite_centena                 = 4'b0011;
    parameter espera_transmissao_centena        = 4'b0100;
    parameter transmite_dezena                  = 4'b0101;
    parameter espera_transmissao_dezena         = 4'b0110;
    parameter transmite_unidade                 = 4'b0111;
    parameter espera_transmissao_unidade        = 4'b1000;
    parameter transmite_caracter_final          = 4'b1001;
    parameter espera_transmissao_caracter_final = 4'b1010;
    parameter fim                               = 4'b1111;

    // Estado
    always @(posedge clock, posedge reset) begin
        if (reset) 
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            inicial:                           Eprox = ligar? (mensurar ? faz_medida : inicial): inicial;
            faz_medida:                        Eprox = aguarda_medida;
            aguarda_medida:                    Eprox = medida_pronto ? transmite_centena : aguarda_medida;
            transmite_centena:                 Eprox = espera_transmissao_centena;
            espera_transmissao_centena:        Eprox = envio_pronto ? transmite_dezena : espera_transmissao_centena;
            transmite_dezena:                  Eprox = espera_transmissao_dezena;
            espera_transmissao_dezena:         Eprox = envio_pronto ? transmite_unidade : espera_transmissao_dezena;
            transmite_unidade:                 Eprox = espera_transmissao_unidade;
            espera_transmissao_unidade:        Eprox = envio_pronto ? transmite_caracter_final : espera_transmissao_unidade;
            transmite_caracter_final:          Eprox = espera_transmissao_caracter_final;
            espera_transmissao_caracter_final: Eprox = envio_pronto ? fim : espera_transmissao_caracter_final;
            fim:                               Eprox = inicial;
            default: 
                Eprox = inicial;
        endcase
    end

    // Saídas de controle
    always @(*) begin
          medir          = (Eatual == faz_medida)    ? 1'b1 : 1'b0;
		  transmitir     = (Eatual == transmite_centena || 
                            Eatual == transmite_dezena  ||
                            Eatual == transmite_unidade ||
                            Eatual == transmite_caracter_final) ? 1'b1 : 1'b0;
		  pronto = (Eatual == fim)  ? 1'b1 : 1'b0;

        case (Eatual)
            inicial:                           db_estado = 4'b0000;//0
            faz_medida:                        db_estado = 4'b0001;//1
            aguarda_medida:                    db_estado = 4'b0010;//2
            transmite_centena:                 db_estado = 4'b0011;//3
            espera_transmissao_centena:        db_estado = 4'b0100;//4
            transmite_dezena:                  db_estado = 4'b0101;//5
            espera_transmissao_dezena:         db_estado = 4'b0110;//6
            transmite_unidade:                 db_estado = 4'b0111;//7
            espera_transmissao_unidade:        db_estado = 4'b1000;//8
            transmite_caracter_final:          db_estado = 4'b1001;//9
            espera_transmissao_caracter_final: db_estado = 4'b1010;//A
            fim:                               db_estado = 4'b1111;//F
            default:       db_estado = 4'b1110;//E
        endcase
    end

endmodule