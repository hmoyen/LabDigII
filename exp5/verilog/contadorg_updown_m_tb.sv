/*
 * contadorg_updown_m_tb.sv
 */
 
`timescale 1ns / 1ps

module contadorg_updown_m_tb;

    parameter M = 8;
    parameter N = 3;

    logic         clock;
    logic         zera_as;
    logic         zera_s;
    logic         conta;
    logic         dir;
    logic [N-1:0] current_count;
    wire  [N-1:0] Q;
    wire          inicio;
    wire          fim;
    wire          meio;
    wire          direcao;

    contadorg_updown_m #(M, N) dut (
        .clock  (clock  ),
        .zera_as(zera_as),
        .zera_s (zera_s ),
        .conta  (conta  ),
        .Q      (Q      ),
        .inicio (inicio ),
        .fim    (fim    ),
        .meio   (meio   ),
        .direcao(direcao)
    );

    // Clock generation
    always #5 clock = ~clock; // 10ns clock period

    initial begin
        // Initialize inputs
        clock   = 0;
        zera_as = 0;
        zera_s  = 0;
        conta   = 0;
        current_count = 0;
        dir = 0; 

        // Test 1: Asynchronous reset
        zera_as = 1;
        #10;
        assert(Q == 0) else $error("Asynchronous reset failed!");
        zera_as = 0;

        // Test 2: Synchronous reset
        zera_s = 1;
        @(posedge clock);
        assert(Q == 0) else $error("Synchronous reset failed!");
        zera_s = 0;

        // Test 3: Count up
        conta = 1;
        dir = 0; // Assuming initial direction is up
        for (int i = 0; i < M; i++) begin
            @(posedge clock);
            assert(Q == i) else $error("Count up failed at %0d!", i);
            assert(inicio == (i == 0)) else $error("inicio signal incorrect at %0d!", i);
            assert(fim == (i == M - 1)) else $error("fim signal incorrect at %0d!", i);
            assert(meio == (i == M / 2 - 1)) else $error("meio signal incorrect at %0d!", i);
        end

        // Test 4: Count down
        dir = 1; // Change direction to down
        for (int i = M - 2; i >= 0; i--) begin
            @(posedge clock);
            assert(Q == i) else $error("Count down failed at %0d!", i);
            assert(inicio == (i == 0)) else $error("inicio signal incorrect at %0d!", i);
            assert(fim == (i == M - 1)) else $error("fim signal incorrect at %0d!", i);
            assert(meio == (i == M / 2 - 1)) else $error("meio signal incorrect at %0d!", i);
        end

        // Test 5: Hold count
        conta = 0;
        assign current_count = Q;
        repeat (10) @(posedge clock); // Wait for 10 clock cycles
        assert(Q == current_count) else $error("Hold count failed!");

        $display("All tests passed!");
        $stop;
    end

endmodule