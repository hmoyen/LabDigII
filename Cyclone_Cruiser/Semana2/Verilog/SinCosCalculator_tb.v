module SinCosCalculator_tb;

    // Testbench signals
    reg [31:0] angle_fixed;          // Input angle in fixed-point format
    wire [31:0] sine_fixed;         // Output sine value in fixed-point format
    wire [31:0] cosine_fixed;       // Output cosine value in fixed-point format

    // Instantiate the SinCosCalculator module
    SinCosCalculator uut (
        .angle_fixed(angle_fixed),
        .sine_fixed(sine_fixed),
        .cosine_fixed(cosine_fixed)
    );

    initial begin
        // Test cases
        $display("Angle (radians) | Sine Value | Cosine Value");
        $display("-----------------------------------------");

        // Test case 1: angle = 0 radians
        angle_fixed = $realtobits(0.0); #10;
        $display("%16.2f | %10.6f | %12.6f", $bitstoreal(angle_fixed), $bitstoreal(sine_fixed), $bitstoreal(cosine_fixed));

        // Test case 2: angle = π/2 radians
        angle_fixed = $realtobits(3.141592653589793/2); #10; // 90 degrees
        $display("%16.2f | %10.6f | %12.6f", $bitstoreal(angle_fixed), $bitstoreal(sine_fixed), $bitstoreal(cosine_fixed));

        // Test case 3: angle = π radians
        angle_fixed = $realtobits(3.141592653589793); #10; // 180 degrees
        $display("%16.2f | %10.6f | %12.6f", $bitstoreal(angle_fixed), $bitstoreal(sine_fixed), $bitstoreal(cosine_fixed));

        // Test case 4: angle = 3π/2 radians
        angle_fixed = $realtobits(3 * 3.141592653589793/2); #10; // 270 degrees
        $display("%16.2f | %10.6f | %12.6f", $bitstoreal(angle_fixed), $bitstoreal(sine_fixed), $bitstoreal(cosine_fixed));

        // Test case 5: angle = 2π radians
        angle_fixed = $realtobits(2 * 3.141592653589793); #10; // 360 degrees
        $display("%16.2f | %10.6f | %12.6f", $bitstoreal(angle_fixed), $bitstoreal(sine_fixed), $bitstoreal(cosine_fixed));

        // End simulation
        $finish;
    end

endmodule
