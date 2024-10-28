module interface_wheel_uc(
    input clk,            // Clock signal
    input reset,          // Reset signal
    input pin1,           // Encoder output pin 1
    input pin2,           // Encoder output pin 2
    output reg dir_cw,    // Output for clockwise rotation
    output reg dir_ccw,   // Output for counterclockwise rotation
    output reg registra    // Output signal indicating final state detection
);

    // State encoding
    parameter R_START = 3'b000,
              R_CW_FINAL = 3'b001,
              R_CW_BEGIN = 3'b010,
              R_CW_NEXT = 3'b011,
              R_CCW_BEGIN = 3'b100,
              R_CCW_FINAL = 3'b101,
              R_CCW_NEXT = 3'b110,
              R_REGISTRA = 3'b111;

    reg [2:0] state;      // Current state
    wire [1:0] pin_state; // Combined pin state (bit1 and bit2)

    // Combine pin1 and pin2 into a 2-bit value for state transitions
    assign pin_state = {pin2, pin1};

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= R_START;
            dir_cw <= 0;
            dir_ccw <= 0;
            registra <= 0; // Initialize registra to 0
        end else begin
            case (state)
                R_START: begin
                    dir_cw <= 0;
                    dir_ccw <= 0;
                    registra <= 0; // Reset registra in idle state
                    case (pin_state)
                        2'b01: state <= R_CW_BEGIN;
                        2'b10: state <= R_CCW_BEGIN;
                        default: state <= R_START;
                    endcase
                end

                // Clockwise Rotation States
                R_CW_BEGIN: begin
                    if (pin_state == 2'b11)
                        state <= R_CW_NEXT;
                    else if (pin_state == 2'b00)
                        state <= R_START;
                    else
                        state <= R_CW_BEGIN;
                end
                R_CW_NEXT: begin
                    if (pin_state == 2'b10)
                        state <= R_CW_FINAL;
                    else if (pin_state == 2'b00)
                        state <= R_START;
                    else
                        state <= R_CW_NEXT;
                end
                R_CW_FINAL: begin
                    if (pin_state == 2'b00) begin
                        state <= R_REGISTRA;
                        dir_cw <= 1;  // Clockwise direction detected
                    end else
                        state <= R_CW_FINAL;
                end

                // Counterclockwise Rotation States
                R_CCW_BEGIN: begin
                    if (pin_state == 2'b11)
                        state <= R_CCW_NEXT;
                    else if (pin_state == 2'b00)
                        state <= R_START;
                    else
                        state <= R_CCW_BEGIN;
                end
                R_CCW_NEXT: begin
                    if (pin_state == 2'b01)
                        state <= R_CCW_FINAL;
                    else if (pin_state == 2'b00)
                        state <= R_START;
                    else
                        state <= R_CCW_NEXT;
                end
                R_CCW_FINAL: begin
                    if (pin_state == 2'b00) begin
                        state <= R_REGISTRA;
                        dir_ccw <= 1;  // Counterclockwise direction detected
                    end else
                        state <= R_CCW_FINAL;
                end

                R_REGISTRA: begin
                    state <= R_START;
                    dir_cw <= 0;
                    dir_ccw <= 0;
                    registra <= 1; // Set registra to indicate final state detection
                end

                default: begin
                    state <= R_START;
                    dir_cw <= 0;
                    dir_ccw <= 0;
                    registra <= 0; // Reset registra in default case
                end
            endcase
        end
    end

endmodule
