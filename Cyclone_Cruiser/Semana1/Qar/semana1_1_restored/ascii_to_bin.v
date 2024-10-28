module ascii_to_bin (
    input [7:0] ascii_in,  // Entrada de 8 bits para o código ASCII
    output reg [3:0] bin_out // Saída de 4 bits para o valor binário        
);

    always @(*) begin
  
            bin_out = ascii_in - 8'b00110000;
  
    end

endmodule
