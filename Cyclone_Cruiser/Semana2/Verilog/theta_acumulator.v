module theta_acumulator (
    input wire clk,                        // System clock
    input wire reset,                      // Reset signal
    input wire start,                      // Signal to start the accumulation
    input wire signed [63:0] delta_theta, // Change in angle (in microradians)
    output wire signed [63:0] theta,       // Accumulated angle, normalized
    output done                        // Done signal
);

    // Internal signals
    wire soma, s_done;                       // Signal to accumulate
    wire normaliza;                  // Signal to normalize

    // Instantiate the control module
    theta_acumulator_uc uc (
        .clk(clk),
        .reset(reset),
        .start(start),
        .soma(soma),
        .normaliza(normaliza),
        .done(s_done)           // Connect done output from data flow
    );

    // Instantiate the data flow module
    theta_acumulator_fd data_flow (
        .clk(clk),
        .reset(reset),
        .soma(soma),
        .normaliza(normaliza),
        .delta_theta(delta_theta),
        .theta(theta)         // Output accumulated angle
    );

    assign done = s_done;

endmodule
