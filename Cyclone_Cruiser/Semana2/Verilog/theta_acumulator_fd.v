module theta_acumulator_fd (
    input wire clk,                        // System clock
    input wire reset,                      // Reset signal
    input wire soma,                       // Signal to accumulate
    input wire normaliza,
    input wire signed [63:0] delta_theta, // Change in angle (in microradians)
    output reg signed [63:0] theta       // Accumulated angle, normalized
);

    // Constants for angle normalization
    localparam signed [63:0] TWO_PI_MICRO = 6283185;  // 2π * 10^6 microradians
    reg signed [63:0] Q_theta;  // Internal variable for accumulated angle

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Q_theta <= 0;       // Reset accumulated angle
            theta <= 0;         // Reset output angle
        end else begin

            if (soma) begin
                // Update Q_theta with delta_theta
                Q_theta <= Q_theta + delta_theta;
            end

            if (normaliza) begin
                // Normalize Q_theta within the range [0, 2π*10^6)
                if (Q_theta < 0) begin
                    Q_theta <= Q_theta + TWO_PI_MICRO;  // Wrap negative angles
                end
                
                // Normalize only if it exceeds TWO_PI_MICRO
                if (Q_theta >= TWO_PI_MICRO) begin
                    Q_theta <= Q_theta - TWO_PI_MICRO;  // Wrap positive angles
                end

                theta <= Q_theta; // Directly set theta to Q_theta
            end

        end
    end

endmodule
