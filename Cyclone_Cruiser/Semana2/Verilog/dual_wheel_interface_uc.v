module dual_wheel_interface_uc (
    input clock,
    input reset,
    input incrementa_cw_left,   // Incremento para CW na roda esquerda
    input incrementa_cw_right,  // Incremento para CW na roda direita
    input incrementa_ccw_left,  // Incremento para CCW na roda esquerda
    input incrementa_ccw_right, // Incremento para CCW na roda direita
    output reg pulso_left_ccw,  // Pulso para a roda esquerda em CCW
    output reg pulso_right_ccw, // Pulso para a roda direita em CCW
    output reg pulso_right_cw,  // Pulso para a roda direita em CW
    output reg pulso_left_cw,   // Pulso para a roda esquerda em CW
    output reg [3:0] db_estado  // Estado de debug (4 bits)
);

    // Parâmetros para estados (4 bits)
    parameter inicial                = 4'b0000;
    parameter check_pulso_ccw_left   = 4'b0001;
    parameter check_pulso_ccw_right  = 4'b0010;
    parameter check_pulso_cw_left    = 4'b0011;
    parameter check_pulso_cw_right   = 4'b0100;
    parameter pulso_unico_left_ccw   = 4'b0101;
    parameter pulso_unico_right_ccw  = 4'b0110;
    parameter pulso_unico_left_cw    = 4'b0111;
    parameter pulso_unico_right_cw   = 4'b1000;
    parameter pulso_duplo_ccw        = 4'b1001;
    parameter pulso_duplo_cw         = 4'b1010;
    parameter fim                    = 4'b1011;

    // Variáveis internas
    reg [3:0] Eatual, Eprox;    // Estado atual e próximo estado
    reg [10:0] count_10us;       // Contador para 10 microssegundos

    // Estado atual (registro)
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            Eatual <= inicial;
            count_10us <= 0;
        end else begin
            Eatual <= Eprox;
            // Incrementa contador apenas nos estados de verificação de pulso
            if (Eatual == check_pulso_ccw_left || Eatual == check_pulso_ccw_right ||
                Eatual == check_pulso_cw_left || Eatual == check_pulso_cw_right)
                count_10us <= count_10us + 1;
            else
                count_10us <= 0;
        end
    end

    // Lógica de Próximo Estado
    always @(*) begin
        case (Eatual)
            inicial: begin
                if (incrementa_cw_left && incrementa_cw_right)
                    Eprox = pulso_duplo_cw;
                else if (incrementa_ccw_right && incrementa_ccw_left)
                    Eprox = pulso_duplo_ccw;
                else if (incrementa_ccw_left)
                    Eprox = check_pulso_ccw_left;
                else if (incrementa_ccw_right)
                    Eprox = check_pulso_ccw_right;
                else if (incrementa_cw_left)
                    Eprox = check_pulso_cw_left;
                else if (incrementa_cw_right)
                    Eprox = check_pulso_cw_right;
                else
                    Eprox = inicial;
            end

            // Estados de verificação para cada direção e roda
            check_pulso_ccw_left: begin
                if (count_10us >= 1000)
                    Eprox = pulso_unico_left_ccw;
                else if (incrementa_ccw_right)
                    Eprox = pulso_duplo_ccw;
                else
                    Eprox = check_pulso_ccw_left;
            end

            check_pulso_ccw_right: begin
                if (count_10us >= 1000)
                    Eprox = pulso_unico_right_ccw;
                else if (incrementa_ccw_left)
                    Eprox = pulso_duplo_ccw;
                else
                    Eprox = check_pulso_ccw_right;
            end

            check_pulso_cw_left: begin
                if (count_10us >= 1000)
                    Eprox = pulso_unico_left_cw;
                else if (incrementa_cw_right)
                    Eprox = pulso_duplo_cw;
                else
                    Eprox = check_pulso_cw_left;
            end

            check_pulso_cw_right: begin
                if (count_10us >= 1000)
                    Eprox = pulso_unico_right_cw;
                else if (incrementa_cw_left)
                    Eprox = pulso_duplo_cw;
                else
                    Eprox = check_pulso_cw_right;
            end

            // Estados para pulsos únicos
            pulso_unico_left_ccw:  Eprox = fim;
            pulso_unico_right_ccw: Eprox = fim;
            pulso_unico_left_cw:   Eprox = fim;
            pulso_unico_right_cw:  Eprox = fim;

            // Estados para pulsos duplos
            pulso_duplo_ccw: Eprox = fim;
            pulso_duplo_cw:  Eprox = fim;
            
            // Estado final
            fim: Eprox = inicial;

            default: Eprox = inicial;
        endcase
    end

    // Lógica de saída
    always @(*) begin
        // Sinalizações padrão
        pulso_left_cw = 1'b0;
        pulso_right_cw = 1'b0;
        pulso_left_ccw = 1'b0;
        pulso_right_ccw = 1'b0;

        case (Eatual)
            inicial: db_estado = 4'b0000;

            // Estados de verificação para debug
            check_pulso_ccw_left:   db_estado = 4'b0001;
            check_pulso_ccw_right:  db_estado = 4'b0010;
            check_pulso_cw_left:    db_estado = 4'b0011;
            check_pulso_cw_right:   db_estado = 4'b0100;

            // Estados de pulso único
            pulso_unico_left_ccw: begin
                db_estado = 4'b0101;
                pulso_left_ccw = 1'b1;
            end

            pulso_unico_right_ccw: begin
                db_estado = 4'b0110;
                pulso_right_ccw = 1'b1;
            end

            pulso_unico_left_cw: begin
                db_estado = 4'b0111;
                pulso_left_cw = 1'b1;
            end

            pulso_unico_right_cw: begin
                db_estado = 4'b1000;
                pulso_right_cw = 1'b1;
            end

            // Estado de pulso duplo para ambas as rodas
            pulso_duplo_ccw: begin
                db_estado = 4'b1001;
                pulso_left_ccw = 1'b1;
                pulso_right_ccw = 1'b1;
            end

            pulso_duplo_cw: begin
                db_estado = 4'b1010;
                pulso_left_cw = 1'b1;
                pulso_right_cw = 1'b1;
            end

            fim: begin 
                db_estado = 4'b1011;
                pulso_left_cw = 1'b0;
                pulso_right_cw = 1'b0;
                pulso_right_ccw = 1'b0;
                pulso_left_ccw = 1'b0;
            end

            default: db_estado = 4'b1111; // Estado de erro
        endcase
    end

endmodule
