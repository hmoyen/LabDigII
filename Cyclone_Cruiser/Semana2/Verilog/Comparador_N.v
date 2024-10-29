module comparador_N #(parameter N = 4) (
    output igual, 
    output maior, 
    output menor, 
    input [N-1:0] A, 
    input [N-1:0] B
);

wire [N-1:0] aux_ig, aux_ma, aux_me; // vetores auxiliares para 1 bit

// Instancia os comparadores de 1 bit para cada bit de A e B
genvar i;
generate
    for (i = 0; i < N; i = i + 1) begin : comparador_loop
        if (i == 0) begin
            comparador_1bit BL (
                .ig(aux_ig[i]), 
                .ma(aux_ma[i]), 
                .me(aux_me[i]), 
                .A(A[i]), 
                .B(B[i]), 
                .carry_in(1'b1) // Para o MSB, carry_in é sempre 1
            );
        end else begin
            comparador_1bit BL (
                .ig(aux_ig[i]), 
                .ma(aux_ma[i]), 
                .me(aux_me[i]), 
                .A(A[i]), 
                .B(B[i]), 
                .carry_in(aux_ig[i-1]) // Carry do bit anterior
            );
        end
    end
endgenerate

// Lógica para determinar maior, menor e igual
assign maior = | aux_ma; // OR de todos os bits de maior
assign menor = | aux_me; // OR de todos os bits de menor
assign igual = aux_ig[N-1]; // O último bit de igual

endmodule
