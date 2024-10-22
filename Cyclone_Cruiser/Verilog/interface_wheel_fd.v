module interface_wheel_fd (
    input wire clk,          // Clock do sistema
    input wire reset,        // Sinal de reset
    input wire [1:0] state,  // Estado da unidade de controle
    output reg [7:0] count   // Saída do contador
);

    // Definição dos estados (mesmos da UC)
    typedef enum reg [1:0] {
        IDLE,    // Estado de espera
        CW,      // Rotação no sentido horário
        CCW,     // Rotação no sentido anti-horário
        UPDATE   // Atualiza a contagem
    } state_t;

    // Lógica de atualização da contagem
    always @(posedge clk or posedge reset) begin
        if (reset)
            count <= 8'b0;  // Reseta o contador
        else begin
            case (state)
                CW: count <= count + 1;  // Incrementa o contador no sentido horário
                CCW: count <= count - 1; // Decrementa no sentido anti-horário
                default: count <= count; // Não altera o contador em IDLE ou UPDATE
            endcase
        end
    end

endmodule
