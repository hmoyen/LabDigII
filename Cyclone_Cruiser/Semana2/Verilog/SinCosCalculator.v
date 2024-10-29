module SinCosCalculator (
    input wire [31:0] angle_fixed,  // Input angle in fixed-point format
    output reg [31:0] sine_fixed,    // Output sine value in fixed-point format
    output reg [31:0] cosine_fixed    // Output cosine value in fixed-point format
);

    real angle;           // Real angle variable
    real sine_val;       // Real sine value
    real cosine_val;     // Real cosine value

    always @(*) begin
        // Convert fixed-point angle to real
        angle = $bitstoreal(angle_fixed);
        
        // Calculate sine and cosine values
        sine_val = $sin(angle);
        cosine_val = $cos(angle);

        // Convert sine and cosine values back to fixed-point representation
        sine_fixed = $realtobits(sine_val);
        cosine_fixed = $realtobits(cosine_val);
    end

endmodule
