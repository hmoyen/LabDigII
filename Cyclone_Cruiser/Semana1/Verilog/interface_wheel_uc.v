module interface_wheel_uc(
    input wire clk,          // Clock do sistema
    input wire reset,        // Sinal de reset
    input wire A_prev,       // Valor anterior do canal A
    input wire A,            // Valor atual do canal A
    input wire B,            // Valor atual do canal B
    output reg conta_cw,
    output reg registra,
    output reg conta_cww
);

    // Definição dos estados usando `localparam`
    localparam IDLE   = 2'b00;   // Estado de espera
    localparam CW     = 2'b01;   // Rotação no sentido horário
    localparam CWW    = 2'b10;   // Rotação no sentido anti-horário
    localparam UPDATE = 2'b11;   // Estado de atualização

    reg [1:0] state, next_state;  // Registradores para o estado atual e o próximo
    reg [1:0] Eatual, Eprox;      // Registradores para o controle interno

    // Lógica de transição de estados para o `state`
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;   // Estado inicial
        else
            state <= next_state; // Atualiza o estado atual
    end

    // Lógica de transição de estados para `Eatual` e `Eprox`
    always @(posedge clk or posedge reset) begin
        if (reset) 
            Eatual <= IDLE;
        else
            Eatual <= Eprox; 
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            IDLE:    Eprox = (A_prev == 0) ? ((A == 1) ? ((B == 0) ? CW : CWW) : IDLE) : IDLE;
            CW:      Eprox = UPDATE;
            CWW:     Eprox = UPDATE;
            UPDATE:  Eprox = IDLE;
            default: Eprox = IDLE;
        endcase
    end

    // Saídas de controle
    always @(*) begin
        conta_cw   = (Eatual == CW) ? 1'b1 : 1'b0;
        conta_cww  = (Eatual == CWW) ? 1'b1 : 1'b0;
        registra   = (Eatual == UPDATE) ? 1'b1 : 1'b0;
    end

endmodule
