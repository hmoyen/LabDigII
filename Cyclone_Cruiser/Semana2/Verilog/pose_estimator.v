module position_estimator (
    input wire clk,                     // Clock do sistema
    input wire reset,                   // Sinal de reset
    input wire signed [63:0] delta_theta, // Delta theta em microrradianos
    input wire signed [31:0] average_distance, // Distância média em micrômetros
    input wire signed [31:0] cos_theta, // Coseno calculado de (last_theta + delta_theta / 2)
    input wire signed [31:0] sin_theta, // Seno calculado de (last_theta + delta_theta / 2)
    output reg signed [63:0] theta,     // Ângulo theta acumulado em microrradianos
    output reg signed [31:0] x,         // Coordenada x em micrômetros
    output reg signed [31:0] y          // Coordenada y em micrômetros
);

    // Registradores internos para os valores anteriores de x, y, theta e average_distance
    reg signed [63:0] last_theta;
    reg signed [31:0] last_x;
    reg signed [31:0] last_y;
    reg signed [31:0] last_average_distance;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Resetando valores para a posição inicial
            last_theta <= 0;
            last_x <= 0;
            last_y <= 0;
            theta <= 0;
            x <= 0;
            y <= 0;
            last_average_distance <= 0;
        end else if (average_distance != last_average_distance && average_distance != 0) begin
            // Atualiza theta, x e y quando average_distance muda e é diferente de zero
            theta <= last_theta + delta_theta;
            x <= last_x + (average_distance * cos_theta) / (1 << 15); // Ajuste de precisão
            y <= last_y + (average_distance * sin_theta) / (1 << 15);

            // Atualiza valores anteriores para o próximo ciclo
            last_theta <= theta;
            last_x <= x;
            last_y <= y;
            last_average_distance <= average_distance; // Armazena o último average_distance
        end else begin
            // Apenas atualiza last_average_distance mesmo que average_distance seja zero
            last_average_distance <= average_distance;
        end
    end

endmodule
