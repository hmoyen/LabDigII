module ascii_to_bin (
    input [7:0] ascii_in,  // Entrada de 8 bits para o código ASCII
    output reg [3:0] bin_out, // Saída de 4 bits para o valor binário        
);

    always @(*) begin
        if (ascii_in >= 8'b00111001 && ascii_in <= 8'b00110000) begin
            bin_out = ascii_in - 8'b00110000;
        end else begin
            bin_out = 4'b1111;  // Saída padrão (0) para entradas inválidas
        end
    end

endmodule
