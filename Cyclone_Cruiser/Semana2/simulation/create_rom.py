import math

# Define fixed-point scaling factor
SCALE_FACTOR = 32768

# Generate sine and cosine values for each degree
sine_entries = []
cosine_entries = []
for angle in range(360):
    # Convert angle to radians
    radians = math.radians(angle)
    
    # Calculate sine and cosine, scale to fixed point
    sine_fixed = int(math.sin(radians) * SCALE_FACTOR)
    cosine_fixed = int(math.cos(radians) * SCALE_FACTOR)
    
    # Store the values as 16-bit hex
    sine_entries.append(sine_fixed & 0xFFFF)
    cosine_entries.append(cosine_fixed & 0xFFFF)

# Write to Verilog ROM file
with open("rom_sine_cosine_360x16.v", "w") as f:
    f.write("/*\n * rom_sine_cosine_360x16.v\n */\n\n")
    f.write("module rom_sine_cosine_360x16 (\n")
    f.write("    input      [8:0]  angle,        // 9-bit angle input (0-359)\n")
    f.write("    output reg [15:0] sine_out,     // 16-bit output for sine\n")
    f.write("    output reg [15:0] cosine_out    // 16-bit output for cosine\n")
    f.write(");\n\n")
    f.write("  // ROM content in arrays for sine and cosine\n")
    f.write("  reg [15:0] sine_table [0:359];\n")
    f.write("  reg [15:0] cosine_table [0:359];\n\n")
    f.write("  initial begin\n")
    
    # Initialize ROM with sine values
    for angle, sine_value in enumerate(sine_entries):
        f.write(f"    sine_table[{angle}] = 16'h{sine_value:04X};  // Angle {angle}°\n")
    
    f.write("\n")
    
    # Initialize ROM with cosine values
    for angle, cosine_value in enumerate(cosine_entries):
        f.write(f"    cosine_table[{angle}] = 16'h{cosine_value:04X};  // Angle {angle}°\n")
    
    f.write("  end\n\n")
    f.write("  // Output sine and cosine based on the angle\n")
    f.write("  always @(*) begin\n")
    f.write("    sine_out = sine_table[angle];\n")
    f.write("    cosine_out = cosine_table[angle];\n")
    f.write("  end\n\n")
    f.write("endmodule\n")
