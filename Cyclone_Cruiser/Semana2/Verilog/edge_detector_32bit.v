module edge_detector_32bit (
    input  clock,
    input  reset,
    input  [31:0] new_average_distance, // Sinal de entrada de 32 bits
    output reg pulso                     // Pulso de saída
);

    reg prev_state; // Estado anterior

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            prev_state <= 1'b0;
            pulso <= 1'b0;  // Reseta o pulso na inicialização
        end else begin
            // Atualiza o estado anterior
            prev_state <= (new_average_distance != 32'b0);
            // Gera pulso na borda de subida
            if (prev_state == 1'b0 && new_average_distance != 32'b0) begin
                pulso <= 1'b1; // Gera pulso de saída
            end else begin
                pulso <= 1'b0; // Reseta o pulso para 0
            end
        end
    end

endmodule
