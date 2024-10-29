module motor_contr(
input clk,
input reset,
input wire frente,
input wire tras,
input wire direita, 
input wire esquerda, 
output [3:0]motores

);

reg [3:0]motores_r;

always @(posedge clk or posedge reset) begin

	if(frente) begin
	motores_r <= 4'b0101;
	end

	if(tras) begin
	motores_r <= 4'b1010;
	end

	if(direita) begin
	motores_r <= 4'b0100;
	end

	if(esquerda) begin
	motores_r <= 4'b0001;
	end
end

assign motores = motores_r;

endmodule

