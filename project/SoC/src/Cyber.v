`timescale 1ns / 1ps
`define SYNTHESIS

module Cyber (
    input wire rst,
    input wire clk,

    input  wire io_jtag_tms,
    input  wire io_jtag_tdi,
    output wire io_jtag_tdo,
    input  wire io_jtag_tck,

    inout wire [15:0] GPIOA,
    inout wire [15:0] GPIOB
);

    wire io_axiClk = clk;
    wire io_asyncReset = ~rst;

    /* GPIO AFIO */
    // USART
    wire USART1_TX;
    wire USART1_RX = GPIOB[1];
    wire USART2_TX;
    wire USART2_RX = GPIOB[3];
    // I2C
    wire I2C1_SDA;
    wire I2C1_SCL;
    wire I2C2_SDA;
    wire I2C2_SCL;
    // SPI
    wire SPI1_SCK;
    wire SPI1_MOSI;
    wire SPI1_MISO = GPIOB[10];
    wire SPI1_CS;
    wire SPI2_SCK;
    wire SPI2_MOSI;
    wire SPI2_MISO = GPIOB[14];
    wire SPI2_CS;
    // TIM
    wire [3:0] TIM2_CH;
    wire [3:0] TIM3_CH;
    // AFIO Contection
    wire [15:0] AFIOA = {TIM3_CH, TIM2_CH, 8'bz};
    wire [15:0] AFIOB = {
        SPI2_CS,
        1'bz,
        SPI2_MOSI,
        SPI2_SCK,
        SPI1_CS,
        1'bz,
        SPI1_MOSI,
        SPI1_SCK,
        I2C2_SDA,
        I2C2_SCL,
        I2C1_SDA,
        I2C1_SCL,
        1'bz,
        USART2_TX,
        1'bz,
        USART1_TX
    };
    // Interrupt
    wire system_externalInterrupt = USART1_interrupt | USART2_interrupt;
    wire system_timerInterrupt = TIM2_interrupt | TIM3_interrupt;
    wire USART1_interrupt, USART2_interrupt;
    wire TIM2_interrupt, TIM3_interrupt;

    wire        system_gpioCtrl_io_apb_PREADY;  // GPIO
    wire [31:0] system_gpioCtrl_io_apb_PRDATA;  // GPIO
    wire        system_gpioCtrl_io_apb_PSLVERROR;  // GPIO
    wire [31:0] system_gpioCtrl_io_gpio_write;  // GPIO
    wire [31:0] system_gpioCtrl_io_gpio_writeEnable;  // GPIO
    wire        system_wdgCtrl_io_apb_PREADY;  // WDG
    wire [31:0] system_wdgCtrl_io_apb_PRDATA;  // WDG
    wire        system_wdgCtrl_io_apb_PSLVERROR;  // WDG
    wire [31:0] system_wdgCtrl_io_gpio_write;  // WDG
    wire [31:0] system_wdgCtrl_io_gpio_writeEnable;  // WDG
    wire        system_usartCtrl_io_apb_PREADY;  // USART
    wire [31:0] system_usartCtrl_io_apb_PRDATA;  // USART
    wire        system_usartCtrl_io_apb_PSLVERROR;  // USART
    wire [31:0] system_usartCtrl_io_gpio_write;  // USART
    wire [31:0] system_usartCtrl_io_gpio_writeEnable;  // USART
    wire        system_i2cCtrl_io_apb_PREADY;  // I2C
    wire [31:0] system_i2cCtrl_io_apb_PRDATA;  // I2C
    wire        system_i2cCtrl_io_apb_PSLVERROR;  // I2C
    wire [31:0] system_i2cCtrl_io_gpio_write;  // I2C
    wire [31:0] system_i2cCtrl_io_gpio_writeEnable;  // I2C
    wire        system_spiCtrl_io_apb_PREADY;  // SPI
    wire [31:0] system_spiCtrl_io_apb_PRDATA;  // SPI
    wire        system_spiCtrl_io_apb_PSLVERROR;  // SPI
    wire [31:0] system_spiCtrl_io_gpio_write;  // SPI
    wire [31:0] system_spiCtrl_io_gpio_writeEnable;  // SPI
    wire        system_timCtrl_io_apb_PREADY;  // TIM
    wire [31:0] system_timCtrl_io_apb_PRDATA;  // TIM
    wire        system_timCtrl_io_apb_PSLVERROR;  // TIM
    wire [31:0] system_timCtrl_io_gpio_write;  // TIM
    wire [31:0] system_timCtrl_io_gpio_writeEnable;  // TIM

    wire [19:0] apb3Router_1_io_outputs_0_PADDR;  // GPIO
    wire [ 0:0] apb3Router_1_io_outputs_0_PSEL;  // GPIO
    wire        apb3Router_1_io_outputs_0_PENABLE;  // GPIO
    wire        apb3Router_1_io_outputs_0_PWRITE;  // GPIO
    wire [31:0] apb3Router_1_io_outputs_0_PWDATA;  // GPIO
    wire [19:0] apb3Router_1_io_outputs_1_PADDR;  // WDG
    wire [ 0:0] apb3Router_1_io_outputs_1_PSEL;  // WDG
    wire        apb3Router_1_io_outputs_1_PENABLE;  // WDG
    wire        apb3Router_1_io_outputs_1_PWRITE;  // WDG
    wire [31:0] apb3Router_1_io_outputs_1_PWDATA;  // WDG
    wire [19:0] apb3Router_1_io_outputs_2_PADDR;  // USART
    wire [ 0:0] apb3Router_1_io_outputs_2_PSEL;  // USART
    wire        apb3Router_1_io_outputs_2_PENABLE;  // USART
    wire        apb3Router_1_io_outputs_2_PWRITE;  // USART
    wire [31:0] apb3Router_1_io_outputs_2_PWDATA;  // USART
    wire [19:0] apb3Router_1_io_outputs_3_PADDR;  // I2C
    wire [ 0:0] apb3Router_1_io_outputs_3_PSEL;  // I2C
    wire        apb3Router_1_io_outputs_3_PENABLE;  // I2C
    wire        apb3Router_1_io_outputs_3_PWRITE;  // I2C
    wire [31:0] apb3Router_1_io_outputs_3_PWDATA;  // I2C
    wire [19:0] apb3Router_1_io_outputs_4_PADDR;  // SPI
    wire [ 0:0] apb3Router_1_io_outputs_4_PSEL;  // SPI
    wire        apb3Router_1_io_outputs_4_PENABLE;  // SPI
    wire        apb3Router_1_io_outputs_4_PWRITE;  // SPI
    wire [31:0] apb3Router_1_io_outputs_4_PWDATA;  // SPI
    wire [19:0] apb3Router_1_io_outputs_5_PADDR;  // TIM
    wire [ 0:0] apb3Router_1_io_outputs_5_PSEL;  // TIM
    wire        apb3Router_1_io_outputs_5_PENABLE;  // TIM
    wire        apb3Router_1_io_outputs_5_PWRITE;  // TIM
    wire [31:0] apb3Router_1_io_outputs_5_PWDATA;  // TIM

    wire [15:0] system_gpioCtrl_io_apb_PADDR;  // GPIO PADDR
    wire [15:0] system_wdgCtrl_io_apb_PADDR;  // WDG PADDR
    wire [15:0] system_usartCtrl_io_apb_PADDR;  // USART PADDR
    wire [15:0] system_i2cCtrl_io_apb_PADDR;  // I2C PADDR
    wire [15:0] system_spiCtrl_io_apb_PADDR;  // SPI PADDR
    wire [15:0] system_timCtrl_io_apb_PADDR;  // TIM PADDR
    assign system_gpioCtrl_io_apb_PADDR  = apb3Router_1_io_outputs_0_PADDR[15:0];  // GPIO
    assign system_wdgCtrl_io_apb_PADDR   = apb3Router_1_io_outputs_1_PADDR[15:0];  // WDG
    assign system_usartCtrl_io_apb_PADDR = apb3Router_1_io_outputs_2_PADDR[15:0];  // USART
    assign system_i2cCtrl_io_apb_PADDR   = apb3Router_1_io_outputs_3_PADDR[15:0];  // I2C
    assign system_spiCtrl_io_apb_PADDR   = apb3Router_1_io_outputs_4_PADDR[15:0];  // SPI
    assign system_timCtrl_io_apb_PADDR   = apb3Router_1_io_outputs_5_PADDR[15:0];  // TIM






    reg         axi_core_cpu_dBus_cmd_ready;
    wire        axi_core_cpu_dBus_rsp_payload_last;
    wire        axi_core_cpu_dBus_rsp_payload_error;
    wire [ 7:0] axi_core_cpu_debug_bus_cmd_payload_address;
    wire        axi_core_cpu_iBus_rsp_payload_error;
    reg         dbus_axi_decoder_io_input_r_ready;
    wire [17:0] axi_ram_io_axi_arbiter_io_readInputs_0_ar_payload_addr;
    wire [17:0] axi_ram_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr;
    wire        axi_ram_io_axi_arbiter_io_output_arw_ready;
    wire [19:0] axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr;
    wire        axi_apbBridge_io_axi_arbiter_io_output_arw_ready;
    wire        axi_apbBridge_io_axi_arbiter_io_output_w_ready;
    wire        io_asyncReset_buffercc_io_dataOut;
    wire        axi_ram_io_axi_arw_ready;
    wire        axi_ram_io_axi_w_ready;
    wire        axi_ram_io_axi_b_valid;
    wire [ 3:0] axi_ram_io_axi_b_payload_id;
    wire [ 1:0] axi_ram_io_axi_b_payload_resp;
    wire        axi_ram_io_axi_r_valid;
    wire [31:0] axi_ram_io_axi_r_payload_data;
    wire [ 3:0] axi_ram_io_axi_r_payload_id;
    wire [ 1:0] axi_ram_io_axi_r_payload_resp;
    wire        axi_ram_io_axi_r_payload_last;
    wire        axi_apbBridge_io_axi_arw_ready;
    wire        axi_apbBridge_io_axi_w_ready;
    wire        axi_apbBridge_io_axi_b_valid;
    wire [ 3:0] axi_apbBridge_io_axi_b_payload_id;
    wire [ 1:0] axi_apbBridge_io_axi_b_payload_resp;
    wire        axi_apbBridge_io_axi_r_valid;
    wire [31:0] axi_apbBridge_io_axi_r_payload_data;
    wire [ 3:0] axi_apbBridge_io_axi_r_payload_id;
    wire [ 1:0] axi_apbBridge_io_axi_r_payload_resp;
    wire        axi_apbBridge_io_axi_r_payload_last;
    wire [19:0] axi_apbBridge_io_apb_PADDR;
    wire [ 0:0] axi_apbBridge_io_apb_PSEL;
    wire        axi_apbBridge_io_apb_PENABLE;
    wire        axi_apbBridge_io_apb_PWRITE;
    wire [31:0] axi_apbBridge_io_apb_PWDATA;
    wire        axi_core_cpu_dBus_cmd_valid;
    wire        axi_core_cpu_dBus_cmd_payload_wr;
    wire        axi_core_cpu_dBus_cmd_payload_uncached;
    wire [31:0] axi_core_cpu_dBus_cmd_payload_address;
    wire [31:0] axi_core_cpu_dBus_cmd_payload_data;
    wire [ 3:0] axi_core_cpu_dBus_cmd_payload_mask;
    wire [ 2:0] axi_core_cpu_dBus_cmd_payload_size;
    wire        axi_core_cpu_dBus_cmd_payload_last;
    wire        axi_core_cpu_debug_bus_cmd_ready;
    wire [31:0] axi_core_cpu_debug_bus_rsp_data;
    wire        axi_core_cpu_debug_resetOut;
    wire        axi_core_cpu_iBus_cmd_valid;
    wire [31:0] axi_core_cpu_iBus_cmd_payload_address;
    wire [ 2:0] axi_core_cpu_iBus_cmd_payload_size;
    wire        io_coreInterrupt_buffercc_io_dataOut;
    wire        jtagBridge_1_io_jtag_tdo;
    wire        jtagBridge_1_io_remote_cmd_valid;
    wire        jtagBridge_1_io_remote_cmd_payload_last;
    wire [ 0:0] jtagBridge_1_io_remote_cmd_payload_fragment;
    wire        jtagBridge_1_io_remote_rsp_ready;
    wire        systemDebugger_1_io_remote_cmd_ready;
    wire        systemDebugger_1_io_remote_rsp_valid;
    wire        systemDebugger_1_io_remote_rsp_payload_error;
    wire [31:0] systemDebugger_1_io_remote_rsp_payload_data;
    wire        systemDebugger_1_io_mem_cmd_valid;
    wire [31:0] systemDebugger_1_io_mem_cmd_payload_address;
    wire [31:0] systemDebugger_1_io_mem_cmd_payload_data;
    wire        systemDebugger_1_io_mem_cmd_payload_wr;
    wire [ 1:0] systemDebugger_1_io_mem_cmd_payload_size;
    wire        axi4ReadOnlyDecoder_1_io_input_ar_ready;
    wire        axi4ReadOnlyDecoder_1_io_input_r_valid;
    wire [31:0] axi4ReadOnlyDecoder_1_io_input_r_payload_data;
    wire [ 1:0] axi4ReadOnlyDecoder_1_io_input_r_payload_resp;
    wire        axi4ReadOnlyDecoder_1_io_input_r_payload_last;
    wire        axi4ReadOnlyDecoder_1_io_outputs_0_ar_valid;
    wire [31:0] axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_addr;
    wire [ 7:0] axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_len;
    wire [ 1:0] axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_burst;
    wire [ 3:0] axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_cache;
    wire [ 2:0] axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_prot;
    wire        axi4ReadOnlyDecoder_1_io_outputs_0_r_ready;
    wire        dbus_axi_decoder_io_input_arw_ready;
    wire        dbus_axi_decoder_io_input_w_ready;
    wire        dbus_axi_decoder_io_input_b_valid;
    wire [ 1:0] dbus_axi_decoder_io_input_b_payload_resp;
    wire        dbus_axi_decoder_io_input_r_valid;
    wire [31:0] dbus_axi_decoder_io_input_r_payload_data;
    wire [ 1:0] dbus_axi_decoder_io_input_r_payload_resp;
    wire        dbus_axi_decoder_io_input_r_payload_last;
    wire        dbus_axi_decoder_io_sharedOutputs_0_arw_valid;
    wire [31:0] dbus_axi_decoder_io_sharedOutputs_0_arw_payload_addr;
    wire [ 7:0] dbus_axi_decoder_io_sharedOutputs_0_arw_payload_len;
    wire [ 2:0] dbus_axi_decoder_io_sharedOutputs_0_arw_payload_size;
    wire [ 3:0] dbus_axi_decoder_io_sharedOutputs_0_arw_payload_cache;
    wire [ 2:0] dbus_axi_decoder_io_sharedOutputs_0_arw_payload_prot;
    wire        dbus_axi_decoder_io_sharedOutputs_0_arw_payload_write;
    wire        dbus_axi_decoder_io_sharedOutputs_0_w_valid;
    wire [31:0] dbus_axi_decoder_io_sharedOutputs_0_w_payload_data;
    wire [ 3:0] dbus_axi_decoder_io_sharedOutputs_0_w_payload_strb;
    wire        dbus_axi_decoder_io_sharedOutputs_0_w_payload_last;
    wire        dbus_axi_decoder_io_sharedOutputs_0_b_ready;
    wire        dbus_axi_decoder_io_sharedOutputs_0_r_ready;
    wire        dbus_axi_decoder_io_sharedOutputs_1_arw_valid;
    wire [31:0] dbus_axi_decoder_io_sharedOutputs_1_arw_payload_addr;
    wire [ 7:0] dbus_axi_decoder_io_sharedOutputs_1_arw_payload_len;
    wire [ 2:0] dbus_axi_decoder_io_sharedOutputs_1_arw_payload_size;
    wire [ 3:0] dbus_axi_decoder_io_sharedOutputs_1_arw_payload_cache;
    wire [ 2:0] dbus_axi_decoder_io_sharedOutputs_1_arw_payload_prot;
    wire        dbus_axi_decoder_io_sharedOutputs_1_arw_payload_write;
    wire        dbus_axi_decoder_io_sharedOutputs_1_w_valid;
    wire [31:0] dbus_axi_decoder_io_sharedOutputs_1_w_payload_data;
    wire [ 3:0] dbus_axi_decoder_io_sharedOutputs_1_w_payload_strb;
    wire        dbus_axi_decoder_io_sharedOutputs_1_w_payload_last;
    wire        dbus_axi_decoder_io_sharedOutputs_1_b_ready;
    wire        dbus_axi_decoder_io_sharedOutputs_1_r_ready;
    wire        axi_ram_io_axi_arbiter_io_readInputs_0_ar_ready;
    wire        axi_ram_io_axi_arbiter_io_readInputs_0_r_valid;
    wire [31:0] axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_data;
    wire [ 2:0] axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_id;
    wire [ 1:0] axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_resp;
    wire        axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_last;
    wire        axi_ram_io_axi_arbiter_io_sharedInputs_0_arw_ready;
    wire        axi_ram_io_axi_arbiter_io_sharedInputs_0_w_ready;
    wire        axi_ram_io_axi_arbiter_io_sharedInputs_0_b_valid;
    wire [ 2:0] axi_ram_io_axi_arbiter_io_sharedInputs_0_b_payload_id;
    wire [ 1:0] axi_ram_io_axi_arbiter_io_sharedInputs_0_b_payload_resp;
    wire        axi_ram_io_axi_arbiter_io_sharedInputs_0_r_valid;
    wire [31:0] axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_data;
    wire [ 2:0] axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_id;
    wire [ 1:0] axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_resp;
    wire        axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_last;
    wire        axi_ram_io_axi_arbiter_io_output_arw_valid;
    wire [17:0] axi_ram_io_axi_arbiter_io_output_arw_payload_addr;
    wire [ 3:0] axi_ram_io_axi_arbiter_io_output_arw_payload_id;
    wire [ 7:0] axi_ram_io_axi_arbiter_io_output_arw_payload_len;
    wire [ 2:0] axi_ram_io_axi_arbiter_io_output_arw_payload_size;
    wire [ 1:0] axi_ram_io_axi_arbiter_io_output_arw_payload_burst;
    wire        axi_ram_io_axi_arbiter_io_output_arw_payload_write;
    wire        axi_ram_io_axi_arbiter_io_output_w_valid;
    wire [31:0] axi_ram_io_axi_arbiter_io_output_w_payload_data;
    wire [ 3:0] axi_ram_io_axi_arbiter_io_output_w_payload_strb;
    wire        axi_ram_io_axi_arbiter_io_output_w_payload_last;
    wire        axi_ram_io_axi_arbiter_io_output_b_ready;
    wire        axi_ram_io_axi_arbiter_io_output_r_ready;
    wire        axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_ready;
    wire        axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_w_ready;
    wire        axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_valid;
    wire [ 3:0] axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_id;
    wire [ 1:0] axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_resp;
    wire        axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_valid;
    wire [31:0] axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_data;
    wire [ 3:0] axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_id;
    wire [ 1:0] axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_resp;
    wire        axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_last;
    wire        axi_apbBridge_io_axi_arbiter_io_output_arw_valid;
    wire [19:0] axi_apbBridge_io_axi_arbiter_io_output_arw_payload_addr;
    wire [ 3:0] axi_apbBridge_io_axi_arbiter_io_output_arw_payload_id;
    wire [ 7:0] axi_apbBridge_io_axi_arbiter_io_output_arw_payload_len;
    wire [ 2:0] axi_apbBridge_io_axi_arbiter_io_output_arw_payload_size;
    wire [ 1:0] axi_apbBridge_io_axi_arbiter_io_output_arw_payload_burst;
    wire        axi_apbBridge_io_axi_arbiter_io_output_arw_payload_write;
    wire        axi_apbBridge_io_axi_arbiter_io_output_w_valid;
    wire [31:0] axi_apbBridge_io_axi_arbiter_io_output_w_payload_data;
    wire [ 3:0] axi_apbBridge_io_axi_arbiter_io_output_w_payload_strb;
    wire        axi_apbBridge_io_axi_arbiter_io_output_w_payload_last;
    wire        axi_apbBridge_io_axi_arbiter_io_output_b_ready;
    wire        axi_apbBridge_io_axi_arbiter_io_output_r_ready;
    wire        io_apb_decoder_io_input_PREADY;
    wire [31:0] io_apb_decoder_io_input_PRDATA;
    wire        io_apb_decoder_io_input_PSLVERROR;
    wire [19:0] io_apb_decoder_io_output_PADDR;
    wire [ 3:0] io_apb_decoder_io_output_PSEL;
    wire        io_apb_decoder_io_output_PENABLE;
    wire        io_apb_decoder_io_output_PWRITE;
    wire [31:0] io_apb_decoder_io_output_PWDATA;
    wire        apb3Router_1_io_input_PREADY;
    wire [31:0] apb3Router_1_io_input_PRDATA;
    wire        apb3Router_1_io_input_PSLVERROR;
    wire [ 2:0] _zz_dbus_axi_arw_payload_len;
    reg         resetCtrl_systemResetUnbuffered;
    reg  [ 5:0] resetCtrl_systemResetCounter;
    wire [ 5:0] _zz_when_Briey2_l197;
    wire        when_Briey2_l197;
    wire        when_Briey2_l201;
    reg         resetCtrl_systemReset;
    reg         resetCtrl_axiReset;
    wire        dbus_axi_arw_valid;
    wire        dbus_axi_arw_ready;
    wire [31:0] dbus_axi_arw_payload_addr;
    wire [ 7:0] dbus_axi_arw_payload_len;
    wire [ 2:0] dbus_axi_arw_payload_size;
    wire [ 3:0] dbus_axi_arw_payload_cache;
    wire [ 2:0] dbus_axi_arw_payload_prot;
    wire        dbus_axi_arw_payload_write;
    wire        dbus_axi_w_valid;
    wire        dbus_axi_w_ready;
    wire [31:0] dbus_axi_w_payload_data;
    wire [ 3:0] dbus_axi_w_payload_strb;
    wire        dbus_axi_w_payload_last;
    wire        dbus_axi_b_valid;
    wire        dbus_axi_b_ready;
    wire [ 1:0] dbus_axi_b_payload_resp;
    wire        dbus_axi_r_valid;
    wire        dbus_axi_r_ready;
    wire [31:0] dbus_axi_r_payload_data;
    wire [ 1:0] dbus_axi_r_payload_resp;
    wire        dbus_axi_r_payload_last;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_valid;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_ready;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_wr;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_uncached;
    wire [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_address;
    wire [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_data;
    wire [ 3:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_mask;
    wire [ 2:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_size;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_last;
    reg         toplevel_axi_core_cpu_dBus_cmd_rValid;
    reg         toplevel_axi_core_cpu_dBus_cmd_rData_wr;
    reg         toplevel_axi_core_cpu_dBus_cmd_rData_uncached;
    reg  [31:0] toplevel_axi_core_cpu_dBus_cmd_rData_address;
    reg  [31:0] toplevel_axi_core_cpu_dBus_cmd_rData_data;
    reg  [ 3:0] toplevel_axi_core_cpu_dBus_cmd_rData_mask;
    reg  [ 2:0] toplevel_axi_core_cpu_dBus_cmd_rData_size;
    reg         toplevel_axi_core_cpu_dBus_cmd_rData_last;
    wire        when_Stream_l375;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_valid;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_ready;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_wr;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_uncached;
    wire [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_address;
    wire [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_data;
    wire [ 3:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_mask;
    wire [ 2:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_size;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_last;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rValid;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_wr;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_uncached;
    reg  [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_address;
    reg  [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_data;
    reg  [ 3:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_mask;
    reg  [ 2:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_size;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_last;
    wire        when_Stream_l375_1;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_valid;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_wr;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_uncached;
    wire [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_address;
    wire [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_data;
    wire [ 3:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_mask;
    wire [ 2:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_size;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_last;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_wr;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_uncached;
    reg  [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_address;
    reg  [31:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_data;
    reg  [ 3:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_mask;
    reg  [ 2:0] toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_size;
    reg         toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_last;
    wire        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_fire;
    wire        when_Utils_l706;
    wire        dbus_axi_b_fire;
    reg         _zz_when_Utils_l735;
    reg         _zz_when_Utils_l735_1;
    reg  [ 2:0] _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready;
    reg  [ 2:0] _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_1;
    wire        when_Utils_l735;
    wire        when_Utils_l737;
    wire        _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_2;
    wire        _zz_dbus_axi_arw_valid;
    reg         _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_3;
    wire        _zz_dbus_axi_arw_payload_write;
    wire        _zz_dbus_axi_w_payload_last;
    wire        _zz_dbus_axi_arw_valid_1;
    reg         _zz_when_Stream_l1063;
    wire        _zz_dbus_axi_w_valid;
    reg         _zz_when_Stream_l1063_1;
    reg         _zz_when_Stream_l1063_2;
    reg         _zz_when_Stream_l1063_3;
    wire        when_Stream_l1063;
    wire        when_Stream_l1063_1;
    wire        _zz_1;
    reg         _zz_2;
    reg         _zz_dbus_axi_arw_valid_2;
    wire        when_Stream_l445;
    reg         _zz_dbus_axi_w_valid_1;
    reg         toplevel_axi_core_cpu_debug_resetOut_regNext;
    wire        toplevel_axi_core_cpu_debug_bus_cmd_fire;
    reg         toplevel_axi_core_cpu_debug_bus_cmd_fire_regNext;
    wire        toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_valid;
    wire        toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_ready;
    wire [31:0] toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_addr;
    wire [ 7:0] toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_len;
    wire [ 1:0] toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_burst;
    wire [ 3:0] toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_cache;
    wire [ 2:0] toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_prot;
    reg         toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_rValid;
    wire        toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_fire;
    wire        toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_valid;
    wire        toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_ready;
    wire [31:0] toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_addr;
    wire [ 7:0] toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_len;
    wire [ 2:0] toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_size;
    wire [ 3:0] toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_cache;
    wire [ 2:0] toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_prot;
    wire        toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_write;
    reg         toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_rValid;
    wire        toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_fire;
    wire        toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_valid;
    wire        toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_ready;
    wire [31:0] toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_addr;
    wire [ 7:0] toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_len;
    wire [ 2:0] toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_size;
    wire [ 3:0] toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_cache;
    wire [ 2:0] toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_prot;
    wire        toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_write;
    reg         toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_rValid;
    wire        toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_fire;
    wire        toplevel_dbus_axi_decoder_io_input_r_m2sPipe_valid;
    wire        toplevel_dbus_axi_decoder_io_input_r_m2sPipe_ready;
    wire [31:0] toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_data;
    wire [ 1:0] toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_resp;
    wire        toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_last;
    reg         toplevel_dbus_axi_decoder_io_input_r_rValid;
    reg  [31:0] toplevel_dbus_axi_decoder_io_input_r_rData_data;
    reg  [ 1:0] toplevel_dbus_axi_decoder_io_input_r_rData_resp;
    reg         toplevel_dbus_axi_decoder_io_input_r_rData_last;
    wire        when_Stream_l375_2;
    wire [ 2:0] _zz_io_readInputs_0_ar_payload_id;
    wire [ 2:0] _zz_io_sharedInputs_0_arw_payload_id;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_valid;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_ready;
    wire [17:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_addr;
    wire [ 3:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_id;
    wire [ 7:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_len;
    wire [ 2:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_size;
    wire [ 1:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_burst;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_write;
    reg         toplevel_axi_ram_io_axi_arbiter_io_output_arw_rValid;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_fire;
    reg  [17:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_addr;
    reg  [ 3:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_id;
    reg  [ 7:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_len;
    reg  [ 2:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_size;
    reg  [ 1:0] toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_burst;
    reg         toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_write;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_valid;
    reg         toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_ready;
    wire [31:0] toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_data;
    wire [ 3:0] toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_strb;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_last;
    reg         toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN;
    reg  [31:0] toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_data;
    reg  [ 3:0] toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_strb;
    reg         toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_last;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_valid;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_ready;
    wire [31:0] toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_data;
    wire [ 3:0] toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_strb;
    wire        toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_last;
    reg         toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rValid;
    reg  [31:0] toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_data;
    reg  [ 3:0] toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_strb;
    reg         toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_last;
    wire        when_Stream_l375_3;
    wire [ 3:0] _zz_io_sharedInputs_0_arw_payload_id_1;
    wire        toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_valid;
    wire        toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_ready;
    wire [19:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_addr;
    wire [ 3:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_id;
    wire [ 7:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_len;
    wire [ 2:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_size;
    wire [ 1:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_burst;
    wire        toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_write;
    reg         toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rValid;
    wire        toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_fire;
    reg  [19:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_addr;
    reg  [ 3:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_id;
    reg  [ 7:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_len;
    reg  [ 2:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_size;
    reg  [ 1:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_burst;
    reg         toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_write;
    wire        toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_valid;
    wire        toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_ready;
    wire [31:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_data;
    wire [ 3:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_strb;
    wire        toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_last;
    reg         toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rValid;
    wire        toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_fire;
    reg  [31:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_data;
    reg  [ 3:0] toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_strb;
    reg         toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_last;

    assign _zz_dbus_axi_arw_payload_len = ((toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_size == 3'b101) ? 3'b111:3'b000);
    (* keep_hierarchy = "TRUE" *) BufferCC io_asyncReset_buffercc (
        .io_dataIn (io_asyncReset),                      //i
        .io_dataOut(io_asyncReset_buffercc_io_dataOut),  //o
        .io_axiClk (io_axiClk)                           //i
    );
    AXI4RAM AXI4RAM (
        .io_axi_arw_valid(toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_valid),  //i
        .io_axi_arw_ready(axi_ram_io_axi_arw_ready),  //o
        .io_axi_arw_payload_addr(toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_addr[17:0]), //i
        .io_axi_arw_payload_id(toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_id[3:0]), //i
        .io_axi_arw_payload_len(toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_len[7:0]), //i
        .io_axi_arw_payload_size(toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_size[2:0]), //i
        .io_axi_arw_payload_burst(toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_burst[1:0]), //i
        .io_axi_arw_payload_write(toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_write), //i
        .io_axi_w_valid(toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_valid),  //i
        .io_axi_w_ready(axi_ram_io_axi_w_ready),  //o
        .io_axi_w_payload_data(toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_data[31:0]), //i
        .io_axi_w_payload_strb(toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_strb[3:0] ), //i
        .io_axi_w_payload_last(toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_last), //i
        .io_axi_b_valid(axi_ram_io_axi_b_valid),  //o
        .io_axi_b_ready(axi_ram_io_axi_arbiter_io_output_b_ready),  //i
        .io_axi_b_payload_id(axi_ram_io_axi_b_payload_id[3:0]),  //o
        .io_axi_b_payload_resp(axi_ram_io_axi_b_payload_resp[1:0]),  //o
        .io_axi_r_valid(axi_ram_io_axi_r_valid),  //o
        .io_axi_r_ready(axi_ram_io_axi_arbiter_io_output_r_ready),  //i
        .io_axi_r_payload_data(axi_ram_io_axi_r_payload_data[31:0]),  //o
        .io_axi_r_payload_id(axi_ram_io_axi_r_payload_id[3:0]),  //o
        .io_axi_r_payload_resp(axi_ram_io_axi_r_payload_resp[1:0]),  //o
        .io_axi_r_payload_last(axi_ram_io_axi_r_payload_last),  //o
        .io_axiClk(io_axiClk),  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)  //i
    );
    Axi4SharedToApb3Bridge axi_apbBridge (
        .io_axi_arw_valid(toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_valid),  //i
        .io_axi_arw_ready(axi_apbBridge_io_axi_arw_ready),  //o
        .io_axi_arw_payload_addr  (toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_addr[19:0]), //i
        .io_axi_arw_payload_id    (toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_id[3:0]   ), //i
        .io_axi_arw_payload_len   (toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_len[7:0]  ), //i
        .io_axi_arw_payload_size  (toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_size[2:0] ), //i
        .io_axi_arw_payload_burst (toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_burst[1:0]), //i
        .io_axi_arw_payload_write (toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_write     ), //i
        .io_axi_w_valid(toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_valid),  //i
        .io_axi_w_ready(axi_apbBridge_io_axi_w_ready),  //o
        .io_axi_w_payload_data    (toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_data[31:0]  ), //i
        .io_axi_w_payload_strb    (toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_strb[3:0]   ), //i
        .io_axi_w_payload_last    (toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_last        ), //i
        .io_axi_b_valid(axi_apbBridge_io_axi_b_valid),  //o
        .io_axi_b_ready(axi_apbBridge_io_axi_arbiter_io_output_b_ready),  //i
        .io_axi_b_payload_id(axi_apbBridge_io_axi_b_payload_id[3:0]),  //o
        .io_axi_b_payload_resp(axi_apbBridge_io_axi_b_payload_resp[1:0]),  //o
        .io_axi_r_valid(axi_apbBridge_io_axi_r_valid),  //o
        .io_axi_r_ready(axi_apbBridge_io_axi_arbiter_io_output_r_ready),  //i
        .io_axi_r_payload_data(axi_apbBridge_io_axi_r_payload_data[31:0]),  //o
        .io_axi_r_payload_id(axi_apbBridge_io_axi_r_payload_id[3:0]),  //o
        .io_axi_r_payload_resp(axi_apbBridge_io_axi_r_payload_resp[1:0]),  //o
        .io_axi_r_payload_last(axi_apbBridge_io_axi_r_payload_last),  //o
        .io_apb_PADDR(axi_apbBridge_io_apb_PADDR[19:0]),  //o
        .io_apb_PSEL(axi_apbBridge_io_apb_PSEL),  //o
        .io_apb_PENABLE(axi_apbBridge_io_apb_PENABLE),  //o
        .io_apb_PREADY(io_apb_decoder_io_input_PREADY),  //i
        .io_apb_PWRITE(axi_apbBridge_io_apb_PWRITE),  //o
        .io_apb_PWDATA(axi_apbBridge_io_apb_PWDATA[31:0]),  //o
        .io_apb_PRDATA(io_apb_decoder_io_input_PRDATA[31:0]),  //i
        .io_apb_PSLVERROR(io_apb_decoder_io_input_PSLVERROR),  //i
        .io_axiClk(io_axiClk),  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)  //i
    );
    VexRiscv VexRiscv (
        .dBus_cmd_valid               (axi_core_cpu_dBus_cmd_valid),                          //o
        .dBus_cmd_ready               (axi_core_cpu_dBus_cmd_ready),                          //i
        .dBus_cmd_payload_wr          (axi_core_cpu_dBus_cmd_payload_wr),                     //o
        .dBus_cmd_payload_uncached    (axi_core_cpu_dBus_cmd_payload_uncached),               //o
        .dBus_cmd_payload_address     (axi_core_cpu_dBus_cmd_payload_address[31:0]),          //o
        .dBus_cmd_payload_data        (axi_core_cpu_dBus_cmd_payload_data[31:0]),             //o
        .dBus_cmd_payload_mask        (axi_core_cpu_dBus_cmd_payload_mask[3:0]),              //o
        .dBus_cmd_payload_size        (axi_core_cpu_dBus_cmd_payload_size[2:0]),              //o
        .dBus_cmd_payload_last        (axi_core_cpu_dBus_cmd_payload_last),                   //o
        .dBus_rsp_valid               (dbus_axi_r_valid),                                     //i
        .dBus_rsp_payload_last        (axi_core_cpu_dBus_rsp_payload_last),                   //i
        .dBus_rsp_payload_data        (dbus_axi_r_payload_data[31:0]),                        //i
        .dBus_rsp_payload_error       (axi_core_cpu_dBus_rsp_payload_error),                  //i
        .timerInterrupt               (system_timerInterrupt),                                //i
        .externalInterrupt            (system_externalInterrupt),                             //i
        .softwareInterrupt            (1'b0),                                                 //i
        .debug_bus_cmd_valid          (systemDebugger_1_io_mem_cmd_valid),                    //i
        .debug_bus_cmd_ready          (axi_core_cpu_debug_bus_cmd_ready),                     //o
        .debug_bus_cmd_payload_wr     (systemDebugger_1_io_mem_cmd_payload_wr),               //i
        .debug_bus_cmd_payload_address(axi_core_cpu_debug_bus_cmd_payload_address[7:0]),      //i
        .debug_bus_cmd_payload_data   (systemDebugger_1_io_mem_cmd_payload_data[31:0]),       //i
        .debug_bus_rsp_data           (axi_core_cpu_debug_bus_rsp_data[31:0]),                //o
        .debug_resetOut               (axi_core_cpu_debug_resetOut),                          //o
        .iBus_cmd_valid               (axi_core_cpu_iBus_cmd_valid),                          //o
        .iBus_cmd_ready               (axi4ReadOnlyDecoder_1_io_input_ar_ready),              //i
        .iBus_cmd_payload_address     (axi_core_cpu_iBus_cmd_payload_address[31:0]),          //o
        .iBus_cmd_payload_size        (axi_core_cpu_iBus_cmd_payload_size[2:0]),              //o
        .iBus_rsp_valid               (axi4ReadOnlyDecoder_1_io_input_r_valid),               //i
        .iBus_rsp_payload_data        (axi4ReadOnlyDecoder_1_io_input_r_payload_data[31:0]),  //i
        .iBus_rsp_payload_error       (axi_core_cpu_iBus_rsp_payload_error),                  //i
        .io_axiClk                    (io_axiClk),                                            //i
        .resetCtrl_axiReset           (resetCtrl_axiReset),                                   //i
        .resetCtrl_systemReset        (resetCtrl_systemReset)                                 //i
    );
    (* keep_hierarchy = "TRUE" *) BufferCC_1 io_coreInterrupt_buffercc (
        .io_dataIn         (io_coreInterrupt),                      //i
        .io_dataOut        (io_coreInterrupt_buffercc_io_dataOut),  //o
        .io_axiClk         (io_axiClk),                             //i
        .resetCtrl_axiReset(resetCtrl_axiReset)                     //i
    );
    JtagBridge JtagBridge (
        .io_jtag_tms                   (io_jtag_tms),                                        //i
        .io_jtag_tdi                   (io_jtag_tdi),                                        //i
        .io_jtag_tdo                   (jtagBridge_1_io_jtag_tdo),                           //o
        .io_jtag_tck                   (io_jtag_tck),                                        //i
        .io_remote_cmd_valid           (jtagBridge_1_io_remote_cmd_valid),                   //o
        .io_remote_cmd_ready           (systemDebugger_1_io_remote_cmd_ready),               //i
        .io_remote_cmd_payload_last    (jtagBridge_1_io_remote_cmd_payload_last),            //o
        .io_remote_cmd_payload_fragment(jtagBridge_1_io_remote_cmd_payload_fragment),        //o
        .io_remote_rsp_valid           (systemDebugger_1_io_remote_rsp_valid),               //i
        .io_remote_rsp_ready           (jtagBridge_1_io_remote_rsp_ready),                   //o
        .io_remote_rsp_payload_error   (systemDebugger_1_io_remote_rsp_payload_error),       //i
        .io_remote_rsp_payload_data    (systemDebugger_1_io_remote_rsp_payload_data[31:0]),  //i
        .io_axiClk                     (io_axiClk),                                          //i
        .resetCtrl_systemReset         (resetCtrl_systemReset)                               //i
    );
    SystemDebugger SystemDebugger (
        .io_remote_cmd_valid           (jtagBridge_1_io_remote_cmd_valid),                   //i
        .io_remote_cmd_ready           (systemDebugger_1_io_remote_cmd_ready),               //o
        .io_remote_cmd_payload_last    (jtagBridge_1_io_remote_cmd_payload_last),            //i
        .io_remote_cmd_payload_fragment(jtagBridge_1_io_remote_cmd_payload_fragment),        //i
        .io_remote_rsp_valid           (systemDebugger_1_io_remote_rsp_valid),               //o
        .io_remote_rsp_ready           (jtagBridge_1_io_remote_rsp_ready),                   //i
        .io_remote_rsp_payload_error   (systemDebugger_1_io_remote_rsp_payload_error),       //o
        .io_remote_rsp_payload_data    (systemDebugger_1_io_remote_rsp_payload_data[31:0]),  //o
        .io_mem_cmd_valid              (systemDebugger_1_io_mem_cmd_valid),                  //o
        .io_mem_cmd_ready              (axi_core_cpu_debug_bus_cmd_ready),                   //i
        .io_mem_cmd_payload_address    (systemDebugger_1_io_mem_cmd_payload_address[31:0]),  //o
        .io_mem_cmd_payload_data       (systemDebugger_1_io_mem_cmd_payload_data[31:0]),     //o
        .io_mem_cmd_payload_wr         (systemDebugger_1_io_mem_cmd_payload_wr),             //o
        .io_mem_cmd_payload_size       (systemDebugger_1_io_mem_cmd_payload_size[1:0]),      //o
        .io_mem_rsp_valid              (toplevel_axi_core_cpu_debug_bus_cmd_fire_regNext),   //i
        .io_mem_rsp_payload            (axi_core_cpu_debug_bus_rsp_data[31:0]),              //i
        .io_axiClk                     (io_axiClk),                                          //i
        .resetCtrl_systemReset         (resetCtrl_systemReset)                               //i
    );
    Axi4ReadOnlyDecoder axi4ReadOnlyDecoder (
        .io_input_ar_valid(axi_core_cpu_iBus_cmd_valid),  //i
        .io_input_ar_ready(axi4ReadOnlyDecoder_1_io_input_ar_ready),  //o
        .io_input_ar_payload_addr(axi_core_cpu_iBus_cmd_payload_address[31:0]),  //i
        .io_input_ar_payload_len(8'h07),  //i
        .io_input_ar_payload_burst(2'b01),  //i
        .io_input_ar_payload_cache(4'b1111),  //i
        .io_input_ar_payload_prot(3'b110),  //i
        .io_input_r_valid(axi4ReadOnlyDecoder_1_io_input_r_valid),  //o
        .io_input_r_ready(1'b1),  //i
        .io_input_r_payload_data(axi4ReadOnlyDecoder_1_io_input_r_payload_data[31:0]),  //o
        .io_input_r_payload_resp(axi4ReadOnlyDecoder_1_io_input_r_payload_resp[1:0]),  //o
        .io_input_r_payload_last(axi4ReadOnlyDecoder_1_io_input_r_payload_last),  //o
        .io_outputs_0_ar_valid(axi4ReadOnlyDecoder_1_io_outputs_0_ar_valid),  //o
        .io_outputs_0_ar_ready(toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_fire),  //i
        .io_outputs_0_ar_payload_addr(axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_addr[31:0]     ), //o
        .io_outputs_0_ar_payload_len(axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_len[7:0]),  //o
        .io_outputs_0_ar_payload_burst(axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_burst[1:0]     ), //o
        .io_outputs_0_ar_payload_cache(axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_cache[3:0]     ), //o
        .io_outputs_0_ar_payload_prot(axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_prot[2:0]),  //o
        .io_outputs_0_r_valid(axi_ram_io_axi_arbiter_io_readInputs_0_r_valid),  //i
        .io_outputs_0_r_ready(axi4ReadOnlyDecoder_1_io_outputs_0_r_ready),  //o
        .io_outputs_0_r_payload_data(axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_data[31:0]  ), //i
        .io_outputs_0_r_payload_resp(axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_resp[1:0]   ), //i
        .io_outputs_0_r_payload_last(axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_last),  //i
        .io_axiClk(io_axiClk),  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)  //i
    );
    Axi4SharedDecoder dbus_axi_decoder (
        .io_input_arw_valid(dbus_axi_arw_valid),  //i
        .io_input_arw_ready(dbus_axi_decoder_io_input_arw_ready),  //o
        .io_input_arw_payload_addr(dbus_axi_arw_payload_addr[31:0]),  //i
        .io_input_arw_payload_len(dbus_axi_arw_payload_len[7:0]),  //i
        .io_input_arw_payload_size(dbus_axi_arw_payload_size[2:0]),  //i
        .io_input_arw_payload_cache(dbus_axi_arw_payload_cache[3:0]),  //i
        .io_input_arw_payload_prot(dbus_axi_arw_payload_prot[2:0]),  //i
        .io_input_arw_payload_write(dbus_axi_arw_payload_write),  //i
        .io_input_w_valid(dbus_axi_w_valid),  //i
        .io_input_w_ready(dbus_axi_decoder_io_input_w_ready),  //o
        .io_input_w_payload_data(dbus_axi_w_payload_data[31:0]),  //i
        .io_input_w_payload_strb(dbus_axi_w_payload_strb[3:0]),  //i
        .io_input_w_payload_last(dbus_axi_w_payload_last),  //i
        .io_input_b_valid(dbus_axi_decoder_io_input_b_valid),  //o
        .io_input_b_ready(dbus_axi_b_ready),  //i
        .io_input_b_payload_resp(dbus_axi_decoder_io_input_b_payload_resp[1:0]),  //o
        .io_input_r_valid(dbus_axi_decoder_io_input_r_valid),  //o
        .io_input_r_ready(dbus_axi_decoder_io_input_r_ready),  //i
        .io_input_r_payload_data(dbus_axi_decoder_io_input_r_payload_data[31:0]),  //o
        .io_input_r_payload_resp(dbus_axi_decoder_io_input_r_payload_resp[1:0]),  //o
        .io_input_r_payload_last(dbus_axi_decoder_io_input_r_payload_last),  //o
        .io_sharedOutputs_0_arw_valid(dbus_axi_decoder_io_sharedOutputs_0_arw_valid),  //o
        .io_sharedOutputs_0_arw_ready(toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_fire    ), //i
        .io_sharedOutputs_0_arw_payload_addr(dbus_axi_decoder_io_sharedOutputs_0_arw_payload_addr[31:0]         ), //o
        .io_sharedOutputs_0_arw_payload_len(dbus_axi_decoder_io_sharedOutputs_0_arw_payload_len[7:0]           ), //o
        .io_sharedOutputs_0_arw_payload_size(dbus_axi_decoder_io_sharedOutputs_0_arw_payload_size[2:0]          ), //o
        .io_sharedOutputs_0_arw_payload_cache(dbus_axi_decoder_io_sharedOutputs_0_arw_payload_cache[3:0]         ), //o
        .io_sharedOutputs_0_arw_payload_prot(dbus_axi_decoder_io_sharedOutputs_0_arw_payload_prot[2:0]          ), //o
        .io_sharedOutputs_0_arw_payload_write(dbus_axi_decoder_io_sharedOutputs_0_arw_payload_write              ), //o
        .io_sharedOutputs_0_w_valid(dbus_axi_decoder_io_sharedOutputs_0_w_valid),  //o
        .io_sharedOutputs_0_w_ready(axi_ram_io_axi_arbiter_io_sharedInputs_0_w_ready),  //i
        .io_sharedOutputs_0_w_payload_data(dbus_axi_decoder_io_sharedOutputs_0_w_payload_data[31:0]           ), //o
        .io_sharedOutputs_0_w_payload_strb(dbus_axi_decoder_io_sharedOutputs_0_w_payload_strb[3:0]            ), //o
        .io_sharedOutputs_0_w_payload_last(dbus_axi_decoder_io_sharedOutputs_0_w_payload_last),  //o
        .io_sharedOutputs_0_b_valid(axi_ram_io_axi_arbiter_io_sharedInputs_0_b_valid),  //i
        .io_sharedOutputs_0_b_ready(dbus_axi_decoder_io_sharedOutputs_0_b_ready),  //o
        .io_sharedOutputs_0_b_payload_resp(axi_ram_io_axi_arbiter_io_sharedInputs_0_b_payload_resp[1:0]       ), //i
        .io_sharedOutputs_0_r_valid(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_valid),  //i
        .io_sharedOutputs_0_r_ready(dbus_axi_decoder_io_sharedOutputs_0_r_ready),  //o
        .io_sharedOutputs_0_r_payload_data(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_data[31:0]      ), //i
        .io_sharedOutputs_0_r_payload_resp(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_resp[1:0]       ), //i
        .io_sharedOutputs_0_r_payload_last(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_last            ), //i
        .io_sharedOutputs_1_arw_valid(dbus_axi_decoder_io_sharedOutputs_1_arw_valid),  //o
        .io_sharedOutputs_1_arw_ready(toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_fire    ), //i
        .io_sharedOutputs_1_arw_payload_addr(dbus_axi_decoder_io_sharedOutputs_1_arw_payload_addr[31:0]         ), //o
        .io_sharedOutputs_1_arw_payload_len(dbus_axi_decoder_io_sharedOutputs_1_arw_payload_len[7:0]           ), //o
        .io_sharedOutputs_1_arw_payload_size(dbus_axi_decoder_io_sharedOutputs_1_arw_payload_size[2:0]          ), //o
        .io_sharedOutputs_1_arw_payload_cache(dbus_axi_decoder_io_sharedOutputs_1_arw_payload_cache[3:0]         ), //o
        .io_sharedOutputs_1_arw_payload_prot(dbus_axi_decoder_io_sharedOutputs_1_arw_payload_prot[2:0]          ), //o
        .io_sharedOutputs_1_arw_payload_write(dbus_axi_decoder_io_sharedOutputs_1_arw_payload_write              ), //o
        .io_sharedOutputs_1_w_valid(dbus_axi_decoder_io_sharedOutputs_1_w_valid),  //o
        .io_sharedOutputs_1_w_ready(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_w_ready),  //i
        .io_sharedOutputs_1_w_payload_data(dbus_axi_decoder_io_sharedOutputs_1_w_payload_data[31:0]           ), //o
        .io_sharedOutputs_1_w_payload_strb(dbus_axi_decoder_io_sharedOutputs_1_w_payload_strb[3:0]            ), //o
        .io_sharedOutputs_1_w_payload_last(dbus_axi_decoder_io_sharedOutputs_1_w_payload_last),  //o
        .io_sharedOutputs_1_b_valid(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_valid),  //i
        .io_sharedOutputs_1_b_ready(dbus_axi_decoder_io_sharedOutputs_1_b_ready),  //o
        .io_sharedOutputs_1_b_payload_resp(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_resp[1:0] ), //i
        .io_sharedOutputs_1_r_valid(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_valid),  //i
        .io_sharedOutputs_1_r_ready(dbus_axi_decoder_io_sharedOutputs_1_r_ready),  //o
        .io_sharedOutputs_1_r_payload_data(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_data[31:0]), //i
        .io_sharedOutputs_1_r_payload_resp(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_resp[1:0] ), //i
        .io_sharedOutputs_1_r_payload_last(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_last      ), //i
        .io_axiClk(io_axiClk),  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)  //i
    );
    Axi4SharedArbiter axi_ram_io_axi_arbiter (
        .io_readInputs_0_ar_valid(toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_valid              ), //i
        .io_readInputs_0_ar_ready(axi_ram_io_axi_arbiter_io_readInputs_0_ar_ready),  //o
        .io_readInputs_0_ar_payload_addr(axi_ram_io_axi_arbiter_io_readInputs_0_ar_payload_addr[17:0]                ), //i
        .io_readInputs_0_ar_payload_id(_zz_io_readInputs_0_ar_payload_id[2:0]),  //i
        .io_readInputs_0_ar_payload_len(toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_len[7:0]   ), //i
        .io_readInputs_0_ar_payload_size(3'b010),  //i
        .io_readInputs_0_ar_payload_burst(toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_burst[1:0] ), //i
        .io_readInputs_0_r_valid(axi_ram_io_axi_arbiter_io_readInputs_0_r_valid),  //o
        .io_readInputs_0_r_ready(axi4ReadOnlyDecoder_1_io_outputs_0_r_ready),  //i
        .io_readInputs_0_r_payload_data(axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_data[31:0]                 ), //o
        .io_readInputs_0_r_payload_id(axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_id[2:0]                    ), //o
        .io_readInputs_0_r_payload_resp(axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_resp[1:0]                  ), //o
        .io_readInputs_0_r_payload_last(axi_ram_io_axi_arbiter_io_readInputs_0_r_payload_last),  //o
        .io_sharedInputs_0_arw_valid(toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_valid            ), //i
        .io_sharedInputs_0_arw_ready(axi_ram_io_axi_arbiter_io_sharedInputs_0_arw_ready),  //o
        .io_sharedInputs_0_arw_payload_addr(axi_ram_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr[17:0]             ), //i
        .io_sharedInputs_0_arw_payload_id(_zz_io_sharedInputs_0_arw_payload_id[2:0]),  //i
        .io_sharedInputs_0_arw_payload_len(toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_len[7:0] ), //i
        .io_sharedInputs_0_arw_payload_size(toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_size[2:0]), //i
        .io_sharedInputs_0_arw_payload_burst(2'b01),  //i
        .io_sharedInputs_0_arw_payload_write (toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_write    ), //i
        .io_sharedInputs_0_w_valid(dbus_axi_decoder_io_sharedOutputs_0_w_valid),  //i
        .io_sharedInputs_0_w_ready(axi_ram_io_axi_arbiter_io_sharedInputs_0_w_ready),  //o
        .io_sharedInputs_0_w_payload_data(dbus_axi_decoder_io_sharedOutputs_0_w_payload_data[31:0]                    ), //i
        .io_sharedInputs_0_w_payload_strb(dbus_axi_decoder_io_sharedOutputs_0_w_payload_strb[3:0]                     ), //i
        .io_sharedInputs_0_w_payload_last(dbus_axi_decoder_io_sharedOutputs_0_w_payload_last),  //i
        .io_sharedInputs_0_b_valid(axi_ram_io_axi_arbiter_io_sharedInputs_0_b_valid),  //o
        .io_sharedInputs_0_b_ready(dbus_axi_decoder_io_sharedOutputs_0_b_ready),  //i
        .io_sharedInputs_0_b_payload_id(axi_ram_io_axi_arbiter_io_sharedInputs_0_b_payload_id[2:0]                  ), //o
        .io_sharedInputs_0_b_payload_resp(axi_ram_io_axi_arbiter_io_sharedInputs_0_b_payload_resp[1:0]                ), //o
        .io_sharedInputs_0_r_valid(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_valid),  //o
        .io_sharedInputs_0_r_ready(dbus_axi_decoder_io_sharedOutputs_0_r_ready),  //i
        .io_sharedInputs_0_r_payload_data(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_data[31:0]               ), //o
        .io_sharedInputs_0_r_payload_id(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_id[2:0]                  ), //o
        .io_sharedInputs_0_r_payload_resp(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_resp[1:0]                ), //o
        .io_sharedInputs_0_r_payload_last(axi_ram_io_axi_arbiter_io_sharedInputs_0_r_payload_last                     ), //o
        .io_output_arw_valid(axi_ram_io_axi_arbiter_io_output_arw_valid),  //o
        .io_output_arw_ready(axi_ram_io_axi_arbiter_io_output_arw_ready),  //i
        .io_output_arw_payload_addr(axi_ram_io_axi_arbiter_io_output_arw_payload_addr[17:0]),  //o
        .io_output_arw_payload_id(axi_ram_io_axi_arbiter_io_output_arw_payload_id[3:0]),  //o
        .io_output_arw_payload_len(axi_ram_io_axi_arbiter_io_output_arw_payload_len[7:0]),  //o
        .io_output_arw_payload_size(axi_ram_io_axi_arbiter_io_output_arw_payload_size[2:0]),  //o
        .io_output_arw_payload_burst(axi_ram_io_axi_arbiter_io_output_arw_payload_burst[1:0]),  //o
        .io_output_arw_payload_write(axi_ram_io_axi_arbiter_io_output_arw_payload_write),  //o
        .io_output_w_valid(axi_ram_io_axi_arbiter_io_output_w_valid),  //o
        .io_output_w_ready(toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN),  //i
        .io_output_w_payload_data(axi_ram_io_axi_arbiter_io_output_w_payload_data[31:0]),  //o
        .io_output_w_payload_strb(axi_ram_io_axi_arbiter_io_output_w_payload_strb[3:0]),  //o
        .io_output_w_payload_last(axi_ram_io_axi_arbiter_io_output_w_payload_last),  //o
        .io_output_b_valid(axi_ram_io_axi_b_valid),  //i
        .io_output_b_ready(axi_ram_io_axi_arbiter_io_output_b_ready),  //o
        .io_output_b_payload_id(axi_ram_io_axi_b_payload_id[3:0]),  //i
        .io_output_b_payload_resp(axi_ram_io_axi_b_payload_resp[1:0]),  //i
        .io_output_r_valid(axi_ram_io_axi_r_valid),  //i
        .io_output_r_ready(axi_ram_io_axi_arbiter_io_output_r_ready),  //o
        .io_output_r_payload_data(axi_ram_io_axi_r_payload_data[31:0]),  //i
        .io_output_r_payload_id(axi_ram_io_axi_r_payload_id[3:0]),  //i
        .io_output_r_payload_resp(axi_ram_io_axi_r_payload_resp[1:0]),  //i
        .io_output_r_payload_last(axi_ram_io_axi_r_payload_last),  //i
        .io_axiClk(io_axiClk),  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)  //i
    );
    Axi4SharedArbiter_1 axi_apbBridge_io_axi_arbiter (
        .io_sharedInputs_0_arw_valid(toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_valid            ), //i
        .io_sharedInputs_0_arw_ready(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_ready),  //o
        .io_sharedInputs_0_arw_payload_addr(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr[19:0]       ), //i
        .io_sharedInputs_0_arw_payload_id(_zz_io_sharedInputs_0_arw_payload_id_1[3:0]),  //i
        .io_sharedInputs_0_arw_payload_len(toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_len[7:0] ), //i
        .io_sharedInputs_0_arw_payload_size(toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_size[2:0]), //i
        .io_sharedInputs_0_arw_payload_burst(2'b01),  //i
        .io_sharedInputs_0_arw_payload_write(toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_write    ), //i
        .io_sharedInputs_0_w_valid(dbus_axi_decoder_io_sharedOutputs_1_w_valid),  //i
        .io_sharedInputs_0_w_ready(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_w_ready),  //o
        .io_sharedInputs_0_w_payload_data(dbus_axi_decoder_io_sharedOutputs_1_w_payload_data[31:0]                    ), //i
        .io_sharedInputs_0_w_payload_strb(dbus_axi_decoder_io_sharedOutputs_1_w_payload_strb[3:0]                     ), //i
        .io_sharedInputs_0_w_payload_last(dbus_axi_decoder_io_sharedOutputs_1_w_payload_last),  //i
        .io_sharedInputs_0_b_valid(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_valid),  //o
        .io_sharedInputs_0_b_ready(dbus_axi_decoder_io_sharedOutputs_1_b_ready),  //i
        .io_sharedInputs_0_b_payload_id(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_id[3:0]            ), //o
        .io_sharedInputs_0_b_payload_resp(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_b_payload_resp[1:0]          ), //o
        .io_sharedInputs_0_r_valid(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_valid),  //o
        .io_sharedInputs_0_r_ready(dbus_axi_decoder_io_sharedOutputs_1_r_ready),  //i
        .io_sharedInputs_0_r_payload_data(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_data[31:0]         ), //o
        .io_sharedInputs_0_r_payload_id(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_id[3:0]            ), //o
        .io_sharedInputs_0_r_payload_resp(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_resp[1:0]          ), //o
        .io_sharedInputs_0_r_payload_last(axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_r_payload_last               ), //o
        .io_output_arw_valid(axi_apbBridge_io_axi_arbiter_io_output_arw_valid),  //o
        .io_output_arw_ready(axi_apbBridge_io_axi_arbiter_io_output_arw_ready),  //i
        .io_output_arw_payload_addr(axi_apbBridge_io_axi_arbiter_io_output_arw_payload_addr[19:0]               ), //o
        .io_output_arw_payload_id(axi_apbBridge_io_axi_arbiter_io_output_arw_payload_id[3:0]),  //o
        .io_output_arw_payload_len(axi_apbBridge_io_axi_arbiter_io_output_arw_payload_len[7:0]                 ), //o
        .io_output_arw_payload_size(axi_apbBridge_io_axi_arbiter_io_output_arw_payload_size[2:0]                ), //o
        .io_output_arw_payload_burst(axi_apbBridge_io_axi_arbiter_io_output_arw_payload_burst[1:0]               ), //o
        .io_output_arw_payload_write(axi_apbBridge_io_axi_arbiter_io_output_arw_payload_write),  //o
        .io_output_w_valid(axi_apbBridge_io_axi_arbiter_io_output_w_valid),  //o
        .io_output_w_ready(axi_apbBridge_io_axi_arbiter_io_output_w_ready),  //i
        .io_output_w_payload_data(axi_apbBridge_io_axi_arbiter_io_output_w_payload_data[31:0]),  //o
        .io_output_w_payload_strb(axi_apbBridge_io_axi_arbiter_io_output_w_payload_strb[3:0]),  //o
        .io_output_w_payload_last(axi_apbBridge_io_axi_arbiter_io_output_w_payload_last),  //o
        .io_output_b_valid(axi_apbBridge_io_axi_b_valid),  //i
        .io_output_b_ready(axi_apbBridge_io_axi_arbiter_io_output_b_ready),  //o
        .io_output_b_payload_id(axi_apbBridge_io_axi_b_payload_id[3:0]),  //i
        .io_output_b_payload_resp(axi_apbBridge_io_axi_b_payload_resp[1:0]),  //i
        .io_output_r_valid(axi_apbBridge_io_axi_r_valid),  //i
        .io_output_r_ready(axi_apbBridge_io_axi_arbiter_io_output_r_ready),  //o
        .io_output_r_payload_data(axi_apbBridge_io_axi_r_payload_data[31:0]),  //i
        .io_output_r_payload_id(axi_apbBridge_io_axi_r_payload_id[3:0]),  //i
        .io_output_r_payload_resp(axi_apbBridge_io_axi_r_payload_resp[1:0]),  //i
        .io_output_r_payload_last(axi_apbBridge_io_axi_r_payload_last),  //i
        .io_axiClk(io_axiClk),  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)  //i
    );
    Apb3PRouter Apb3PRouter (
        .io_input_PADDR    (axi_apbBridge_io_apb_PADDR[19:0]),      //i
        .io_input_PSEL     (axi_apbBridge_io_apb_PSEL),             //i
        .io_input_PENABLE  (axi_apbBridge_io_apb_PENABLE),          //i
        .io_input_PREADY   (io_apb_decoder_io_input_PREADY),        //o
        .io_input_PWRITE   (axi_apbBridge_io_apb_PWRITE),           //i
        .io_input_PWDATA   (axi_apbBridge_io_apb_PWDATA[31:0]),     //i
        .io_input_PRDATA   (io_apb_decoder_io_input_PRDATA[31:0]),  //o
        .io_input_PSLVERROR(io_apb_decoder_io_input_PSLVERROR),     //o

        .io_outputs_0_PADDR    (apb3Router_1_io_outputs_0_PADDR[19:0]),   // o GPIO
        .io_outputs_0_PSEL     (apb3Router_1_io_outputs_0_PSEL),          // o GPIO
        .io_outputs_0_PENABLE  (apb3Router_1_io_outputs_0_PENABLE),       // o GPIO
        .io_outputs_0_PREADY   (system_gpioCtrl_io_apb_PREADY),           // i GPIO
        .io_outputs_0_PWRITE   (apb3Router_1_io_outputs_0_PWRITE),        // o GPIO
        .io_outputs_0_PWDATA   (apb3Router_1_io_outputs_0_PWDATA[31:0]),  // o GPIO
        .io_outputs_0_PRDATA   (system_gpioCtrl_io_apb_PRDATA[31:0]),     // i GPIO
        .io_outputs_0_PSLVERROR(system_gpioCtrl_io_apb_PSLVERROR),        // i GPIO
        .io_outputs_1_PADDR    (apb3Router_1_io_outputs_1_PADDR[19:0]),   // o WDG
        .io_outputs_1_PSEL     (apb3Router_1_io_outputs_1_PSEL),          // o WDG
        .io_outputs_1_PENABLE  (apb3Router_1_io_outputs_1_PENABLE),       // o WDG
        .io_outputs_1_PREADY   (system_wdgCtrl_io_apb_PREADY),            // i WDG
        .io_outputs_1_PWRITE   (apb3Router_1_io_outputs_1_PWRITE),        // o WDG
        .io_outputs_1_PWDATA   (apb3Router_1_io_outputs_1_PWDATA[31:0]),  // o WDG
        .io_outputs_1_PRDATA   (system_wdgCtrl_io_apb_PRDATA[31:0]),      // i WDG
        .io_outputs_1_PSLVERROR(system_wdgCtrl_io_apb_PSLVERROR),         // i WDG
        .io_outputs_2_PADDR    (apb3Router_1_io_outputs_2_PADDR[19:0]),   // o USART
        .io_outputs_2_PSEL     (apb3Router_1_io_outputs_2_PSEL),          // o USART
        .io_outputs_2_PENABLE  (apb3Router_1_io_outputs_2_PENABLE),       // o USART
        .io_outputs_2_PREADY   (system_usartCtrl_io_apb_PREADY),          // i USART
        .io_outputs_2_PWRITE   (apb3Router_1_io_outputs_2_PWRITE),        // o USART
        .io_outputs_2_PWDATA   (apb3Router_1_io_outputs_2_PWDATA[31:0]),  // o USART
        .io_outputs_2_PRDATA   (system_usartCtrl_io_apb_PRDATA[31:0]),    // i USART
        .io_outputs_2_PSLVERROR(system_usartCtrl_io_apb_PSLVERROR),       // i USART
        .io_outputs_3_PADDR    (apb3Router_1_io_outputs_3_PADDR[19:0]),   // o I2C
        .io_outputs_3_PSEL     (apb3Router_1_io_outputs_3_PSEL),          // o I2C
        .io_outputs_3_PENABLE  (apb3Router_1_io_outputs_3_PENABLE),       // o I2C
        .io_outputs_3_PREADY   (system_i2cCtrl_io_apb_PREADY),            // i I2C
        .io_outputs_3_PWRITE   (apb3Router_1_io_outputs_3_PWRITE),        // o I2C
        .io_outputs_3_PWDATA   (apb3Router_1_io_outputs_3_PWDATA[31:0]),  // o I2C
        .io_outputs_3_PRDATA   (system_i2cCtrl_io_apb_PRDATA[31:0]),      // i I2C
        .io_outputs_3_PSLVERROR(system_i2cCtrl_io_apb_PSLVERROR),         // i I2C
        .io_outputs_4_PADDR    (apb3Router_1_io_outputs_4_PADDR[19:0]),   // o SPI
        .io_outputs_4_PSEL     (apb3Router_1_io_outputs_4_PSEL),          // o SPI
        .io_outputs_4_PENABLE  (apb3Router_1_io_outputs_4_PENABLE),       // o SPI
        .io_outputs_4_PREADY   (system_spiCtrl_io_apb_PREADY),            // i SPI
        .io_outputs_4_PWRITE   (apb3Router_1_io_outputs_4_PWRITE),        // o SPI
        .io_outputs_4_PWDATA   (apb3Router_1_io_outputs_4_PWDATA[31:0]),  // o SPI
        .io_outputs_4_PRDATA   (system_spiCtrl_io_apb_PRDATA[31:0]),      // i SPI
        .io_outputs_4_PSLVERROR(system_spiCtrl_io_apb_PSLVERROR),         // i SPI
        .io_outputs_5_PADDR    (apb3Router_1_io_outputs_5_PADDR[19:0]),   // o TIM
        .io_outputs_5_PSEL     (apb3Router_1_io_outputs_5_PSEL),          // o TIM
        .io_outputs_5_PENABLE  (apb3Router_1_io_outputs_5_PENABLE),       // o TIM
        .io_outputs_5_PREADY   (system_timCtrl_io_apb_PREADY),            // i TIM
        .io_outputs_5_PWRITE   (apb3Router_1_io_outputs_5_PWRITE),        // o TIM
        .io_outputs_5_PWDATA   (apb3Router_1_io_outputs_5_PWDATA[31:0]),  // o TIM
        .io_outputs_5_PRDATA   (system_timCtrl_io_apb_PRDATA[31:0]),      // i TIM
        .io_outputs_5_PSLVERROR(system_timCtrl_io_apb_PSLVERROR),         // i TIM

        .io_axiClk            (io_axiClk),             // i
        .resetCtrl_systemReset(resetCtrl_systemReset)  // i
    );
    Apb3GPIORouter Apb3GPIORouter (
        .io_apb_PCLK     (io_axiClk),                          // i
        .io_apb_PRESET   (resetCtrl_systemReset),              // i
        .io_apb_PADDR    (system_gpioCtrl_io_apb_PADDR),       // i
        .io_apb_PSEL     (apb3Router_1_io_outputs_0_PSEL),     // i
        .io_apb_PENABLE  (apb3Router_1_io_outputs_0_PENABLE),  // i
        .io_apb_PREADY   (system_gpioCtrl_io_apb_PREADY),      // o
        .io_apb_PWRITE   (apb3Router_1_io_outputs_0_PWRITE),   // i
        .io_apb_PWDATA   (apb3Router_1_io_outputs_0_PWDATA),   // i
        .io_apb_PRDATA   (system_gpioCtrl_io_apb_PRDATA),      // o
        .io_apb_PSLVERROR(system_gpioCtrl_io_apb_PSLVERROR),   // o
        .AFIOA           (AFIOA),                              // i
        .GPIOA           (GPIOA),                              // io
        .AFIOB           (AFIOB),                              // i
        .GPIOB           (GPIOB)                               // io
    );
    Apb3WDGRouter Apb3WDGRouter (
        .io_apb_PCLK     (io_axiClk),                          // i
        .io_apb_PRESET   (resetCtrl_systemReset),              // i
        .io_apb_PADDR    (system_wdgCtrl_io_apb_PADDR),        // i
        .io_apb_PSEL     (apb3Router_1_io_outputs_1_PSEL),     // i
        .io_apb_PENABLE  (apb3Router_1_io_outputs_1_PENABLE),  // i
        .io_apb_PREADY   (system_wdgCtrl_io_apb_PREADY),       // o
        .io_apb_PWRITE   (apb3Router_1_io_outputs_1_PWRITE),   // i
        .io_apb_PWDATA   (apb3Router_1_io_outputs_1_PWDATA),   // i
        .io_apb_PRDATA   (system_wdgCtrl_io_apb_PRDATA),       // o
        .io_apb_PSLVERROR(system_wdgCtrl_io_apb_PSLVERROR),    // o
        .IWDG_rst        (),                                   // o
        .WWDG_rst        ()                                    // o
    );
    Apb3USARTRouter Apb3USARTRouter (
        .io_apb_PCLK     (io_axiClk),                          // i
        .io_apb_PRESET   (resetCtrl_systemReset),              // i
        .io_apb_PADDR    (system_usartCtrl_io_apb_PADDR),      // i
        .io_apb_PSEL     (apb3Router_1_io_outputs_2_PSEL),     // i
        .io_apb_PENABLE  (apb3Router_1_io_outputs_2_PENABLE),  // i
        .io_apb_PREADY   (system_usartCtrl_io_apb_PREADY),     // o
        .io_apb_PWRITE   (apb3Router_1_io_outputs_2_PWRITE),   // i
        .io_apb_PWDATA   (apb3Router_1_io_outputs_2_PWDATA),   // i
        .io_apb_PRDATA   (system_usartCtrl_io_apb_PRDATA),     // o
        .io_apb_PSLVERROR(system_usartCtrl_io_apb_PSLVERROR),  // o
        .USART1_RX       (USART1_RX),                          // i
        .USART1_TX       (USART1_TX),                          // o
        .USART1_interrupt(USART1_interrupt),                   // o  // USART interrupt
        .USART2_RX       (USART2_RX),                          // i
        .USART2_TX       (USART2_TX),                          // o
        .USART2_interrupt(USART2_interrupt)                    // o
    );
    Apb3I2CRouter Apb3I2CRouter (
        .io_apb_PCLK     (io_axiClk),                          // i
        .io_apb_PRESET   (resetCtrl_systemReset),              // i
        .io_apb_PADDR    (system_i2cCtrl_io_apb_PADDR),        // i
        .io_apb_PSEL     (apb3Router_1_io_outputs_3_PSEL),     // i
        .io_apb_PENABLE  (apb3Router_1_io_outputs_3_PENABLE),  // i
        .io_apb_PREADY   (system_i2cCtrl_io_apb_PREADY),       // o
        .io_apb_PWRITE   (apb3Router_1_io_outputs_3_PWRITE),   // i
        .io_apb_PWDATA   (apb3Router_1_io_outputs_3_PWDATA),   // i
        .io_apb_PRDATA   (system_i2cCtrl_io_apb_PRDATA),       // o
        .io_apb_PSLVERROR(system_i2cCtrl_io_apb_PSLVERROR),    // o
        .I2C1_SDA        (I2C1_SDA),                           // i
        .I2C1_SCL        (I2C1_SCL),                           // o
        .I2C1_interrupt  (),                                   // o  // SPI interrupt
        .I2C2_SDA        (I2C1_SDA),                           // i
        .I2C2_SCL        (I2C2_SCL),                           // o
        .I2C2_interrupt  ()                                    // o
    );
    Apb3SPIRouter Apb3SPIRouter (
        .io_apb_PCLK     (io_axiClk),                          // i
        .io_apb_PRESET   (resetCtrl_systemReset),              // i
        .io_apb_PADDR    (system_spiCtrl_io_apb_PADDR),        // i
        .io_apb_PSEL     (apb3Router_1_io_outputs_4_PSEL),     // i
        .io_apb_PENABLE  (apb3Router_1_io_outputs_4_PENABLE),  // i
        .io_apb_PREADY   (system_spiCtrl_io_apb_PREADY),       // o
        .io_apb_PWRITE   (apb3Router_1_io_outputs_4_PWRITE),   // i
        .io_apb_PWDATA   (apb3Router_1_io_outputs_4_PWDATA),   // i
        .io_apb_PRDATA   (system_spiCtrl_io_apb_PRDATA),       // o
        .io_apb_PSLVERROR(system_spiCtrl_io_apb_PSLVERROR),    // o
        .SPI1_SCK        (SPI1_SCK),                           // o
        .SPI1_MOSI       (SPI1_MOSI),                          // o
        .SPI1_MISO       (SPI1_MISO),                          // i
        .SPI1_CS         (SPI1_CS),                            // o
        .SPI1_interrupt  (),                                   // o  // SPI interrupt
        .SPI2_SCK        (SPI2_SCK),                           // o
        .SPI2_MOSI       (SPI2_MOSI),                          // o
        .SPI2_MISO       (SPI2_MISO),                          // i
        .SPI2_CS         (SPI2_CS),                            // o
        .SPI2_interrupt  ()                                    // o
    );
    Apb3TIMRouter Apb3TIMRouter (
        .io_apb_PCLK     (io_axiClk),                          // i
        .io_apb_PRESET   (resetCtrl_systemReset),              // i
        .io_apb_PADDR    (system_timCtrl_io_apb_PADDR),        // i
        .io_apb_PSEL     (apb3Router_1_io_outputs_5_PSEL),     // i
        .io_apb_PENABLE  (apb3Router_1_io_outputs_5_PENABLE),  // i
        .io_apb_PREADY   (system_timCtrl_io_apb_PREADY),       // o
        .io_apb_PWRITE   (apb3Router_1_io_outputs_5_PWRITE),   // i
        .io_apb_PWDATA   (apb3Router_1_io_outputs_5_PWDATA),   // i
        .io_apb_PRDATA   (system_timCtrl_io_apb_PRDATA),       // o
        .io_apb_PSLVERROR(system_timCtrl_io_apb_PSLVERROR),    // o
        .TIM2_CH         (TIM2_CH),                            // o
        .TIM2_interrupt  (TIM2_interrupt),                     // o  // TIM interrupt
        .TIM3_CH         (TIM3_CH),                            // o
        .TIM3_interrupt  (TIM3_interrupt)                      // o
    );

    initial begin
        resetCtrl_systemResetCounter = 6'h0;
    end

    always @(*) begin
        resetCtrl_systemResetUnbuffered = 1'b0;
        if (when_Briey2_l197) begin
            resetCtrl_systemResetUnbuffered = 1'b1;
        end
    end

    assign _zz_when_Briey2_l197[5:0] = 6'h3f;
    assign when_Briey2_l197 = (resetCtrl_systemResetCounter != _zz_when_Briey2_l197);
    assign when_Briey2_l201 = io_asyncReset_buffercc_io_dataOut;
    assign axi_core_cpu_iBus_rsp_payload_error = (! (axi4ReadOnlyDecoder_1_io_input_r_payload_resp == 2'b00));
    always @(*) begin
        axi_core_cpu_dBus_cmd_ready = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_ready;
        if (when_Stream_l375) begin
            axi_core_cpu_dBus_cmd_ready = 1'b1;
        end
    end

    assign when_Stream_l375 = (!toplevel_axi_core_cpu_dBus_cmd_m2sPipe_valid);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_valid = toplevel_axi_core_cpu_dBus_cmd_rValid;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_wr = toplevel_axi_core_cpu_dBus_cmd_rData_wr;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_uncached = toplevel_axi_core_cpu_dBus_cmd_rData_uncached;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_address = toplevel_axi_core_cpu_dBus_cmd_rData_address;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_data = toplevel_axi_core_cpu_dBus_cmd_rData_data;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_mask = toplevel_axi_core_cpu_dBus_cmd_rData_mask;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_size = toplevel_axi_core_cpu_dBus_cmd_rData_size;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_last = toplevel_axi_core_cpu_dBus_cmd_rData_last;
    always @(*) begin
        toplevel_axi_core_cpu_dBus_cmd_m2sPipe_ready = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_ready;
        if (when_Stream_l375_1) begin
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_ready = 1'b1;
        end
    end

    assign when_Stream_l375_1 = (!toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_valid);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_valid = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rValid;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_wr = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_wr;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_uncached = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_uncached;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_address = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_address;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_data = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_data;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_mask = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_mask;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_size = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_size;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_last = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_last;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_ready = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN;
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_valid = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_valid || (! toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN));
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_wr = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN ? toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_wr:toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_wr);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_uncached = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN ? toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_uncached:toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_uncached);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_address = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN ? toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_address:toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_address);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_data = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN ? toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_data:toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_data);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_mask = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN ? toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_mask:toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_mask);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_size = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN ? toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_size:toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_size);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_last = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN ? toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_last:toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_last);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_fire = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_valid && toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready);
    assign when_Utils_l706 = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_fire && toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_wr);
    assign dbus_axi_b_fire = (dbus_axi_b_valid && dbus_axi_b_ready);
    always @(*) begin
        _zz_when_Utils_l735 = 1'b0;
        if (when_Utils_l706) begin
            _zz_when_Utils_l735 = 1'b1;
        end
    end

    always @(*) begin
        _zz_when_Utils_l735_1 = 1'b0;
        if (dbus_axi_b_fire) begin
            _zz_when_Utils_l735_1 = 1'b1;
        end
    end

    assign when_Utils_l735 = (_zz_when_Utils_l735 && (!_zz_when_Utils_l735_1));
    always @(*) begin
        if (when_Utils_l735) begin
            _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_1 = 3'b001;
        end else begin
            if (when_Utils_l737) begin
                _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_1 = 3'b111;
            end else begin
                _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_1 = 3'b000;
            end
        end
    end

    assign when_Utils_l737 = ((!_zz_when_Utils_l735) && _zz_when_Utils_l735_1);
    assign _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_2 = (! (((_zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready != 3'b000) && (! toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_wr)) || (_zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready == 3'b111)));
    assign _zz_dbus_axi_arw_valid = (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_valid && _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_2);
    assign toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready = (_zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_3 && _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_2);
    assign _zz_dbus_axi_arw_payload_write = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_wr;
    assign _zz_dbus_axi_w_payload_last = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_last;
    always @(*) begin
        _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_3 = 1'b1;
        if (when_Stream_l1063) begin
            _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_3 = 1'b0;
        end
        if (when_Stream_l1063_1) begin
            _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_3 = 1'b0;
        end
    end

    assign when_Stream_l1063 = ((!_zz_when_Stream_l1063) && _zz_when_Stream_l1063_2);
    assign when_Stream_l1063_1 = ((!_zz_when_Stream_l1063_1) && _zz_when_Stream_l1063_3);
    assign _zz_dbus_axi_arw_valid_1 = (_zz_dbus_axi_arw_valid && _zz_when_Stream_l1063_2);
    assign _zz_1 = (_zz_dbus_axi_arw_valid_1 && _zz_when_Stream_l1063);
    assign _zz_dbus_axi_w_valid = (_zz_dbus_axi_arw_valid && _zz_when_Stream_l1063_3);
    always @(*) begin
        _zz_dbus_axi_arw_valid_2 = _zz_dbus_axi_arw_valid_1;
        if (_zz_2) begin
            _zz_dbus_axi_arw_valid_2 = 1'b0;
        end
    end

    always @(*) begin
        _zz_when_Stream_l1063 = dbus_axi_arw_ready;
        if (_zz_2) begin
            _zz_when_Stream_l1063 = 1'b1;
        end
    end

    assign when_Stream_l445 = (!_zz_dbus_axi_arw_payload_write);
    always @(*) begin
        _zz_dbus_axi_w_valid_1 = _zz_dbus_axi_w_valid;
        if (when_Stream_l445) begin
            _zz_dbus_axi_w_valid_1 = 1'b0;
        end
    end

    always @(*) begin
        _zz_when_Stream_l1063_1 = dbus_axi_w_ready;
        if (when_Stream_l445) begin
            _zz_when_Stream_l1063_1 = 1'b1;
        end
    end

    assign dbus_axi_arw_valid = _zz_dbus_axi_arw_valid_2;
    assign dbus_axi_arw_payload_write = _zz_dbus_axi_arw_payload_write;
    assign dbus_axi_arw_payload_prot = 3'b010;
    assign dbus_axi_arw_payload_cache = 4'b1111;
    assign dbus_axi_arw_payload_size = 3'b010;
    assign dbus_axi_arw_payload_addr = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_address;
    assign dbus_axi_arw_payload_len = {5'd0, _zz_dbus_axi_arw_payload_len};
    assign dbus_axi_w_valid = _zz_dbus_axi_w_valid_1;
    assign dbus_axi_w_payload_data = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_data;
    assign dbus_axi_w_payload_strb = toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_payload_mask;
    assign dbus_axi_w_payload_last = _zz_dbus_axi_w_payload_last;
    assign axi_core_cpu_dBus_rsp_payload_error = (!(dbus_axi_r_payload_resp == 2'b00));
    assign dbus_axi_r_ready = 1'b1;
    assign dbus_axi_b_ready = 1'b1;
    assign axi_core_cpu_debug_bus_cmd_payload_address = systemDebugger_1_io_mem_cmd_payload_address[7:0];
    assign toplevel_axi_core_cpu_debug_bus_cmd_fire = (systemDebugger_1_io_mem_cmd_valid && axi_core_cpu_debug_bus_cmd_ready);
    assign io_jtag_tdo = jtagBridge_1_io_jtag_tdo;
    assign toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_fire = (toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_valid && toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_ready);
    assign toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_valid = toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_rValid;
    assign toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_addr = axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_addr;
    assign toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_len = axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_len;
    assign toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_burst = axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_burst;
    assign toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_cache = axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_cache;
    assign toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_prot = axi4ReadOnlyDecoder_1_io_outputs_0_ar_payload_prot;
    assign toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_ready = axi_ram_io_axi_arbiter_io_readInputs_0_ar_ready;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_fire = (toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_valid && toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_ready);
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_valid = toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_rValid;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_addr = dbus_axi_decoder_io_sharedOutputs_0_arw_payload_addr;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_len = dbus_axi_decoder_io_sharedOutputs_0_arw_payload_len;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_size = dbus_axi_decoder_io_sharedOutputs_0_arw_payload_size;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_cache = dbus_axi_decoder_io_sharedOutputs_0_arw_payload_cache;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_prot = dbus_axi_decoder_io_sharedOutputs_0_arw_payload_prot;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_write = dbus_axi_decoder_io_sharedOutputs_0_arw_payload_write;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_ready = axi_ram_io_axi_arbiter_io_sharedInputs_0_arw_ready;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_fire = (toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_valid && toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_ready);
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_valid = toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_rValid;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_addr = dbus_axi_decoder_io_sharedOutputs_1_arw_payload_addr;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_len = dbus_axi_decoder_io_sharedOutputs_1_arw_payload_len;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_size = dbus_axi_decoder_io_sharedOutputs_1_arw_payload_size;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_cache = dbus_axi_decoder_io_sharedOutputs_1_arw_payload_cache;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_prot = dbus_axi_decoder_io_sharedOutputs_1_arw_payload_prot;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_write = dbus_axi_decoder_io_sharedOutputs_1_arw_payload_write;
    assign toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_ready = axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_ready;
    assign dbus_axi_arw_ready = dbus_axi_decoder_io_input_arw_ready;
    assign dbus_axi_w_ready = dbus_axi_decoder_io_input_w_ready;
    assign dbus_axi_b_valid = dbus_axi_decoder_io_input_b_valid;
    assign dbus_axi_b_payload_resp = dbus_axi_decoder_io_input_b_payload_resp;
    always @(*) begin
        dbus_axi_decoder_io_input_r_ready = toplevel_dbus_axi_decoder_io_input_r_m2sPipe_ready;
        if (when_Stream_l375_2) begin
            dbus_axi_decoder_io_input_r_ready = 1'b1;
        end
    end

    assign when_Stream_l375_2 = (!toplevel_dbus_axi_decoder_io_input_r_m2sPipe_valid);
    assign toplevel_dbus_axi_decoder_io_input_r_m2sPipe_valid = toplevel_dbus_axi_decoder_io_input_r_rValid;
    assign toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_data = toplevel_dbus_axi_decoder_io_input_r_rData_data;
    assign toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_resp = toplevel_dbus_axi_decoder_io_input_r_rData_resp;
    assign toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_last = toplevel_dbus_axi_decoder_io_input_r_rData_last;
    assign dbus_axi_r_valid = toplevel_dbus_axi_decoder_io_input_r_m2sPipe_valid;
    assign toplevel_dbus_axi_decoder_io_input_r_m2sPipe_ready = dbus_axi_r_ready;
    assign dbus_axi_r_payload_data = toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_data;
    assign dbus_axi_r_payload_resp = toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_resp;
    assign dbus_axi_r_payload_last = toplevel_dbus_axi_decoder_io_input_r_m2sPipe_payload_last;
    assign axi_ram_io_axi_arbiter_io_readInputs_0_ar_payload_addr = toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_payload_addr[17:0];
    assign _zz_io_readInputs_0_ar_payload_id[2:0] = 3'b000;
    assign axi_ram_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr = toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_payload_addr[17:0];
    assign _zz_io_sharedInputs_0_arw_payload_id[2:0] = 3'b000;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_fire = (toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_valid && toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_ready);
    assign axi_ram_io_axi_arbiter_io_output_arw_ready = (! toplevel_axi_ram_io_axi_arbiter_io_output_arw_rValid);
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_valid = toplevel_axi_ram_io_axi_arbiter_io_output_arw_rValid;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_addr = toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_addr;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_id = toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_id;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_len = toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_len;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_size = toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_size;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_burst = toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_burst;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_payload_write = toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_write;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_ready = axi_ram_io_axi_arw_ready;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_valid = (axi_ram_io_axi_arbiter_io_output_w_valid || (! toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN));
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_data = (toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN ? axi_ram_io_axi_arbiter_io_output_w_payload_data:toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_data);
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_strb = (toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN ? axi_ram_io_axi_arbiter_io_output_w_payload_strb:toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_strb);
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_last = (toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN ? axi_ram_io_axi_arbiter_io_output_w_payload_last:toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_last);
    always @(*) begin
        toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_ready = toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_ready;
        if (when_Stream_l375_3) begin
            toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_ready = 1'b1;
        end
    end

    assign when_Stream_l375_3 = (! toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_valid);
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_valid = toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rValid;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_data = toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_data;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_strb = toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_strb;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_payload_last = toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_last;
    assign toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_m2sPipe_ready = axi_ram_io_axi_w_ready;
    assign axi_apbBridge_io_axi_arbiter_io_sharedInputs_0_arw_payload_addr = toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_payload_addr[19:0];
    assign _zz_io_sharedInputs_0_arw_payload_id_1[3:0] = 4'b0000;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_fire = (toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_valid && toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_ready);
    assign axi_apbBridge_io_axi_arbiter_io_output_arw_ready = (! toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rValid);
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_valid = toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rValid;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_addr = toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_addr;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_id = toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_id;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_len = toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_len;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_size = toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_size;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_burst = toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_burst;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_payload_write = toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_write;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_ready = axi_apbBridge_io_axi_arw_ready;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_fire = (toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_valid && toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_ready);
    assign axi_apbBridge_io_axi_arbiter_io_output_w_ready = (! toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rValid);
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_valid = toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rValid;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_data = toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_data;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_strb = toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_strb;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_payload_last = toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_last;
    assign toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_ready = axi_apbBridge_io_axi_w_ready;

    always @(posedge io_axiClk) begin
        if (when_Briey2_l197) begin
            resetCtrl_systemResetCounter <= (resetCtrl_systemResetCounter + 6'h01);
        end
        if (when_Briey2_l201) begin
            resetCtrl_systemResetCounter <= 6'h0;
        end
    end

    always @(posedge io_axiClk) begin
        resetCtrl_systemReset <= resetCtrl_systemResetUnbuffered;
        resetCtrl_axiReset <= resetCtrl_systemResetUnbuffered;
        if (toplevel_axi_core_cpu_debug_resetOut_regNext) begin
            resetCtrl_axiReset <= 1'b1;
        end
    end

    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            toplevel_axi_core_cpu_dBus_cmd_rValid <= 1'b0;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rValid <= 1'b0;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN <= 1'b1;
            _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready <= 3'b000;
            _zz_when_Stream_l1063_2 <= 1'b1;
            _zz_when_Stream_l1063_3 <= 1'b1;
            _zz_2 <= 1'b0;
            toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_rValid <= 1'b0;
            toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_rValid <= 1'b0;
            toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_rValid <= 1'b0;
            toplevel_dbus_axi_decoder_io_input_r_rValid <= 1'b0;
            toplevel_axi_ram_io_axi_arbiter_io_output_arw_rValid <= 1'b0;
            toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN <= 1'b1;
            toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rValid <= 1'b0;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rValid <= 1'b0;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rValid <= 1'b0;
        end else begin
            if (axi_core_cpu_dBus_cmd_ready) begin
                toplevel_axi_core_cpu_dBus_cmd_rValid <= axi_core_cpu_dBus_cmd_valid;
            end
            if (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_ready) begin
                toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rValid <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_valid;
            end
            if (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_valid) begin
                toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN <= 1'b0;
            end
            if (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready) begin
                toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rValidN <= 1'b1;
            end
            _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready <= (_zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready + _zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_1);
            if (_zz_1) begin
                _zz_when_Stream_l1063_2 <= 1'b0;
            end
            if ((_zz_dbus_axi_w_valid && _zz_when_Stream_l1063_1)) begin
                _zz_when_Stream_l1063_3 <= 1'b0;
            end
            if (_zz_toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_s2mPipe_ready_3) begin
                _zz_when_Stream_l1063_2 <= 1'b1;
                _zz_when_Stream_l1063_3 <= 1'b1;
            end
            if (_zz_1) begin
                _zz_2 <= (!_zz_dbus_axi_w_payload_last);
            end
            if (axi4ReadOnlyDecoder_1_io_outputs_0_ar_valid) begin
                toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_rValid <= 1'b1;
            end
            if (toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_validPipe_fire) begin
                toplevel_axi4ReadOnlyDecoder_1_io_outputs_0_ar_rValid <= 1'b0;
            end
            if (dbus_axi_decoder_io_sharedOutputs_0_arw_valid) begin
                toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_rValid <= 1'b1;
            end
            if (toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_validPipe_fire) begin
                toplevel_dbus_axi_decoder_io_sharedOutputs_0_arw_rValid <= 1'b0;
            end
            if (dbus_axi_decoder_io_sharedOutputs_1_arw_valid) begin
                toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_rValid <= 1'b1;
            end
            if (toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_validPipe_fire) begin
                toplevel_dbus_axi_decoder_io_sharedOutputs_1_arw_rValid <= 1'b0;
            end
            if (dbus_axi_decoder_io_input_r_ready) begin
                toplevel_dbus_axi_decoder_io_input_r_rValid <= dbus_axi_decoder_io_input_r_valid;
            end
            if (axi_ram_io_axi_arbiter_io_output_arw_valid) begin
                toplevel_axi_ram_io_axi_arbiter_io_output_arw_rValid <= 1'b1;
            end
            if (toplevel_axi_ram_io_axi_arbiter_io_output_arw_halfPipe_fire) begin
                toplevel_axi_ram_io_axi_arbiter_io_output_arw_rValid <= 1'b0;
            end
            if (axi_ram_io_axi_arbiter_io_output_w_valid) begin
                toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN <= 1'b0;
            end
            if (toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_ready) begin
                toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN <= 1'b1;
            end
            if (toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_ready) begin
                toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rValid <= toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_valid;
            end
            if (axi_apbBridge_io_axi_arbiter_io_output_arw_valid) begin
                toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rValid <= 1'b1;
            end
            if (toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_halfPipe_fire) begin
                toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rValid <= 1'b0;
            end
            if (axi_apbBridge_io_axi_arbiter_io_output_w_valid) begin
                toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rValid <= 1'b1;
            end
            if (toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_halfPipe_fire) begin
                toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rValid <= 1'b0;
            end
        end
    end

    always @(posedge io_axiClk) begin
        if (axi_core_cpu_dBus_cmd_ready) begin
            toplevel_axi_core_cpu_dBus_cmd_rData_wr <= axi_core_cpu_dBus_cmd_payload_wr;
            toplevel_axi_core_cpu_dBus_cmd_rData_uncached <= axi_core_cpu_dBus_cmd_payload_uncached;
            toplevel_axi_core_cpu_dBus_cmd_rData_address <= axi_core_cpu_dBus_cmd_payload_address;
            toplevel_axi_core_cpu_dBus_cmd_rData_data <= axi_core_cpu_dBus_cmd_payload_data;
            toplevel_axi_core_cpu_dBus_cmd_rData_mask <= axi_core_cpu_dBus_cmd_payload_mask;
            toplevel_axi_core_cpu_dBus_cmd_rData_size <= axi_core_cpu_dBus_cmd_payload_size;
            toplevel_axi_core_cpu_dBus_cmd_rData_last <= axi_core_cpu_dBus_cmd_payload_last;
        end
        if (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_ready) begin
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_wr <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_wr;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_uncached <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_uncached;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_address <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_address;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_data <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_data;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_mask <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_mask;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_size <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_size;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_rData_last <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_payload_last;
        end
        if (toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_ready) begin
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_wr <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_wr;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_uncached <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_uncached;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_address <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_address;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_data <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_data;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_mask <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_mask;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_size <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_size;
            toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_rData_last <= toplevel_axi_core_cpu_dBus_cmd_m2sPipe_m2sPipe_payload_last;
        end
        if (dbus_axi_decoder_io_input_r_ready) begin
            toplevel_dbus_axi_decoder_io_input_r_rData_data <= dbus_axi_decoder_io_input_r_payload_data;
            toplevel_dbus_axi_decoder_io_input_r_rData_resp <= dbus_axi_decoder_io_input_r_payload_resp;
            toplevel_dbus_axi_decoder_io_input_r_rData_last <= dbus_axi_decoder_io_input_r_payload_last;
        end
        if (axi_ram_io_axi_arbiter_io_output_arw_ready) begin
            toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_addr <= axi_ram_io_axi_arbiter_io_output_arw_payload_addr;
            toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_id <= axi_ram_io_axi_arbiter_io_output_arw_payload_id;
            toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_len <= axi_ram_io_axi_arbiter_io_output_arw_payload_len;
            toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_size <= axi_ram_io_axi_arbiter_io_output_arw_payload_size;
            toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_burst <= axi_ram_io_axi_arbiter_io_output_arw_payload_burst;
            toplevel_axi_ram_io_axi_arbiter_io_output_arw_rData_write <= axi_ram_io_axi_arbiter_io_output_arw_payload_write;
        end
        if (toplevel_axi_ram_io_axi_arbiter_io_output_w_rValidN) begin
            toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_data <= axi_ram_io_axi_arbiter_io_output_w_payload_data;
            toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_strb <= axi_ram_io_axi_arbiter_io_output_w_payload_strb;
            toplevel_axi_ram_io_axi_arbiter_io_output_w_rData_last <= axi_ram_io_axi_arbiter_io_output_w_payload_last;
        end
        if (toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_ready) begin
            toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_data <= toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_data;
            toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_strb <= toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_strb;
            toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_rData_last <= toplevel_axi_ram_io_axi_arbiter_io_output_w_s2mPipe_payload_last;
        end
        if (axi_apbBridge_io_axi_arbiter_io_output_arw_ready) begin
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_addr <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_addr;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_id <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_id;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_len <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_len;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_size <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_size;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_burst <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_burst;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_arw_rData_write <= axi_apbBridge_io_axi_arbiter_io_output_arw_payload_write;
        end
        if (axi_apbBridge_io_axi_arbiter_io_output_w_ready) begin
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_data <= axi_apbBridge_io_axi_arbiter_io_output_w_payload_data;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_strb <= axi_apbBridge_io_axi_arbiter_io_output_w_payload_strb;
            toplevel_axi_apbBridge_io_axi_arbiter_io_output_w_rData_last <= axi_apbBridge_io_axi_arbiter_io_output_w_payload_last;
        end
    end

    always @(posedge io_axiClk) begin
        toplevel_axi_core_cpu_debug_resetOut_regNext <= axi_core_cpu_debug_resetOut;
    end

    always @(posedge io_axiClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            toplevel_axi_core_cpu_debug_bus_cmd_fire_regNext <= 1'b0;
        end else begin
            toplevel_axi_core_cpu_debug_bus_cmd_fire_regNext <= toplevel_axi_core_cpu_debug_bus_cmd_fire;
        end
    end

endmodule


module Axi4SharedArbiter_1 (
    input  wire        io_sharedInputs_0_arw_valid,
    output wire        io_sharedInputs_0_arw_ready,
    input  wire [19:0] io_sharedInputs_0_arw_payload_addr,
    input  wire [ 3:0] io_sharedInputs_0_arw_payload_id,
    input  wire [ 7:0] io_sharedInputs_0_arw_payload_len,
    input  wire [ 2:0] io_sharedInputs_0_arw_payload_size,
    input  wire [ 1:0] io_sharedInputs_0_arw_payload_burst,
    input  wire        io_sharedInputs_0_arw_payload_write,
    input  wire        io_sharedInputs_0_w_valid,
    output wire        io_sharedInputs_0_w_ready,
    input  wire [31:0] io_sharedInputs_0_w_payload_data,
    input  wire [ 3:0] io_sharedInputs_0_w_payload_strb,
    input  wire        io_sharedInputs_0_w_payload_last,
    output wire        io_sharedInputs_0_b_valid,
    input  wire        io_sharedInputs_0_b_ready,
    output wire [ 3:0] io_sharedInputs_0_b_payload_id,
    output wire [ 1:0] io_sharedInputs_0_b_payload_resp,
    output wire        io_sharedInputs_0_r_valid,
    input  wire        io_sharedInputs_0_r_ready,
    output wire [31:0] io_sharedInputs_0_r_payload_data,
    output wire [ 3:0] io_sharedInputs_0_r_payload_id,
    output wire [ 1:0] io_sharedInputs_0_r_payload_resp,
    output wire        io_sharedInputs_0_r_payload_last,
    output wire        io_output_arw_valid,
    input  wire        io_output_arw_ready,
    output wire [19:0] io_output_arw_payload_addr,
    output wire [ 3:0] io_output_arw_payload_id,
    output wire [ 7:0] io_output_arw_payload_len,
    output wire [ 2:0] io_output_arw_payload_size,
    output wire [ 1:0] io_output_arw_payload_burst,
    output wire        io_output_arw_payload_write,
    output wire        io_output_w_valid,
    input  wire        io_output_w_ready,
    output wire [31:0] io_output_w_payload_data,
    output wire [ 3:0] io_output_w_payload_strb,
    output wire        io_output_w_payload_last,
    input  wire        io_output_b_valid,
    output wire        io_output_b_ready,
    input  wire [ 3:0] io_output_b_payload_id,
    input  wire [ 1:0] io_output_b_payload_resp,
    input  wire        io_output_r_valid,
    output wire        io_output_r_ready,
    input  wire [31:0] io_output_r_payload_data,
    input  wire [ 3:0] io_output_r_payload_id,
    input  wire [ 1:0] io_output_r_payload_resp,
    input  wire        io_output_r_payload_last,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    reg         cmdArbiter_io_output_ready;
    wire        cmdRouteFork_thrown_translated_fifo_io_pop_ready;
    wire        cmdArbiter_io_inputs_0_ready;
    wire        cmdArbiter_io_output_valid;
    wire [19:0] cmdArbiter_io_output_payload_addr;
    wire [ 3:0] cmdArbiter_io_output_payload_id;
    wire [ 7:0] cmdArbiter_io_output_payload_len;
    wire [ 2:0] cmdArbiter_io_output_payload_size;
    wire [ 1:0] cmdArbiter_io_output_payload_burst;
    wire        cmdArbiter_io_output_payload_write;
    wire [ 0:0] cmdArbiter_io_chosenOH;
    wire        cmdRouteFork_thrown_translated_fifo_io_push_ready;
    wire        cmdRouteFork_thrown_translated_fifo_io_pop_valid;
    wire [ 2:0] cmdRouteFork_thrown_translated_fifo_io_occupancy;
    wire [ 2:0] cmdRouteFork_thrown_translated_fifo_io_availability;
    wire        inputsCmd_0_valid;
    wire        inputsCmd_0_ready;
    wire [19:0] inputsCmd_0_payload_addr;
    wire [ 3:0] inputsCmd_0_payload_id;
    wire [ 7:0] inputsCmd_0_payload_len;
    wire [ 2:0] inputsCmd_0_payload_size;
    wire [ 1:0] inputsCmd_0_payload_burst;
    wire        inputsCmd_0_payload_write;
    wire        cmdOutputFork_valid;
    wire        cmdOutputFork_ready;
    wire [19:0] cmdOutputFork_payload_addr;
    wire [ 3:0] cmdOutputFork_payload_id;
    wire [ 7:0] cmdOutputFork_payload_len;
    wire [ 2:0] cmdOutputFork_payload_size;
    wire [ 1:0] cmdOutputFork_payload_burst;
    wire        cmdOutputFork_payload_write;
    wire        cmdRouteFork_valid;
    reg         cmdRouteFork_ready;
    wire [19:0] cmdRouteFork_payload_addr;
    wire [ 3:0] cmdRouteFork_payload_id;
    wire [ 7:0] cmdRouteFork_payload_len;
    wire [ 2:0] cmdRouteFork_payload_size;
    wire [ 1:0] cmdRouteFork_payload_burst;
    wire        cmdRouteFork_payload_write;
    reg         axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0;
    reg         axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1;
    wire        when_Stream_l1063;
    wire        when_Stream_l1063_1;
    wire        cmdOutputFork_fire;
    wire        cmdRouteFork_fire;
    wire        when_Stream_l445;
    reg         cmdRouteFork_thrown_valid;
    wire        cmdRouteFork_thrown_ready;
    wire [19:0] cmdRouteFork_thrown_payload_addr;
    wire [ 3:0] cmdRouteFork_thrown_payload_id;
    wire [ 7:0] cmdRouteFork_thrown_payload_len;
    wire [ 2:0] cmdRouteFork_thrown_payload_size;
    wire [ 1:0] cmdRouteFork_thrown_payload_burst;
    wire        cmdRouteFork_thrown_payload_write;
    wire        cmdRouteFork_thrown_translated_valid;
    wire        cmdRouteFork_thrown_translated_ready;
    wire        writeLogic_routeDataInput_valid;
    wire        writeLogic_routeDataInput_ready;
    wire [31:0] writeLogic_routeDataInput_payload_data;
    wire [ 3:0] writeLogic_routeDataInput_payload_strb;
    wire        writeLogic_routeDataInput_payload_last;
    wire        io_output_w_fire;
    wire        writeLogic_writeRspSels_0;
    wire        readRspSels_0;

    StreamArbiter cmdArbiter (
        .io_inputs_0_valid        (inputsCmd_0_valid),                        //i
        .io_inputs_0_ready        (cmdArbiter_io_inputs_0_ready),             //o
        .io_inputs_0_payload_addr (inputsCmd_0_payload_addr[19:0]),           //i
        .io_inputs_0_payload_id   (inputsCmd_0_payload_id[3:0]),              //i
        .io_inputs_0_payload_len  (inputsCmd_0_payload_len[7:0]),             //i
        .io_inputs_0_payload_size (inputsCmd_0_payload_size[2:0]),            //i
        .io_inputs_0_payload_burst(inputsCmd_0_payload_burst[1:0]),           //i
        .io_inputs_0_payload_write(inputsCmd_0_payload_write),                //i
        .io_output_valid          (cmdArbiter_io_output_valid),               //o
        .io_output_ready          (cmdArbiter_io_output_ready),               //i
        .io_output_payload_addr   (cmdArbiter_io_output_payload_addr[19:0]),  //o
        .io_output_payload_id     (cmdArbiter_io_output_payload_id[3:0]),     //o
        .io_output_payload_len    (cmdArbiter_io_output_payload_len[7:0]),    //o
        .io_output_payload_size   (cmdArbiter_io_output_payload_size[2:0]),   //o
        .io_output_payload_burst  (cmdArbiter_io_output_payload_burst[1:0]),  //o
        .io_output_payload_write  (cmdArbiter_io_output_payload_write),       //o
        .io_chosenOH              (cmdArbiter_io_chosenOH),                   //o
        .io_axiClk                (io_axiClk),                                //i
        .resetCtrl_axiReset       (resetCtrl_axiReset)                        //i
    );
    StreamFifoLowLatency_1 cmdRouteFork_thrown_translated_fifo (
        .io_push_valid     (cmdRouteFork_thrown_translated_valid),                      //i
        .io_push_ready     (cmdRouteFork_thrown_translated_fifo_io_push_ready),         //o
        .io_pop_valid      (cmdRouteFork_thrown_translated_fifo_io_pop_valid),          //o
        .io_pop_ready      (cmdRouteFork_thrown_translated_fifo_io_pop_ready),          //i
        .io_flush          (1'b0),                                                      //i
        .io_occupancy      (cmdRouteFork_thrown_translated_fifo_io_occupancy[2:0]),     //o
        .io_availability   (cmdRouteFork_thrown_translated_fifo_io_availability[2:0]),  //o
        .io_axiClk         (io_axiClk),                                                 //i
        .resetCtrl_axiReset(resetCtrl_axiReset)                                         //i
    );
    assign inputsCmd_0_valid = io_sharedInputs_0_arw_valid;
    assign io_sharedInputs_0_arw_ready = inputsCmd_0_ready;
    assign inputsCmd_0_payload_addr = io_sharedInputs_0_arw_payload_addr;
    assign inputsCmd_0_payload_id = io_sharedInputs_0_arw_payload_id;
    assign inputsCmd_0_payload_len = io_sharedInputs_0_arw_payload_len;
    assign inputsCmd_0_payload_size = io_sharedInputs_0_arw_payload_size;
    assign inputsCmd_0_payload_burst = io_sharedInputs_0_arw_payload_burst;
    assign inputsCmd_0_payload_write = io_sharedInputs_0_arw_payload_write;
    assign inputsCmd_0_ready = cmdArbiter_io_inputs_0_ready;
    always @(*) begin
        cmdArbiter_io_output_ready = 1'b1;
        if (when_Stream_l1063) begin
            cmdArbiter_io_output_ready = 1'b0;
        end
        if (when_Stream_l1063_1) begin
            cmdArbiter_io_output_ready = 1'b0;
        end
    end

    assign when_Stream_l1063 = ((! cmdOutputFork_ready) && axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0);
    assign when_Stream_l1063_1 = ((! cmdRouteFork_ready) && axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1);
    assign cmdOutputFork_valid = (cmdArbiter_io_output_valid && axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0);
    assign cmdOutputFork_payload_addr = cmdArbiter_io_output_payload_addr;
    assign cmdOutputFork_payload_id = cmdArbiter_io_output_payload_id;
    assign cmdOutputFork_payload_len = cmdArbiter_io_output_payload_len;
    assign cmdOutputFork_payload_size = cmdArbiter_io_output_payload_size;
    assign cmdOutputFork_payload_burst = cmdArbiter_io_output_payload_burst;
    assign cmdOutputFork_payload_write = cmdArbiter_io_output_payload_write;
    assign cmdOutputFork_fire = (cmdOutputFork_valid && cmdOutputFork_ready);
    assign cmdRouteFork_valid = (cmdArbiter_io_output_valid && axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1);
    assign cmdRouteFork_payload_addr = cmdArbiter_io_output_payload_addr;
    assign cmdRouteFork_payload_id = cmdArbiter_io_output_payload_id;
    assign cmdRouteFork_payload_len = cmdArbiter_io_output_payload_len;
    assign cmdRouteFork_payload_size = cmdArbiter_io_output_payload_size;
    assign cmdRouteFork_payload_burst = cmdArbiter_io_output_payload_burst;
    assign cmdRouteFork_payload_write = cmdArbiter_io_output_payload_write;
    assign cmdRouteFork_fire = (cmdRouteFork_valid && cmdRouteFork_ready);
    assign io_output_arw_valid = cmdOutputFork_valid;
    assign cmdOutputFork_ready = io_output_arw_ready;
    assign io_output_arw_payload_addr = cmdOutputFork_payload_addr;
    assign io_output_arw_payload_len = cmdOutputFork_payload_len;
    assign io_output_arw_payload_size = cmdOutputFork_payload_size;
    assign io_output_arw_payload_burst = cmdOutputFork_payload_burst;
    assign io_output_arw_payload_write = cmdOutputFork_payload_write;
    assign io_output_arw_payload_id = (cmdOutputFork_payload_write ? cmdOutputFork_payload_id:cmdOutputFork_payload_id);
    assign when_Stream_l445 = (!cmdRouteFork_payload_write);
    always @(*) begin
        cmdRouteFork_thrown_valid = cmdRouteFork_valid;
        if (when_Stream_l445) begin
            cmdRouteFork_thrown_valid = 1'b0;
        end
    end

    always @(*) begin
        cmdRouteFork_ready = cmdRouteFork_thrown_ready;
        if (when_Stream_l445) begin
            cmdRouteFork_ready = 1'b1;
        end
    end

    assign cmdRouteFork_thrown_payload_addr = cmdRouteFork_payload_addr;
    assign cmdRouteFork_thrown_payload_id = cmdRouteFork_payload_id;
    assign cmdRouteFork_thrown_payload_len = cmdRouteFork_payload_len;
    assign cmdRouteFork_thrown_payload_size = cmdRouteFork_payload_size;
    assign cmdRouteFork_thrown_payload_burst = cmdRouteFork_payload_burst;
    assign cmdRouteFork_thrown_payload_write = cmdRouteFork_payload_write;
    assign cmdRouteFork_thrown_translated_valid = cmdRouteFork_thrown_valid;
    assign cmdRouteFork_thrown_ready = cmdRouteFork_thrown_translated_ready;
    assign cmdRouteFork_thrown_translated_ready = cmdRouteFork_thrown_translated_fifo_io_push_ready;
    assign writeLogic_routeDataInput_valid = io_sharedInputs_0_w_valid;
    assign writeLogic_routeDataInput_ready = io_sharedInputs_0_w_ready;
    assign writeLogic_routeDataInput_payload_data = io_sharedInputs_0_w_payload_data;
    assign writeLogic_routeDataInput_payload_strb = io_sharedInputs_0_w_payload_strb;
    assign writeLogic_routeDataInput_payload_last = io_sharedInputs_0_w_payload_last;
    assign io_output_w_valid = (cmdRouteFork_thrown_translated_fifo_io_pop_valid && writeLogic_routeDataInput_valid);
    assign io_output_w_payload_data = writeLogic_routeDataInput_payload_data;
    assign io_output_w_payload_strb = writeLogic_routeDataInput_payload_strb;
    assign io_output_w_payload_last = writeLogic_routeDataInput_payload_last;
    assign io_sharedInputs_0_w_ready = ((cmdRouteFork_thrown_translated_fifo_io_pop_valid && io_output_w_ready) && 1'b1);
    assign io_output_w_fire = (io_output_w_valid && io_output_w_ready);
    assign cmdRouteFork_thrown_translated_fifo_io_pop_ready = (io_output_w_fire && io_output_w_payload_last);
    assign writeLogic_writeRspSels_0 = 1'b1;
    assign io_sharedInputs_0_b_valid = (io_output_b_valid && writeLogic_writeRspSels_0);
    assign io_sharedInputs_0_b_payload_resp = io_output_b_payload_resp;
    assign io_sharedInputs_0_b_payload_id = io_output_b_payload_id;
    assign io_output_b_ready = io_sharedInputs_0_b_ready;
    assign readRspSels_0 = 1'b1;
    assign io_sharedInputs_0_r_valid = (io_output_r_valid && readRspSels_0);
    assign io_sharedInputs_0_r_payload_data = io_output_r_payload_data;
    assign io_sharedInputs_0_r_payload_resp = io_output_r_payload_resp;
    assign io_sharedInputs_0_r_payload_last = io_output_r_payload_last;
    assign io_sharedInputs_0_r_payload_id = io_output_r_payload_id;
    assign io_output_r_ready = io_sharedInputs_0_r_ready;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
            axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
        end else begin
            if (cmdOutputFork_fire) begin
                axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b0;
            end
            if (cmdRouteFork_fire) begin
                axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b0;
            end
            if (cmdArbiter_io_output_ready) begin
                axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
                axi_apbBridge_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
            end
        end
    end

endmodule


module Axi4SharedArbiter (
    input  wire        io_readInputs_0_ar_valid,
    output wire        io_readInputs_0_ar_ready,
    input  wire [17:0] io_readInputs_0_ar_payload_addr,
    input  wire [ 2:0] io_readInputs_0_ar_payload_id,
    input  wire [ 7:0] io_readInputs_0_ar_payload_len,
    input  wire [ 2:0] io_readInputs_0_ar_payload_size,
    input  wire [ 1:0] io_readInputs_0_ar_payload_burst,
    output wire        io_readInputs_0_r_valid,
    input  wire        io_readInputs_0_r_ready,
    output wire [31:0] io_readInputs_0_r_payload_data,
    output wire [ 2:0] io_readInputs_0_r_payload_id,
    output wire [ 1:0] io_readInputs_0_r_payload_resp,
    output wire        io_readInputs_0_r_payload_last,
    input  wire        io_sharedInputs_0_arw_valid,
    output wire        io_sharedInputs_0_arw_ready,
    input  wire [17:0] io_sharedInputs_0_arw_payload_addr,
    input  wire [ 2:0] io_sharedInputs_0_arw_payload_id,
    input  wire [ 7:0] io_sharedInputs_0_arw_payload_len,
    input  wire [ 2:0] io_sharedInputs_0_arw_payload_size,
    input  wire [ 1:0] io_sharedInputs_0_arw_payload_burst,
    input  wire        io_sharedInputs_0_arw_payload_write,
    input  wire        io_sharedInputs_0_w_valid,
    output wire        io_sharedInputs_0_w_ready,
    input  wire [31:0] io_sharedInputs_0_w_payload_data,
    input  wire [ 3:0] io_sharedInputs_0_w_payload_strb,
    input  wire        io_sharedInputs_0_w_payload_last,
    output wire        io_sharedInputs_0_b_valid,
    input  wire        io_sharedInputs_0_b_ready,
    output wire [ 2:0] io_sharedInputs_0_b_payload_id,
    output wire [ 1:0] io_sharedInputs_0_b_payload_resp,
    output wire        io_sharedInputs_0_r_valid,
    input  wire        io_sharedInputs_0_r_ready,
    output wire [31:0] io_sharedInputs_0_r_payload_data,
    output wire [ 2:0] io_sharedInputs_0_r_payload_id,
    output wire [ 1:0] io_sharedInputs_0_r_payload_resp,
    output wire        io_sharedInputs_0_r_payload_last,
    output wire        io_output_arw_valid,
    input  wire        io_output_arw_ready,
    output wire [17:0] io_output_arw_payload_addr,
    output wire [ 3:0] io_output_arw_payload_id,
    output wire [ 7:0] io_output_arw_payload_len,
    output wire [ 2:0] io_output_arw_payload_size,
    output wire [ 1:0] io_output_arw_payload_burst,
    output wire        io_output_arw_payload_write,
    output wire        io_output_w_valid,
    input  wire        io_output_w_ready,
    output wire [31:0] io_output_w_payload_data,
    output wire [ 3:0] io_output_w_payload_strb,
    output wire        io_output_w_payload_last,
    input  wire        io_output_b_valid,
    output wire        io_output_b_ready,
    input  wire [ 3:0] io_output_b_payload_id,
    input  wire [ 1:0] io_output_b_payload_resp,
    input  wire        io_output_r_valid,
    output wire        io_output_r_ready,
    input  wire [31:0] io_output_r_payload_data,
    input  wire [ 3:0] io_output_r_payload_id,
    input  wire [ 1:0] io_output_r_payload_resp,
    input  wire        io_output_r_payload_last,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    reg         cmdArbiter_io_output_ready;
    wire        cmdRouteFork_thrown_translated_fifo_io_pop_ready;
    wire        cmdArbiter_io_inputs_0_ready;
    wire        cmdArbiter_io_inputs_1_ready;
    wire        cmdArbiter_io_output_valid;
    wire [17:0] cmdArbiter_io_output_payload_addr;
    wire [ 2:0] cmdArbiter_io_output_payload_id;
    wire [ 7:0] cmdArbiter_io_output_payload_len;
    wire [ 2:0] cmdArbiter_io_output_payload_size;
    wire [ 1:0] cmdArbiter_io_output_payload_burst;
    wire        cmdArbiter_io_output_payload_write;
    wire [ 0:0] cmdArbiter_io_chosen;
    wire [ 1:0] cmdArbiter_io_chosenOH;
    wire        cmdRouteFork_thrown_translated_fifo_io_push_ready;
    wire        cmdRouteFork_thrown_translated_fifo_io_pop_valid;
    wire [ 2:0] cmdRouteFork_thrown_translated_fifo_io_occupancy;
    wire [ 2:0] cmdRouteFork_thrown_translated_fifo_io_availability;
    wire [ 1:0] _zz__zz_io_output_arw_payload_id;
    wire [ 3:0] _zz_io_output_arw_payload_id_1;
    wire [ 2:0] _zz_io_output_arw_payload_id_2;
    reg         _zz_io_output_r_ready;
    wire        inputsCmd_0_valid;
    wire        inputsCmd_0_ready;
    wire [17:0] inputsCmd_0_payload_addr;
    wire [ 2:0] inputsCmd_0_payload_id;
    wire [ 7:0] inputsCmd_0_payload_len;
    wire [ 2:0] inputsCmd_0_payload_size;
    wire [ 1:0] inputsCmd_0_payload_burst;
    wire        inputsCmd_0_payload_write;
    wire        inputsCmd_1_valid;
    wire        inputsCmd_1_ready;
    wire [17:0] inputsCmd_1_payload_addr;
    wire [ 2:0] inputsCmd_1_payload_id;
    wire [ 7:0] inputsCmd_1_payload_len;
    wire [ 2:0] inputsCmd_1_payload_size;
    wire [ 1:0] inputsCmd_1_payload_burst;
    wire        inputsCmd_1_payload_write;
    wire        cmdOutputFork_valid;
    wire        cmdOutputFork_ready;
    wire [17:0] cmdOutputFork_payload_addr;
    wire [ 2:0] cmdOutputFork_payload_id;
    wire [ 7:0] cmdOutputFork_payload_len;
    wire [ 2:0] cmdOutputFork_payload_size;
    wire [ 1:0] cmdOutputFork_payload_burst;
    wire        cmdOutputFork_payload_write;
    wire        cmdRouteFork_valid;
    reg         cmdRouteFork_ready;
    wire [17:0] cmdRouteFork_payload_addr;
    wire [ 2:0] cmdRouteFork_payload_id;
    wire [ 7:0] cmdRouteFork_payload_len;
    wire [ 2:0] cmdRouteFork_payload_size;
    wire [ 1:0] cmdRouteFork_payload_burst;
    wire        cmdRouteFork_payload_write;
    reg         axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0;
    reg         axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1;
    wire        when_Stream_l1063;
    wire        when_Stream_l1063_1;
    wire        cmdOutputFork_fire;
    wire        cmdRouteFork_fire;
    wire        _zz_io_output_arw_payload_id;
    wire        when_Stream_l445;
    reg         cmdRouteFork_thrown_valid;
    wire        cmdRouteFork_thrown_ready;
    wire [17:0] cmdRouteFork_thrown_payload_addr;
    wire [ 2:0] cmdRouteFork_thrown_payload_id;
    wire [ 7:0] cmdRouteFork_thrown_payload_len;
    wire [ 2:0] cmdRouteFork_thrown_payload_size;
    wire [ 1:0] cmdRouteFork_thrown_payload_burst;
    wire        cmdRouteFork_thrown_payload_write;
    wire        cmdRouteFork_thrown_translated_valid;
    wire        cmdRouteFork_thrown_translated_ready;
    wire        writeLogic_routeDataInput_valid;
    wire        writeLogic_routeDataInput_ready;
    wire [31:0] writeLogic_routeDataInput_payload_data;
    wire [ 3:0] writeLogic_routeDataInput_payload_strb;
    wire        writeLogic_routeDataInput_payload_last;
    wire        io_output_w_fire;
    wire        writeLogic_writeRspSels_0;
    wire [ 0:0] readRspIndex;
    wire        readRspSels_0;
    wire        readRspSels_1;

    assign _zz__zz_io_output_arw_payload_id = {
        cmdArbiter_io_chosenOH[1:1], cmdArbiter_io_chosenOH[0:0]
    };
    assign _zz_io_output_arw_payload_id_2 = cmdOutputFork_payload_id;
    assign _zz_io_output_arw_payload_id_1 = {1'd0, _zz_io_output_arw_payload_id_2};
    StreamArbiter_1 cmdArbiter (
        .io_inputs_0_valid        (inputsCmd_0_valid),                        //i
        .io_inputs_0_ready        (cmdArbiter_io_inputs_0_ready),             //o
        .io_inputs_0_payload_addr (inputsCmd_0_payload_addr[17:0]),           //i
        .io_inputs_0_payload_id   (inputsCmd_0_payload_id[2:0]),              //i
        .io_inputs_0_payload_len  (inputsCmd_0_payload_len[7:0]),             //i
        .io_inputs_0_payload_size (inputsCmd_0_payload_size[2:0]),            //i
        .io_inputs_0_payload_burst(inputsCmd_0_payload_burst[1:0]),           //i
        .io_inputs_0_payload_write(inputsCmd_0_payload_write),                //i
        .io_inputs_1_valid        (inputsCmd_1_valid),                        //i
        .io_inputs_1_ready        (cmdArbiter_io_inputs_1_ready),             //o
        .io_inputs_1_payload_addr (inputsCmd_1_payload_addr[17:0]),           //i
        .io_inputs_1_payload_id   (inputsCmd_1_payload_id[2:0]),              //i
        .io_inputs_1_payload_len  (inputsCmd_1_payload_len[7:0]),             //i
        .io_inputs_1_payload_size (inputsCmd_1_payload_size[2:0]),            //i
        .io_inputs_1_payload_burst(inputsCmd_1_payload_burst[1:0]),           //i
        .io_inputs_1_payload_write(inputsCmd_1_payload_write),                //i
        .io_output_valid          (cmdArbiter_io_output_valid),               //o
        .io_output_ready          (cmdArbiter_io_output_ready),               //i
        .io_output_payload_addr   (cmdArbiter_io_output_payload_addr[17:0]),  //o
        .io_output_payload_id     (cmdArbiter_io_output_payload_id[2:0]),     //o
        .io_output_payload_len    (cmdArbiter_io_output_payload_len[7:0]),    //o
        .io_output_payload_size   (cmdArbiter_io_output_payload_size[2:0]),   //o
        .io_output_payload_burst  (cmdArbiter_io_output_payload_burst[1:0]),  //o
        .io_output_payload_write  (cmdArbiter_io_output_payload_write),       //o
        .io_chosen                (cmdArbiter_io_chosen),                     //o
        .io_chosenOH              (cmdArbiter_io_chosenOH[1:0]),              //o
        .io_axiClk                (io_axiClk),                                //i
        .resetCtrl_axiReset       (resetCtrl_axiReset)                        //i
    );
    StreamFifoLowLatency_1 cmdRouteFork_thrown_translated_fifo (
        .io_push_valid     (cmdRouteFork_thrown_translated_valid),                      //i
        .io_push_ready     (cmdRouteFork_thrown_translated_fifo_io_push_ready),         //o
        .io_pop_valid      (cmdRouteFork_thrown_translated_fifo_io_pop_valid),          //o
        .io_pop_ready      (cmdRouteFork_thrown_translated_fifo_io_pop_ready),          //i
        .io_flush          (1'b0),                                                      //i
        .io_occupancy      (cmdRouteFork_thrown_translated_fifo_io_occupancy[2:0]),     //o
        .io_availability   (cmdRouteFork_thrown_translated_fifo_io_availability[2:0]),  //o
        .io_axiClk         (io_axiClk),                                                 //i
        .resetCtrl_axiReset(resetCtrl_axiReset)                                         //i
    );
    always @(*) begin
        case (readRspIndex)
            1'b0: _zz_io_output_r_ready = io_readInputs_0_r_ready;
            default: _zz_io_output_r_ready = io_sharedInputs_0_r_ready;
        endcase
    end

    assign inputsCmd_0_valid = io_readInputs_0_ar_valid;
    assign io_readInputs_0_ar_ready = inputsCmd_0_ready;
    assign inputsCmd_0_payload_addr = io_readInputs_0_ar_payload_addr;
    assign inputsCmd_0_payload_id = io_readInputs_0_ar_payload_id;
    assign inputsCmd_0_payload_len = io_readInputs_0_ar_payload_len;
    assign inputsCmd_0_payload_size = io_readInputs_0_ar_payload_size;
    assign inputsCmd_0_payload_burst = io_readInputs_0_ar_payload_burst;
    assign inputsCmd_0_payload_write = 1'b0;
    assign inputsCmd_1_valid = io_sharedInputs_0_arw_valid;
    assign io_sharedInputs_0_arw_ready = inputsCmd_1_ready;
    assign inputsCmd_1_payload_addr = io_sharedInputs_0_arw_payload_addr;
    assign inputsCmd_1_payload_id = io_sharedInputs_0_arw_payload_id;
    assign inputsCmd_1_payload_len = io_sharedInputs_0_arw_payload_len;
    assign inputsCmd_1_payload_size = io_sharedInputs_0_arw_payload_size;
    assign inputsCmd_1_payload_burst = io_sharedInputs_0_arw_payload_burst;
    assign inputsCmd_1_payload_write = io_sharedInputs_0_arw_payload_write;
    assign inputsCmd_0_ready = cmdArbiter_io_inputs_0_ready;
    assign inputsCmd_1_ready = cmdArbiter_io_inputs_1_ready;
    always @(*) begin
        cmdArbiter_io_output_ready = 1'b1;
        if (when_Stream_l1063) begin
            cmdArbiter_io_output_ready = 1'b0;
        end
        if (when_Stream_l1063_1) begin
            cmdArbiter_io_output_ready = 1'b0;
        end
    end

    assign when_Stream_l1063 = ((! cmdOutputFork_ready) && axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0);
    assign when_Stream_l1063_1 = ((! cmdRouteFork_ready) && axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1);
    assign cmdOutputFork_valid = (cmdArbiter_io_output_valid && axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0);
    assign cmdOutputFork_payload_addr = cmdArbiter_io_output_payload_addr;
    assign cmdOutputFork_payload_id = cmdArbiter_io_output_payload_id;
    assign cmdOutputFork_payload_len = cmdArbiter_io_output_payload_len;
    assign cmdOutputFork_payload_size = cmdArbiter_io_output_payload_size;
    assign cmdOutputFork_payload_burst = cmdArbiter_io_output_payload_burst;
    assign cmdOutputFork_payload_write = cmdArbiter_io_output_payload_write;
    assign cmdOutputFork_fire = (cmdOutputFork_valid && cmdOutputFork_ready);
    assign cmdRouteFork_valid = (cmdArbiter_io_output_valid && axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1);
    assign cmdRouteFork_payload_addr = cmdArbiter_io_output_payload_addr;
    assign cmdRouteFork_payload_id = cmdArbiter_io_output_payload_id;
    assign cmdRouteFork_payload_len = cmdArbiter_io_output_payload_len;
    assign cmdRouteFork_payload_size = cmdArbiter_io_output_payload_size;
    assign cmdRouteFork_payload_burst = cmdArbiter_io_output_payload_burst;
    assign cmdRouteFork_payload_write = cmdArbiter_io_output_payload_write;
    assign cmdRouteFork_fire = (cmdRouteFork_valid && cmdRouteFork_ready);
    assign io_output_arw_valid = cmdOutputFork_valid;
    assign cmdOutputFork_ready = io_output_arw_ready;
    assign io_output_arw_payload_addr = cmdOutputFork_payload_addr;
    assign io_output_arw_payload_len = cmdOutputFork_payload_len;
    assign io_output_arw_payload_size = cmdOutputFork_payload_size;
    assign io_output_arw_payload_burst = cmdOutputFork_payload_burst;
    assign io_output_arw_payload_write = cmdOutputFork_payload_write;
    assign _zz_io_output_arw_payload_id = _zz__zz_io_output_arw_payload_id[1];
    assign io_output_arw_payload_id = (cmdOutputFork_payload_write ? _zz_io_output_arw_payload_id_1:{_zz_io_output_arw_payload_id,cmdOutputFork_payload_id});
    assign when_Stream_l445 = (!cmdRouteFork_payload_write);
    always @(*) begin
        cmdRouteFork_thrown_valid = cmdRouteFork_valid;
        if (when_Stream_l445) begin
            cmdRouteFork_thrown_valid = 1'b0;
        end
    end

    always @(*) begin
        cmdRouteFork_ready = cmdRouteFork_thrown_ready;
        if (when_Stream_l445) begin
            cmdRouteFork_ready = 1'b1;
        end
    end

    assign cmdRouteFork_thrown_payload_addr = cmdRouteFork_payload_addr;
    assign cmdRouteFork_thrown_payload_id = cmdRouteFork_payload_id;
    assign cmdRouteFork_thrown_payload_len = cmdRouteFork_payload_len;
    assign cmdRouteFork_thrown_payload_size = cmdRouteFork_payload_size;
    assign cmdRouteFork_thrown_payload_burst = cmdRouteFork_payload_burst;
    assign cmdRouteFork_thrown_payload_write = cmdRouteFork_payload_write;
    assign cmdRouteFork_thrown_translated_valid = cmdRouteFork_thrown_valid;
    assign cmdRouteFork_thrown_ready = cmdRouteFork_thrown_translated_ready;
    assign cmdRouteFork_thrown_translated_ready = cmdRouteFork_thrown_translated_fifo_io_push_ready;
    assign writeLogic_routeDataInput_valid = io_sharedInputs_0_w_valid;
    assign writeLogic_routeDataInput_ready = io_sharedInputs_0_w_ready;
    assign writeLogic_routeDataInput_payload_data = io_sharedInputs_0_w_payload_data;
    assign writeLogic_routeDataInput_payload_strb = io_sharedInputs_0_w_payload_strb;
    assign writeLogic_routeDataInput_payload_last = io_sharedInputs_0_w_payload_last;
    assign io_output_w_valid = (cmdRouteFork_thrown_translated_fifo_io_pop_valid && writeLogic_routeDataInput_valid);
    assign io_output_w_payload_data = writeLogic_routeDataInput_payload_data;
    assign io_output_w_payload_strb = writeLogic_routeDataInput_payload_strb;
    assign io_output_w_payload_last = writeLogic_routeDataInput_payload_last;
    assign io_sharedInputs_0_w_ready = ((cmdRouteFork_thrown_translated_fifo_io_pop_valid && io_output_w_ready) && 1'b1);
    assign io_output_w_fire = (io_output_w_valid && io_output_w_ready);
    assign cmdRouteFork_thrown_translated_fifo_io_pop_ready = (io_output_w_fire && io_output_w_payload_last);
    assign writeLogic_writeRspSels_0 = 1'b1;
    assign io_sharedInputs_0_b_valid = (io_output_b_valid && writeLogic_writeRspSels_0);
    assign io_sharedInputs_0_b_payload_resp = io_output_b_payload_resp;
    assign io_sharedInputs_0_b_payload_id = io_output_b_payload_id[2:0];
    assign io_output_b_ready = io_sharedInputs_0_b_ready;
    assign readRspIndex = io_output_r_payload_id[3:3];
    assign readRspSels_0 = (readRspIndex == 1'b0);
    assign readRspSels_1 = (readRspIndex == 1'b1);
    assign io_readInputs_0_r_valid = (io_output_r_valid && readRspSels_0);
    assign io_readInputs_0_r_payload_data = io_output_r_payload_data;
    assign io_readInputs_0_r_payload_resp = io_output_r_payload_resp;
    assign io_readInputs_0_r_payload_last = io_output_r_payload_last;
    assign io_readInputs_0_r_payload_id = io_output_r_payload_id[2:0];
    assign io_sharedInputs_0_r_valid = (io_output_r_valid && readRspSels_1);
    assign io_sharedInputs_0_r_payload_data = io_output_r_payload_data;
    assign io_sharedInputs_0_r_payload_resp = io_output_r_payload_resp;
    assign io_sharedInputs_0_r_payload_last = io_output_r_payload_last;
    assign io_sharedInputs_0_r_payload_id = io_output_r_payload_id[2:0];
    assign io_output_r_ready = _zz_io_output_r_ready;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
            axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
        end else begin
            if (cmdOutputFork_fire) begin
                axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b0;
            end
            if (cmdRouteFork_fire) begin
                axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b0;
            end
            if (cmdArbiter_io_output_ready) begin
                axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_0 <= 1'b1;
                axi_ram_io_axi_arbiter_cmdArbiter_io_output_fork2_logic_linkEnable_1 <= 1'b1;
            end
        end
    end

endmodule


module Axi4SharedDecoder (
    input  wire        io_input_arw_valid,
    output wire        io_input_arw_ready,
    input  wire [31:0] io_input_arw_payload_addr,
    input  wire [ 7:0] io_input_arw_payload_len,
    input  wire [ 2:0] io_input_arw_payload_size,
    input  wire [ 3:0] io_input_arw_payload_cache,
    input  wire [ 2:0] io_input_arw_payload_prot,
    input  wire        io_input_arw_payload_write,
    input  wire        io_input_w_valid,
    output wire        io_input_w_ready,
    input  wire [31:0] io_input_w_payload_data,
    input  wire [ 3:0] io_input_w_payload_strb,
    input  wire        io_input_w_payload_last,
    output wire        io_input_b_valid,
    input  wire        io_input_b_ready,
    output reg  [ 1:0] io_input_b_payload_resp,
    output wire        io_input_r_valid,
    input  wire        io_input_r_ready,
    output wire [31:0] io_input_r_payload_data,
    output reg  [ 1:0] io_input_r_payload_resp,
    output reg         io_input_r_payload_last,
    output wire        io_sharedOutputs_0_arw_valid,
    input  wire        io_sharedOutputs_0_arw_ready,
    output wire [31:0] io_sharedOutputs_0_arw_payload_addr,
    output wire [ 7:0] io_sharedOutputs_0_arw_payload_len,
    output wire [ 2:0] io_sharedOutputs_0_arw_payload_size,
    output wire [ 3:0] io_sharedOutputs_0_arw_payload_cache,
    output wire [ 2:0] io_sharedOutputs_0_arw_payload_prot,
    output wire        io_sharedOutputs_0_arw_payload_write,
    output wire        io_sharedOutputs_0_w_valid,
    input  wire        io_sharedOutputs_0_w_ready,
    output wire [31:0] io_sharedOutputs_0_w_payload_data,
    output wire [ 3:0] io_sharedOutputs_0_w_payload_strb,
    output wire        io_sharedOutputs_0_w_payload_last,
    input  wire        io_sharedOutputs_0_b_valid,
    output wire        io_sharedOutputs_0_b_ready,
    input  wire [ 1:0] io_sharedOutputs_0_b_payload_resp,
    input  wire        io_sharedOutputs_0_r_valid,
    output wire        io_sharedOutputs_0_r_ready,
    input  wire [31:0] io_sharedOutputs_0_r_payload_data,
    input  wire [ 1:0] io_sharedOutputs_0_r_payload_resp,
    input  wire        io_sharedOutputs_0_r_payload_last,
    output wire        io_sharedOutputs_1_arw_valid,
    input  wire        io_sharedOutputs_1_arw_ready,
    output wire [31:0] io_sharedOutputs_1_arw_payload_addr,
    output wire [ 7:0] io_sharedOutputs_1_arw_payload_len,
    output wire [ 2:0] io_sharedOutputs_1_arw_payload_size,
    output wire [ 3:0] io_sharedOutputs_1_arw_payload_cache,
    output wire [ 2:0] io_sharedOutputs_1_arw_payload_prot,
    output wire        io_sharedOutputs_1_arw_payload_write,
    output wire        io_sharedOutputs_1_w_valid,
    input  wire        io_sharedOutputs_1_w_ready,
    output wire [31:0] io_sharedOutputs_1_w_payload_data,
    output wire [ 3:0] io_sharedOutputs_1_w_payload_strb,
    output wire        io_sharedOutputs_1_w_payload_last,
    input  wire        io_sharedOutputs_1_b_valid,
    output wire        io_sharedOutputs_1_b_ready,
    input  wire [ 1:0] io_sharedOutputs_1_b_payload_resp,
    input  wire        io_sharedOutputs_1_r_valid,
    output wire        io_sharedOutputs_1_r_ready,
    input  wire [31:0] io_sharedOutputs_1_r_payload_data,
    input  wire [ 1:0] io_sharedOutputs_1_r_payload_resp,
    input  wire        io_sharedOutputs_1_r_payload_last,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    wire        errorSlave_io_axi_arw_valid;
    wire        errorSlave_io_axi_w_valid;
    wire        errorSlave_io_axi_arw_ready;
    wire        errorSlave_io_axi_w_ready;
    wire        errorSlave_io_axi_b_valid;
    wire [ 1:0] errorSlave_io_axi_b_payload_resp;
    wire        errorSlave_io_axi_r_valid;
    wire [31:0] errorSlave_io_axi_r_payload_data;
    wire [ 1:0] errorSlave_io_axi_r_payload_resp;
    wire        errorSlave_io_axi_r_payload_last;
    wire [ 1:0] _zz__zz_writeRspIndex;
    reg  [ 1:0] _zz_io_input_b_payload_resp;
    wire [ 1:0] _zz__zz_readRspIndex;
    reg  [31:0] _zz_io_input_r_payload_data;
    reg  [ 1:0] _zz_io_input_r_payload_resp;
    reg         _zz_io_input_r_payload_last;
    reg  [ 2:0] _zz_pendingCmdCounter;
    reg  [ 2:0] _zz_pendingCmdCounter_1;
    reg  [ 2:0] _zz_pendingCmdCounter_2;
    wire        cmdAllowedStart;
    wire        io_input_arw_fire;
    wire        io_input_b_fire;
    wire        io_input_r_fire;
    wire        when_Utils_l766;
    reg  [ 2:0] pendingCmdCounter;
    wire [ 2:0] _zz_pendingCmdCounter_3;
    wire        when_Utils_l706;
    wire        io_input_w_fire;
    wire        when_Utils_l709;
    reg         pendingDataCounter_incrementIt;
    reg         pendingDataCounter_decrementIt;
    wire [ 2:0] pendingDataCounter_valueNext;
    reg  [ 2:0] pendingDataCounter_value;
    wire        pendingDataCounter_mayOverflow;
    wire        pendingDataCounter_willOverflowIfInc;
    wire        pendingDataCounter_willOverflow;
    reg  [ 2:0] pendingDataCounter_finalIncrement;
    wire        when_Utils_l735;
    wire        when_Utils_l737;
    wire [ 1:0] decodedCmdSels;
    wire        decodedCmdError;
    reg  [ 1:0] pendingSels;
    reg         pendingError;
    wire        allowCmd;
    wire        allowData;
    reg         _zz_cmdAllowedStart;
    wire [ 1:0] _zz_io_sharedOutputs_0_arw_valid;
    wire [ 1:0] _zz_io_sharedOutputs_0_w_valid;
    wire        _zz_writeRspIndex;
    wire [ 0:0] writeRspIndex;
    wire        _zz_readRspIndex;
    wire [ 0:0] readRspIndex;

    assign _zz__zz_writeRspIndex = pendingSels[1:0];
    assign _zz__zz_readRspIndex  = pendingSels[1:0];
    Axi4SharedErrorSlave errorSlave (
        .io_axi_arw_valid        (errorSlave_io_axi_arw_valid),             //i
        .io_axi_arw_ready        (errorSlave_io_axi_arw_ready),             //o
        .io_axi_arw_payload_addr (io_input_arw_payload_addr[31:0]),         //i
        .io_axi_arw_payload_len  (io_input_arw_payload_len[7:0]),           //i
        .io_axi_arw_payload_size (io_input_arw_payload_size[2:0]),          //i
        .io_axi_arw_payload_cache(io_input_arw_payload_cache[3:0]),         //i
        .io_axi_arw_payload_prot (io_input_arw_payload_prot[2:0]),          //i
        .io_axi_arw_payload_write(io_input_arw_payload_write),              //i
        .io_axi_w_valid          (errorSlave_io_axi_w_valid),               //i
        .io_axi_w_ready          (errorSlave_io_axi_w_ready),               //o
        .io_axi_w_payload_data   (io_input_w_payload_data[31:0]),           //i
        .io_axi_w_payload_strb   (io_input_w_payload_strb[3:0]),            //i
        .io_axi_w_payload_last   (io_input_w_payload_last),                 //i
        .io_axi_b_valid          (errorSlave_io_axi_b_valid),               //o
        .io_axi_b_ready          (io_input_b_ready),                        //i
        .io_axi_b_payload_resp   (errorSlave_io_axi_b_payload_resp[1:0]),   //o
        .io_axi_r_valid          (errorSlave_io_axi_r_valid),               //o
        .io_axi_r_ready          (io_input_r_ready),                        //i
        .io_axi_r_payload_data   (errorSlave_io_axi_r_payload_data[31:0]),  //o
        .io_axi_r_payload_resp   (errorSlave_io_axi_r_payload_resp[1:0]),   //o
        .io_axi_r_payload_last   (errorSlave_io_axi_r_payload_last),        //o
        .io_axiClk               (io_axiClk),                               //i
        .resetCtrl_axiReset      (resetCtrl_axiReset)                       //i
    );
    always @(*) begin
        case (writeRspIndex)
            1'b0: _zz_io_input_b_payload_resp = io_sharedOutputs_0_b_payload_resp;
            default: _zz_io_input_b_payload_resp = io_sharedOutputs_1_b_payload_resp;
        endcase
    end

    always @(*) begin
        case (readRspIndex)
            1'b0: begin
                _zz_io_input_r_payload_data = io_sharedOutputs_0_r_payload_data;
                _zz_io_input_r_payload_resp = io_sharedOutputs_0_r_payload_resp;
                _zz_io_input_r_payload_last = io_sharedOutputs_0_r_payload_last;
            end
            default: begin
                _zz_io_input_r_payload_data = io_sharedOutputs_1_r_payload_data;
                _zz_io_input_r_payload_resp = io_sharedOutputs_1_r_payload_resp;
                _zz_io_input_r_payload_last = io_sharedOutputs_1_r_payload_last;
            end
        endcase
    end

    always @(*) begin
        _zz_pendingCmdCounter = _zz_pendingCmdCounter_1;
        if (when_Utils_l766) begin
            _zz_pendingCmdCounter = (_zz_pendingCmdCounter_1 - 3'b001);
        end
    end

    always @(*) begin
        _zz_pendingCmdCounter_1 = _zz_pendingCmdCounter_2;
        if (io_input_b_fire) begin
            _zz_pendingCmdCounter_1 = (_zz_pendingCmdCounter_2 - 3'b001);
        end
    end

    always @(*) begin
        _zz_pendingCmdCounter_2 = _zz_pendingCmdCounter_3;
        if (io_input_arw_fire) begin
            _zz_pendingCmdCounter_2 = (_zz_pendingCmdCounter_3 + 3'b001);
        end
    end

    assign io_input_arw_fire = (io_input_arw_valid && io_input_arw_ready);
    assign io_input_b_fire = (io_input_b_valid && io_input_b_ready);
    assign io_input_r_fire = (io_input_r_valid && io_input_r_ready);
    assign when_Utils_l766 = (io_input_r_fire && io_input_r_payload_last);
    assign _zz_pendingCmdCounter_3 = pendingCmdCounter;
    assign when_Utils_l706 = (cmdAllowedStart && io_input_arw_payload_write);
    assign io_input_w_fire = (io_input_w_valid && io_input_w_ready);
    assign when_Utils_l709 = (io_input_w_fire && io_input_w_payload_last);
    always @(*) begin
        pendingDataCounter_incrementIt = 1'b0;
        if (when_Utils_l706) begin
            pendingDataCounter_incrementIt = 1'b1;
        end
    end

    always @(*) begin
        pendingDataCounter_decrementIt = 1'b0;
        if (when_Utils_l709) begin
            pendingDataCounter_decrementIt = 1'b1;
        end
    end

    assign pendingDataCounter_mayOverflow = (pendingDataCounter_value == 3'b111);
    assign pendingDataCounter_willOverflowIfInc = (pendingDataCounter_mayOverflow && (! pendingDataCounter_decrementIt));
    assign pendingDataCounter_willOverflow = (pendingDataCounter_willOverflowIfInc && pendingDataCounter_incrementIt);
    assign when_Utils_l735 = (pendingDataCounter_incrementIt && (!pendingDataCounter_decrementIt));
    always @(*) begin
        if (when_Utils_l735) begin
            pendingDataCounter_finalIncrement = 3'b001;
        end else begin
            if (when_Utils_l737) begin
                pendingDataCounter_finalIncrement = 3'b111;
            end else begin
                pendingDataCounter_finalIncrement = 3'b000;
            end
        end
    end

    assign when_Utils_l737 = ((!pendingDataCounter_incrementIt) && pendingDataCounter_decrementIt);
    assign pendingDataCounter_valueNext = (pendingDataCounter_value + pendingDataCounter_finalIncrement);
    assign decodedCmdSels = {
        ((io_input_arw_payload_addr & (~32'h000fffff)) == 32'hf0000000),
        ((io_input_arw_payload_addr & (~32'h0003ffff)) == 32'h80000000)
    };
    assign decodedCmdError = (decodedCmdSels == 2'b00);
    assign allowCmd = ((pendingCmdCounter == 3'b000) || ((pendingCmdCounter != 3'b111) && (pendingSels == decodedCmdSels)));
    assign allowData = (pendingDataCounter_value != 3'b000);
    assign cmdAllowedStart = ((io_input_arw_valid && allowCmd) && _zz_cmdAllowedStart);
    assign io_input_arw_ready = (((|(decodedCmdSels & {io_sharedOutputs_1_arw_ready,io_sharedOutputs_0_arw_ready})) || (decodedCmdError && errorSlave_io_axi_arw_ready)) && allowCmd);
    assign errorSlave_io_axi_arw_valid = ((io_input_arw_valid && decodedCmdError) && allowCmd);
    assign _zz_io_sharedOutputs_0_arw_valid = decodedCmdSels[1:0];
    assign io_sharedOutputs_0_arw_valid = ((io_input_arw_valid && _zz_io_sharedOutputs_0_arw_valid[0]) && allowCmd);
    assign io_sharedOutputs_0_arw_payload_addr = io_input_arw_payload_addr;
    assign io_sharedOutputs_0_arw_payload_len = io_input_arw_payload_len;
    assign io_sharedOutputs_0_arw_payload_size = io_input_arw_payload_size;
    assign io_sharedOutputs_0_arw_payload_cache = io_input_arw_payload_cache;
    assign io_sharedOutputs_0_arw_payload_prot = io_input_arw_payload_prot;
    assign io_sharedOutputs_0_arw_payload_write = io_input_arw_payload_write;
    assign io_sharedOutputs_1_arw_valid = ((io_input_arw_valid && _zz_io_sharedOutputs_0_arw_valid[1]) && allowCmd);
    assign io_sharedOutputs_1_arw_payload_addr = io_input_arw_payload_addr;
    assign io_sharedOutputs_1_arw_payload_len = io_input_arw_payload_len;
    assign io_sharedOutputs_1_arw_payload_size = io_input_arw_payload_size;
    assign io_sharedOutputs_1_arw_payload_cache = io_input_arw_payload_cache;
    assign io_sharedOutputs_1_arw_payload_prot = io_input_arw_payload_prot;
    assign io_sharedOutputs_1_arw_payload_write = io_input_arw_payload_write;
    assign io_input_w_ready = (((|(pendingSels[1:0] & {io_sharedOutputs_1_w_ready,io_sharedOutputs_0_w_ready})) || (pendingError && errorSlave_io_axi_w_ready)) && allowData);
    assign errorSlave_io_axi_w_valid = ((io_input_w_valid && pendingError) && allowData);
    assign _zz_io_sharedOutputs_0_w_valid = pendingSels[1:0];
    assign io_sharedOutputs_0_w_valid = ((io_input_w_valid && _zz_io_sharedOutputs_0_w_valid[0]) && allowData);
    assign io_sharedOutputs_0_w_payload_data = io_input_w_payload_data;
    assign io_sharedOutputs_0_w_payload_strb = io_input_w_payload_strb;
    assign io_sharedOutputs_0_w_payload_last = io_input_w_payload_last;
    assign io_sharedOutputs_1_w_valid = ((io_input_w_valid && _zz_io_sharedOutputs_0_w_valid[1]) && allowData);
    assign io_sharedOutputs_1_w_payload_data = io_input_w_payload_data;
    assign io_sharedOutputs_1_w_payload_strb = io_input_w_payload_strb;
    assign io_sharedOutputs_1_w_payload_last = io_input_w_payload_last;
    assign _zz_writeRspIndex = _zz__zz_writeRspIndex[1];
    assign writeRspIndex = _zz_writeRspIndex;
    assign io_input_b_valid = ((|{io_sharedOutputs_1_b_valid,io_sharedOutputs_0_b_valid}) || errorSlave_io_axi_b_valid);
    always @(*) begin
        io_input_b_payload_resp = _zz_io_input_b_payload_resp;
        if (pendingError) begin
            io_input_b_payload_resp = errorSlave_io_axi_b_payload_resp;
        end
    end

    assign io_sharedOutputs_0_b_ready = io_input_b_ready;
    assign io_sharedOutputs_1_b_ready = io_input_b_ready;
    assign _zz_readRspIndex = _zz__zz_readRspIndex[1];
    assign readRspIndex = _zz_readRspIndex;
    assign io_input_r_valid = ((|{io_sharedOutputs_1_r_valid,io_sharedOutputs_0_r_valid}) || errorSlave_io_axi_r_valid);
    assign io_input_r_payload_data = _zz_io_input_r_payload_data;
    always @(*) begin
        io_input_r_payload_resp = _zz_io_input_r_payload_resp;
        if (pendingError) begin
            io_input_r_payload_resp = errorSlave_io_axi_r_payload_resp;
        end
    end

    always @(*) begin
        io_input_r_payload_last = _zz_io_input_r_payload_last;
        if (pendingError) begin
            io_input_r_payload_last = errorSlave_io_axi_r_payload_last;
        end
    end

    assign io_sharedOutputs_0_r_ready = io_input_r_ready;
    assign io_sharedOutputs_1_r_ready = io_input_r_ready;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            pendingCmdCounter <= 3'b000;
            pendingDataCounter_value <= 3'b000;
            pendingSels <= 2'b00;
            pendingError <= 1'b0;
            _zz_cmdAllowedStart <= 1'b1;
        end else begin
            pendingCmdCounter <= _zz_pendingCmdCounter;
            pendingDataCounter_value <= pendingDataCounter_valueNext;
            if (cmdAllowedStart) begin
                pendingSels <= decodedCmdSels;
            end
            if (cmdAllowedStart) begin
                pendingError <= decodedCmdError;
            end
            if (cmdAllowedStart) begin
                _zz_cmdAllowedStart <= 1'b0;
            end
            if (io_input_arw_ready) begin
                _zz_cmdAllowedStart <= 1'b1;
            end
        end
    end

endmodule


module Axi4ReadOnlyDecoder (
    input  wire        io_input_ar_valid,
    output wire        io_input_ar_ready,
    input  wire [31:0] io_input_ar_payload_addr,
    input  wire [ 7:0] io_input_ar_payload_len,
    input  wire [ 1:0] io_input_ar_payload_burst,
    input  wire [ 3:0] io_input_ar_payload_cache,
    input  wire [ 2:0] io_input_ar_payload_prot,
    output reg         io_input_r_valid,
    input  wire        io_input_r_ready,
    output wire [31:0] io_input_r_payload_data,
    output reg  [ 1:0] io_input_r_payload_resp,
    output reg         io_input_r_payload_last,
    output wire        io_outputs_0_ar_valid,
    input  wire        io_outputs_0_ar_ready,
    output wire [31:0] io_outputs_0_ar_payload_addr,
    output wire [ 7:0] io_outputs_0_ar_payload_len,
    output wire [ 1:0] io_outputs_0_ar_payload_burst,
    output wire [ 3:0] io_outputs_0_ar_payload_cache,
    output wire [ 2:0] io_outputs_0_ar_payload_prot,
    input  wire        io_outputs_0_r_valid,
    output wire        io_outputs_0_r_ready,
    input  wire [31:0] io_outputs_0_r_payload_data,
    input  wire [ 1:0] io_outputs_0_r_payload_resp,
    input  wire        io_outputs_0_r_payload_last,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    wire        errorSlave_io_axi_ar_valid;
    wire        errorSlave_io_axi_ar_ready;
    wire        errorSlave_io_axi_r_valid;
    wire [31:0] errorSlave_io_axi_r_payload_data;
    wire [ 1:0] errorSlave_io_axi_r_payload_resp;
    wire        errorSlave_io_axi_r_payload_last;
    wire        io_input_ar_fire;
    wire        io_input_r_fire;
    wire        when_Utils_l709;
    reg         pendingCmdCounter_incrementIt;
    reg         pendingCmdCounter_decrementIt;
    wire [ 2:0] pendingCmdCounter_valueNext;
    reg  [ 2:0] pendingCmdCounter_value;
    wire        pendingCmdCounter_mayOverflow;
    wire        pendingCmdCounter_willOverflowIfInc;
    wire        pendingCmdCounter_willOverflow;
    reg  [ 2:0] pendingCmdCounter_finalIncrement;
    wire        when_Utils_l735;
    wire        when_Utils_l737;
    wire [ 0:0] decodedCmdSels;
    wire        decodedCmdError;
    reg  [ 0:0] pendingSels;
    reg         pendingError;
    wire        allowCmd;

    Axi4ReadOnlyErrorSlave errorSlave (
        .io_axi_ar_valid        (errorSlave_io_axi_ar_valid),              //i
        .io_axi_ar_ready        (errorSlave_io_axi_ar_ready),              //o
        .io_axi_ar_payload_addr (io_input_ar_payload_addr[31:0]),          //i
        .io_axi_ar_payload_len  (io_input_ar_payload_len[7:0]),            //i
        .io_axi_ar_payload_burst(io_input_ar_payload_burst[1:0]),          //i
        .io_axi_ar_payload_cache(io_input_ar_payload_cache[3:0]),          //i
        .io_axi_ar_payload_prot (io_input_ar_payload_prot[2:0]),           //i
        .io_axi_r_valid         (errorSlave_io_axi_r_valid),               //o
        .io_axi_r_ready         (io_input_r_ready),                        //i
        .io_axi_r_payload_data  (errorSlave_io_axi_r_payload_data[31:0]),  //o
        .io_axi_r_payload_resp  (errorSlave_io_axi_r_payload_resp[1:0]),   //o
        .io_axi_r_payload_last  (errorSlave_io_axi_r_payload_last),        //o
        .io_axiClk              (io_axiClk),                               //i
        .resetCtrl_axiReset     (resetCtrl_axiReset)                       //i
    );
    assign io_input_ar_fire = (io_input_ar_valid && io_input_ar_ready);
    assign io_input_r_fire  = (io_input_r_valid && io_input_r_ready);
    assign when_Utils_l709  = (io_input_r_fire && io_input_r_payload_last);
    always @(*) begin
        pendingCmdCounter_incrementIt = 1'b0;
        if (io_input_ar_fire) begin
            pendingCmdCounter_incrementIt = 1'b1;
        end
    end

    always @(*) begin
        pendingCmdCounter_decrementIt = 1'b0;
        if (when_Utils_l709) begin
            pendingCmdCounter_decrementIt = 1'b1;
        end
    end

    assign pendingCmdCounter_mayOverflow = (pendingCmdCounter_value == 3'b111);
    assign pendingCmdCounter_willOverflowIfInc = (pendingCmdCounter_mayOverflow && (! pendingCmdCounter_decrementIt));
    assign pendingCmdCounter_willOverflow = (pendingCmdCounter_willOverflowIfInc && pendingCmdCounter_incrementIt);
    assign when_Utils_l735 = (pendingCmdCounter_incrementIt && (!pendingCmdCounter_decrementIt));
    always @(*) begin
        if (when_Utils_l735) begin
            pendingCmdCounter_finalIncrement = 3'b001;
        end else begin
            if (when_Utils_l737) begin
                pendingCmdCounter_finalIncrement = 3'b111;
            end else begin
                pendingCmdCounter_finalIncrement = 3'b000;
            end
        end
    end

    assign when_Utils_l737 = ((!pendingCmdCounter_incrementIt) && pendingCmdCounter_decrementIt);
    assign pendingCmdCounter_valueNext = (pendingCmdCounter_value + pendingCmdCounter_finalIncrement);
    assign decodedCmdSels = (((io_input_ar_payload_addr & (~ 32'h0003ffff)) == 32'h80000000) && io_input_ar_valid);
    assign decodedCmdError = (decodedCmdSels == 1'b0);
    assign allowCmd = ((pendingCmdCounter_value == 3'b000) || ((pendingCmdCounter_value != 3'b111) && (pendingSels == decodedCmdSels)));
    assign io_input_ar_ready = (((|(decodedCmdSels & io_outputs_0_ar_ready)) || (decodedCmdError && errorSlave_io_axi_ar_ready)) && allowCmd);
    assign errorSlave_io_axi_ar_valid = ((io_input_ar_valid && decodedCmdError) && allowCmd);
    assign io_outputs_0_ar_valid = ((io_input_ar_valid && decodedCmdSels[0]) && allowCmd);
    assign io_outputs_0_ar_payload_addr = io_input_ar_payload_addr;
    assign io_outputs_0_ar_payload_len = io_input_ar_payload_len;
    assign io_outputs_0_ar_payload_burst = io_input_ar_payload_burst;
    assign io_outputs_0_ar_payload_cache = io_input_ar_payload_cache;
    assign io_outputs_0_ar_payload_prot = io_input_ar_payload_prot;
    always @(*) begin
        io_input_r_valid = (|io_outputs_0_r_valid);
        if (errorSlave_io_axi_r_valid) begin
            io_input_r_valid = 1'b1;
        end
    end

    assign io_input_r_payload_data = io_outputs_0_r_payload_data;
    always @(*) begin
        io_input_r_payload_resp = io_outputs_0_r_payload_resp;
        if (pendingError) begin
            io_input_r_payload_resp = errorSlave_io_axi_r_payload_resp;
        end
    end

    always @(*) begin
        io_input_r_payload_last = io_outputs_0_r_payload_last;
        if (pendingError) begin
            io_input_r_payload_last = errorSlave_io_axi_r_payload_last;
        end
    end

    assign io_outputs_0_r_ready = io_input_r_ready;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            pendingCmdCounter_value <= 3'b000;
            pendingSels <= 1'b0;
            pendingError <= 1'b0;
        end else begin
            pendingCmdCounter_value <= pendingCmdCounter_valueNext;
            if (io_input_ar_ready) begin
                pendingSels <= decodedCmdSels;
            end
            if (io_input_ar_ready) begin
                pendingError <= decodedCmdError;
            end
        end
    end

endmodule


module SystemDebugger (
    input  wire        io_remote_cmd_valid,
    output wire        io_remote_cmd_ready,
    input  wire        io_remote_cmd_payload_last,
    input  wire [ 0:0] io_remote_cmd_payload_fragment,
    output wire        io_remote_rsp_valid,
    input  wire        io_remote_rsp_ready,
    output wire        io_remote_rsp_payload_error,
    output wire [31:0] io_remote_rsp_payload_data,
    output wire        io_mem_cmd_valid,
    input  wire        io_mem_cmd_ready,
    output wire [31:0] io_mem_cmd_payload_address,
    output wire [31:0] io_mem_cmd_payload_data,
    output wire        io_mem_cmd_payload_wr,
    output wire [ 1:0] io_mem_cmd_payload_size,
    input  wire        io_mem_rsp_valid,
    input  wire [31:0] io_mem_rsp_payload,
    input  wire        io_axiClk,
    input  wire        resetCtrl_systemReset
);

    reg  [66:0] dispatcher_dataShifter;
    reg         dispatcher_dataLoaded;
    reg  [ 7:0] dispatcher_headerShifter;
    wire [ 7:0] dispatcher_header;
    reg         dispatcher_headerLoaded;
    reg  [ 2:0] dispatcher_counter;
    wire        when_Fragment_l356;
    wire        when_Fragment_l359;
    wire [66:0] _zz_io_mem_cmd_payload_address;
    wire        io_mem_cmd_isStall;
    wire        when_Fragment_l382;

    assign dispatcher_header = dispatcher_headerShifter[7:0];
    assign when_Fragment_l356 = (dispatcher_headerLoaded == 1'b0);
    assign when_Fragment_l359 = (dispatcher_counter == 3'b111);
    assign io_remote_cmd_ready = (!dispatcher_dataLoaded);
    assign _zz_io_mem_cmd_payload_address = dispatcher_dataShifter[66:0];
    assign io_mem_cmd_payload_address = _zz_io_mem_cmd_payload_address[31:0];
    assign io_mem_cmd_payload_data = _zz_io_mem_cmd_payload_address[63:32];
    assign io_mem_cmd_payload_wr = _zz_io_mem_cmd_payload_address[64];
    assign io_mem_cmd_payload_size = _zz_io_mem_cmd_payload_address[66:65];
    assign io_mem_cmd_valid = (dispatcher_dataLoaded && (dispatcher_header == 8'h0));
    assign io_mem_cmd_isStall = (io_mem_cmd_valid && (!io_mem_cmd_ready));
    assign when_Fragment_l382 = ((dispatcher_headerLoaded && dispatcher_dataLoaded) && (! io_mem_cmd_isStall));
    assign io_remote_rsp_valid = io_mem_rsp_valid;
    assign io_remote_rsp_payload_error = 1'b0;
    assign io_remote_rsp_payload_data = io_mem_rsp_payload;
    always @(posedge io_axiClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            dispatcher_dataLoaded <= 1'b0;
            dispatcher_headerLoaded <= 1'b0;
            dispatcher_counter <= 3'b000;
        end else begin
            if (io_remote_cmd_valid) begin
                if (when_Fragment_l356) begin
                    dispatcher_counter <= (dispatcher_counter + 3'b001);
                    if (when_Fragment_l359) begin
                        dispatcher_headerLoaded <= 1'b1;
                    end
                end
                if (io_remote_cmd_payload_last) begin
                    dispatcher_headerLoaded <= 1'b1;
                    dispatcher_dataLoaded <= 1'b1;
                    dispatcher_counter <= 3'b000;
                end
            end
            if (when_Fragment_l382) begin
                dispatcher_headerLoaded <= 1'b0;
                dispatcher_dataLoaded   <= 1'b0;
            end
        end
    end

    always @(posedge io_axiClk) begin
        if (io_remote_cmd_valid) begin
            if (when_Fragment_l356) begin
                dispatcher_headerShifter <= ({io_remote_cmd_payload_fragment,dispatcher_headerShifter} >>> 1'd1);
            end else begin
                dispatcher_dataShifter <= ({io_remote_cmd_payload_fragment,dispatcher_dataShifter} >>> 1'd1);
            end
        end
    end

endmodule


module JtagBridge (
    input  wire        io_jtag_tms,
    input  wire        io_jtag_tdi,
    output wire        io_jtag_tdo,
    input  wire        io_jtag_tck,
    output wire        io_remote_cmd_valid,
    input  wire        io_remote_cmd_ready,
    output wire        io_remote_cmd_payload_last,
    output wire [ 0:0] io_remote_cmd_payload_fragment,
    input  wire        io_remote_rsp_valid,
    output wire        io_remote_rsp_ready,
    input  wire        io_remote_rsp_payload_error,
    input  wire [31:0] io_remote_rsp_payload_data,
    input  wire        io_axiClk,
    input  wire        resetCtrl_systemReset
);
    localparam JtagState_RESET = 4'd0;
    localparam JtagState_IDLE = 4'd1;
    localparam JtagState_IR_SELECT = 4'd2;
    localparam JtagState_IR_CAPTURE = 4'd3;
    localparam JtagState_IR_SHIFT = 4'd4;
    localparam JtagState_IR_EXIT1 = 4'd5;
    localparam JtagState_IR_PAUSE = 4'd6;
    localparam JtagState_IR_EXIT2 = 4'd7;
    localparam JtagState_IR_UPDATE = 4'd8;
    localparam JtagState_DR_SELECT = 4'd9;
    localparam JtagState_DR_CAPTURE = 4'd10;
    localparam JtagState_DR_SHIFT = 4'd11;
    localparam JtagState_DR_EXIT1 = 4'd12;
    localparam JtagState_DR_PAUSE = 4'd13;
    localparam JtagState_DR_EXIT2 = 4'd14;
    localparam JtagState_DR_UPDATE = 4'd15;

    wire        flowCCUnsafeByToggle_1_io_output_valid;
    wire        flowCCUnsafeByToggle_1_io_output_payload_last;
    wire [ 0:0] flowCCUnsafeByToggle_1_io_output_payload_fragment;
    wire [ 3:0] _zz_jtag_tap_isBypass;
    wire [ 1:0] _zz_jtag_tap_instructionShift;
    wire        system_cmd_valid;
    wire        system_cmd_payload_last;
    wire [ 0:0] system_cmd_payload_fragment;
    wire        system_cmd_toStream_valid;
    wire        system_cmd_toStream_ready;
    wire        system_cmd_toStream_payload_last;
    wire [ 0:0] system_cmd_toStream_payload_fragment;
    (* async_reg = "true" *)reg         system_rsp_valid;
    (* async_reg = "true" *)reg         system_rsp_payload_error;
    (* async_reg = "true" *)reg  [31:0] system_rsp_payload_data;
    wire        io_remote_rsp_fire;
    reg  [ 3:0] jtag_tap_fsm_stateNext;
    reg  [ 3:0] jtag_tap_fsm_state;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_1;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_2;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_3;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_4;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_5;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_6;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_7;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_8;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_9;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_10;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_11;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_12;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_13;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_14;
    wire [ 3:0] _zz_jtag_tap_fsm_stateNext_15;
    reg  [ 3:0] jtag_tap_instruction;
    reg  [ 3:0] jtag_tap_instructionShift;
    reg         jtag_tap_bypass;
    reg         jtag_tap_tdoUnbufferd;
    reg         jtag_tap_tdoDr;
    wire        jtag_tap_tdoIr;
    wire        jtag_tap_isBypass;
    reg         jtag_tap_tdoUnbufferd_regNext;
    wire        jtag_idcodeArea_ctrl_tdi;
    wire        jtag_idcodeArea_ctrl_enable;
    wire        jtag_idcodeArea_ctrl_capture;
    wire        jtag_idcodeArea_ctrl_shift;
    wire        jtag_idcodeArea_ctrl_update;
    wire        jtag_idcodeArea_ctrl_reset;
    wire        jtag_idcodeArea_ctrl_tdo;
    reg  [31:0] jtag_idcodeArea_shifter;
    wire        when_JtagTap_l121;
    wire        jtag_writeArea_ctrl_tdi;
    wire        jtag_writeArea_ctrl_enable;
    wire        jtag_writeArea_ctrl_capture;
    wire        jtag_writeArea_ctrl_shift;
    wire        jtag_writeArea_ctrl_update;
    wire        jtag_writeArea_ctrl_reset;
    wire        jtag_writeArea_ctrl_tdo;
    wire        jtag_writeArea_source_valid;
    wire        jtag_writeArea_source_payload_last;
    wire [ 0:0] jtag_writeArea_source_payload_fragment;
    reg         jtag_writeArea_valid;
    reg         jtag_writeArea_data;
    wire        jtag_readArea_ctrl_tdi;
    wire        jtag_readArea_ctrl_enable;
    wire        jtag_readArea_ctrl_capture;
    wire        jtag_readArea_ctrl_shift;
    wire        jtag_readArea_ctrl_update;
    wire        jtag_readArea_ctrl_reset;
    wire        jtag_readArea_ctrl_tdo;
    reg  [33:0] jtag_readArea_full_shifter;
`ifndef SYNTHESIS
    reg [79:0] jtag_tap_fsm_stateNext_string;
    reg [79:0] jtag_tap_fsm_state_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_1_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_2_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_3_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_4_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_5_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_6_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_7_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_8_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_9_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_10_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_11_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_12_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_13_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_14_string;
    reg [79:0] _zz_jtag_tap_fsm_stateNext_15_string;
`endif


    assign _zz_jtag_tap_isBypass = jtag_tap_instruction;
    assign _zz_jtag_tap_instructionShift = 2'b01;
    FlowCCUnsafeByToggle FlowCCUnsafeByToggle (
        .io_input_valid            (jtag_writeArea_source_valid),                        //i
        .io_input_payload_last     (jtag_writeArea_source_payload_last),                 //i
        .io_input_payload_fragment (jtag_writeArea_source_payload_fragment),             //i
        .io_output_valid           (flowCCUnsafeByToggle_1_io_output_valid),             //o
        .io_output_payload_last    (flowCCUnsafeByToggle_1_io_output_payload_last),      //o
        .io_output_payload_fragment(flowCCUnsafeByToggle_1_io_output_payload_fragment),  //o
        .io_jtag_tck               (io_jtag_tck),                                        //i
        .io_axiClk                 (io_axiClk),                                          //i
        .resetCtrl_systemReset     (resetCtrl_systemReset)                               //i
    );
    initial begin
`ifndef SYNTHESIS
        jtag_tap_fsm_state = {$urandom};
`endif
    end

`ifndef SYNTHESIS
    always @(*) begin
        case (jtag_tap_fsm_stateNext)
            JtagState_RESET: jtag_tap_fsm_stateNext_string = "RESET     ";
            JtagState_IDLE: jtag_tap_fsm_stateNext_string = "IDLE      ";
            JtagState_IR_SELECT: jtag_tap_fsm_stateNext_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: jtag_tap_fsm_stateNext_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: jtag_tap_fsm_stateNext_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: jtag_tap_fsm_stateNext_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: jtag_tap_fsm_stateNext_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: jtag_tap_fsm_stateNext_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: jtag_tap_fsm_stateNext_string = "IR_UPDATE ";
            JtagState_DR_SELECT: jtag_tap_fsm_stateNext_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: jtag_tap_fsm_stateNext_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: jtag_tap_fsm_stateNext_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: jtag_tap_fsm_stateNext_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: jtag_tap_fsm_stateNext_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: jtag_tap_fsm_stateNext_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: jtag_tap_fsm_stateNext_string = "DR_UPDATE ";
            default: jtag_tap_fsm_stateNext_string = "??????????";
        endcase
    end
    always @(*) begin
        case (jtag_tap_fsm_state)
            JtagState_RESET: jtag_tap_fsm_state_string = "RESET     ";
            JtagState_IDLE: jtag_tap_fsm_state_string = "IDLE      ";
            JtagState_IR_SELECT: jtag_tap_fsm_state_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: jtag_tap_fsm_state_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: jtag_tap_fsm_state_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: jtag_tap_fsm_state_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: jtag_tap_fsm_state_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: jtag_tap_fsm_state_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: jtag_tap_fsm_state_string = "IR_UPDATE ";
            JtagState_DR_SELECT: jtag_tap_fsm_state_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: jtag_tap_fsm_state_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: jtag_tap_fsm_state_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: jtag_tap_fsm_state_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: jtag_tap_fsm_state_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: jtag_tap_fsm_state_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: jtag_tap_fsm_state_string = "DR_UPDATE ";
            default: jtag_tap_fsm_state_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_1)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_1_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_1_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_1_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_1_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_1_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_1_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_1_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_1_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_1_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_1_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_1_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_1_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_1_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_1_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_1_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_1_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_1_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_2)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_2_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_2_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_2_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_2_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_2_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_2_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_2_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_2_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_2_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_2_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_2_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_2_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_2_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_2_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_2_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_2_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_2_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_3)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_3_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_3_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_3_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_3_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_3_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_3_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_3_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_3_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_3_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_3_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_3_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_3_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_3_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_3_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_3_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_3_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_3_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_4)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_4_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_4_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_4_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_4_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_4_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_4_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_4_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_4_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_4_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_4_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_4_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_4_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_4_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_4_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_4_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_4_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_4_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_5)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_5_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_5_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_5_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_5_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_5_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_5_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_5_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_5_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_5_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_5_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_5_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_5_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_5_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_5_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_5_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_5_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_5_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_6)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_6_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_6_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_6_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_6_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_6_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_6_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_6_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_6_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_6_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_6_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_6_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_6_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_6_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_6_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_6_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_6_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_6_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_7)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_7_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_7_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_7_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_7_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_7_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_7_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_7_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_7_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_7_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_7_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_7_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_7_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_7_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_7_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_7_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_7_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_7_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_8)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_8_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_8_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_8_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_8_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_8_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_8_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_8_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_8_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_8_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_8_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_8_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_8_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_8_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_8_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_8_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_8_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_8_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_9)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_9_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_9_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_9_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_9_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_9_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_9_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_9_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_9_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_9_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_9_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_9_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_9_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_9_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_9_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_9_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_9_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_9_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_10)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_10_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_10_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_10_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_10_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_10_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_10_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_10_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_10_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_10_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_10_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_10_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_10_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_10_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_10_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_10_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_10_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_10_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_11)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_11_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_11_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_11_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_11_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_11_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_11_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_11_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_11_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_11_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_11_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_11_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_11_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_11_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_11_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_11_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_11_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_11_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_12)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_12_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_12_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_12_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_12_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_12_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_12_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_12_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_12_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_12_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_12_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_12_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_12_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_12_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_12_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_12_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_12_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_12_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_13)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_13_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_13_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_13_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_13_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_13_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_13_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_13_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_13_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_13_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_13_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_13_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_13_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_13_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_13_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_13_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_13_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_13_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_14)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_14_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_14_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_14_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_14_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_14_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_14_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_14_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_14_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_14_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_14_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_14_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_14_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_14_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_14_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_14_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_14_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_14_string = "??????????";
        endcase
    end
    always @(*) begin
        case (_zz_jtag_tap_fsm_stateNext_15)
            JtagState_RESET: _zz_jtag_tap_fsm_stateNext_15_string = "RESET     ";
            JtagState_IDLE: _zz_jtag_tap_fsm_stateNext_15_string = "IDLE      ";
            JtagState_IR_SELECT: _zz_jtag_tap_fsm_stateNext_15_string = "IR_SELECT ";
            JtagState_IR_CAPTURE: _zz_jtag_tap_fsm_stateNext_15_string = "IR_CAPTURE";
            JtagState_IR_SHIFT: _zz_jtag_tap_fsm_stateNext_15_string = "IR_SHIFT  ";
            JtagState_IR_EXIT1: _zz_jtag_tap_fsm_stateNext_15_string = "IR_EXIT1  ";
            JtagState_IR_PAUSE: _zz_jtag_tap_fsm_stateNext_15_string = "IR_PAUSE  ";
            JtagState_IR_EXIT2: _zz_jtag_tap_fsm_stateNext_15_string = "IR_EXIT2  ";
            JtagState_IR_UPDATE: _zz_jtag_tap_fsm_stateNext_15_string = "IR_UPDATE ";
            JtagState_DR_SELECT: _zz_jtag_tap_fsm_stateNext_15_string = "DR_SELECT ";
            JtagState_DR_CAPTURE: _zz_jtag_tap_fsm_stateNext_15_string = "DR_CAPTURE";
            JtagState_DR_SHIFT: _zz_jtag_tap_fsm_stateNext_15_string = "DR_SHIFT  ";
            JtagState_DR_EXIT1: _zz_jtag_tap_fsm_stateNext_15_string = "DR_EXIT1  ";
            JtagState_DR_PAUSE: _zz_jtag_tap_fsm_stateNext_15_string = "DR_PAUSE  ";
            JtagState_DR_EXIT2: _zz_jtag_tap_fsm_stateNext_15_string = "DR_EXIT2  ";
            JtagState_DR_UPDATE: _zz_jtag_tap_fsm_stateNext_15_string = "DR_UPDATE ";
            default: _zz_jtag_tap_fsm_stateNext_15_string = "??????????";
        endcase
    end
`endif

    assign system_cmd_toStream_valid = system_cmd_valid;
    assign system_cmd_toStream_payload_last = system_cmd_payload_last;
    assign system_cmd_toStream_payload_fragment = system_cmd_payload_fragment;
    assign io_remote_cmd_valid = system_cmd_toStream_valid;
    assign system_cmd_toStream_ready = io_remote_cmd_ready;
    assign io_remote_cmd_payload_last = system_cmd_toStream_payload_last;
    assign io_remote_cmd_payload_fragment = system_cmd_toStream_payload_fragment;
    assign io_remote_rsp_fire = (io_remote_rsp_valid && io_remote_rsp_ready);
    assign io_remote_rsp_ready = 1'b1;
    assign _zz_jtag_tap_fsm_stateNext = (io_jtag_tms ? JtagState_RESET : JtagState_IDLE);
    always @(*) begin
        case (jtag_tap_fsm_state)
            JtagState_RESET: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext;
            end
            JtagState_IDLE: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_1;
            end
            JtagState_IR_SELECT: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_2;
            end
            JtagState_IR_CAPTURE: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_3;
            end
            JtagState_IR_SHIFT: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_4;
            end
            JtagState_IR_EXIT1: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_5;
            end
            JtagState_IR_PAUSE: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_6;
            end
            JtagState_IR_EXIT2: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_7;
            end
            JtagState_IR_UPDATE: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_8;
            end
            JtagState_DR_SELECT: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_9;
            end
            JtagState_DR_CAPTURE: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_10;
            end
            JtagState_DR_SHIFT: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_11;
            end
            JtagState_DR_EXIT1: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_12;
            end
            JtagState_DR_PAUSE: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_13;
            end
            JtagState_DR_EXIT2: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_14;
            end
            JtagState_DR_UPDATE: begin
                jtag_tap_fsm_stateNext = _zz_jtag_tap_fsm_stateNext_15;
            end
            default: begin
            end
        endcase
    end

    assign _zz_jtag_tap_fsm_stateNext_1 = (io_jtag_tms ? JtagState_DR_SELECT : JtagState_IDLE);
    assign _zz_jtag_tap_fsm_stateNext_2 = (io_jtag_tms ? JtagState_RESET : JtagState_IR_CAPTURE);
    assign _zz_jtag_tap_fsm_stateNext_3 = (io_jtag_tms ? JtagState_IR_EXIT1 : JtagState_IR_SHIFT);
    assign _zz_jtag_tap_fsm_stateNext_4 = (io_jtag_tms ? JtagState_IR_EXIT1 : JtagState_IR_SHIFT);
    assign _zz_jtag_tap_fsm_stateNext_5 = (io_jtag_tms ? JtagState_IR_UPDATE : JtagState_IR_PAUSE);
    assign _zz_jtag_tap_fsm_stateNext_6 = (io_jtag_tms ? JtagState_IR_EXIT2 : JtagState_IR_PAUSE);
    assign _zz_jtag_tap_fsm_stateNext_7 = (io_jtag_tms ? JtagState_IR_UPDATE : JtagState_IR_SHIFT);
    assign _zz_jtag_tap_fsm_stateNext_8 = (io_jtag_tms ? JtagState_DR_SELECT : JtagState_IDLE);
    assign _zz_jtag_tap_fsm_stateNext_9 = (io_jtag_tms ? JtagState_IR_SELECT:JtagState_DR_CAPTURE);
    assign _zz_jtag_tap_fsm_stateNext_10 = (io_jtag_tms ? JtagState_DR_EXIT1 : JtagState_DR_SHIFT);
    assign _zz_jtag_tap_fsm_stateNext_11 = (io_jtag_tms ? JtagState_DR_EXIT1 : JtagState_DR_SHIFT);
    assign _zz_jtag_tap_fsm_stateNext_12 = (io_jtag_tms ? JtagState_DR_UPDATE : JtagState_DR_PAUSE);
    assign _zz_jtag_tap_fsm_stateNext_13 = (io_jtag_tms ? JtagState_DR_EXIT2 : JtagState_DR_PAUSE);
    assign _zz_jtag_tap_fsm_stateNext_14 = (io_jtag_tms ? JtagState_DR_UPDATE : JtagState_DR_SHIFT);
    assign _zz_jtag_tap_fsm_stateNext_15 = (io_jtag_tms ? JtagState_DR_SELECT : JtagState_IDLE);
    always @(*) begin
        jtag_tap_tdoUnbufferd = jtag_tap_bypass;
        case (jtag_tap_fsm_state)
            JtagState_IR_SHIFT: begin
                jtag_tap_tdoUnbufferd = jtag_tap_tdoIr;
            end
            JtagState_DR_SHIFT: begin
                if (jtag_tap_isBypass) begin
                    jtag_tap_tdoUnbufferd = jtag_tap_bypass;
                end else begin
                    jtag_tap_tdoUnbufferd = jtag_tap_tdoDr;
                end
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        jtag_tap_tdoDr = 1'b0;
        if (jtag_idcodeArea_ctrl_enable) begin
            jtag_tap_tdoDr = jtag_idcodeArea_ctrl_tdo;
        end
        if (jtag_writeArea_ctrl_enable) begin
            jtag_tap_tdoDr = jtag_writeArea_ctrl_tdo;
        end
        if (jtag_readArea_ctrl_enable) begin
            jtag_tap_tdoDr = jtag_readArea_ctrl_tdo;
        end
    end

    assign jtag_tap_tdoIr = jtag_tap_instructionShift[0];
    assign jtag_tap_isBypass = ($signed(_zz_jtag_tap_isBypass) == $signed(4'b1111));
    assign io_jtag_tdo = jtag_tap_tdoUnbufferd_regNext;
    assign jtag_idcodeArea_ctrl_tdo = jtag_idcodeArea_shifter[0];
    assign jtag_idcodeArea_ctrl_tdi = io_jtag_tdi;
    assign jtag_idcodeArea_ctrl_enable = (jtag_tap_instruction == 4'b0001);
    assign jtag_idcodeArea_ctrl_capture = (jtag_tap_fsm_state == JtagState_DR_CAPTURE);
    assign jtag_idcodeArea_ctrl_shift = (jtag_tap_fsm_state == JtagState_DR_SHIFT);
    assign jtag_idcodeArea_ctrl_update = (jtag_tap_fsm_state == JtagState_DR_UPDATE);
    assign jtag_idcodeArea_ctrl_reset = (jtag_tap_fsm_state == JtagState_RESET);
    assign when_JtagTap_l121 = (jtag_tap_fsm_state == JtagState_RESET);
    assign jtag_writeArea_source_valid = jtag_writeArea_valid;
    assign jtag_writeArea_source_payload_last = (! (jtag_writeArea_ctrl_enable && jtag_writeArea_ctrl_shift));
    assign jtag_writeArea_source_payload_fragment[0] = jtag_writeArea_data;
    assign system_cmd_valid = flowCCUnsafeByToggle_1_io_output_valid;
    assign system_cmd_payload_last = flowCCUnsafeByToggle_1_io_output_payload_last;
    assign system_cmd_payload_fragment = flowCCUnsafeByToggle_1_io_output_payload_fragment;
    assign jtag_writeArea_ctrl_tdo = 1'b0;
    assign jtag_writeArea_ctrl_tdi = io_jtag_tdi;
    assign jtag_writeArea_ctrl_enable = (jtag_tap_instruction == 4'b0010);
    assign jtag_writeArea_ctrl_capture = (jtag_tap_fsm_state == JtagState_DR_CAPTURE);
    assign jtag_writeArea_ctrl_shift = (jtag_tap_fsm_state == JtagState_DR_SHIFT);
    assign jtag_writeArea_ctrl_update = (jtag_tap_fsm_state == JtagState_DR_UPDATE);
    assign jtag_writeArea_ctrl_reset = (jtag_tap_fsm_state == JtagState_RESET);
    assign jtag_readArea_ctrl_tdo = jtag_readArea_full_shifter[0];
    assign jtag_readArea_ctrl_tdi = io_jtag_tdi;
    assign jtag_readArea_ctrl_enable = (jtag_tap_instruction == 4'b0011);
    assign jtag_readArea_ctrl_capture = (jtag_tap_fsm_state == JtagState_DR_CAPTURE);
    assign jtag_readArea_ctrl_shift = (jtag_tap_fsm_state == JtagState_DR_SHIFT);
    assign jtag_readArea_ctrl_update = (jtag_tap_fsm_state == JtagState_DR_UPDATE);
    assign jtag_readArea_ctrl_reset = (jtag_tap_fsm_state == JtagState_RESET);
    always @(posedge io_axiClk) begin
        if (io_remote_cmd_valid) begin
            system_rsp_valid <= 1'b0;
        end
        if (io_remote_rsp_fire) begin
            system_rsp_valid <= 1'b1;
            system_rsp_payload_error <= io_remote_rsp_payload_error;
            system_rsp_payload_data <= io_remote_rsp_payload_data;
        end
    end

    always @(posedge io_jtag_tck) begin
        jtag_tap_fsm_state <= jtag_tap_fsm_stateNext;
        jtag_tap_bypass <= io_jtag_tdi;
        case (jtag_tap_fsm_state)
            JtagState_IR_CAPTURE: begin
                jtag_tap_instructionShift <= {2'd0, _zz_jtag_tap_instructionShift};
            end
            JtagState_IR_SHIFT: begin
                jtag_tap_instructionShift <= ({io_jtag_tdi, jtag_tap_instructionShift} >>> 1'd1);
            end
            JtagState_IR_UPDATE: begin
                jtag_tap_instruction <= jtag_tap_instructionShift;
            end
            JtagState_DR_SHIFT: begin
                jtag_tap_instructionShift <= ({io_jtag_tdi, jtag_tap_instructionShift} >>> 1'd1);
            end
            default: begin
            end
        endcase
        if (jtag_idcodeArea_ctrl_enable) begin
            if (jtag_idcodeArea_ctrl_shift) begin
                jtag_idcodeArea_shifter <= ({jtag_idcodeArea_ctrl_tdi,jtag_idcodeArea_shifter} >>> 1'd1);
            end
        end
        if (jtag_idcodeArea_ctrl_capture) begin
            jtag_idcodeArea_shifter <= 32'h10001fff;
        end
        if (when_JtagTap_l121) begin
            jtag_tap_instruction <= 4'b0001;
        end
        jtag_writeArea_valid <= (jtag_writeArea_ctrl_enable && jtag_writeArea_ctrl_shift);
        jtag_writeArea_data  <= jtag_writeArea_ctrl_tdi;
        if (jtag_readArea_ctrl_enable) begin
            if (jtag_readArea_ctrl_capture) begin
                jtag_readArea_full_shifter <= {
                    {system_rsp_payload_data, system_rsp_payload_error}, system_rsp_valid
                };
            end
            if (jtag_readArea_ctrl_shift) begin
                jtag_readArea_full_shifter <= ({jtag_readArea_ctrl_tdi,jtag_readArea_full_shifter} >>> 1'd1);
            end
        end
    end

    always @(negedge io_jtag_tck) begin
        jtag_tap_tdoUnbufferd_regNext <= jtag_tap_tdoUnbufferd;
    end

endmodule


module BufferCC_1 (
    input  wire io_dataIn,
    output wire io_dataOut,
    input  wire io_axiClk,
    input  wire resetCtrl_axiReset
);

    (* async_reg = "true" *)reg buffers_0;
    (* async_reg = "true" *)reg buffers_1;

    assign io_dataOut = buffers_1;
    always @(posedge io_axiClk) begin
        buffers_0 <= io_dataIn;
        buffers_1 <= buffers_0;
    end

endmodule


module VexRiscv (
    output wire        dBus_cmd_valid,
    input  wire        dBus_cmd_ready,
    output wire        dBus_cmd_payload_wr,
    output wire        dBus_cmd_payload_uncached,
    output wire [31:0] dBus_cmd_payload_address,
    output wire [31:0] dBus_cmd_payload_data,
    output wire [ 3:0] dBus_cmd_payload_mask,
    output wire [ 2:0] dBus_cmd_payload_size,
    output wire        dBus_cmd_payload_last,
    input  wire        dBus_rsp_valid,
    input  wire        dBus_rsp_payload_last,
    input  wire [31:0] dBus_rsp_payload_data,
    input  wire        dBus_rsp_payload_error,
    input  wire        timerInterrupt,
    input  wire        externalInterrupt,
    input  wire        softwareInterrupt,
    input  wire        debug_bus_cmd_valid,
    output reg         debug_bus_cmd_ready,
    input  wire        debug_bus_cmd_payload_wr,
    input  wire [ 7:0] debug_bus_cmd_payload_address,
    input  wire [31:0] debug_bus_cmd_payload_data,
    output reg  [31:0] debug_bus_rsp_data,
    output wire        debug_resetOut,
    output wire        iBus_cmd_valid,
    input  wire        iBus_cmd_ready,
    output reg  [31:0] iBus_cmd_payload_address,
    output wire [ 2:0] iBus_cmd_payload_size,
    input  wire        iBus_rsp_valid,
    input  wire [31:0] iBus_rsp_payload_data,
    input  wire        iBus_rsp_payload_error,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset,
    input  wire        resetCtrl_systemReset
);
    localparam ShiftCtrlEnum_DISABLE_1 = 2'd0;
    localparam ShiftCtrlEnum_SLL_1 = 2'd1;
    localparam ShiftCtrlEnum_SRL_1 = 2'd2;
    localparam ShiftCtrlEnum_SRA_1 = 2'd3;
    localparam EnvCtrlEnum_NONE = 1'd0;
    localparam EnvCtrlEnum_XRET = 1'd1;
    localparam BranchCtrlEnum_INC = 2'd0;
    localparam BranchCtrlEnum_B = 2'd1;
    localparam BranchCtrlEnum_JAL = 2'd2;
    localparam BranchCtrlEnum_JALR = 2'd3;
    localparam AluBitwiseCtrlEnum_XOR_1 = 2'd0;
    localparam AluBitwiseCtrlEnum_OR_1 = 2'd1;
    localparam AluBitwiseCtrlEnum_AND_1 = 2'd2;
    localparam Src2CtrlEnum_RS = 2'd0;
    localparam Src2CtrlEnum_IMI = 2'd1;
    localparam Src2CtrlEnum_IMS = 2'd2;
    localparam Src2CtrlEnum_PC = 2'd3;
    localparam AluCtrlEnum_ADD_SUB = 2'd0;
    localparam AluCtrlEnum_SLT_SLTU = 2'd1;
    localparam AluCtrlEnum_BITWISE = 2'd2;
    localparam Src1CtrlEnum_RS = 2'd0;
    localparam Src1CtrlEnum_IMU = 2'd1;
    localparam Src1CtrlEnum_PC_INCREMENT = 2'd2;
    localparam Src1CtrlEnum_URS1 = 2'd3;

    wire        IBusCachedPlugin_cache_io_flush;
    wire        IBusCachedPlugin_cache_io_cpu_prefetch_isValid;
    wire        IBusCachedPlugin_cache_io_cpu_fetch_isValid;
    wire        IBusCachedPlugin_cache_io_cpu_fetch_isStuck;
    wire        IBusCachedPlugin_cache_io_cpu_fetch_isRemoved;
    wire        IBusCachedPlugin_cache_io_cpu_decode_isValid;
    wire        IBusCachedPlugin_cache_io_cpu_decode_isStuck;
    wire        IBusCachedPlugin_cache_io_cpu_decode_isUser;
    reg         IBusCachedPlugin_cache_io_cpu_fill_valid;
    wire        dataCache_1_io_cpu_execute_isValid;
    wire [31:0] dataCache_1_io_cpu_execute_address;
    wire        dataCache_1_io_cpu_memory_isValid;
    wire [31:0] dataCache_1_io_cpu_memory_address;
    reg         dataCache_1_io_cpu_memory_mmuRsp_isIoAccess;
    reg         dataCache_1_io_cpu_writeBack_isValid;
    wire        dataCache_1_io_cpu_writeBack_isUser;
    wire [31:0] dataCache_1_io_cpu_writeBack_storeData;
    wire [31:0] dataCache_1_io_cpu_writeBack_address;
    wire        dataCache_1_io_cpu_writeBack_fence_SW;
    wire        dataCache_1_io_cpu_writeBack_fence_SR;
    wire        dataCache_1_io_cpu_writeBack_fence_SO;
    wire        dataCache_1_io_cpu_writeBack_fence_SI;
    wire        dataCache_1_io_cpu_writeBack_fence_PW;
    wire        dataCache_1_io_cpu_writeBack_fence_PR;
    wire        dataCache_1_io_cpu_writeBack_fence_PO;
    wire        dataCache_1_io_cpu_writeBack_fence_PI;
    wire [ 3:0] dataCache_1_io_cpu_writeBack_fence_FM;
    wire        dataCache_1_io_cpu_flush_valid;
    wire        dataCache_1_io_cpu_flush_payload_singleLine;
    wire [ 6:0] dataCache_1_io_cpu_flush_payload_lineId;
    reg  [31:0] RegFilePlugin_regFile_spinal_port0;
    reg  [31:0] RegFilePlugin_regFile_spinal_port1;
    wire        IBusCachedPlugin_cache_io_cpu_prefetch_haltIt;
    wire [31:0] IBusCachedPlugin_cache_io_cpu_fetch_data;
    wire [31:0] IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress;
    wire        IBusCachedPlugin_cache_io_cpu_decode_error;
    wire        IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling;
    wire        IBusCachedPlugin_cache_io_cpu_decode_mmuException;
    wire [31:0] IBusCachedPlugin_cache_io_cpu_decode_data;
    wire        IBusCachedPlugin_cache_io_cpu_decode_cacheMiss;
    wire [31:0] IBusCachedPlugin_cache_io_cpu_decode_physicalAddress;
    wire        IBusCachedPlugin_cache_io_mem_cmd_valid;
    wire [31:0] IBusCachedPlugin_cache_io_mem_cmd_payload_address;
    wire [ 2:0] IBusCachedPlugin_cache_io_mem_cmd_payload_size;
    wire        dataCache_1_io_cpu_execute_haltIt;
    wire        dataCache_1_io_cpu_execute_refilling;
    wire        dataCache_1_io_cpu_memory_isWrite;
    wire        dataCache_1_io_cpu_writeBack_haltIt;
    wire [31:0] dataCache_1_io_cpu_writeBack_data;
    wire        dataCache_1_io_cpu_writeBack_mmuException;
    wire        dataCache_1_io_cpu_writeBack_unalignedAccess;
    wire        dataCache_1_io_cpu_writeBack_accessError;
    wire        dataCache_1_io_cpu_writeBack_isWrite;
    wire        dataCache_1_io_cpu_writeBack_keepMemRspData;
    wire        dataCache_1_io_cpu_writeBack_exclusiveOk;
    wire        dataCache_1_io_cpu_flush_ready;
    wire        dataCache_1_io_cpu_redo;
    wire        dataCache_1_io_cpu_writesPending;
    wire        dataCache_1_io_mem_cmd_valid;
    wire        dataCache_1_io_mem_cmd_payload_wr;
    wire        dataCache_1_io_mem_cmd_payload_uncached;
    wire [31:0] dataCache_1_io_mem_cmd_payload_address;
    wire [31:0] dataCache_1_io_mem_cmd_payload_data;
    wire [ 3:0] dataCache_1_io_mem_cmd_payload_mask;
    wire [ 2:0] dataCache_1_io_mem_cmd_payload_size;
    wire        dataCache_1_io_mem_cmd_payload_last;
    wire [51:0] _zz_memory_MUL_LOW;
    wire [51:0] _zz_memory_MUL_LOW_1;
    wire [51:0] _zz_memory_MUL_LOW_2;
    wire [32:0] _zz_memory_MUL_LOW_3;
    wire [51:0] _zz_memory_MUL_LOW_4;
    wire [49:0] _zz_memory_MUL_LOW_5;
    wire [51:0] _zz_memory_MUL_LOW_6;
    wire [49:0] _zz_memory_MUL_LOW_7;
    wire [31:0] _zz_execute_SHIFT_RIGHT;
    wire [32:0] _zz_execute_SHIFT_RIGHT_1;
    wire [32:0] _zz_execute_SHIFT_RIGHT_2;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION_1;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION_2;
    wire        _zz_decode_LEGAL_INSTRUCTION_3;
    wire [ 0:0] _zz_decode_LEGAL_INSTRUCTION_4;
    wire [12:0] _zz_decode_LEGAL_INSTRUCTION_5;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION_6;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION_7;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION_8;
    wire        _zz_decode_LEGAL_INSTRUCTION_9;
    wire [ 0:0] _zz_decode_LEGAL_INSTRUCTION_10;
    wire [ 6:0] _zz_decode_LEGAL_INSTRUCTION_11;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION_12;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION_13;
    wire [31:0] _zz_decode_LEGAL_INSTRUCTION_14;
    wire        _zz_decode_LEGAL_INSTRUCTION_15;
    wire [ 0:0] _zz_decode_LEGAL_INSTRUCTION_16;
    wire [ 0:0] _zz_decode_LEGAL_INSTRUCTION_17;
    wire [ 3:0] _zz__zz_IBusCachedPlugin_jump_pcLoad_payload_1;
    reg  [31:0] _zz_IBusCachedPlugin_jump_pcLoad_payload_5;
    wire [ 1:0] _zz_IBusCachedPlugin_jump_pcLoad_payload_6;
    wire [31:0] _zz_IBusCachedPlugin_fetchPc_pc;
    wire [ 2:0] _zz_IBusCachedPlugin_fetchPc_pc_1;
    wire [11:0] _zz__zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    wire [31:0] _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_2;
    wire [19:0] _zz__zz_2;
    wire [11:0] _zz__zz_4;
    wire [31:0] _zz__zz_6;
    wire [31:0] _zz__zz_6_1;
    wire [19:0] _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload;
    wire [11:0] _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    wire        _zz_IBusCachedPlugin_predictionJumpInterface_payload_4;
    wire        _zz_IBusCachedPlugin_predictionJumpInterface_payload_5;
    wire        _zz_IBusCachedPlugin_predictionJumpInterface_payload_6;
    wire [26:0] _zz_io_cpu_flush_payload_lineId;
    wire [26:0] _zz_io_cpu_flush_payload_lineId_1;
    wire [ 2:0] _zz_DBusCachedPlugin_exceptionBus_payload_code;
    wire [ 2:0] _zz_DBusCachedPlugin_exceptionBus_payload_code_1;
    reg  [ 7:0] _zz_writeBack_DBusCachedPlugin_rspShifted;
    wire [ 1:0] _zz_writeBack_DBusCachedPlugin_rspShifted_1;
    reg  [ 7:0] _zz_writeBack_DBusCachedPlugin_rspShifted_2;
    wire [ 0:0] _zz_writeBack_DBusCachedPlugin_rspShifted_3;
    wire [31:0] _zz__zz_decode_IS_CSR;
    wire        _zz__zz_decode_IS_CSR_1;
    wire        _zz__zz_decode_IS_CSR_2;
    wire [ 0:0] _zz__zz_decode_IS_CSR_3;
    wire [ 0:0] _zz__zz_decode_IS_CSR_4;
    wire [ 0:0] _zz__zz_decode_IS_CSR_5;
    wire        _zz__zz_decode_IS_CSR_6;
    wire [ 0:0] _zz__zz_decode_IS_CSR_7;
    wire [24:0] _zz__zz_decode_IS_CSR_8;
    wire        _zz__zz_decode_IS_CSR_9;
    wire [ 0:0] _zz__zz_decode_IS_CSR_10;
    wire        _zz__zz_decode_IS_CSR_11;
    wire [31:0] _zz__zz_decode_IS_CSR_12;
    wire [ 0:0] _zz__zz_decode_IS_CSR_13;
    wire        _zz__zz_decode_IS_CSR_14;
    wire        _zz__zz_decode_IS_CSR_15;
    wire [20:0] _zz__zz_decode_IS_CSR_16;
    wire        _zz__zz_decode_IS_CSR_17;
    wire [ 0:0] _zz__zz_decode_IS_CSR_18;
    wire        _zz__zz_decode_IS_CSR_19;
    wire [31:0] _zz__zz_decode_IS_CSR_20;
    wire [ 0:0] _zz__zz_decode_IS_CSR_21;
    wire        _zz__zz_decode_IS_CSR_22;
    wire        _zz__zz_decode_IS_CSR_23;
    wire [16:0] _zz__zz_decode_IS_CSR_24;
    wire        _zz__zz_decode_IS_CSR_25;
    wire [ 1:0] _zz__zz_decode_IS_CSR_26;
    wire [31:0] _zz__zz_decode_IS_CSR_27;
    wire [31:0] _zz__zz_decode_IS_CSR_28;
    wire [31:0] _zz__zz_decode_IS_CSR_29;
    wire [31:0] _zz__zz_decode_IS_CSR_30;
    wire        _zz__zz_decode_IS_CSR_31;
    wire        _zz__zz_decode_IS_CSR_32;
    wire [ 0:0] _zz__zz_decode_IS_CSR_33;
    wire [ 0:0] _zz__zz_decode_IS_CSR_34;
    wire [31:0] _zz__zz_decode_IS_CSR_35;
    wire [ 0:0] _zz__zz_decode_IS_CSR_36;
    wire        _zz__zz_decode_IS_CSR_37;
    wire [12:0] _zz__zz_decode_IS_CSR_38;
    wire [ 4:0] _zz__zz_decode_IS_CSR_39;
    wire [31:0] _zz__zz_decode_IS_CSR_40;
    wire [31:0] _zz__zz_decode_IS_CSR_41;
    wire [ 0:0] _zz__zz_decode_IS_CSR_42;
    wire [31:0] _zz__zz_decode_IS_CSR_43;
    wire [31:0] _zz__zz_decode_IS_CSR_44;
    wire [ 1:0] _zz__zz_decode_IS_CSR_45;
    wire        _zz__zz_decode_IS_CSR_46;
    wire [31:0] _zz__zz_decode_IS_CSR_47;
    wire        _zz__zz_decode_IS_CSR_48;
    wire [31:0] _zz__zz_decode_IS_CSR_49;
    wire        _zz__zz_decode_IS_CSR_50;
    wire [ 0:0] _zz__zz_decode_IS_CSR_51;
    wire [31:0] _zz__zz_decode_IS_CSR_52;
    wire [31:0] _zz__zz_decode_IS_CSR_53;
    wire [ 2:0] _zz__zz_decode_IS_CSR_54;
    wire        _zz__zz_decode_IS_CSR_55;
    wire [31:0] _zz__zz_decode_IS_CSR_56;
    wire [ 0:0] _zz__zz_decode_IS_CSR_57;
    wire [31:0] _zz__zz_decode_IS_CSR_58;
    wire [31:0] _zz__zz_decode_IS_CSR_59;
    wire [ 0:0] _zz__zz_decode_IS_CSR_60;
    wire [31:0] _zz__zz_decode_IS_CSR_61;
    wire [31:0] _zz__zz_decode_IS_CSR_62;
    wire [ 0:0] _zz__zz_decode_IS_CSR_63;
    wire [ 0:0] _zz__zz_decode_IS_CSR_64;
    wire [ 4:0] _zz__zz_decode_IS_CSR_65;
    wire        _zz__zz_decode_IS_CSR_66;
    wire [31:0] _zz__zz_decode_IS_CSR_67;
    wire [ 0:0] _zz__zz_decode_IS_CSR_68;
    wire [31:0] _zz__zz_decode_IS_CSR_69;
    wire [31:0] _zz__zz_decode_IS_CSR_70;
    wire [ 2:0] _zz__zz_decode_IS_CSR_71;
    wire        _zz__zz_decode_IS_CSR_72;
    wire [ 0:0] _zz__zz_decode_IS_CSR_73;
    wire [31:0] _zz__zz_decode_IS_CSR_74;
    wire [ 0:0] _zz__zz_decode_IS_CSR_75;
    wire [31:0] _zz__zz_decode_IS_CSR_76;
    wire [ 9:0] _zz__zz_decode_IS_CSR_77;
    wire [ 1:0] _zz__zz_decode_IS_CSR_78;
    wire        _zz__zz_decode_IS_CSR_79;
    wire [31:0] _zz__zz_decode_IS_CSR_80;
    wire        _zz__zz_decode_IS_CSR_81;
    wire [ 0:0] _zz__zz_decode_IS_CSR_82;
    wire [ 0:0] _zz__zz_decode_IS_CSR_83;
    wire [31:0] _zz__zz_decode_IS_CSR_84;
    wire [31:0] _zz__zz_decode_IS_CSR_85;
    wire [ 0:0] _zz__zz_decode_IS_CSR_86;
    wire [ 0:0] _zz__zz_decode_IS_CSR_87;
    wire [31:0] _zz__zz_decode_IS_CSR_88;
    wire [31:0] _zz__zz_decode_IS_CSR_89;
    wire [ 6:0] _zz__zz_decode_IS_CSR_90;
    wire        _zz__zz_decode_IS_CSR_91;
    wire        _zz__zz_decode_IS_CSR_92;
    wire [ 0:0] _zz__zz_decode_IS_CSR_93;
    wire [ 4:0] _zz__zz_decode_IS_CSR_94;
    wire [31:0] _zz__zz_decode_IS_CSR_95;
    wire [31:0] _zz__zz_decode_IS_CSR_96;
    wire [ 0:0] _zz__zz_decode_IS_CSR_97;
    wire [31:0] _zz__zz_decode_IS_CSR_98;
    wire [ 1:0] _zz__zz_decode_IS_CSR_99;
    wire [31:0] _zz__zz_decode_IS_CSR_100;
    wire [31:0] _zz__zz_decode_IS_CSR_101;
    wire [31:0] _zz__zz_decode_IS_CSR_102;
    wire [31:0] _zz__zz_decode_IS_CSR_103;
    wire [ 4:0] _zz__zz_decode_IS_CSR_104;
    wire        _zz__zz_decode_IS_CSR_105;
    wire [31:0] _zz__zz_decode_IS_CSR_106;
    wire [31:0] _zz__zz_decode_IS_CSR_107;
    wire [ 0:0] _zz__zz_decode_IS_CSR_108;
    wire [ 0:0] _zz__zz_decode_IS_CSR_109;
    wire [31:0] _zz__zz_decode_IS_CSR_110;
    wire [ 1:0] _zz__zz_decode_IS_CSR_111;
    wire [31:0] _zz__zz_decode_IS_CSR_112;
    wire [31:0] _zz__zz_decode_IS_CSR_113;
    wire [31:0] _zz__zz_decode_IS_CSR_114;
    wire [31:0] _zz__zz_decode_IS_CSR_115;
    wire [ 2:0] _zz__zz_decode_IS_CSR_116;
    wire [ 1:0] _zz__zz_decode_IS_CSR_117;
    wire [31:0] _zz__zz_decode_IS_CSR_118;
    wire [31:0] _zz__zz_decode_IS_CSR_119;
    wire        _zz__zz_decode_IS_CSR_120;
    wire        _zz__zz_decode_IS_CSR_121;
    wire        _zz__zz_decode_IS_CSR_122;
    wire [31:0] _zz__zz_decode_IS_CSR_123;
    wire [31:0] _zz__zz_decode_IS_CSR_124;
    wire        _zz_RegFilePlugin_regFile_port;
    wire        _zz_decode_RegFilePlugin_rs1Data;
    wire        _zz_RegFilePlugin_regFile_port_1;
    wire        _zz_decode_RegFilePlugin_rs2Data;
    wire [ 0:0] _zz__zz_execute_REGFILE_WRITE_DATA;
    wire [ 2:0] _zz__zz_execute_SRC1;
    wire [ 4:0] _zz__zz_execute_SRC1_1;
    wire [11:0] _zz__zz_execute_SRC2_2;
    wire [31:0] _zz_execute_SrcPlugin_addSub;
    wire [31:0] _zz_execute_SrcPlugin_addSub_1;
    wire [31:0] _zz_execute_SrcPlugin_addSub_2;
    wire [31:0] _zz_execute_SrcPlugin_addSub_3;
    wire [31:0] _zz_execute_SrcPlugin_addSub_4;
    wire [65:0] _zz_writeBack_MulPlugin_result;
    wire [65:0] _zz_writeBack_MulPlugin_result_1;
    wire [31:0] _zz__zz_decode_RS2_2;
    wire [31:0] _zz__zz_decode_RS2_2_1;
    wire [ 5:0] _zz_memory_DivPlugin_div_counter_valueNext;
    wire [ 0:0] _zz_memory_DivPlugin_div_counter_valueNext_1;
    wire [32:0] _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator;
    wire [31:0] _zz_memory_DivPlugin_div_stage_0_outRemainder;
    wire [31:0] _zz_memory_DivPlugin_div_stage_0_outRemainder_1;
    wire [32:0] _zz_memory_DivPlugin_div_stage_0_outNumerator;
    wire [32:0] _zz_memory_DivPlugin_div_result_1;
    wire [32:0] _zz_memory_DivPlugin_div_result_2;
    wire [32:0] _zz_memory_DivPlugin_div_result_3;
    wire [32:0] _zz_memory_DivPlugin_div_result_4;
    wire [ 0:0] _zz_memory_DivPlugin_div_result_5;
    wire [32:0] _zz_memory_DivPlugin_rs1_2;
    wire [ 0:0] _zz_memory_DivPlugin_rs1_3;
    wire [31:0] _zz_memory_DivPlugin_rs2_1;
    wire [ 0:0] _zz_memory_DivPlugin_rs2_2;
    wire [19:0] _zz__zz_execute_BranchPlugin_missAlignedTarget_2;
    wire [11:0] _zz__zz_execute_BranchPlugin_missAlignedTarget_4;
    wire [31:0] _zz__zz_execute_BranchPlugin_missAlignedTarget_6;
    wire [31:0] _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1;
    wire [31:0] _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2;
    wire [19:0] _zz__zz_execute_BranchPlugin_branch_src2_2;
    wire [11:0] _zz__zz_execute_BranchPlugin_branch_src2_4;
    wire [ 0:0] _zz_execute_BranchPlugin_branch_src2_6;
    wire [ 7:0] _zz_execute_BranchPlugin_branch_src2_7;
    wire        _zz_execute_BranchPlugin_branch_src2_8;
    wire [ 0:0] _zz_execute_BranchPlugin_branch_src2_9;
    wire [ 0:0] _zz_execute_BranchPlugin_branch_src2_10;
    wire [ 2:0] _zz_execute_BranchPlugin_branch_src2_11;
    wire [ 1:0] _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1;
    wire [ 1:0] _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1_1;
    wire        _zz_when;
    wire [51:0] memory_MUL_LOW;
    wire [31:0] execute_BRANCH_CALC;
    wire        execute_BRANCH_DO;
    wire [33:0] memory_MUL_HH;
    wire [33:0] execute_MUL_HH;
    wire [33:0] execute_MUL_HL;
    wire [33:0] execute_MUL_LH;
    wire [31:0] execute_MUL_LL;
    wire [31:0] execute_SHIFT_RIGHT;
    wire [31:0] execute_REGFILE_WRITE_DATA;
    wire [31:0] memory_MEMORY_STORE_DATA_RF;
    wire [31:0] execute_MEMORY_STORE_DATA_RF;
    wire        decode_DO_EBREAK;
    wire        decode_CSR_READ_OPCODE;
    wire        decode_CSR_WRITE_OPCODE;
    wire        decode_PREDICTION_HAD_BRANCHED1;
    wire        decode_SRC2_FORCE_ZERO;
    wire [ 0:0] _zz_memory_to_writeBack_ENV_CTRL;
    wire [ 0:0] _zz_memory_to_writeBack_ENV_CTRL_1;
    wire [ 0:0] _zz_execute_to_memory_ENV_CTRL;
    wire [ 0:0] _zz_execute_to_memory_ENV_CTRL_1;
    wire [ 0:0] decode_ENV_CTRL;
    wire [ 0:0] _zz_decode_ENV_CTRL;
    wire [ 0:0] _zz_decode_to_execute_ENV_CTRL;
    wire [ 0:0] _zz_decode_to_execute_ENV_CTRL_1;
    wire        decode_IS_CSR;
    wire [ 1:0] _zz_decode_to_execute_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_to_execute_BRANCH_CTRL_1;
    wire        decode_IS_RS2_SIGNED;
    wire        decode_IS_RS1_SIGNED;
    wire        decode_IS_DIV;
    wire        memory_IS_MUL;
    wire        execute_IS_MUL;
    wire        decode_IS_MUL;
    wire [ 1:0] _zz_execute_to_memory_SHIFT_CTRL;
    wire [ 1:0] _zz_execute_to_memory_SHIFT_CTRL_1;
    wire [ 1:0] decode_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SHIFT_CTRL_1;
    wire [ 1:0] decode_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
    wire        decode_SRC_LESS_UNSIGNED;
    wire        decode_MEMORY_MANAGMENT;
    wire        memory_MEMORY_WR;
    wire        decode_MEMORY_WR;
    wire        execute_BYPASSABLE_MEMORY_STAGE;
    wire        decode_BYPASSABLE_MEMORY_STAGE;
    wire        decode_BYPASSABLE_EXECUTE_STAGE;
    wire [ 1:0] decode_SRC2_CTRL;
    wire [ 1:0] _zz_decode_SRC2_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SRC2_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SRC2_CTRL_1;
    wire [ 1:0] decode_ALU_CTRL;
    wire [ 1:0] _zz_decode_ALU_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_CTRL_1;
    wire [ 1:0] decode_SRC1_CTRL;
    wire [ 1:0] _zz_decode_SRC1_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SRC1_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SRC1_CTRL_1;
    wire        decode_MEMORY_FORCE_CONSTISTENCY;
    wire [31:0] writeBack_FORMAL_PC_NEXT;
    wire [31:0] memory_FORMAL_PC_NEXT;
    wire [31:0] execute_FORMAL_PC_NEXT;
    wire [31:0] decode_FORMAL_PC_NEXT;
    wire [31:0] memory_PC;
    wire        execute_DO_EBREAK;
    wire        decode_IS_EBREAK;
    wire        execute_CSR_READ_OPCODE;
    wire        execute_CSR_WRITE_OPCODE;
    wire        execute_IS_CSR;
    wire [ 0:0] memory_ENV_CTRL;
    wire [ 0:0] _zz_memory_ENV_CTRL;
    wire [ 0:0] execute_ENV_CTRL;
    wire [ 0:0] _zz_execute_ENV_CTRL;
    wire [ 0:0] writeBack_ENV_CTRL;
    wire [ 0:0] _zz_writeBack_ENV_CTRL;
    wire [31:0] memory_BRANCH_CALC;
    wire        memory_BRANCH_DO;
    wire [31:0] execute_PC;
    wire        execute_PREDICTION_HAD_BRANCHED1;
    wire        execute_BRANCH_COND_RESULT;
    wire [ 1:0] execute_BRANCH_CTRL;
    wire [ 1:0] _zz_execute_BRANCH_CTRL;
    wire        decode_RS2_USE;
    wire        decode_RS1_USE;
    reg  [31:0] _zz_decode_RS2;
    wire        execute_REGFILE_WRITE_VALID;
    wire        execute_BYPASSABLE_EXECUTE_STAGE;
    wire        memory_REGFILE_WRITE_VALID;
    wire        memory_BYPASSABLE_MEMORY_STAGE;
    wire        writeBack_REGFILE_WRITE_VALID;
    reg  [31:0] decode_RS2;
    reg  [31:0] decode_RS1;
    wire        execute_IS_RS1_SIGNED;
    wire        execute_IS_DIV;
    wire        execute_IS_RS2_SIGNED;
    wire [31:0] memory_INSTRUCTION;
    wire        memory_IS_DIV;
    wire        writeBack_IS_MUL;
    wire [33:0] writeBack_MUL_HH;
    wire [51:0] writeBack_MUL_LOW;
    wire [33:0] memory_MUL_HL;
    wire [33:0] memory_MUL_LH;
    wire [31:0] memory_MUL_LL;
    wire [31:0] memory_SHIFT_RIGHT;
    reg  [31:0] _zz_decode_RS2_1;
    wire [ 1:0] memory_SHIFT_CTRL;
    wire [ 1:0] _zz_memory_SHIFT_CTRL;
    wire [ 1:0] execute_SHIFT_CTRL;
    wire [ 1:0] _zz_execute_SHIFT_CTRL;
    wire        execute_SRC_LESS_UNSIGNED;
    wire        execute_SRC2_FORCE_ZERO;
    wire        execute_SRC_USE_SUB_LESS;
    wire [31:0] _zz_execute_to_memory_PC;
    wire [ 1:0] execute_SRC2_CTRL;
    wire [ 1:0] _zz_execute_SRC2_CTRL;
    wire [ 1:0] execute_SRC1_CTRL;
    wire [ 1:0] _zz_execute_SRC1_CTRL;
    wire        decode_SRC_USE_SUB_LESS;
    wire        decode_SRC_ADD_ZERO;
    wire [31:0] execute_SRC_ADD_SUB;
    wire        execute_SRC_LESS;
    wire [ 1:0] execute_ALU_CTRL;
    wire [ 1:0] _zz_execute_ALU_CTRL;
    wire [31:0] execute_SRC2;
    wire [31:0] execute_SRC1;
    wire [ 1:0] execute_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_execute_ALU_BITWISE_CTRL;
    wire [31:0] _zz_lastStageRegFileWrite_payload_address;
    wire        _zz_lastStageRegFileWrite_valid;
    reg         _zz_1;
    wire [31:0] decode_INSTRUCTION_ANTICIPATED;
    reg         decode_REGFILE_WRITE_VALID;
    wire        decode_LEGAL_INSTRUCTION;
    wire [ 0:0] _zz_decode_ENV_CTRL_1;
    wire [ 1:0] _zz_decode_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_SHIFT_CTRL_1;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL_1;
    wire [ 1:0] _zz_decode_SRC2_CTRL_1;
    wire [ 1:0] _zz_decode_ALU_CTRL_1;
    wire [ 1:0] _zz_decode_SRC1_CTRL_1;
    reg  [31:0] _zz_decode_RS2_2;
    wire        writeBack_MEMORY_WR;
    wire [31:0] writeBack_MEMORY_STORE_DATA_RF;
    wire [31:0] writeBack_REGFILE_WRITE_DATA;
    wire        writeBack_MEMORY_ENABLE;
    wire [31:0] memory_REGFILE_WRITE_DATA;
    wire        memory_MEMORY_ENABLE;
    wire        execute_MEMORY_FORCE_CONSTISTENCY;
    (* keep , syn_keep *)wire [31:0] execute_RS1  /* synthesis syn_keep = 1 */;
    wire        execute_MEMORY_MANAGMENT;
    (* keep , syn_keep *)wire [31:0] execute_RS2  /* synthesis syn_keep = 1 */;
    wire        execute_MEMORY_WR;
    wire [31:0] execute_SRC_ADD;
    wire        execute_MEMORY_ENABLE;
    wire [31:0] execute_INSTRUCTION;
    wire        decode_MEMORY_ENABLE;
    wire        decode_FLUSH_ALL;
    reg         IBusCachedPlugin_rsp_issueDetected_4;
    reg         IBusCachedPlugin_rsp_issueDetected_3;
    reg         IBusCachedPlugin_rsp_issueDetected_2;
    reg         IBusCachedPlugin_rsp_issueDetected_1;
    wire [ 1:0] decode_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_BRANCH_CTRL_1;
    wire [31:0] decode_INSTRUCTION;
    reg  [31:0] _zz_memory_to_writeBack_FORMAL_PC_NEXT;
    reg  [31:0] _zz_decode_to_execute_FORMAL_PC_NEXT;
    wire [31:0] decode_PC;
    wire [31:0] writeBack_PC;
    wire [31:0] writeBack_INSTRUCTION;
    reg         decode_arbitration_haltItself;
    reg         decode_arbitration_haltByOther;
    reg         decode_arbitration_removeIt;
    wire        decode_arbitration_flushIt;
    reg         decode_arbitration_flushNext;
    reg         decode_arbitration_isValid;
    wire        decode_arbitration_isStuck;
    wire        decode_arbitration_isStuckByOthers;
    wire        decode_arbitration_isFlushed;
    wire        decode_arbitration_isMoving;
    wire        decode_arbitration_isFiring;
    reg         execute_arbitration_haltItself;
    reg         execute_arbitration_haltByOther;
    reg         execute_arbitration_removeIt;
    reg         execute_arbitration_flushIt;
    reg         execute_arbitration_flushNext;
    reg         execute_arbitration_isValid;
    wire        execute_arbitration_isStuck;
    wire        execute_arbitration_isStuckByOthers;
    wire        execute_arbitration_isFlushed;
    wire        execute_arbitration_isMoving;
    wire        execute_arbitration_isFiring;
    reg         memory_arbitration_haltItself;
    wire        memory_arbitration_haltByOther;
    reg         memory_arbitration_removeIt;
    wire        memory_arbitration_flushIt;
    reg         memory_arbitration_flushNext;
    reg         memory_arbitration_isValid;
    wire        memory_arbitration_isStuck;
    wire        memory_arbitration_isStuckByOthers;
    wire        memory_arbitration_isFlushed;
    wire        memory_arbitration_isMoving;
    wire        memory_arbitration_isFiring;
    reg         writeBack_arbitration_haltItself;
    wire        writeBack_arbitration_haltByOther;
    reg         writeBack_arbitration_removeIt;
    reg         writeBack_arbitration_flushIt;
    reg         writeBack_arbitration_flushNext;
    reg         writeBack_arbitration_isValid;
    wire        writeBack_arbitration_isStuck;
    wire        writeBack_arbitration_isStuckByOthers;
    wire        writeBack_arbitration_isFlushed;
    wire        writeBack_arbitration_isMoving;
    wire        writeBack_arbitration_isFiring;
    wire [31:0] lastStageInstruction  /* verilator public */;
    wire [31:0] lastStagePc  /* verilator public */;
    wire        lastStageIsValid  /* verilator public */;
    wire        lastStageIsFiring  /* verilator public */;
    reg         IBusCachedPlugin_fetcherHalt;
    wire        IBusCachedPlugin_forceNoDecodeCond;
    reg         IBusCachedPlugin_incomingInstruction;
    wire        IBusCachedPlugin_predictionJumpInterface_valid;
    (* keep , syn_keep *)wire [31:0] IBusCachedPlugin_predictionJumpInterface_payload  /* synthesis syn_keep = 1 */;
    reg         IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    wire        IBusCachedPlugin_decodePrediction_rsp_wasWrong;
    wire        IBusCachedPlugin_pcValids_0;
    wire        IBusCachedPlugin_pcValids_1;
    wire        IBusCachedPlugin_pcValids_2;
    wire        IBusCachedPlugin_pcValids_3;
    reg         IBusCachedPlugin_decodeExceptionPort_valid;
    reg  [ 3:0] IBusCachedPlugin_decodeExceptionPort_payload_code;
    wire [31:0] IBusCachedPlugin_decodeExceptionPort_payload_badAddr;
    wire        IBusCachedPlugin_mmuBus_cmd_0_isValid;
    wire        IBusCachedPlugin_mmuBus_cmd_0_isStuck;
    wire [31:0] IBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
    wire        IBusCachedPlugin_mmuBus_cmd_0_bypassTranslation;
    wire [31:0] IBusCachedPlugin_mmuBus_rsp_physicalAddress;
    wire        IBusCachedPlugin_mmuBus_rsp_isIoAccess;
    wire        IBusCachedPlugin_mmuBus_rsp_isPaging;
    wire        IBusCachedPlugin_mmuBus_rsp_allowRead;
    wire        IBusCachedPlugin_mmuBus_rsp_allowWrite;
    wire        IBusCachedPlugin_mmuBus_rsp_allowExecute;
    wire        IBusCachedPlugin_mmuBus_rsp_exception;
    wire        IBusCachedPlugin_mmuBus_rsp_refilling;
    wire        IBusCachedPlugin_mmuBus_rsp_bypassTranslation;
    wire        IBusCachedPlugin_mmuBus_end;
    wire        IBusCachedPlugin_mmuBus_busy;
    wire        DBusCachedPlugin_mmuBus_cmd_0_isValid;
    wire        DBusCachedPlugin_mmuBus_cmd_0_isStuck;
    wire [31:0] DBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
    wire        DBusCachedPlugin_mmuBus_cmd_0_bypassTranslation;
    wire [31:0] DBusCachedPlugin_mmuBus_rsp_physicalAddress;
    wire        DBusCachedPlugin_mmuBus_rsp_isIoAccess;
    wire        DBusCachedPlugin_mmuBus_rsp_isPaging;
    wire        DBusCachedPlugin_mmuBus_rsp_allowRead;
    wire        DBusCachedPlugin_mmuBus_rsp_allowWrite;
    wire        DBusCachedPlugin_mmuBus_rsp_allowExecute;
    wire        DBusCachedPlugin_mmuBus_rsp_exception;
    wire        DBusCachedPlugin_mmuBus_rsp_refilling;
    wire        DBusCachedPlugin_mmuBus_rsp_bypassTranslation;
    wire        DBusCachedPlugin_mmuBus_end;
    wire        DBusCachedPlugin_mmuBus_busy;
    reg         DBusCachedPlugin_redoBranch_valid;
    wire [31:0] DBusCachedPlugin_redoBranch_payload;
    reg         DBusCachedPlugin_exceptionBus_valid;
    reg  [ 3:0] DBusCachedPlugin_exceptionBus_payload_code;
    wire [31:0] DBusCachedPlugin_exceptionBus_payload_badAddr;
    reg         _zz_when_DBusCachedPlugin_l473;
    wire        decodeExceptionPort_valid;
    wire [ 3:0] decodeExceptionPort_payload_code;
    wire [31:0] decodeExceptionPort_payload_badAddr;
    wire        BranchPlugin_jumpInterface_valid;
    wire [31:0] BranchPlugin_jumpInterface_payload;
    wire        BranchPlugin_branchExceptionPort_valid;
    wire [ 3:0] BranchPlugin_branchExceptionPort_payload_code;
    wire [31:0] BranchPlugin_branchExceptionPort_payload_badAddr;
    reg         BranchPlugin_inDebugNoFetchFlag;
    wire [31:0] CsrPlugin_csrMapping_readDataSignal;
    wire [31:0] CsrPlugin_csrMapping_readDataInit;
    wire [31:0] CsrPlugin_csrMapping_writeDataSignal;
    reg         CsrPlugin_csrMapping_allowCsrSignal;
    wire        CsrPlugin_csrMapping_hazardFree;
    wire        CsrPlugin_csrMapping_doForceFailCsr;
    wire        CsrPlugin_inWfi  /* verilator public */;
    reg         CsrPlugin_thirdPartyWake;
    reg         CsrPlugin_jumpInterface_valid;
    reg  [31:0] CsrPlugin_jumpInterface_payload;
    wire        CsrPlugin_exceptionPendings_0;
    wire        CsrPlugin_exceptionPendings_1;
    wire        CsrPlugin_exceptionPendings_2;
    wire        CsrPlugin_exceptionPendings_3;
    wire        contextSwitching;
    reg  [ 1:0] CsrPlugin_privilege;
    reg         CsrPlugin_forceMachineWire;
    reg         CsrPlugin_allowInterrupts;
    reg         CsrPlugin_allowException;
    reg         CsrPlugin_allowEbreakException;
    wire        CsrPlugin_xretAwayFromMachine;
    reg         DebugPlugin_injectionPort_valid;
    reg         DebugPlugin_injectionPort_ready;
    wire [31:0] DebugPlugin_injectionPort_payload;
    wire        IBusCachedPlugin_externalFlush;
    wire        IBusCachedPlugin_jump_pcLoad_valid;
    wire [31:0] IBusCachedPlugin_jump_pcLoad_payload;
    wire [ 3:0] _zz_IBusCachedPlugin_jump_pcLoad_payload;
    wire [ 3:0] _zz_IBusCachedPlugin_jump_pcLoad_payload_1;
    wire        _zz_IBusCachedPlugin_jump_pcLoad_payload_2;
    wire        _zz_IBusCachedPlugin_jump_pcLoad_payload_3;
    wire        _zz_IBusCachedPlugin_jump_pcLoad_payload_4;
    wire        IBusCachedPlugin_fetchPc_output_valid;
    wire        IBusCachedPlugin_fetchPc_output_ready;
    wire [31:0] IBusCachedPlugin_fetchPc_output_payload;
    reg  [31:0] IBusCachedPlugin_fetchPc_pcReg  /* verilator public */;
    reg         IBusCachedPlugin_fetchPc_correction;
    reg         IBusCachedPlugin_fetchPc_correctionReg;
    wire        IBusCachedPlugin_fetchPc_output_fire;
    wire        IBusCachedPlugin_fetchPc_corrected;
    reg         IBusCachedPlugin_fetchPc_pcRegPropagate;
    reg         IBusCachedPlugin_fetchPc_booted;
    reg         IBusCachedPlugin_fetchPc_inc;
    wire        when_Fetcher_l133;
    wire        when_Fetcher_l133_1;
    reg  [31:0] IBusCachedPlugin_fetchPc_pc;
    wire        IBusCachedPlugin_fetchPc_redo_valid;
    wire [31:0] IBusCachedPlugin_fetchPc_redo_payload;
    reg         IBusCachedPlugin_fetchPc_flushed;
    wire        when_Fetcher_l160;
    reg         IBusCachedPlugin_iBusRsp_redoFetch;
    wire        IBusCachedPlugin_iBusRsp_stages_0_input_valid;
    wire        IBusCachedPlugin_iBusRsp_stages_0_input_ready;
    wire [31:0] IBusCachedPlugin_iBusRsp_stages_0_input_payload;
    wire        IBusCachedPlugin_iBusRsp_stages_0_output_valid;
    wire        IBusCachedPlugin_iBusRsp_stages_0_output_ready;
    wire [31:0] IBusCachedPlugin_iBusRsp_stages_0_output_payload;
    reg         IBusCachedPlugin_iBusRsp_stages_0_halt;
    wire        IBusCachedPlugin_iBusRsp_stages_1_input_valid;
    wire        IBusCachedPlugin_iBusRsp_stages_1_input_ready;
    wire [31:0] IBusCachedPlugin_iBusRsp_stages_1_input_payload;
    wire        IBusCachedPlugin_iBusRsp_stages_1_output_valid;
    wire        IBusCachedPlugin_iBusRsp_stages_1_output_ready;
    wire [31:0] IBusCachedPlugin_iBusRsp_stages_1_output_payload;
    reg         IBusCachedPlugin_iBusRsp_stages_1_halt;
    wire        IBusCachedPlugin_iBusRsp_stages_2_input_valid;
    wire        IBusCachedPlugin_iBusRsp_stages_2_input_ready;
    wire [31:0] IBusCachedPlugin_iBusRsp_stages_2_input_payload;
    wire        IBusCachedPlugin_iBusRsp_stages_2_output_valid;
    wire        IBusCachedPlugin_iBusRsp_stages_2_output_ready;
    wire [31:0] IBusCachedPlugin_iBusRsp_stages_2_output_payload;
    reg         IBusCachedPlugin_iBusRsp_stages_2_halt;
    wire        _zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready;
    wire        _zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready;
    wire        _zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready;
    wire        IBusCachedPlugin_iBusRsp_flush;
    wire        _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready;
    wire        _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid;
    reg         _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1;
    wire        IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    wire        IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready;
    wire [31:0] IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    reg         _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    reg  [31:0] _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    reg         IBusCachedPlugin_iBusRsp_readyForError;
    wire        IBusCachedPlugin_iBusRsp_output_valid;
    wire        IBusCachedPlugin_iBusRsp_output_ready;
    wire [31:0] IBusCachedPlugin_iBusRsp_output_payload_pc;
    wire        IBusCachedPlugin_iBusRsp_output_payload_rsp_error;
    wire [31:0] IBusCachedPlugin_iBusRsp_output_payload_rsp_inst;
    wire        IBusCachedPlugin_iBusRsp_output_payload_isRvc;
    wire        when_Fetcher_l242;
    wire        when_Fetcher_l322;
    reg         IBusCachedPlugin_injector_nextPcCalc_valids_0;
    wire        when_Fetcher_l331;
    reg         IBusCachedPlugin_injector_nextPcCalc_valids_1;
    wire        when_Fetcher_l331_1;
    reg         IBusCachedPlugin_injector_nextPcCalc_valids_2;
    wire        when_Fetcher_l331_2;
    reg         IBusCachedPlugin_injector_nextPcCalc_valids_3;
    wire        when_Fetcher_l331_3;
    reg         IBusCachedPlugin_injector_nextPcCalc_valids_4;
    wire        when_Fetcher_l331_4;
    wire        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    reg  [18:0] _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1;
    wire        _zz_2;
    reg  [10:0] _zz_3;
    wire        _zz_4;
    reg  [18:0] _zz_5;
    reg         _zz_6;
    wire        _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    reg  [10:0] _zz_IBusCachedPlugin_predictionJumpInterface_payload_1;
    wire        _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    reg  [18:0] _zz_IBusCachedPlugin_predictionJumpInterface_payload_3;
    reg  [31:0] IBusCachedPlugin_rspCounter;
    wire        IBusCachedPlugin_s0_tightlyCoupledHit;
    reg         IBusCachedPlugin_s1_tightlyCoupledHit;
    reg         IBusCachedPlugin_s2_tightlyCoupledHit;
    wire        IBusCachedPlugin_rsp_iBusRspOutputHalt;
    wire        IBusCachedPlugin_rsp_issueDetected;
    reg         IBusCachedPlugin_rsp_redoFetch;
    wire        when_IBusCachedPlugin_l245;
    wire        when_IBusCachedPlugin_l250;
    wire        when_IBusCachedPlugin_l256;
    wire        when_IBusCachedPlugin_l262;
    wire        when_IBusCachedPlugin_l273;
    reg  [31:0] DBusCachedPlugin_rspCounter;
    wire        when_DBusCachedPlugin_l353;
    wire [ 1:0] execute_DBusCachedPlugin_size;
    reg  [31:0] _zz_execute_MEMORY_STORE_DATA_RF;
    wire        axi_core_cpu_dataCache_1_io_cpu_flush_isStall;
    wire        when_DBusCachedPlugin_l395;
    wire        when_DBusCachedPlugin_l411;
    wire        when_DBusCachedPlugin_l473;
    wire        when_DBusCachedPlugin_l534;
    wire        when_DBusCachedPlugin_l554;
    wire [31:0] writeBack_DBusCachedPlugin_rspData;
    wire [ 7:0] writeBack_DBusCachedPlugin_rspSplits_0;
    wire [ 7:0] writeBack_DBusCachedPlugin_rspSplits_1;
    wire [ 7:0] writeBack_DBusCachedPlugin_rspSplits_2;
    wire [ 7:0] writeBack_DBusCachedPlugin_rspSplits_3;
    reg  [31:0] writeBack_DBusCachedPlugin_rspShifted;
    wire [31:0] writeBack_DBusCachedPlugin_rspRf;
    wire [ 1:0] switch_Misc_l241;
    wire        _zz_writeBack_DBusCachedPlugin_rspFormated;
    reg  [31:0] _zz_writeBack_DBusCachedPlugin_rspFormated_1;
    wire        _zz_writeBack_DBusCachedPlugin_rspFormated_2;
    reg  [31:0] _zz_writeBack_DBusCachedPlugin_rspFormated_3;
    reg  [31:0] writeBack_DBusCachedPlugin_rspFormated;
    wire        when_DBusCachedPlugin_l581;
    wire [31:0] _zz_decode_IS_CSR;
    wire        _zz_decode_IS_CSR_1;
    wire        _zz_decode_IS_CSR_2;
    wire        _zz_decode_IS_CSR_3;
    wire        _zz_decode_IS_CSR_4;
    wire        _zz_decode_IS_CSR_5;
    wire [ 1:0] _zz_decode_SRC1_CTRL_2;
    wire [ 1:0] _zz_decode_ALU_CTRL_2;
    wire [ 1:0] _zz_decode_SRC2_CTRL_2;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL_2;
    wire [ 1:0] _zz_decode_SHIFT_CTRL_2;
    wire [ 1:0] _zz_decode_BRANCH_CTRL_2;
    wire [ 0:0] _zz_decode_ENV_CTRL_2;
    wire        when_RegFilePlugin_l63;
    wire [ 4:0] decode_RegFilePlugin_regFileReadAddress1;
    wire [ 4:0] decode_RegFilePlugin_regFileReadAddress2;
    wire [31:0] decode_RegFilePlugin_rs1Data;
    wire [31:0] decode_RegFilePlugin_rs2Data;
    reg         lastStageRegFileWrite_valid  /* verilator public */;
    reg  [ 4:0] lastStageRegFileWrite_payload_address  /* verilator public */;
    reg  [31:0] lastStageRegFileWrite_payload_data  /* verilator public */;
    reg         _zz_10;
    reg  [31:0] execute_IntAluPlugin_bitwise;
    reg  [31:0] _zz_execute_REGFILE_WRITE_DATA;
    reg  [31:0] _zz_execute_SRC1;
    wire        _zz_execute_SRC2;
    reg  [19:0] _zz_execute_SRC2_1;
    wire        _zz_execute_SRC2_2;
    reg  [19:0] _zz_execute_SRC2_3;
    reg  [31:0] _zz_execute_SRC2_4;
    reg  [31:0] execute_SrcPlugin_addSub;
    wire        execute_SrcPlugin_less;
    wire [ 4:0] execute_FullBarrelShifterPlugin_amplitude;
    reg  [31:0] _zz_execute_FullBarrelShifterPlugin_reversed;
    wire [31:0] execute_FullBarrelShifterPlugin_reversed;
    reg  [31:0] _zz_decode_RS2_3;
    reg         execute_MulPlugin_aSigned;
    reg         execute_MulPlugin_bSigned;
    wire [31:0] execute_MulPlugin_a;
    wire [31:0] execute_MulPlugin_b;
    wire [ 1:0] switch_MulPlugin_l87;
    wire [15:0] execute_MulPlugin_aULow;
    wire [15:0] execute_MulPlugin_bULow;
    wire [16:0] execute_MulPlugin_aSLow;
    wire [16:0] execute_MulPlugin_bSLow;
    wire [16:0] execute_MulPlugin_aHigh;
    wire [16:0] execute_MulPlugin_bHigh;
    wire [65:0] writeBack_MulPlugin_result;
    wire        when_MulPlugin_l147;
    wire [ 1:0] switch_MulPlugin_l148;
    reg  [32:0] memory_DivPlugin_rs1;
    reg  [31:0] memory_DivPlugin_rs2;
    reg  [64:0] memory_DivPlugin_accumulator;
    wire        memory_DivPlugin_frontendOk;
    reg         memory_DivPlugin_div_needRevert;
    reg         memory_DivPlugin_div_counter_willIncrement;
    reg         memory_DivPlugin_div_counter_willClear;
    reg  [ 5:0] memory_DivPlugin_div_counter_valueNext;
    reg  [ 5:0] memory_DivPlugin_div_counter_value;
    wire        memory_DivPlugin_div_counter_willOverflowIfInc;
    wire        memory_DivPlugin_div_counter_willOverflow;
    reg         memory_DivPlugin_div_done;
    wire        when_MulDivIterativePlugin_l126;
    wire        when_MulDivIterativePlugin_l126_1;
    reg  [31:0] memory_DivPlugin_div_result;
    wire        when_MulDivIterativePlugin_l128;
    wire        when_MulDivIterativePlugin_l129;
    wire        when_MulDivIterativePlugin_l132;
    wire [31:0] _zz_memory_DivPlugin_div_stage_0_remainderShifted;
    wire [32:0] memory_DivPlugin_div_stage_0_remainderShifted;
    wire [32:0] memory_DivPlugin_div_stage_0_remainderMinusDenominator;
    wire [31:0] memory_DivPlugin_div_stage_0_outRemainder;
    wire [31:0] memory_DivPlugin_div_stage_0_outNumerator;
    wire        when_MulDivIterativePlugin_l151;
    wire [31:0] _zz_memory_DivPlugin_div_result;
    wire        when_MulDivIterativePlugin_l162;
    wire        _zz_memory_DivPlugin_rs2;
    wire        _zz_memory_DivPlugin_rs1;
    reg  [32:0] _zz_memory_DivPlugin_rs1_1;
    reg         HazardSimplePlugin_src0Hazard;
    reg         HazardSimplePlugin_src1Hazard;
    wire        HazardSimplePlugin_writeBackWrites_valid;
    wire [ 4:0] HazardSimplePlugin_writeBackWrites_payload_address;
    wire [31:0] HazardSimplePlugin_writeBackWrites_payload_data;
    reg         HazardSimplePlugin_writeBackBuffer_valid;
    reg  [ 4:0] HazardSimplePlugin_writeBackBuffer_payload_address;
    reg  [31:0] HazardSimplePlugin_writeBackBuffer_payload_data;
    wire        HazardSimplePlugin_addr0Match;
    wire        HazardSimplePlugin_addr1Match;
    wire        when_HazardSimplePlugin_l47;
    wire        when_HazardSimplePlugin_l48;
    wire        when_HazardSimplePlugin_l51;
    wire        when_HazardSimplePlugin_l45;
    wire        when_HazardSimplePlugin_l57;
    wire        when_HazardSimplePlugin_l58;
    wire        when_HazardSimplePlugin_l48_1;
    wire        when_HazardSimplePlugin_l51_1;
    wire        when_HazardSimplePlugin_l45_1;
    wire        when_HazardSimplePlugin_l57_1;
    wire        when_HazardSimplePlugin_l58_1;
    wire        when_HazardSimplePlugin_l48_2;
    wire        when_HazardSimplePlugin_l51_2;
    wire        when_HazardSimplePlugin_l45_2;
    wire        when_HazardSimplePlugin_l57_2;
    wire        when_HazardSimplePlugin_l58_2;
    wire        when_HazardSimplePlugin_l105;
    wire        when_HazardSimplePlugin_l108;
    wire        when_HazardSimplePlugin_l113;
    wire        execute_BranchPlugin_eq;
    wire [ 2:0] switch_Misc_l241_1;
    reg         _zz_execute_BRANCH_COND_RESULT;
    reg         _zz_execute_BRANCH_COND_RESULT_1;
    wire        _zz_execute_BranchPlugin_missAlignedTarget;
    reg  [19:0] _zz_execute_BranchPlugin_missAlignedTarget_1;
    wire        _zz_execute_BranchPlugin_missAlignedTarget_2;
    reg  [10:0] _zz_execute_BranchPlugin_missAlignedTarget_3;
    wire        _zz_execute_BranchPlugin_missAlignedTarget_4;
    reg  [18:0] _zz_execute_BranchPlugin_missAlignedTarget_5;
    reg         _zz_execute_BranchPlugin_missAlignedTarget_6;
    wire        execute_BranchPlugin_missAlignedTarget;
    reg  [31:0] execute_BranchPlugin_branch_src1;
    reg  [31:0] execute_BranchPlugin_branch_src2;
    wire        _zz_execute_BranchPlugin_branch_src2;
    reg  [19:0] _zz_execute_BranchPlugin_branch_src2_1;
    wire        _zz_execute_BranchPlugin_branch_src2_2;
    reg  [10:0] _zz_execute_BranchPlugin_branch_src2_3;
    wire        _zz_execute_BranchPlugin_branch_src2_4;
    reg  [18:0] _zz_execute_BranchPlugin_branch_src2_5;
    wire [31:0] execute_BranchPlugin_branchAdder;
    wire [ 1:0] CsrPlugin_misa_base;
    wire [25:0] CsrPlugin_misa_extensions;
    wire [ 1:0] CsrPlugin_mtvec_mode;
    reg  [29:0] CsrPlugin_mtvec_base;
    reg  [31:0] CsrPlugin_mepc;
    reg         CsrPlugin_mstatus_MIE;
    reg         CsrPlugin_mstatus_MPIE;
    reg  [ 1:0] CsrPlugin_mstatus_MPP;
    reg         CsrPlugin_mip_MEIP;
    reg         CsrPlugin_mip_MTIP;
    reg         CsrPlugin_mip_MSIP;
    reg         CsrPlugin_mie_MEIE;
    reg         CsrPlugin_mie_MTIE;
    reg         CsrPlugin_mie_MSIE;
    reg         CsrPlugin_mcause_interrupt;
    reg  [ 3:0] CsrPlugin_mcause_exceptionCode;
    reg  [31:0] CsrPlugin_mtval;
    reg  [63:0] CsrPlugin_mcycle;
    reg  [63:0] CsrPlugin_minstret;
    wire        _zz_when_CsrPlugin_l1302;
    wire        _zz_when_CsrPlugin_l1302_1;
    wire        _zz_when_CsrPlugin_l1302_2;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
    reg  [ 3:0] CsrPlugin_exceptionPortCtrl_exceptionContext_code;
    reg  [31:0] CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
    wire [ 1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped;
    wire [ 1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
    wire [ 1:0] _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code;
    wire        _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1;
    wire        when_CsrPlugin_l1259;
    wire        when_CsrPlugin_l1259_1;
    wire        when_CsrPlugin_l1259_2;
    wire        when_CsrPlugin_l1259_3;
    wire        when_CsrPlugin_l1272;
    reg         CsrPlugin_interrupt_valid;
    reg  [ 3:0] CsrPlugin_interrupt_code  /* verilator public */;
    reg  [ 1:0] CsrPlugin_interrupt_targetPrivilege;
    wire        when_CsrPlugin_l1296;
    wire        when_CsrPlugin_l1302;
    wire        when_CsrPlugin_l1302_1;
    wire        when_CsrPlugin_l1302_2;
    wire        CsrPlugin_exception;
    wire        CsrPlugin_lastStageWasWfi;
    reg         CsrPlugin_pipelineLiberator_pcValids_0;
    reg         CsrPlugin_pipelineLiberator_pcValids_1;
    reg         CsrPlugin_pipelineLiberator_pcValids_2;
    wire        CsrPlugin_pipelineLiberator_active;
    wire        when_CsrPlugin_l1335;
    wire        when_CsrPlugin_l1335_1;
    wire        when_CsrPlugin_l1335_2;
    wire        when_CsrPlugin_l1340;
    reg         CsrPlugin_pipelineLiberator_done;
    wire        when_CsrPlugin_l1346;
    wire        CsrPlugin_interruptJump  /* verilator public */;
    reg         CsrPlugin_hadException  /* verilator public */;
    reg  [ 1:0] CsrPlugin_targetPrivilege;
    reg  [ 3:0] CsrPlugin_trapCause;
    wire        CsrPlugin_trapCauseEbreakDebug;
    reg  [ 1:0] CsrPlugin_xtvec_mode;
    reg  [29:0] CsrPlugin_xtvec_base;
    wire        CsrPlugin_trapEnterDebug;
    wire        when_CsrPlugin_l1390;
    wire        when_CsrPlugin_l1398;
    wire        when_CsrPlugin_l1456;
    wire [ 1:0] switch_CsrPlugin_l1460;
    reg         execute_CsrPlugin_wfiWake;
    wire        when_CsrPlugin_l1527;
    wire        execute_CsrPlugin_blockedBySideEffects;
    reg         execute_CsrPlugin_illegalAccess;
    reg         execute_CsrPlugin_illegalInstruction;
    wire        when_CsrPlugin_l1547;
    wire        when_CsrPlugin_l1548;
    reg         execute_CsrPlugin_writeInstruction;
    reg         execute_CsrPlugin_readInstruction;
    wire        execute_CsrPlugin_writeEnable;
    wire        execute_CsrPlugin_readEnable;
    wire [31:0] execute_CsrPlugin_readToWriteData;
    wire        switch_Misc_l241_2;
    reg  [31:0] _zz_CsrPlugin_csrMapping_writeDataSignal;
    wire        when_CsrPlugin_l1587;
    wire        when_CsrPlugin_l1591;
    wire [11:0] execute_CsrPlugin_csrAddress;
    reg         DebugPlugin_firstCycle;
    reg         DebugPlugin_secondCycle;
    reg         DebugPlugin_resetIt;
    reg         DebugPlugin_haltIt;
    reg         DebugPlugin_stepIt;
    reg         DebugPlugin_isPipBusy;
    reg         DebugPlugin_godmode;
    wire        when_DebugPlugin_l238;
    reg         DebugPlugin_haltedByBreak;
    reg         DebugPlugin_debugUsed  /* verilator public */;
    reg         DebugPlugin_disableEbreak;
    wire        DebugPlugin_allowEBreak;
    reg  [31:0] DebugPlugin_busReadDataReg;
    reg         _zz_when_DebugPlugin_l257;
    wire        when_DebugPlugin_l257;
    wire [ 5:0] switch_DebugPlugin_l280;
    wire        when_DebugPlugin_l284;
    wire        when_DebugPlugin_l284_1;
    wire        when_DebugPlugin_l285;
    wire        when_DebugPlugin_l285_1;
    wire        when_DebugPlugin_l286;
    wire        when_DebugPlugin_l287;
    wire        when_DebugPlugin_l288;
    wire        when_DebugPlugin_l288_1;
    wire        when_DebugPlugin_l308;
    wire        when_DebugPlugin_l311;
    wire        when_DebugPlugin_l324;
    reg         DebugPlugin_resetIt_regNext;
    wire        when_DebugPlugin_l344;
    wire        when_Pipeline_l124;
    reg  [31:0] decode_to_execute_PC;
    wire        when_Pipeline_l124_1;
    reg  [31:0] execute_to_memory_PC;
    wire        when_Pipeline_l124_2;
    reg  [31:0] memory_to_writeBack_PC;
    wire        when_Pipeline_l124_3;
    reg  [31:0] decode_to_execute_INSTRUCTION;
    wire        when_Pipeline_l124_4;
    reg  [31:0] execute_to_memory_INSTRUCTION;
    wire        when_Pipeline_l124_5;
    reg  [31:0] memory_to_writeBack_INSTRUCTION;
    wire        when_Pipeline_l124_6;
    reg  [31:0] decode_to_execute_FORMAL_PC_NEXT;
    wire        when_Pipeline_l124_7;
    reg  [31:0] execute_to_memory_FORMAL_PC_NEXT;
    wire        when_Pipeline_l124_8;
    reg  [31:0] memory_to_writeBack_FORMAL_PC_NEXT;
    wire        when_Pipeline_l124_9;
    reg         decode_to_execute_MEMORY_FORCE_CONSTISTENCY;
    wire        when_Pipeline_l124_10;
    reg  [ 1:0] decode_to_execute_SRC1_CTRL;
    wire        when_Pipeline_l124_11;
    reg         decode_to_execute_SRC_USE_SUB_LESS;
    wire        when_Pipeline_l124_12;
    reg         decode_to_execute_MEMORY_ENABLE;
    wire        when_Pipeline_l124_13;
    reg         execute_to_memory_MEMORY_ENABLE;
    wire        when_Pipeline_l124_14;
    reg         memory_to_writeBack_MEMORY_ENABLE;
    wire        when_Pipeline_l124_15;
    reg  [ 1:0] decode_to_execute_ALU_CTRL;
    wire        when_Pipeline_l124_16;
    reg  [ 1:0] decode_to_execute_SRC2_CTRL;
    wire        when_Pipeline_l124_17;
    reg         decode_to_execute_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_18;
    reg         execute_to_memory_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_19;
    reg         memory_to_writeBack_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_20;
    reg         decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
    wire        when_Pipeline_l124_21;
    reg         decode_to_execute_BYPASSABLE_MEMORY_STAGE;
    wire        when_Pipeline_l124_22;
    reg         execute_to_memory_BYPASSABLE_MEMORY_STAGE;
    wire        when_Pipeline_l124_23;
    reg         decode_to_execute_MEMORY_WR;
    wire        when_Pipeline_l124_24;
    reg         execute_to_memory_MEMORY_WR;
    wire        when_Pipeline_l124_25;
    reg         memory_to_writeBack_MEMORY_WR;
    wire        when_Pipeline_l124_26;
    reg         decode_to_execute_MEMORY_MANAGMENT;
    wire        when_Pipeline_l124_27;
    reg         decode_to_execute_SRC_LESS_UNSIGNED;
    wire        when_Pipeline_l124_28;
    reg  [ 1:0] decode_to_execute_ALU_BITWISE_CTRL;
    wire        when_Pipeline_l124_29;
    reg  [ 1:0] decode_to_execute_SHIFT_CTRL;
    wire        when_Pipeline_l124_30;
    reg  [ 1:0] execute_to_memory_SHIFT_CTRL;
    wire        when_Pipeline_l124_31;
    reg         decode_to_execute_IS_MUL;
    wire        when_Pipeline_l124_32;
    reg         execute_to_memory_IS_MUL;
    wire        when_Pipeline_l124_33;
    reg         memory_to_writeBack_IS_MUL;
    wire        when_Pipeline_l124_34;
    reg         decode_to_execute_IS_DIV;
    wire        when_Pipeline_l124_35;
    reg         execute_to_memory_IS_DIV;
    wire        when_Pipeline_l124_36;
    reg         decode_to_execute_IS_RS1_SIGNED;
    wire        when_Pipeline_l124_37;
    reg         decode_to_execute_IS_RS2_SIGNED;
    wire        when_Pipeline_l124_38;
    reg  [ 1:0] decode_to_execute_BRANCH_CTRL;
    wire        when_Pipeline_l124_39;
    reg         decode_to_execute_IS_CSR;
    wire        when_Pipeline_l124_40;
    reg  [ 0:0] decode_to_execute_ENV_CTRL;
    wire        when_Pipeline_l124_41;
    reg  [ 0:0] execute_to_memory_ENV_CTRL;
    wire        when_Pipeline_l124_42;
    reg  [ 0:0] memory_to_writeBack_ENV_CTRL;
    wire        when_Pipeline_l124_43;
    reg  [31:0] decode_to_execute_RS1;
    wire        when_Pipeline_l124_44;
    reg  [31:0] decode_to_execute_RS2;
    wire        when_Pipeline_l124_45;
    reg         decode_to_execute_SRC2_FORCE_ZERO;
    wire        when_Pipeline_l124_46;
    reg         decode_to_execute_PREDICTION_HAD_BRANCHED1;
    wire        when_Pipeline_l124_47;
    reg         decode_to_execute_CSR_WRITE_OPCODE;
    wire        when_Pipeline_l124_48;
    reg         decode_to_execute_CSR_READ_OPCODE;
    wire        when_Pipeline_l124_49;
    reg         decode_to_execute_DO_EBREAK;
    wire        when_Pipeline_l124_50;
    reg  [31:0] execute_to_memory_MEMORY_STORE_DATA_RF;
    wire        when_Pipeline_l124_51;
    reg  [31:0] memory_to_writeBack_MEMORY_STORE_DATA_RF;
    wire        when_Pipeline_l124_52;
    reg  [31:0] execute_to_memory_REGFILE_WRITE_DATA;
    wire        when_Pipeline_l124_53;
    reg  [31:0] memory_to_writeBack_REGFILE_WRITE_DATA;
    wire        when_Pipeline_l124_54;
    reg  [31:0] execute_to_memory_SHIFT_RIGHT;
    wire        when_Pipeline_l124_55;
    reg  [31:0] execute_to_memory_MUL_LL;
    wire        when_Pipeline_l124_56;
    reg  [33:0] execute_to_memory_MUL_LH;
    wire        when_Pipeline_l124_57;
    reg  [33:0] execute_to_memory_MUL_HL;
    wire        when_Pipeline_l124_58;
    reg  [33:0] execute_to_memory_MUL_HH;
    wire        when_Pipeline_l124_59;
    reg  [33:0] memory_to_writeBack_MUL_HH;
    wire        when_Pipeline_l124_60;
    reg         execute_to_memory_BRANCH_DO;
    wire        when_Pipeline_l124_61;
    reg  [31:0] execute_to_memory_BRANCH_CALC;
    wire        when_Pipeline_l124_62;
    reg  [51:0] memory_to_writeBack_MUL_LOW;
    wire        when_Pipeline_l151;
    wire        when_Pipeline_l154;
    wire        when_Pipeline_l151_1;
    wire        when_Pipeline_l154_1;
    wire        when_Pipeline_l151_2;
    wire        when_Pipeline_l154_2;
    reg  [ 2:0] IBusCachedPlugin_injector_port_state;
    wire        when_Fetcher_l391;
    wire        when_CsrPlugin_l1669;
    reg         execute_CsrPlugin_csr_768;
    wire        when_CsrPlugin_l1669_1;
    reg         execute_CsrPlugin_csr_836;
    wire        when_CsrPlugin_l1669_2;
    reg         execute_CsrPlugin_csr_772;
    wire        when_CsrPlugin_l1669_3;
    reg         execute_CsrPlugin_csr_773;
    wire        when_CsrPlugin_l1669_4;
    reg         execute_CsrPlugin_csr_833;
    wire        when_CsrPlugin_l1669_5;
    reg         execute_CsrPlugin_csr_834;
    wire        when_CsrPlugin_l1669_6;
    reg         execute_CsrPlugin_csr_835;
    wire [ 1:0] switch_CsrPlugin_l1031;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_1;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_2;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_3;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_4;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_5;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_6;
    wire        when_CsrPlugin_l1702;
    wire [11:0] _zz_when_CsrPlugin_l1709;
    wire        when_CsrPlugin_l1709;
    reg         when_CsrPlugin_l1719;
    wire        when_CsrPlugin_l1717;
    wire        when_CsrPlugin_l1725;
`ifndef SYNTHESIS
    reg [31:0] _zz_memory_to_writeBack_ENV_CTRL_string;
    reg [31:0] _zz_memory_to_writeBack_ENV_CTRL_1_string;
    reg [31:0] _zz_execute_to_memory_ENV_CTRL_string;
    reg [31:0] _zz_execute_to_memory_ENV_CTRL_1_string;
    reg [31:0] decode_ENV_CTRL_string;
    reg [31:0] _zz_decode_ENV_CTRL_string;
    reg [31:0] _zz_decode_to_execute_ENV_CTRL_string;
    reg [31:0] _zz_decode_to_execute_ENV_CTRL_1_string;
    reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_string;
    reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_1_string;
    reg [71:0] _zz_execute_to_memory_SHIFT_CTRL_string;
    reg [71:0] _zz_execute_to_memory_SHIFT_CTRL_1_string;
    reg [71:0] decode_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_1_string;
    reg [39:0] decode_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string;
    reg [23:0] decode_SRC2_CTRL_string;
    reg [23:0] _zz_decode_SRC2_CTRL_string;
    reg [23:0] _zz_decode_to_execute_SRC2_CTRL_string;
    reg [23:0] _zz_decode_to_execute_SRC2_CTRL_1_string;
    reg [63:0] decode_ALU_CTRL_string;
    reg [63:0] _zz_decode_ALU_CTRL_string;
    reg [63:0] _zz_decode_to_execute_ALU_CTRL_string;
    reg [63:0] _zz_decode_to_execute_ALU_CTRL_1_string;
    reg [95:0] decode_SRC1_CTRL_string;
    reg [95:0] _zz_decode_SRC1_CTRL_string;
    reg [95:0] _zz_decode_to_execute_SRC1_CTRL_string;
    reg [95:0] _zz_decode_to_execute_SRC1_CTRL_1_string;
    reg [31:0] memory_ENV_CTRL_string;
    reg [31:0] _zz_memory_ENV_CTRL_string;
    reg [31:0] execute_ENV_CTRL_string;
    reg [31:0] _zz_execute_ENV_CTRL_string;
    reg [31:0] writeBack_ENV_CTRL_string;
    reg [31:0] _zz_writeBack_ENV_CTRL_string;
    reg [31:0] execute_BRANCH_CTRL_string;
    reg [31:0] _zz_execute_BRANCH_CTRL_string;
    reg [71:0] memory_SHIFT_CTRL_string;
    reg [71:0] _zz_memory_SHIFT_CTRL_string;
    reg [71:0] execute_SHIFT_CTRL_string;
    reg [71:0] _zz_execute_SHIFT_CTRL_string;
    reg [23:0] execute_SRC2_CTRL_string;
    reg [23:0] _zz_execute_SRC2_CTRL_string;
    reg [95:0] execute_SRC1_CTRL_string;
    reg [95:0] _zz_execute_SRC1_CTRL_string;
    reg [63:0] execute_ALU_CTRL_string;
    reg [63:0] _zz_execute_ALU_CTRL_string;
    reg [39:0] execute_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_execute_ALU_BITWISE_CTRL_string;
    reg [31:0] _zz_decode_ENV_CTRL_1_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_1_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_1_string;
    reg [23:0] _zz_decode_SRC2_CTRL_1_string;
    reg [63:0] _zz_decode_ALU_CTRL_1_string;
    reg [95:0] _zz_decode_SRC1_CTRL_1_string;
    reg [31:0] decode_BRANCH_CTRL_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_1_string;
    reg [95:0] _zz_decode_SRC1_CTRL_2_string;
    reg [63:0] _zz_decode_ALU_CTRL_2_string;
    reg [23:0] _zz_decode_SRC2_CTRL_2_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_2_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_2_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_2_string;
    reg [31:0] _zz_decode_ENV_CTRL_2_string;
    reg [95:0] decode_to_execute_SRC1_CTRL_string;
    reg [63:0] decode_to_execute_ALU_CTRL_string;
    reg [23:0] decode_to_execute_SRC2_CTRL_string;
    reg [39:0] decode_to_execute_ALU_BITWISE_CTRL_string;
    reg [71:0] decode_to_execute_SHIFT_CTRL_string;
    reg [71:0] execute_to_memory_SHIFT_CTRL_string;
    reg [31:0] decode_to_execute_BRANCH_CTRL_string;
    reg [31:0] decode_to_execute_ENV_CTRL_string;
    reg [31:0] execute_to_memory_ENV_CTRL_string;
    reg [31:0] memory_to_writeBack_ENV_CTRL_string;
`endif

    reg [31:0] RegFilePlugin_regFile[0:31]  /* verilator public */;

    assign _zz_when = (|{decodeExceptionPort_valid, IBusCachedPlugin_decodeExceptionPort_valid});
    assign _zz_memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW_1) + $signed(_zz_memory_MUL_LOW_4));
    assign _zz_memory_MUL_LOW_1 = ($signed(52'h0) + $signed(_zz_memory_MUL_LOW_2));
    assign _zz_memory_MUL_LOW_3 = {1'b0, memory_MUL_LL};
    assign _zz_memory_MUL_LOW_2 = {{19{_zz_memory_MUL_LOW_3[32]}}, _zz_memory_MUL_LOW_3};
    assign _zz_memory_MUL_LOW_5 = ({16'd0, memory_MUL_LH} <<< 5'd16);
    assign _zz_memory_MUL_LOW_4 = {{2{_zz_memory_MUL_LOW_5[49]}}, _zz_memory_MUL_LOW_5};
    assign _zz_memory_MUL_LOW_7 = ({16'd0, memory_MUL_HL} <<< 5'd16);
    assign _zz_memory_MUL_LOW_6 = {{2{_zz_memory_MUL_LOW_7[49]}}, _zz_memory_MUL_LOW_7};
    assign _zz_execute_SHIFT_RIGHT_1 = ($signed(
        _zz_execute_SHIFT_RIGHT_2
    ) >>> execute_FullBarrelShifterPlugin_amplitude);
    assign _zz_execute_SHIFT_RIGHT = _zz_execute_SHIFT_RIGHT_1[31 : 0];
    assign _zz_execute_SHIFT_RIGHT_2 = {
        ((execute_SHIFT_CTRL == ShiftCtrlEnum_SRA_1) && execute_FullBarrelShifterPlugin_reversed[31]),
        execute_FullBarrelShifterPlugin_reversed
    };
    assign _zz__zz_IBusCachedPlugin_jump_pcLoad_payload_1 = (_zz_IBusCachedPlugin_jump_pcLoad_payload - 4'b0001);
    assign _zz_IBusCachedPlugin_fetchPc_pc_1 = {IBusCachedPlugin_fetchPc_inc, 2'b00};
    assign _zz_IBusCachedPlugin_fetchPc_pc = {29'd0, _zz_IBusCachedPlugin_fetchPc_pc_1};
    assign _zz__zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch = {
        {{decode_INSTRUCTION[31], decode_INSTRUCTION[7]}, decode_INSTRUCTION[30 : 25]},
        decode_INSTRUCTION[11 : 8]
    };
    assign _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_2 = {
        {
            _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1,
            {
                {{decode_INSTRUCTION[31], decode_INSTRUCTION[7]}, decode_INSTRUCTION[30 : 25]},
                decode_INSTRUCTION[11 : 8]
            }
        },
        1'b0
    };
    assign _zz__zz_2 = {
        {{decode_INSTRUCTION[31], decode_INSTRUCTION[19 : 12]}, decode_INSTRUCTION[20]},
        decode_INSTRUCTION[30 : 21]
    };
    assign _zz__zz_4 = {
        {{decode_INSTRUCTION[31], decode_INSTRUCTION[7]}, decode_INSTRUCTION[30 : 25]},
        decode_INSTRUCTION[11 : 8]
    };
    assign _zz__zz_6 = {
        {
            _zz_3,
            {
                {{decode_INSTRUCTION[31], decode_INSTRUCTION[19 : 12]}, decode_INSTRUCTION[20]},
                decode_INSTRUCTION[30 : 21]
            }
        },
        1'b0
    };
    assign _zz__zz_6_1 = {
        {
            _zz_5,
            {
                {{decode_INSTRUCTION[31], decode_INSTRUCTION[7]}, decode_INSTRUCTION[30 : 25]},
                decode_INSTRUCTION[11 : 8]
            }
        },
        1'b0
    };
    assign _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload = {
        {{decode_INSTRUCTION[31], decode_INSTRUCTION[19 : 12]}, decode_INSTRUCTION[20]},
        decode_INSTRUCTION[30 : 21]
    };
    assign _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload_2 = {
        {{decode_INSTRUCTION[31], decode_INSTRUCTION[7]}, decode_INSTRUCTION[30 : 25]},
        decode_INSTRUCTION[11 : 8]
    };
    assign _zz_io_cpu_flush_payload_lineId = _zz_io_cpu_flush_payload_lineId_1;
    assign _zz_io_cpu_flush_payload_lineId_1 = (execute_RS1 >>> 3'd5);
    assign _zz_DBusCachedPlugin_exceptionBus_payload_code = (writeBack_MEMORY_WR ? 3'b111 : 3'b101);
    assign _zz_DBusCachedPlugin_exceptionBus_payload_code_1 = (writeBack_MEMORY_WR ? 3'b110 : 3'b100);
    assign _zz__zz_execute_REGFILE_WRITE_DATA = execute_SRC_LESS;
    assign _zz__zz_execute_SRC1 = 3'b100;
    assign _zz__zz_execute_SRC1_1 = execute_INSTRUCTION[19 : 15];
    assign _zz__zz_execute_SRC2_2 = {execute_INSTRUCTION[31 : 25], execute_INSTRUCTION[11 : 7]};
    assign _zz_execute_SrcPlugin_addSub = ($signed(
        _zz_execute_SrcPlugin_addSub_1
    ) + $signed(
        _zz_execute_SrcPlugin_addSub_4
    ));
    assign _zz_execute_SrcPlugin_addSub_1 = ($signed(
        _zz_execute_SrcPlugin_addSub_2
    ) + $signed(
        _zz_execute_SrcPlugin_addSub_3
    ));
    assign _zz_execute_SrcPlugin_addSub_2 = execute_SRC1;
    assign _zz_execute_SrcPlugin_addSub_3 = (execute_SRC_USE_SUB_LESS ? (~ execute_SRC2) : execute_SRC2);
    assign _zz_execute_SrcPlugin_addSub_4 = (execute_SRC_USE_SUB_LESS ? 32'h00000001 : 32'h0);
    assign _zz_writeBack_MulPlugin_result = {{14{writeBack_MUL_LOW[51]}}, writeBack_MUL_LOW};
    assign _zz_writeBack_MulPlugin_result_1 = ({32'd0, writeBack_MUL_HH} <<< 6'd32);
    assign _zz__zz_decode_RS2_2 = writeBack_MUL_LOW[31 : 0];
    assign _zz__zz_decode_RS2_2_1 = writeBack_MulPlugin_result[63 : 32];
    assign _zz_memory_DivPlugin_div_counter_valueNext_1 = memory_DivPlugin_div_counter_willIncrement;
    assign _zz_memory_DivPlugin_div_counter_valueNext = {
        5'd0, _zz_memory_DivPlugin_div_counter_valueNext_1
    };
    assign _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator = {
        1'd0, memory_DivPlugin_rs2
    };
    assign _zz_memory_DivPlugin_div_stage_0_outRemainder = memory_DivPlugin_div_stage_0_remainderMinusDenominator[31:0];
    assign _zz_memory_DivPlugin_div_stage_0_outRemainder_1 = memory_DivPlugin_div_stage_0_remainderShifted[31:0];
    assign _zz_memory_DivPlugin_div_stage_0_outNumerator = {
        _zz_memory_DivPlugin_div_stage_0_remainderShifted,
        (!memory_DivPlugin_div_stage_0_remainderMinusDenominator[32])
    };
    assign _zz_memory_DivPlugin_div_result_1 = _zz_memory_DivPlugin_div_result_2;
    assign _zz_memory_DivPlugin_div_result_2 = _zz_memory_DivPlugin_div_result_3;
    assign _zz_memory_DivPlugin_div_result_3 = ({memory_DivPlugin_div_needRevert,(memory_DivPlugin_div_needRevert ? (~ _zz_memory_DivPlugin_div_result) : _zz_memory_DivPlugin_div_result)} + _zz_memory_DivPlugin_div_result_4);
    assign _zz_memory_DivPlugin_div_result_5 = memory_DivPlugin_div_needRevert;
    assign _zz_memory_DivPlugin_div_result_4 = {32'd0, _zz_memory_DivPlugin_div_result_5};
    assign _zz_memory_DivPlugin_rs1_3 = _zz_memory_DivPlugin_rs1;
    assign _zz_memory_DivPlugin_rs1_2 = {32'd0, _zz_memory_DivPlugin_rs1_3};
    assign _zz_memory_DivPlugin_rs2_2 = _zz_memory_DivPlugin_rs2;
    assign _zz_memory_DivPlugin_rs2_1 = {31'd0, _zz_memory_DivPlugin_rs2_2};
    assign _zz__zz_execute_BranchPlugin_missAlignedTarget_2 = {
        {{execute_INSTRUCTION[31], execute_INSTRUCTION[19 : 12]}, execute_INSTRUCTION[20]},
        execute_INSTRUCTION[30 : 21]
    };
    assign _zz__zz_execute_BranchPlugin_missAlignedTarget_4 = {
        {{execute_INSTRUCTION[31], execute_INSTRUCTION[7]}, execute_INSTRUCTION[30 : 25]},
        execute_INSTRUCTION[11 : 8]
    };
    assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6 = {
        _zz_execute_BranchPlugin_missAlignedTarget_1, execute_INSTRUCTION[31 : 20]
    };
    assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1 = {
        {
            _zz_execute_BranchPlugin_missAlignedTarget_3,
            {
                {{execute_INSTRUCTION[31], execute_INSTRUCTION[19 : 12]}, execute_INSTRUCTION[20]},
                execute_INSTRUCTION[30 : 21]
            }
        },
        1'b0
    };
    assign _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2 = {
        {
            _zz_execute_BranchPlugin_missAlignedTarget_5,
            {
                {{execute_INSTRUCTION[31], execute_INSTRUCTION[7]}, execute_INSTRUCTION[30 : 25]},
                execute_INSTRUCTION[11 : 8]
            }
        },
        1'b0
    };
    assign _zz__zz_execute_BranchPlugin_branch_src2_2 = {
        {{execute_INSTRUCTION[31], execute_INSTRUCTION[19 : 12]}, execute_INSTRUCTION[20]},
        execute_INSTRUCTION[30 : 21]
    };
    assign _zz__zz_execute_BranchPlugin_branch_src2_4 = {
        {{execute_INSTRUCTION[31], execute_INSTRUCTION[7]}, execute_INSTRUCTION[30 : 25]},
        execute_INSTRUCTION[11 : 8]
    };
    assign _zz_execute_BranchPlugin_branch_src2_11 = 3'b100;
    assign _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 = (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code & (~ _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1_1));
    assign _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1_1 = (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code - 2'b01);
    assign _zz_decode_RegFilePlugin_rs1Data = 1'b1;
    assign _zz_decode_RegFilePlugin_rs2Data = 1'b1;
    assign _zz_IBusCachedPlugin_jump_pcLoad_payload_6 = {
        _zz_IBusCachedPlugin_jump_pcLoad_payload_4, _zz_IBusCachedPlugin_jump_pcLoad_payload_3
    };
    assign _zz_writeBack_DBusCachedPlugin_rspShifted_1 = dataCache_1_io_cpu_writeBack_address[1 : 0];
    assign _zz_writeBack_DBusCachedPlugin_rspShifted_3 = dataCache_1_io_cpu_writeBack_address[1 : 1];
    assign _zz_decode_LEGAL_INSTRUCTION = 32'h0000107f;
    assign _zz_decode_LEGAL_INSTRUCTION_1 = (decode_INSTRUCTION & 32'h0000207f);
    assign _zz_decode_LEGAL_INSTRUCTION_2 = 32'h00002073;
    assign _zz_decode_LEGAL_INSTRUCTION_3 = ((decode_INSTRUCTION & 32'h0000407f) == 32'h00004063);
    assign _zz_decode_LEGAL_INSTRUCTION_4 = ((decode_INSTRUCTION & 32'h0000207f) == 32'h00002013);
    assign _zz_decode_LEGAL_INSTRUCTION_5 = {
        ((decode_INSTRUCTION & 32'h0000107f) == 32'h00000013),
        {
            ((decode_INSTRUCTION & 32'h0000603f) == 32'h00000023),
            {
                ((decode_INSTRUCTION & _zz_decode_LEGAL_INSTRUCTION_6) == 32'h00000003),
                {
                    (_zz_decode_LEGAL_INSTRUCTION_7 == _zz_decode_LEGAL_INSTRUCTION_8),
                    {
                        _zz_decode_LEGAL_INSTRUCTION_9,
                        {_zz_decode_LEGAL_INSTRUCTION_10, _zz_decode_LEGAL_INSTRUCTION_11}
                    }
                }
            }
        }
    };
    assign _zz_decode_LEGAL_INSTRUCTION_6 = 32'h0000207f;
    assign _zz_decode_LEGAL_INSTRUCTION_7 = (decode_INSTRUCTION & 32'h0000505f);
    assign _zz_decode_LEGAL_INSTRUCTION_8 = 32'h00000003;
    assign _zz_decode_LEGAL_INSTRUCTION_9 = ((decode_INSTRUCTION & 32'h0000707b) == 32'h00000063);
    assign _zz_decode_LEGAL_INSTRUCTION_10 = ((decode_INSTRUCTION & 32'h0000607f) == 32'h0000000f);
    assign _zz_decode_LEGAL_INSTRUCTION_11 = {
        ((decode_INSTRUCTION & 32'hfc00007f) == 32'h00000033),
        {
            ((decode_INSTRUCTION & 32'h01f0707f) == 32'h0000500f),
            {
                ((decode_INSTRUCTION & _zz_decode_LEGAL_INSTRUCTION_12) == 32'h00005013),
                {
                    (_zz_decode_LEGAL_INSTRUCTION_13 == _zz_decode_LEGAL_INSTRUCTION_14),
                    {
                        _zz_decode_LEGAL_INSTRUCTION_15,
                        {_zz_decode_LEGAL_INSTRUCTION_16, _zz_decode_LEGAL_INSTRUCTION_17}
                    }
                }
            }
        }
    };
    assign _zz_decode_LEGAL_INSTRUCTION_12 = 32'hbe00705f;
    assign _zz_decode_LEGAL_INSTRUCTION_13 = (decode_INSTRUCTION & 32'hfe00305f);
    assign _zz_decode_LEGAL_INSTRUCTION_14 = 32'h00001013;
    assign _zz_decode_LEGAL_INSTRUCTION_15 = ((decode_INSTRUCTION & 32'hbe00707f) == 32'h00000033);
    assign _zz_decode_LEGAL_INSTRUCTION_16 = ((decode_INSTRUCTION & 32'hdfffffff) == 32'h10200073);
    assign _zz_decode_LEGAL_INSTRUCTION_17 = ((decode_INSTRUCTION & 32'hffffffff) == 32'h00100073);
    assign _zz_IBusCachedPlugin_predictionJumpInterface_payload_4 = decode_INSTRUCTION[31];
    assign _zz_IBusCachedPlugin_predictionJumpInterface_payload_5 = decode_INSTRUCTION[31];
    assign _zz_IBusCachedPlugin_predictionJumpInterface_payload_6 = decode_INSTRUCTION[7];
    assign _zz__zz_decode_IS_CSR = 32'h00103050;
    assign _zz__zz_decode_IS_CSR_1 = ((decode_INSTRUCTION & 32'h00001050) == 32'h00001050);
    assign _zz__zz_decode_IS_CSR_2 = ((decode_INSTRUCTION & 32'h00002050) == 32'h00002050);
    assign _zz__zz_decode_IS_CSR_3 = _zz_decode_IS_CSR_4;
    assign _zz__zz_decode_IS_CSR_4 = ((decode_INSTRUCTION & 32'h0000001c) == 32'h00000004);
    assign _zz__zz_decode_IS_CSR_5 = ((decode_INSTRUCTION & 32'h00000058) == 32'h00000040);
    assign _zz__zz_decode_IS_CSR_6 = (|_zz_decode_IS_CSR_5);
    assign _zz__zz_decode_IS_CSR_7 = (|_zz_decode_IS_CSR_5);
    assign _zz__zz_decode_IS_CSR_8 = {
        (|_zz__zz_decode_IS_CSR_9),
        {
            (|_zz__zz_decode_IS_CSR_10),
            {_zz__zz_decode_IS_CSR_11, {_zz__zz_decode_IS_CSR_13, _zz__zz_decode_IS_CSR_16}}
        }
    };
    assign _zz__zz_decode_IS_CSR_9 = ((decode_INSTRUCTION & 32'h02004064) == 32'h02004020);
    assign _zz__zz_decode_IS_CSR_10 = ((decode_INSTRUCTION & 32'h02004074) == 32'h02000030);
    assign _zz__zz_decode_IS_CSR_11 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_12) == 32'h00005010));
    assign _zz__zz_decode_IS_CSR_13 = (|{_zz__zz_decode_IS_CSR_14, _zz__zz_decode_IS_CSR_15});
    assign _zz__zz_decode_IS_CSR_16 = {
        (|_zz__zz_decode_IS_CSR_17),
        {
            (|_zz__zz_decode_IS_CSR_18),
            {_zz__zz_decode_IS_CSR_19, {_zz__zz_decode_IS_CSR_21, _zz__zz_decode_IS_CSR_24}}
        }
    };
    assign _zz__zz_decode_IS_CSR_12 = 32'h02007054;
    assign _zz__zz_decode_IS_CSR_14 = ((decode_INSTRUCTION & 32'h40003054) == 32'h40001010);
    assign _zz__zz_decode_IS_CSR_15 = ((decode_INSTRUCTION & 32'h02007054) == 32'h00001010);
    assign _zz__zz_decode_IS_CSR_17 = ((decode_INSTRUCTION & 32'h00000064) == 32'h00000024);
    assign _zz__zz_decode_IS_CSR_18 = ((decode_INSTRUCTION & 32'h00001000) == 32'h00001000);
    assign _zz__zz_decode_IS_CSR_19 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_20) == 32'h00002000));
    assign _zz__zz_decode_IS_CSR_21 = (|{_zz__zz_decode_IS_CSR_22, _zz__zz_decode_IS_CSR_23});
    assign _zz__zz_decode_IS_CSR_24 = {
        (|_zz__zz_decode_IS_CSR_25),
        {
            (|_zz__zz_decode_IS_CSR_26),
            {_zz__zz_decode_IS_CSR_31, {_zz__zz_decode_IS_CSR_36, _zz__zz_decode_IS_CSR_38}}
        }
    };
    assign _zz__zz_decode_IS_CSR_20 = 32'h00003000;
    assign _zz__zz_decode_IS_CSR_22 = ((decode_INSTRUCTION & 32'h00002010) == 32'h00002000);
    assign _zz__zz_decode_IS_CSR_23 = ((decode_INSTRUCTION & 32'h00005000) == 32'h00001000);
    assign _zz__zz_decode_IS_CSR_25 = ((decode_INSTRUCTION & 32'h00004048) == 32'h00004008);
    assign _zz__zz_decode_IS_CSR_26 = {
        (_zz__zz_decode_IS_CSR_27 == _zz__zz_decode_IS_CSR_28),
        (_zz__zz_decode_IS_CSR_29 == _zz__zz_decode_IS_CSR_30)
    };
    assign _zz__zz_decode_IS_CSR_31 = (|{_zz__zz_decode_IS_CSR_32, {
        _zz__zz_decode_IS_CSR_33, _zz__zz_decode_IS_CSR_34
    }});
    assign _zz__zz_decode_IS_CSR_36 = (|_zz__zz_decode_IS_CSR_37);
    assign _zz__zz_decode_IS_CSR_38 = {
        (|_zz__zz_decode_IS_CSR_39),
        {_zz__zz_decode_IS_CSR_50, {_zz__zz_decode_IS_CSR_63, _zz__zz_decode_IS_CSR_77}}
    };
    assign _zz__zz_decode_IS_CSR_27 = (decode_INSTRUCTION & 32'h00000034);
    assign _zz__zz_decode_IS_CSR_28 = 32'h00000020;
    assign _zz__zz_decode_IS_CSR_29 = (decode_INSTRUCTION & 32'h00000064);
    assign _zz__zz_decode_IS_CSR_30 = 32'h00000020;
    assign _zz__zz_decode_IS_CSR_32 = ((decode_INSTRUCTION & 32'h00000050) == 32'h00000040);
    assign _zz__zz_decode_IS_CSR_33 = _zz_decode_IS_CSR_2;
    assign _zz__zz_decode_IS_CSR_34 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_35) == 32'h00000040);
    assign _zz__zz_decode_IS_CSR_37 = ((decode_INSTRUCTION & 32'h00000020) == 32'h00000020);
    assign _zz__zz_decode_IS_CSR_39 = {
        (_zz__zz_decode_IS_CSR_40 == _zz__zz_decode_IS_CSR_41),
        {_zz_decode_IS_CSR_3, {_zz__zz_decode_IS_CSR_42, _zz__zz_decode_IS_CSR_45}}
    };
    assign _zz__zz_decode_IS_CSR_50 = (|{_zz_decode_IS_CSR_3, {
        _zz__zz_decode_IS_CSR_51, _zz__zz_decode_IS_CSR_54
    }});
    assign _zz__zz_decode_IS_CSR_63 = (|{_zz__zz_decode_IS_CSR_64, _zz__zz_decode_IS_CSR_65});
    assign _zz__zz_decode_IS_CSR_77 = {
        (|_zz__zz_decode_IS_CSR_78),
        {_zz__zz_decode_IS_CSR_81, {_zz__zz_decode_IS_CSR_86, _zz__zz_decode_IS_CSR_90}}
    };
    assign _zz__zz_decode_IS_CSR_35 = 32'h00103040;
    assign _zz__zz_decode_IS_CSR_40 = (decode_INSTRUCTION & 32'h00000040);
    assign _zz__zz_decode_IS_CSR_41 = 32'h00000040;
    assign _zz__zz_decode_IS_CSR_42 = (_zz__zz_decode_IS_CSR_43 == _zz__zz_decode_IS_CSR_44);
    assign _zz__zz_decode_IS_CSR_45 = {_zz__zz_decode_IS_CSR_46, _zz__zz_decode_IS_CSR_48};
    assign _zz__zz_decode_IS_CSR_51 = (_zz__zz_decode_IS_CSR_52 == _zz__zz_decode_IS_CSR_53);
    assign _zz__zz_decode_IS_CSR_54 = {
        _zz__zz_decode_IS_CSR_55, {_zz__zz_decode_IS_CSR_57, _zz__zz_decode_IS_CSR_60}
    };
    assign _zz__zz_decode_IS_CSR_64 = _zz_decode_IS_CSR_4;
    assign _zz__zz_decode_IS_CSR_65 = {
        _zz__zz_decode_IS_CSR_66, {_zz__zz_decode_IS_CSR_68, _zz__zz_decode_IS_CSR_71}
    };
    assign _zz__zz_decode_IS_CSR_78 = {_zz_decode_IS_CSR_3, _zz__zz_decode_IS_CSR_79};
    assign _zz__zz_decode_IS_CSR_81 = (|{_zz__zz_decode_IS_CSR_82, _zz__zz_decode_IS_CSR_83});
    assign _zz__zz_decode_IS_CSR_86 = (|_zz__zz_decode_IS_CSR_87);
    assign _zz__zz_decode_IS_CSR_90 = {
        _zz__zz_decode_IS_CSR_91, {_zz__zz_decode_IS_CSR_93, _zz__zz_decode_IS_CSR_104}
    };
    assign _zz__zz_decode_IS_CSR_43 = (decode_INSTRUCTION & 32'h00004020);
    assign _zz__zz_decode_IS_CSR_44 = 32'h00004020;
    assign _zz__zz_decode_IS_CSR_46 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_47) == 32'h00000010);
    assign _zz__zz_decode_IS_CSR_48 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_49) == 32'h00000020);
    assign _zz__zz_decode_IS_CSR_52 = (decode_INSTRUCTION & 32'h00002030);
    assign _zz__zz_decode_IS_CSR_53 = 32'h00002010;
    assign _zz__zz_decode_IS_CSR_55 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_56) == 32'h00000010);
    assign _zz__zz_decode_IS_CSR_57 = (_zz__zz_decode_IS_CSR_58 == _zz__zz_decode_IS_CSR_59);
    assign _zz__zz_decode_IS_CSR_60 = (_zz__zz_decode_IS_CSR_61 == _zz__zz_decode_IS_CSR_62);
    assign _zz__zz_decode_IS_CSR_66 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_67) == 32'h00001010);
    assign _zz__zz_decode_IS_CSR_68 = (_zz__zz_decode_IS_CSR_69 == _zz__zz_decode_IS_CSR_70);
    assign _zz__zz_decode_IS_CSR_71 = {
        _zz__zz_decode_IS_CSR_72, {_zz__zz_decode_IS_CSR_73, _zz__zz_decode_IS_CSR_75}
    };
    assign _zz__zz_decode_IS_CSR_79 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_80) == 32'h00000020);
    assign _zz__zz_decode_IS_CSR_82 = _zz_decode_IS_CSR_3;
    assign _zz__zz_decode_IS_CSR_83 = (_zz__zz_decode_IS_CSR_84 == _zz__zz_decode_IS_CSR_85);
    assign _zz__zz_decode_IS_CSR_87 = (_zz__zz_decode_IS_CSR_88 == _zz__zz_decode_IS_CSR_89);
    assign _zz__zz_decode_IS_CSR_91 = (|_zz__zz_decode_IS_CSR_92);
    assign _zz__zz_decode_IS_CSR_93 = (|_zz__zz_decode_IS_CSR_94);
    assign _zz__zz_decode_IS_CSR_104 = {
        _zz__zz_decode_IS_CSR_105, {_zz__zz_decode_IS_CSR_108, _zz__zz_decode_IS_CSR_116}
    };
    assign _zz__zz_decode_IS_CSR_47 = 32'h00000030;
    assign _zz__zz_decode_IS_CSR_49 = 32'h02000020;
    assign _zz__zz_decode_IS_CSR_56 = 32'h00001030;
    assign _zz__zz_decode_IS_CSR_58 = (decode_INSTRUCTION & 32'h02002060);
    assign _zz__zz_decode_IS_CSR_59 = 32'h00002020;
    assign _zz__zz_decode_IS_CSR_61 = (decode_INSTRUCTION & 32'h02003020);
    assign _zz__zz_decode_IS_CSR_62 = 32'h00000020;
    assign _zz__zz_decode_IS_CSR_67 = 32'h00001010;
    assign _zz__zz_decode_IS_CSR_69 = (decode_INSTRUCTION & 32'h00002010);
    assign _zz__zz_decode_IS_CSR_70 = 32'h00002010;
    assign _zz__zz_decode_IS_CSR_72 = ((decode_INSTRUCTION & 32'h00000050) == 32'h00000010);
    assign _zz__zz_decode_IS_CSR_73 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_74) == 32'h00000004);
    assign _zz__zz_decode_IS_CSR_75 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_76) == 32'h0);
    assign _zz__zz_decode_IS_CSR_80 = 32'h00000070;
    assign _zz__zz_decode_IS_CSR_84 = (decode_INSTRUCTION & 32'h00000020);
    assign _zz__zz_decode_IS_CSR_85 = 32'h0;
    assign _zz__zz_decode_IS_CSR_88 = (decode_INSTRUCTION & 32'h00004014);
    assign _zz__zz_decode_IS_CSR_89 = 32'h00004010;
    assign _zz__zz_decode_IS_CSR_92 = ((decode_INSTRUCTION & 32'h00006014) == 32'h00002010);
    assign _zz__zz_decode_IS_CSR_94 = {
        (_zz__zz_decode_IS_CSR_95 == _zz__zz_decode_IS_CSR_96),
        {_zz_decode_IS_CSR_2, {_zz__zz_decode_IS_CSR_97, _zz__zz_decode_IS_CSR_99}}
    };
    assign _zz__zz_decode_IS_CSR_105 = (|(_zz__zz_decode_IS_CSR_106 == _zz__zz_decode_IS_CSR_107));
    assign _zz__zz_decode_IS_CSR_108 = (|{_zz__zz_decode_IS_CSR_109, _zz__zz_decode_IS_CSR_111});
    assign _zz__zz_decode_IS_CSR_116 = {
        (|_zz__zz_decode_IS_CSR_117), {_zz__zz_decode_IS_CSR_120, _zz__zz_decode_IS_CSR_122}
    };
    assign _zz__zz_decode_IS_CSR_74 = 32'h0000000c;
    assign _zz__zz_decode_IS_CSR_76 = 32'h00000028;
    assign _zz__zz_decode_IS_CSR_95 = (decode_INSTRUCTION & 32'h00000044);
    assign _zz__zz_decode_IS_CSR_96 = 32'h0;
    assign _zz__zz_decode_IS_CSR_97 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_98) == 32'h00002000);
    assign _zz__zz_decode_IS_CSR_99 = {
        (_zz__zz_decode_IS_CSR_100 == _zz__zz_decode_IS_CSR_101),
        (_zz__zz_decode_IS_CSR_102 == _zz__zz_decode_IS_CSR_103)
    };
    assign _zz__zz_decode_IS_CSR_106 = (decode_INSTRUCTION & 32'h00000058);
    assign _zz__zz_decode_IS_CSR_107 = 32'h0;
    assign _zz__zz_decode_IS_CSR_109 = ((decode_INSTRUCTION & _zz__zz_decode_IS_CSR_110) == 32'h00000040);
    assign _zz__zz_decode_IS_CSR_111 = {
        (_zz__zz_decode_IS_CSR_112 == _zz__zz_decode_IS_CSR_113),
        (_zz__zz_decode_IS_CSR_114 == _zz__zz_decode_IS_CSR_115)
    };
    assign _zz__zz_decode_IS_CSR_117 = {
        (_zz__zz_decode_IS_CSR_118 == _zz__zz_decode_IS_CSR_119), _zz_decode_IS_CSR_1
    };
    assign _zz__zz_decode_IS_CSR_120 = (|{_zz__zz_decode_IS_CSR_121, _zz_decode_IS_CSR_1});
    assign _zz__zz_decode_IS_CSR_122 = (|(_zz__zz_decode_IS_CSR_123 == _zz__zz_decode_IS_CSR_124));
    assign _zz__zz_decode_IS_CSR_98 = 32'h00006004;
    assign _zz__zz_decode_IS_CSR_100 = (decode_INSTRUCTION & 32'h00005004);
    assign _zz__zz_decode_IS_CSR_101 = 32'h00001000;
    assign _zz__zz_decode_IS_CSR_102 = (decode_INSTRUCTION & 32'h00004050);
    assign _zz__zz_decode_IS_CSR_103 = 32'h00004000;
    assign _zz__zz_decode_IS_CSR_110 = 32'h00000044;
    assign _zz__zz_decode_IS_CSR_112 = (decode_INSTRUCTION & 32'h00002014);
    assign _zz__zz_decode_IS_CSR_113 = 32'h00002010;
    assign _zz__zz_decode_IS_CSR_114 = (decode_INSTRUCTION & 32'h40000034);
    assign _zz__zz_decode_IS_CSR_115 = 32'h40000030;
    assign _zz__zz_decode_IS_CSR_118 = (decode_INSTRUCTION & 32'h00000014);
    assign _zz__zz_decode_IS_CSR_119 = 32'h00000004;
    assign _zz__zz_decode_IS_CSR_121 = ((decode_INSTRUCTION & 32'h00000044) == 32'h00000004);
    assign _zz__zz_decode_IS_CSR_123 = (decode_INSTRUCTION & 32'h00005048);
    assign _zz__zz_decode_IS_CSR_124 = 32'h00001008;
    assign _zz_execute_BranchPlugin_branch_src2_6 = execute_INSTRUCTION[31];
    assign _zz_execute_BranchPlugin_branch_src2_7 = execute_INSTRUCTION[19 : 12];
    assign _zz_execute_BranchPlugin_branch_src2_8 = execute_INSTRUCTION[20];
    assign _zz_execute_BranchPlugin_branch_src2_9 = execute_INSTRUCTION[31];
    assign _zz_execute_BranchPlugin_branch_src2_10 = execute_INSTRUCTION[7];
    always @(posedge io_axiClk) begin
        if (_zz_decode_RegFilePlugin_rs1Data) begin
            RegFilePlugin_regFile_spinal_port0 <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress1];
        end
    end

    always @(posedge io_axiClk) begin
        if (_zz_decode_RegFilePlugin_rs2Data) begin
            RegFilePlugin_regFile_spinal_port1 <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress2];
        end
    end

    always @(posedge io_axiClk) begin
        if (_zz_1) begin
            RegFilePlugin_regFile[lastStageRegFileWrite_payload_address] <= lastStageRegFileWrite_payload_data;
        end
    end

    InstructionCache IBusCachedPlugin_cache (
        .io_flush(IBusCachedPlugin_cache_io_flush),  //i
        .io_cpu_prefetch_isValid(IBusCachedPlugin_cache_io_cpu_prefetch_isValid),  //i
        .io_cpu_prefetch_haltIt(IBusCachedPlugin_cache_io_cpu_prefetch_haltIt),  //o
        .io_cpu_prefetch_pc(IBusCachedPlugin_iBusRsp_stages_0_input_payload[31:0]),  //i
        .io_cpu_fetch_isValid(IBusCachedPlugin_cache_io_cpu_fetch_isValid),  //i
        .io_cpu_fetch_isStuck(IBusCachedPlugin_cache_io_cpu_fetch_isStuck),  //i
        .io_cpu_fetch_isRemoved(IBusCachedPlugin_cache_io_cpu_fetch_isRemoved),  //i
        .io_cpu_fetch_pc(IBusCachedPlugin_iBusRsp_stages_1_input_payload[31:0]),  //i
        .io_cpu_fetch_data(IBusCachedPlugin_cache_io_cpu_fetch_data[31:0]),  //o
        .io_cpu_fetch_mmuRsp_physicalAddress   (IBusCachedPlugin_mmuBus_rsp_physicalAddress[31:0]         ), //i
        .io_cpu_fetch_mmuRsp_isIoAccess(IBusCachedPlugin_mmuBus_rsp_isIoAccess),  //i
        .io_cpu_fetch_mmuRsp_isPaging(IBusCachedPlugin_mmuBus_rsp_isPaging),  //i
        .io_cpu_fetch_mmuRsp_allowRead(IBusCachedPlugin_mmuBus_rsp_allowRead),  //i
        .io_cpu_fetch_mmuRsp_allowWrite(IBusCachedPlugin_mmuBus_rsp_allowWrite),  //i
        .io_cpu_fetch_mmuRsp_allowExecute(IBusCachedPlugin_mmuBus_rsp_allowExecute),  //i
        .io_cpu_fetch_mmuRsp_exception(IBusCachedPlugin_mmuBus_rsp_exception),  //i
        .io_cpu_fetch_mmuRsp_refilling(IBusCachedPlugin_mmuBus_rsp_refilling),  //i
        .io_cpu_fetch_mmuRsp_bypassTranslation(IBusCachedPlugin_mmuBus_rsp_bypassTranslation),  //i
        .io_cpu_fetch_physicalAddress          (IBusCachedPlugin_cache_io_cpu_fetch_physicalAddress[31:0] ), //o
        .io_cpu_decode_isValid(IBusCachedPlugin_cache_io_cpu_decode_isValid),  //i
        .io_cpu_decode_isStuck(IBusCachedPlugin_cache_io_cpu_decode_isStuck),  //i
        .io_cpu_decode_pc(IBusCachedPlugin_iBusRsp_stages_2_input_payload[31:0]),  //i
        .io_cpu_decode_physicalAddress         (IBusCachedPlugin_cache_io_cpu_decode_physicalAddress[31:0]), //o
        .io_cpu_decode_data(IBusCachedPlugin_cache_io_cpu_decode_data[31:0]),  //o
        .io_cpu_decode_cacheMiss(IBusCachedPlugin_cache_io_cpu_decode_cacheMiss),  //o
        .io_cpu_decode_error(IBusCachedPlugin_cache_io_cpu_decode_error),  //o
        .io_cpu_decode_mmuRefilling(IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling),  //o
        .io_cpu_decode_mmuException(IBusCachedPlugin_cache_io_cpu_decode_mmuException),  //o
        .io_cpu_decode_isUser(IBusCachedPlugin_cache_io_cpu_decode_isUser),  //i
        .io_cpu_fill_valid(IBusCachedPlugin_cache_io_cpu_fill_valid),  //i
        .io_cpu_fill_payload(IBusCachedPlugin_cache_io_cpu_decode_physicalAddress[31:0]),  //i
        .io_mem_cmd_valid(IBusCachedPlugin_cache_io_mem_cmd_valid),  //o
        .io_mem_cmd_ready(iBus_cmd_ready),  //i
        .io_mem_cmd_payload_address(IBusCachedPlugin_cache_io_mem_cmd_payload_address[31:0]),  //o
        .io_mem_cmd_payload_size(IBusCachedPlugin_cache_io_mem_cmd_payload_size[2:0]),  //o
        .io_mem_rsp_valid(iBus_rsp_valid),  //i
        .io_mem_rsp_payload_data(iBus_rsp_payload_data[31:0]),  //i
        .io_mem_rsp_payload_error(iBus_rsp_payload_error),  //i
        ._zz_when_Fetcher_l411(IBusCachedPlugin_injector_port_state[2:0]),  //i
        ._zz_decodeStage_hit_data_1(DebugPlugin_injectionPort_payload[31:0]),  //i
        .io_axiClk(io_axiClk),  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)  //i
    );
    DataCache dataCache_1 (
        .io_cpu_execute_isValid(dataCache_1_io_cpu_execute_isValid),  //i
        .io_cpu_execute_address(dataCache_1_io_cpu_execute_address[31:0]),  //i
        .io_cpu_execute_haltIt(dataCache_1_io_cpu_execute_haltIt),  //o
        .io_cpu_execute_args_wr(execute_MEMORY_WR),  //i
        .io_cpu_execute_args_size(execute_DBusCachedPlugin_size[1:0]),  //i
        .io_cpu_execute_args_totalyConsistent(execute_MEMORY_FORCE_CONSTISTENCY),  //i
        .io_cpu_execute_refilling(dataCache_1_io_cpu_execute_refilling),  //o
        .io_cpu_memory_isValid(dataCache_1_io_cpu_memory_isValid),  //i
        .io_cpu_memory_isStuck(memory_arbitration_isStuck),  //i
        .io_cpu_memory_isWrite(dataCache_1_io_cpu_memory_isWrite),  //o
        .io_cpu_memory_address(dataCache_1_io_cpu_memory_address[31:0]),  //i
        .io_cpu_memory_mmuRsp_physicalAddress   (DBusCachedPlugin_mmuBus_rsp_physicalAddress[31:0]), //i
        .io_cpu_memory_mmuRsp_isIoAccess(dataCache_1_io_cpu_memory_mmuRsp_isIoAccess),  //i
        .io_cpu_memory_mmuRsp_isPaging(DBusCachedPlugin_mmuBus_rsp_isPaging),  //i
        .io_cpu_memory_mmuRsp_allowRead(DBusCachedPlugin_mmuBus_rsp_allowRead),  //i
        .io_cpu_memory_mmuRsp_allowWrite(DBusCachedPlugin_mmuBus_rsp_allowWrite),  //i
        .io_cpu_memory_mmuRsp_allowExecute(DBusCachedPlugin_mmuBus_rsp_allowExecute),  //i
        .io_cpu_memory_mmuRsp_exception(DBusCachedPlugin_mmuBus_rsp_exception),  //i
        .io_cpu_memory_mmuRsp_refilling(DBusCachedPlugin_mmuBus_rsp_refilling),  //i
        .io_cpu_memory_mmuRsp_bypassTranslation(DBusCachedPlugin_mmuBus_rsp_bypassTranslation),  //i
        .io_cpu_writeBack_isValid(dataCache_1_io_cpu_writeBack_isValid),  //i
        .io_cpu_writeBack_isStuck(writeBack_arbitration_isStuck),  //i
        .io_cpu_writeBack_isFiring(writeBack_arbitration_isFiring),  //i
        .io_cpu_writeBack_isUser(dataCache_1_io_cpu_writeBack_isUser),  //i
        .io_cpu_writeBack_haltIt(dataCache_1_io_cpu_writeBack_haltIt),  //o
        .io_cpu_writeBack_isWrite(dataCache_1_io_cpu_writeBack_isWrite),  //o
        .io_cpu_writeBack_storeData(dataCache_1_io_cpu_writeBack_storeData[31:0]),  //i
        .io_cpu_writeBack_data(dataCache_1_io_cpu_writeBack_data[31:0]),  //o
        .io_cpu_writeBack_address(dataCache_1_io_cpu_writeBack_address[31:0]),  //i
        .io_cpu_writeBack_mmuException(dataCache_1_io_cpu_writeBack_mmuException),  //o
        .io_cpu_writeBack_unalignedAccess(dataCache_1_io_cpu_writeBack_unalignedAccess),  //o
        .io_cpu_writeBack_accessError(dataCache_1_io_cpu_writeBack_accessError),  //o
        .io_cpu_writeBack_keepMemRspData(dataCache_1_io_cpu_writeBack_keepMemRspData),  //o
        .io_cpu_writeBack_fence_SW(dataCache_1_io_cpu_writeBack_fence_SW),  //i
        .io_cpu_writeBack_fence_SR(dataCache_1_io_cpu_writeBack_fence_SR),  //i
        .io_cpu_writeBack_fence_SO(dataCache_1_io_cpu_writeBack_fence_SO),  //i
        .io_cpu_writeBack_fence_SI(dataCache_1_io_cpu_writeBack_fence_SI),  //i
        .io_cpu_writeBack_fence_PW(dataCache_1_io_cpu_writeBack_fence_PW),  //i
        .io_cpu_writeBack_fence_PR(dataCache_1_io_cpu_writeBack_fence_PR),  //i
        .io_cpu_writeBack_fence_PO(dataCache_1_io_cpu_writeBack_fence_PO),  //i
        .io_cpu_writeBack_fence_PI(dataCache_1_io_cpu_writeBack_fence_PI),  //i
        .io_cpu_writeBack_fence_FM(dataCache_1_io_cpu_writeBack_fence_FM[3:0]),  //i
        .io_cpu_writeBack_exclusiveOk(dataCache_1_io_cpu_writeBack_exclusiveOk),  //o
        .io_cpu_redo(dataCache_1_io_cpu_redo),  //o
        .io_cpu_flush_valid(dataCache_1_io_cpu_flush_valid),  //i
        .io_cpu_flush_ready(dataCache_1_io_cpu_flush_ready),  //o
        .io_cpu_flush_payload_singleLine(dataCache_1_io_cpu_flush_payload_singleLine),  //i
        .io_cpu_flush_payload_lineId(dataCache_1_io_cpu_flush_payload_lineId[6:0]),  //i
        .io_cpu_writesPending(dataCache_1_io_cpu_writesPending),  //o
        .io_mem_cmd_valid(dataCache_1_io_mem_cmd_valid),  //o
        .io_mem_cmd_ready(dBus_cmd_ready),  //i
        .io_mem_cmd_payload_wr(dataCache_1_io_mem_cmd_payload_wr),  //o
        .io_mem_cmd_payload_uncached(dataCache_1_io_mem_cmd_payload_uncached),  //o
        .io_mem_cmd_payload_address(dataCache_1_io_mem_cmd_payload_address[31:0]),  //o
        .io_mem_cmd_payload_data(dataCache_1_io_mem_cmd_payload_data[31:0]),  //o
        .io_mem_cmd_payload_mask(dataCache_1_io_mem_cmd_payload_mask[3:0]),  //o
        .io_mem_cmd_payload_size(dataCache_1_io_mem_cmd_payload_size[2:0]),  //o
        .io_mem_cmd_payload_last(dataCache_1_io_mem_cmd_payload_last),  //o
        .io_mem_rsp_valid(dBus_rsp_valid),  //i
        .io_mem_rsp_payload_last(dBus_rsp_payload_last),  //i
        .io_mem_rsp_payload_data(dBus_rsp_payload_data[31:0]),  //i
        .io_mem_rsp_payload_error(dBus_rsp_payload_error),  //i
        .io_axiClk(io_axiClk),  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)  //i
    );
    always @(*) begin
        case (_zz_IBusCachedPlugin_jump_pcLoad_payload_6)
            2'b00: _zz_IBusCachedPlugin_jump_pcLoad_payload_5 = DBusCachedPlugin_redoBranch_payload;
            2'b01: _zz_IBusCachedPlugin_jump_pcLoad_payload_5 = CsrPlugin_jumpInterface_payload;
            2'b10: _zz_IBusCachedPlugin_jump_pcLoad_payload_5 = BranchPlugin_jumpInterface_payload;
            default:
            _zz_IBusCachedPlugin_jump_pcLoad_payload_5 = IBusCachedPlugin_predictionJumpInterface_payload;
        endcase
    end

    always @(*) begin
        case (_zz_writeBack_DBusCachedPlugin_rspShifted_1)
            2'b00:
            _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_0;
            2'b01:
            _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_1;
            2'b10:
            _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_2;
            default:
            _zz_writeBack_DBusCachedPlugin_rspShifted = writeBack_DBusCachedPlugin_rspSplits_3;
        endcase
    end

    always @(*) begin
        case (_zz_writeBack_DBusCachedPlugin_rspShifted_3)
            1'b0:
            _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_1;
            default:
            _zz_writeBack_DBusCachedPlugin_rspShifted_2 = writeBack_DBusCachedPlugin_rspSplits_3;
        endcase
    end

`ifndef SYNTHESIS
    always @(*) begin
        case (_zz_memory_to_writeBack_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_memory_to_writeBack_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: _zz_memory_to_writeBack_ENV_CTRL_string = "XRET";
            default: _zz_memory_to_writeBack_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_memory_to_writeBack_ENV_CTRL_1)
            EnvCtrlEnum_NONE: _zz_memory_to_writeBack_ENV_CTRL_1_string = "NONE";
            EnvCtrlEnum_XRET: _zz_memory_to_writeBack_ENV_CTRL_1_string = "XRET";
            default: _zz_memory_to_writeBack_ENV_CTRL_1_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_to_memory_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_execute_to_memory_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: _zz_execute_to_memory_ENV_CTRL_string = "XRET";
            default: _zz_execute_to_memory_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_to_memory_ENV_CTRL_1)
            EnvCtrlEnum_NONE: _zz_execute_to_memory_ENV_CTRL_1_string = "NONE";
            EnvCtrlEnum_XRET: _zz_execute_to_memory_ENV_CTRL_1_string = "XRET";
            default: _zz_execute_to_memory_ENV_CTRL_1_string = "????";
        endcase
    end
    always @(*) begin
        case (decode_ENV_CTRL)
            EnvCtrlEnum_NONE: decode_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: decode_ENV_CTRL_string = "XRET";
            default: decode_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_decode_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: _zz_decode_ENV_CTRL_string = "XRET";
            default: _zz_decode_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_decode_to_execute_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: _zz_decode_to_execute_ENV_CTRL_string = "XRET";
            default: _zz_decode_to_execute_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ENV_CTRL_1)
            EnvCtrlEnum_NONE: _zz_decode_to_execute_ENV_CTRL_1_string = "NONE";
            EnvCtrlEnum_XRET: _zz_decode_to_execute_ENV_CTRL_1_string = "XRET";
            default: _zz_decode_to_execute_ENV_CTRL_1_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: _zz_decode_to_execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_to_execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_to_execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_to_execute_BRANCH_CTRL_string = "JALR";
            default: _zz_decode_to_execute_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_BRANCH_CTRL_1)
            BranchCtrlEnum_INC: _zz_decode_to_execute_BRANCH_CTRL_1_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_to_execute_BRANCH_CTRL_1_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_to_execute_BRANCH_CTRL_1_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_to_execute_BRANCH_CTRL_1_string = "JALR";
            default: _zz_decode_to_execute_BRANCH_CTRL_1_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_to_memory_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_execute_to_memory_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_execute_to_memory_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_execute_to_memory_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_execute_to_memory_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_execute_to_memory_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_to_memory_SHIFT_CTRL_1)
            ShiftCtrlEnum_DISABLE_1: _zz_execute_to_memory_SHIFT_CTRL_1_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_execute_to_memory_SHIFT_CTRL_1_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_execute_to_memory_SHIFT_CTRL_1_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_execute_to_memory_SHIFT_CTRL_1_string = "SRA_1    ";
            default: _zz_execute_to_memory_SHIFT_CTRL_1_string = "?????????";
        endcase
    end
    always @(*) begin
        case (decode_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: decode_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: decode_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: decode_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: decode_SHIFT_CTRL_string = "SRA_1    ";
            default: decode_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_decode_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_decode_to_execute_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_SHIFT_CTRL_1)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_to_execute_SHIFT_CTRL_1_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_to_execute_SHIFT_CTRL_1_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_to_execute_SHIFT_CTRL_1_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_to_execute_SHIFT_CTRL_1_string = "SRA_1    ";
            default: _zz_decode_to_execute_SHIFT_CTRL_1_string = "?????????";
        endcase
    end
    always @(*) begin
        case (decode_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: decode_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: decode_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: decode_ALU_BITWISE_CTRL_string = "AND_1";
            default: decode_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_ALU_BITWISE_CTRL_string = "AND_1";
            default: _zz_decode_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
            default: _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ALU_BITWISE_CTRL_1)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "AND_1";
            default: _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "?????";
        endcase
    end
    always @(*) begin
        case (decode_SRC2_CTRL)
            Src2CtrlEnum_RS: decode_SRC2_CTRL_string = "RS ";
            Src2CtrlEnum_IMI: decode_SRC2_CTRL_string = "IMI";
            Src2CtrlEnum_IMS: decode_SRC2_CTRL_string = "IMS";
            Src2CtrlEnum_PC: decode_SRC2_CTRL_string = "PC ";
            default: decode_SRC2_CTRL_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC2_CTRL)
            Src2CtrlEnum_RS: _zz_decode_SRC2_CTRL_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_SRC2_CTRL_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_SRC2_CTRL_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_SRC2_CTRL_string = "PC ";
            default: _zz_decode_SRC2_CTRL_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_SRC2_CTRL)
            Src2CtrlEnum_RS: _zz_decode_to_execute_SRC2_CTRL_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_to_execute_SRC2_CTRL_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_to_execute_SRC2_CTRL_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_to_execute_SRC2_CTRL_string = "PC ";
            default: _zz_decode_to_execute_SRC2_CTRL_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_SRC2_CTRL_1)
            Src2CtrlEnum_RS: _zz_decode_to_execute_SRC2_CTRL_1_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_to_execute_SRC2_CTRL_1_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_to_execute_SRC2_CTRL_1_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_to_execute_SRC2_CTRL_1_string = "PC ";
            default: _zz_decode_to_execute_SRC2_CTRL_1_string = "???";
        endcase
    end
    always @(*) begin
        case (decode_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: decode_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: decode_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: decode_ALU_CTRL_string = "BITWISE ";
            default: decode_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: _zz_decode_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_ALU_CTRL_string = "BITWISE ";
            default: _zz_decode_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: _zz_decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_to_execute_ALU_CTRL_string = "BITWISE ";
            default: _zz_decode_to_execute_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ALU_CTRL_1)
            AluCtrlEnum_ADD_SUB: _zz_decode_to_execute_ALU_CTRL_1_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_to_execute_ALU_CTRL_1_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_to_execute_ALU_CTRL_1_string = "BITWISE ";
            default: _zz_decode_to_execute_ALU_CTRL_1_string = "????????";
        endcase
    end
    always @(*) begin
        case (decode_SRC1_CTRL)
            Src1CtrlEnum_RS: decode_SRC1_CTRL_string = "RS          ";
            Src1CtrlEnum_IMU: decode_SRC1_CTRL_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: decode_SRC1_CTRL_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: decode_SRC1_CTRL_string = "URS1        ";
            default: decode_SRC1_CTRL_string = "????????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC1_CTRL)
            Src1CtrlEnum_RS: _zz_decode_SRC1_CTRL_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_SRC1_CTRL_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_SRC1_CTRL_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_SRC1_CTRL_string = "URS1        ";
            default: _zz_decode_SRC1_CTRL_string = "????????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_SRC1_CTRL)
            Src1CtrlEnum_RS: _zz_decode_to_execute_SRC1_CTRL_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_to_execute_SRC1_CTRL_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_to_execute_SRC1_CTRL_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_to_execute_SRC1_CTRL_string = "URS1        ";
            default: _zz_decode_to_execute_SRC1_CTRL_string = "????????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_SRC1_CTRL_1)
            Src1CtrlEnum_RS: _zz_decode_to_execute_SRC1_CTRL_1_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_to_execute_SRC1_CTRL_1_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_to_execute_SRC1_CTRL_1_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_to_execute_SRC1_CTRL_1_string = "URS1        ";
            default: _zz_decode_to_execute_SRC1_CTRL_1_string = "????????????";
        endcase
    end
    always @(*) begin
        case (memory_ENV_CTRL)
            EnvCtrlEnum_NONE: memory_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: memory_ENV_CTRL_string = "XRET";
            default: memory_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_memory_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_memory_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: _zz_memory_ENV_CTRL_string = "XRET";
            default: _zz_memory_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (execute_ENV_CTRL)
            EnvCtrlEnum_NONE: execute_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: execute_ENV_CTRL_string = "XRET";
            default: execute_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_execute_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: _zz_execute_ENV_CTRL_string = "XRET";
            default: _zz_execute_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (writeBack_ENV_CTRL)
            EnvCtrlEnum_NONE: writeBack_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: writeBack_ENV_CTRL_string = "XRET";
            default: writeBack_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_writeBack_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_writeBack_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: _zz_writeBack_ENV_CTRL_string = "XRET";
            default: _zz_writeBack_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: execute_BRANCH_CTRL_string = "JALR";
            default: execute_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: _zz_execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: _zz_execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: _zz_execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_execute_BRANCH_CTRL_string = "JALR";
            default: _zz_execute_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (memory_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: memory_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: memory_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: memory_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: memory_SHIFT_CTRL_string = "SRA_1    ";
            default: memory_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_memory_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_memory_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_memory_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_memory_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_memory_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_memory_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (execute_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: execute_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: execute_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: execute_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: execute_SHIFT_CTRL_string = "SRA_1    ";
            default: execute_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_execute_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_execute_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_execute_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_execute_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_execute_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (execute_SRC2_CTRL)
            Src2CtrlEnum_RS: execute_SRC2_CTRL_string = "RS ";
            Src2CtrlEnum_IMI: execute_SRC2_CTRL_string = "IMI";
            Src2CtrlEnum_IMS: execute_SRC2_CTRL_string = "IMS";
            Src2CtrlEnum_PC: execute_SRC2_CTRL_string = "PC ";
            default: execute_SRC2_CTRL_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_execute_SRC2_CTRL)
            Src2CtrlEnum_RS: _zz_execute_SRC2_CTRL_string = "RS ";
            Src2CtrlEnum_IMI: _zz_execute_SRC2_CTRL_string = "IMI";
            Src2CtrlEnum_IMS: _zz_execute_SRC2_CTRL_string = "IMS";
            Src2CtrlEnum_PC: _zz_execute_SRC2_CTRL_string = "PC ";
            default: _zz_execute_SRC2_CTRL_string = "???";
        endcase
    end
    always @(*) begin
        case (execute_SRC1_CTRL)
            Src1CtrlEnum_RS: execute_SRC1_CTRL_string = "RS          ";
            Src1CtrlEnum_IMU: execute_SRC1_CTRL_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: execute_SRC1_CTRL_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: execute_SRC1_CTRL_string = "URS1        ";
            default: execute_SRC1_CTRL_string = "????????????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_SRC1_CTRL)
            Src1CtrlEnum_RS: _zz_execute_SRC1_CTRL_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_execute_SRC1_CTRL_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_execute_SRC1_CTRL_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_execute_SRC1_CTRL_string = "URS1        ";
            default: _zz_execute_SRC1_CTRL_string = "????????????";
        endcase
    end
    always @(*) begin
        case (execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: execute_ALU_CTRL_string = "BITWISE ";
            default: execute_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: _zz_execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_execute_ALU_CTRL_string = "BITWISE ";
            default: _zz_execute_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: execute_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: execute_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: execute_ALU_BITWISE_CTRL_string = "AND_1";
            default: execute_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: _zz_execute_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_execute_ALU_BITWISE_CTRL_string = "AND_1";
            default: _zz_execute_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ENV_CTRL_1)
            EnvCtrlEnum_NONE: _zz_decode_ENV_CTRL_1_string = "NONE";
            EnvCtrlEnum_XRET: _zz_decode_ENV_CTRL_1_string = "XRET";
            default: _zz_decode_ENV_CTRL_1_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_BRANCH_CTRL)
            BranchCtrlEnum_INC: _zz_decode_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_BRANCH_CTRL_string = "JALR";
            default: _zz_decode_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SHIFT_CTRL_1)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_SHIFT_CTRL_1_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_SHIFT_CTRL_1_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_SHIFT_CTRL_1_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_SHIFT_CTRL_1_string = "SRA_1    ";
            default: _zz_decode_SHIFT_CTRL_1_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_BITWISE_CTRL_1)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_ALU_BITWISE_CTRL_1_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_ALU_BITWISE_CTRL_1_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_ALU_BITWISE_CTRL_1_string = "AND_1";
            default: _zz_decode_ALU_BITWISE_CTRL_1_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC2_CTRL_1)
            Src2CtrlEnum_RS: _zz_decode_SRC2_CTRL_1_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_SRC2_CTRL_1_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_SRC2_CTRL_1_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_SRC2_CTRL_1_string = "PC ";
            default: _zz_decode_SRC2_CTRL_1_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_CTRL_1)
            AluCtrlEnum_ADD_SUB: _zz_decode_ALU_CTRL_1_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_ALU_CTRL_1_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_ALU_CTRL_1_string = "BITWISE ";
            default: _zz_decode_ALU_CTRL_1_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC1_CTRL_1)
            Src1CtrlEnum_RS: _zz_decode_SRC1_CTRL_1_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_SRC1_CTRL_1_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_SRC1_CTRL_1_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_SRC1_CTRL_1_string = "URS1        ";
            default: _zz_decode_SRC1_CTRL_1_string = "????????????";
        endcase
    end
    always @(*) begin
        case (decode_BRANCH_CTRL)
            BranchCtrlEnum_INC: decode_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: decode_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: decode_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: decode_BRANCH_CTRL_string = "JALR";
            default: decode_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_BRANCH_CTRL_1)
            BranchCtrlEnum_INC: _zz_decode_BRANCH_CTRL_1_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_BRANCH_CTRL_1_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_BRANCH_CTRL_1_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_BRANCH_CTRL_1_string = "JALR";
            default: _zz_decode_BRANCH_CTRL_1_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC1_CTRL_2)
            Src1CtrlEnum_RS: _zz_decode_SRC1_CTRL_2_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_SRC1_CTRL_2_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_SRC1_CTRL_2_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_SRC1_CTRL_2_string = "URS1        ";
            default: _zz_decode_SRC1_CTRL_2_string = "????????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_CTRL_2)
            AluCtrlEnum_ADD_SUB: _zz_decode_ALU_CTRL_2_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_ALU_CTRL_2_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_ALU_CTRL_2_string = "BITWISE ";
            default: _zz_decode_ALU_CTRL_2_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC2_CTRL_2)
            Src2CtrlEnum_RS: _zz_decode_SRC2_CTRL_2_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_SRC2_CTRL_2_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_SRC2_CTRL_2_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_SRC2_CTRL_2_string = "PC ";
            default: _zz_decode_SRC2_CTRL_2_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_BITWISE_CTRL_2)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_ALU_BITWISE_CTRL_2_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_ALU_BITWISE_CTRL_2_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_ALU_BITWISE_CTRL_2_string = "AND_1";
            default: _zz_decode_ALU_BITWISE_CTRL_2_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SHIFT_CTRL_2)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_SHIFT_CTRL_2_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_SHIFT_CTRL_2_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_SHIFT_CTRL_2_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_SHIFT_CTRL_2_string = "SRA_1    ";
            default: _zz_decode_SHIFT_CTRL_2_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_BRANCH_CTRL_2)
            BranchCtrlEnum_INC: _zz_decode_BRANCH_CTRL_2_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_BRANCH_CTRL_2_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_BRANCH_CTRL_2_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_BRANCH_CTRL_2_string = "JALR";
            default: _zz_decode_BRANCH_CTRL_2_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ENV_CTRL_2)
            EnvCtrlEnum_NONE: _zz_decode_ENV_CTRL_2_string = "NONE";
            EnvCtrlEnum_XRET: _zz_decode_ENV_CTRL_2_string = "XRET";
            default: _zz_decode_ENV_CTRL_2_string = "????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_SRC1_CTRL)
            Src1CtrlEnum_RS: decode_to_execute_SRC1_CTRL_string = "RS          ";
            Src1CtrlEnum_IMU: decode_to_execute_SRC1_CTRL_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: decode_to_execute_SRC1_CTRL_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: decode_to_execute_SRC1_CTRL_string = "URS1        ";
            default: decode_to_execute_SRC1_CTRL_string = "????????????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: decode_to_execute_ALU_CTRL_string = "BITWISE ";
            default: decode_to_execute_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_SRC2_CTRL)
            Src2CtrlEnum_RS: decode_to_execute_SRC2_CTRL_string = "RS ";
            Src2CtrlEnum_IMI: decode_to_execute_SRC2_CTRL_string = "IMI";
            Src2CtrlEnum_IMS: decode_to_execute_SRC2_CTRL_string = "IMS";
            Src2CtrlEnum_PC: decode_to_execute_SRC2_CTRL_string = "PC ";
            default: decode_to_execute_SRC2_CTRL_string = "???";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
            default: decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
            default: decode_to_execute_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (execute_to_memory_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: execute_to_memory_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: execute_to_memory_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: execute_to_memory_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: execute_to_memory_SHIFT_CTRL_string = "SRA_1    ";
            default: execute_to_memory_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: decode_to_execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: decode_to_execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: decode_to_execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: decode_to_execute_BRANCH_CTRL_string = "JALR";
            default: decode_to_execute_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_ENV_CTRL)
            EnvCtrlEnum_NONE: decode_to_execute_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: decode_to_execute_ENV_CTRL_string = "XRET";
            default: decode_to_execute_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (execute_to_memory_ENV_CTRL)
            EnvCtrlEnum_NONE: execute_to_memory_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: execute_to_memory_ENV_CTRL_string = "XRET";
            default: execute_to_memory_ENV_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (memory_to_writeBack_ENV_CTRL)
            EnvCtrlEnum_NONE: memory_to_writeBack_ENV_CTRL_string = "NONE";
            EnvCtrlEnum_XRET: memory_to_writeBack_ENV_CTRL_string = "XRET";
            default: memory_to_writeBack_ENV_CTRL_string = "????";
        endcase
    end
`endif

    assign memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW) + $signed(_zz_memory_MUL_LOW_6));
    assign execute_BRANCH_CALC = {execute_BranchPlugin_branchAdder[31 : 1], 1'b0};
    assign execute_BRANCH_DO = ((execute_PREDICTION_HAD_BRANCHED1 != execute_BRANCH_COND_RESULT) || execute_BranchPlugin_missAlignedTarget);
    assign memory_MUL_HH = execute_to_memory_MUL_HH;
    assign execute_MUL_HH = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bHigh));
    assign execute_MUL_HL = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bSLow));
    assign execute_MUL_LH = ($signed(execute_MulPlugin_aSLow) * $signed(execute_MulPlugin_bHigh));
    assign execute_MUL_LL = (execute_MulPlugin_aULow * execute_MulPlugin_bULow);
    assign execute_SHIFT_RIGHT = _zz_execute_SHIFT_RIGHT;
    assign execute_REGFILE_WRITE_DATA = _zz_execute_REGFILE_WRITE_DATA;
    assign memory_MEMORY_STORE_DATA_RF = execute_to_memory_MEMORY_STORE_DATA_RF;
    assign execute_MEMORY_STORE_DATA_RF = _zz_execute_MEMORY_STORE_DATA_RF;
    assign decode_DO_EBREAK = (((! DebugPlugin_haltIt) && (decode_IS_EBREAK || 1'b0)) && DebugPlugin_allowEBreak);
    assign decode_CSR_READ_OPCODE = (decode_INSTRUCTION[13 : 7] != 7'h20);
    assign decode_CSR_WRITE_OPCODE = (! (((decode_INSTRUCTION[14 : 13] == 2'b01) && (decode_INSTRUCTION[19 : 15] == 5'h0)) || ((decode_INSTRUCTION[14 : 13] == 2'b11) && (decode_INSTRUCTION[19 : 15] == 5'h0))));
    assign decode_PREDICTION_HAD_BRANCHED1 = IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    assign decode_SRC2_FORCE_ZERO = (decode_SRC_ADD_ZERO && (!decode_SRC_USE_SUB_LESS));
    assign _zz_memory_to_writeBack_ENV_CTRL = _zz_memory_to_writeBack_ENV_CTRL_1;
    assign _zz_execute_to_memory_ENV_CTRL = _zz_execute_to_memory_ENV_CTRL_1;
    assign decode_ENV_CTRL = _zz_decode_ENV_CTRL;
    assign _zz_decode_to_execute_ENV_CTRL = _zz_decode_to_execute_ENV_CTRL_1;
    assign decode_IS_CSR = _zz_decode_IS_CSR[29];
    assign _zz_decode_to_execute_BRANCH_CTRL = _zz_decode_to_execute_BRANCH_CTRL_1;
    assign decode_IS_RS2_SIGNED = _zz_decode_IS_CSR[26];
    assign decode_IS_RS1_SIGNED = _zz_decode_IS_CSR[25];
    assign decode_IS_DIV = _zz_decode_IS_CSR[24];
    assign memory_IS_MUL = execute_to_memory_IS_MUL;
    assign execute_IS_MUL = decode_to_execute_IS_MUL;
    assign decode_IS_MUL = _zz_decode_IS_CSR[23];
    assign _zz_execute_to_memory_SHIFT_CTRL = _zz_execute_to_memory_SHIFT_CTRL_1;
    assign decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL;
    assign _zz_decode_to_execute_SHIFT_CTRL = _zz_decode_to_execute_SHIFT_CTRL_1;
    assign decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL;
    assign _zz_decode_to_execute_ALU_BITWISE_CTRL = _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
    assign decode_SRC_LESS_UNSIGNED = _zz_decode_IS_CSR[17];
    assign decode_MEMORY_MANAGMENT = _zz_decode_IS_CSR[16];
    assign memory_MEMORY_WR = execute_to_memory_MEMORY_WR;
    assign decode_MEMORY_WR = _zz_decode_IS_CSR[13];
    assign execute_BYPASSABLE_MEMORY_STAGE = decode_to_execute_BYPASSABLE_MEMORY_STAGE;
    assign decode_BYPASSABLE_MEMORY_STAGE = _zz_decode_IS_CSR[12];
    assign decode_BYPASSABLE_EXECUTE_STAGE = _zz_decode_IS_CSR[11];
    assign decode_SRC2_CTRL = _zz_decode_SRC2_CTRL;
    assign _zz_decode_to_execute_SRC2_CTRL = _zz_decode_to_execute_SRC2_CTRL_1;
    assign decode_ALU_CTRL = _zz_decode_ALU_CTRL;
    assign _zz_decode_to_execute_ALU_CTRL = _zz_decode_to_execute_ALU_CTRL_1;
    assign decode_SRC1_CTRL = _zz_decode_SRC1_CTRL;
    assign _zz_decode_to_execute_SRC1_CTRL = _zz_decode_to_execute_SRC1_CTRL_1;
    assign decode_MEMORY_FORCE_CONSTISTENCY = 1'b0;
    assign writeBack_FORMAL_PC_NEXT = memory_to_writeBack_FORMAL_PC_NEXT;
    assign memory_FORMAL_PC_NEXT = execute_to_memory_FORMAL_PC_NEXT;
    assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
    assign decode_FORMAL_PC_NEXT = (decode_PC + 32'h00000004);
    assign memory_PC = execute_to_memory_PC;
    assign execute_DO_EBREAK = decode_to_execute_DO_EBREAK;
    assign decode_IS_EBREAK = _zz_decode_IS_CSR[31];
    assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
    assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
    assign execute_IS_CSR = decode_to_execute_IS_CSR;
    assign memory_ENV_CTRL = _zz_memory_ENV_CTRL;
    assign execute_ENV_CTRL = _zz_execute_ENV_CTRL;
    assign writeBack_ENV_CTRL = _zz_writeBack_ENV_CTRL;
    assign memory_BRANCH_CALC = execute_to_memory_BRANCH_CALC;
    assign memory_BRANCH_DO = execute_to_memory_BRANCH_DO;
    assign execute_PC = decode_to_execute_PC;
    assign execute_PREDICTION_HAD_BRANCHED1 = decode_to_execute_PREDICTION_HAD_BRANCHED1;
    assign execute_BRANCH_COND_RESULT = _zz_execute_BRANCH_COND_RESULT_1;
    assign execute_BRANCH_CTRL = _zz_execute_BRANCH_CTRL;
    assign decode_RS2_USE = _zz_decode_IS_CSR[15];
    assign decode_RS1_USE = _zz_decode_IS_CSR[5];
    always @(*) begin
        _zz_decode_RS2 = execute_REGFILE_WRITE_DATA;
        if (when_CsrPlugin_l1587) begin
            _zz_decode_RS2 = CsrPlugin_csrMapping_readDataSignal;
        end
    end

    assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
    assign execute_BYPASSABLE_EXECUTE_STAGE = decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
    assign memory_REGFILE_WRITE_VALID = execute_to_memory_REGFILE_WRITE_VALID;
    assign memory_BYPASSABLE_MEMORY_STAGE = execute_to_memory_BYPASSABLE_MEMORY_STAGE;
    assign writeBack_REGFILE_WRITE_VALID = memory_to_writeBack_REGFILE_WRITE_VALID;
    always @(*) begin
        decode_RS2 = decode_RegFilePlugin_rs2Data;
        if (HazardSimplePlugin_writeBackBuffer_valid) begin
            if (HazardSimplePlugin_addr1Match) begin
                decode_RS2 = HazardSimplePlugin_writeBackBuffer_payload_data;
            end
        end
        if (when_HazardSimplePlugin_l45) begin
            if (when_HazardSimplePlugin_l47) begin
                if (when_HazardSimplePlugin_l51) begin
                    decode_RS2 = _zz_decode_RS2_2;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_1) begin
            if (memory_BYPASSABLE_MEMORY_STAGE) begin
                if (when_HazardSimplePlugin_l51_1) begin
                    decode_RS2 = _zz_decode_RS2_1;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_2) begin
            if (execute_BYPASSABLE_EXECUTE_STAGE) begin
                if (when_HazardSimplePlugin_l51_2) begin
                    decode_RS2 = _zz_decode_RS2;
                end
            end
        end
    end

    always @(*) begin
        decode_RS1 = decode_RegFilePlugin_rs1Data;
        if (HazardSimplePlugin_writeBackBuffer_valid) begin
            if (HazardSimplePlugin_addr0Match) begin
                decode_RS1 = HazardSimplePlugin_writeBackBuffer_payload_data;
            end
        end
        if (when_HazardSimplePlugin_l45) begin
            if (when_HazardSimplePlugin_l47) begin
                if (when_HazardSimplePlugin_l48) begin
                    decode_RS1 = _zz_decode_RS2_2;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_1) begin
            if (memory_BYPASSABLE_MEMORY_STAGE) begin
                if (when_HazardSimplePlugin_l48_1) begin
                    decode_RS1 = _zz_decode_RS2_1;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_2) begin
            if (execute_BYPASSABLE_EXECUTE_STAGE) begin
                if (when_HazardSimplePlugin_l48_2) begin
                    decode_RS1 = _zz_decode_RS2;
                end
            end
        end
    end

    assign execute_IS_RS1_SIGNED = decode_to_execute_IS_RS1_SIGNED;
    assign execute_IS_DIV = decode_to_execute_IS_DIV;
    assign execute_IS_RS2_SIGNED = decode_to_execute_IS_RS2_SIGNED;
    assign memory_INSTRUCTION = execute_to_memory_INSTRUCTION;
    assign memory_IS_DIV = execute_to_memory_IS_DIV;
    assign writeBack_IS_MUL = memory_to_writeBack_IS_MUL;
    assign writeBack_MUL_HH = memory_to_writeBack_MUL_HH;
    assign writeBack_MUL_LOW = memory_to_writeBack_MUL_LOW;
    assign memory_MUL_HL = execute_to_memory_MUL_HL;
    assign memory_MUL_LH = execute_to_memory_MUL_LH;
    assign memory_MUL_LL = execute_to_memory_MUL_LL;
    assign memory_SHIFT_RIGHT = execute_to_memory_SHIFT_RIGHT;
    always @(*) begin
        _zz_decode_RS2_1 = memory_REGFILE_WRITE_DATA;
        if (memory_arbitration_isValid) begin
            case (memory_SHIFT_CTRL)
                ShiftCtrlEnum_SLL_1: begin
                    _zz_decode_RS2_1 = _zz_decode_RS2_3;
                end
                ShiftCtrlEnum_SRL_1, ShiftCtrlEnum_SRA_1: begin
                    _zz_decode_RS2_1 = memory_SHIFT_RIGHT;
                end
                default: begin
                end
            endcase
        end
        if (when_MulDivIterativePlugin_l128) begin
            _zz_decode_RS2_1 = memory_DivPlugin_div_result;
        end
    end

    assign memory_SHIFT_CTRL = _zz_memory_SHIFT_CTRL;
    assign execute_SHIFT_CTRL = _zz_execute_SHIFT_CTRL;
    assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
    assign execute_SRC2_FORCE_ZERO = decode_to_execute_SRC2_FORCE_ZERO;
    assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
    assign _zz_execute_to_memory_PC = execute_PC;
    assign execute_SRC2_CTRL = _zz_execute_SRC2_CTRL;
    assign execute_SRC1_CTRL = _zz_execute_SRC1_CTRL;
    assign decode_SRC_USE_SUB_LESS = _zz_decode_IS_CSR[3];
    assign decode_SRC_ADD_ZERO = _zz_decode_IS_CSR[20];
    assign execute_SRC_ADD_SUB = execute_SrcPlugin_addSub;
    assign execute_SRC_LESS = execute_SrcPlugin_less;
    assign execute_ALU_CTRL = _zz_execute_ALU_CTRL;
    assign execute_SRC2 = _zz_execute_SRC2_4;
    assign execute_SRC1 = _zz_execute_SRC1;
    assign execute_ALU_BITWISE_CTRL = _zz_execute_ALU_BITWISE_CTRL;
    assign _zz_lastStageRegFileWrite_payload_address = writeBack_INSTRUCTION;
    assign _zz_lastStageRegFileWrite_valid = writeBack_REGFILE_WRITE_VALID;
    always @(*) begin
        _zz_1 = 1'b0;
        if (lastStageRegFileWrite_valid) begin
            _zz_1 = 1'b1;
        end
    end

    assign decode_INSTRUCTION_ANTICIPATED = (decode_arbitration_isStuck ? decode_INSTRUCTION : IBusCachedPlugin_cache_io_cpu_fetch_data);
    always @(*) begin
        decode_REGFILE_WRITE_VALID = _zz_decode_IS_CSR[10];
        if (when_RegFilePlugin_l63) begin
            decode_REGFILE_WRITE_VALID = 1'b0;
        end
    end

    assign decode_LEGAL_INSTRUCTION = (|{((decode_INSTRUCTION & 32'h0000005f) == 32'h00000017), {
        ((decode_INSTRUCTION & 32'h0000007f) == 32'h0000006f),
        {
            ((decode_INSTRUCTION & _zz_decode_LEGAL_INSTRUCTION) == 32'h00001073),
            {
                (_zz_decode_LEGAL_INSTRUCTION_1 == _zz_decode_LEGAL_INSTRUCTION_2),
                {
                    _zz_decode_LEGAL_INSTRUCTION_3,
                    {_zz_decode_LEGAL_INSTRUCTION_4, _zz_decode_LEGAL_INSTRUCTION_5}
                }
            }
        }
    }});
    always @(*) begin
        _zz_decode_RS2_2 = writeBack_REGFILE_WRITE_DATA;
        if (when_DBusCachedPlugin_l581) begin
            _zz_decode_RS2_2 = writeBack_DBusCachedPlugin_rspFormated;
        end
        if (when_MulPlugin_l147) begin
            case (switch_MulPlugin_l148)
                2'b00: begin
                    _zz_decode_RS2_2 = _zz__zz_decode_RS2_2;
                end
                default: begin
                    _zz_decode_RS2_2 = _zz__zz_decode_RS2_2_1;
                end
            endcase
        end
    end

    assign writeBack_MEMORY_WR = memory_to_writeBack_MEMORY_WR;
    assign writeBack_MEMORY_STORE_DATA_RF = memory_to_writeBack_MEMORY_STORE_DATA_RF;
    assign writeBack_REGFILE_WRITE_DATA = memory_to_writeBack_REGFILE_WRITE_DATA;
    assign writeBack_MEMORY_ENABLE = memory_to_writeBack_MEMORY_ENABLE;
    assign memory_REGFILE_WRITE_DATA = execute_to_memory_REGFILE_WRITE_DATA;
    assign memory_MEMORY_ENABLE = execute_to_memory_MEMORY_ENABLE;
    assign execute_MEMORY_FORCE_CONSTISTENCY = decode_to_execute_MEMORY_FORCE_CONSTISTENCY;
    assign execute_RS1 = decode_to_execute_RS1;
    assign execute_MEMORY_MANAGMENT = decode_to_execute_MEMORY_MANAGMENT;
    assign execute_RS2 = decode_to_execute_RS2;
    assign execute_MEMORY_WR = decode_to_execute_MEMORY_WR;
    assign execute_SRC_ADD = execute_SrcPlugin_addSub;
    assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
    assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
    assign decode_MEMORY_ENABLE = _zz_decode_IS_CSR[4];
    assign decode_FLUSH_ALL = _zz_decode_IS_CSR[0];
    always @(*) begin
        IBusCachedPlugin_rsp_issueDetected_4 = IBusCachedPlugin_rsp_issueDetected_3;
        if (when_IBusCachedPlugin_l262) begin
            IBusCachedPlugin_rsp_issueDetected_4 = 1'b1;
        end
    end

    always @(*) begin
        IBusCachedPlugin_rsp_issueDetected_3 = IBusCachedPlugin_rsp_issueDetected_2;
        if (when_IBusCachedPlugin_l256) begin
            IBusCachedPlugin_rsp_issueDetected_3 = 1'b1;
        end
    end

    always @(*) begin
        IBusCachedPlugin_rsp_issueDetected_2 = IBusCachedPlugin_rsp_issueDetected_1;
        if (when_IBusCachedPlugin_l250) begin
            IBusCachedPlugin_rsp_issueDetected_2 = 1'b1;
        end
    end

    always @(*) begin
        IBusCachedPlugin_rsp_issueDetected_1 = IBusCachedPlugin_rsp_issueDetected;
        if (when_IBusCachedPlugin_l245) begin
            IBusCachedPlugin_rsp_issueDetected_1 = 1'b1;
        end
    end

    assign decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL_1;
    assign decode_INSTRUCTION = IBusCachedPlugin_iBusRsp_output_payload_rsp_inst;
    always @(*) begin
        _zz_memory_to_writeBack_FORMAL_PC_NEXT = memory_FORMAL_PC_NEXT;
        if (BranchPlugin_jumpInterface_valid) begin
            _zz_memory_to_writeBack_FORMAL_PC_NEXT = BranchPlugin_jumpInterface_payload;
        end
    end

    always @(*) begin
        _zz_decode_to_execute_FORMAL_PC_NEXT = decode_FORMAL_PC_NEXT;
        if (IBusCachedPlugin_predictionJumpInterface_valid) begin
            _zz_decode_to_execute_FORMAL_PC_NEXT = IBusCachedPlugin_predictionJumpInterface_payload;
        end
    end

    assign decode_PC = IBusCachedPlugin_iBusRsp_output_payload_pc;
    assign writeBack_PC = memory_to_writeBack_PC;
    assign writeBack_INSTRUCTION = memory_to_writeBack_INSTRUCTION;
    always @(*) begin
        decode_arbitration_haltItself = 1'b0;
        if (when_DBusCachedPlugin_l353) begin
            decode_arbitration_haltItself = 1'b1;
        end
        case (IBusCachedPlugin_injector_port_state)
            3'b010: begin
                decode_arbitration_haltItself = 1'b1;
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        decode_arbitration_haltByOther = 1'b0;
        if (when_HazardSimplePlugin_l113) begin
            decode_arbitration_haltByOther = 1'b1;
        end
        if (CsrPlugin_pipelineLiberator_active) begin
            decode_arbitration_haltByOther = 1'b1;
        end
        if (when_CsrPlugin_l1527) begin
            decode_arbitration_haltByOther = 1'b1;
        end
    end

    always @(*) begin
        decode_arbitration_removeIt = 1'b0;
        if (_zz_when) begin
            decode_arbitration_removeIt = 1'b1;
        end
        if (decode_arbitration_isFlushed) begin
            decode_arbitration_removeIt = 1'b1;
        end
    end

    assign decode_arbitration_flushIt = 1'b0;
    always @(*) begin
        decode_arbitration_flushNext = 1'b0;
        if (IBusCachedPlugin_predictionJumpInterface_valid) begin
            decode_arbitration_flushNext = 1'b1;
        end
        if (_zz_when) begin
            decode_arbitration_flushNext = 1'b1;
        end
    end

    always @(*) begin
        execute_arbitration_haltItself = 1'b0;
        if (when_DBusCachedPlugin_l395) begin
            execute_arbitration_haltItself = 1'b1;
        end
        if (when_CsrPlugin_l1591) begin
            if (execute_CsrPlugin_blockedBySideEffects) begin
                execute_arbitration_haltItself = 1'b1;
            end
        end
    end

    always @(*) begin
        execute_arbitration_haltByOther = 1'b0;
        if (when_DBusCachedPlugin_l411) begin
            execute_arbitration_haltByOther = 1'b1;
        end
        if (when_DebugPlugin_l308) begin
            execute_arbitration_haltByOther = 1'b1;
        end
    end

    always @(*) begin
        execute_arbitration_removeIt = 1'b0;
        if (execute_arbitration_isFlushed) begin
            execute_arbitration_removeIt = 1'b1;
        end
    end

    always @(*) begin
        execute_arbitration_flushIt = 1'b0;
        if (when_DebugPlugin_l308) begin
            if (when_DebugPlugin_l311) begin
                execute_arbitration_flushIt = 1'b1;
            end
        end
    end

    always @(*) begin
        execute_arbitration_flushNext = 1'b0;
        if (when_DebugPlugin_l308) begin
            if (when_DebugPlugin_l311) begin
                execute_arbitration_flushNext = 1'b1;
            end
        end
    end

    always @(*) begin
        memory_arbitration_haltItself = 1'b0;
        if (when_MulDivIterativePlugin_l128) begin
            if (when_MulDivIterativePlugin_l129) begin
                memory_arbitration_haltItself = 1'b1;
            end
        end
    end

    assign memory_arbitration_haltByOther = 1'b0;
    always @(*) begin
        memory_arbitration_removeIt = 1'b0;
        if (BranchPlugin_branchExceptionPort_valid) begin
            memory_arbitration_removeIt = 1'b1;
        end
        if (memory_arbitration_isFlushed) begin
            memory_arbitration_removeIt = 1'b1;
        end
    end

    assign memory_arbitration_flushIt = 1'b0;
    always @(*) begin
        memory_arbitration_flushNext = 1'b0;
        if (BranchPlugin_jumpInterface_valid) begin
            memory_arbitration_flushNext = 1'b1;
        end
        if (BranchPlugin_branchExceptionPort_valid) begin
            memory_arbitration_flushNext = 1'b1;
        end
    end

    always @(*) begin
        writeBack_arbitration_haltItself = 1'b0;
        if (when_DBusCachedPlugin_l554) begin
            writeBack_arbitration_haltItself = 1'b1;
        end
    end

    assign writeBack_arbitration_haltByOther = 1'b0;
    always @(*) begin
        writeBack_arbitration_removeIt = 1'b0;
        if (DBusCachedPlugin_exceptionBus_valid) begin
            writeBack_arbitration_removeIt = 1'b1;
        end
        if (writeBack_arbitration_isFlushed) begin
            writeBack_arbitration_removeIt = 1'b1;
        end
    end

    always @(*) begin
        writeBack_arbitration_flushIt = 1'b0;
        if (DBusCachedPlugin_redoBranch_valid) begin
            writeBack_arbitration_flushIt = 1'b1;
        end
    end

    always @(*) begin
        writeBack_arbitration_flushNext = 1'b0;
        if (DBusCachedPlugin_redoBranch_valid) begin
            writeBack_arbitration_flushNext = 1'b1;
        end
        if (DBusCachedPlugin_exceptionBus_valid) begin
            writeBack_arbitration_flushNext = 1'b1;
        end
        if (when_CsrPlugin_l1390) begin
            writeBack_arbitration_flushNext = 1'b1;
        end
        if (when_CsrPlugin_l1456) begin
            writeBack_arbitration_flushNext = 1'b1;
        end
    end

    assign lastStageInstruction = writeBack_INSTRUCTION;
    assign lastStagePc = writeBack_PC;
    assign lastStageIsValid = writeBack_arbitration_isValid;
    assign lastStageIsFiring = writeBack_arbitration_isFiring;
    always @(*) begin
        IBusCachedPlugin_fetcherHalt = 1'b0;
        if (when_CsrPlugin_l1272) begin
            IBusCachedPlugin_fetcherHalt = 1'b1;
        end
        if (when_CsrPlugin_l1390) begin
            IBusCachedPlugin_fetcherHalt = 1'b1;
        end
        if (when_CsrPlugin_l1456) begin
            IBusCachedPlugin_fetcherHalt = 1'b1;
        end
        if (when_DebugPlugin_l308) begin
            if (when_DebugPlugin_l311) begin
                IBusCachedPlugin_fetcherHalt = 1'b1;
            end
        end
        if (DebugPlugin_haltIt) begin
            IBusCachedPlugin_fetcherHalt = 1'b1;
        end
        if (when_DebugPlugin_l324) begin
            IBusCachedPlugin_fetcherHalt = 1'b1;
        end
    end

    assign IBusCachedPlugin_forceNoDecodeCond = 1'b0;
    always @(*) begin
        IBusCachedPlugin_incomingInstruction = 1'b0;
        if (when_Fetcher_l242) begin
            IBusCachedPlugin_incomingInstruction = 1'b1;
        end
    end

    always @(*) begin
        _zz_when_DBusCachedPlugin_l473 = 1'b0;
        if (DebugPlugin_godmode) begin
            _zz_when_DBusCachedPlugin_l473 = 1'b1;
        end
    end

    always @(*) begin
        BranchPlugin_inDebugNoFetchFlag = 1'b0;
        if (DebugPlugin_godmode) begin
            BranchPlugin_inDebugNoFetchFlag = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_csrMapping_allowCsrSignal = 1'b0;
        if (when_CsrPlugin_l1702) begin
            CsrPlugin_csrMapping_allowCsrSignal = 1'b1;
        end
        if (when_CsrPlugin_l1709) begin
            CsrPlugin_csrMapping_allowCsrSignal = 1'b1;
        end
    end

    assign CsrPlugin_csrMapping_doForceFailCsr = 1'b0;
    assign CsrPlugin_csrMapping_readDataSignal = CsrPlugin_csrMapping_readDataInit;
    assign CsrPlugin_inWfi = 1'b0;
    always @(*) begin
        CsrPlugin_thirdPartyWake = 1'b0;
        if (DebugPlugin_haltIt) begin
            CsrPlugin_thirdPartyWake = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_jumpInterface_valid = 1'b0;
        if (when_CsrPlugin_l1390) begin
            CsrPlugin_jumpInterface_valid = 1'b1;
        end
        if (when_CsrPlugin_l1456) begin
            CsrPlugin_jumpInterface_valid = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_jumpInterface_payload = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        if (when_CsrPlugin_l1390) begin
            CsrPlugin_jumpInterface_payload = {CsrPlugin_xtvec_base, 2'b00};
        end
        if (when_CsrPlugin_l1456) begin
            case (switch_CsrPlugin_l1460)
                2'b11: begin
                    CsrPlugin_jumpInterface_payload = CsrPlugin_mepc;
                end
                default: begin
                end
            endcase
        end
    end

    always @(*) begin
        CsrPlugin_forceMachineWire = 1'b0;
        if (DebugPlugin_godmode) begin
            CsrPlugin_forceMachineWire = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_allowInterrupts = 1'b1;
        if (when_DebugPlugin_l344) begin
            CsrPlugin_allowInterrupts = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_allowException = 1'b1;
        if (DebugPlugin_godmode) begin
            CsrPlugin_allowException = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_allowEbreakException = 1'b1;
        if (DebugPlugin_allowEBreak) begin
            CsrPlugin_allowEbreakException = 1'b0;
        end
    end

    assign CsrPlugin_xretAwayFromMachine = 1'b0;
    assign IBusCachedPlugin_externalFlush = (|{writeBack_arbitration_flushNext, {
        memory_arbitration_flushNext, {execute_arbitration_flushNext, decode_arbitration_flushNext}
    }});
    assign IBusCachedPlugin_jump_pcLoad_valid = (|{CsrPlugin_jumpInterface_valid, {
        BranchPlugin_jumpInterface_valid,
        {DBusCachedPlugin_redoBranch_valid, IBusCachedPlugin_predictionJumpInterface_valid}
    }});
    assign _zz_IBusCachedPlugin_jump_pcLoad_payload = {
        IBusCachedPlugin_predictionJumpInterface_valid,
        {
            BranchPlugin_jumpInterface_valid,
            {CsrPlugin_jumpInterface_valid, DBusCachedPlugin_redoBranch_valid}
        }
    };
    assign _zz_IBusCachedPlugin_jump_pcLoad_payload_1 = (_zz_IBusCachedPlugin_jump_pcLoad_payload & (~ _zz__zz_IBusCachedPlugin_jump_pcLoad_payload_1));
    assign _zz_IBusCachedPlugin_jump_pcLoad_payload_2 = _zz_IBusCachedPlugin_jump_pcLoad_payload_1[3];
    assign _zz_IBusCachedPlugin_jump_pcLoad_payload_3 = (_zz_IBusCachedPlugin_jump_pcLoad_payload_1[1] || _zz_IBusCachedPlugin_jump_pcLoad_payload_2);
    assign _zz_IBusCachedPlugin_jump_pcLoad_payload_4 = (_zz_IBusCachedPlugin_jump_pcLoad_payload_1[2] || _zz_IBusCachedPlugin_jump_pcLoad_payload_2);
    assign IBusCachedPlugin_jump_pcLoad_payload = _zz_IBusCachedPlugin_jump_pcLoad_payload_5;
    always @(*) begin
        IBusCachedPlugin_fetchPc_correction = 1'b0;
        if (IBusCachedPlugin_fetchPc_redo_valid) begin
            IBusCachedPlugin_fetchPc_correction = 1'b1;
        end
        if (IBusCachedPlugin_jump_pcLoad_valid) begin
            IBusCachedPlugin_fetchPc_correction = 1'b1;
        end
    end

    assign IBusCachedPlugin_fetchPc_output_fire = (IBusCachedPlugin_fetchPc_output_valid && IBusCachedPlugin_fetchPc_output_ready);
    assign IBusCachedPlugin_fetchPc_corrected = (IBusCachedPlugin_fetchPc_correction || IBusCachedPlugin_fetchPc_correctionReg);
    always @(*) begin
        IBusCachedPlugin_fetchPc_pcRegPropagate = 1'b0;
        if (IBusCachedPlugin_iBusRsp_stages_1_input_ready) begin
            IBusCachedPlugin_fetchPc_pcRegPropagate = 1'b1;
        end
    end

    assign when_Fetcher_l133 = (IBusCachedPlugin_fetchPc_correction || IBusCachedPlugin_fetchPc_pcRegPropagate);
    assign when_Fetcher_l133_1 = ((! IBusCachedPlugin_fetchPc_output_valid) && IBusCachedPlugin_fetchPc_output_ready);
    always @(*) begin
        IBusCachedPlugin_fetchPc_pc = (IBusCachedPlugin_fetchPc_pcReg + _zz_IBusCachedPlugin_fetchPc_pc);
        if (IBusCachedPlugin_fetchPc_redo_valid) begin
            IBusCachedPlugin_fetchPc_pc = IBusCachedPlugin_fetchPc_redo_payload;
        end
        if (IBusCachedPlugin_jump_pcLoad_valid) begin
            IBusCachedPlugin_fetchPc_pc = IBusCachedPlugin_jump_pcLoad_payload;
        end
        IBusCachedPlugin_fetchPc_pc[0] = 1'b0;
        IBusCachedPlugin_fetchPc_pc[1] = 1'b0;
    end

    always @(*) begin
        IBusCachedPlugin_fetchPc_flushed = 1'b0;
        if (IBusCachedPlugin_fetchPc_redo_valid) begin
            IBusCachedPlugin_fetchPc_flushed = 1'b1;
        end
        if (IBusCachedPlugin_jump_pcLoad_valid) begin
            IBusCachedPlugin_fetchPc_flushed = 1'b1;
        end
    end

    assign when_Fetcher_l160 = (IBusCachedPlugin_fetchPc_booted && ((IBusCachedPlugin_fetchPc_output_ready || IBusCachedPlugin_fetchPc_correction) || IBusCachedPlugin_fetchPc_pcRegPropagate));
    assign IBusCachedPlugin_fetchPc_output_valid = ((! IBusCachedPlugin_fetcherHalt) && IBusCachedPlugin_fetchPc_booted);
    assign IBusCachedPlugin_fetchPc_output_payload = IBusCachedPlugin_fetchPc_pc;
    always @(*) begin
        IBusCachedPlugin_iBusRsp_redoFetch = 1'b0;
        if (IBusCachedPlugin_rsp_redoFetch) begin
            IBusCachedPlugin_iBusRsp_redoFetch = 1'b1;
        end
    end

    assign IBusCachedPlugin_iBusRsp_stages_0_input_valid = IBusCachedPlugin_fetchPc_output_valid;
    assign IBusCachedPlugin_fetchPc_output_ready = IBusCachedPlugin_iBusRsp_stages_0_input_ready;
    assign IBusCachedPlugin_iBusRsp_stages_0_input_payload = IBusCachedPlugin_fetchPc_output_payload;
    always @(*) begin
        IBusCachedPlugin_iBusRsp_stages_0_halt = 1'b0;
        if (IBusCachedPlugin_cache_io_cpu_prefetch_haltIt) begin
            IBusCachedPlugin_iBusRsp_stages_0_halt = 1'b1;
        end
    end

    assign _zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready = (! IBusCachedPlugin_iBusRsp_stages_0_halt);
    assign IBusCachedPlugin_iBusRsp_stages_0_input_ready = (IBusCachedPlugin_iBusRsp_stages_0_output_ready && _zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready);
    assign IBusCachedPlugin_iBusRsp_stages_0_output_valid = (IBusCachedPlugin_iBusRsp_stages_0_input_valid && _zz_IBusCachedPlugin_iBusRsp_stages_0_input_ready);
    assign IBusCachedPlugin_iBusRsp_stages_0_output_payload = IBusCachedPlugin_iBusRsp_stages_0_input_payload;
    always @(*) begin
        IBusCachedPlugin_iBusRsp_stages_1_halt = 1'b0;
        if (IBusCachedPlugin_mmuBus_busy) begin
            IBusCachedPlugin_iBusRsp_stages_1_halt = 1'b1;
        end
    end

    assign _zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready = (! IBusCachedPlugin_iBusRsp_stages_1_halt);
    assign IBusCachedPlugin_iBusRsp_stages_1_input_ready = (IBusCachedPlugin_iBusRsp_stages_1_output_ready && _zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready);
    assign IBusCachedPlugin_iBusRsp_stages_1_output_valid = (IBusCachedPlugin_iBusRsp_stages_1_input_valid && _zz_IBusCachedPlugin_iBusRsp_stages_1_input_ready);
    assign IBusCachedPlugin_iBusRsp_stages_1_output_payload = IBusCachedPlugin_iBusRsp_stages_1_input_payload;
    always @(*) begin
        IBusCachedPlugin_iBusRsp_stages_2_halt = 1'b0;
        if (when_IBusCachedPlugin_l273) begin
            IBusCachedPlugin_iBusRsp_stages_2_halt = 1'b1;
        end
    end

    assign _zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready = (! IBusCachedPlugin_iBusRsp_stages_2_halt);
    assign IBusCachedPlugin_iBusRsp_stages_2_input_ready = (IBusCachedPlugin_iBusRsp_stages_2_output_ready && _zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready);
    assign IBusCachedPlugin_iBusRsp_stages_2_output_valid = (IBusCachedPlugin_iBusRsp_stages_2_input_valid && _zz_IBusCachedPlugin_iBusRsp_stages_2_input_ready);
    assign IBusCachedPlugin_iBusRsp_stages_2_output_payload = IBusCachedPlugin_iBusRsp_stages_2_input_payload;
    assign IBusCachedPlugin_fetchPc_redo_valid = IBusCachedPlugin_iBusRsp_redoFetch;
    assign IBusCachedPlugin_fetchPc_redo_payload = IBusCachedPlugin_iBusRsp_stages_2_input_payload;
    assign IBusCachedPlugin_iBusRsp_flush = ((decode_arbitration_removeIt || (decode_arbitration_flushNext && (! decode_arbitration_isStuck))) || IBusCachedPlugin_iBusRsp_redoFetch);
    assign IBusCachedPlugin_iBusRsp_stages_0_output_ready = _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready;
    assign _zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready = ((1'b0 && (! _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid)) || IBusCachedPlugin_iBusRsp_stages_1_input_ready);
    assign _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid = _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1;
    assign IBusCachedPlugin_iBusRsp_stages_1_input_valid = _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid;
    assign IBusCachedPlugin_iBusRsp_stages_1_input_payload = IBusCachedPlugin_fetchPc_pcReg;
    assign IBusCachedPlugin_iBusRsp_stages_1_output_ready = ((1'b0 && (! IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid)) || IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready);
    assign IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid = _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    assign IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload = _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    assign IBusCachedPlugin_iBusRsp_stages_2_input_valid = IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    assign IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_ready = IBusCachedPlugin_iBusRsp_stages_2_input_ready;
    assign IBusCachedPlugin_iBusRsp_stages_2_input_payload = IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    always @(*) begin
        IBusCachedPlugin_iBusRsp_readyForError = 1'b1;
        if (when_Fetcher_l322) begin
            IBusCachedPlugin_iBusRsp_readyForError = 1'b0;
        end
    end

    assign when_Fetcher_l242 = (IBusCachedPlugin_iBusRsp_stages_1_input_valid || IBusCachedPlugin_iBusRsp_stages_2_input_valid);
    assign when_Fetcher_l322 = (!IBusCachedPlugin_pcValids_0);
    assign when_Fetcher_l331 = (!(!IBusCachedPlugin_iBusRsp_stages_1_input_ready));
    assign when_Fetcher_l331_1 = (!(!IBusCachedPlugin_iBusRsp_stages_2_input_ready));
    assign when_Fetcher_l331_2 = (!execute_arbitration_isStuck);
    assign when_Fetcher_l331_3 = (!memory_arbitration_isStuck);
    assign when_Fetcher_l331_4 = (!writeBack_arbitration_isStuck);
    assign IBusCachedPlugin_pcValids_0 = IBusCachedPlugin_injector_nextPcCalc_valids_1;
    assign IBusCachedPlugin_pcValids_1 = IBusCachedPlugin_injector_nextPcCalc_valids_2;
    assign IBusCachedPlugin_pcValids_2 = IBusCachedPlugin_injector_nextPcCalc_valids_3;
    assign IBusCachedPlugin_pcValids_3 = IBusCachedPlugin_injector_nextPcCalc_valids_4;
    assign IBusCachedPlugin_iBusRsp_output_ready = (!decode_arbitration_isStuck);
    always @(*) begin
        decode_arbitration_isValid = IBusCachedPlugin_iBusRsp_output_valid;
        case (IBusCachedPlugin_injector_port_state)
            3'b010: begin
                decode_arbitration_isValid = 1'b1;
            end
            3'b011: begin
                decode_arbitration_isValid = 1'b1;
            end
            default: begin
            end
        endcase
        if (IBusCachedPlugin_forceNoDecodeCond) begin
            decode_arbitration_isValid = 1'b0;
        end
    end

    assign _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch = _zz__zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch[11];
    always @(*) begin
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[18] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[17] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[16] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[15] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[14] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[13] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[12] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[11] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[10] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[9] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[8] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[7] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[6] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[5] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[4] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[3] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[2] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[1] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
        _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_1[0] = _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch;
    end

    always @(*) begin
        IBusCachedPlugin_decodePrediction_cmd_hadBranch = ((decode_BRANCH_CTRL == BranchCtrlEnum_JAL) || ((decode_BRANCH_CTRL == BranchCtrlEnum_B) && _zz_IBusCachedPlugin_decodePrediction_cmd_hadBranch_2[31]));
        if (_zz_6) begin
            IBusCachedPlugin_decodePrediction_cmd_hadBranch = 1'b0;
        end
    end

    assign _zz_2 = _zz__zz_2[19];
    always @(*) begin
        _zz_3[10] = _zz_2;
        _zz_3[9]  = _zz_2;
        _zz_3[8]  = _zz_2;
        _zz_3[7]  = _zz_2;
        _zz_3[6]  = _zz_2;
        _zz_3[5]  = _zz_2;
        _zz_3[4]  = _zz_2;
        _zz_3[3]  = _zz_2;
        _zz_3[2]  = _zz_2;
        _zz_3[1]  = _zz_2;
        _zz_3[0]  = _zz_2;
    end

    assign _zz_4 = _zz__zz_4[11];
    always @(*) begin
        _zz_5[18] = _zz_4;
        _zz_5[17] = _zz_4;
        _zz_5[16] = _zz_4;
        _zz_5[15] = _zz_4;
        _zz_5[14] = _zz_4;
        _zz_5[13] = _zz_4;
        _zz_5[12] = _zz_4;
        _zz_5[11] = _zz_4;
        _zz_5[10] = _zz_4;
        _zz_5[9]  = _zz_4;
        _zz_5[8]  = _zz_4;
        _zz_5[7]  = _zz_4;
        _zz_5[6]  = _zz_4;
        _zz_5[5]  = _zz_4;
        _zz_5[4]  = _zz_4;
        _zz_5[3]  = _zz_4;
        _zz_5[2]  = _zz_4;
        _zz_5[1]  = _zz_4;
        _zz_5[0]  = _zz_4;
    end

    always @(*) begin
        case (decode_BRANCH_CTRL)
            BranchCtrlEnum_JAL: begin
                _zz_6 = _zz__zz_6[1];
            end
            default: begin
                _zz_6 = _zz__zz_6_1[1];
            end
        endcase
    end

    assign IBusCachedPlugin_predictionJumpInterface_valid = (decode_arbitration_isValid && IBusCachedPlugin_decodePrediction_cmd_hadBranch);
    assign _zz_IBusCachedPlugin_predictionJumpInterface_payload = _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload[19];
    always @(*) begin
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[10] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[9] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[8] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[7] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[6] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[5] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[4] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[3] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[2] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[1] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_1[0] = _zz_IBusCachedPlugin_predictionJumpInterface_payload;
    end

    assign _zz_IBusCachedPlugin_predictionJumpInterface_payload_2 = _zz__zz_IBusCachedPlugin_predictionJumpInterface_payload_2[11];
    always @(*) begin
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[18] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[17] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[16] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[15] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[14] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[13] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[12] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[11] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[10] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[9] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[8] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[7] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[6] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[5] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[4] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[3] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[2] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[1] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
        _zz_IBusCachedPlugin_predictionJumpInterface_payload_3[0] = _zz_IBusCachedPlugin_predictionJumpInterface_payload_2;
    end

    assign IBusCachedPlugin_predictionJumpInterface_payload = (decode_PC + ((decode_BRANCH_CTRL == BranchCtrlEnum_JAL) ? {{_zz_IBusCachedPlugin_predictionJumpInterface_payload_1,{{{_zz_IBusCachedPlugin_predictionJumpInterface_payload_4,decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_IBusCachedPlugin_predictionJumpInterface_payload_3,{{{_zz_IBusCachedPlugin_predictionJumpInterface_payload_5,_zz_IBusCachedPlugin_predictionJumpInterface_payload_6},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0}));
    assign iBus_cmd_valid = IBusCachedPlugin_cache_io_mem_cmd_valid;
    always @(*) begin
        iBus_cmd_payload_address = IBusCachedPlugin_cache_io_mem_cmd_payload_address;
        iBus_cmd_payload_address = IBusCachedPlugin_cache_io_mem_cmd_payload_address;
    end

    assign iBus_cmd_payload_size = IBusCachedPlugin_cache_io_mem_cmd_payload_size;
    assign IBusCachedPlugin_s0_tightlyCoupledHit = 1'b0;
    assign IBusCachedPlugin_cache_io_cpu_prefetch_isValid = (IBusCachedPlugin_iBusRsp_stages_0_input_valid && (! IBusCachedPlugin_s0_tightlyCoupledHit));
    assign IBusCachedPlugin_cache_io_cpu_fetch_isValid = (IBusCachedPlugin_iBusRsp_stages_1_input_valid && (! IBusCachedPlugin_s1_tightlyCoupledHit));
    assign IBusCachedPlugin_cache_io_cpu_fetch_isStuck = (! IBusCachedPlugin_iBusRsp_stages_1_input_ready);
    assign IBusCachedPlugin_mmuBus_cmd_0_isValid = IBusCachedPlugin_cache_io_cpu_fetch_isValid;
    assign IBusCachedPlugin_mmuBus_cmd_0_isStuck = (!IBusCachedPlugin_iBusRsp_stages_1_input_ready);
    assign IBusCachedPlugin_mmuBus_cmd_0_virtualAddress = IBusCachedPlugin_iBusRsp_stages_1_input_payload;
    assign IBusCachedPlugin_mmuBus_cmd_0_bypassTranslation = 1'b0;
    assign IBusCachedPlugin_mmuBus_end = (IBusCachedPlugin_iBusRsp_stages_1_input_ready || IBusCachedPlugin_externalFlush);
    assign IBusCachedPlugin_cache_io_cpu_decode_isValid = (IBusCachedPlugin_iBusRsp_stages_2_input_valid && (! IBusCachedPlugin_s2_tightlyCoupledHit));
    assign IBusCachedPlugin_cache_io_cpu_decode_isStuck = (! IBusCachedPlugin_iBusRsp_stages_2_input_ready);
    assign IBusCachedPlugin_cache_io_cpu_decode_isUser = (CsrPlugin_privilege == 2'b00);
    assign IBusCachedPlugin_rsp_iBusRspOutputHalt = 1'b0;
    assign IBusCachedPlugin_rsp_issueDetected = 1'b0;
    always @(*) begin
        IBusCachedPlugin_rsp_redoFetch = 1'b0;
        if (when_IBusCachedPlugin_l245) begin
            IBusCachedPlugin_rsp_redoFetch = 1'b1;
        end
        if (when_IBusCachedPlugin_l256) begin
            IBusCachedPlugin_rsp_redoFetch = 1'b1;
        end
    end

    always @(*) begin
        IBusCachedPlugin_cache_io_cpu_fill_valid = (IBusCachedPlugin_rsp_redoFetch && (! IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling));
        if (when_IBusCachedPlugin_l256) begin
            IBusCachedPlugin_cache_io_cpu_fill_valid = 1'b1;
        end
    end

    always @(*) begin
        IBusCachedPlugin_decodeExceptionPort_valid = 1'b0;
        if (when_IBusCachedPlugin_l250) begin
            IBusCachedPlugin_decodeExceptionPort_valid = IBusCachedPlugin_iBusRsp_readyForError;
        end
        if (when_IBusCachedPlugin_l262) begin
            IBusCachedPlugin_decodeExceptionPort_valid = IBusCachedPlugin_iBusRsp_readyForError;
        end
    end

    always @(*) begin
        IBusCachedPlugin_decodeExceptionPort_payload_code = 4'bxxxx;
        if (when_IBusCachedPlugin_l250) begin
            IBusCachedPlugin_decodeExceptionPort_payload_code = 4'b1100;
        end
        if (when_IBusCachedPlugin_l262) begin
            IBusCachedPlugin_decodeExceptionPort_payload_code = 4'b0001;
        end
    end

    assign IBusCachedPlugin_decodeExceptionPort_payload_badAddr = {
        IBusCachedPlugin_iBusRsp_stages_2_input_payload[31 : 2], 2'b00
    };
    assign when_IBusCachedPlugin_l245 = ((IBusCachedPlugin_cache_io_cpu_decode_isValid && IBusCachedPlugin_cache_io_cpu_decode_mmuRefilling) && (! IBusCachedPlugin_rsp_issueDetected));
    assign when_IBusCachedPlugin_l250 = ((IBusCachedPlugin_cache_io_cpu_decode_isValid && IBusCachedPlugin_cache_io_cpu_decode_mmuException) && (! IBusCachedPlugin_rsp_issueDetected_1));
    assign when_IBusCachedPlugin_l256 = ((IBusCachedPlugin_cache_io_cpu_decode_isValid && IBusCachedPlugin_cache_io_cpu_decode_cacheMiss) && (! IBusCachedPlugin_rsp_issueDetected_2));
    assign when_IBusCachedPlugin_l262 = ((IBusCachedPlugin_cache_io_cpu_decode_isValid && IBusCachedPlugin_cache_io_cpu_decode_error) && (! IBusCachedPlugin_rsp_issueDetected_3));
    assign when_IBusCachedPlugin_l273 = (IBusCachedPlugin_rsp_issueDetected_4 || IBusCachedPlugin_rsp_iBusRspOutputHalt);
    assign IBusCachedPlugin_iBusRsp_output_valid = IBusCachedPlugin_iBusRsp_stages_2_output_valid;
    assign IBusCachedPlugin_iBusRsp_stages_2_output_ready = IBusCachedPlugin_iBusRsp_output_ready;
    assign IBusCachedPlugin_iBusRsp_output_payload_rsp_inst = IBusCachedPlugin_cache_io_cpu_decode_data;
    assign IBusCachedPlugin_iBusRsp_output_payload_pc = IBusCachedPlugin_iBusRsp_stages_2_output_payload;
    assign IBusCachedPlugin_cache_io_flush = (decode_arbitration_isValid && decode_FLUSH_ALL);
    assign dBus_cmd_valid = dataCache_1_io_mem_cmd_valid;
    assign dBus_cmd_payload_wr = dataCache_1_io_mem_cmd_payload_wr;
    assign dBus_cmd_payload_uncached = dataCache_1_io_mem_cmd_payload_uncached;
    assign dBus_cmd_payload_address = dataCache_1_io_mem_cmd_payload_address;
    assign dBus_cmd_payload_data = dataCache_1_io_mem_cmd_payload_data;
    assign dBus_cmd_payload_mask = dataCache_1_io_mem_cmd_payload_mask;
    assign dBus_cmd_payload_size = dataCache_1_io_mem_cmd_payload_size;
    assign dBus_cmd_payload_last = dataCache_1_io_mem_cmd_payload_last;
    assign when_DBusCachedPlugin_l353 = ((DBusCachedPlugin_mmuBus_busy && decode_arbitration_isValid) && decode_MEMORY_ENABLE);
    assign execute_DBusCachedPlugin_size = execute_INSTRUCTION[13 : 12];
    assign dataCache_1_io_cpu_execute_isValid = (execute_arbitration_isValid && execute_MEMORY_ENABLE);
    assign dataCache_1_io_cpu_execute_address = execute_SRC_ADD;
    always @(*) begin
        case (execute_DBusCachedPlugin_size)
            2'b00: begin
                _zz_execute_MEMORY_STORE_DATA_RF = {
                    {{execute_RS2[7 : 0], execute_RS2[7 : 0]}, execute_RS2[7 : 0]},
                    execute_RS2[7 : 0]
                };
            end
            2'b01: begin
                _zz_execute_MEMORY_STORE_DATA_RF = {execute_RS2[15 : 0], execute_RS2[15 : 0]};
            end
            default: begin
                _zz_execute_MEMORY_STORE_DATA_RF = execute_RS2[31 : 0];
            end
        endcase
    end

    assign dataCache_1_io_cpu_flush_valid = (execute_arbitration_isValid && execute_MEMORY_MANAGMENT);
    assign dataCache_1_io_cpu_flush_payload_singleLine = (execute_INSTRUCTION[19 : 15] != 5'h0);
    assign dataCache_1_io_cpu_flush_payload_lineId = _zz_io_cpu_flush_payload_lineId[6:0];
    assign axi_core_cpu_dataCache_1_io_cpu_flush_isStall = (dataCache_1_io_cpu_flush_valid && (! dataCache_1_io_cpu_flush_ready));
    assign when_DBusCachedPlugin_l395 = (axi_core_cpu_dataCache_1_io_cpu_flush_isStall || dataCache_1_io_cpu_execute_haltIt);
    assign when_DBusCachedPlugin_l411 = (dataCache_1_io_cpu_execute_refilling && execute_arbitration_isValid);
    assign dataCache_1_io_cpu_memory_isValid = (memory_arbitration_isValid && memory_MEMORY_ENABLE);
    assign dataCache_1_io_cpu_memory_address = memory_REGFILE_WRITE_DATA;
    assign DBusCachedPlugin_mmuBus_cmd_0_isValid = dataCache_1_io_cpu_memory_isValid;
    assign DBusCachedPlugin_mmuBus_cmd_0_isStuck = memory_arbitration_isStuck;
    assign DBusCachedPlugin_mmuBus_cmd_0_virtualAddress = dataCache_1_io_cpu_memory_address;
    assign DBusCachedPlugin_mmuBus_cmd_0_bypassTranslation = 1'b0;
    assign DBusCachedPlugin_mmuBus_end = ((! memory_arbitration_isStuck) || memory_arbitration_removeIt);
    always @(*) begin
        dataCache_1_io_cpu_memory_mmuRsp_isIoAccess = DBusCachedPlugin_mmuBus_rsp_isIoAccess;
        if (when_DBusCachedPlugin_l473) begin
            dataCache_1_io_cpu_memory_mmuRsp_isIoAccess = 1'b1;
        end
    end

    assign when_DBusCachedPlugin_l473 = (_zz_when_DBusCachedPlugin_l473 && (! dataCache_1_io_cpu_memory_isWrite));
    always @(*) begin
        dataCache_1_io_cpu_writeBack_isValid = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
        if (writeBack_arbitration_haltByOther) begin
            dataCache_1_io_cpu_writeBack_isValid = 1'b0;
        end
    end

    assign dataCache_1_io_cpu_writeBack_isUser = (CsrPlugin_privilege == 2'b00);
    assign dataCache_1_io_cpu_writeBack_address = writeBack_REGFILE_WRITE_DATA;
    assign dataCache_1_io_cpu_writeBack_storeData[31 : 0] = writeBack_MEMORY_STORE_DATA_RF;
    always @(*) begin
        DBusCachedPlugin_redoBranch_valid = 1'b0;
        if (when_DBusCachedPlugin_l534) begin
            if (dataCache_1_io_cpu_redo) begin
                DBusCachedPlugin_redoBranch_valid = 1'b1;
            end
        end
    end

    assign DBusCachedPlugin_redoBranch_payload = writeBack_PC;
    always @(*) begin
        DBusCachedPlugin_exceptionBus_valid = 1'b0;
        if (when_DBusCachedPlugin_l534) begin
            if (dataCache_1_io_cpu_writeBack_accessError) begin
                DBusCachedPlugin_exceptionBus_valid = 1'b1;
            end
            if (dataCache_1_io_cpu_writeBack_mmuException) begin
                DBusCachedPlugin_exceptionBus_valid = 1'b1;
            end
            if (dataCache_1_io_cpu_writeBack_unalignedAccess) begin
                DBusCachedPlugin_exceptionBus_valid = 1'b1;
            end
            if (dataCache_1_io_cpu_redo) begin
                DBusCachedPlugin_exceptionBus_valid = 1'b0;
            end
        end
    end

    assign DBusCachedPlugin_exceptionBus_payload_badAddr = writeBack_REGFILE_WRITE_DATA;
    always @(*) begin
        DBusCachedPlugin_exceptionBus_payload_code = 4'bxxxx;
        if (when_DBusCachedPlugin_l534) begin
            if (dataCache_1_io_cpu_writeBack_accessError) begin
                DBusCachedPlugin_exceptionBus_payload_code = {
                    1'd0, _zz_DBusCachedPlugin_exceptionBus_payload_code
                };
            end
            if (dataCache_1_io_cpu_writeBack_mmuException) begin
                DBusCachedPlugin_exceptionBus_payload_code = (writeBack_MEMORY_WR ? 4'b1111 : 4'b1101);
            end
            if (dataCache_1_io_cpu_writeBack_unalignedAccess) begin
                DBusCachedPlugin_exceptionBus_payload_code = {
                    1'd0, _zz_DBusCachedPlugin_exceptionBus_payload_code_1
                };
            end
        end
    end

    assign when_DBusCachedPlugin_l534 = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
    assign when_DBusCachedPlugin_l554 = (dataCache_1_io_cpu_writeBack_isValid && dataCache_1_io_cpu_writeBack_haltIt);
    assign writeBack_DBusCachedPlugin_rspData = dataCache_1_io_cpu_writeBack_data;
    assign writeBack_DBusCachedPlugin_rspSplits_0 = writeBack_DBusCachedPlugin_rspData[7 : 0];
    assign writeBack_DBusCachedPlugin_rspSplits_1 = writeBack_DBusCachedPlugin_rspData[15 : 8];
    assign writeBack_DBusCachedPlugin_rspSplits_2 = writeBack_DBusCachedPlugin_rspData[23 : 16];
    assign writeBack_DBusCachedPlugin_rspSplits_3 = writeBack_DBusCachedPlugin_rspData[31 : 24];
    always @(*) begin
        writeBack_DBusCachedPlugin_rspShifted[7 : 0] = _zz_writeBack_DBusCachedPlugin_rspShifted;
        writeBack_DBusCachedPlugin_rspShifted[15 : 8] = _zz_writeBack_DBusCachedPlugin_rspShifted_2;
        writeBack_DBusCachedPlugin_rspShifted[23 : 16] = writeBack_DBusCachedPlugin_rspSplits_2;
        writeBack_DBusCachedPlugin_rspShifted[31 : 24] = writeBack_DBusCachedPlugin_rspSplits_3;
    end

    assign writeBack_DBusCachedPlugin_rspRf = writeBack_DBusCachedPlugin_rspShifted[31 : 0];
    assign switch_Misc_l241 = writeBack_INSTRUCTION[13 : 12];
    assign _zz_writeBack_DBusCachedPlugin_rspFormated = (writeBack_DBusCachedPlugin_rspRf[7] && (! writeBack_INSTRUCTION[14]));
    always @(*) begin
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[31] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[30] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[29] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[28] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[27] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[26] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[25] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[24] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[23] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[22] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[21] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[20] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[19] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[18] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[17] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[16] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[15] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[14] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[13] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[12] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[11] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[10] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[9] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[8] = _zz_writeBack_DBusCachedPlugin_rspFormated;
        _zz_writeBack_DBusCachedPlugin_rspFormated_1[7 : 0] = writeBack_DBusCachedPlugin_rspRf[7 : 0];
    end

    assign _zz_writeBack_DBusCachedPlugin_rspFormated_2 = (writeBack_DBusCachedPlugin_rspRf[15] && (! writeBack_INSTRUCTION[14]));
    always @(*) begin
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[31] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[30] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[29] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[28] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[27] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[26] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[25] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[24] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[23] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[22] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[21] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[20] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[19] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[18] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[17] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[16] = _zz_writeBack_DBusCachedPlugin_rspFormated_2;
        _zz_writeBack_DBusCachedPlugin_rspFormated_3[15 : 0] = writeBack_DBusCachedPlugin_rspRf[15 : 0];
    end

    always @(*) begin
        case (switch_Misc_l241)
            2'b00: begin
                writeBack_DBusCachedPlugin_rspFormated = _zz_writeBack_DBusCachedPlugin_rspFormated_1;
            end
            2'b01: begin
                writeBack_DBusCachedPlugin_rspFormated = _zz_writeBack_DBusCachedPlugin_rspFormated_3;
            end
            default: begin
                writeBack_DBusCachedPlugin_rspFormated = writeBack_DBusCachedPlugin_rspRf;
            end
        endcase
    end

    assign when_DBusCachedPlugin_l581 = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
    assign IBusCachedPlugin_mmuBus_rsp_physicalAddress = IBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
    assign IBusCachedPlugin_mmuBus_rsp_allowRead = 1'b1;
    assign IBusCachedPlugin_mmuBus_rsp_allowWrite = 1'b1;
    assign IBusCachedPlugin_mmuBus_rsp_allowExecute = 1'b1;
    assign IBusCachedPlugin_mmuBus_rsp_isIoAccess = (IBusCachedPlugin_mmuBus_rsp_physicalAddress[31 : 28] == 4'b1111);
    assign IBusCachedPlugin_mmuBus_rsp_isPaging = 1'b0;
    assign IBusCachedPlugin_mmuBus_rsp_exception = 1'b0;
    assign IBusCachedPlugin_mmuBus_rsp_refilling = 1'b0;
    assign IBusCachedPlugin_mmuBus_busy = 1'b0;
    assign DBusCachedPlugin_mmuBus_rsp_physicalAddress = DBusCachedPlugin_mmuBus_cmd_0_virtualAddress;
    assign DBusCachedPlugin_mmuBus_rsp_allowRead = 1'b1;
    assign DBusCachedPlugin_mmuBus_rsp_allowWrite = 1'b1;
    assign DBusCachedPlugin_mmuBus_rsp_allowExecute = 1'b1;
    assign DBusCachedPlugin_mmuBus_rsp_isIoAccess = (DBusCachedPlugin_mmuBus_rsp_physicalAddress[31 : 28] == 4'b1111);
    assign DBusCachedPlugin_mmuBus_rsp_isPaging = 1'b0;
    assign DBusCachedPlugin_mmuBus_rsp_exception = 1'b0;
    assign DBusCachedPlugin_mmuBus_rsp_refilling = 1'b0;
    assign DBusCachedPlugin_mmuBus_busy = 1'b0;
    assign _zz_decode_IS_CSR_1 = ((decode_INSTRUCTION & 32'h00004050) == 32'h00004050);
    assign _zz_decode_IS_CSR_2 = ((decode_INSTRUCTION & 32'h00000018) == 32'h0);
    assign _zz_decode_IS_CSR_3 = ((decode_INSTRUCTION & 32'h00000004) == 32'h00000004);
    assign _zz_decode_IS_CSR_4 = ((decode_INSTRUCTION & 32'h00000048) == 32'h00000048);
    assign _zz_decode_IS_CSR_5 = ((decode_INSTRUCTION & 32'h00001000) == 32'h0);
    assign _zz_decode_IS_CSR = {
        (|((decode_INSTRUCTION & 32'h10003050) == 32'h00000050)),
        {
            (|((decode_INSTRUCTION & _zz__zz_decode_IS_CSR) == 32'h00000050)),
            {
                (|{_zz__zz_decode_IS_CSR_1, _zz__zz_decode_IS_CSR_2}),
                {
                    (|{_zz__zz_decode_IS_CSR_3, _zz__zz_decode_IS_CSR_4}),
                    {
                        (|_zz__zz_decode_IS_CSR_5),
                        {
                            _zz__zz_decode_IS_CSR_6,
                            {_zz__zz_decode_IS_CSR_7, _zz__zz_decode_IS_CSR_8}
                        }
                    }
                }
            }
        }
    };
    assign _zz_decode_SRC1_CTRL_2 = _zz_decode_IS_CSR[2 : 1];
    assign _zz_decode_SRC1_CTRL_1 = _zz_decode_SRC1_CTRL_2;
    assign _zz_decode_ALU_CTRL_2 = _zz_decode_IS_CSR[7 : 6];
    assign _zz_decode_ALU_CTRL_1 = _zz_decode_ALU_CTRL_2;
    assign _zz_decode_SRC2_CTRL_2 = _zz_decode_IS_CSR[9 : 8];
    assign _zz_decode_SRC2_CTRL_1 = _zz_decode_SRC2_CTRL_2;
    assign _zz_decode_ALU_BITWISE_CTRL_2 = _zz_decode_IS_CSR[19 : 18];
    assign _zz_decode_ALU_BITWISE_CTRL_1 = _zz_decode_ALU_BITWISE_CTRL_2;
    assign _zz_decode_SHIFT_CTRL_2 = _zz_decode_IS_CSR[22 : 21];
    assign _zz_decode_SHIFT_CTRL_1 = _zz_decode_SHIFT_CTRL_2;
    assign _zz_decode_BRANCH_CTRL_2 = _zz_decode_IS_CSR[28 : 27];
    assign _zz_decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL_2;
    assign _zz_decode_ENV_CTRL_2 = _zz_decode_IS_CSR[30 : 30];
    assign _zz_decode_ENV_CTRL_1 = _zz_decode_ENV_CTRL_2;
    assign decodeExceptionPort_valid = (decode_arbitration_isValid && (!decode_LEGAL_INSTRUCTION));
    assign decodeExceptionPort_payload_code = 4'b0010;
    assign decodeExceptionPort_payload_badAddr = decode_INSTRUCTION;
    assign when_RegFilePlugin_l63 = (decode_INSTRUCTION[11 : 7] == 5'h0);
    assign decode_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION_ANTICIPATED[19 : 15];
    assign decode_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION_ANTICIPATED[24 : 20];
    assign decode_RegFilePlugin_rs1Data = RegFilePlugin_regFile_spinal_port0;
    assign decode_RegFilePlugin_rs2Data = RegFilePlugin_regFile_spinal_port1;
    always @(*) begin
        lastStageRegFileWrite_valid = (_zz_lastStageRegFileWrite_valid && writeBack_arbitration_isFiring);
        if (_zz_10) begin
            lastStageRegFileWrite_valid = 1'b1;
        end
    end

    always @(*) begin
        lastStageRegFileWrite_payload_address = _zz_lastStageRegFileWrite_payload_address[11 : 7];
        if (_zz_10) begin
            lastStageRegFileWrite_payload_address = 5'h0;
        end
    end

    always @(*) begin
        lastStageRegFileWrite_payload_data = _zz_decode_RS2_2;
        if (_zz_10) begin
            lastStageRegFileWrite_payload_data = 32'h0;
        end
    end

    always @(*) begin
        case (execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_AND_1: begin
                execute_IntAluPlugin_bitwise = (execute_SRC1 & execute_SRC2);
            end
            AluBitwiseCtrlEnum_OR_1: begin
                execute_IntAluPlugin_bitwise = (execute_SRC1 | execute_SRC2);
            end
            default: begin
                execute_IntAluPlugin_bitwise = (execute_SRC1 ^ execute_SRC2);
            end
        endcase
    end

    always @(*) begin
        case (execute_ALU_CTRL)
            AluCtrlEnum_BITWISE: begin
                _zz_execute_REGFILE_WRITE_DATA = execute_IntAluPlugin_bitwise;
            end
            AluCtrlEnum_SLT_SLTU: begin
                _zz_execute_REGFILE_WRITE_DATA = {31'd0, _zz__zz_execute_REGFILE_WRITE_DATA};
            end
            default: begin
                _zz_execute_REGFILE_WRITE_DATA = execute_SRC_ADD_SUB;
            end
        endcase
    end

    always @(*) begin
        case (execute_SRC1_CTRL)
            Src1CtrlEnum_RS: begin
                _zz_execute_SRC1 = execute_RS1;
            end
            Src1CtrlEnum_PC_INCREMENT: begin
                _zz_execute_SRC1 = {29'd0, _zz__zz_execute_SRC1};
            end
            Src1CtrlEnum_IMU: begin
                _zz_execute_SRC1 = {execute_INSTRUCTION[31 : 12], 12'h0};
            end
            default: begin
                _zz_execute_SRC1 = {27'd0, _zz__zz_execute_SRC1_1};
            end
        endcase
    end

    assign _zz_execute_SRC2 = execute_INSTRUCTION[31];
    always @(*) begin
        _zz_execute_SRC2_1[19] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[18] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[17] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[16] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[15] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[14] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[13] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[12] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[11] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[10] = _zz_execute_SRC2;
        _zz_execute_SRC2_1[9]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[8]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[7]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[6]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[5]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[4]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[3]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[2]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[1]  = _zz_execute_SRC2;
        _zz_execute_SRC2_1[0]  = _zz_execute_SRC2;
    end

    assign _zz_execute_SRC2_2 = _zz__zz_execute_SRC2_2[11];
    always @(*) begin
        _zz_execute_SRC2_3[19] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[18] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[17] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[16] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[15] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[14] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[13] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[12] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[11] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[10] = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[9]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[8]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[7]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[6]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[5]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[4]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[3]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[2]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[1]  = _zz_execute_SRC2_2;
        _zz_execute_SRC2_3[0]  = _zz_execute_SRC2_2;
    end

    always @(*) begin
        case (execute_SRC2_CTRL)
            Src2CtrlEnum_RS: begin
                _zz_execute_SRC2_4 = execute_RS2;
            end
            Src2CtrlEnum_IMI: begin
                _zz_execute_SRC2_4 = {_zz_execute_SRC2_1, execute_INSTRUCTION[31 : 20]};
            end
            Src2CtrlEnum_IMS: begin
                _zz_execute_SRC2_4 = {
                    _zz_execute_SRC2_3, {execute_INSTRUCTION[31 : 25], execute_INSTRUCTION[11 : 7]}
                };
            end
            default: begin
                _zz_execute_SRC2_4 = _zz_execute_to_memory_PC;
            end
        endcase
    end

    always @(*) begin
        execute_SrcPlugin_addSub = _zz_execute_SrcPlugin_addSub;
        if (execute_SRC2_FORCE_ZERO) begin
            execute_SrcPlugin_addSub = execute_SRC1;
        end
    end

    assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_addSub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
    assign execute_FullBarrelShifterPlugin_amplitude = execute_SRC2[4 : 0];
    always @(*) begin
        _zz_execute_FullBarrelShifterPlugin_reversed[0]  = execute_SRC1[31];
        _zz_execute_FullBarrelShifterPlugin_reversed[1]  = execute_SRC1[30];
        _zz_execute_FullBarrelShifterPlugin_reversed[2]  = execute_SRC1[29];
        _zz_execute_FullBarrelShifterPlugin_reversed[3]  = execute_SRC1[28];
        _zz_execute_FullBarrelShifterPlugin_reversed[4]  = execute_SRC1[27];
        _zz_execute_FullBarrelShifterPlugin_reversed[5]  = execute_SRC1[26];
        _zz_execute_FullBarrelShifterPlugin_reversed[6]  = execute_SRC1[25];
        _zz_execute_FullBarrelShifterPlugin_reversed[7]  = execute_SRC1[24];
        _zz_execute_FullBarrelShifterPlugin_reversed[8]  = execute_SRC1[23];
        _zz_execute_FullBarrelShifterPlugin_reversed[9]  = execute_SRC1[22];
        _zz_execute_FullBarrelShifterPlugin_reversed[10] = execute_SRC1[21];
        _zz_execute_FullBarrelShifterPlugin_reversed[11] = execute_SRC1[20];
        _zz_execute_FullBarrelShifterPlugin_reversed[12] = execute_SRC1[19];
        _zz_execute_FullBarrelShifterPlugin_reversed[13] = execute_SRC1[18];
        _zz_execute_FullBarrelShifterPlugin_reversed[14] = execute_SRC1[17];
        _zz_execute_FullBarrelShifterPlugin_reversed[15] = execute_SRC1[16];
        _zz_execute_FullBarrelShifterPlugin_reversed[16] = execute_SRC1[15];
        _zz_execute_FullBarrelShifterPlugin_reversed[17] = execute_SRC1[14];
        _zz_execute_FullBarrelShifterPlugin_reversed[18] = execute_SRC1[13];
        _zz_execute_FullBarrelShifterPlugin_reversed[19] = execute_SRC1[12];
        _zz_execute_FullBarrelShifterPlugin_reversed[20] = execute_SRC1[11];
        _zz_execute_FullBarrelShifterPlugin_reversed[21] = execute_SRC1[10];
        _zz_execute_FullBarrelShifterPlugin_reversed[22] = execute_SRC1[9];
        _zz_execute_FullBarrelShifterPlugin_reversed[23] = execute_SRC1[8];
        _zz_execute_FullBarrelShifterPlugin_reversed[24] = execute_SRC1[7];
        _zz_execute_FullBarrelShifterPlugin_reversed[25] = execute_SRC1[6];
        _zz_execute_FullBarrelShifterPlugin_reversed[26] = execute_SRC1[5];
        _zz_execute_FullBarrelShifterPlugin_reversed[27] = execute_SRC1[4];
        _zz_execute_FullBarrelShifterPlugin_reversed[28] = execute_SRC1[3];
        _zz_execute_FullBarrelShifterPlugin_reversed[29] = execute_SRC1[2];
        _zz_execute_FullBarrelShifterPlugin_reversed[30] = execute_SRC1[1];
        _zz_execute_FullBarrelShifterPlugin_reversed[31] = execute_SRC1[0];
    end

    assign execute_FullBarrelShifterPlugin_reversed = ((execute_SHIFT_CTRL == ShiftCtrlEnum_SLL_1) ? _zz_execute_FullBarrelShifterPlugin_reversed : execute_SRC1);
    always @(*) begin
        _zz_decode_RS2_3[0]  = memory_SHIFT_RIGHT[31];
        _zz_decode_RS2_3[1]  = memory_SHIFT_RIGHT[30];
        _zz_decode_RS2_3[2]  = memory_SHIFT_RIGHT[29];
        _zz_decode_RS2_3[3]  = memory_SHIFT_RIGHT[28];
        _zz_decode_RS2_3[4]  = memory_SHIFT_RIGHT[27];
        _zz_decode_RS2_3[5]  = memory_SHIFT_RIGHT[26];
        _zz_decode_RS2_3[6]  = memory_SHIFT_RIGHT[25];
        _zz_decode_RS2_3[7]  = memory_SHIFT_RIGHT[24];
        _zz_decode_RS2_3[8]  = memory_SHIFT_RIGHT[23];
        _zz_decode_RS2_3[9]  = memory_SHIFT_RIGHT[22];
        _zz_decode_RS2_3[10] = memory_SHIFT_RIGHT[21];
        _zz_decode_RS2_3[11] = memory_SHIFT_RIGHT[20];
        _zz_decode_RS2_3[12] = memory_SHIFT_RIGHT[19];
        _zz_decode_RS2_3[13] = memory_SHIFT_RIGHT[18];
        _zz_decode_RS2_3[14] = memory_SHIFT_RIGHT[17];
        _zz_decode_RS2_3[15] = memory_SHIFT_RIGHT[16];
        _zz_decode_RS2_3[16] = memory_SHIFT_RIGHT[15];
        _zz_decode_RS2_3[17] = memory_SHIFT_RIGHT[14];
        _zz_decode_RS2_3[18] = memory_SHIFT_RIGHT[13];
        _zz_decode_RS2_3[19] = memory_SHIFT_RIGHT[12];
        _zz_decode_RS2_3[20] = memory_SHIFT_RIGHT[11];
        _zz_decode_RS2_3[21] = memory_SHIFT_RIGHT[10];
        _zz_decode_RS2_3[22] = memory_SHIFT_RIGHT[9];
        _zz_decode_RS2_3[23] = memory_SHIFT_RIGHT[8];
        _zz_decode_RS2_3[24] = memory_SHIFT_RIGHT[7];
        _zz_decode_RS2_3[25] = memory_SHIFT_RIGHT[6];
        _zz_decode_RS2_3[26] = memory_SHIFT_RIGHT[5];
        _zz_decode_RS2_3[27] = memory_SHIFT_RIGHT[4];
        _zz_decode_RS2_3[28] = memory_SHIFT_RIGHT[3];
        _zz_decode_RS2_3[29] = memory_SHIFT_RIGHT[2];
        _zz_decode_RS2_3[30] = memory_SHIFT_RIGHT[1];
        _zz_decode_RS2_3[31] = memory_SHIFT_RIGHT[0];
    end

    assign execute_MulPlugin_a  = execute_RS1;
    assign execute_MulPlugin_b  = execute_RS2;
    assign switch_MulPlugin_l87 = execute_INSTRUCTION[13 : 12];
    always @(*) begin
        case (switch_MulPlugin_l87)
            2'b01: begin
                execute_MulPlugin_aSigned = 1'b1;
            end
            2'b10: begin
                execute_MulPlugin_aSigned = 1'b1;
            end
            default: begin
                execute_MulPlugin_aSigned = 1'b0;
            end
        endcase
    end

    always @(*) begin
        case (switch_MulPlugin_l87)
            2'b01: begin
                execute_MulPlugin_bSigned = 1'b1;
            end
            2'b10: begin
                execute_MulPlugin_bSigned = 1'b0;
            end
            default: begin
                execute_MulPlugin_bSigned = 1'b0;
            end
        endcase
    end

    assign execute_MulPlugin_aULow = execute_MulPlugin_a[15 : 0];
    assign execute_MulPlugin_bULow = execute_MulPlugin_b[15 : 0];
    assign execute_MulPlugin_aSLow = {1'b0, execute_MulPlugin_a[15 : 0]};
    assign execute_MulPlugin_bSLow = {1'b0, execute_MulPlugin_b[15 : 0]};
    assign execute_MulPlugin_aHigh = {
        (execute_MulPlugin_aSigned && execute_MulPlugin_a[31]), execute_MulPlugin_a[31 : 16]
    };
    assign execute_MulPlugin_bHigh = {
        (execute_MulPlugin_bSigned && execute_MulPlugin_b[31]), execute_MulPlugin_b[31 : 16]
    };
    assign writeBack_MulPlugin_result = ($signed(
        _zz_writeBack_MulPlugin_result
    ) + $signed(
        _zz_writeBack_MulPlugin_result_1
    ));
    assign when_MulPlugin_l147 = (writeBack_arbitration_isValid && writeBack_IS_MUL);
    assign switch_MulPlugin_l148 = writeBack_INSTRUCTION[13 : 12];
    assign memory_DivPlugin_frontendOk = 1'b1;
    always @(*) begin
        memory_DivPlugin_div_counter_willIncrement = 1'b0;
        if (when_MulDivIterativePlugin_l128) begin
            if (when_MulDivIterativePlugin_l132) begin
                memory_DivPlugin_div_counter_willIncrement = 1'b1;
            end
        end
    end

    always @(*) begin
        memory_DivPlugin_div_counter_willClear = 1'b0;
        if (when_MulDivIterativePlugin_l162) begin
            memory_DivPlugin_div_counter_willClear = 1'b1;
        end
    end

    assign memory_DivPlugin_div_counter_willOverflowIfInc = (memory_DivPlugin_div_counter_value == 6'h21);
    assign memory_DivPlugin_div_counter_willOverflow = (memory_DivPlugin_div_counter_willOverflowIfInc && memory_DivPlugin_div_counter_willIncrement);
    always @(*) begin
        if (memory_DivPlugin_div_counter_willOverflow) begin
            memory_DivPlugin_div_counter_valueNext = 6'h0;
        end else begin
            memory_DivPlugin_div_counter_valueNext = (memory_DivPlugin_div_counter_value + _zz_memory_DivPlugin_div_counter_valueNext);
        end
        if (memory_DivPlugin_div_counter_willClear) begin
            memory_DivPlugin_div_counter_valueNext = 6'h0;
        end
    end

    assign when_MulDivIterativePlugin_l126 = (memory_DivPlugin_div_counter_value == 6'h20);
    assign when_MulDivIterativePlugin_l126_1 = (!memory_arbitration_isStuck);
    assign when_MulDivIterativePlugin_l128 = (memory_arbitration_isValid && memory_IS_DIV);
    assign when_MulDivIterativePlugin_l129 = ((! memory_DivPlugin_frontendOk) || (! memory_DivPlugin_div_done));
    assign when_MulDivIterativePlugin_l132 = (memory_DivPlugin_frontendOk && (! memory_DivPlugin_div_done));
    assign _zz_memory_DivPlugin_div_stage_0_remainderShifted = memory_DivPlugin_rs1[31 : 0];
    assign memory_DivPlugin_div_stage_0_remainderShifted = {
        memory_DivPlugin_accumulator[31 : 0], _zz_memory_DivPlugin_div_stage_0_remainderShifted[31]
    };
    assign memory_DivPlugin_div_stage_0_remainderMinusDenominator = (memory_DivPlugin_div_stage_0_remainderShifted - _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator);
    assign memory_DivPlugin_div_stage_0_outRemainder = ((! memory_DivPlugin_div_stage_0_remainderMinusDenominator[32]) ? _zz_memory_DivPlugin_div_stage_0_outRemainder : _zz_memory_DivPlugin_div_stage_0_outRemainder_1);
    assign memory_DivPlugin_div_stage_0_outNumerator = _zz_memory_DivPlugin_div_stage_0_outNumerator[31:0];
    assign when_MulDivIterativePlugin_l151 = (memory_DivPlugin_div_counter_value == 6'h20);
    assign _zz_memory_DivPlugin_div_result = (memory_INSTRUCTION[13] ? memory_DivPlugin_accumulator[31 : 0] : memory_DivPlugin_rs1[31 : 0]);
    assign when_MulDivIterativePlugin_l162 = (!memory_arbitration_isStuck);
    assign _zz_memory_DivPlugin_rs2 = (execute_RS2[31] && execute_IS_RS2_SIGNED);
    assign _zz_memory_DivPlugin_rs1 = (1'b0 || ((execute_IS_DIV && execute_RS1[31]) && execute_IS_RS1_SIGNED));
    always @(*) begin
        _zz_memory_DivPlugin_rs1_1[32] = (execute_IS_RS1_SIGNED && execute_RS1[31]);
        _zz_memory_DivPlugin_rs1_1[31 : 0] = execute_RS1;
    end

    always @(*) begin
        HazardSimplePlugin_src0Hazard = 1'b0;
        if (when_HazardSimplePlugin_l57) begin
            if (when_HazardSimplePlugin_l58) begin
                if (when_HazardSimplePlugin_l48) begin
                    HazardSimplePlugin_src0Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l57_1) begin
            if (when_HazardSimplePlugin_l58_1) begin
                if (when_HazardSimplePlugin_l48_1) begin
                    HazardSimplePlugin_src0Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l57_2) begin
            if (when_HazardSimplePlugin_l58_2) begin
                if (when_HazardSimplePlugin_l48_2) begin
                    HazardSimplePlugin_src0Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l105) begin
            HazardSimplePlugin_src0Hazard = 1'b0;
        end
    end

    always @(*) begin
        HazardSimplePlugin_src1Hazard = 1'b0;
        if (when_HazardSimplePlugin_l57) begin
            if (when_HazardSimplePlugin_l58) begin
                if (when_HazardSimplePlugin_l51) begin
                    HazardSimplePlugin_src1Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l57_1) begin
            if (when_HazardSimplePlugin_l58_1) begin
                if (when_HazardSimplePlugin_l51_1) begin
                    HazardSimplePlugin_src1Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l57_2) begin
            if (when_HazardSimplePlugin_l58_2) begin
                if (when_HazardSimplePlugin_l51_2) begin
                    HazardSimplePlugin_src1Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l108) begin
            HazardSimplePlugin_src1Hazard = 1'b0;
        end
    end

    assign HazardSimplePlugin_writeBackWrites_valid = (_zz_lastStageRegFileWrite_valid && writeBack_arbitration_isFiring);
    assign HazardSimplePlugin_writeBackWrites_payload_address = _zz_lastStageRegFileWrite_payload_address[11 : 7];
    assign HazardSimplePlugin_writeBackWrites_payload_data = _zz_decode_RS2_2;
    assign HazardSimplePlugin_addr0Match = (HazardSimplePlugin_writeBackBuffer_payload_address == decode_INSTRUCTION[19 : 15]);
    assign HazardSimplePlugin_addr1Match = (HazardSimplePlugin_writeBackBuffer_payload_address == decode_INSTRUCTION[24 : 20]);
    assign when_HazardSimplePlugin_l47 = 1'b1;
    assign when_HazardSimplePlugin_l48 = (writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
    assign when_HazardSimplePlugin_l51 = (writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
    assign when_HazardSimplePlugin_l45 = (writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l57 = (writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l58 = (1'b0 || (!when_HazardSimplePlugin_l47));
    assign when_HazardSimplePlugin_l48_1 = (memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
    assign when_HazardSimplePlugin_l51_1 = (memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
    assign when_HazardSimplePlugin_l45_1 = (memory_arbitration_isValid && memory_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l57_1 = (memory_arbitration_isValid && memory_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l58_1 = (1'b0 || (!memory_BYPASSABLE_MEMORY_STAGE));
    assign when_HazardSimplePlugin_l48_2 = (execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
    assign when_HazardSimplePlugin_l51_2 = (execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
    assign when_HazardSimplePlugin_l45_2 = (execute_arbitration_isValid && execute_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l57_2 = (execute_arbitration_isValid && execute_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l58_2 = (1'b0 || (!execute_BYPASSABLE_EXECUTE_STAGE));
    assign when_HazardSimplePlugin_l105 = (!decode_RS1_USE);
    assign when_HazardSimplePlugin_l108 = (!decode_RS2_USE);
    assign when_HazardSimplePlugin_l113 = (decode_arbitration_isValid && (HazardSimplePlugin_src0Hazard || HazardSimplePlugin_src1Hazard));
    assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
    assign switch_Misc_l241_1 = execute_INSTRUCTION[14 : 12];
    always @(*) begin
        case (switch_Misc_l241_1)
            3'b000: begin
                _zz_execute_BRANCH_COND_RESULT = execute_BranchPlugin_eq;
            end
            3'b001: begin
                _zz_execute_BRANCH_COND_RESULT = (!execute_BranchPlugin_eq);
            end
            3'b101: begin
                _zz_execute_BRANCH_COND_RESULT = (!execute_SRC_LESS);
            end
            3'b111: begin
                _zz_execute_BRANCH_COND_RESULT = (!execute_SRC_LESS);
            end
            default: begin
                _zz_execute_BRANCH_COND_RESULT = execute_SRC_LESS;
            end
        endcase
    end

    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: begin
                _zz_execute_BRANCH_COND_RESULT_1 = 1'b0;
            end
            BranchCtrlEnum_JAL: begin
                _zz_execute_BRANCH_COND_RESULT_1 = 1'b1;
            end
            BranchCtrlEnum_JALR: begin
                _zz_execute_BRANCH_COND_RESULT_1 = 1'b1;
            end
            default: begin
                _zz_execute_BRANCH_COND_RESULT_1 = _zz_execute_BRANCH_COND_RESULT;
            end
        endcase
    end

    assign _zz_execute_BranchPlugin_missAlignedTarget = execute_INSTRUCTION[31];
    always @(*) begin
        _zz_execute_BranchPlugin_missAlignedTarget_1[19] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[18] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[17] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[16] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[15] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[14] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[13] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[12] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[11] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[10] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[9] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[8] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[7] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[6] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[5] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[4] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[3] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[2] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[1] = _zz_execute_BranchPlugin_missAlignedTarget;
        _zz_execute_BranchPlugin_missAlignedTarget_1[0] = _zz_execute_BranchPlugin_missAlignedTarget;
    end

    assign _zz_execute_BranchPlugin_missAlignedTarget_2 = _zz__zz_execute_BranchPlugin_missAlignedTarget_2[19];
    always @(*) begin
        _zz_execute_BranchPlugin_missAlignedTarget_3[10] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[9] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[8] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[7] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[6] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[5] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[4] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[3] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[2] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[1] = _zz_execute_BranchPlugin_missAlignedTarget_2;
        _zz_execute_BranchPlugin_missAlignedTarget_3[0] = _zz_execute_BranchPlugin_missAlignedTarget_2;
    end

    assign _zz_execute_BranchPlugin_missAlignedTarget_4 = _zz__zz_execute_BranchPlugin_missAlignedTarget_4[11];
    always @(*) begin
        _zz_execute_BranchPlugin_missAlignedTarget_5[18] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[17] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[16] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[15] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[14] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[13] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[12] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[11] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[10] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[9] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[8] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[7] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[6] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[5] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[4] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[3] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[2] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[1] = _zz_execute_BranchPlugin_missAlignedTarget_4;
        _zz_execute_BranchPlugin_missAlignedTarget_5[0] = _zz_execute_BranchPlugin_missAlignedTarget_4;
    end

    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_JALR: begin
                _zz_execute_BranchPlugin_missAlignedTarget_6 = (_zz__zz_execute_BranchPlugin_missAlignedTarget_6[1] ^ execute_RS1[1]);
            end
            BranchCtrlEnum_JAL: begin
                _zz_execute_BranchPlugin_missAlignedTarget_6 = _zz__zz_execute_BranchPlugin_missAlignedTarget_6_1[1];
            end
            default: begin
                _zz_execute_BranchPlugin_missAlignedTarget_6 = _zz__zz_execute_BranchPlugin_missAlignedTarget_6_2[1];
            end
        endcase
    end

    assign execute_BranchPlugin_missAlignedTarget = (execute_BRANCH_COND_RESULT && _zz_execute_BranchPlugin_missAlignedTarget_6);
    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_JALR: begin
                execute_BranchPlugin_branch_src1 = execute_RS1;
            end
            default: begin
                execute_BranchPlugin_branch_src1 = execute_PC;
            end
        endcase
    end

    assign _zz_execute_BranchPlugin_branch_src2 = execute_INSTRUCTION[31];
    always @(*) begin
        _zz_execute_BranchPlugin_branch_src2_1[19] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[18] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[17] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[16] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[15] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[14] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[13] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[12] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[11] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[10] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[9]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[8]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[7]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[6]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[5]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[4]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[3]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[2]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[1]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[0]  = _zz_execute_BranchPlugin_branch_src2;
    end

    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_JALR: begin
                execute_BranchPlugin_branch_src2 = {
                    _zz_execute_BranchPlugin_branch_src2_1, execute_INSTRUCTION[31 : 20]
                };
            end
            default: begin
                execute_BranchPlugin_branch_src2 = ((execute_BRANCH_CTRL == BranchCtrlEnum_JAL) ? {{_zz_execute_BranchPlugin_branch_src2_3,{{{_zz_execute_BranchPlugin_branch_src2_6,_zz_execute_BranchPlugin_branch_src2_7},_zz_execute_BranchPlugin_branch_src2_8},execute_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_execute_BranchPlugin_branch_src2_5,{{{_zz_execute_BranchPlugin_branch_src2_9,_zz_execute_BranchPlugin_branch_src2_10},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0});
                if (execute_PREDICTION_HAD_BRANCHED1) begin
                    execute_BranchPlugin_branch_src2 = {
                        29'd0, _zz_execute_BranchPlugin_branch_src2_11
                    };
                end
            end
        endcase
    end

    assign _zz_execute_BranchPlugin_branch_src2_2 = _zz__zz_execute_BranchPlugin_branch_src2_2[19];
    always @(*) begin
        _zz_execute_BranchPlugin_branch_src2_3[10] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[9]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[8]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[7]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[6]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[5]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[4]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[3]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[2]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[1]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[0]  = _zz_execute_BranchPlugin_branch_src2_2;
    end

    assign _zz_execute_BranchPlugin_branch_src2_4 = _zz__zz_execute_BranchPlugin_branch_src2_4[11];
    always @(*) begin
        _zz_execute_BranchPlugin_branch_src2_5[18] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[17] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[16] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[15] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[14] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[13] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[12] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[11] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[10] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[9]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[8]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[7]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[6]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[5]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[4]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[3]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[2]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[1]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[0]  = _zz_execute_BranchPlugin_branch_src2_4;
    end

    assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
    assign BranchPlugin_jumpInterface_valid = ((memory_arbitration_isValid && memory_BRANCH_DO) && (! 1'b0));
    assign BranchPlugin_jumpInterface_payload = memory_BRANCH_CALC;
    assign BranchPlugin_branchExceptionPort_valid = (memory_arbitration_isValid && (memory_BRANCH_DO && memory_BRANCH_CALC[1]));
    assign BranchPlugin_branchExceptionPort_payload_code = 4'b0000;
    assign BranchPlugin_branchExceptionPort_payload_badAddr = memory_BRANCH_CALC;
    assign IBusCachedPlugin_decodePrediction_rsp_wasWrong = BranchPlugin_jumpInterface_valid;
    always @(*) begin
        CsrPlugin_privilege = 2'b11;
        if (CsrPlugin_forceMachineWire) begin
            CsrPlugin_privilege = 2'b11;
        end
    end

    assign CsrPlugin_misa_base = 2'b01;
    assign CsrPlugin_misa_extensions = 26'h0000042;
    assign CsrPlugin_mtvec_mode = 2'b00;
    assign _zz_when_CsrPlugin_l1302 = (CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE);
    assign _zz_when_CsrPlugin_l1302_1 = (CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE);
    assign _zz_when_CsrPlugin_l1302_2 = (CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE);
    assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped = 2'b11;
    assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege = ((CsrPlugin_privilege < CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped) ? CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped : CsrPlugin_privilege);
    assign _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code = {
        decodeExceptionPort_valid, IBusCachedPlugin_decodeExceptionPort_valid
    };
    assign _zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 = _zz__zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1[0];
    always @(*) begin
        CsrPlugin_exceptionPortCtrl_exceptionValids_decode = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
        if (_zz_when) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_decode = 1'b1;
        end
        if (decode_arbitration_isFlushed) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_decode = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_exceptionPortCtrl_exceptionValids_execute = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
        if (execute_arbitration_isFlushed) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_exceptionPortCtrl_exceptionValids_memory = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
        if (BranchPlugin_branchExceptionPort_valid) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b1;
        end
        if (memory_arbitration_isFlushed) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
        if (DBusCachedPlugin_exceptionBus_valid) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = 1'b1;
        end
        if (writeBack_arbitration_isFlushed) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = 1'b0;
        end
    end

    assign when_CsrPlugin_l1259 = (!decode_arbitration_isStuck);
    assign when_CsrPlugin_l1259_1 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1259_2 = (!memory_arbitration_isStuck);
    assign when_CsrPlugin_l1259_3 = (!writeBack_arbitration_isStuck);
    assign when_CsrPlugin_l1272 = (|{CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack, {
        CsrPlugin_exceptionPortCtrl_exceptionValids_memory,
        {
            CsrPlugin_exceptionPortCtrl_exceptionValids_execute,
            CsrPlugin_exceptionPortCtrl_exceptionValids_decode
        }
    }});
    assign CsrPlugin_exceptionPendings_0 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
    assign CsrPlugin_exceptionPendings_1 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    assign CsrPlugin_exceptionPendings_2 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
    assign CsrPlugin_exceptionPendings_3 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
    assign when_CsrPlugin_l1296 = (CsrPlugin_mstatus_MIE || (CsrPlugin_privilege < 2'b11));
    assign when_CsrPlugin_l1302 = ((_zz_when_CsrPlugin_l1302 && 1'b1) && (!1'b0));
    assign when_CsrPlugin_l1302_1 = ((_zz_when_CsrPlugin_l1302_1 && 1'b1) && (!1'b0));
    assign when_CsrPlugin_l1302_2 = ((_zz_when_CsrPlugin_l1302_2 && 1'b1) && (!1'b0));
    assign CsrPlugin_exception = (CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack && CsrPlugin_allowException);
    assign CsrPlugin_lastStageWasWfi = 1'b0;
    assign CsrPlugin_pipelineLiberator_active = ((CsrPlugin_interrupt_valid && CsrPlugin_allowInterrupts) && decode_arbitration_isValid);
    assign when_CsrPlugin_l1335 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1335_1 = (!memory_arbitration_isStuck);
    assign when_CsrPlugin_l1335_2 = (!writeBack_arbitration_isStuck);
    assign when_CsrPlugin_l1340 = ((! CsrPlugin_pipelineLiberator_active) || decode_arbitration_removeIt);
    always @(*) begin
        CsrPlugin_pipelineLiberator_done = CsrPlugin_pipelineLiberator_pcValids_2;
        if (when_CsrPlugin_l1346) begin
            CsrPlugin_pipelineLiberator_done = 1'b0;
        end
        if (CsrPlugin_hadException) begin
            CsrPlugin_pipelineLiberator_done = 1'b0;
        end
    end

    assign when_CsrPlugin_l1346 = (|{CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack, {
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory,
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute
    }});
    assign CsrPlugin_interruptJump = ((CsrPlugin_interrupt_valid && CsrPlugin_pipelineLiberator_done) && CsrPlugin_allowInterrupts);
    always @(*) begin
        CsrPlugin_targetPrivilege = CsrPlugin_interrupt_targetPrivilege;
        if (CsrPlugin_hadException) begin
            CsrPlugin_targetPrivilege = CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
        end
    end

    always @(*) begin
        CsrPlugin_trapCause = CsrPlugin_interrupt_code;
        if (CsrPlugin_hadException) begin
            CsrPlugin_trapCause = CsrPlugin_exceptionPortCtrl_exceptionContext_code;
        end
    end

    assign CsrPlugin_trapCauseEbreakDebug = 1'b0;
    always @(*) begin
        CsrPlugin_xtvec_mode = 2'bxx;
        case (CsrPlugin_targetPrivilege)
            2'b11: begin
                CsrPlugin_xtvec_mode = CsrPlugin_mtvec_mode;
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        CsrPlugin_xtvec_base = 30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        case (CsrPlugin_targetPrivilege)
            2'b11: begin
                CsrPlugin_xtvec_base = CsrPlugin_mtvec_base;
            end
            default: begin
            end
        endcase
    end

    assign CsrPlugin_trapEnterDebug = 1'b0;
    assign when_CsrPlugin_l1390 = (CsrPlugin_hadException || CsrPlugin_interruptJump);
    assign when_CsrPlugin_l1398 = (!CsrPlugin_trapEnterDebug);
    assign when_CsrPlugin_l1456 = (writeBack_arbitration_isValid && (writeBack_ENV_CTRL == EnvCtrlEnum_XRET));
    assign switch_CsrPlugin_l1460 = writeBack_INSTRUCTION[29 : 28];
    assign contextSwitching = CsrPlugin_jumpInterface_valid;
    assign when_CsrPlugin_l1527 = (|{(writeBack_arbitration_isValid && (writeBack_ENV_CTRL == EnvCtrlEnum_XRET)),{
        (memory_arbitration_isValid && (memory_ENV_CTRL == EnvCtrlEnum_XRET)),
        (execute_arbitration_isValid && (execute_ENV_CTRL == EnvCtrlEnum_XRET))
    }});
    assign execute_CsrPlugin_blockedBySideEffects = ((|{writeBack_arbitration_isValid,memory_arbitration_isValid}) || 1'b0);
    always @(*) begin
        execute_CsrPlugin_illegalAccess = 1'b1;
        if (execute_CsrPlugin_csr_768) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_836) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_772) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_773) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_833) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_834) begin
            if (execute_CSR_READ_OPCODE) begin
                execute_CsrPlugin_illegalAccess = 1'b0;
            end
        end
        if (execute_CsrPlugin_csr_835) begin
            if (execute_CSR_READ_OPCODE) begin
                execute_CsrPlugin_illegalAccess = 1'b0;
            end
        end
        if (CsrPlugin_csrMapping_allowCsrSignal) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (when_CsrPlugin_l1719) begin
            execute_CsrPlugin_illegalAccess = 1'b1;
        end
        if (when_CsrPlugin_l1725) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
    end

    always @(*) begin
        execute_CsrPlugin_illegalInstruction = 1'b0;
        if (when_CsrPlugin_l1547) begin
            if (when_CsrPlugin_l1548) begin
                execute_CsrPlugin_illegalInstruction = 1'b1;
            end
        end
    end

    assign when_CsrPlugin_l1547 = (execute_arbitration_isValid && (execute_ENV_CTRL == EnvCtrlEnum_XRET));
    assign when_CsrPlugin_l1548 = (CsrPlugin_privilege < execute_INSTRUCTION[29 : 28]);
    always @(*) begin
        execute_CsrPlugin_writeInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_WRITE_OPCODE);
        if (when_CsrPlugin_l1719) begin
            execute_CsrPlugin_writeInstruction = 1'b0;
        end
    end

    always @(*) begin
        execute_CsrPlugin_readInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_READ_OPCODE);
        if (when_CsrPlugin_l1719) begin
            execute_CsrPlugin_readInstruction = 1'b0;
        end
    end

    assign execute_CsrPlugin_writeEnable = (execute_CsrPlugin_writeInstruction && (! execute_arbitration_isStuck));
    assign execute_CsrPlugin_readEnable = (execute_CsrPlugin_readInstruction && (! execute_arbitration_isStuck));
    assign CsrPlugin_csrMapping_hazardFree = (!execute_CsrPlugin_blockedBySideEffects);
    assign execute_CsrPlugin_readToWriteData = CsrPlugin_csrMapping_readDataSignal;
    assign switch_Misc_l241_2 = execute_INSTRUCTION[13];
    always @(*) begin
        case (switch_Misc_l241_2)
            1'b0: begin
                _zz_CsrPlugin_csrMapping_writeDataSignal = execute_SRC1;
            end
            default: begin
                _zz_CsrPlugin_csrMapping_writeDataSignal = (execute_INSTRUCTION[12] ? (execute_CsrPlugin_readToWriteData & (~ execute_SRC1)) : (execute_CsrPlugin_readToWriteData | execute_SRC1));
            end
        endcase
    end

    assign CsrPlugin_csrMapping_writeDataSignal = _zz_CsrPlugin_csrMapping_writeDataSignal;
    assign when_CsrPlugin_l1587 = (execute_arbitration_isValid && execute_IS_CSR);
    assign when_CsrPlugin_l1591 = (execute_arbitration_isValid && (execute_IS_CSR || 1'b0));
    assign execute_CsrPlugin_csrAddress = execute_INSTRUCTION[31 : 20];
    assign when_DebugPlugin_l238 = (DebugPlugin_haltIt && (!DebugPlugin_isPipBusy));
    assign DebugPlugin_allowEBreak = (DebugPlugin_debugUsed && (!DebugPlugin_disableEbreak));
    always @(*) begin
        debug_bus_cmd_ready = 1'b1;
        if (debug_bus_cmd_valid) begin
            case (switch_DebugPlugin_l280)
                6'h01: begin
                    if (debug_bus_cmd_payload_wr) begin
                        debug_bus_cmd_ready = DebugPlugin_injectionPort_ready;
                    end
                end
                default: begin
                end
            endcase
        end
    end

    always @(*) begin
        debug_bus_rsp_data = DebugPlugin_busReadDataReg;
        if (when_DebugPlugin_l257) begin
            debug_bus_rsp_data[0] = DebugPlugin_resetIt;
            debug_bus_rsp_data[1] = DebugPlugin_haltIt;
            debug_bus_rsp_data[2] = DebugPlugin_isPipBusy;
            debug_bus_rsp_data[3] = DebugPlugin_haltedByBreak;
            debug_bus_rsp_data[4] = DebugPlugin_stepIt;
        end
    end

    assign when_DebugPlugin_l257 = (!_zz_when_DebugPlugin_l257);
    always @(*) begin
        DebugPlugin_injectionPort_valid = 1'b0;
        if (debug_bus_cmd_valid) begin
            case (switch_DebugPlugin_l280)
                6'h01: begin
                    if (debug_bus_cmd_payload_wr) begin
                        DebugPlugin_injectionPort_valid = 1'b1;
                    end
                end
                default: begin
                end
            endcase
        end
    end

    assign DebugPlugin_injectionPort_payload = debug_bus_cmd_payload_data;
    assign switch_DebugPlugin_l280 = debug_bus_cmd_payload_address[7 : 2];
    assign when_DebugPlugin_l284 = debug_bus_cmd_payload_data[16];
    assign when_DebugPlugin_l284_1 = debug_bus_cmd_payload_data[24];
    assign when_DebugPlugin_l285 = debug_bus_cmd_payload_data[17];
    assign when_DebugPlugin_l285_1 = debug_bus_cmd_payload_data[25];
    assign when_DebugPlugin_l286 = debug_bus_cmd_payload_data[25];
    assign when_DebugPlugin_l287 = debug_bus_cmd_payload_data[25];
    assign when_DebugPlugin_l288 = debug_bus_cmd_payload_data[18];
    assign when_DebugPlugin_l288_1 = debug_bus_cmd_payload_data[26];
    assign when_DebugPlugin_l308 = (execute_arbitration_isValid && execute_DO_EBREAK);
    assign when_DebugPlugin_l311 = ((|{writeBack_arbitration_isValid,memory_arbitration_isValid}) == 1'b0);
    assign when_DebugPlugin_l324 = (DebugPlugin_stepIt && IBusCachedPlugin_incomingInstruction);
    assign debug_resetOut = DebugPlugin_resetIt_regNext;
    assign when_DebugPlugin_l344 = (DebugPlugin_haltIt || DebugPlugin_stepIt);
    assign when_Pipeline_l124 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_1 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_2 = ((! writeBack_arbitration_isStuck) && (! CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack));
    assign when_Pipeline_l124_3 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_4 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_5 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_6 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_7 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_8 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_9 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_SRC1_CTRL_1 = decode_SRC1_CTRL;
    assign _zz_decode_SRC1_CTRL = _zz_decode_SRC1_CTRL_1;
    assign when_Pipeline_l124_10 = (!execute_arbitration_isStuck);
    assign _zz_execute_SRC1_CTRL = decode_to_execute_SRC1_CTRL;
    assign when_Pipeline_l124_11 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_12 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_13 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_14 = (!writeBack_arbitration_isStuck);
    assign _zz_decode_to_execute_ALU_CTRL_1 = decode_ALU_CTRL;
    assign _zz_decode_ALU_CTRL = _zz_decode_ALU_CTRL_1;
    assign when_Pipeline_l124_15 = (!execute_arbitration_isStuck);
    assign _zz_execute_ALU_CTRL = decode_to_execute_ALU_CTRL;
    assign _zz_decode_to_execute_SRC2_CTRL_1 = decode_SRC2_CTRL;
    assign _zz_decode_SRC2_CTRL = _zz_decode_SRC2_CTRL_1;
    assign when_Pipeline_l124_16 = (!execute_arbitration_isStuck);
    assign _zz_execute_SRC2_CTRL = decode_to_execute_SRC2_CTRL;
    assign when_Pipeline_l124_17 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_18 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_19 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_20 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_21 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_22 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_23 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_24 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_25 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_26 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_27 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_ALU_BITWISE_CTRL_1 = decode_ALU_BITWISE_CTRL;
    assign _zz_decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL_1;
    assign when_Pipeline_l124_28 = (!execute_arbitration_isStuck);
    assign _zz_execute_ALU_BITWISE_CTRL = decode_to_execute_ALU_BITWISE_CTRL;
    assign _zz_decode_to_execute_SHIFT_CTRL_1 = decode_SHIFT_CTRL;
    assign _zz_execute_to_memory_SHIFT_CTRL_1 = execute_SHIFT_CTRL;
    assign _zz_decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL_1;
    assign when_Pipeline_l124_29 = (!execute_arbitration_isStuck);
    assign _zz_execute_SHIFT_CTRL = decode_to_execute_SHIFT_CTRL;
    assign when_Pipeline_l124_30 = (!memory_arbitration_isStuck);
    assign _zz_memory_SHIFT_CTRL = execute_to_memory_SHIFT_CTRL;
    assign when_Pipeline_l124_31 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_32 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_33 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_34 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_35 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_36 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_37 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_BRANCH_CTRL_1 = decode_BRANCH_CTRL;
    assign _zz_decode_BRANCH_CTRL_1 = _zz_decode_BRANCH_CTRL;
    assign when_Pipeline_l124_38 = (!execute_arbitration_isStuck);
    assign _zz_execute_BRANCH_CTRL = decode_to_execute_BRANCH_CTRL;
    assign when_Pipeline_l124_39 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_ENV_CTRL_1 = decode_ENV_CTRL;
    assign _zz_execute_to_memory_ENV_CTRL_1 = execute_ENV_CTRL;
    assign _zz_memory_to_writeBack_ENV_CTRL_1 = memory_ENV_CTRL;
    assign _zz_decode_ENV_CTRL = _zz_decode_ENV_CTRL_1;
    assign when_Pipeline_l124_40 = (!execute_arbitration_isStuck);
    assign _zz_execute_ENV_CTRL = decode_to_execute_ENV_CTRL;
    assign when_Pipeline_l124_41 = (!memory_arbitration_isStuck);
    assign _zz_memory_ENV_CTRL = execute_to_memory_ENV_CTRL;
    assign when_Pipeline_l124_42 = (!writeBack_arbitration_isStuck);
    assign _zz_writeBack_ENV_CTRL = memory_to_writeBack_ENV_CTRL;
    assign when_Pipeline_l124_43 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_44 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_45 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_46 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_47 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_48 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_49 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_50 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_51 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_52 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_53 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_54 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_55 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_56 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_57 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_58 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_59 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_60 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_61 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_62 = (!writeBack_arbitration_isStuck);
    assign decode_arbitration_isFlushed = ((|{writeBack_arbitration_flushNext,{memory_arbitration_flushNext,execute_arbitration_flushNext}}) || (|{writeBack_arbitration_flushIt,{memory_arbitration_flushIt,{execute_arbitration_flushIt,decode_arbitration_flushIt}}}));
    assign execute_arbitration_isFlushed = ((|{writeBack_arbitration_flushNext,memory_arbitration_flushNext}) || (|{writeBack_arbitration_flushIt,{memory_arbitration_flushIt,execute_arbitration_flushIt}}));
    assign memory_arbitration_isFlushed = ((|writeBack_arbitration_flushNext) || (|{writeBack_arbitration_flushIt,memory_arbitration_flushIt}));
    assign writeBack_arbitration_isFlushed = (1'b0 || (|writeBack_arbitration_flushIt));
    assign decode_arbitration_isStuckByOthers = (decode_arbitration_haltByOther || (((1'b0 || execute_arbitration_isStuck) || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
    assign decode_arbitration_isStuck = (decode_arbitration_haltItself || decode_arbitration_isStuckByOthers);
    assign decode_arbitration_isMoving = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
    assign decode_arbitration_isFiring = ((decode_arbitration_isValid && (! decode_arbitration_isStuck)) && (! decode_arbitration_removeIt));
    assign execute_arbitration_isStuckByOthers = (execute_arbitration_haltByOther || ((1'b0 || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
    assign execute_arbitration_isStuck = (execute_arbitration_haltItself || execute_arbitration_isStuckByOthers);
    assign execute_arbitration_isMoving = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
    assign execute_arbitration_isFiring = ((execute_arbitration_isValid && (! execute_arbitration_isStuck)) && (! execute_arbitration_removeIt));
    assign memory_arbitration_isStuckByOthers = (memory_arbitration_haltByOther || (1'b0 || writeBack_arbitration_isStuck));
    assign memory_arbitration_isStuck = (memory_arbitration_haltItself || memory_arbitration_isStuckByOthers);
    assign memory_arbitration_isMoving = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
    assign memory_arbitration_isFiring = ((memory_arbitration_isValid && (! memory_arbitration_isStuck)) && (! memory_arbitration_removeIt));
    assign writeBack_arbitration_isStuckByOthers = (writeBack_arbitration_haltByOther || 1'b0);
    assign writeBack_arbitration_isStuck = (writeBack_arbitration_haltItself || writeBack_arbitration_isStuckByOthers);
    assign writeBack_arbitration_isMoving = ((! writeBack_arbitration_isStuck) && (! writeBack_arbitration_removeIt));
    assign writeBack_arbitration_isFiring = ((writeBack_arbitration_isValid && (! writeBack_arbitration_isStuck)) && (! writeBack_arbitration_removeIt));
    assign when_Pipeline_l151 = ((!execute_arbitration_isStuck) || execute_arbitration_removeIt);
    assign when_Pipeline_l154 = ((!decode_arbitration_isStuck) && (!decode_arbitration_removeIt));
    assign when_Pipeline_l151_1 = ((!memory_arbitration_isStuck) || memory_arbitration_removeIt);
    assign when_Pipeline_l154_1 = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
    assign when_Pipeline_l151_2 = ((! writeBack_arbitration_isStuck) || writeBack_arbitration_removeIt);
    assign when_Pipeline_l154_2 = ((!memory_arbitration_isStuck) && (!memory_arbitration_removeIt));
    always @(*) begin
        DebugPlugin_injectionPort_ready = 1'b0;
        case (IBusCachedPlugin_injector_port_state)
            3'b100: begin
                DebugPlugin_injectionPort_ready = 1'b1;
            end
            default: begin
            end
        endcase
    end

    assign when_Fetcher_l391 = (!decode_arbitration_isStuck);
    assign when_CsrPlugin_l1669 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_1 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_2 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_3 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_4 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_5 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_6 = (!execute_arbitration_isStuck);
    assign switch_CsrPlugin_l1031 = CsrPlugin_csrMapping_writeDataSignal[12 : 11];
    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit = 32'h0;
        if (execute_CsrPlugin_csr_768) begin
            _zz_CsrPlugin_csrMapping_readDataInit[7 : 7]   = CsrPlugin_mstatus_MPIE;
            _zz_CsrPlugin_csrMapping_readDataInit[3 : 3]   = CsrPlugin_mstatus_MIE;
            _zz_CsrPlugin_csrMapping_readDataInit[12 : 11] = CsrPlugin_mstatus_MPP;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_1 = 32'h0;
        if (execute_CsrPlugin_csr_836) begin
            _zz_CsrPlugin_csrMapping_readDataInit_1[11 : 11] = CsrPlugin_mip_MEIP;
            _zz_CsrPlugin_csrMapping_readDataInit_1[7 : 7]   = CsrPlugin_mip_MTIP;
            _zz_CsrPlugin_csrMapping_readDataInit_1[3 : 3]   = CsrPlugin_mip_MSIP;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_2 = 32'h0;
        if (execute_CsrPlugin_csr_772) begin
            _zz_CsrPlugin_csrMapping_readDataInit_2[11 : 11] = CsrPlugin_mie_MEIE;
            _zz_CsrPlugin_csrMapping_readDataInit_2[7 : 7]   = CsrPlugin_mie_MTIE;
            _zz_CsrPlugin_csrMapping_readDataInit_2[3 : 3]   = CsrPlugin_mie_MSIE;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_3 = 32'h0;
        if (execute_CsrPlugin_csr_773) begin
            _zz_CsrPlugin_csrMapping_readDataInit_3[31 : 2] = CsrPlugin_mtvec_base;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_4 = 32'h0;
        if (execute_CsrPlugin_csr_833) begin
            _zz_CsrPlugin_csrMapping_readDataInit_4[31 : 0] = CsrPlugin_mepc;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_5 = 32'h0;
        if (execute_CsrPlugin_csr_834) begin
            _zz_CsrPlugin_csrMapping_readDataInit_5[31 : 31] = CsrPlugin_mcause_interrupt;
            _zz_CsrPlugin_csrMapping_readDataInit_5[3 : 0]   = CsrPlugin_mcause_exceptionCode;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_6 = 32'h0;
        if (execute_CsrPlugin_csr_835) begin
            _zz_CsrPlugin_csrMapping_readDataInit_6[31 : 0] = CsrPlugin_mtval;
        end
    end

    assign CsrPlugin_csrMapping_readDataInit = (((_zz_CsrPlugin_csrMapping_readDataInit | _zz_CsrPlugin_csrMapping_readDataInit_1) | (_zz_CsrPlugin_csrMapping_readDataInit_2 | _zz_CsrPlugin_csrMapping_readDataInit_3)) | ((_zz_CsrPlugin_csrMapping_readDataInit_4 | _zz_CsrPlugin_csrMapping_readDataInit_5) | _zz_CsrPlugin_csrMapping_readDataInit_6));
    assign when_CsrPlugin_l1702 = ((execute_arbitration_isValid && execute_IS_CSR) && (({execute_CsrPlugin_csrAddress[11 : 2],2'b00} == 12'h3a0) || ({execute_CsrPlugin_csrAddress[11 : 4],4'b0000} == 12'h3b0)));
    assign _zz_when_CsrPlugin_l1709 = (execute_CsrPlugin_csrAddress & 12'hf60);
    assign when_CsrPlugin_l1709 = (((execute_arbitration_isValid && execute_IS_CSR) && (5'h03 <= execute_CsrPlugin_csrAddress[4 : 0])) && (((_zz_when_CsrPlugin_l1709 == 12'hb00) || (((_zz_when_CsrPlugin_l1709 == 12'hc00) && (! execute_CsrPlugin_writeInstruction)) && (CsrPlugin_privilege == 2'b11))) || ((execute_CsrPlugin_csrAddress & 12'hfe0) == 12'h320)));
    always @(*) begin
        when_CsrPlugin_l1719 = CsrPlugin_csrMapping_doForceFailCsr;
        if (when_CsrPlugin_l1717) begin
            when_CsrPlugin_l1719 = 1'b1;
        end
    end

    assign when_CsrPlugin_l1717 = (CsrPlugin_privilege < execute_CsrPlugin_csrAddress[9 : 8]);
    assign when_CsrPlugin_l1725 = ((!execute_arbitration_isValid) || (!execute_IS_CSR));
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            IBusCachedPlugin_fetchPc_pcReg <= 32'h80000000;
            IBusCachedPlugin_fetchPc_correctionReg <= 1'b0;
            IBusCachedPlugin_fetchPc_booted <= 1'b0;
            IBusCachedPlugin_fetchPc_inc <= 1'b0;
            _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1 <= 1'b0;
            _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= 1'b0;
            IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b0;
            IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            IBusCachedPlugin_rspCounter <= 32'h0;
            DBusCachedPlugin_rspCounter <= 32'h0;
            _zz_10 <= 1'b1;
            memory_DivPlugin_div_counter_value <= 6'h0;
            HazardSimplePlugin_writeBackBuffer_valid <= 1'b0;
            CsrPlugin_mtvec_base <= 30'h20000008;
            CsrPlugin_mstatus_MIE <= 1'b0;
            CsrPlugin_mstatus_MPIE <= 1'b0;
            CsrPlugin_mstatus_MPP <= 2'b11;
            CsrPlugin_mie_MEIE <= 1'b0;
            CsrPlugin_mie_MTIE <= 1'b0;
            CsrPlugin_mie_MSIE <= 1'b0;
            CsrPlugin_mcycle <= 64'h0;
            CsrPlugin_minstret <= 64'h0;
            CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= 1'b0;
            CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
            CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= 1'b0;
            CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
            CsrPlugin_interrupt_valid <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_1 <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_2 <= 1'b0;
            CsrPlugin_hadException <= 1'b0;
            execute_CsrPlugin_wfiWake <= 1'b0;
            execute_arbitration_isValid <= 1'b0;
            memory_arbitration_isValid <= 1'b0;
            writeBack_arbitration_isValid <= 1'b0;
            IBusCachedPlugin_injector_port_state <= 3'b000;
        end else begin
            if (IBusCachedPlugin_fetchPc_correction) begin
                IBusCachedPlugin_fetchPc_correctionReg <= 1'b1;
            end
            if (IBusCachedPlugin_fetchPc_output_fire) begin
                IBusCachedPlugin_fetchPc_correctionReg <= 1'b0;
            end
            IBusCachedPlugin_fetchPc_booted <= 1'b1;
            if (when_Fetcher_l133) begin
                IBusCachedPlugin_fetchPc_inc <= 1'b0;
            end
            if (IBusCachedPlugin_fetchPc_output_fire) begin
                IBusCachedPlugin_fetchPc_inc <= 1'b1;
            end
            if (when_Fetcher_l133_1) begin
                IBusCachedPlugin_fetchPc_inc <= 1'b0;
            end
            if (when_Fetcher_l160) begin
                IBusCachedPlugin_fetchPc_pcReg <= IBusCachedPlugin_fetchPc_pc;
            end
            if (IBusCachedPlugin_iBusRsp_flush) begin
                _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1 <= 1'b0;
            end
            if (_zz_IBusCachedPlugin_iBusRsp_stages_0_output_ready) begin
                _zz_IBusCachedPlugin_iBusRsp_stages_1_input_valid_1 <= (IBusCachedPlugin_iBusRsp_stages_0_output_valid && (! 1'b0));
            end
            if (IBusCachedPlugin_iBusRsp_flush) begin
                _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= 1'b0;
            end
            if (IBusCachedPlugin_iBusRsp_stages_1_output_ready) begin
                _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_valid <= (IBusCachedPlugin_iBusRsp_stages_1_output_valid && (! IBusCachedPlugin_iBusRsp_flush));
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b0;
            end
            if (when_Fetcher_l331) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_0 <= 1'b1;
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            end
            if (when_Fetcher_l331_1) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_1 <= IBusCachedPlugin_injector_nextPcCalc_valids_0;
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            end
            if (when_Fetcher_l331_2) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_2 <= IBusCachedPlugin_injector_nextPcCalc_valids_1;
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            end
            if (when_Fetcher_l331_3) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_3 <= IBusCachedPlugin_injector_nextPcCalc_valids_2;
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            end
            if (when_Fetcher_l331_4) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_4 <= IBusCachedPlugin_injector_nextPcCalc_valids_3;
            end
            if (IBusCachedPlugin_fetchPc_flushed) begin
                IBusCachedPlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            end
            if (iBus_rsp_valid) begin
                IBusCachedPlugin_rspCounter <= (IBusCachedPlugin_rspCounter + 32'h00000001);
            end
            if (dBus_rsp_valid) begin
                DBusCachedPlugin_rspCounter <= (DBusCachedPlugin_rspCounter + 32'h00000001);
            end
            _zz_10 <= 1'b0;
            memory_DivPlugin_div_counter_value <= memory_DivPlugin_div_counter_valueNext;
            HazardSimplePlugin_writeBackBuffer_valid <= HazardSimplePlugin_writeBackWrites_valid;
            CsrPlugin_mcycle <= (CsrPlugin_mcycle + 64'h0000000000000001);
            if (writeBack_arbitration_isFiring) begin
                CsrPlugin_minstret <= (CsrPlugin_minstret + 64'h0000000000000001);
            end
            if (when_CsrPlugin_l1259) begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= 1'b0;
            end else begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode <= CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
            end
            if (when_CsrPlugin_l1259_1) begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= (CsrPlugin_exceptionPortCtrl_exceptionValids_decode && (! decode_arbitration_isStuck));
            end else begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
            end
            if (when_CsrPlugin_l1259_2) begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= (CsrPlugin_exceptionPortCtrl_exceptionValids_execute && (! execute_arbitration_isStuck));
            end else begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
            end
            if (when_CsrPlugin_l1259_3) begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= (CsrPlugin_exceptionPortCtrl_exceptionValids_memory && (! memory_arbitration_isStuck));
            end else begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
            end
            CsrPlugin_interrupt_valid <= 1'b0;
            if (when_CsrPlugin_l1296) begin
                if (when_CsrPlugin_l1302) begin
                    CsrPlugin_interrupt_valid <= 1'b1;
                end
                if (when_CsrPlugin_l1302_1) begin
                    CsrPlugin_interrupt_valid <= 1'b1;
                end
                if (when_CsrPlugin_l1302_2) begin
                    CsrPlugin_interrupt_valid <= 1'b1;
                end
            end
            if (CsrPlugin_pipelineLiberator_active) begin
                if (when_CsrPlugin_l1335) begin
                    CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b1;
                end
                if (when_CsrPlugin_l1335_1) begin
                    CsrPlugin_pipelineLiberator_pcValids_1 <= CsrPlugin_pipelineLiberator_pcValids_0;
                end
                if (when_CsrPlugin_l1335_2) begin
                    CsrPlugin_pipelineLiberator_pcValids_2 <= CsrPlugin_pipelineLiberator_pcValids_1;
                end
            end
            if (when_CsrPlugin_l1340) begin
                CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b0;
                CsrPlugin_pipelineLiberator_pcValids_1 <= 1'b0;
                CsrPlugin_pipelineLiberator_pcValids_2 <= 1'b0;
            end
            if (CsrPlugin_interruptJump) begin
                CsrPlugin_interrupt_valid <= 1'b0;
            end
            CsrPlugin_hadException <= CsrPlugin_exception;
            if (when_CsrPlugin_l1390) begin
                if (when_CsrPlugin_l1398) begin
                    case (CsrPlugin_targetPrivilege)
                        2'b11: begin
                            CsrPlugin_mstatus_MIE  <= 1'b0;
                            CsrPlugin_mstatus_MPIE <= CsrPlugin_mstatus_MIE;
                            CsrPlugin_mstatus_MPP  <= CsrPlugin_privilege;
                        end
                        default: begin
                        end
                    endcase
                end
            end
            if (when_CsrPlugin_l1456) begin
                case (switch_CsrPlugin_l1460)
                    2'b11: begin
                        CsrPlugin_mstatus_MPP  <= 2'b00;
                        CsrPlugin_mstatus_MIE  <= CsrPlugin_mstatus_MPIE;
                        CsrPlugin_mstatus_MPIE <= 1'b1;
                    end
                    default: begin
                    end
                endcase
            end
            execute_CsrPlugin_wfiWake <= ((|{_zz_when_CsrPlugin_l1302_2,{_zz_when_CsrPlugin_l1302_1,_zz_when_CsrPlugin_l1302}}) || CsrPlugin_thirdPartyWake);
            if (when_Pipeline_l151) begin
                execute_arbitration_isValid <= 1'b0;
            end
            if (when_Pipeline_l154) begin
                execute_arbitration_isValid <= decode_arbitration_isValid;
            end
            if (when_Pipeline_l151_1) begin
                memory_arbitration_isValid <= 1'b0;
            end
            if (when_Pipeline_l154_1) begin
                memory_arbitration_isValid <= execute_arbitration_isValid;
            end
            if (when_Pipeline_l151_2) begin
                writeBack_arbitration_isValid <= 1'b0;
            end
            if (when_Pipeline_l154_2) begin
                writeBack_arbitration_isValid <= memory_arbitration_isValid;
            end
            case (IBusCachedPlugin_injector_port_state)
                3'b000: begin
                    if (DebugPlugin_injectionPort_valid) begin
                        IBusCachedPlugin_injector_port_state <= 3'b001;
                    end
                end
                3'b001: begin
                    IBusCachedPlugin_injector_port_state <= 3'b010;
                end
                3'b010: begin
                    IBusCachedPlugin_injector_port_state <= 3'b011;
                end
                3'b011: begin
                    if (when_Fetcher_l391) begin
                        IBusCachedPlugin_injector_port_state <= 3'b100;
                    end
                end
                3'b100: begin
                    IBusCachedPlugin_injector_port_state <= 3'b000;
                end
                default: begin
                end
            endcase
            if (execute_CsrPlugin_csr_768) begin
                if (execute_CsrPlugin_writeEnable) begin
                    CsrPlugin_mstatus_MPIE <= CsrPlugin_csrMapping_writeDataSignal[7];
                    CsrPlugin_mstatus_MIE  <= CsrPlugin_csrMapping_writeDataSignal[3];
                    case (switch_CsrPlugin_l1031)
                        2'b11: begin
                            CsrPlugin_mstatus_MPP <= 2'b11;
                        end
                        default: begin
                        end
                    endcase
                end
            end
            if (execute_CsrPlugin_csr_772) begin
                if (execute_CsrPlugin_writeEnable) begin
                    CsrPlugin_mie_MEIE <= CsrPlugin_csrMapping_writeDataSignal[11];
                    CsrPlugin_mie_MTIE <= CsrPlugin_csrMapping_writeDataSignal[7];
                    CsrPlugin_mie_MSIE <= CsrPlugin_csrMapping_writeDataSignal[3];
                end
            end
            if (execute_CsrPlugin_csr_773) begin
                if (execute_CsrPlugin_writeEnable) begin
                    CsrPlugin_mtvec_base <= CsrPlugin_csrMapping_writeDataSignal[31 : 2];
                end
            end
        end
    end

    always @(posedge io_axiClk) begin
        if (IBusCachedPlugin_iBusRsp_stages_1_output_ready) begin
            _zz_IBusCachedPlugin_iBusRsp_stages_1_output_m2sPipe_payload <= IBusCachedPlugin_iBusRsp_stages_1_output_payload;
        end
        if (IBusCachedPlugin_iBusRsp_stages_1_input_ready) begin
            IBusCachedPlugin_s1_tightlyCoupledHit <= IBusCachedPlugin_s0_tightlyCoupledHit;
        end
        if (IBusCachedPlugin_iBusRsp_stages_2_input_ready) begin
            IBusCachedPlugin_s2_tightlyCoupledHit <= IBusCachedPlugin_s1_tightlyCoupledHit;
        end
        if (when_MulDivIterativePlugin_l126) begin
            memory_DivPlugin_div_done <= 1'b1;
        end
        if (when_MulDivIterativePlugin_l126_1) begin
            memory_DivPlugin_div_done <= 1'b0;
        end
        if (when_MulDivIterativePlugin_l128) begin
            if (when_MulDivIterativePlugin_l132) begin
                memory_DivPlugin_rs1[31 : 0] <= memory_DivPlugin_div_stage_0_outNumerator;
                memory_DivPlugin_accumulator[31 : 0] <= memory_DivPlugin_div_stage_0_outRemainder;
                if (when_MulDivIterativePlugin_l151) begin
                    memory_DivPlugin_div_result <= _zz_memory_DivPlugin_div_result_1[31:0];
                end
            end
        end
        if (when_MulDivIterativePlugin_l162) begin
            memory_DivPlugin_accumulator <= 65'h0;
            memory_DivPlugin_rs1 <= ((_zz_memory_DivPlugin_rs1 ? (~ _zz_memory_DivPlugin_rs1_1) : _zz_memory_DivPlugin_rs1_1) + _zz_memory_DivPlugin_rs1_2);
            memory_DivPlugin_rs2 <= ((_zz_memory_DivPlugin_rs2 ? (~ execute_RS2) : execute_RS2) + _zz_memory_DivPlugin_rs2_1);
            memory_DivPlugin_div_needRevert <= ((_zz_memory_DivPlugin_rs1 ^ (_zz_memory_DivPlugin_rs2 && (! execute_INSTRUCTION[13]))) && (! (((execute_RS2 == 32'h0) && execute_IS_RS2_SIGNED) && (! execute_INSTRUCTION[13]))));
        end
        HazardSimplePlugin_writeBackBuffer_payload_address <= HazardSimplePlugin_writeBackWrites_payload_address;
        HazardSimplePlugin_writeBackBuffer_payload_data <= HazardSimplePlugin_writeBackWrites_payload_data;
        CsrPlugin_mip_MEIP <= externalInterrupt;
        CsrPlugin_mip_MTIP <= timerInterrupt;
        CsrPlugin_mip_MSIP <= softwareInterrupt;
        if (_zz_when) begin
            CsrPlugin_exceptionPortCtrl_exceptionContext_code <= (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 ? IBusCachedPlugin_decodeExceptionPort_payload_code : decodeExceptionPort_payload_code);
            CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= (_zz_CsrPlugin_exceptionPortCtrl_exceptionContext_code_1 ? IBusCachedPlugin_decodeExceptionPort_payload_badAddr : decodeExceptionPort_payload_badAddr);
        end
        if (BranchPlugin_branchExceptionPort_valid) begin
            CsrPlugin_exceptionPortCtrl_exceptionContext_code <= BranchPlugin_branchExceptionPort_payload_code;
            CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= BranchPlugin_branchExceptionPort_payload_badAddr;
        end
        if (DBusCachedPlugin_exceptionBus_valid) begin
            CsrPlugin_exceptionPortCtrl_exceptionContext_code <= DBusCachedPlugin_exceptionBus_payload_code;
            CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= DBusCachedPlugin_exceptionBus_payload_badAddr;
        end
        if (when_CsrPlugin_l1296) begin
            if (when_CsrPlugin_l1302) begin
                CsrPlugin_interrupt_code <= 4'b0111;
                CsrPlugin_interrupt_targetPrivilege <= 2'b11;
            end
            if (when_CsrPlugin_l1302_1) begin
                CsrPlugin_interrupt_code <= 4'b0011;
                CsrPlugin_interrupt_targetPrivilege <= 2'b11;
            end
            if (when_CsrPlugin_l1302_2) begin
                CsrPlugin_interrupt_code <= 4'b1011;
                CsrPlugin_interrupt_targetPrivilege <= 2'b11;
            end
        end
        if (when_CsrPlugin_l1390) begin
            if (when_CsrPlugin_l1398) begin
                case (CsrPlugin_targetPrivilege)
                    2'b11: begin
                        CsrPlugin_mcause_interrupt <= (!CsrPlugin_hadException);
                        CsrPlugin_mcause_exceptionCode <= CsrPlugin_trapCause;
                        CsrPlugin_mepc <= writeBack_PC;
                        if (CsrPlugin_hadException) begin
                            CsrPlugin_mtval <= CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
                        end
                    end
                    default: begin
                    end
                endcase
            end
        end
        if (when_Pipeline_l124) begin
            decode_to_execute_PC <= decode_PC;
        end
        if (when_Pipeline_l124_1) begin
            execute_to_memory_PC <= _zz_execute_to_memory_PC;
        end
        if (when_Pipeline_l124_2) begin
            memory_to_writeBack_PC <= memory_PC;
        end
        if (when_Pipeline_l124_3) begin
            decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
        end
        if (when_Pipeline_l124_4) begin
            execute_to_memory_INSTRUCTION <= execute_INSTRUCTION;
        end
        if (when_Pipeline_l124_5) begin
            memory_to_writeBack_INSTRUCTION <= memory_INSTRUCTION;
        end
        if (when_Pipeline_l124_6) begin
            decode_to_execute_FORMAL_PC_NEXT <= _zz_decode_to_execute_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_7) begin
            execute_to_memory_FORMAL_PC_NEXT <= execute_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_8) begin
            memory_to_writeBack_FORMAL_PC_NEXT <= _zz_memory_to_writeBack_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_9) begin
            decode_to_execute_MEMORY_FORCE_CONSTISTENCY <= decode_MEMORY_FORCE_CONSTISTENCY;
        end
        if (when_Pipeline_l124_10) begin
            decode_to_execute_SRC1_CTRL <= _zz_decode_to_execute_SRC1_CTRL;
        end
        if (when_Pipeline_l124_11) begin
            decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
        end
        if (when_Pipeline_l124_12) begin
            decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
        end
        if (when_Pipeline_l124_13) begin
            execute_to_memory_MEMORY_ENABLE <= execute_MEMORY_ENABLE;
        end
        if (when_Pipeline_l124_14) begin
            memory_to_writeBack_MEMORY_ENABLE <= memory_MEMORY_ENABLE;
        end
        if (when_Pipeline_l124_15) begin
            decode_to_execute_ALU_CTRL <= _zz_decode_to_execute_ALU_CTRL;
        end
        if (when_Pipeline_l124_16) begin
            decode_to_execute_SRC2_CTRL <= _zz_decode_to_execute_SRC2_CTRL;
        end
        if (when_Pipeline_l124_17) begin
            decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_18) begin
            execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_19) begin
            memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_20) begin
            decode_to_execute_BYPASSABLE_EXECUTE_STAGE <= decode_BYPASSABLE_EXECUTE_STAGE;
        end
        if (when_Pipeline_l124_21) begin
            decode_to_execute_BYPASSABLE_MEMORY_STAGE <= decode_BYPASSABLE_MEMORY_STAGE;
        end
        if (when_Pipeline_l124_22) begin
            execute_to_memory_BYPASSABLE_MEMORY_STAGE <= execute_BYPASSABLE_MEMORY_STAGE;
        end
        if (when_Pipeline_l124_23) begin
            decode_to_execute_MEMORY_WR <= decode_MEMORY_WR;
        end
        if (when_Pipeline_l124_24) begin
            execute_to_memory_MEMORY_WR <= execute_MEMORY_WR;
        end
        if (when_Pipeline_l124_25) begin
            memory_to_writeBack_MEMORY_WR <= memory_MEMORY_WR;
        end
        if (when_Pipeline_l124_26) begin
            decode_to_execute_MEMORY_MANAGMENT <= decode_MEMORY_MANAGMENT;
        end
        if (when_Pipeline_l124_27) begin
            decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
        end
        if (when_Pipeline_l124_28) begin
            decode_to_execute_ALU_BITWISE_CTRL <= _zz_decode_to_execute_ALU_BITWISE_CTRL;
        end
        if (when_Pipeline_l124_29) begin
            decode_to_execute_SHIFT_CTRL <= _zz_decode_to_execute_SHIFT_CTRL;
        end
        if (when_Pipeline_l124_30) begin
            execute_to_memory_SHIFT_CTRL <= _zz_execute_to_memory_SHIFT_CTRL;
        end
        if (when_Pipeline_l124_31) begin
            decode_to_execute_IS_MUL <= decode_IS_MUL;
        end
        if (when_Pipeline_l124_32) begin
            execute_to_memory_IS_MUL <= execute_IS_MUL;
        end
        if (when_Pipeline_l124_33) begin
            memory_to_writeBack_IS_MUL <= memory_IS_MUL;
        end
        if (when_Pipeline_l124_34) begin
            decode_to_execute_IS_DIV <= decode_IS_DIV;
        end
        if (when_Pipeline_l124_35) begin
            execute_to_memory_IS_DIV <= execute_IS_DIV;
        end
        if (when_Pipeline_l124_36) begin
            decode_to_execute_IS_RS1_SIGNED <= decode_IS_RS1_SIGNED;
        end
        if (when_Pipeline_l124_37) begin
            decode_to_execute_IS_RS2_SIGNED <= decode_IS_RS2_SIGNED;
        end
        if (when_Pipeline_l124_38) begin
            decode_to_execute_BRANCH_CTRL <= _zz_decode_to_execute_BRANCH_CTRL;
        end
        if (when_Pipeline_l124_39) begin
            decode_to_execute_IS_CSR <= decode_IS_CSR;
        end
        if (when_Pipeline_l124_40) begin
            decode_to_execute_ENV_CTRL <= _zz_decode_to_execute_ENV_CTRL;
        end
        if (when_Pipeline_l124_41) begin
            execute_to_memory_ENV_CTRL <= _zz_execute_to_memory_ENV_CTRL;
        end
        if (when_Pipeline_l124_42) begin
            memory_to_writeBack_ENV_CTRL <= _zz_memory_to_writeBack_ENV_CTRL;
        end
        if (when_Pipeline_l124_43) begin
            decode_to_execute_RS1 <= decode_RS1;
        end
        if (when_Pipeline_l124_44) begin
            decode_to_execute_RS2 <= decode_RS2;
        end
        if (when_Pipeline_l124_45) begin
            decode_to_execute_SRC2_FORCE_ZERO <= decode_SRC2_FORCE_ZERO;
        end
        if (when_Pipeline_l124_46) begin
            decode_to_execute_PREDICTION_HAD_BRANCHED1 <= decode_PREDICTION_HAD_BRANCHED1;
        end
        if (when_Pipeline_l124_47) begin
            decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
        end
        if (when_Pipeline_l124_48) begin
            decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
        end
        if (when_Pipeline_l124_49) begin
            decode_to_execute_DO_EBREAK <= decode_DO_EBREAK;
        end
        if (when_Pipeline_l124_50) begin
            execute_to_memory_MEMORY_STORE_DATA_RF <= execute_MEMORY_STORE_DATA_RF;
        end
        if (when_Pipeline_l124_51) begin
            memory_to_writeBack_MEMORY_STORE_DATA_RF <= memory_MEMORY_STORE_DATA_RF;
        end
        if (when_Pipeline_l124_52) begin
            execute_to_memory_REGFILE_WRITE_DATA <= _zz_decode_RS2;
        end
        if (when_Pipeline_l124_53) begin
            memory_to_writeBack_REGFILE_WRITE_DATA <= _zz_decode_RS2_1;
        end
        if (when_Pipeline_l124_54) begin
            execute_to_memory_SHIFT_RIGHT <= execute_SHIFT_RIGHT;
        end
        if (when_Pipeline_l124_55) begin
            execute_to_memory_MUL_LL <= execute_MUL_LL;
        end
        if (when_Pipeline_l124_56) begin
            execute_to_memory_MUL_LH <= execute_MUL_LH;
        end
        if (when_Pipeline_l124_57) begin
            execute_to_memory_MUL_HL <= execute_MUL_HL;
        end
        if (when_Pipeline_l124_58) begin
            execute_to_memory_MUL_HH <= execute_MUL_HH;
        end
        if (when_Pipeline_l124_59) begin
            memory_to_writeBack_MUL_HH <= memory_MUL_HH;
        end
        if (when_Pipeline_l124_60) begin
            execute_to_memory_BRANCH_DO <= execute_BRANCH_DO;
        end
        if (when_Pipeline_l124_61) begin
            execute_to_memory_BRANCH_CALC <= execute_BRANCH_CALC;
        end
        if (when_Pipeline_l124_62) begin
            memory_to_writeBack_MUL_LOW <= memory_MUL_LOW;
        end
        if (when_CsrPlugin_l1669) begin
            execute_CsrPlugin_csr_768 <= (decode_INSTRUCTION[31 : 20] == 12'h300);
        end
        if (when_CsrPlugin_l1669_1) begin
            execute_CsrPlugin_csr_836 <= (decode_INSTRUCTION[31 : 20] == 12'h344);
        end
        if (when_CsrPlugin_l1669_2) begin
            execute_CsrPlugin_csr_772 <= (decode_INSTRUCTION[31 : 20] == 12'h304);
        end
        if (when_CsrPlugin_l1669_3) begin
            execute_CsrPlugin_csr_773 <= (decode_INSTRUCTION[31 : 20] == 12'h305);
        end
        if (when_CsrPlugin_l1669_4) begin
            execute_CsrPlugin_csr_833 <= (decode_INSTRUCTION[31 : 20] == 12'h341);
        end
        if (when_CsrPlugin_l1669_5) begin
            execute_CsrPlugin_csr_834 <= (decode_INSTRUCTION[31 : 20] == 12'h342);
        end
        if (when_CsrPlugin_l1669_6) begin
            execute_CsrPlugin_csr_835 <= (decode_INSTRUCTION[31 : 20] == 12'h343);
        end
        if (execute_CsrPlugin_csr_836) begin
            if (execute_CsrPlugin_writeEnable) begin
                CsrPlugin_mip_MSIP <= CsrPlugin_csrMapping_writeDataSignal[3];
            end
        end
        if (execute_CsrPlugin_csr_833) begin
            if (execute_CsrPlugin_writeEnable) begin
                CsrPlugin_mepc <= CsrPlugin_csrMapping_writeDataSignal[31 : 0];
            end
        end
    end

    always @(posedge io_axiClk) begin
        DebugPlugin_firstCycle <= 1'b0;
        if (debug_bus_cmd_ready) begin
            DebugPlugin_firstCycle <= 1'b1;
        end
        DebugPlugin_secondCycle <= DebugPlugin_firstCycle;
        DebugPlugin_isPipBusy <= ((|{writeBack_arbitration_isValid,{memory_arbitration_isValid,{execute_arbitration_isValid,decode_arbitration_isValid}}}) || IBusCachedPlugin_incomingInstruction);
        if (writeBack_arbitration_isValid) begin
            DebugPlugin_busReadDataReg <= _zz_decode_RS2_2;
        end
        _zz_when_DebugPlugin_l257 <= debug_bus_cmd_payload_address[2];
        if (when_DebugPlugin_l308) begin
            DebugPlugin_busReadDataReg <= execute_PC;
        end
        DebugPlugin_resetIt_regNext <= DebugPlugin_resetIt;
    end

    always @(posedge io_axiClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            DebugPlugin_resetIt <= 1'b0;
            DebugPlugin_haltIt <= 1'b0;
            DebugPlugin_stepIt <= 1'b0;
            DebugPlugin_godmode <= 1'b0;
            DebugPlugin_haltedByBreak <= 1'b0;
            DebugPlugin_debugUsed <= 1'b0;
            DebugPlugin_disableEbreak <= 1'b0;
        end else begin
            if (when_DebugPlugin_l238) begin
                DebugPlugin_godmode <= 1'b1;
            end
            if (debug_bus_cmd_valid) begin
                DebugPlugin_debugUsed <= 1'b1;
            end
            if (debug_bus_cmd_valid) begin
                case (switch_DebugPlugin_l280)
                    6'h0: begin
                        if (debug_bus_cmd_payload_wr) begin
                            DebugPlugin_stepIt <= debug_bus_cmd_payload_data[4];
                            if (when_DebugPlugin_l284) begin
                                DebugPlugin_resetIt <= 1'b1;
                            end
                            if (when_DebugPlugin_l284_1) begin
                                DebugPlugin_resetIt <= 1'b0;
                            end
                            if (when_DebugPlugin_l285) begin
                                DebugPlugin_haltIt <= 1'b1;
                            end
                            if (when_DebugPlugin_l285_1) begin
                                DebugPlugin_haltIt <= 1'b0;
                            end
                            if (when_DebugPlugin_l286) begin
                                DebugPlugin_haltedByBreak <= 1'b0;
                            end
                            if (when_DebugPlugin_l287) begin
                                DebugPlugin_godmode <= 1'b0;
                            end
                            if (when_DebugPlugin_l288) begin
                                DebugPlugin_disableEbreak <= 1'b1;
                            end
                            if (when_DebugPlugin_l288_1) begin
                                DebugPlugin_disableEbreak <= 1'b0;
                            end
                        end
                    end
                    default: begin
                    end
                endcase
            end
            if (when_DebugPlugin_l308) begin
                if (when_DebugPlugin_l311) begin
                    DebugPlugin_haltIt <= 1'b1;
                    DebugPlugin_haltedByBreak <= 1'b1;
                end
            end
            if (when_DebugPlugin_l324) begin
                if (decode_arbitration_isValid) begin
                    DebugPlugin_haltIt <= 1'b1;
                end
            end
        end
    end


endmodule


module BufferCC (
    input  wire io_dataIn,
    output wire io_dataOut,
    input  wire io_axiClk
);

    (* async_reg = "true" *)reg buffers_0;
    (* async_reg = "true" *)reg buffers_1;

    assign io_dataOut = buffers_1;
    always @(posedge io_axiClk) begin
        buffers_0 <= io_dataIn;
        buffers_1 <= buffers_0;
    end

endmodule


//StreamFifoLowLatency replaced by StreamFifoLowLatency_1

module StreamArbiter (
    input  wire        io_inputs_0_valid,
    output wire        io_inputs_0_ready,
    input  wire [19:0] io_inputs_0_payload_addr,
    input  wire [ 3:0] io_inputs_0_payload_id,
    input  wire [ 7:0] io_inputs_0_payload_len,
    input  wire [ 2:0] io_inputs_0_payload_size,
    input  wire [ 1:0] io_inputs_0_payload_burst,
    input  wire        io_inputs_0_payload_write,
    output wire        io_output_valid,
    input  wire        io_output_ready,
    output wire [19:0] io_output_payload_addr,
    output wire [ 3:0] io_output_payload_id,
    output wire [ 7:0] io_output_payload_len,
    output wire [ 2:0] io_output_payload_size,
    output wire [ 1:0] io_output_payload_burst,
    output wire        io_output_payload_write,
    output wire [ 0:0] io_chosenOH,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    wire [1:0] _zz__zz_maskProposal_0_2;
    wire [1:0] _zz__zz_maskProposal_0_2_1;
    wire [0:0] _zz__zz_maskProposal_0_2_2;
    wire [0:0] _zz_maskProposal_0_3;
    reg        locked;
    wire       maskProposal_0;
    reg        maskLocked_0;
    wire       maskRouted_0;
    wire [0:0] _zz_maskProposal_0;
    wire [1:0] _zz_maskProposal_0_1;
    wire [1:0] _zz_maskProposal_0_2;
    wire       io_output_fire;

    assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
    assign _zz__zz_maskProposal_0_2_2 = maskLocked_0;
    assign _zz__zz_maskProposal_0_2_1 = {1'd0, _zz__zz_maskProposal_0_2_2};
    assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[1:1] | _zz_maskProposal_0_2[0:0]);
    assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
    assign _zz_maskProposal_0 = io_inputs_0_valid;
    assign _zz_maskProposal_0_1 = {_zz_maskProposal_0, _zz_maskProposal_0};
    assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~_zz__zz_maskProposal_0_2));
    assign maskProposal_0 = _zz_maskProposal_0_3[0];
    assign io_output_fire = (io_output_valid && io_output_ready);
    assign io_output_valid = (io_inputs_0_valid && maskRouted_0);
    assign io_output_payload_addr = io_inputs_0_payload_addr;
    assign io_output_payload_id = io_inputs_0_payload_id;
    assign io_output_payload_len = io_inputs_0_payload_len;
    assign io_output_payload_size = io_inputs_0_payload_size;
    assign io_output_payload_burst = io_inputs_0_payload_burst;
    assign io_output_payload_write = io_inputs_0_payload_write;
    assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
    assign io_chosenOH = maskRouted_0;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            locked <= 1'b0;
            maskLocked_0 <= 1'b1;
        end else begin
            if (io_output_valid) begin
                maskLocked_0 <= maskRouted_0;
            end
            if (io_output_valid) begin
                locked <= 1'b1;
            end
            if (io_output_fire) begin
                locked <= 1'b0;
            end
        end
    end

endmodule


module StreamFifoLowLatency_1 (
    input  wire       io_push_valid,
    output wire       io_push_ready,
    output wire       io_pop_valid,
    input  wire       io_pop_ready,
    input  wire       io_flush,
    output wire [2:0] io_occupancy,
    output wire [2:0] io_availability,
    input  wire       io_axiClk,
    input  wire       resetCtrl_axiReset
);

    wire       fifo_io_push_ready;
    wire       fifo_io_pop_valid;
    wire [2:0] fifo_io_occupancy;
    wire [2:0] fifo_io_availability;

    StreamFifo_3 fifo (
        .io_push_valid     (io_push_valid),              //i
        .io_push_ready     (fifo_io_push_ready),         //o
        .io_pop_valid      (fifo_io_pop_valid),          //o
        .io_pop_ready      (io_pop_ready),               //i
        .io_flush          (io_flush),                   //i
        .io_occupancy      (fifo_io_occupancy[2:0]),     //o
        .io_availability   (fifo_io_availability[2:0]),  //o
        .io_axiClk         (io_axiClk),                  //i
        .resetCtrl_axiReset(resetCtrl_axiReset)          //i
    );
    assign io_push_ready = fifo_io_push_ready;
    assign io_pop_valid = fifo_io_pop_valid;
    assign io_occupancy = fifo_io_occupancy;
    assign io_availability = fifo_io_availability;

endmodule

module StreamArbiter_1 (
    input  wire        io_inputs_0_valid,
    output wire        io_inputs_0_ready,
    input  wire [17:0] io_inputs_0_payload_addr,
    input  wire [ 2:0] io_inputs_0_payload_id,
    input  wire [ 7:0] io_inputs_0_payload_len,
    input  wire [ 2:0] io_inputs_0_payload_size,
    input  wire [ 1:0] io_inputs_0_payload_burst,
    input  wire        io_inputs_0_payload_write,
    input  wire        io_inputs_1_valid,
    output wire        io_inputs_1_ready,
    input  wire [17:0] io_inputs_1_payload_addr,
    input  wire [ 2:0] io_inputs_1_payload_id,
    input  wire [ 7:0] io_inputs_1_payload_len,
    input  wire [ 2:0] io_inputs_1_payload_size,
    input  wire [ 1:0] io_inputs_1_payload_burst,
    input  wire        io_inputs_1_payload_write,
    output wire        io_output_valid,
    input  wire        io_output_ready,
    output wire [17:0] io_output_payload_addr,
    output wire [ 2:0] io_output_payload_id,
    output wire [ 7:0] io_output_payload_len,
    output wire [ 2:0] io_output_payload_size,
    output wire [ 1:0] io_output_payload_burst,
    output wire        io_output_payload_write,
    output wire [ 0:0] io_chosen,
    output wire [ 1:0] io_chosenOH,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    wire [3:0] _zz__zz_maskProposal_0_2;
    wire [3:0] _zz__zz_maskProposal_0_2_1;
    wire [1:0] _zz__zz_maskProposal_0_2_2;
    reg        locked;
    wire       maskProposal_0;
    wire       maskProposal_1;
    reg        maskLocked_0;
    reg        maskLocked_1;
    wire       maskRouted_0;
    wire       maskRouted_1;
    wire [1:0] _zz_maskProposal_0;
    wire [3:0] _zz_maskProposal_0_1;
    wire [3:0] _zz_maskProposal_0_2;
    wire [1:0] _zz_maskProposal_0_3;
    wire       io_output_fire;
    wire       _zz_io_chosen;

    assign _zz__zz_maskProposal_0_2 = (_zz_maskProposal_0_1 - _zz__zz_maskProposal_0_2_1);
    assign _zz__zz_maskProposal_0_2_2 = {maskLocked_0, maskLocked_1};
    assign _zz__zz_maskProposal_0_2_1 = {2'd0, _zz__zz_maskProposal_0_2_2};
    assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
    assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
    assign _zz_maskProposal_0 = {io_inputs_1_valid, io_inputs_0_valid};
    assign _zz_maskProposal_0_1 = {_zz_maskProposal_0, _zz_maskProposal_0};
    assign _zz_maskProposal_0_2 = (_zz_maskProposal_0_1 & (~_zz__zz_maskProposal_0_2));
    assign _zz_maskProposal_0_3 = (_zz_maskProposal_0_2[3:2] | _zz_maskProposal_0_2[1:0]);
    assign maskProposal_0 = _zz_maskProposal_0_3[0];
    assign maskProposal_1 = _zz_maskProposal_0_3[1];
    assign io_output_fire = (io_output_valid && io_output_ready);
    assign io_output_valid = ((io_inputs_0_valid && maskRouted_0) || (io_inputs_1_valid && maskRouted_1));
    assign io_output_payload_addr = (maskRouted_0 ? io_inputs_0_payload_addr:io_inputs_1_payload_addr);
    assign io_output_payload_id = (maskRouted_0 ? io_inputs_0_payload_id : io_inputs_1_payload_id);
    assign io_output_payload_len = (maskRouted_0 ? io_inputs_0_payload_len:io_inputs_1_payload_len);
    assign io_output_payload_size = (maskRouted_0 ? io_inputs_0_payload_size:io_inputs_1_payload_size);
    assign io_output_payload_burst = (maskRouted_0 ? io_inputs_0_payload_burst:io_inputs_1_payload_burst);
    assign io_output_payload_write = (maskRouted_0 ? io_inputs_0_payload_write:io_inputs_1_payload_write);
    assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
    assign io_inputs_1_ready = (maskRouted_1 && io_output_ready);
    assign io_chosenOH = {maskRouted_1, maskRouted_0};
    assign _zz_io_chosen = io_chosenOH[1];
    assign io_chosen = _zz_io_chosen;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            locked <= 1'b0;
            maskLocked_0 <= 1'b0;
            maskLocked_1 <= 1'b1;
        end else begin
            if (io_output_valid) begin
                maskLocked_0 <= maskRouted_0;
                maskLocked_1 <= maskRouted_1;
            end
            if (io_output_valid) begin
                locked <= 1'b1;
            end
            if (io_output_fire) begin
                locked <= 1'b0;
            end
        end
    end

endmodule


module Axi4SharedErrorSlave (
    input  wire        io_axi_arw_valid,
    output wire        io_axi_arw_ready,
    input  wire [31:0] io_axi_arw_payload_addr,
    input  wire [ 7:0] io_axi_arw_payload_len,
    input  wire [ 2:0] io_axi_arw_payload_size,
    input  wire [ 3:0] io_axi_arw_payload_cache,
    input  wire [ 2:0] io_axi_arw_payload_prot,
    input  wire        io_axi_arw_payload_write,
    input  wire        io_axi_w_valid,
    output wire        io_axi_w_ready,
    input  wire [31:0] io_axi_w_payload_data,
    input  wire [ 3:0] io_axi_w_payload_strb,
    input  wire        io_axi_w_payload_last,
    output wire        io_axi_b_valid,
    input  wire        io_axi_b_ready,
    output wire [ 1:0] io_axi_b_payload_resp,
    output wire        io_axi_r_valid,
    input  wire        io_axi_r_ready,
    output wire [31:0] io_axi_r_payload_data,
    output wire [ 1:0] io_axi_r_payload_resp,
    output wire        io_axi_r_payload_last,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    reg        consumeData;
    reg        sendReadRsp;
    reg        sendWriteRsp;
    reg  [7:0] remaining;
    wire       remainingZero;
    wire       io_axi_arw_fire;
    wire       io_axi_w_fire;
    wire       when_Axi4ErrorSlave_l92;
    wire       io_axi_b_fire;

    assign remainingZero = (remaining == 8'h0);
    assign io_axi_arw_ready = (!((consumeData || sendWriteRsp) || sendReadRsp));
    assign io_axi_arw_fire = (io_axi_arw_valid && io_axi_arw_ready);
    assign io_axi_w_ready = consumeData;
    assign io_axi_w_fire = (io_axi_w_valid && io_axi_w_ready);
    assign when_Axi4ErrorSlave_l92 = (io_axi_w_fire && io_axi_w_payload_last);
    assign io_axi_b_valid = sendWriteRsp;
    assign io_axi_b_payload_resp = 2'b11;
    assign io_axi_b_fire = (io_axi_b_valid && io_axi_b_ready);
    assign io_axi_r_valid = sendReadRsp;
    assign io_axi_r_payload_resp = 2'b11;
    assign io_axi_r_payload_last = remainingZero;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            consumeData  <= 1'b0;
            sendReadRsp  <= 1'b0;
            sendWriteRsp <= 1'b0;
        end else begin
            if (io_axi_arw_fire) begin
                consumeData <= io_axi_arw_payload_write;
                sendReadRsp <= (!io_axi_arw_payload_write);
            end
            if (when_Axi4ErrorSlave_l92) begin
                consumeData  <= 1'b0;
                sendWriteRsp <= 1'b1;
            end
            if (io_axi_b_fire) begin
                sendWriteRsp <= 1'b0;
            end
            if (sendReadRsp) begin
                if (io_axi_r_ready) begin
                    if (remainingZero) begin
                        sendReadRsp <= 1'b0;
                    end
                end
            end
        end
    end

    always @(posedge io_axiClk) begin
        if (io_axi_arw_fire) begin
            remaining <= io_axi_arw_payload_len;
        end
        if (sendReadRsp) begin
            if (io_axi_r_ready) begin
                remaining <= (remaining - 8'h01);
            end
        end
    end

endmodule


module Axi4ReadOnlyErrorSlave (
    input  wire        io_axi_ar_valid,
    output wire        io_axi_ar_ready,
    input  wire [31:0] io_axi_ar_payload_addr,
    input  wire [ 7:0] io_axi_ar_payload_len,
    input  wire [ 1:0] io_axi_ar_payload_burst,
    input  wire [ 3:0] io_axi_ar_payload_cache,
    input  wire [ 2:0] io_axi_ar_payload_prot,
    output wire        io_axi_r_valid,
    input  wire        io_axi_r_ready,
    output wire [31:0] io_axi_r_payload_data,
    output wire [ 1:0] io_axi_r_payload_resp,
    output wire        io_axi_r_payload_last,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    reg        sendRsp;
    reg  [7:0] remaining;
    wire       remainingZero;
    wire       io_axi_ar_fire;

    assign remainingZero = (remaining == 8'h0);
    assign io_axi_ar_ready = (!sendRsp);
    assign io_axi_ar_fire = (io_axi_ar_valid && io_axi_ar_ready);
    assign io_axi_r_valid = sendRsp;
    assign io_axi_r_payload_resp = 2'b11;
    assign io_axi_r_payload_last = remainingZero;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            sendRsp <= 1'b0;
        end else begin
            if (io_axi_ar_fire) begin
                sendRsp <= 1'b1;
            end
            if (sendRsp) begin
                if (io_axi_r_ready) begin
                    if (remainingZero) begin
                        sendRsp <= 1'b0;
                    end
                end
            end
        end
    end

    always @(posedge io_axiClk) begin
        if (io_axi_ar_fire) begin
            remaining <= io_axi_ar_payload_len;
        end
        if (sendRsp) begin
            if (io_axi_r_ready) begin
                remaining <= (remaining - 8'h01);
            end
        end
    end

endmodule


module FlowCCUnsafeByToggle (
    input  wire       io_input_valid,
    input  wire       io_input_payload_last,
    input  wire [0:0] io_input_payload_fragment,
    output wire       io_output_valid,
    output wire       io_output_payload_last,
    output wire [0:0] io_output_payload_fragment,
    input  wire       io_jtag_tck,
    input  wire       io_axiClk,
    input  wire       resetCtrl_systemReset
);

    wire       inputArea_target_buffercc_io_dataOut;
    reg        inputArea_target;
    reg        inputArea_data_last;
    reg  [0:0] inputArea_data_fragment;
    wire       outputArea_target;
    reg        outputArea_hit;
    wire       outputArea_flow_valid;
    wire       outputArea_flow_payload_last;
    wire [0:0] outputArea_flow_payload_fragment;
    reg        outputArea_flow_m2sPipe_valid;
    (* async_reg = "true" *)reg        outputArea_flow_m2sPipe_payload_last;
    (* async_reg = "true" *)reg  [0:0] outputArea_flow_m2sPipe_payload_fragment;

    (* keep_hierarchy = "TRUE" *) BufferCC_5 inputArea_target_buffercc (
        .io_dataIn            (inputArea_target),                      //i
        .io_dataOut           (inputArea_target_buffercc_io_dataOut),  //o
        .io_axiClk            (io_axiClk),                             //i
        .resetCtrl_systemReset(resetCtrl_systemReset)                  //i
    );
    initial begin
`ifndef SYNTHESIS
        inputArea_target = $urandom;
        outputArea_hit   = $urandom;
`endif
    end

    assign outputArea_target = inputArea_target_buffercc_io_dataOut;
    assign outputArea_flow_valid = (outputArea_target != outputArea_hit);
    assign outputArea_flow_payload_last = inputArea_data_last;
    assign outputArea_flow_payload_fragment = inputArea_data_fragment;
    assign io_output_valid = outputArea_flow_m2sPipe_valid;
    assign io_output_payload_last = outputArea_flow_m2sPipe_payload_last;
    assign io_output_payload_fragment = outputArea_flow_m2sPipe_payload_fragment;
    always @(posedge io_jtag_tck) begin
        if (io_input_valid) begin
            inputArea_target <= (!inputArea_target);
            inputArea_data_last <= io_input_payload_last;
            inputArea_data_fragment <= io_input_payload_fragment;
        end
    end

    always @(posedge io_axiClk) begin
        outputArea_hit <= outputArea_target;
        if (outputArea_flow_valid) begin
            outputArea_flow_m2sPipe_payload_last <= outputArea_flow_payload_last;
            outputArea_flow_m2sPipe_payload_fragment <= outputArea_flow_payload_fragment;
        end
    end

    always @(posedge io_axiClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            outputArea_flow_m2sPipe_valid <= 1'b0;
        end else begin
            outputArea_flow_m2sPipe_valid <= outputArea_flow_valid;
        end
    end

endmodule


module DataCache (
    input  wire        io_cpu_execute_isValid,
    input  wire [31:0] io_cpu_execute_address,
    output reg         io_cpu_execute_haltIt,
    input  wire        io_cpu_execute_args_wr,
    input  wire [ 1:0] io_cpu_execute_args_size,
    input  wire        io_cpu_execute_args_totalyConsistent,
    output wire        io_cpu_execute_refilling,
    input  wire        io_cpu_memory_isValid,
    input  wire        io_cpu_memory_isStuck,
    output wire        io_cpu_memory_isWrite,
    input  wire [31:0] io_cpu_memory_address,
    input  wire [31:0] io_cpu_memory_mmuRsp_physicalAddress,
    input  wire        io_cpu_memory_mmuRsp_isIoAccess,
    input  wire        io_cpu_memory_mmuRsp_isPaging,
    input  wire        io_cpu_memory_mmuRsp_allowRead,
    input  wire        io_cpu_memory_mmuRsp_allowWrite,
    input  wire        io_cpu_memory_mmuRsp_allowExecute,
    input  wire        io_cpu_memory_mmuRsp_exception,
    input  wire        io_cpu_memory_mmuRsp_refilling,
    input  wire        io_cpu_memory_mmuRsp_bypassTranslation,
    input  wire        io_cpu_writeBack_isValid,
    input  wire        io_cpu_writeBack_isStuck,
    input  wire        io_cpu_writeBack_isFiring,
    input  wire        io_cpu_writeBack_isUser,
    output reg         io_cpu_writeBack_haltIt,
    output wire        io_cpu_writeBack_isWrite,
    input  wire [31:0] io_cpu_writeBack_storeData,
    output reg  [31:0] io_cpu_writeBack_data,
    input  wire [31:0] io_cpu_writeBack_address,
    output wire        io_cpu_writeBack_mmuException,
    output wire        io_cpu_writeBack_unalignedAccess,
    output reg         io_cpu_writeBack_accessError,
    output wire        io_cpu_writeBack_keepMemRspData,
    input  wire        io_cpu_writeBack_fence_SW,
    input  wire        io_cpu_writeBack_fence_SR,
    input  wire        io_cpu_writeBack_fence_SO,
    input  wire        io_cpu_writeBack_fence_SI,
    input  wire        io_cpu_writeBack_fence_PW,
    input  wire        io_cpu_writeBack_fence_PR,
    input  wire        io_cpu_writeBack_fence_PO,
    input  wire        io_cpu_writeBack_fence_PI,
    input  wire [ 3:0] io_cpu_writeBack_fence_FM,
    output wire        io_cpu_writeBack_exclusiveOk,
    output reg         io_cpu_redo,
    input  wire        io_cpu_flush_valid,
    output wire        io_cpu_flush_ready,
    input  wire        io_cpu_flush_payload_singleLine,
    input  wire [ 6:0] io_cpu_flush_payload_lineId,
    output wire        io_cpu_writesPending,
    output reg         io_mem_cmd_valid,
    input  wire        io_mem_cmd_ready,
    output reg         io_mem_cmd_payload_wr,
    output wire        io_mem_cmd_payload_uncached,
    output reg  [31:0] io_mem_cmd_payload_address,
    output wire [31:0] io_mem_cmd_payload_data,
    output wire [ 3:0] io_mem_cmd_payload_mask,
    output reg  [ 2:0] io_mem_cmd_payload_size,
    output wire        io_mem_cmd_payload_last,
    input  wire        io_mem_rsp_valid,
    input  wire        io_mem_rsp_payload_last,
    input  wire [31:0] io_mem_rsp_payload_data,
    input  wire        io_mem_rsp_payload_error,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    reg  [21:0] ways_0_tags_spinal_port0;
    reg  [31:0] ways_0_data_spinal_port0;
    wire [21:0] _zz_ways_0_tags_port;
    wire [ 0:0] _zz_when;
    wire [ 2:0] _zz_loader_counter_valueNext;
    wire [ 0:0] _zz_loader_counter_valueNext_1;
    wire [ 1:0] _zz_loader_waysAllocator;
    reg         _zz_1;
    reg         _zz_2;
    wire        haltCpu;
    reg         tagsReadCmd_valid;
    reg  [ 6:0] tagsReadCmd_payload;
    reg         tagsWriteCmd_valid;
    reg  [ 0:0] tagsWriteCmd_payload_way;
    reg  [ 6:0] tagsWriteCmd_payload_address;
    reg         tagsWriteCmd_payload_data_valid;
    reg         tagsWriteCmd_payload_data_error;
    reg  [19:0] tagsWriteCmd_payload_data_address;
    reg         tagsWriteLastCmd_valid;
    reg  [ 0:0] tagsWriteLastCmd_payload_way;
    reg  [ 6:0] tagsWriteLastCmd_payload_address;
    reg         tagsWriteLastCmd_payload_data_valid;
    reg         tagsWriteLastCmd_payload_data_error;
    reg  [19:0] tagsWriteLastCmd_payload_data_address;
    reg         dataReadCmd_valid;
    reg  [ 9:0] dataReadCmd_payload;
    reg         dataWriteCmd_valid;
    reg  [ 0:0] dataWriteCmd_payload_way;
    reg  [ 9:0] dataWriteCmd_payload_address;
    reg  [31:0] dataWriteCmd_payload_data;
    reg  [ 3:0] dataWriteCmd_payload_mask;
    wire        _zz_ways_0_tagsReadRsp_valid;
    wire        ways_0_tagsReadRsp_valid;
    wire        ways_0_tagsReadRsp_error;
    wire [19:0] ways_0_tagsReadRsp_address;
    wire [21:0] _zz_ways_0_tagsReadRsp_valid_1;
    wire        _zz_ways_0_dataReadRspMem;
    wire [31:0] ways_0_dataReadRspMem;
    wire [31:0] ways_0_dataReadRsp;
    wire        when_DataCache_l645;
    wire        when_DataCache_l648;
    wire        when_DataCache_l667;
    wire        rspSync;
    wire        rspLast;
    reg         memCmdSent;
    wire        io_mem_cmd_fire;
    wire        when_DataCache_l689;
    reg  [ 3:0] _zz_stage0_mask;
    wire [ 3:0] stage0_mask;
    wire [ 0:0] stage0_dataColisions;
    wire [ 0:0] stage0_wayInvalidate;
    wire        stage0_isAmo;
    wire        when_DataCache_l776;
    reg         stageA_request_wr;
    reg  [ 1:0] stageA_request_size;
    reg         stageA_request_totalyConsistent;
    wire        when_DataCache_l776_1;
    reg  [ 3:0] stageA_mask;
    wire        stageA_isAmo;
    wire        stageA_isLrsc;
    wire [ 0:0] stageA_wayHits;
    wire        when_DataCache_l776_2;
    reg  [ 0:0] stageA_wayInvalidate;
    wire        when_DataCache_l776_3;
    reg  [ 0:0] stage0_dataColisions_regNextWhen;
    wire [ 0:0] _zz_stageA_dataColisions;
    wire [ 0:0] stageA_dataColisions;
    wire        when_DataCache_l827;
    reg         stageB_request_wr;
    reg  [ 1:0] stageB_request_size;
    reg         stageB_request_totalyConsistent;
    reg         stageB_mmuRspFreeze;
    wire        when_DataCache_l829;
    reg  [31:0] stageB_mmuRsp_physicalAddress;
    reg         stageB_mmuRsp_isIoAccess;
    reg         stageB_mmuRsp_isPaging;
    reg         stageB_mmuRsp_allowRead;
    reg         stageB_mmuRsp_allowWrite;
    reg         stageB_mmuRsp_allowExecute;
    reg         stageB_mmuRsp_exception;
    reg         stageB_mmuRsp_refilling;
    reg         stageB_mmuRsp_bypassTranslation;
    wire        when_DataCache_l826;
    reg         stageB_tagsReadRsp_0_valid;
    reg         stageB_tagsReadRsp_0_error;
    reg  [19:0] stageB_tagsReadRsp_0_address;
    wire        when_DataCache_l826_1;
    reg  [31:0] stageB_dataReadRsp_0;
    wire        when_DataCache_l825;
    reg  [ 0:0] stageB_wayInvalidate;
    wire        stageB_consistancyHazard;
    wire        when_DataCache_l825_1;
    reg  [ 0:0] stageB_dataColisions;
    wire        when_DataCache_l825_2;
    reg         stageB_unaligned;
    wire        when_DataCache_l825_3;
    reg  [ 0:0] stageB_waysHitsBeforeInvalidate;
    wire [ 0:0] stageB_waysHits;
    wire        stageB_waysHit;
    wire [31:0] stageB_dataMux;
    wire        when_DataCache_l825_4;
    reg  [ 3:0] stageB_mask;
    reg         stageB_loaderValid;
    wire [31:0] stageB_ioMemRspMuxed;
    reg         stageB_flusher_waitDone;
    wire        stageB_flusher_hold;
    reg  [ 7:0] stageB_flusher_counter;
    wire        when_DataCache_l855;
    wire        when_DataCache_l861;
    wire        when_DataCache_l863;
    reg         stageB_flusher_start;
    wire        when_DataCache_l877;
    wire        stageB_isAmo;
    wire        stageB_isAmoCached;
    wire        stageB_isExternalLsrc;
    wire        stageB_isExternalAmo;
    wire [31:0] stageB_requestDataBypass;
    reg         stageB_cpuWriteToCache;
    wire        when_DataCache_l931;
    wire        stageB_badPermissions;
    wire        stageB_loadStoreFault;
    wire        stageB_bypassCache;
    wire        when_DataCache_l1000;
    wire        when_DataCache_l1009;
    wire        when_DataCache_l1014;
    wire        when_DataCache_l1025;
    wire        when_DataCache_l1037;
    wire        when_DataCache_l996;
    wire        when_DataCache_l1072;
    wire        when_DataCache_l1081;
    reg         loader_valid;
    reg         loader_counter_willIncrement;
    wire        loader_counter_willClear;
    reg  [ 2:0] loader_counter_valueNext;
    reg  [ 2:0] loader_counter_value;
    wire        loader_counter_willOverflowIfInc;
    wire        loader_counter_willOverflow;
    reg  [ 0:0] loader_waysAllocator;
    reg         loader_error;
    wire        loader_kill;
    reg         loader_killReg;
    wire        when_DataCache_l1097;
    wire        loader_done;
    wire        when_DataCache_l1125;
    reg         loader_valid_regNext;
    wire        when_DataCache_l1129;
    wire        when_DataCache_l1132;
    reg  [21:0] ways_0_tags                           [ 0:127];
    reg  [ 7:0] ways_0_data_symbol0                   [0:1023];
    reg  [ 7:0] ways_0_data_symbol1                   [0:1023];
    reg  [ 7:0] ways_0_data_symbol2                   [0:1023];
    reg  [ 7:0] ways_0_data_symbol3                   [0:1023];
    reg  [ 7:0] _zz_ways_0_datasymbol_read;
    reg  [ 7:0] _zz_ways_0_datasymbol_read_1;
    reg  [ 7:0] _zz_ways_0_datasymbol_read_2;
    reg  [ 7:0] _zz_ways_0_datasymbol_read_3;

    assign _zz_when = 1'b1;
    assign _zz_loader_counter_valueNext_1 = loader_counter_willIncrement;
    assign _zz_loader_counter_valueNext = {2'd0, _zz_loader_counter_valueNext_1};
    assign _zz_loader_waysAllocator = {loader_waysAllocator, loader_waysAllocator[0]};
    assign _zz_ways_0_tags_port = {
        tagsWriteCmd_payload_data_address,
        {tagsWriteCmd_payload_data_error, tagsWriteCmd_payload_data_valid}
    };
    always @(posedge io_axiClk) begin
        if (_zz_ways_0_tagsReadRsp_valid) begin
            ways_0_tags_spinal_port0 <= ways_0_tags[tagsReadCmd_payload];
        end
    end

    always @(posedge io_axiClk) begin
        if (_zz_2) begin
            ways_0_tags[tagsWriteCmd_payload_address] <= _zz_ways_0_tags_port;
        end
    end

    always @(*) begin
        ways_0_data_spinal_port0 = {
            _zz_ways_0_datasymbol_read_3,
            _zz_ways_0_datasymbol_read_2,
            _zz_ways_0_datasymbol_read_1,
            _zz_ways_0_datasymbol_read
        };
    end
    always @(posedge io_axiClk) begin
        if (_zz_ways_0_dataReadRspMem) begin
            _zz_ways_0_datasymbol_read   <= ways_0_data_symbol0[dataReadCmd_payload];
            _zz_ways_0_datasymbol_read_1 <= ways_0_data_symbol1[dataReadCmd_payload];
            _zz_ways_0_datasymbol_read_2 <= ways_0_data_symbol2[dataReadCmd_payload];
            _zz_ways_0_datasymbol_read_3 <= ways_0_data_symbol3[dataReadCmd_payload];
        end
    end

    always @(posedge io_axiClk) begin
        if (dataWriteCmd_payload_mask[0] && _zz_1) begin
            ways_0_data_symbol0[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[7:0];
        end
        if (dataWriteCmd_payload_mask[1] && _zz_1) begin
            ways_0_data_symbol1[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[15:8];
        end
        if (dataWriteCmd_payload_mask[2] && _zz_1) begin
            ways_0_data_symbol2[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[23:16];
        end
        if (dataWriteCmd_payload_mask[3] && _zz_1) begin
            ways_0_data_symbol3[dataWriteCmd_payload_address] <= dataWriteCmd_payload_data[31:24];
        end
    end

    always @(*) begin
        _zz_1 = 1'b0;
        if (when_DataCache_l648) begin
            _zz_1 = 1'b1;
        end
    end

    always @(*) begin
        _zz_2 = 1'b0;
        if (when_DataCache_l645) begin
            _zz_2 = 1'b1;
        end
    end

    assign haltCpu = 1'b0;
    assign _zz_ways_0_tagsReadRsp_valid = (tagsReadCmd_valid && (!io_cpu_memory_isStuck));
    assign _zz_ways_0_tagsReadRsp_valid_1 = ways_0_tags_spinal_port0;
    assign ways_0_tagsReadRsp_valid = _zz_ways_0_tagsReadRsp_valid_1[0];
    assign ways_0_tagsReadRsp_error = _zz_ways_0_tagsReadRsp_valid_1[1];
    assign ways_0_tagsReadRsp_address = _zz_ways_0_tagsReadRsp_valid_1[21:2];
    assign _zz_ways_0_dataReadRspMem = (dataReadCmd_valid && (!io_cpu_memory_isStuck));
    assign ways_0_dataReadRspMem = ways_0_data_spinal_port0;
    assign ways_0_dataReadRsp = ways_0_dataReadRspMem[31:0];
    assign when_DataCache_l645 = (tagsWriteCmd_valid && tagsWriteCmd_payload_way[0]);
    assign when_DataCache_l648 = (dataWriteCmd_valid && dataWriteCmd_payload_way[0]);
    always @(*) begin
        tagsReadCmd_valid = 1'b0;
        if (when_DataCache_l667) begin
            tagsReadCmd_valid = 1'b1;
        end
    end

    always @(*) begin
        tagsReadCmd_payload = 7'bxxxxxxx;
        if (when_DataCache_l667) begin
            tagsReadCmd_payload = io_cpu_execute_address[11:5];
        end
    end

    always @(*) begin
        dataReadCmd_valid = 1'b0;
        if (when_DataCache_l667) begin
            dataReadCmd_valid = 1'b1;
        end
    end

    always @(*) begin
        dataReadCmd_payload = 10'bxxxxxxxxxx;
        if (when_DataCache_l667) begin
            dataReadCmd_payload = io_cpu_execute_address[11:2];
        end
    end

    always @(*) begin
        tagsWriteCmd_valid = 1'b0;
        if (when_DataCache_l855) begin
            tagsWriteCmd_valid = 1'b1;
        end
        if (io_cpu_writeBack_isValid) begin
            if (when_DataCache_l1072) begin
                tagsWriteCmd_valid = 1'b0;
            end
        end
        if (loader_done) begin
            tagsWriteCmd_valid = 1'b1;
        end
    end

    always @(*) begin
        tagsWriteCmd_payload_way = 1'bx;
        if (when_DataCache_l855) begin
            tagsWriteCmd_payload_way = 1'b1;
        end
        if (loader_done) begin
            tagsWriteCmd_payload_way = loader_waysAllocator;
        end
    end

    always @(*) begin
        tagsWriteCmd_payload_address = 7'bxxxxxxx;
        if (when_DataCache_l855) begin
            tagsWriteCmd_payload_address = stageB_flusher_counter[6:0];
        end
        if (loader_done) begin
            tagsWriteCmd_payload_address = stageB_mmuRsp_physicalAddress[11:5];
        end
    end

    always @(*) begin
        tagsWriteCmd_payload_data_valid = 1'bx;
        if (when_DataCache_l855) begin
            tagsWriteCmd_payload_data_valid = 1'b0;
        end
        if (loader_done) begin
            tagsWriteCmd_payload_data_valid = (!(loader_kill || loader_killReg));
        end
    end

    always @(*) begin
        tagsWriteCmd_payload_data_error = 1'bx;
        if (loader_done) begin
            tagsWriteCmd_payload_data_error = (loader_error || (io_mem_rsp_valid && io_mem_rsp_payload_error));
        end
    end

    always @(*) begin
        tagsWriteCmd_payload_data_address = 20'bxxxxxxxxxxxxxxxxxxxx;
        if (loader_done) begin
            tagsWriteCmd_payload_data_address = stageB_mmuRsp_physicalAddress[31:12];
        end
    end

    always @(*) begin
        dataWriteCmd_valid = 1'b0;
        if (stageB_cpuWriteToCache) begin
            if (when_DataCache_l931) begin
                dataWriteCmd_valid = 1'b1;
            end
        end
        if (io_cpu_writeBack_isValid) begin
            if (when_DataCache_l1072) begin
                dataWriteCmd_valid = 1'b0;
            end
        end
        if (when_DataCache_l1097) begin
            dataWriteCmd_valid = 1'b1;
        end
    end

    always @(*) begin
        dataWriteCmd_payload_way = 1'bx;
        if (stageB_cpuWriteToCache) begin
            dataWriteCmd_payload_way = stageB_waysHits;
        end
        if (when_DataCache_l1097) begin
            dataWriteCmd_payload_way = loader_waysAllocator;
        end
    end

    always @(*) begin
        dataWriteCmd_payload_address = 10'bxxxxxxxxxx;
        if (stageB_cpuWriteToCache) begin
            dataWriteCmd_payload_address = stageB_mmuRsp_physicalAddress[11:2];
        end
        if (when_DataCache_l1097) begin
            dataWriteCmd_payload_address = {
                stageB_mmuRsp_physicalAddress[11:5], loader_counter_value
            };
        end
    end

    always @(*) begin
        dataWriteCmd_payload_data = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        if (stageB_cpuWriteToCache) begin
            dataWriteCmd_payload_data[31:0] = stageB_requestDataBypass;
        end
        if (when_DataCache_l1097) begin
            dataWriteCmd_payload_data = io_mem_rsp_payload_data;
        end
    end

    always @(*) begin
        dataWriteCmd_payload_mask = 4'bxxxx;
        if (stageB_cpuWriteToCache) begin
            dataWriteCmd_payload_mask = 4'b0000;
            if (_zz_when[0]) begin
                dataWriteCmd_payload_mask[3:0] = stageB_mask;
            end
        end
        if (when_DataCache_l1097) begin
            dataWriteCmd_payload_mask = 4'b1111;
        end
    end

    assign when_DataCache_l667 = (io_cpu_execute_isValid && (!io_cpu_memory_isStuck));
    always @(*) begin
        io_cpu_execute_haltIt = 1'b0;
        if (when_DataCache_l855) begin
            io_cpu_execute_haltIt = 1'b1;
        end
    end

    assign rspSync = 1'b1;
    assign rspLast = 1'b1;
    assign io_mem_cmd_fire = (io_mem_cmd_valid && io_mem_cmd_ready);
    assign when_DataCache_l689 = (!io_cpu_writeBack_isStuck);
    always @(*) begin
        _zz_stage0_mask = 4'bxxxx;
        case (io_cpu_execute_args_size)
            2'b00: begin
                _zz_stage0_mask = 4'b0001;
            end
            2'b01: begin
                _zz_stage0_mask = 4'b0011;
            end
            2'b10: begin
                _zz_stage0_mask = 4'b1111;
            end
            default: begin
            end
        endcase
    end

    assign stage0_mask = (_zz_stage0_mask <<< io_cpu_execute_address[1:0]);
    assign stage0_dataColisions[0] = (((dataWriteCmd_valid && dataWriteCmd_payload_way[0]) && (dataWriteCmd_payload_address == io_cpu_execute_address[11:2])) && ((stage0_mask & dataWriteCmd_payload_mask[3:0]) != 4'b0000));
    assign stage0_wayInvalidate = 1'b0;
    assign stage0_isAmo = 1'b0;
    assign when_DataCache_l776 = (!io_cpu_memory_isStuck);
    assign when_DataCache_l776_1 = (!io_cpu_memory_isStuck);
    assign io_cpu_memory_isWrite = stageA_request_wr;
    assign stageA_isAmo = 1'b0;
    assign stageA_isLrsc = 1'b0;
    assign stageA_wayHits = ((io_cpu_memory_mmuRsp_physicalAddress[31:12] == ways_0_tagsReadRsp_address) && ways_0_tagsReadRsp_valid);
    assign when_DataCache_l776_2 = (!io_cpu_memory_isStuck);
    assign when_DataCache_l776_3 = (!io_cpu_memory_isStuck);
    assign _zz_stageA_dataColisions[0] = (((dataWriteCmd_valid && dataWriteCmd_payload_way[0]) && (dataWriteCmd_payload_address == io_cpu_memory_address[11:2])) && ((stageA_mask & dataWriteCmd_payload_mask[3:0]) != 4'b0000));
    assign stageA_dataColisions = (stage0_dataColisions_regNextWhen | _zz_stageA_dataColisions);
    assign when_DataCache_l827 = (!io_cpu_writeBack_isStuck);
    always @(*) begin
        stageB_mmuRspFreeze = 1'b0;
        if (when_DataCache_l1132) begin
            stageB_mmuRspFreeze = 1'b1;
        end
    end

    assign when_DataCache_l829 = ((!io_cpu_writeBack_isStuck) && (!stageB_mmuRspFreeze));
    assign when_DataCache_l826 = (!io_cpu_writeBack_isStuck);
    assign when_DataCache_l826_1 = (!io_cpu_writeBack_isStuck);
    assign when_DataCache_l825 = (!io_cpu_writeBack_isStuck);
    assign stageB_consistancyHazard = 1'b0;
    assign when_DataCache_l825_1 = (!io_cpu_writeBack_isStuck);
    assign when_DataCache_l825_2 = (!io_cpu_writeBack_isStuck);
    assign when_DataCache_l825_3 = (!io_cpu_writeBack_isStuck);
    assign stageB_waysHits = (stageB_waysHitsBeforeInvalidate & (~stageB_wayInvalidate));
    assign stageB_waysHit = (|stageB_waysHits);
    assign stageB_dataMux = stageB_dataReadRsp_0;
    assign when_DataCache_l825_4 = (!io_cpu_writeBack_isStuck);
    always @(*) begin
        stageB_loaderValid = 1'b0;
        if (io_cpu_writeBack_isValid) begin
            if (!stageB_isExternalAmo) begin
                if (!when_DataCache_l996) begin
                    if (!when_DataCache_l1009) begin
                        if (io_mem_cmd_ready) begin
                            stageB_loaderValid = 1'b1;
                        end
                    end
                end
            end
        end
        if (io_cpu_writeBack_isValid) begin
            if (when_DataCache_l1072) begin
                stageB_loaderValid = 1'b0;
            end
        end
    end

    assign stageB_ioMemRspMuxed = io_mem_rsp_payload_data[31:0];
    always @(*) begin
        io_cpu_writeBack_haltIt = 1'b1;
        if (io_cpu_writeBack_isValid) begin
            if (!stageB_isExternalAmo) begin
                if (when_DataCache_l996) begin
                    if (when_DataCache_l1000) begin
                        io_cpu_writeBack_haltIt = 1'b0;
                    end
                end else begin
                    if (when_DataCache_l1009) begin
                        if (when_DataCache_l1014) begin
                            io_cpu_writeBack_haltIt = 1'b0;
                        end
                    end
                end
            end
        end
        if (io_cpu_writeBack_isValid) begin
            if (when_DataCache_l1072) begin
                io_cpu_writeBack_haltIt = 1'b0;
            end
        end
    end

    assign stageB_flusher_hold = 1'b0;
    assign when_DataCache_l855 = (!stageB_flusher_counter[7]);
    assign when_DataCache_l861 = (!stageB_flusher_hold);
    assign when_DataCache_l863 = (io_cpu_flush_valid && io_cpu_flush_payload_singleLine);
    assign io_cpu_flush_ready = (stageB_flusher_waitDone && stageB_flusher_counter[7]);
    assign when_DataCache_l877 = (io_cpu_flush_valid && io_cpu_flush_payload_singleLine);
    assign stageB_isAmo = 1'b0;
    assign stageB_isAmoCached = 1'b0;
    assign stageB_isExternalLsrc = 1'b0;
    assign stageB_isExternalAmo = 1'b0;
    assign stageB_requestDataBypass = io_cpu_writeBack_storeData;
    always @(*) begin
        stageB_cpuWriteToCache = 1'b0;
        if (io_cpu_writeBack_isValid) begin
            if (!stageB_isExternalAmo) begin
                if (!when_DataCache_l996) begin
                    if (when_DataCache_l1009) begin
                        stageB_cpuWriteToCache = 1'b1;
                    end
                end
            end
        end
    end

    assign when_DataCache_l931 = (stageB_request_wr && stageB_waysHit);
    assign stageB_badPermissions = (((! stageB_mmuRsp_allowWrite) && stageB_request_wr) || ((! stageB_mmuRsp_allowRead) && ((! stageB_request_wr) || stageB_isAmo)));
    assign stageB_loadStoreFault = (io_cpu_writeBack_isValid && (stageB_mmuRsp_exception || stageB_badPermissions));
    always @(*) begin
        io_cpu_redo = 1'b0;
        if (io_cpu_writeBack_isValid) begin
            if (!stageB_isExternalAmo) begin
                if (!when_DataCache_l996) begin
                    if (when_DataCache_l1009) begin
                        if (when_DataCache_l1025) begin
                            io_cpu_redo = 1'b1;
                        end
                    end
                end
            end
        end
        if (io_cpu_writeBack_isValid) begin
            if (when_DataCache_l1081) begin
                io_cpu_redo = 1'b1;
            end
        end
        if (when_DataCache_l1129) begin
            io_cpu_redo = 1'b1;
        end
    end

    always @(*) begin
        io_cpu_writeBack_accessError = 1'b0;
        if (stageB_bypassCache) begin
            io_cpu_writeBack_accessError = ((((! stageB_request_wr) && 1'b1) && io_mem_rsp_valid) && io_mem_rsp_payload_error);
        end else begin
            io_cpu_writeBack_accessError = (((stageB_waysHits & stageB_tagsReadRsp_0_error) != 1'b0) || (stageB_loadStoreFault && (! stageB_mmuRsp_isPaging)));
        end
    end

    assign io_cpu_writeBack_mmuException = (stageB_loadStoreFault && stageB_mmuRsp_isPaging);
    assign io_cpu_writeBack_unalignedAccess = (io_cpu_writeBack_isValid && stageB_unaligned);
    assign io_cpu_writeBack_isWrite = stageB_request_wr;
    always @(*) begin
        io_mem_cmd_valid = 1'b0;
        if (io_cpu_writeBack_isValid) begin
            if (!stageB_isExternalAmo) begin
                if (when_DataCache_l996) begin
                    io_mem_cmd_valid = (!memCmdSent);
                end else begin
                    if (when_DataCache_l1009) begin
                        if (stageB_request_wr) begin
                            io_mem_cmd_valid = 1'b1;
                        end
                    end else begin
                        if (when_DataCache_l1037) begin
                            io_mem_cmd_valid = 1'b1;
                        end
                    end
                end
            end
        end
        if (io_cpu_writeBack_isValid) begin
            if (when_DataCache_l1072) begin
                io_mem_cmd_valid = 1'b0;
            end
        end
    end

    always @(*) begin
        io_mem_cmd_payload_address = stageB_mmuRsp_physicalAddress;
        if (io_cpu_writeBack_isValid) begin
            if (!stageB_isExternalAmo) begin
                if (!when_DataCache_l996) begin
                    if (!when_DataCache_l1009) begin
                        io_mem_cmd_payload_address[4:0] = 5'h0;
                    end
                end
            end
        end
    end

    assign io_mem_cmd_payload_last = 1'b1;
    always @(*) begin
        io_mem_cmd_payload_wr = stageB_request_wr;
        if (io_cpu_writeBack_isValid) begin
            if (!stageB_isExternalAmo) begin
                if (!when_DataCache_l996) begin
                    if (!when_DataCache_l1009) begin
                        io_mem_cmd_payload_wr = 1'b0;
                    end
                end
            end
        end
    end

    assign io_mem_cmd_payload_mask = stageB_mask;
    assign io_mem_cmd_payload_data = stageB_requestDataBypass;
    assign io_mem_cmd_payload_uncached = stageB_mmuRsp_isIoAccess;
    always @(*) begin
        io_mem_cmd_payload_size = {1'd0, stageB_request_size};
        if (io_cpu_writeBack_isValid) begin
            if (!stageB_isExternalAmo) begin
                if (!when_DataCache_l996) begin
                    if (!when_DataCache_l1009) begin
                        io_mem_cmd_payload_size = 3'b101;
                    end
                end
            end
        end
    end

    assign stageB_bypassCache = ((stageB_mmuRsp_isIoAccess || stageB_isExternalLsrc) || stageB_isExternalAmo);
    assign io_cpu_writeBack_keepMemRspData = 1'b0;
    assign when_DataCache_l1000 = ((! stageB_request_wr) ? (io_mem_rsp_valid && rspSync):io_mem_cmd_ready);
    assign when_DataCache_l1009 = (stageB_waysHit || (stageB_request_wr && (!stageB_isAmoCached)));
    assign when_DataCache_l1014 = ((!stageB_request_wr) || io_mem_cmd_ready);
    assign when_DataCache_l1025 = (((! stageB_request_wr) || stageB_isAmoCached) && ((stageB_dataColisions & stageB_waysHits) != 1'b0));
    assign when_DataCache_l1037 = (!memCmdSent);
    assign when_DataCache_l996 = (stageB_mmuRsp_isIoAccess || stageB_isExternalLsrc);
    always @(*) begin
        if (stageB_bypassCache) begin
            io_cpu_writeBack_data = stageB_ioMemRspMuxed;
        end else begin
            io_cpu_writeBack_data = stageB_dataMux;
        end
    end

    assign when_DataCache_l1072 = ((((stageB_consistancyHazard || stageB_mmuRsp_refilling) || io_cpu_writeBack_accessError) || io_cpu_writeBack_mmuException) || io_cpu_writeBack_unalignedAccess);
    assign when_DataCache_l1081 = (stageB_mmuRsp_refilling || stageB_consistancyHazard);
    always @(*) begin
        loader_counter_willIncrement = 1'b0;
        if (when_DataCache_l1097) begin
            loader_counter_willIncrement = 1'b1;
        end
    end

    assign loader_counter_willClear = 1'b0;
    assign loader_counter_willOverflowIfInc = (loader_counter_value == 3'b111);
    assign loader_counter_willOverflow = (loader_counter_willOverflowIfInc && loader_counter_willIncrement);
    always @(*) begin
        loader_counter_valueNext = (loader_counter_value + _zz_loader_counter_valueNext);
        if (loader_counter_willClear) begin
            loader_counter_valueNext = 3'b000;
        end
    end

    assign loader_kill = 1'b0;
    assign when_DataCache_l1097 = ((loader_valid && io_mem_rsp_valid) && rspLast);
    assign loader_done = loader_counter_willOverflow;
    assign when_DataCache_l1125 = (!loader_valid);
    assign when_DataCache_l1129 = (loader_valid && (!loader_valid_regNext));
    assign io_cpu_execute_refilling = loader_valid;
    assign when_DataCache_l1132 = (stageB_loaderValid || loader_valid);
    always @(posedge io_axiClk) begin
        tagsWriteLastCmd_valid <= tagsWriteCmd_valid;
        tagsWriteLastCmd_payload_way <= tagsWriteCmd_payload_way;
        tagsWriteLastCmd_payload_address <= tagsWriteCmd_payload_address;
        tagsWriteLastCmd_payload_data_valid <= tagsWriteCmd_payload_data_valid;
        tagsWriteLastCmd_payload_data_error <= tagsWriteCmd_payload_data_error;
        tagsWriteLastCmd_payload_data_address <= tagsWriteCmd_payload_data_address;
        if (when_DataCache_l776) begin
            stageA_request_wr <= io_cpu_execute_args_wr;
            stageA_request_size <= io_cpu_execute_args_size;
            stageA_request_totalyConsistent <= io_cpu_execute_args_totalyConsistent;
        end
        if (when_DataCache_l776_1) begin
            stageA_mask <= stage0_mask;
        end
        if (when_DataCache_l776_2) begin
            stageA_wayInvalidate <= stage0_wayInvalidate;
        end
        if (when_DataCache_l776_3) begin
            stage0_dataColisions_regNextWhen <= stage0_dataColisions;
        end
        if (when_DataCache_l827) begin
            stageB_request_wr <= stageA_request_wr;
            stageB_request_size <= stageA_request_size;
            stageB_request_totalyConsistent <= stageA_request_totalyConsistent;
        end
        if (when_DataCache_l829) begin
            stageB_mmuRsp_physicalAddress <= io_cpu_memory_mmuRsp_physicalAddress;
            stageB_mmuRsp_isIoAccess <= io_cpu_memory_mmuRsp_isIoAccess;
            stageB_mmuRsp_isPaging <= io_cpu_memory_mmuRsp_isPaging;
            stageB_mmuRsp_allowRead <= io_cpu_memory_mmuRsp_allowRead;
            stageB_mmuRsp_allowWrite <= io_cpu_memory_mmuRsp_allowWrite;
            stageB_mmuRsp_allowExecute <= io_cpu_memory_mmuRsp_allowExecute;
            stageB_mmuRsp_exception <= io_cpu_memory_mmuRsp_exception;
            stageB_mmuRsp_refilling <= io_cpu_memory_mmuRsp_refilling;
            stageB_mmuRsp_bypassTranslation <= io_cpu_memory_mmuRsp_bypassTranslation;
        end
        if (when_DataCache_l826) begin
            stageB_tagsReadRsp_0_valid   <= ways_0_tagsReadRsp_valid;
            stageB_tagsReadRsp_0_error   <= ways_0_tagsReadRsp_error;
            stageB_tagsReadRsp_0_address <= ways_0_tagsReadRsp_address;
        end
        if (when_DataCache_l826_1) begin
            stageB_dataReadRsp_0 <= ways_0_dataReadRsp;
        end
        if (when_DataCache_l825) begin
            stageB_wayInvalidate <= stageA_wayInvalidate;
        end
        if (when_DataCache_l825_1) begin
            stageB_dataColisions <= stageA_dataColisions;
        end
        if (when_DataCache_l825_2) begin
            stageB_unaligned <= (|{((stageA_request_size == 2'b10) && (io_cpu_memory_address[1:0] != 2'b00)),((stageA_request_size == 2'b01) && (io_cpu_memory_address[0:0] != 1'b0))});
        end
        if (when_DataCache_l825_3) begin
            stageB_waysHitsBeforeInvalidate <= stageA_wayHits;
        end
        if (when_DataCache_l825_4) begin
            stageB_mask <= stageA_mask;
        end
        loader_valid_regNext <= loader_valid;
    end

    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            memCmdSent <= 1'b0;
            stageB_flusher_waitDone <= 1'b0;
            stageB_flusher_counter <= 8'h0;
            stageB_flusher_start <= 1'b1;
            loader_valid <= 1'b0;
            loader_counter_value <= 3'b000;
            loader_waysAllocator <= 1'b1;
            loader_error <= 1'b0;
            loader_killReg <= 1'b0;
        end else begin
            if (io_mem_cmd_fire) begin
                memCmdSent <= 1'b1;
            end
            if (when_DataCache_l689) begin
                memCmdSent <= 1'b0;
            end
            if (io_cpu_flush_ready) begin
                stageB_flusher_waitDone <= 1'b0;
            end
            if (when_DataCache_l855) begin
                if (when_DataCache_l861) begin
                    stageB_flusher_counter <= (stageB_flusher_counter + 8'h01);
                    if (when_DataCache_l863) begin
                        stageB_flusher_counter[7] <= 1'b1;
                    end
                end
            end
            stageB_flusher_start <= (((((((! stageB_flusher_waitDone) && (! stageB_flusher_start)) && io_cpu_flush_valid) && (! io_cpu_execute_isValid)) && (! io_cpu_memory_isValid)) && (! io_cpu_writeBack_isValid)) && (! io_cpu_redo));
            if (stageB_flusher_start) begin
                stageB_flusher_waitDone <= 1'b1;
                stageB_flusher_counter  <= 8'h0;
                if (when_DataCache_l877) begin
                    stageB_flusher_counter <= {1'b0, io_cpu_flush_payload_lineId};
                end
            end
`ifndef SYNTHESIS
`ifdef FORMAL
            assert((! ((io_cpu_writeBack_isValid && (! io_cpu_writeBack_haltIt)) && io_cpu_writeBack_isStuck))); // DataCache.scala:L1084
`else
            if(!(! ((io_cpu_writeBack_isValid && (! io_cpu_writeBack_haltIt)) && io_cpu_writeBack_isStuck))) begin
                $display(
                    "ERROR writeBack stuck by another plugin is not allowed");  // DataCache.scala:L1084
            end
`endif
`endif
            if (stageB_loaderValid) begin
                loader_valid <= 1'b1;
            end
            loader_counter_value <= loader_counter_valueNext;
            if (loader_kill) begin
                loader_killReg <= 1'b1;
            end
            if (when_DataCache_l1097) begin
                loader_error <= (loader_error || io_mem_rsp_payload_error);
            end
            if (loader_done) begin
                loader_valid   <= 1'b0;
                loader_error   <= 1'b0;
                loader_killReg <= 1'b0;
            end
            if (when_DataCache_l1125) begin
                loader_waysAllocator <= _zz_loader_waysAllocator[0:0];
            end
        end
    end

endmodule


module InstructionCache (
    input  wire        io_flush,
    input  wire        io_cpu_prefetch_isValid,
    output reg         io_cpu_prefetch_haltIt,
    input  wire [31:0] io_cpu_prefetch_pc,
    input  wire        io_cpu_fetch_isValid,
    input  wire        io_cpu_fetch_isStuck,
    input  wire        io_cpu_fetch_isRemoved,
    input  wire [31:0] io_cpu_fetch_pc,
    output wire [31:0] io_cpu_fetch_data,
    input  wire [31:0] io_cpu_fetch_mmuRsp_physicalAddress,
    input  wire        io_cpu_fetch_mmuRsp_isIoAccess,
    input  wire        io_cpu_fetch_mmuRsp_isPaging,
    input  wire        io_cpu_fetch_mmuRsp_allowRead,
    input  wire        io_cpu_fetch_mmuRsp_allowWrite,
    input  wire        io_cpu_fetch_mmuRsp_allowExecute,
    input  wire        io_cpu_fetch_mmuRsp_exception,
    input  wire        io_cpu_fetch_mmuRsp_refilling,
    input  wire        io_cpu_fetch_mmuRsp_bypassTranslation,
    output wire [31:0] io_cpu_fetch_physicalAddress,
    input  wire        io_cpu_decode_isValid,
    input  wire        io_cpu_decode_isStuck,
    input  wire [31:0] io_cpu_decode_pc,
    output wire [31:0] io_cpu_decode_physicalAddress,
    output wire [31:0] io_cpu_decode_data,
    output wire        io_cpu_decode_cacheMiss,
    output wire        io_cpu_decode_error,
    output wire        io_cpu_decode_mmuRefilling,
    output wire        io_cpu_decode_mmuException,
    input  wire        io_cpu_decode_isUser,
    input  wire        io_cpu_fill_valid,
    input  wire [31:0] io_cpu_fill_payload,
    output wire        io_mem_cmd_valid,
    input  wire        io_mem_cmd_ready,
    output wire [31:0] io_mem_cmd_payload_address,
    output wire [ 2:0] io_mem_cmd_payload_size,
    input  wire        io_mem_rsp_valid,
    input  wire [31:0] io_mem_rsp_payload_data,
    input  wire        io_mem_rsp_payload_error,
    input  wire [ 2:0] _zz_when_Fetcher_l411,
    input  wire [31:0] _zz_decodeStage_hit_data_1,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    reg  [31:0] banks_0_spinal_port1;
    reg  [21:0] ways_0_tags_spinal_port1;
    wire [21:0] _zz_ways_0_tags_port;
    reg         _zz_1;
    reg         _zz_2;
    reg         lineLoader_fire;
    reg         lineLoader_valid;
    (* keep , syn_keep *)reg  [31:0] lineLoader_address  /* synthesis syn_keep = 1 */;
    reg         lineLoader_hadError;
    reg         lineLoader_flushPending;
    reg  [ 7:0] lineLoader_flushCounter;
    wire        when_InstructionCache_l338;
    reg         _zz_when_InstructionCache_l342;
    wire        when_InstructionCache_l342;
    wire        when_InstructionCache_l351;
    reg         lineLoader_cmdSent;
    wire        io_mem_cmd_fire;
    wire        when_Utils_l578;
    reg         lineLoader_wayToAllocate_willIncrement;
    wire        lineLoader_wayToAllocate_willClear;
    wire        lineLoader_wayToAllocate_willOverflowIfInc;
    wire        lineLoader_wayToAllocate_willOverflow;
    (* keep , syn_keep *)reg  [ 2:0] lineLoader_wordIndex  /* synthesis syn_keep = 1 */;
    wire        lineLoader_write_tag_0_valid;
    wire [ 6:0] lineLoader_write_tag_0_payload_address;
    wire        lineLoader_write_tag_0_payload_data_valid;
    wire        lineLoader_write_tag_0_payload_data_error;
    wire [19:0] lineLoader_write_tag_0_payload_data_address;
    wire        lineLoader_write_data_0_valid;
    wire [ 9:0] lineLoader_write_data_0_payload_address;
    wire [31:0] lineLoader_write_data_0_payload_data;
    wire        when_InstructionCache_l401;
    wire [ 9:0] _zz_fetchStage_read_banksValue_0_dataMem;
    wire        _zz_fetchStage_read_banksValue_0_dataMem_1;
    wire [31:0] fetchStage_read_banksValue_0_dataMem;
    wire [31:0] fetchStage_read_banksValue_0_data;
    wire [ 6:0] _zz_fetchStage_read_waysValues_0_tag_valid;
    wire        _zz_fetchStage_read_waysValues_0_tag_valid_1;
    wire        fetchStage_read_waysValues_0_tag_valid;
    wire        fetchStage_read_waysValues_0_tag_error;
    wire [19:0] fetchStage_read_waysValues_0_tag_address;
    wire [21:0] _zz_fetchStage_read_waysValues_0_tag_valid_2;
    wire        when_InstructionCache_l459;
    reg  [31:0] decodeStage_mmuRsp_physicalAddress;
    reg         decodeStage_mmuRsp_isIoAccess;
    reg         decodeStage_mmuRsp_isPaging;
    reg         decodeStage_mmuRsp_allowRead;
    reg         decodeStage_mmuRsp_allowWrite;
    reg         decodeStage_mmuRsp_allowExecute;
    reg         decodeStage_mmuRsp_exception;
    reg         decodeStage_mmuRsp_refilling;
    reg         decodeStage_mmuRsp_bypassTranslation;
    wire        when_InstructionCache_l459_1;
    reg         decodeStage_hit_tags_0_valid;
    reg         decodeStage_hit_tags_0_error;
    reg  [19:0] decodeStage_hit_tags_0_address;
    wire        decodeStage_hit_hits_0;
    wire        decodeStage_hit_valid;
    wire        when_InstructionCache_l459_2;
    reg  [31:0] _zz_decodeStage_hit_data;
    wire [31:0] decodeStage_hit_data;
    wire        when_Fetcher_l411;
    reg  [31:0] banks_0                                            [0:1023];
    reg  [21:0] ways_0_tags                                        [ 0:127];

    assign _zz_ways_0_tags_port = {
        lineLoader_write_tag_0_payload_data_address,
        {lineLoader_write_tag_0_payload_data_error, lineLoader_write_tag_0_payload_data_valid}
    };
    always @(posedge io_axiClk) begin
        if (_zz_1) begin
            banks_0[lineLoader_write_data_0_payload_address] <= lineLoader_write_data_0_payload_data;
        end
    end

    always @(posedge io_axiClk) begin
        if (_zz_fetchStage_read_banksValue_0_dataMem_1) begin
            banks_0_spinal_port1 <= banks_0[_zz_fetchStage_read_banksValue_0_dataMem];
        end
    end

    always @(posedge io_axiClk) begin
        if (_zz_2) begin
            ways_0_tags[lineLoader_write_tag_0_payload_address] <= _zz_ways_0_tags_port;
        end
    end

    always @(posedge io_axiClk) begin
        if (_zz_fetchStage_read_waysValues_0_tag_valid_1) begin
            ways_0_tags_spinal_port1 <= ways_0_tags[_zz_fetchStage_read_waysValues_0_tag_valid];
        end
    end

    always @(*) begin
        _zz_1 = 1'b0;
        if (lineLoader_write_data_0_valid) begin
            _zz_1 = 1'b1;
        end
    end

    always @(*) begin
        _zz_2 = 1'b0;
        if (lineLoader_write_tag_0_valid) begin
            _zz_2 = 1'b1;
        end
    end

    always @(*) begin
        lineLoader_fire = 1'b0;
        if (io_mem_rsp_valid) begin
            if (when_InstructionCache_l401) begin
                lineLoader_fire = 1'b1;
            end
        end
    end

    always @(*) begin
        io_cpu_prefetch_haltIt = (lineLoader_valid || lineLoader_flushPending);
        if (when_InstructionCache_l338) begin
            io_cpu_prefetch_haltIt = 1'b1;
        end
        if (when_InstructionCache_l342) begin
            io_cpu_prefetch_haltIt = 1'b1;
        end
        if (io_flush) begin
            io_cpu_prefetch_haltIt = 1'b1;
        end
    end

    assign when_InstructionCache_l338 = (!lineLoader_flushCounter[7]);
    assign when_InstructionCache_l342 = (!_zz_when_InstructionCache_l342);
    assign when_InstructionCache_l351 = (lineLoader_flushPending && (! (lineLoader_valid || io_cpu_fetch_isValid)));
    assign io_mem_cmd_fire = (io_mem_cmd_valid && io_mem_cmd_ready);
    assign io_mem_cmd_valid = (lineLoader_valid && (!lineLoader_cmdSent));
    assign io_mem_cmd_payload_address = {lineLoader_address[31:5], 5'h0};
    assign io_mem_cmd_payload_size = 3'b101;
    assign when_Utils_l578 = (!lineLoader_valid);
    always @(*) begin
        lineLoader_wayToAllocate_willIncrement = 1'b0;
        if (when_Utils_l578) begin
            lineLoader_wayToAllocate_willIncrement = 1'b1;
        end
    end

    assign lineLoader_wayToAllocate_willClear = 1'b0;
    assign lineLoader_wayToAllocate_willOverflowIfInc = 1'b1;
    assign lineLoader_wayToAllocate_willOverflow = (lineLoader_wayToAllocate_willOverflowIfInc && lineLoader_wayToAllocate_willIncrement);
    assign lineLoader_write_tag_0_valid = ((1'b1 && lineLoader_fire) || (! lineLoader_flushCounter[7]));
    assign lineLoader_write_tag_0_payload_address = (lineLoader_flushCounter[7] ? lineLoader_address[11:5]:lineLoader_flushCounter[6:0]);
    assign lineLoader_write_tag_0_payload_data_valid = lineLoader_flushCounter[7];
    assign lineLoader_write_tag_0_payload_data_error = (lineLoader_hadError || io_mem_rsp_payload_error);
    assign lineLoader_write_tag_0_payload_data_address = lineLoader_address[31:12];
    assign lineLoader_write_data_0_valid = (io_mem_rsp_valid && 1'b1);
    assign lineLoader_write_data_0_payload_address = {
        lineLoader_address[11:5], lineLoader_wordIndex
    };
    assign lineLoader_write_data_0_payload_data = io_mem_rsp_payload_data;
    assign when_InstructionCache_l401 = (lineLoader_wordIndex == 3'b111);
    assign _zz_fetchStage_read_banksValue_0_dataMem = io_cpu_prefetch_pc[11:2];
    assign _zz_fetchStage_read_banksValue_0_dataMem_1 = (!io_cpu_fetch_isStuck);
    assign fetchStage_read_banksValue_0_dataMem = banks_0_spinal_port1;
    assign fetchStage_read_banksValue_0_data = fetchStage_read_banksValue_0_dataMem[31:0];
    assign _zz_fetchStage_read_waysValues_0_tag_valid = io_cpu_prefetch_pc[11:5];
    assign _zz_fetchStage_read_waysValues_0_tag_valid_1 = (!io_cpu_fetch_isStuck);
    assign _zz_fetchStage_read_waysValues_0_tag_valid_2 = ways_0_tags_spinal_port1;
    assign fetchStage_read_waysValues_0_tag_valid = _zz_fetchStage_read_waysValues_0_tag_valid_2[0];
    assign fetchStage_read_waysValues_0_tag_error = _zz_fetchStage_read_waysValues_0_tag_valid_2[1];
    assign fetchStage_read_waysValues_0_tag_address = _zz_fetchStage_read_waysValues_0_tag_valid_2[21:2];
    assign io_cpu_fetch_data = fetchStage_read_banksValue_0_data;
    assign io_cpu_fetch_physicalAddress = io_cpu_fetch_mmuRsp_physicalAddress;
    assign when_InstructionCache_l459 = (!io_cpu_decode_isStuck);
    assign when_InstructionCache_l459_1 = (!io_cpu_decode_isStuck);
    assign decodeStage_hit_hits_0 = (decodeStage_hit_tags_0_valid && (decodeStage_hit_tags_0_address == decodeStage_mmuRsp_physicalAddress[31:12]));
    assign decodeStage_hit_valid = (|decodeStage_hit_hits_0);
    assign when_InstructionCache_l459_2 = (!io_cpu_decode_isStuck);
    assign decodeStage_hit_data = _zz_decodeStage_hit_data;
    assign io_cpu_decode_data = decodeStage_hit_data;
    assign io_cpu_decode_cacheMiss = (!decodeStage_hit_valid);
    assign io_cpu_decode_error = (decodeStage_hit_tags_0_error || ((! decodeStage_mmuRsp_isPaging) && (decodeStage_mmuRsp_exception || (! decodeStage_mmuRsp_allowExecute))));
    assign io_cpu_decode_mmuRefilling = decodeStage_mmuRsp_refilling;
    assign io_cpu_decode_mmuException = (((! decodeStage_mmuRsp_refilling) && decodeStage_mmuRsp_isPaging) && (decodeStage_mmuRsp_exception || (! decodeStage_mmuRsp_allowExecute)));
    assign io_cpu_decode_physicalAddress = decodeStage_mmuRsp_physicalAddress;
    assign when_Fetcher_l411 = (_zz_when_Fetcher_l411 != 3'b000);
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            lineLoader_valid <= 1'b0;
            lineLoader_hadError <= 1'b0;
            lineLoader_flushPending <= 1'b1;
            lineLoader_cmdSent <= 1'b0;
            lineLoader_wordIndex <= 3'b000;
        end else begin
            if (lineLoader_fire) begin
                lineLoader_valid <= 1'b0;
            end
            if (lineLoader_fire) begin
                lineLoader_hadError <= 1'b0;
            end
            if (io_cpu_fill_valid) begin
                lineLoader_valid <= 1'b1;
            end
            if (io_flush) begin
                lineLoader_flushPending <= 1'b1;
            end
            if (when_InstructionCache_l351) begin
                lineLoader_flushPending <= 1'b0;
            end
            if (io_mem_cmd_fire) begin
                lineLoader_cmdSent <= 1'b1;
            end
            if (lineLoader_fire) begin
                lineLoader_cmdSent <= 1'b0;
            end
            if (io_mem_rsp_valid) begin
                lineLoader_wordIndex <= (lineLoader_wordIndex + 3'b001);
                if (io_mem_rsp_payload_error) begin
                    lineLoader_hadError <= 1'b1;
                end
            end
        end
    end

    always @(posedge io_axiClk) begin
        if (io_cpu_fill_valid) begin
            lineLoader_address <= io_cpu_fill_payload;
        end
        if (when_InstructionCache_l338) begin
            lineLoader_flushCounter <= (lineLoader_flushCounter + 8'h01);
        end
        _zz_when_InstructionCache_l342 <= lineLoader_flushCounter[7];
        if (when_InstructionCache_l351) begin
            lineLoader_flushCounter <= 8'h0;
        end
        if (when_InstructionCache_l459) begin
            decodeStage_mmuRsp_physicalAddress <= io_cpu_fetch_mmuRsp_physicalAddress;
            decodeStage_mmuRsp_isIoAccess <= io_cpu_fetch_mmuRsp_isIoAccess;
            decodeStage_mmuRsp_isPaging <= io_cpu_fetch_mmuRsp_isPaging;
            decodeStage_mmuRsp_allowRead <= io_cpu_fetch_mmuRsp_allowRead;
            decodeStage_mmuRsp_allowWrite <= io_cpu_fetch_mmuRsp_allowWrite;
            decodeStage_mmuRsp_allowExecute <= io_cpu_fetch_mmuRsp_allowExecute;
            decodeStage_mmuRsp_exception <= io_cpu_fetch_mmuRsp_exception;
            decodeStage_mmuRsp_refilling <= io_cpu_fetch_mmuRsp_refilling;
            decodeStage_mmuRsp_bypassTranslation <= io_cpu_fetch_mmuRsp_bypassTranslation;
        end
        if (when_InstructionCache_l459_1) begin
            decodeStage_hit_tags_0_valid   <= fetchStage_read_waysValues_0_tag_valid;
            decodeStage_hit_tags_0_error   <= fetchStage_read_waysValues_0_tag_error;
            decodeStage_hit_tags_0_address <= fetchStage_read_waysValues_0_tag_address;
        end
        if (when_InstructionCache_l459_2) begin
            _zz_decodeStage_hit_data <= fetchStage_read_banksValue_0_data;
        end
        if (when_Fetcher_l411) begin
            _zz_decodeStage_hit_data <= _zz_decodeStage_hit_data_1;
        end
    end

endmodule


module StreamFifo_3 (
    input  wire       io_push_valid,
    output wire       io_push_ready,
    output reg        io_pop_valid,
    input  wire       io_pop_ready,
    input  wire       io_flush,
    output wire [2:0] io_occupancy,
    output wire [2:0] io_availability,
    input  wire       io_axiClk,
    input  wire       resetCtrl_axiReset
);

    reg        logic_ptr_doPush;
    wire       logic_ptr_doPop;
    wire       logic_ptr_full;
    wire       logic_ptr_empty;
    reg  [2:0] logic_ptr_push;
    reg  [2:0] logic_ptr_pop;
    wire [2:0] logic_ptr_occupancy;
    wire [2:0] logic_ptr_popOnIo;
    wire       when_Stream_l1248;
    reg        logic_ptr_wentUp;
    wire       io_push_fire;
    wire       logic_push_onRam_write_valid;
    wire [1:0] logic_push_onRam_write_payload_address;
    wire       logic_pop_addressGen_valid;
    wire       logic_pop_addressGen_ready;
    wire [1:0] logic_pop_addressGen_payload;
    wire       logic_pop_addressGen_fire;
    wire       logic_pop_addressGen_translated_valid;
    wire       logic_pop_addressGen_translated_ready;

    assign when_Stream_l1248 = (logic_ptr_doPush != logic_ptr_doPop);
    assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 3'b100) == 3'b000);
    assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
    assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
    assign io_push_ready = (!logic_ptr_full);
    assign io_push_fire = (io_push_valid && io_push_ready);
    always @(*) begin
        logic_ptr_doPush = io_push_fire;
        if (logic_ptr_empty) begin
            if (io_pop_ready) begin
                logic_ptr_doPush = 1'b0;
            end
        end
    end

    assign logic_push_onRam_write_valid = io_push_fire;
    assign logic_push_onRam_write_payload_address = logic_ptr_push[1:0];
    assign logic_pop_addressGen_valid = (!logic_ptr_empty);
    assign logic_pop_addressGen_payload = logic_ptr_pop[1:0];
    assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
    assign logic_ptr_doPop = logic_pop_addressGen_fire;
    assign logic_pop_addressGen_translated_valid = logic_pop_addressGen_valid;
    assign logic_pop_addressGen_ready = logic_pop_addressGen_translated_ready;
    always @(*) begin
        io_pop_valid = logic_pop_addressGen_translated_valid;
        if (logic_ptr_empty) begin
            io_pop_valid = io_push_valid;
        end
    end

    assign logic_pop_addressGen_translated_ready = io_pop_ready;
    assign logic_ptr_popOnIo = logic_ptr_pop;
    assign io_occupancy = logic_ptr_occupancy;
    assign io_availability = (3'b100 - logic_ptr_occupancy);
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            logic_ptr_push <= 3'b000;
            logic_ptr_pop <= 3'b000;
            logic_ptr_wentUp <= 1'b0;
        end else begin
            if (when_Stream_l1248) begin
                logic_ptr_wentUp <= logic_ptr_doPush;
            end
            if (io_flush) begin
                logic_ptr_wentUp <= 1'b0;
            end
            if (logic_ptr_doPush) begin
                logic_ptr_push <= (logic_ptr_push + 3'b001);
            end
            if (logic_ptr_doPop) begin
                logic_ptr_pop <= (logic_ptr_pop + 3'b001);
            end
            if (io_flush) begin
                logic_ptr_push <= 3'b000;
                logic_ptr_pop  <= 3'b000;
            end
        end
    end

endmodule


module BufferCC_5 (
    input  wire io_dataIn,
    output wire io_dataOut,
    input  wire io_axiClk,
    input  wire resetCtrl_systemReset
);

    (* async_reg = "true" *)reg buffers_0;
    (* async_reg = "true" *)reg buffers_1;

    initial begin
`ifndef SYNTHESIS
        buffers_0 = $urandom;
        buffers_1 = $urandom;
`endif
    end

    assign io_dataOut = buffers_1;
    always @(posedge io_axiClk) begin
        buffers_0 <= io_dataIn;
        buffers_1 <= buffers_0;
    end

endmodule

