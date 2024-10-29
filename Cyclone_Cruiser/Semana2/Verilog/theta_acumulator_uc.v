module theta_acumulator_uc (
    input wire clk,                        // System clock
    input wire reset,                      // Reset signal
    input wire start,
    output reg soma,                       // Signal to indicate accumulation
    output reg normaliza,                  // Signal to normalize
    output reg done                        // Done signal from data flow
);

    // State Definitions
    localparam IDLE          = 3'b000;
    localparam SOME          = 3'b001;
    localparam ESPERA_SOME   = 3'b010;
    localparam NORMALIZE     = 3'b011;
    localparam ESPERA_NORMALIZE = 3'b100;
    localparam DONE          = 3'b101;

    reg [2:0] current_state, next_state;

    // State Transition Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE; // Reset to IDLE state
            done <= 0;             // Reset done signal
        end else begin
            current_state <= next_state; // Transition to next state
        end
    end

    // Next state logic
    always @(*) begin
        // Default values
        soma = 0;              // Disable accumulation by default
        normaliza = 0;        // Disable normalization by default
        done = 0;             // Clear done signal by default

        case (current_state)
            IDLE: begin
                if (start) begin
                    next_state = SOME; // Transition to SOME state
                end else begin
                    next_state = IDLE; // Stay in IDLE
                end
            end
            
            SOME: begin
                soma = 1;            // Enable accumulation
                next_state = ESPERA_SOME; // Transition to ESPERA_SOME state
            end
            
            ESPERA_SOME: begin
                soma = 0;       // Não preciso de dois ciclos aqui
                // Logic to wait or check if accumulation should stop can be added here
                // You might want to check a condition here to transition to NORMALIZE
                next_state = NORMALIZE; // Automatically transition for simplicity
            end

            NORMALIZE: begin
                soma = 0;            // Disable accumulation
                normaliza = 1;      // Enable normalization
                next_state = ESPERA_NORMALIZE; // Transition to ESPERA_NORMALIZE state
            end
            
            ESPERA_NORMALIZE: begin
                normaliza = 1;      // Keep normalizing
                // Logic to wait or check if normalization should stop can be added here
                next_state = DONE; // Automatically transition for simplicity
            end

            DONE: begin
                done = 1;           // Set done signal
                next_state = IDLE;  // Transition back to IDLE
            end
            
            default: begin
                next_state = IDLE; // Default to IDLE on undefined state
            end
        endcase
    end

endmodule
