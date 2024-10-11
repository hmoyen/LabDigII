`timescale 1ns/1ns

module sonar_tb;
    reg clock;
    reg reset;
    reg ligar;
    reg echo;
    reg silencio;
    wire trigger;
    wire pwm;
    wire saida_serial;
    wire fim_posicao;

    // Instanciação do DUT (Dispositivo sob Teste)
    sonar DUT (
        .clock(clock),
        .reset(reset),
        .ligar(ligar),
        .echo(echo),
        .parar(),
        .trigger(trigger),
        .silencio(silencio),
        .pwm(pwm),
        .saida_serial(saida_serial),
        .fim_posicao(fim_posicao),
        .medida0(),
        .medida1(),
        .medida2(),
        .db_mensurar(),
        .db_saida_serial(),
        .db_trigger(),
        .db_estado(),
        .db_echo()
    );

    // Configurações do clock
    parameter clockPeriod = 20; // clock de 50MHz
    // Gerador de clock
    always #(clockPeriod/2) clock = ~clock;

    // Array de casos de teste (estrutura equivalente em Verilog)
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
        clock = 0;

        // Reset
        caso = 0; 
        #(2*clockPeriod);
        reset = 1;
        #(2_000); // 2 us
        reset = 0;
        @(negedge clock);

        // Espera de 100us
        #(100_000); // 100 us
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
            #(400_000); // 400 us

            // 4) Gera pulso de echo
            echo = 1;
            #(larguraPulso);
            echo = 0;

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
