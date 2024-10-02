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
    output reg [4:0] db_estado
);

    // Tipos e sinais
    reg [4:0] Eatual, Eprox; // 3 bits são suficientes para 7 estados

    // Parâmetros para os estados
    parameter inicial                           = 5'b00000;
    parameter faz_medida                        = 5'b00001;
    parameter aguarda_medida                    = 5'b00010;
    parameter transmite_centena                 = 5'b00011;
    parameter espera_transmissao_centena        = 5'b00100;
    parameter transmite_dezena                  = 5'b00101;
    parameter espera_transmissao_dezena         = 5'b00110;
    parameter transmite_unidade                 = 5'b00111;
    parameter espera_transmissao_unidade        = 5'b01000;
    parameter transmite_caracter_final          = 5'b01001;
    parameter espera_transmissao_caracter_final = 5'b01010;
    parameter espera_transmissao_caracter_final_ang = 5'b01011;
    parameter espera_transmissao_centena_ang = 5'b01100;
    parameter espera_transmissao_dezena_ang = 5'b01101;
    parameter espera_transmissao_unidade_ang = 5'b01110;
    parameter transmite_caracter_final_ang = 5'b10000;
    parameter transmite_centena_ang = 5'b10001;
    parameter transmite_dezena_ang = 5'b10010;
    parameter transmite_unidade_ang = 5'b10011;
    parameter fim                               = 5'b11111;

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
            transmite_centena_ang:                 Eprox = espera_transmissao_centena_ang;
            espera_transmissao_centena_ang:        Eprox = envio_pronto ? transmite_dezena_ang : espera_transmissao_centena_ang;
            transmite_dezena_ang:                  Eprox = espera_transmissao_dezena_ang;
            espera_transmissao_dezena_ang:         Eprox = envio_pronto ? transmite_unidade_ang : espera_transmissao_dezena_ang;
            transmite_unidade_ang:                 Eprox = espera_transmissao_unidade_ang;
            espera_transmissao_unidade_ang:        Eprox = envio_pronto ? transmite_caracter_final_ang : espera_transmissao_unidade_ang;
            transmite_caracter_final_ang:          Eprox = espera_transmissao_caracter_final_ang;
            espera_transmissao_caracter_final_ang: Eprox = envio_pronto ? transmite_centena : espera_transmissao_caracter_final_ang;
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
            inicial:                           db_estado = 5'b00000;//0
            faz_medida:                        db_estado = 5'b00001;//1
            aguarda_medida:                    db_estado = 5'b00010;//2
            transmite_centena:                 db_estado = 5'b00011;//3
            espera_transmissao_centena:        db_estado = 5'b00100;//4
            transmite_dezena:                  db_estado = 5'b00101;//5
            espera_transmissao_dezena:         db_estado = 5'b00110;//6
            transmite_unidade:                 db_estado = 5'b00111;//7
            espera_transmissao_unidade:        db_estado = 5'b01000;//8
            transmite_caracter_final:          db_estado = 5'b01001;//9
            espera_transmissao_caracter_final: db_estado = 5'b01010;//A
            espera_transmissao_caracter_final_ang: db_estado = 5'b01011;
            espera_transmissao_centena_ang: db_estado = 5'b01100;
            espera_transmissao_dezena_ang: db_estado = 5'b01101;
            espera_transmissao_unidade_ang: db_estado = 5'b01110;
            transmite_caracter_final_ang: db_estado = 5'b10000;
            transmite_centena_ang: db_estado = 5'b10001;
            transmite_dezena_ang: db_estado = 5'b10010;
            transmite_unidade_ang: db_estado = 5'b10011;
            fim:           db_estado = 5'b11111;
            default:       db_estado = 5'b11110;
        endcase
    end

endmodule