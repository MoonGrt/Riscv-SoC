//Copyright (C)2014-2025 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.10.02 
//Created Time: 2025-06-03 20:15:18
create_clock -name clk -period 37.037 -waveform {0 18.518} [get_ports {clk}]
create_clock -name sys_clk -period 20 -waveform {0 10} [get_nets {io_mainClk}]
