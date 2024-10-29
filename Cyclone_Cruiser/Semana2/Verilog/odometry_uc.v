module odometry_uc(
    input wire clock,                    // Clock do sistema
    input wire reset,                    // Sinal de reset
    input wire new_average_distance,     // Sinal indicando nova média de distância
    input wire done_argument,
    input wire done_theta,
    output reg register_angle,           // Sinal para registrar ângulo
    output reg register_argument,        // Sinal para registrar argumento
    output reg start_argument,               // Sinal para somar ângulo
    output reg start_theta,
    output reg register_position,        // Sinal para registrar posição
    output reg [3:0] db_estado           // Usando 4 bits para o estado
);

    // Tipos e sinais
    reg [3:0] Eatual, Eprox; // Aumenta para 4 bits
    reg [1:0] counter;       // Contador para os ciclos

    // Parâmetros para os estados
    parameter IDLE                = 4'b0000;
    parameter REGISTER_DELTA_THETA = 4'b0001; // Novo estado
    parameter UPDATE_ARGUMENT      = 4'b0010; // Novo estado
    parameter REGISTER_ARGUMENT    = 4'b0011; // Novo estado
    parameter ESPERA_DONE_ARGUMENT = 4'b0100; // Novo estado
    parameter UPDATE_ANGLE        = 4'b0101;
    parameter ESPERA_DONE_ANGLE    = 4'b0110; // Novo estado
    parameter NORMALIZE_ANGLE     = 4'b0111;
    parameter REGISTER_ANGLE      = 4'b1000; // Novo estado
    parameter UPDATE_POSITION      = 4'b1001;
    parameter REGISTER_POSITION    = 4'b1010;

    // Estado
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            Eatual <= IDLE; // Estado inicial
            counter <= 2'b00; // Reinicia o contador
        end else begin
            Eatual <= Eprox;
            // Incrementa o contador apenas em estados de atualização
            if (Eatual == UPDATE_ARGUMENT || Eatual == UPDATE_ANGLE) begin
                counter <= counter + 1;
            end else begin
                counter <= 2'b00; // Reseta o contador em outros estados
            end
        end
    end

    // Lógica de próximo estado
    always @(*) begin
        case (Eatual)
            IDLE: begin
                Eprox = new_average_distance ? REGISTER_DELTA_THETA : IDLE; // Transita para registrar delta_theta
            end

            REGISTER_DELTA_THETA: begin
                // Aqui você pode adicionar a lógica para registrar delta_theta
                Eprox = UPDATE_ARGUMENT; // Transita para atualizar argumento
            end

            UPDATE_ARGUMENT: begin

                Eprox = ESPERA_DONE_ARGUMENT; // Transita para esperar o done_argument
             
            end
            
            ESPERA_DONE_ARGUMENT: begin
                Eprox = done_argument ? REGISTER_ARGUMENT : ESPERA_DONE_ARGUMENT; // Espera até done_argument ser 1
            end
            
            REGISTER_ARGUMENT: begin
                Eprox = UPDATE_ANGLE; // Transita para atualizar ângulo
            end
            
            UPDATE_ANGLE: begin
         
                Eprox = ESPERA_DONE_ANGLE; // Transita para esperar o done_theta
    
            end

            ESPERA_DONE_ANGLE: begin
                Eprox = done_theta ? NORMALIZE_ANGLE : ESPERA_DONE_ANGLE; // Espera até done_theta ser 1
            end
            
            NORMALIZE_ANGLE: begin
                Eprox = REGISTER_ANGLE; // Transita para registrar ângulo
            end

            REGISTER_ANGLE: begin
                Eprox = UPDATE_POSITION; // Transita para atualizar posição
            end

            UPDATE_POSITION: begin
                Eprox = REGISTER_POSITION; // Transita para registrar posição
            end

            REGISTER_POSITION: begin
                Eprox = IDLE; // Retorna ao estado de espera
            end

            default: begin
                Eprox = IDLE; // Em caso de estado indefinido, volta ao IDLE
            end
        endcase
    end

    // Saídas de controle
    always @(*) begin
        register_angle = (Eatual == REGISTER_ANGLE) ? 1'b1 : 1'b0;
        register_argument = (Eatual == REGISTER_ARGUMENT) ? 1'b1 : 1'b0; // Ativa o sinal de registrar argumento
        register_position = (Eatual == REGISTER_POSITION) ? 1'b1 : 1'b0;
        start_argument = (Eatual == UPDATE_ARGUMENT) ? 1'b1 : 1'b0;
        start_theta = (Eatual == UPDATE_ANGLE) ? 1'b1 : 1'b0;


        case (Eatual)
            IDLE:                     db_estado = 4'b0000; // 0
            REGISTER_DELTA_THETA:    db_estado = 4'b0001; // 1
            UPDATE_ARGUMENT:          db_estado = 4'b0010; // 2
            REGISTER_ARGUMENT:        db_estado = 4'b0011; // 3
            ESPERA_DONE_ARGUMENT:     db_estado = 4'b0100; // 4
            UPDATE_ANGLE:            db_estado = 4'b0101; // 5
            ESPERA_DONE_ANGLE:       db_estado = 4'b0110; // 6
            NORMALIZE_ANGLE:         db_estado = 4'b0111; // 7
            REGISTER_ANGLE:          db_estado = 4'b1000; // 8
            UPDATE_POSITION:          db_estado = 4'b1001; // 9
            REGISTER_POSITION:        db_estado = 4'b1010; // 10
            default:                 db_estado = 4'b1111; // Estado de erro
        endcase
    end

endmodule
