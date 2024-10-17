onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate -height 20 -label clock /sonar_tb/clock
add wave -noupdate -height 20 -label caso /sonar_tb/caso
add wave -noupdate -divider Entradas
add wave -noupdate -color {Violet Red} -height 20 -label reset /sonar_tb/reset
add wave -noupdate -color {Violet Red} -height 20 -label ligar /sonar_tb/ligar
add wave -noupdate -color {Violet Red} -height 20 -label echo /sonar_tb/echo
add wave -noupdate -color {Violet Red} -height 20 -label silencio /sonar_tb/silencio
add wave -noupdate -divider Saidas
add wave -noupdate -color Cyan -height 20 -label trigger /sonar_tb/trigger
add wave -noupdate -color Cyan -height 20 -label pwm /sonar_tb/pwm
add wave -noupdate -color Cyan -height 20 -label saida_serial /sonar_tb/saida_serial
add wave -noupdate -color Cyan -height 20 -label fim_posicao /sonar_tb/fim_posicao
add wave -noupdate -divider {Interface do sensor}
add wave -noupdate -color Magenta -height 20 -label {reset do sensor} /sonar_tb/DUT/FD/s_reset_int
add wave -noupdate -color Magenta -height 20 -label medir /sonar_tb/DUT/FD/INT/U1/medir
add wave -noupdate -color Magenta -height 20 -label {fim da medida} /sonar_tb/DUT/FD/INT/U1/fim_medida
add wave -noupdate -color Magenta -height 20 -label zera /sonar_tb/DUT/FD/INT/U1/zera
add wave -noupdate -color Magenta -height 20 -label {gera - gera trigger} /sonar_tb/DUT/FD/INT/U1/gera
add wave -noupdate -color Magenta -height 20 -label {registra - registra medida} /sonar_tb/DUT/FD/INT/U1/registra
add wave -noupdate -color Magenta -height 20 -label {estado interface} /sonar_tb/DUT/FD/INT/U1/db_estado
add wave -noupdate -divider {Fluxo de dados (trena)}
add wave -noupdate -color Pink -height 20 -label medir /sonar_tb/DUT/FD/medir
add wave -noupdate -color Pink -height 20 -label timeout /sonar_tb/DUT/FD/timeout
add wave -noupdate -color Pink -height 20 -label transmitir /sonar_tb/DUT/FD/transmitir
add wave -noupdate -color Pink -height 20 -label angulo_centena -radix ascii /sonar_tb/DUT/FD/angulo_centena
add wave -noupdate -color Pink -height 20 -label angulo_dezena -radix ascii /sonar_tb/DUT/FD/angulo_dezena
add wave -noupdate -color Pink -height 20 -label angulo_unidade -radix ascii /sonar_tb/DUT/FD/angulo_unidade
add wave -noupdate -color Pink -height 20 -label medida_pronto /sonar_tb/DUT/FD/medida_pronto
add wave -noupdate -color Pink -height 20 -label envio_pronto /sonar_tb/DUT/FD/envio_pronto
add wave -noupdate -color Pink -height 20 -label medida_unidade -radix unsigned /sonar_tb/DUT/FD/unidade
add wave -noupdate -color Pink -height 20 -label medida_dezena -radix unsigned /sonar_tb/DUT/FD/dezena
add wave -noupdate -color Pink -height 20 -label medida_centena -radix unsigned /sonar_tb/DUT/FD/centena
add wave -noupdate -color Pink -height 20 -label {fim_transmissao (fim contador)} /sonar_tb/DUT/FD/fim_transmissao
add wave -noupdate -color Pink -height 20 -label {seletor mux (angulo ou medida)} /sonar_tb/DUT/FD/seletor_mux
add wave -noupdate -color Pink -height 20 -label {dados_ascii (para transmissao)} -radix ascii /sonar_tb/DUT/FD/dados_ascii
add wave -noupdate -divider {Unidade de Controle}
add wave -noupdate -color {Sky Blue} -height 20 -label timeout_conta /sonar_tb/DUT/UC/timeout_conta
add wave -noupdate -color {Sky Blue} -height 20 -label {pronto (fim posicao)} /sonar_tb/DUT/UC/pronto
add wave -noupdate -label estado /sonar_tb/DUT/UC/db_estado
add wave -noupdate -divider Timeout
add wave -noupdate -color {Blue Violet} -height 20 /sonar_tb/DUT/s_timeout
add wave -noupdate -color {Blue Violet} -height 20 /sonar_tb/DUT/s_termina_medida
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {211033672 ns} 0} {{Cursor 2} {20002050 ns} 0} {{Cursor 3} {96196556 ns} 0} {{Cursor 4} {86532961 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 286
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {55264896 ns}
