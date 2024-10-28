module distance_calculator #(
    parameter integer DIST_PER_PULSE = 628 // 2 * 3.141592 * 0.1 * 1000, em milímetros
) (
    input wire clk,
    input wire reset,
    input wire incrementa_cw,
    input wire incrementa_ccw,
    output reg signed [31:0] distance // Saída como um número inteiro em mm
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            distance <= 0;
        end else if (incrementa_cw) begin
            distance <= DIST_PER_PULSE;  // Valor positivo para CW
        end else if (incrementa_ccw) begin
            distance <= -DIST_PER_PULSE; // Valor negativo para CCW
        end else begin
            distance <= 0; // Nenhum incremento
        end
    end

endmodule
