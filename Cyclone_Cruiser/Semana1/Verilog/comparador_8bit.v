module comparador_8bit(igual, maior, menor, A, B);
    input [7:0] A, B; // vetor de 8 bits
    output igual, maior, menor;

    wire igual_4_1, igual_4_2;
    wire maior_4_1, maior_4_2;
    wire menor_4_1, menor_4_2;

    // Instanciando dois comparadores de 4 bits
    comparador_4bit comp1(igual_4_1, maior_4_1, menor_4_1, A[7:4], B[7:4]); // comparação dos 4 bits mais significativos
    comparador_4bit comp2(igual_4_2, maior_4_2, menor_4_2, A[3:0], B[3:0]); // comparação dos 4 bits menos significativos

    // Determinando as saídas para o comparador de 8 bits
    assign igual = igual_4_1 & igual_4_2; // os dois grupos devem ser iguais
    assign maior = maior_4_1 | (igual_4_1 & maior_4_2); // se os 4 bits mais significativos forem maiores, ou se forem iguais e os 4 menos significativos forem maiores
    assign menor = menor_4_1 | (igual_4_1 & menor_4_2); // lógica semelhante para menor

endmodule
