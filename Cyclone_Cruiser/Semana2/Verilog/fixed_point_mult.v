module fixed_point_mult (
    input wire signed [15:0] value,    // Sine or cosine in fixed-point (16-bit signed)
    input wire signed [31:0] avg_dist,     // Average distance in millimeters (32-bit signed)
    output wire signed [31:0] scaled_result // Result after scaling
);

    // Temporary variable for the multiplication result (48-bit to handle overflow)
    wire signed [47:0] temp_result;

    // Multiply sine or cosine by average distance
    assign temp_result = value * avg_dist;

    // Divide by scaling factor to get the final result
    assign scaled_result = temp_result >>> 15; // Right shift by 15 bits (divide by 32768)

endmodule
