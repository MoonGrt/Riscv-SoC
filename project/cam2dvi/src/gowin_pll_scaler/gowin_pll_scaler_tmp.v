//Copyright (C)2014-2023 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: Template file for instantiation
//Tool Version: V1.9.9 (64-bit)
//Part Number: GW5AST-LV138FPG676AES
//Device: GW5AST-138B
//Device Version: B
//Created Time: Fri Oct 25 17:24:45 2024

//Change the instance name and port connections to the signal names
//--------Copy here to design--------

    Gowin_PLL_Scaler your_instance_name(
        .clkout0(clkout0_o), //output clkout0
        .clkin(clkin_i), //input clkin
        .reset(reset_i) //input reset
    );

//--------Copy end-------------------