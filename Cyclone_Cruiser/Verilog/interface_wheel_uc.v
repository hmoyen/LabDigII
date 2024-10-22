module interface_wheel_uc(
    input wire clk,          // Clock do sistema
    input wire reset,        // Sinal de reset
    input wire A_prev,       // Valor anterior do canal A
    input wire A,            // Valor atual do canal A
    input wire B,            // Valor atual do canal B
    output reg conta_cw; 
	 output reg registra;
	 output reg conta_cww;
		
);

	reg [1:0] Eatual, Eprox;

    // Definição dos estados
    typedef enum reg [1:0] {
        IDLE,    // Estado de espera
        CW,      // Rotação no sentido horário
        CCW,     // Rotação no sentido anti-horário
        UPDATE   
    // Parâmetros para os estados
    parameter inicial             = 3'b000;
    parameter CW                  = 3'b001;
    parameter CWW                 = 3'b010;
    parameter UPDATE              = 3'b011;
   


    // Lógica de transição de estados
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;   // Estado inicial
        else
            state <= next_state; // Atualiza o estado atual
    end
	 
	 always @(posedge clock or posedge reset) begin
        if (reset) 
            Eatual <= inicial;
        else
            Eatual <= Eprox; 
    end
	 
	 // Lógica de próximo estado
	 always @(*) begin
        case (Eatual)
            inicial:    Eprox = A_prev == 0 ? (A == 1 ? (B == 0 ? CW : CWW) : inicial) : inicial;
            CW:         Eprox = UPDATE;
            CWW:       	Eprox = UPDATE;
				UPDATE:		Eprox = inicial; 
            default:    Eprox = inicial;
        endcase
    end

	 // Saídas de controle
    always @(*) begin
        conta_cw       = (Eatual == CW) ? 1'b1 : 1'b0;
		  conta_cww       = (Eatual == CWW) ? 1'b1 : 1'b0;
        registra  = (Eatual == Update) ? 1'b1 : 1'b0;
		  
		  case (Eatual)
            inicial:              db_estado = 3'b000; // 0
            CW:           db_estado = 3'b001; // 1
            CWW:       db_estado = 3'b010; // 2
            UPDATE:  db_estado = 3'b011; // 3
            default:              db_estado = 3'b110; // Error state
        endcase
		end
		  

endmodule
