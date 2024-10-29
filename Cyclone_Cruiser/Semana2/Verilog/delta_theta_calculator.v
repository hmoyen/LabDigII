module delta_theta_calculator #(
    parameter integer DIST_BETWEEN_WHEELS = 200000 // Distância entre as rodas em micro
)(
    input wire signed [31:0] distance_right, // Distância da roda direita
    input wire signed [31:0] distance_left,  // Distância da roda esquerda
    output reg signed [63:0] delta_theta      // Saída: delta theta em milirradianos
);
    always @(*) begin
        // Cálculo de delta theta em milirradianos
        delta_theta = ((distance_right - distance_left)) *1000000 / DIST_BETWEEN_WHEELS; // Entrada em micro, saída em microrradianos
    end
endmodule
