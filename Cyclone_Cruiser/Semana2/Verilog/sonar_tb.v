`timescale 1ns/1ns

module sonar_tb;
    reg clock;
    reg reset;
    reg ligar;
    reg echo;
    reg silencio;
    reg parar;           // Nova entrada adicionada
    reg [1:0] sel_mux;  // Nova entrada adicionada
    wire trigger;
    wire pwm;
    wire saida_serial;
    wire fim_posicao;
    wire [6:0] hex0_out, hex1_out, hex2_out, hex3_out, hex4_out, hex5_out; // Saídas adicionais

    // Instanciação do DUT (Dispositivo sob Teste)
    sonar DUT (
        .clock(clock),
        .reset(reset),
        .parar(parar),          // Conectando a nova entrada
        .ligar(ligar),
        .echo(echo),
        .silencio(silencio),
        .sel_mux(sel_mux),      // Conectando o seletor
        .trigger(trigger),
        .pwm(pwm),
        .saida_serial(saida_serial),
        .fim_posicao(fim_posicao),
        .hex0_out(hex0_out),    // Saídas adicionais
        .hex1_out(hex1_out),
        .hex2_out(hex2_out),
        .hex3_out(hex3_out),
        .hex4_out(hex4_out),
        .hex5_out(hex5_out),
        .db_timeout(),
        .db_mensurar(),
        .db_saida_serial(),
        .db_trigger(),
        .db_pwm(),
        .db_echo()
    );

    // Configurações do clock
    parameter clockPeriod = 20; // clock de 50MHz
    // Gerador de clock
    always #(clockPeriod/2) clock = ~clock;

    // Array de casos de teste
    reg [31:0] casos_teste [0:11]; // Usando 32 bits para acomodar o tempo
    integer caso;

    // Largura do pulso
    reg [31:0] larguraPulso; // Usando 32 bits para acomodar tempos maiores

    // Geração dos sinais de entrada (estímulos)
    initial begin
        $display("Inicio das simulacoes");

        // Inicialização do array de casos de teste
        casos_teste[0]  = 5882;   // 5882us (100cm)
        casos_teste[1]  = 4430;   // 4430us (75.29cm)
        casos_teste[2]  = 3222;   // 3222us (54.79cm)
        casos_teste[3]  = 2550;   // 2550us (43.35cm)
        casos_teste[4]  = 2000;   // 2000us (34.00cm)
        casos_teste[5]  = 1500;   // 1500us (25.501cm)
        casos_teste[6]  = 1000;   // 1000us (17.001cm)
        casos_teste[7]  = 500;    // 500us (8.50cm)
        casos_teste[8]  = 2941;   // 2941us (50cm)
        casos_teste[9]  = 882;    // 882us (15cm)
        casos_teste[10] = 1764;   // 1764us (30cm)
        casos_teste[11] = 7352;   // 7352us (125cm)

        // Valores iniciais
        ligar = 0;
        echo  = 0;
        silencio = 0;
        parar = 0;               // Inicializa a entrada parar
        sel_mux = 2'b00;         // Inicializa o seletor
        clock = 0;

        // Reset
        caso = 0; 
        #(2*clockPeriod);
        reset = 1;
        #(2_000); // 2 us
        reset = 0;
        @(negedge clock);

        // Espera de 10us
        #(10_000); // 10 us
        ligar = 1; // Ligar o sonar
        #(5*clockPeriod);

        // Loop pelos casos de teste
        for (caso = 1; caso < 13; caso = caso + 1) begin
            // Alternar silencio após o caso 6
            if (caso == 7) begin
                silencio = 1; // Ativa o silencio no meio dos testes
                $display("Silencio ativado");
            end

            // Desativar silencio após o caso 9
            if (caso == 10) begin
                silencio = 0; // Desativa o silencio para os últimos testes
                $display("Silencio desativado");
            end

            // 1) Determina a largura do pulso echo
            $display("Caso de teste %0d: %0dus", caso, casos_teste[caso-1]);
            larguraPulso = casos_teste[caso-1]*1000; // 1us=1000

            // 2) Espera envio do trigger
            wait (trigger == 1'b1);
            // 3) Espera por 400us (tempo entre trigger e echo)
            #(10_000); // 400 us

            // 4) Gera pulso de echo (timeout no caso 4)
            if (caso == 4) begin
                $display("Caso %0d: Timeout simulado", caso);
                echo = 0; // Simula timeout não gerando o pulso echo
                #(4_000_000);
                // Deve dar timeout
            end else begin
                echo = 1;
                #(larguraPulso);
                echo = 0;
            end

            // 5) Espera final da medida
            wait (fim_posicao == 1'b1);
            $display("Fim do caso %0d", caso);

            // 6) Espera entre casos de teste
            #(100); // 100 ns
        end

        // Fim da simulação
        $display("Fim das simulacoes");
        caso = 99; 
        $stop;
    end

endmodule
