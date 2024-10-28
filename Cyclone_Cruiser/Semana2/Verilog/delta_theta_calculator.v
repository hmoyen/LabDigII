module delta_theta_calculator #(
    parameter real DIST_BETWEEN_WHEELS = 0.1 // Distância entre as rodas em metros (10 cm = 0.1 m)
)(
    input wire signed [31:0] distance_right, // Distância da roda direita
    input wire signed [31:0] distance_left,  // Distância da roda esquerda
    output reg signed [31:0] delta_theta      // Saída: delta theta em milirradianos
);
    always @(*) begin
        // Cálculo de delta theta em milirradianos
        delta_theta = ((distance_right - distance_left) * 1000) / DIST_BETWEEN_WHEELS; // Multiplica por 1000 para converter para milirradianos
    end
endmodule
