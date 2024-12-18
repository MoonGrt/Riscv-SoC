create_clock -name I_clk -period 20 -waveform {0 10} [get_ports {I_clk}] -add
create_clock -name I_tmds_clk_p -period 13.468 -waveform {0 6.734} [get_ports {I_tmds_clk_p}] -add
create_clock -name rx0_pclk -period 13.468 -waveform {0 6.734} [get_nets {rx0_pclk}] -add
set_clock_groups -exclusive -group [get_clocks {I_tmds_clk_p}] -group [get_clocks {rx0_pclk}]
