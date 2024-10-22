module interface_wheel (
		input clk,
		input reset,
		input A,
		input B,
		output CCW,
		output CW,
		output reg [7:0} count,
		output reg speed

);

// Fios de interconexão
    reg A_prev;              // Armazena o valor anterior de A
    wire [1:0] state;        // Sinal do estado atual da UC

    // Instancia a unidade de controle (UC)
    control_unit UC (
        .clk(clk),
        .reset(reset),
        .A_prev(A_prev),
        .A(A),
        .B(B),
        .state(state)
    );

    // Instancia o fluxo de dados (FD)
    data_path FD (
        .clk(clk),
        .reset(reset),
        .state(state),
        .count(count)
    );

    // Atualiza o valor anterior de A
    always @(posedge clk or posedge reset) begin
        if (reset)
            A_prev <= 0;
        else
            A_prev <= A;  // Armazena o valor anterior de A
    end


endmodule
