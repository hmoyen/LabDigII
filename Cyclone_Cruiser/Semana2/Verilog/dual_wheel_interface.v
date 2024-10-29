module dual_wheel_interface #(
    parameter integer DIST_PER_PULSE = 314159  // Distância por pulso em mm 2 * pi * R em micro, ex: roda de raio 5 cm --> 5cm = 50 * 1000 micrometro ; 50 000 * 2 * pi
) (
    input wire clk,                // Clock do sistema
    input wire reset,              // Sinal de reset
    input wire A_left,             // Canal A do encoder para a roda esquerda
    input wire B_left,             // Canal B do encoder para a roda esquerda
    input wire A_right,            // Canal A do encoder para a roda direita
    input wire B_right,            // Canal B do encoder para a roda direita
    output wire signed [63:0] delta_theta, // Delta theta em microrradianos
    output wire signed [31:0] average_distance,    // Distância média
    output wire [31:0] db_distance_right,
    output wire [31:0] db_distance_left
);

    // Conexões intermediárias entre os módulos
    wire pulso_ccw_left;
    wire pulso_ccw_right;
    wire pulso_cw_left;
    wire pulso_cw_right;
    wire incrementa_ccw_left;
    wire incrementa_ccw_right;
    wire incrementa_cw_left;
    wire incrementa_cw_right;
    wire [31:0] distance_pulse_left;
    wire [31:0] distance_pulse_right;

    // Instanciação do módulo de interface das rodas
    dual_wheel_interface_fd #(
        .DIST_PER_PULSE(DIST_PER_PULSE)
    ) dual_wheel_interface (
        .clk(clk),
        .reset(reset),
        .A_left(A_left),
        .B_left(B_left),
        .A_right(A_right),
        .B_right(B_right),
        .pulso_ccw_left(pulso_ccw_left),
        .pulso_ccw_right(pulso_ccw_right),
        .pulso_cw_left(pulso_cw_left),
        .pulso_cw_right(pulso_cw_right),
        .incrementa_ccw_left(incrementa_ccw_left),
        .incrementa_ccw_right(incrementa_ccw_right),
        .incrementa_cw_left(incrementa_cw_left),
        .incrementa_cw_right(incrementa_cw_right),
        .distance_pulse_left(distance_pulse_left),
        .distance_pulse_right(distance_pulse_right),
        .delta_theta(delta_theta),
        .average_distance(average_distance)
    );

    // Instanciação do módulo de controle de pulso
    dual_wheel_interface_uc pulse_synchronizer (
        .clock(clk),
        .reset(reset),
        .incrementa_cw_left(incrementa_cw_left),
        .incrementa_cw_right(incrementa_cw_right),
        .incrementa_ccw_left(incrementa_ccw_left),
        .incrementa_ccw_right(incrementa_ccw_right),
        .pulso_left_ccw(pulso_ccw_left),
        .pulso_right_ccw(pulso_ccw_right),
        .pulso_right_cw(pulso_cw_right),
        .pulso_left_cw(pulso_cw_left),
        .db_estado()  // Estado de debug (opcional)
    );


    assign db_distance_left = distance_pulse_left;
    assign db_distance_right = distance_pulse_right;

endmodule
