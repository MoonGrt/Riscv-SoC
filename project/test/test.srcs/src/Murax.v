`timescale 1ns / 1ps

module Murax (
    input  wire        io_asyncReset,
    input  wire        io_mainClk,
    input  wire        io_jtag_tms,
    input  wire        io_jtag_tdi,
    output wire        io_jtag_tdo,
    input  wire        io_jtag_tck,

    inout  wire [15:0] GPIOA,  // GPIO2
    inout  wire [15:0] GPIOB,  // GPIO2

    input  wire [31:0] io_gpioA_read,
    output wire [31:0] io_gpioA_write,
    output wire [31:0] io_gpioA_writeEnable,
    output wire        io_uart_txd,
    input  wire        io_uart_rxd
);

    /* GPIO AFIO */
    // USART
    wire        USART1_TX;
    wire        USART1_RX = GPIOB[1];
    wire        USART2_TX;
    wire        USART2_RX = GPIOB[3];
    // I2C
    wire        I2C1_SDA;  // 有问题
    wire        I2C1_SCL;
    wire        I2C2_SDA;
    wire        I2C2_SCL;
    // SPI
    wire        SPI1_SCK;
    wire        SPI1_MOSI;
    wire        SPI1_MISO = GPIOB[10];
    wire        SPI1_CS;
    wire        SPI2_SCK;
    wire        SPI2_MOSI;
    wire        SPI2_MISO = GPIOB[14];
    wire        SPI2_CS;
    // TIM
    wire [ 3:0] TIM2_CH;
    wire [ 3:0] TIM3_CH;
    // AFIO Contection
    wire [15:0] AFIOA = {TIM3_CH, TIM2_CH, 8'bz};
    wire [15:0] AFIOB = {SPI2_CS, 1'bz, SPI2_MOSI, SPI2_SCK, SPI1_CS, 1'bz, SPI1_MOSI, SPI1_SCK, 
                         I2C2_SDA, I2C2_SCL, I2C1_SDA, I2C1_SCL, 1'bz, USART2_TX, 1'bz, USART1_TX};
    // Interrupt
    reg         system_externalInterrupt, system_timerInterrupt;
    wire        timer_interrupt, uart_interrupt;
    wire        USART1_interrupt, USART2_interrupt;
    wire        TIM2_interrupt, TIM3_interrupt;

    wire [ 7:0] system_cpu_debug_bus_cmd_payload_address;
    wire        system_cpu_dBus_cmd_ready;
    reg         system_ram_io_bus_cmd_valid;
    reg         system_apbBridge_io_pipelinedMemoryBus_cmd_valid;
    wire [ 3:0] system_gpioACtrl_io_apb_PADDR;
    wire [15:0] system_gpioCtrl_io_apb_PADDR;  // GPIO2 PADDR
    wire [ 4:0] system_uartCtrl_io_apb_PADDR;
    wire [ 7:0] system_timer_io_apb_PADDR;
    wire [15:0] system_wdgCtrl_io_apb_PADDR;  // WDG PADDR
    wire [15:0] system_usartCtrl_io_apb_PADDR;  // USART PADDR
    wire [15:0] system_i2cCtrl_io_apb_PADDR;  // I2C PADDR
    wire [15:0] system_spiCtrl_io_apb_PADDR;  // SPI PADDR
    wire [15:0] system_timCtrl_io_apb_PADDR;  // TIM PADDR
    wire        io_asyncReset_buffercc_io_dataOut;
    wire        system_mainBusArbiter_io_iBus_cmd_ready;
    wire        system_mainBusArbiter_io_iBus_rsp_valid;
    wire        system_mainBusArbiter_io_iBus_rsp_payload_error;
    wire [31:0] system_mainBusArbiter_io_iBus_rsp_payload_inst;
    wire        system_mainBusArbiter_io_dBus_cmd_ready;
    wire        system_mainBusArbiter_io_dBus_rsp_ready;
    wire        system_mainBusArbiter_io_dBus_rsp_error;
    wire [31:0] system_mainBusArbiter_io_dBus_rsp_data;
    wire        system_mainBusArbiter_io_masterBus_cmd_valid;
    wire        system_mainBusArbiter_io_masterBus_cmd_payload_write;
    wire [31:0] system_mainBusArbiter_io_masterBus_cmd_payload_address;
    wire [31:0] system_mainBusArbiter_io_masterBus_cmd_payload_data;
    wire [ 3:0] system_mainBusArbiter_io_masterBus_cmd_payload_mask;
    wire        system_cpu_iBus_cmd_valid;
    wire [31:0] system_cpu_iBus_cmd_payload_pc;
    wire        system_cpu_debug_bus_cmd_ready;
    wire [31:0] system_cpu_debug_bus_rsp_data;
    wire        system_cpu_debug_resetOut;
    wire        system_cpu_dBus_cmd_valid;
    wire        system_cpu_dBus_cmd_payload_wr;
    wire [ 3:0] system_cpu_dBus_cmd_payload_mask;
    wire [31:0] system_cpu_dBus_cmd_payload_address;
    wire [31:0] system_cpu_dBus_cmd_payload_data;
    wire [ 1:0] system_cpu_dBus_cmd_payload_size;
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
    wire        system_ram_io_bus_cmd_ready;
    wire        system_ram_io_bus_rsp_valid;
    wire [31:0] system_ram_io_bus_rsp_payload_data;
    wire        system_apbBridge_io_pipelinedMemoryBus_cmd_ready;
    wire        system_apbBridge_io_pipelinedMemoryBus_rsp_valid;
    wire [31:0] system_apbBridge_io_pipelinedMemoryBus_rsp_payload_data;
    wire [19:0] system_apbBridge_io_apb_PADDR;
    wire [ 0:0] system_apbBridge_io_apb_PSEL;
    wire        system_apbBridge_io_apb_PENABLE;
    wire        system_apbBridge_io_apb_PWRITE;
    wire [31:0] system_apbBridge_io_apb_PWDATA;
    wire        system_gpioACtrl_io_apb_PREADY;
    wire [31:0] system_gpioACtrl_io_apb_PRDATA;
    wire        system_gpioACtrl_io_apb_PSLVERROR;
    wire [31:0] system_gpioACtrl_io_gpio_write;
    wire [31:0] system_gpioACtrl_io_gpio_writeEnable;
    wire        system_gpioCtrl_io_apb_PREADY;        // GPIO2
    wire [31:0] system_gpioCtrl_io_apb_PRDATA;        // GPIO2
    wire        system_gpioCtrl_io_apb_PSLVERROR;     // GPIO2
    wire [31:0] system_gpioCtrl_io_gpio_write;        // GPIO2
    wire [31:0] system_gpioCtrl_io_gpio_writeEnable;  // GPIO2
    wire        system_wdgCtrl_io_apb_PREADY;         // WDG
    wire [31:0] system_wdgCtrl_io_apb_PRDATA;         // WDG
    wire        system_wdgCtrl_io_apb_PSLVERROR;      // WDG
    wire [31:0] system_wdgCtrl_io_gpio_write;         // WDG
    wire [31:0] system_wdgCtrl_io_gpio_writeEnable;   // WDG
    wire        system_usartCtrl_io_apb_PREADY;         // USART
    wire [31:0] system_usartCtrl_io_apb_PRDATA;         // USART
    wire        system_usartCtrl_io_apb_PSLVERROR;      // USART
    wire [31:0] system_usartCtrl_io_gpio_write;         // USART
    wire [31:0] system_usartCtrl_io_gpio_writeEnable;   // USART
    wire        system_i2cCtrl_io_apb_PREADY;         // I2C
    wire [31:0] system_i2cCtrl_io_apb_PRDATA;         // I2C
    wire        system_i2cCtrl_io_apb_PSLVERROR;      // I2C
    wire [31:0] system_i2cCtrl_io_gpio_write;         // I2C
    wire [31:0] system_i2cCtrl_io_gpio_writeEnable;   // I2C
    wire        system_spiCtrl_io_apb_PREADY;         // SPI
    wire [31:0] system_spiCtrl_io_apb_PRDATA;         // SPI
    wire        system_spiCtrl_io_apb_PSLVERROR;      // SPI
    wire [31:0] system_spiCtrl_io_gpio_write;         // SPI
    wire [31:0] system_spiCtrl_io_gpio_writeEnable;   // SPI
    wire        system_timCtrl_io_apb_PREADY;         // TIM
    wire [31:0] system_timCtrl_io_apb_PRDATA;         // TIM
    wire        system_timCtrl_io_apb_PSLVERROR;      // TIM
    wire [31:0] system_timCtrl_io_gpio_write;         // TIM
    wire [31:0] system_timCtrl_io_gpio_writeEnable;   // TIM
    wire        system_uartCtrl_io_apb_PREADY;
    wire [31:0] system_uartCtrl_io_apb_PRDATA;
    wire        system_uartCtrl_io_uart_txd;
    wire        system_uartCtrl_io_interrupt;
    wire        system_timer_io_apb_PREADY;
    wire [31:0] system_timer_io_apb_PRDATA;
    wire        system_timer_io_apb_PSLVERROR;
    wire        system_timer_io_interrupt;
    wire        io_apb_decoder_io_input_PREADY;
    wire [31:0] io_apb_decoder_io_input_PRDATA;
    wire        io_apb_decoder_io_input_PSLVERROR;
    wire [19:0] io_apb_decoder_io_output_PADDR;
    wire [15:0] io_apb_decoder_io_output_PSEL;
    wire        io_apb_decoder_io_output_PENABLE;
    wire        io_apb_decoder_io_output_PWRITE;
    wire [31:0] io_apb_decoder_io_output_PWDATA;
    wire        apb3Router_1_io_input_PREADY;
    wire [31:0] apb3Router_1_io_input_PRDATA;
    wire        apb3Router_1_io_input_PSLVERROR;
    wire [19:0] apb3Router_1_io_outputs_0_PADDR;
    wire [ 0:0] apb3Router_1_io_outputs_0_PSEL;
    wire        apb3Router_1_io_outputs_0_PENABLE;
    wire        apb3Router_1_io_outputs_0_PWRITE;
    wire [31:0] apb3Router_1_io_outputs_0_PWDATA;
    wire [19:0] apb3Router_1_io_outputs_1_PADDR;
    wire [ 0:0] apb3Router_1_io_outputs_1_PSEL;
    wire        apb3Router_1_io_outputs_1_PENABLE;
    wire        apb3Router_1_io_outputs_1_PWRITE;
    wire [31:0] apb3Router_1_io_outputs_1_PWDATA;
    wire [19:0] apb3Router_1_io_outputs_2_PADDR;
    wire [ 0:0] apb3Router_1_io_outputs_2_PSEL;
    wire        apb3Router_1_io_outputs_2_PENABLE;
    wire        apb3Router_1_io_outputs_2_PWRITE;
    wire [31:0] apb3Router_1_io_outputs_2_PWDATA;
    wire [19:0] apb3Router_1_io_outputs_3_PADDR;  // GPIO2
    wire [ 0:0] apb3Router_1_io_outputs_3_PSEL;  // GPIO2
    wire        apb3Router_1_io_outputs_3_PENABLE;  // GPIO2
    wire        apb3Router_1_io_outputs_3_PWRITE;  // GPIO2
    wire [31:0] apb3Router_1_io_outputs_3_PWDATA;  // GPIO2
    wire [19:0] apb3Router_1_io_outputs_4_PADDR;  // WDG
    wire [ 0:0] apb3Router_1_io_outputs_4_PSEL;  // WDG
    wire        apb3Router_1_io_outputs_4_PENABLE;  // WDG
    wire        apb3Router_1_io_outputs_4_PWRITE;  // WDG
    wire [31:0] apb3Router_1_io_outputs_4_PWDATA;  // WDG
    wire [19:0] apb3Router_1_io_outputs_5_PADDR;  // USART
    wire [ 0:0] apb3Router_1_io_outputs_5_PSEL;  // USART
    wire        apb3Router_1_io_outputs_5_PENABLE;  // USART
    wire        apb3Router_1_io_outputs_5_PWRITE;  // USART
    wire [31:0] apb3Router_1_io_outputs_5_PWDATA;  // USART
    wire [19:0] apb3Router_1_io_outputs_6_PADDR;  // I2C
    wire [ 0:0] apb3Router_1_io_outputs_6_PSEL;  // I2C
    wire        apb3Router_1_io_outputs_6_PENABLE;  // I2C
    wire        apb3Router_1_io_outputs_6_PWRITE;  // I2C
    wire [31:0] apb3Router_1_io_outputs_6_PWDATA;  // I2C
    wire [19:0] apb3Router_1_io_outputs_7_PADDR;  // SPI
    wire [ 0:0] apb3Router_1_io_outputs_7_PSEL;  // SPI
    wire        apb3Router_1_io_outputs_7_PENABLE;  // SPI
    wire        apb3Router_1_io_outputs_7_PWRITE;  // SPI
    wire [31:0] apb3Router_1_io_outputs_7_PWDATA;  // SPI
    wire [19:0] apb3Router_1_io_outputs_8_PADDR;  // TIM
    wire [ 0:0] apb3Router_1_io_outputs_8_PSEL;  // TIM
    wire        apb3Router_1_io_outputs_8_PENABLE;  // TIM
    wire        apb3Router_1_io_outputs_8_PWRITE;  // TIM
    wire [31:0] apb3Router_1_io_outputs_8_PWDATA;  // TIM
    reg  [31:0] _zz_system_mainBusDecoder_logic_masterPipelined_rsp_payload_data;
    reg         resetCtrl_mainClkResetUnbuffered;
    reg  [ 5:0] resetCtrl_systemClkResetCounter;
    wire [ 5:0] _zz_when_Murax_l188;
    wire        when_Murax_l188;
    wire        when_Murax_l192;
    reg         resetCtrl_mainClkReset;
    reg         resetCtrl_systemReset;
    wire        toplevel_system_cpu_dBus_cmd_halfPipe_valid;
    wire        toplevel_system_cpu_dBus_cmd_halfPipe_ready;
    wire        toplevel_system_cpu_dBus_cmd_halfPipe_payload_wr;
    wire [ 3:0] toplevel_system_cpu_dBus_cmd_halfPipe_payload_mask;
    wire [31:0] toplevel_system_cpu_dBus_cmd_halfPipe_payload_address;
    wire [31:0] toplevel_system_cpu_dBus_cmd_halfPipe_payload_data;
    wire [ 1:0] toplevel_system_cpu_dBus_cmd_halfPipe_payload_size;
    reg         toplevel_system_cpu_dBus_cmd_rValid;
    wire        toplevel_system_cpu_dBus_cmd_halfPipe_fire;
    reg         toplevel_system_cpu_dBus_cmd_rData_wr;
    reg  [ 3:0] toplevel_system_cpu_dBus_cmd_rData_mask;
    reg  [31:0] toplevel_system_cpu_dBus_cmd_rData_address;
    reg  [31:0] toplevel_system_cpu_dBus_cmd_rData_data;
    reg  [ 1:0] toplevel_system_cpu_dBus_cmd_rData_size;
    reg         toplevel_system_cpu_debug_resetOut_regNext;
    wire        toplevel_system_cpu_debug_bus_cmd_fire;
    reg         toplevel_system_cpu_debug_bus_cmd_fire_regNext;
    wire        system_mainBusDecoder_logic_masterPipelined_cmd_valid;
    reg         system_mainBusDecoder_logic_masterPipelined_cmd_ready;
    wire        system_mainBusDecoder_logic_masterPipelined_cmd_payload_write;
    wire [31:0] system_mainBusDecoder_logic_masterPipelined_cmd_payload_address;
    wire [31:0] system_mainBusDecoder_logic_masterPipelined_cmd_payload_data;
    wire [ 3:0] system_mainBusDecoder_logic_masterPipelined_cmd_payload_mask;
    wire        system_mainBusDecoder_logic_masterPipelined_rsp_valid;
    wire [31:0] system_mainBusDecoder_logic_masterPipelined_rsp_payload_data;
    wire        system_mainBusDecoder_logic_hits_0;
    wire        _zz_io_bus_cmd_payload_write;
    wire        system_mainBusDecoder_logic_hits_1;
    wire        _zz_io_pipelinedMemoryBus_cmd_payload_write;
    wire        system_mainBusDecoder_logic_noHit;
    reg         system_mainBusDecoder_logic_rspPending;
    wire        system_mainBusDecoder_logic_masterPipelined_cmd_fire;
    wire        when_MuraxUtiles_l127;
    reg         system_mainBusDecoder_logic_rspNoHit;
    reg  [ 0:0] system_mainBusDecoder_logic_rspSourceId;
    wire        when_MuraxUtiles_l133;

    (* keep_hierarchy = "TRUE" *) BufferCC_RST asyncReset (
        .io_dataIn (io_asyncReset),                      // i
        .io_dataOut(io_asyncReset_buffercc_io_dataOut),  // o
        .io_mainClk(io_mainClk)                          // i
    );
    MasterArbiter MasterArbiter (
        .io_iBus_cmd_valid(system_cpu_iBus_cmd_valid),  // i
        .io_iBus_cmd_ready(system_mainBusArbiter_io_iBus_cmd_ready),  // o
        .io_iBus_cmd_payload_pc(system_cpu_iBus_cmd_payload_pc[31:0]),  // i
        .io_iBus_rsp_valid(system_mainBusArbiter_io_iBus_rsp_valid),  // o
        .io_iBus_rsp_payload_error(system_mainBusArbiter_io_iBus_rsp_payload_error),  // o
        .io_iBus_rsp_payload_inst(system_mainBusArbiter_io_iBus_rsp_payload_inst[31:0]),  // o
        .io_dBus_cmd_valid(toplevel_system_cpu_dBus_cmd_halfPipe_valid),  // i
        .io_dBus_cmd_ready(system_mainBusArbiter_io_dBus_cmd_ready),  // o
        .io_dBus_cmd_payload_wr(toplevel_system_cpu_dBus_cmd_halfPipe_payload_wr),  // i
        .io_dBus_cmd_payload_mask(toplevel_system_cpu_dBus_cmd_halfPipe_payload_mask[3:0]),  // i
        .io_dBus_cmd_payload_address(toplevel_system_cpu_dBus_cmd_halfPipe_payload_address[31:0]), // i
        .io_dBus_cmd_payload_data(toplevel_system_cpu_dBus_cmd_halfPipe_payload_data[31:0]),  // i
        .io_dBus_cmd_payload_size(toplevel_system_cpu_dBus_cmd_halfPipe_payload_size[1:0]),  // i
        .io_dBus_rsp_ready(system_mainBusArbiter_io_dBus_rsp_ready),  // o
        .io_dBus_rsp_error(system_mainBusArbiter_io_dBus_rsp_error),  // o
        .io_dBus_rsp_data(system_mainBusArbiter_io_dBus_rsp_data[31:0]),  // o
        .io_masterBus_cmd_valid(system_mainBusArbiter_io_masterBus_cmd_valid),  // o
        .io_masterBus_cmd_ready(system_mainBusDecoder_logic_masterPipelined_cmd_ready),  // i
        .io_masterBus_cmd_payload_write(system_mainBusArbiter_io_masterBus_cmd_payload_write),  // o
        .io_masterBus_cmd_payload_address(system_mainBusArbiter_io_masterBus_cmd_payload_address[31:0]), // o
        .io_masterBus_cmd_payload_data(system_mainBusArbiter_io_masterBus_cmd_payload_data[31:0]), // o
        .io_masterBus_cmd_payload_mask(system_mainBusArbiter_io_masterBus_cmd_payload_mask[3:0]), // o
        .io_masterBus_rsp_valid(system_mainBusDecoder_logic_masterPipelined_rsp_valid),  // i
        .io_masterBus_rsp_payload_data(system_mainBusDecoder_logic_masterPipelined_rsp_payload_data[31:0]), // i
        .io_mainClk(io_mainClk),  // i
        .resetCtrl_systemReset(resetCtrl_systemReset)  // i
    );
    VexRiscv VexRiscv (
        .iBus_cmd_valid               (system_cpu_iBus_cmd_valid),                             // o
        .iBus_cmd_ready               (system_mainBusArbiter_io_iBus_cmd_ready),               // i
        .iBus_cmd_payload_pc          (system_cpu_iBus_cmd_payload_pc[31:0]),                  // o
        .iBus_rsp_valid               (system_mainBusArbiter_io_iBus_rsp_valid),               // i
        .iBus_rsp_payload_error       (system_mainBusArbiter_io_iBus_rsp_payload_error),       // i
        .iBus_rsp_payload_inst        (system_mainBusArbiter_io_iBus_rsp_payload_inst[31:0]),  // i
        .timerInterrupt               (system_timerInterrupt),                                 // i
        .externalInterrupt            (system_externalInterrupt),                              // i
        .softwareInterrupt            (1'b0),                                                  // i
        .debug_bus_cmd_valid          (systemDebugger_1_io_mem_cmd_valid),                     // i
        .debug_bus_cmd_ready          (system_cpu_debug_bus_cmd_ready),                        // o
        .debug_bus_cmd_payload_wr     (systemDebugger_1_io_mem_cmd_payload_wr),                // i
        .debug_bus_cmd_payload_address(system_cpu_debug_bus_cmd_payload_address[7:0]),         // i
        .debug_bus_cmd_payload_data   (systemDebugger_1_io_mem_cmd_payload_data[31:0]),        // i
        .debug_bus_rsp_data           (system_cpu_debug_bus_rsp_data[31:0]),                   // o
        .debug_resetOut               (system_cpu_debug_resetOut),                             // o
        .dBus_cmd_valid               (system_cpu_dBus_cmd_valid),                             // o
        .dBus_cmd_ready               (system_cpu_dBus_cmd_ready),                             // i
        .dBus_cmd_payload_wr          (system_cpu_dBus_cmd_payload_wr),                        // o
        .dBus_cmd_payload_mask        (system_cpu_dBus_cmd_payload_mask[3:0]),                 // o
        .dBus_cmd_payload_address     (system_cpu_dBus_cmd_payload_address[31:0]),             // o
        .dBus_cmd_payload_data        (system_cpu_dBus_cmd_payload_data[31:0]),                // o
        .dBus_cmd_payload_size        (system_cpu_dBus_cmd_payload_size[1:0]),                 // o
        .dBus_rsp_ready               (system_mainBusArbiter_io_dBus_rsp_ready),               // i
        .dBus_rsp_error               (system_mainBusArbiter_io_dBus_rsp_error),               // i
        .dBus_rsp_data                (system_mainBusArbiter_io_dBus_rsp_data[31:0]),          // i
        .io_mainClk                   (io_mainClk),                                            // i
        .resetCtrl_systemReset        (resetCtrl_systemReset),                                 // i
        .resetCtrl_mainClkReset       (resetCtrl_mainClkReset)                                 // i
    );
    JtagBridge JtagBridge (
        .io_jtag_tms                   (io_jtag_tms),                                        // i
        .io_jtag_tdi                   (io_jtag_tdi),                                        // i
        .io_jtag_tdo                   (jtagBridge_1_io_jtag_tdo),                           // o
        .io_jtag_tck                   (io_jtag_tck),                                        // i
        .io_remote_cmd_valid           (jtagBridge_1_io_remote_cmd_valid),                   // o
        .io_remote_cmd_ready           (systemDebugger_1_io_remote_cmd_ready),               // i
        .io_remote_cmd_payload_last    (jtagBridge_1_io_remote_cmd_payload_last),            // o
        .io_remote_cmd_payload_fragment(jtagBridge_1_io_remote_cmd_payload_fragment),        // o
        .io_remote_rsp_valid           (systemDebugger_1_io_remote_rsp_valid),               // i
        .io_remote_rsp_ready           (jtagBridge_1_io_remote_rsp_ready),                   // o
        .io_remote_rsp_payload_error   (systemDebugger_1_io_remote_rsp_payload_error),       // i
        .io_remote_rsp_payload_data    (systemDebugger_1_io_remote_rsp_payload_data[31:0]),  // i
        .io_mainClk                    (io_mainClk),                                         // i
        .resetCtrl_mainClkReset        (resetCtrl_mainClkReset)                              // i
    );
    Debugger Debugger (
        .io_remote_cmd_valid           (jtagBridge_1_io_remote_cmd_valid),                   // i
        .io_remote_cmd_ready           (systemDebugger_1_io_remote_cmd_ready),               // o
        .io_remote_cmd_payload_last    (jtagBridge_1_io_remote_cmd_payload_last),            // i
        .io_remote_cmd_payload_fragment(jtagBridge_1_io_remote_cmd_payload_fragment),        // i
        .io_remote_rsp_valid           (systemDebugger_1_io_remote_rsp_valid),               // o
        .io_remote_rsp_ready           (jtagBridge_1_io_remote_rsp_ready),                   // i
        .io_remote_rsp_payload_error   (systemDebugger_1_io_remote_rsp_payload_error),       // o
        .io_remote_rsp_payload_data    (systemDebugger_1_io_remote_rsp_payload_data[31:0]),  // o
        .io_mem_cmd_valid              (systemDebugger_1_io_mem_cmd_valid),                  // o
        .io_mem_cmd_ready              (system_cpu_debug_bus_cmd_ready),                     // i
        .io_mem_cmd_payload_address    (systemDebugger_1_io_mem_cmd_payload_address[31:0]),  // o
        .io_mem_cmd_payload_data       (systemDebugger_1_io_mem_cmd_payload_data[31:0]),     // o
        .io_mem_cmd_payload_wr         (systemDebugger_1_io_mem_cmd_payload_wr),             // o
        .io_mem_cmd_payload_size       (systemDebugger_1_io_mem_cmd_payload_size[1:0]),      // o
        .io_mem_rsp_valid              (toplevel_system_cpu_debug_bus_cmd_fire_regNext),     // i
        .io_mem_rsp_payload            (system_cpu_debug_bus_rsp_data[31:0]),                // i
        .io_mainClk                    (io_mainClk),                                         // i
        .resetCtrl_mainClkReset        (resetCtrl_mainClkReset)                              // i
    );
    RAMPPL RAMPPL (
        .io_bus_cmd_valid(system_ram_io_bus_cmd_valid),                                                       // i
        .io_bus_cmd_ready(system_ram_io_bus_cmd_ready),                                                       // o
        .io_bus_cmd_payload_write(_zz_io_bus_cmd_payload_write),                                              // i
        .io_bus_cmd_payload_address(system_mainBusDecoder_logic_masterPipelined_cmd_payload_address[31:0]),  // i
        .io_bus_cmd_payload_data(system_mainBusDecoder_logic_masterPipelined_cmd_payload_data[31:0]),         // i
        .io_bus_cmd_payload_mask(system_mainBusDecoder_logic_masterPipelined_cmd_payload_mask[3:0]),          // i
        .io_bus_rsp_valid(system_ram_io_bus_rsp_valid),                                                       // o
        .io_bus_rsp_payload_data(system_ram_io_bus_rsp_payload_data[31:0]),                                   // o
        .io_mainClk(io_mainClk),                                                                              // i
        .resetCtrl_systemReset(resetCtrl_systemReset)                                                         // i
    );
    Apb3Bridge Apb3Bridge (
        .io_pipelinedMemoryBus_cmd_valid(system_apbBridge_io_pipelinedMemoryBus_cmd_valid),                                  // i
        .io_pipelinedMemoryBus_cmd_ready(system_apbBridge_io_pipelinedMemoryBus_cmd_ready),                                  // o
        .io_pipelinedMemoryBus_cmd_payload_write(_zz_io_pipelinedMemoryBus_cmd_payload_write),                               // i
        .io_pipelinedMemoryBus_cmd_payload_address (system_mainBusDecoder_logic_masterPipelined_cmd_payload_address[31:0]),  // i
        .io_pipelinedMemoryBus_cmd_payload_data(system_mainBusDecoder_logic_masterPipelined_cmd_payload_data[31:0]),         // i
        .io_pipelinedMemoryBus_cmd_payload_mask(system_mainBusDecoder_logic_masterPipelined_cmd_payload_mask[3:0]),          // i
        .io_pipelinedMemoryBus_rsp_valid(system_apbBridge_io_pipelinedMemoryBus_rsp_valid),                                  // o
        .io_pipelinedMemoryBus_rsp_payload_data(system_apbBridge_io_pipelinedMemoryBus_rsp_payload_data[31:0]),              // o
        .io_apb_PADDR(system_apbBridge_io_apb_PADDR[19:0]),                                                                  // o
        .io_apb_PSEL(system_apbBridge_io_apb_PSEL),                                                                          // o
        .io_apb_PENABLE(system_apbBridge_io_apb_PENABLE),                                                                    // o
        .io_apb_PREADY(io_apb_decoder_io_input_PREADY),                                                                      // i
        .io_apb_PWRITE(system_apbBridge_io_apb_PWRITE),                                                                      // o
        .io_apb_PWDATA(system_apbBridge_io_apb_PWDATA[31:0]),                                                                // o
        .io_apb_PRDATA(io_apb_decoder_io_input_PRDATA[31:0]),                                                                // i
        .io_apb_PSLVERROR(io_apb_decoder_io_input_PSLVERROR),                                                                // i
        .io_mainClk(io_mainClk),                                                                                             // i
        .resetCtrl_systemReset(resetCtrl_systemReset)                                                                        // i
    );
    Apb3GPIO Apb3GPIO (
        .io_apb_PADDR         (system_gpioACtrl_io_apb_PADDR[3:0]),          // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_0_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_0_PENABLE),           // i
        .io_apb_PREADY        (system_gpioACtrl_io_apb_PREADY),              // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_0_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_0_PWDATA[31:0]),      // i
        .io_apb_PRDATA        (system_gpioACtrl_io_apb_PRDATA[31:0]),        // o
        .io_apb_PSLVERROR     (system_gpioACtrl_io_apb_PSLVERROR),           // o
        .io_gpio_read         (io_gpioA_read[31:0]),                         // i
        .io_gpio_write        (system_gpioACtrl_io_gpio_write[31:0]),        // o
        .io_gpio_writeEnable  (system_gpioACtrl_io_gpio_writeEnable[31:0]),  // o
        .io_mainClk           (io_mainClk),                                  // i
        .resetCtrl_systemReset(resetCtrl_systemReset)                        // i
    );
    Apb3GPIORouter Apb3GPIORouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_gpioCtrl_io_apb_PADDR),                // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_3_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_3_PENABLE),           // i
        .io_apb_PREADY        (system_gpioCtrl_io_apb_PREADY),               // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_3_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_3_PWDATA),            // i
        .io_apb_PRDATA        (system_gpioCtrl_io_apb_PRDATA),               // o
        .io_apb_PSLVERROR     (system_gpioCtrl_io_apb_PSLVERROR),            // o
        .AFIOA                (AFIOA),                                       // i
        .GPIOA                (GPIOA),                                       // io
        .AFIOB                (AFIOB),                                       // i
        .GPIOB                (GPIOB)                                        // io
    );
    Apb3WDGRouter Apb3WDGRouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_wdgCtrl_io_apb_PADDR),                 // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_4_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_4_PENABLE),           // i
        .io_apb_PREADY        (system_wdgCtrl_io_apb_PREADY),                // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_4_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_4_PWDATA),            // i
        .io_apb_PRDATA        (system_wdgCtrl_io_apb_PRDATA),                // o
        .io_apb_PSLVERROR     (system_wdgCtrl_io_apb_PSLVERROR),             // o
        .IWDG_rst             (),                                            // o
        .WWDG_rst             ()                                             // o
    );
    Apb3USARTRouter Apb3USARTRouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_usartCtrl_io_apb_PADDR),               // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_5_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_5_PENABLE),           // i
        .io_apb_PREADY        (system_usartCtrl_io_apb_PREADY),              // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_5_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_5_PWDATA),            // i
        .io_apb_PRDATA        (system_usartCtrl_io_apb_PRDATA),              // o
        .io_apb_PSLVERROR     (system_usartCtrl_io_apb_PSLVERROR),           // o
        .USART1_RX            (USART1_RX),                                   // i
        .USART1_TX            (USART1_TX),                                   // o
        .USART1_interrupt     (USART1_interrupt),                            // o  // USART interrupt
        .USART2_RX            (USART2_RX),                                   // i
        .USART2_TX            (USART2_TX),                                   // o
        .USART2_interrupt     (USART2_interrupt)                             // o
    );
    Apb3I2CRouter Apb3I2CRouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_i2cCtrl_io_apb_PADDR),                 // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_6_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_6_PENABLE),           // i
        .io_apb_PREADY        (system_i2cCtrl_io_apb_PREADY),                // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_6_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_6_PWDATA),            // i
        .io_apb_PRDATA        (system_i2cCtrl_io_apb_PRDATA),                // o
        .io_apb_PSLVERROR     (system_i2cCtrl_io_apb_PSLVERROR),             // o
        .I2C1_SDA             (I2C1_SDA),                                    // i
        .I2C1_SCL             (I2C1_SCL),                                    // o
        .I2C1_interrupt       (),                            // o  // SPI interrupt
        .I2C2_SDA             (I2C1_SDA),                                    // i
        .I2C2_SCL             (I2C2_SCL),                                    // o
        .I2C2_interrupt       ()                             // o
    );
    Apb3SPIRouter Apb3SPIRouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_spiCtrl_io_apb_PADDR),                 // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_7_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_7_PENABLE),           // i
        .io_apb_PREADY        (system_spiCtrl_io_apb_PREADY),                // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_7_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_7_PWDATA),            // i
        .io_apb_PRDATA        (system_spiCtrl_io_apb_PRDATA),               // o
        .io_apb_PSLVERROR     (system_spiCtrl_io_apb_PSLVERROR),            // o
        .SPI1_SCK             (SPI1_SCK),                                    // o
        .SPI1_MOSI            (SPI1_MOSI),                                   // o
        .SPI1_MISO            (SPI1_MISO),                                   // i
        .SPI1_CS              (SPI1_CS),                                     // o
        .SPI1_interrupt       (),                            // o  // SPI interrupt
        .SPI2_SCK             (SPI2_SCK),                                    // o
        .SPI2_MOSI            (SPI2_MOSI),                                   // o
        .SPI2_MISO            (SPI2_MISO),                                   // i
        .SPI2_CS              (SPI2_CS),                                     // o
        .SPI2_interrupt       ()                             // o
    );
    Apb3TIMRouter Apb3TIMRouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_timCtrl_io_apb_PADDR),                 // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_8_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_8_PENABLE),           // i
        .io_apb_PREADY        (system_timCtrl_io_apb_PREADY),                // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_8_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_8_PWDATA),            // i
        .io_apb_PRDATA        (system_timCtrl_io_apb_PRDATA),                // o
        .io_apb_PSLVERROR     (system_timCtrl_io_apb_PSLVERROR),             // o
        .TIM2_CH              (TIM2_CH),                                     // o
        .TIM2_interrupt       (TIM2_interrupt),                              // o  // TIM interrupt
        .TIM3_CH              (TIM3_CH),                                     // o
        .TIM3_interrupt       (TIM3_interrupt)                               // o
    );
    Apb3UART Apb3UART (
        .io_apb_PADDR         (system_uartCtrl_io_apb_PADDR[4:0]),       // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_1_PSEL),          // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_1_PENABLE),       // i
        .io_apb_PREADY        (system_uartCtrl_io_apb_PREADY),           // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_1_PWRITE),        // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_1_PWDATA[31:0]),  // i
        .io_apb_PRDATA        (system_uartCtrl_io_apb_PRDATA[31:0]),     // o
        .io_uart_txd          (system_uartCtrl_io_uart_txd),             // o
        .io_uart_rxd          (io_uart_rxd),                             // i
        .io_interrupt         (system_uartCtrl_io_interrupt),            // o
        .io_mainClk           (io_mainClk),                              // i
        .resetCtrl_systemReset(resetCtrl_systemReset)                    // i
    );
    Apb3Timer Apb3Timer (
        .io_apb_PADDR         (system_timer_io_apb_PADDR[7:0]),          // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_2_PSEL),          // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_2_PENABLE),       // i
        .io_apb_PREADY        (system_timer_io_apb_PREADY),              // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_2_PWRITE),        // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_2_PWDATA[31:0]),  // i
        .io_apb_PRDATA        (system_timer_io_apb_PRDATA[31:0]),        // o
        .io_apb_PSLVERROR     (system_timer_io_apb_PSLVERROR),           // o
        .io_interrupt         (system_timer_io_interrupt),               // o
        .io_mainClk           (io_mainClk),                              // i
        .resetCtrl_systemReset(resetCtrl_systemReset)                    // i
    );
    // Apb3Decoder Apb3Decoder (
    //     .io_input_PADDR     (system_apbBridge_io_apb_PADDR[19:0]),    // i
    //     .io_input_PSEL      (system_apbBridge_io_apb_PSEL),           // i
    //     .io_input_PENABLE   (system_apbBridge_io_apb_PENABLE),        // i
    //     .io_input_PREADY    (io_apb_decoder_io_input_PREADY),         // o
    //     .io_input_PWRITE    (system_apbBridge_io_apb_PWRITE),         // i
    //     .io_input_PWDATA    (system_apbBridge_io_apb_PWDATA[31:0]),   // i
    //     .io_input_PRDATA    (io_apb_decoder_io_input_PRDATA[31:0]),   // o
    //     .io_input_PSLVERROR (io_apb_decoder_io_input_PSLVERROR),      // o
    //     .io_output_PADDR    (io_apb_decoder_io_output_PADDR[19:0]),   // o
    //     .io_output_PSEL     (io_apb_decoder_io_output_PSEL),          // o
    //     .io_output_PENABLE  (io_apb_decoder_io_output_PENABLE),       // o
    //     .io_output_PREADY   (apb3Router_1_io_input_PREADY),           // i
    //     .io_output_PWRITE   (io_apb_decoder_io_output_PWRITE),        // o
    //     .io_output_PWDATA   (io_apb_decoder_io_output_PWDATA[31:0]),  // o
    //     .io_output_PRDATA   (apb3Router_1_io_input_PRDATA[31:0]),     // i
    //     .io_output_PSLVERROR(apb3Router_1_io_input_PSLVERROR)         // i
    // );
    // Apb3Router Apb3Router (
    //     .io_input_PADDR        (io_apb_decoder_io_output_PADDR[19:0]),    // i
    //     .io_input_PSEL         (io_apb_decoder_io_output_PSEL),           // i
    //     .io_input_PENABLE      (io_apb_decoder_io_output_PENABLE),        // i
    //     .io_input_PREADY       (apb3Router_1_io_input_PREADY),            // o
    //     .io_input_PWRITE       (io_apb_decoder_io_output_PWRITE),         // i
    //     .io_input_PWDATA       (io_apb_decoder_io_output_PWDATA[31:0]),   // i
    //     .io_input_PRDATA       (apb3Router_1_io_input_PRDATA[31:0]),      // o
    //     .io_input_PSLVERROR    (apb3Router_1_io_input_PSLVERROR),         // o
    //     .io_outputs_0_PADDR    (apb3Router_1_io_outputs_0_PADDR[19:0]),   // o
    //     .io_outputs_0_PSEL     (apb3Router_1_io_outputs_0_PSEL),          // o
    //     .io_outputs_0_PENABLE  (apb3Router_1_io_outputs_0_PENABLE),       // o
    //     .io_outputs_0_PREADY   (system_gpioACtrl_io_apb_PREADY),          // i
    //     .io_outputs_0_PWRITE   (apb3Router_1_io_outputs_0_PWRITE),        // o
    //     .io_outputs_0_PWDATA   (apb3Router_1_io_outputs_0_PWDATA[31:0]),  // o
    //     .io_outputs_0_PRDATA   (system_gpioACtrl_io_apb_PRDATA[31:0]),    // i
    //     .io_outputs_0_PSLVERROR(system_gpioACtrl_io_apb_PSLVERROR),       // i
    //     .io_outputs_1_PADDR    (apb3Router_1_io_outputs_1_PADDR[19:0]),   // o
    //     .io_outputs_1_PSEL     (apb3Router_1_io_outputs_1_PSEL),          // o
    //     .io_outputs_1_PENABLE  (apb3Router_1_io_outputs_1_PENABLE),       // o
    //     .io_outputs_1_PREADY   (system_uartCtrl_io_apb_PREADY),           // i
    //     .io_outputs_1_PWRITE   (apb3Router_1_io_outputs_1_PWRITE),        // o
    //     .io_outputs_1_PWDATA   (apb3Router_1_io_outputs_1_PWDATA[31:0]),  // o
    //     .io_outputs_1_PRDATA   (system_uartCtrl_io_apb_PRDATA[31:0]),     // i
    //     .io_outputs_1_PSLVERROR(1'b0),                                    // i
    //     .io_outputs_2_PADDR    (apb3Router_1_io_outputs_2_PADDR[19:0]),   // o
    //     .io_outputs_2_PSEL     (apb3Router_1_io_outputs_2_PSEL),          // o
    //     .io_outputs_2_PENABLE  (apb3Router_1_io_outputs_2_PENABLE),       // o
    //     .io_outputs_2_PREADY   (system_timer_io_apb_PREADY),              // i
    //     .io_outputs_2_PWRITE   (apb3Router_1_io_outputs_2_PWRITE),        // o
    //     .io_outputs_2_PWDATA   (apb3Router_1_io_outputs_2_PWDATA[31:0]),  // o
    //     .io_outputs_2_PRDATA   (system_timer_io_apb_PRDATA[31:0]),        // i
    //     .io_outputs_2_PSLVERROR(system_timer_io_apb_PSLVERROR),           // i

    //     .io_outputs_3_PADDR    (apb3Router_1_io_outputs_3_PADDR[19:0]),   // o GPIO2
    //     .io_outputs_3_PSEL     (apb3Router_1_io_outputs_3_PSEL),          // o GPIO2
    //     .io_outputs_3_PENABLE  (apb3Router_1_io_outputs_3_PENABLE),       // o GPIO2
    //     .io_outputs_3_PREADY   (system_gpioCtrl_io_apb_PREADY),         // i GPIO2
    //     .io_outputs_3_PWRITE   (apb3Router_1_io_outputs_3_PWRITE),        // o GPIO2
    //     .io_outputs_3_PWDATA   (apb3Router_1_io_outputs_3_PWDATA[31:0]),  // o GPIO2
    //     .io_outputs_3_PRDATA   (system_gpioCtrl_io_apb_PRDATA[31:0]),   // i GPIO2
    //     .io_outputs_3_PSLVERROR(1'b0),                                    // i GPIO2

    //     .io_mainClk            (io_mainClk),                              // i
    //     .resetCtrl_systemReset (resetCtrl_systemReset)                    // i
    // );
    Apb3PRouter Apb3PRouter (
        .io_input_PADDR     (system_apbBridge_io_apb_PADDR[19:0]),    // i
        .io_input_PSEL      (system_apbBridge_io_apb_PSEL),           // i
        .io_input_PENABLE   (system_apbBridge_io_apb_PENABLE),        // i
        .io_input_PREADY    (io_apb_decoder_io_input_PREADY),         // o
        .io_input_PWRITE    (system_apbBridge_io_apb_PWRITE),         // i
        .io_input_PWDATA    (system_apbBridge_io_apb_PWDATA[31:0]),   // i
        .io_input_PRDATA    (io_apb_decoder_io_input_PRDATA[31:0]),   // o
        .io_input_PSLVERROR (io_apb_decoder_io_input_PSLVERROR),      // o

        .io_outputs_0_PADDR    (apb3Router_1_io_outputs_0_PADDR[19:0]),   // o
        .io_outputs_0_PSEL     (apb3Router_1_io_outputs_0_PSEL),          // o
        .io_outputs_0_PENABLE  (apb3Router_1_io_outputs_0_PENABLE),       // o
        .io_outputs_0_PREADY   (system_gpioACtrl_io_apb_PREADY),          // i
        .io_outputs_0_PWRITE   (apb3Router_1_io_outputs_0_PWRITE),        // o
        .io_outputs_0_PWDATA   (apb3Router_1_io_outputs_0_PWDATA[31:0]),  // o
        .io_outputs_0_PRDATA   (system_gpioACtrl_io_apb_PRDATA[31:0]),    // i
        .io_outputs_0_PSLVERROR(system_gpioACtrl_io_apb_PSLVERROR),       // i
        .io_outputs_1_PADDR    (apb3Router_1_io_outputs_1_PADDR[19:0]),   // o
        .io_outputs_1_PSEL     (apb3Router_1_io_outputs_1_PSEL),          // o
        .io_outputs_1_PENABLE  (apb3Router_1_io_outputs_1_PENABLE),       // o
        .io_outputs_1_PREADY   (system_uartCtrl_io_apb_PREADY),           // i
        .io_outputs_1_PWRITE   (apb3Router_1_io_outputs_1_PWRITE),        // o
        .io_outputs_1_PWDATA   (apb3Router_1_io_outputs_1_PWDATA[31:0]),  // o
        .io_outputs_1_PRDATA   (system_uartCtrl_io_apb_PRDATA[31:0]),     // i
        .io_outputs_1_PSLVERROR(1'b0),                                    // i
        .io_outputs_2_PADDR    (apb3Router_1_io_outputs_2_PADDR[19:0]),   // o
        .io_outputs_2_PSEL     (apb3Router_1_io_outputs_2_PSEL),          // o
        .io_outputs_2_PENABLE  (apb3Router_1_io_outputs_2_PENABLE),       // o
        .io_outputs_2_PREADY   (system_timer_io_apb_PREADY),              // i
        .io_outputs_2_PWRITE   (apb3Router_1_io_outputs_2_PWRITE),        // o
        .io_outputs_2_PWDATA   (apb3Router_1_io_outputs_2_PWDATA[31:0]),  // o
        .io_outputs_2_PRDATA   (system_timer_io_apb_PRDATA[31:0]),        // i
        .io_outputs_2_PSLVERROR(system_timer_io_apb_PSLVERROR),           // i
        .io_outputs_3_PADDR    (apb3Router_1_io_outputs_3_PADDR[19:0]),   // o GPIO2
        .io_outputs_3_PSEL     (apb3Router_1_io_outputs_3_PSEL),          // o GPIO2
        .io_outputs_3_PENABLE  (apb3Router_1_io_outputs_3_PENABLE),       // o GPIO2
        .io_outputs_3_PREADY   (system_gpioCtrl_io_apb_PREADY),           // i GPIO2
        .io_outputs_3_PWRITE   (apb3Router_1_io_outputs_3_PWRITE),        // o GPIO2
        .io_outputs_3_PWDATA   (apb3Router_1_io_outputs_3_PWDATA[31:0]),  // o GPIO2
        .io_outputs_3_PRDATA   (system_gpioCtrl_io_apb_PRDATA[31:0]),     // i GPIO2
        .io_outputs_3_PSLVERROR(system_gpioCtrl_io_apb_PSLVERROR),        // i GPIO2
        .io_outputs_4_PADDR    (apb3Router_1_io_outputs_4_PADDR[19:0]),   // o WDG
        .io_outputs_4_PSEL     (apb3Router_1_io_outputs_4_PSEL),          // o WDG
        .io_outputs_4_PENABLE  (apb3Router_1_io_outputs_4_PENABLE),       // o WDG
        .io_outputs_4_PREADY   (system_wdgCtrl_io_apb_PREADY),            // i WDG
        .io_outputs_4_PWRITE   (apb3Router_1_io_outputs_4_PWRITE),        // o WDG
        .io_outputs_4_PWDATA   (apb3Router_1_io_outputs_4_PWDATA[31:0]),  // o WDG
        .io_outputs_4_PRDATA   (system_wdgCtrl_io_apb_PRDATA[31:0]),      // i WDG
        .io_outputs_4_PSLVERROR(system_wdgCtrl_io_apb_PSLVERROR),         // i WDG
        .io_outputs_5_PADDR    (apb3Router_1_io_outputs_5_PADDR[19:0]),   // o USART
        .io_outputs_5_PSEL     (apb3Router_1_io_outputs_5_PSEL),          // o USART
        .io_outputs_5_PENABLE  (apb3Router_1_io_outputs_5_PENABLE),       // o USART
        .io_outputs_5_PREADY   (system_usartCtrl_io_apb_PREADY),          // i USART
        .io_outputs_5_PWRITE   (apb3Router_1_io_outputs_5_PWRITE),        // o USART
        .io_outputs_5_PWDATA   (apb3Router_1_io_outputs_5_PWDATA[31:0]),  // o USART
        .io_outputs_5_PRDATA   (system_usartCtrl_io_apb_PRDATA[31:0]),    // i USART
        .io_outputs_5_PSLVERROR(system_usartCtrl_io_apb_PSLVERROR),       // i USART
        .io_outputs_6_PADDR    (apb3Router_1_io_outputs_6_PADDR[19:0]),   // o I2C
        .io_outputs_6_PSEL     (apb3Router_1_io_outputs_6_PSEL),          // o I2C
        .io_outputs_6_PENABLE  (apb3Router_1_io_outputs_6_PENABLE),       // o I2C
        .io_outputs_6_PREADY   (system_i2cCtrl_io_apb_PREADY),            // i I2C
        .io_outputs_6_PWRITE   (apb3Router_1_io_outputs_6_PWRITE),        // o I2C
        .io_outputs_6_PWDATA   (apb3Router_1_io_outputs_6_PWDATA[31:0]),  // o I2C
        .io_outputs_6_PRDATA   (system_i2cCtrl_io_apb_PRDATA[31:0]),      // i I2C
        .io_outputs_6_PSLVERROR(system_i2cCtrl_io_apb_PSLVERROR),         // i I2C
        .io_outputs_7_PADDR    (apb3Router_1_io_outputs_7_PADDR[19:0]),   // o SPI
        .io_outputs_7_PSEL     (apb3Router_1_io_outputs_7_PSEL),          // o SPI
        .io_outputs_7_PENABLE  (apb3Router_1_io_outputs_7_PENABLE),       // o SPI
        .io_outputs_7_PREADY   (system_spiCtrl_io_apb_PREADY),            // i SPI
        .io_outputs_7_PWRITE   (apb3Router_1_io_outputs_7_PWRITE),        // o SPI
        .io_outputs_7_PWDATA   (apb3Router_1_io_outputs_7_PWDATA[31:0]),  // o SPI
        .io_outputs_7_PRDATA   (system_spiCtrl_io_apb_PRDATA[31:0]),      // i SPI
        .io_outputs_7_PSLVERROR(system_spiCtrl_io_apb_PSLVERROR),         // i SPI
        .io_outputs_8_PADDR    (apb3Router_1_io_outputs_8_PADDR[19:0]),   // o TIM
        .io_outputs_8_PSEL     (apb3Router_1_io_outputs_8_PSEL),          // o TIM
        .io_outputs_8_PENABLE  (apb3Router_1_io_outputs_8_PENABLE),       // o TIM
        .io_outputs_8_PREADY   (system_timCtrl_io_apb_PREADY),            // i TIM
        .io_outputs_8_PWRITE   (apb3Router_1_io_outputs_8_PWRITE),        // o TIM
        .io_outputs_8_PWDATA   (apb3Router_1_io_outputs_8_PWDATA[31:0]),  // o TIM
        .io_outputs_8_PRDATA   (system_timCtrl_io_apb_PRDATA[31:0]),      // i TIM
        .io_outputs_8_PSLVERROR(system_timCtrl_io_apb_PSLVERROR),         // i TIM

        .io_mainClk            (io_mainClk),                              // i
        .resetCtrl_systemReset (resetCtrl_systemReset)                    // i
    );
    initial begin
        resetCtrl_systemClkResetCounter = 6'h0;
    end

    always @(*) begin
        case (system_mainBusDecoder_logic_rspSourceId)
            1'b0:
            _zz_system_mainBusDecoder_logic_masterPipelined_rsp_payload_data = system_ram_io_bus_rsp_payload_data;
            default:
            _zz_system_mainBusDecoder_logic_masterPipelined_rsp_payload_data = system_apbBridge_io_pipelinedMemoryBus_rsp_payload_data;
        endcase
    end

    always @(*) begin
        resetCtrl_mainClkResetUnbuffered = 1'b0;
        if (when_Murax_l188) begin
            resetCtrl_mainClkResetUnbuffered = 1'b1;
        end
    end

    assign _zz_when_Murax_l188[5 : 0] = 6'h3f;
    assign when_Murax_l188 = (resetCtrl_systemClkResetCounter != _zz_when_Murax_l188);
    assign when_Murax_l192 = io_asyncReset_buffercc_io_dataOut;
    always @(*) begin
        system_timerInterrupt = 1'b0;
        if (system_timer_io_interrupt | TIM2_interrupt | TIM3_interrupt) begin
            system_timerInterrupt = 1'b1;
        end
    end

    always @(*) begin
        system_externalInterrupt = 1'b0;
        if (system_uartCtrl_io_interrupt | USART1_interrupt | USART2_interrupt) begin
            system_externalInterrupt = 1'b1;
        end
    end

    assign toplevel_system_cpu_dBus_cmd_halfPipe_fire = (toplevel_system_cpu_dBus_cmd_halfPipe_valid && toplevel_system_cpu_dBus_cmd_halfPipe_ready);
    assign system_cpu_dBus_cmd_ready = (!toplevel_system_cpu_dBus_cmd_rValid);
    assign toplevel_system_cpu_dBus_cmd_halfPipe_valid = toplevel_system_cpu_dBus_cmd_rValid;
    assign toplevel_system_cpu_dBus_cmd_halfPipe_payload_wr = toplevel_system_cpu_dBus_cmd_rData_wr;
    assign toplevel_system_cpu_dBus_cmd_halfPipe_payload_mask = toplevel_system_cpu_dBus_cmd_rData_mask;
    assign toplevel_system_cpu_dBus_cmd_halfPipe_payload_address = toplevel_system_cpu_dBus_cmd_rData_address;
    assign toplevel_system_cpu_dBus_cmd_halfPipe_payload_data = toplevel_system_cpu_dBus_cmd_rData_data;
    assign toplevel_system_cpu_dBus_cmd_halfPipe_payload_size = toplevel_system_cpu_dBus_cmd_rData_size;
    assign toplevel_system_cpu_dBus_cmd_halfPipe_ready = system_mainBusArbiter_io_dBus_cmd_ready;
    assign system_cpu_debug_bus_cmd_payload_address = systemDebugger_1_io_mem_cmd_payload_address[7:0];
    assign toplevel_system_cpu_debug_bus_cmd_fire = (systemDebugger_1_io_mem_cmd_valid && system_cpu_debug_bus_cmd_ready);
    assign io_jtag_tdo = jtagBridge_1_io_jtag_tdo;
    assign io_gpioA_write = system_gpioACtrl_io_gpio_write;
    assign io_gpioA_writeEnable = system_gpioACtrl_io_gpio_writeEnable;
    assign io_uart_txd = system_uartCtrl_io_uart_txd;
    assign system_gpioACtrl_io_apb_PADDR = apb3Router_1_io_outputs_0_PADDR[3:0];
    assign system_gpioCtrl_io_apb_PADDR = apb3Router_1_io_outputs_3_PADDR[15:0];  // GPIO2
    assign system_uartCtrl_io_apb_PADDR = apb3Router_1_io_outputs_1_PADDR[4:0];
    assign system_timer_io_apb_PADDR = apb3Router_1_io_outputs_2_PADDR[7:0];
    assign system_wdgCtrl_io_apb_PADDR = apb3Router_1_io_outputs_4_PADDR[15:0];  // WDG
    assign system_usartCtrl_io_apb_PADDR = apb3Router_1_io_outputs_5_PADDR[15:0];  // USART
    assign system_i2cCtrl_io_apb_PADDR = apb3Router_1_io_outputs_6_PADDR[15:0];  // I2C
    assign system_spiCtrl_io_apb_PADDR = apb3Router_1_io_outputs_7_PADDR[15:0];  // SPI
    assign system_timCtrl_io_apb_PADDR = apb3Router_1_io_outputs_8_PADDR[15:0];  // TIM
    assign system_mainBusDecoder_logic_masterPipelined_cmd_valid = system_mainBusArbiter_io_masterBus_cmd_valid;
    assign system_mainBusDecoder_logic_masterPipelined_cmd_payload_write = system_mainBusArbiter_io_masterBus_cmd_payload_write;
    assign system_mainBusDecoder_logic_masterPipelined_cmd_payload_address = system_mainBusArbiter_io_masterBus_cmd_payload_address;
    assign system_mainBusDecoder_logic_masterPipelined_cmd_payload_data = system_mainBusArbiter_io_masterBus_cmd_payload_data;
    assign system_mainBusDecoder_logic_masterPipelined_cmd_payload_mask = system_mainBusArbiter_io_masterBus_cmd_payload_mask;
    // assign system_mainBusDecoder_logic_hits_0 = ((system_mainBusDecoder_logic_masterPipelined_cmd_payload_address & (~ 32'h00000fff)) == 32'h80000000);
    assign system_mainBusDecoder_logic_hits_0 = ((system_mainBusDecoder_logic_masterPipelined_cmd_payload_address & (~ 32'h0000ffff)) == 32'h80000000);
    always @(*) begin
        system_ram_io_bus_cmd_valid = (system_mainBusDecoder_logic_masterPipelined_cmd_valid && system_mainBusDecoder_logic_hits_0);
        if (when_MuraxUtiles_l133) begin
            system_ram_io_bus_cmd_valid = 1'b0;
        end
    end

    assign _zz_io_bus_cmd_payload_write = system_mainBusDecoder_logic_masterPipelined_cmd_payload_write;
    assign system_mainBusDecoder_logic_hits_1 = ((system_mainBusDecoder_logic_masterPipelined_cmd_payload_address & (~ 32'h000fffff)) == 32'hf0000000);
    always @(*) begin
        system_apbBridge_io_pipelinedMemoryBus_cmd_valid = (system_mainBusDecoder_logic_masterPipelined_cmd_valid && system_mainBusDecoder_logic_hits_1);
        if (when_MuraxUtiles_l133) begin
            system_apbBridge_io_pipelinedMemoryBus_cmd_valid = 1'b0;
        end
    end

    assign _zz_io_pipelinedMemoryBus_cmd_payload_write = system_mainBusDecoder_logic_masterPipelined_cmd_payload_write;
    assign system_mainBusDecoder_logic_noHit = (! (|{system_mainBusDecoder_logic_hits_1,system_mainBusDecoder_logic_hits_0}));
    always @(*) begin
        system_mainBusDecoder_logic_masterPipelined_cmd_ready = ((|{(system_mainBusDecoder_logic_hits_1 && system_apbBridge_io_pipelinedMemoryBus_cmd_ready),(system_mainBusDecoder_logic_hits_0 && system_ram_io_bus_cmd_ready)}) || system_mainBusDecoder_logic_noHit);
        if (when_MuraxUtiles_l133) begin
            system_mainBusDecoder_logic_masterPipelined_cmd_ready = 1'b0;
        end
    end

    assign system_mainBusDecoder_logic_masterPipelined_cmd_fire = (system_mainBusDecoder_logic_masterPipelined_cmd_valid && system_mainBusDecoder_logic_masterPipelined_cmd_ready);
    assign when_MuraxUtiles_l127 = (system_mainBusDecoder_logic_masterPipelined_cmd_fire && (! system_mainBusDecoder_logic_masterPipelined_cmd_payload_write));
    assign system_mainBusDecoder_logic_masterPipelined_rsp_valid = ((|{system_apbBridge_io_pipelinedMemoryBus_rsp_valid,system_ram_io_bus_rsp_valid}) || (system_mainBusDecoder_logic_rspPending && system_mainBusDecoder_logic_rspNoHit));
    assign system_mainBusDecoder_logic_masterPipelined_rsp_payload_data = _zz_system_mainBusDecoder_logic_masterPipelined_rsp_payload_data;
    assign when_MuraxUtiles_l133 = (system_mainBusDecoder_logic_rspPending && (! system_mainBusDecoder_logic_masterPipelined_rsp_valid));
    always @(posedge io_mainClk) begin
        if (when_Murax_l188) begin
            resetCtrl_systemClkResetCounter <= (resetCtrl_systemClkResetCounter + 6'h01);
        end
        if (when_Murax_l192) begin
            resetCtrl_systemClkResetCounter <= 6'h0;
        end
    end

    always @(posedge io_mainClk) begin
        resetCtrl_mainClkReset <= resetCtrl_mainClkResetUnbuffered;
        resetCtrl_systemReset  <= resetCtrl_mainClkResetUnbuffered;
        if (toplevel_system_cpu_debug_resetOut_regNext) begin
            resetCtrl_systemReset <= 1'b1;
        end
    end

    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            toplevel_system_cpu_dBus_cmd_rValid <= 1'b0;
            system_mainBusDecoder_logic_rspPending <= 1'b0;
            system_mainBusDecoder_logic_rspNoHit <= 1'b0;
        end else begin
            if (system_cpu_dBus_cmd_valid) begin
                toplevel_system_cpu_dBus_cmd_rValid <= 1'b1;
            end
            if (toplevel_system_cpu_dBus_cmd_halfPipe_fire) begin
                toplevel_system_cpu_dBus_cmd_rValid <= 1'b0;
            end
            if (system_mainBusDecoder_logic_masterPipelined_rsp_valid) begin
                system_mainBusDecoder_logic_rspPending <= 1'b0;
            end
            if (when_MuraxUtiles_l127) begin
                system_mainBusDecoder_logic_rspPending <= 1'b1;
            end
            system_mainBusDecoder_logic_rspNoHit <= 1'b0;
            if (system_mainBusDecoder_logic_noHit) begin
                system_mainBusDecoder_logic_rspNoHit <= 1'b1;
            end
        end
    end

    always @(posedge io_mainClk) begin
        if (system_cpu_dBus_cmd_ready) begin
            toplevel_system_cpu_dBus_cmd_rData_wr <= system_cpu_dBus_cmd_payload_wr;
            toplevel_system_cpu_dBus_cmd_rData_mask <= system_cpu_dBus_cmd_payload_mask;
            toplevel_system_cpu_dBus_cmd_rData_address <= system_cpu_dBus_cmd_payload_address;
            toplevel_system_cpu_dBus_cmd_rData_data <= system_cpu_dBus_cmd_payload_data;
            toplevel_system_cpu_dBus_cmd_rData_size <= system_cpu_dBus_cmd_payload_size;
        end
        if (system_mainBusDecoder_logic_masterPipelined_cmd_fire) begin
            system_mainBusDecoder_logic_rspSourceId <= system_mainBusDecoder_logic_hits_1;
        end
    end

    always @(posedge io_mainClk) begin
        toplevel_system_cpu_debug_resetOut_regNext <= system_cpu_debug_resetOut;
    end

    always @(posedge io_mainClk or posedge resetCtrl_mainClkReset) begin
        if (resetCtrl_mainClkReset) begin
            toplevel_system_cpu_debug_bus_cmd_fire_regNext <= 1'b0;
        end else begin
            toplevel_system_cpu_debug_bus_cmd_fire_regNext <= toplevel_system_cpu_debug_bus_cmd_fire;
        end
    end

endmodule
