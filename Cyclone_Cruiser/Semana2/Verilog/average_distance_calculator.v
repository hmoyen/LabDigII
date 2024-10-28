module average_distance_calculator (
    input wire signed [31:0] distance_right, // Distância da roda direita
    input wire signed [31:0] distance_left,  // Distância da roda esquerda
    output reg signed [31:0] average_distance // Saída: distância média
);
    always @(*) begin
        average_distance = (distance_right + distance_left) / 2;
    end
endmodule
