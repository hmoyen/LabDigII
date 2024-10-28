module wheel_distance_calculator #(
    parameter integer DIST_PER_PULSE = 628 // Distância por pulso em mm (2πR * 1000)
) (
    input wire clk,                // Clock do sistema
    input wire reset,              // Sinal de reset
    input wire A,                  // Canal A do encoder
    input wire B,                  // Canal B do encoder
    output wire [31:0] total_distance // Distância total acumulada em mm
);

    // Sinais intermediários
    wire [7:0] count;
    wire CW_db, CCW_db;
    wire CW, CCW;
    wire incrementa_cw, incrementa_ccw;
    wire [6:0] hex0_out, hex1_out;
    wire signed [31:0] distance_pulse;

    // Instância do módulo interface_wheel para detectar a rotação da roda
    interface_wheel wheel_interface (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .count(count),
        .CW_db(CW_db),
        .CCW_db(CCW_db),
        .CW(CW),
        .CCW(CCW),
        .incrementa_cw(incrementa_cw),
        .incrementa_ccw(incrementa_ccw),
        .hex0_out(hex0_out),
        .hex1_out(hex1_out)
    );

    // Instância do módulo distance_calculator para calcular a distância de cada pulso
    distance_calculator #(
        .DIST_PER_PULSE(DIST_PER_PULSE)
    ) calc_distance (
        .clk(clk),
        .reset(reset),
        .incrementa_cw(incrementa_cw),
        .incrementa_ccw(incrementa_ccw),
        .distance(distance_pulse)
    );

    // Reg para acumular a distância total
    reg signed [31:0] accumulated_distance;

    // Acumulação da distância total com base nos pulsos de cada direção
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            accumulated_distance <= 0;
        end else begin
            accumulated_distance <= accumulated_distance + distance_pulse;
        end
    end

    // Atribuição da saída
    assign total_distance = accumulated_distance;

endmodule
