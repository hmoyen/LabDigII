// module AngleConversion (
//     input real angle,             // Input angle in radians
//     output real angle_out,        // Output angle in the range [0, pi/2]
//     output reg sine_positive,      // Flag for sine positivity
//     output reg cosine_positive     // Flag for cosine positivity
// );
//     real sine_val, cosine_val;    // Sine and cosine values

//     always @(*) begin
//         // Calculate sine and cosine values
//         sine_val = $sin(angle);
//         cosine_val = $cos(angle);
        
//         // Determine flags based on sine and cosine values
//         sine_positive = (sine_val >= 0);
//         cosine_positive = (cosine_val >= 0);
        
//         // Convert angle to range [0, pi/2]
//         if (angle >= 0 && angle <= `M_PI) begin
//             angle_out = (sine_positive ? sine_val : -sine_val);
//         end else begin
//             angle_out = (sine_positive ? sine_val : -sine_val);
//         end
//     end
// endmodule
