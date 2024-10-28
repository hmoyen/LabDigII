module dual_wheel_interface #(
    parameter integer DIST_PER_PULSE = 628 // Distância por pulso em mm (2πR * 1000)
) (
    input wire clk,          // Clock do sistema
    input wire reset,        // Sinal de reset
    input wire A_left,       // Canal A do encoder para a roda esquerda
    input wire B_left,       // Canal B do encoder para a roda esquerda
    input wire A_right,      // Canal A do encoder para a roda direita
    input wire B_right,      // Canal B do encoder para a roda direita
    output wire [31:0] distance_pulse_left,
    output wire [31:0] distance_pulse_right,
    output wire signed [31:0] delta_theta, // Saída: delta theta em milirradianos
    output wire [31:0] average_distance // Saída: distância média
);

// Sinais de incremento das rodas
wire incrementa_ccw_left, incrementa_cw_left, incrementa_cw_right, incrementa_ccw_right;

// Instância do módulo interface_wheel para a roda esquerda
interface_wheel left_wheel (
    .clk(clk),
    .reset(reset),
    .A(A_left),
    .B(B_left),
    .count(),
    .CW_db(),
    .CCW_db(),
    .CW(),
    .CCW(),
    .incrementa_cw(incrementa_cw_left),
    .incrementa_ccw(incrementa_ccw_left),
    .hex0_out(),
    .hex1_out()
);

// Instância do módulo interface_wheel para a roda direita
interface_wheel right_wheel (
    .clk(clk),
    .reset(reset),
    .A(A_right),
    .B(B_right),
    .count(),
    .CW_db(),
    .CCW_db(),
    .CW(),
    .CCW(),
    .incrementa_cw(incrementa_cw_right),
    .incrementa_ccw(incrementa_ccw_right),
    .hex0_out(),
    .hex1_out()
);

// Instância do módulo distance_calculator para calcular a distância de cada pulso
distance_calculator #(
    .DIST_PER_PULSE(DIST_PER_PULSE)
) calc_distance_right (
    .clk(clk),
    .reset(reset),
    .incrementa_cw(incrementa_cw_right),
    .incrementa_ccw(incrementa_ccw_right),
    .distance(distance_pulse_right)
);

// Instância do módulo distance_calculator para calcular a distância de cada pulso
distance_calculator #(
    .DIST_PER_PULSE(DIST_PER_PULSE)
) calc_distance_left (
    .clk(clk),
    .reset(reset),
    .incrementa_cw(incrementa_cw_left),
    .incrementa_ccw(incrementa_ccw_left),
    .distance(distance_pulse_left)
);

// Instância do módulo delta_theta_calculator
delta_theta_calculator delta_theta_inst (
    .distance_right(distance_pulse_right),
    .distance_left(distance_pulse_left),
    .delta_theta(delta_theta)
);

// Instância do módulo average_distance_calculator
average_distance_calculator avg_distance_inst (
    .distance_right(distance_pulse_right),
    .distance_left(distance_pulse_left),
    .average_distance(average_distance)
);

endmodule
