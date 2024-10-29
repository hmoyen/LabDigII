module odometry #(
    parameter integer DIST_PER_PULSE = 314159  // Distância por pulso em mm (em micrômetros)
) (
    input wire clk,                // Clock do sistema
    input wire reset,              // Sinal de reset
    input wire A_left,             // Canal A do encoder para a roda esquerda
    input wire B_left,             // Canal B do encoder para a roda esquerda
    input wire A_right,            // Canal A do encoder para a roda direita
    input wire B_right,            // Canal B do encoder para a roda direita
    output wire signed [63:0] theta,           // Ângulo atual em micro-radianos
    output wire signed [31:0] x,                  // Posição x em micrômetros
    output wire signed [31:0] y                   // Posição y em micrômetros
);

    // Conexões intermediárias
    wire signed [63:0] delta_theta;  // Delta theta em micro-radianos
    wire signed [31:0] average_distance, s_average_distance;  // Distância média
    wire [31:0] db_distance_left;     // Debug da distância da roda esquerda
    wire [31:0] db_distance_right;    // Debug da distância da roda direita
    wire [63:0] s_theta, s_argument, argument, s_delta_theta;
    wire [31:0] delta_y, delta_x;
    wire register_argument, done_argument, start_argument, start_theta, done_theta;

    // Sinais para seno e cosseno
    wire signed [15:0] cos_theta;     // Cosseno do ângulo atual
    wire signed [15:0] sin_theta;     // Seno do ângulo atual

    // Instanciação do módulo de interface das rodas
    dual_wheel_interface #(
        .DIST_PER_PULSE(DIST_PER_PULSE)
    ) dual_wheel_interface_inst (
        .clk(clk),
        .reset(reset),
        .A_left(A_left),
        .B_left(B_left),
        .A_right(A_right),
        .B_right(B_right),
        .delta_theta(delta_theta),
        .average_distance(average_distance),
        .db_distance_right(db_distance_right),
        .db_distance_left(db_distance_left)
    );

    // Constants for conversion
    parameter integer SCALE_MRAD_TO_DEG = 573;  // Approximation of 0.0573 * 10^7 for integer multiplication

    // Intermediate variables
    wire [31:0] degrees_temp;
    wire [8:0] angle_index;  // 9-bit output to index the ROM (0–359)

    // Convert milliradians to degrees (approximation by multiplying and shifting)
    assign degrees_temp = (argument * SCALE_MRAD_TO_DEG) / 10000000;

    // Normalize degrees to 0–359 range
    assign angle_index = degrees_temp % 360;

    // Access ROM to get sine and cosine values
    wire [15:0] sine_out, cosine_out;
    rom_sine_cosine_360x16 rom_inst (
        .angle(angle_index),
        .sine_out(sine_out),
        .cosine_out(cosine_out)
    );

    // Instanciação do módulo de estimador de pose
    theta_acumulator theta_inst (
        .clk(clk),
        .reset(reset),
        .done(done_theta),
        .start(start_theta),
        .delta_theta(s_delta_theta),
        .theta(s_theta)      // Atualiza o ângulo atual
    );

    // Calcula o argumento do ângulo que vai no cosseno e no seno

    argument_calc argument_calc (
        .clk(clk),
        .reset(reset),
        .theta(s_theta),
        .start(start_argument),
        .done(done_argument),
        .delta_theta(s_delta_theta),
        .argument(s_argument)      
    );

    fixed_point_mult mult_sine (

        .value(sine_out),
        .avg_dist(s_average_distance),
        .scaled_result(delta_y)
    );

    fixed_point_mult mult_cosine (

        .value(cosine_out),
        .avg_dist(s_average_distance),
        .scaled_result(delta_x)
    );

    // Instanciação do módulo odometry_uc
    wire register_angle;        // Sinal para registrar ângulo
    wire register_delta;
    wire register_position;     // Sinal para registrar posição
    wire signed [31:0] odometry_x;     // Posição x atualizada no módulo odometry_uc
    wire signed [31:0] odometry_y;     // Posição y atualizada no módulo odometry_uc
    wire new_average_distance;   // Sinal indicando nova média de distância

    odometry_uc odometry_controller (
        .clock(clk),
        .reset(reset),
        .new_average_distance(new_average_distance),  // Sinal para nova média de distância
        .register_angle(register_angle),
        .start_argument(start_argument),
        .start_theta(start_theta),
        .register_argument(register_argument),
        .done_argument(done_argument),
        .done_theta(done_theta),
        .register_position(register_position),
        .db_estado()            // Sinal de estado (opcional, se necessário)
    );
    
    edge_detector_32bit edge_detect (

        .new_average_distance(average_distance),
        .pulso(new_average_distance),
        .clock(clk),
        .reset(reset)
    );


    // Registros para armazenar os valores atualizados
    registrador_n #(
        .N(64)
    ) regs_theta (
        .clock(clk),
        .clear(reset),
        .enable(register_angle), // Ativa quando o ângulo deve ser registrado
        .D(s_theta),
        .Q(theta)
    );

    // Registros para armazenar os valores atualizados
    registrador_n #(
        .N(64)
    ) regs_delta_theta (
        .clock(clk),
        .clear(reset),
        .enable(register_delta), // Ativa quando o ângulo deve ser registrado
        .D(delta_theta),
        .Q(s_delta_theta)
    );


    // Registros para armazenar os valores atualizados
    registrador_n #(
        .N(64)
    ) regs_argument (
        .clock(clk),
        .clear(reset),
        .enable(register_argument), // Ativa quando o ângulo deve ser registrado
        .D(s_argument),
        .Q(argument)
    );

    // registrador_n #(
    //     .N(32)
    // ) regs_x (
    //     .clock(clk),
    //     .clear(reset),
    //     .enable(register_position), // Ativa quando a posição deve ser registrada
    //     .D(odometry_x),
    //     .Q(x)
    // );

    registrador_n #(
        .N(32)
    ) regs_avg_dist (
        .clock(clk),
        .clear(reset),
        .enable(register_avg_dist), // Ativa quando a posição deve ser registrada
        .D(average_distance),
        .Q(s_average_distance)
    );

    assign register_avg_dist = average_distance ? 1'b1 : 1'b0;
    assign register_delta = register_avg_dist;

endmodule
