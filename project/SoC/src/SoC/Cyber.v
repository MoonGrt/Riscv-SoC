`timescale 1ns / 1ps
`define SYNTHESIS

module Murax (
    input  wire io_asyncReset,
    input  wire io_mainClk,
    input  wire io_jtag_tms,
    input  wire io_jtag_tdi,
    output wire io_jtag_tdo,
    input  wire io_jtag_tck,

    inout wire [15:0] GPIOA,  // GPIO
    inout wire [15:0] GPIOB   // GPIO
);

    /* GPIO AFIO */
    // USART
    wire USART1_TX;
    wire USART1_RX = GPIOB[1];
    wire USART2_TX;
    wire USART2_RX = GPIOB[3];
    // I2C
    wire I2C1_SDA;  // 有问题
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
    wire [15:0] AFIOB = {SPI2_CS, 1'bz, SPI2_MOSI, SPI2_SCK, SPI1_CS, 1'bz, SPI1_MOSI, SPI1_SCK, 
                         I2C2_SDA, I2C2_SCL, I2C1_SDA, I2C1_SCL, 1'bz, USART2_TX, 1'bz, USART1_TX};
    // Interrupt
    reg system_externalInterrupt, system_timerInterrupt;
    wire timer_interrupt, uart_interrupt;
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
    assign system_gpioCtrl_io_apb_PADDR = apb3Router_1_io_outputs_0_PADDR[15:0];  // GPIO
    assign system_wdgCtrl_io_apb_PADDR = apb3Router_1_io_outputs_1_PADDR[15:0];  // WDG
    assign system_usartCtrl_io_apb_PADDR = apb3Router_1_io_outputs_2_PADDR[15:0];  // USART
    assign system_i2cCtrl_io_apb_PADDR = apb3Router_1_io_outputs_3_PADDR[15:0];  // I2C
    assign system_spiCtrl_io_apb_PADDR = apb3Router_1_io_outputs_4_PADDR[15:0];  // SPI
    assign system_timCtrl_io_apb_PADDR = apb3Router_1_io_outputs_5_PADDR[15:0];  // TIM

    wire [ 7:0] system_cpu_debug_bus_cmd_payload_address;
    wire        system_cpu_dBus_cmd_ready;
    reg         system_ram_io_bus_cmd_valid;
    reg         system_apbBridge_io_pipelinedMemoryBus_cmd_valid;
    wire [ 3:0] system_gpioACtrl_io_apb_PADDR;
    wire [ 4:0] system_uartCtrl_io_apb_PADDR;
    wire [ 7:0] system_timer_io_apb_PADDR;
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
    wire        io_apb_decoder_io_input_PREADY;
    wire [31:0] io_apb_decoder_io_input_PRDATA;
    wire        io_apb_decoder_io_input_PSLVERROR;
    wire [19:0] io_apb_decoder_io_output_PADDR;
    wire [ 2:0] io_apb_decoder_io_output_PSEL;
    wire        io_apb_decoder_io_output_PENABLE;
    wire        io_apb_decoder_io_output_PWRITE;
    wire [31:0] io_apb_decoder_io_output_PWDATA;
    wire        apb3Router_1_io_input_PREADY;
    wire [31:0] apb3Router_1_io_input_PRDATA;
    wire        apb3Router_1_io_input_PSLVERROR;
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

    (* keep_hierarchy = "TRUE" *) BufferCC_RST BufferCC_RST (
        .io_dataIn  (io_asyncReset                    ), //i
        .io_dataOut (io_asyncReset_buffercc_io_dataOut), //o
        .io_mainClk (io_mainClk                       )  //i
    );
    JtagBridge JtagBridge (
        .io_jtag_tms                    (io_jtag_tms                                      ), // i
        .io_jtag_tdi                    (io_jtag_tdi                                      ), // i
        .io_jtag_tdo                    (jtagBridge_1_io_jtag_tdo                         ), // o
        .io_jtag_tck                    (io_jtag_tck                                      ), // i
        .io_remote_cmd_valid            (jtagBridge_1_io_remote_cmd_valid                 ), // o
        .io_remote_cmd_ready            (systemDebugger_1_io_remote_cmd_ready             ), // i
        .io_remote_cmd_payload_last     (jtagBridge_1_io_remote_cmd_payload_last          ), // o
        .io_remote_cmd_payload_fragment (jtagBridge_1_io_remote_cmd_payload_fragment      ), // o
        .io_remote_rsp_valid            (systemDebugger_1_io_remote_rsp_valid             ), // i
        .io_remote_rsp_ready            (jtagBridge_1_io_remote_rsp_ready                 ), // o
        .io_remote_rsp_payload_error    (systemDebugger_1_io_remote_rsp_payload_error     ), // i
        .io_remote_rsp_payload_data     (systemDebugger_1_io_remote_rsp_payload_data[31:0]), // i
        .io_mainClk                     (io_mainClk                                       ), // i
        .resetCtrl_mainClkReset         (resetCtrl_mainClkReset                           )  // i
    );
    Debugger Debugger (
        .io_remote_cmd_valid            (jtagBridge_1_io_remote_cmd_valid                 ), // i
        .io_remote_cmd_ready            (systemDebugger_1_io_remote_cmd_ready             ), // o
        .io_remote_cmd_payload_last     (jtagBridge_1_io_remote_cmd_payload_last          ), // i
        .io_remote_cmd_payload_fragment (jtagBridge_1_io_remote_cmd_payload_fragment      ), // i
        .io_remote_rsp_valid            (systemDebugger_1_io_remote_rsp_valid             ), // o
        .io_remote_rsp_ready            (jtagBridge_1_io_remote_rsp_ready                 ), // i
        .io_remote_rsp_payload_error    (systemDebugger_1_io_remote_rsp_payload_error     ), // o
        .io_remote_rsp_payload_data     (systemDebugger_1_io_remote_rsp_payload_data[31:0]), // o
        .io_mem_cmd_valid               (systemDebugger_1_io_mem_cmd_valid                ), // o
        .io_mem_cmd_ready               (system_cpu_debug_bus_cmd_ready                   ), // i
        .io_mem_cmd_payload_address     (systemDebugger_1_io_mem_cmd_payload_address[31:0]), // o
        .io_mem_cmd_payload_data        (systemDebugger_1_io_mem_cmd_payload_data[31:0]   ), // o
        .io_mem_cmd_payload_wr          (systemDebugger_1_io_mem_cmd_payload_wr           ), // o
        .io_mem_cmd_payload_size        (systemDebugger_1_io_mem_cmd_payload_size[1:0]    ), // o
        .io_mem_rsp_valid               (toplevel_system_cpu_debug_bus_cmd_fire_regNext   ), // i
        .io_mem_rsp_payload             (system_cpu_debug_bus_rsp_data[31:0]              ), // i
        .io_mainClk                     (io_mainClk                                       ), // i
        .resetCtrl_mainClkReset         (resetCtrl_mainClkReset                           )  // i
    );
    VexRiscv VexRiscv (
        .iBus_cmd_valid                (system_cpu_iBus_cmd_valid                           ), //o
        .iBus_cmd_ready                (system_mainBusArbiter_io_iBus_cmd_ready             ), //i
        .iBus_cmd_payload_pc           (system_cpu_iBus_cmd_payload_pc[31:0]                ), //o
        .iBus_rsp_valid                (system_mainBusArbiter_io_iBus_rsp_valid             ), //i
        .iBus_rsp_payload_error        (system_mainBusArbiter_io_iBus_rsp_payload_error     ), //i
        .iBus_rsp_payload_inst         (system_mainBusArbiter_io_iBus_rsp_payload_inst[31:0]), //i
        .timerInterrupt                (system_timerInterrupt                               ), //i
        .externalInterrupt             (system_externalInterrupt                            ), //i
        .softwareInterrupt             (1'b0                                                ), //i
        .debug_bus_cmd_valid           (systemDebugger_1_io_mem_cmd_valid                   ), //i
        .debug_bus_cmd_ready           (system_cpu_debug_bus_cmd_ready                      ), //o
        .debug_bus_cmd_payload_wr      (systemDebugger_1_io_mem_cmd_payload_wr              ), //i
        .debug_bus_cmd_payload_address (system_cpu_debug_bus_cmd_payload_address[7:0]       ), //i
        .debug_bus_cmd_payload_data    (systemDebugger_1_io_mem_cmd_payload_data[31:0]      ), //i
        .debug_bus_rsp_data            (system_cpu_debug_bus_rsp_data[31:0]                 ), //o
        .debug_resetOut                (system_cpu_debug_resetOut                           ), //o
        .dBus_cmd_valid                (system_cpu_dBus_cmd_valid                           ), //o
        .dBus_cmd_ready                (system_cpu_dBus_cmd_ready                           ), //i
        .dBus_cmd_payload_wr           (system_cpu_dBus_cmd_payload_wr                      ), //o
        .dBus_cmd_payload_mask         (system_cpu_dBus_cmd_payload_mask[3:0]               ), //o
        .dBus_cmd_payload_address      (system_cpu_dBus_cmd_payload_address[31:0]           ), //o
        .dBus_cmd_payload_data         (system_cpu_dBus_cmd_payload_data[31:0]              ), //o
        .dBus_cmd_payload_size         (system_cpu_dBus_cmd_payload_size[1:0]               ), //o
        .dBus_rsp_ready                (system_mainBusArbiter_io_dBus_rsp_ready             ), //i
        .dBus_rsp_error                (system_mainBusArbiter_io_dBus_rsp_error             ), //i
        .dBus_rsp_data                 (system_mainBusArbiter_io_dBus_rsp_data[31:0]        ), //i
        .io_mainClk                    (io_mainClk                                          ), //i
        .resetCtrl_systemReset         (resetCtrl_systemReset                               ), //i
        .resetCtrl_mainClkReset        (resetCtrl_mainClkReset                              )  //i
    );
    MasterArbiter MasterArbiter (
        .io_iBus_cmd_valid                (system_cpu_iBus_cmd_valid                                         ), //i
        .io_iBus_cmd_ready                (system_mainBusArbiter_io_iBus_cmd_ready                           ), //o
        .io_iBus_cmd_payload_pc           (system_cpu_iBus_cmd_payload_pc[31:0]                              ), //i
        .io_iBus_rsp_valid                (system_mainBusArbiter_io_iBus_rsp_valid                           ), //o
        .io_iBus_rsp_payload_error        (system_mainBusArbiter_io_iBus_rsp_payload_error                   ), //o
        .io_iBus_rsp_payload_inst         (system_mainBusArbiter_io_iBus_rsp_payload_inst[31:0]              ), //o
        .io_dBus_cmd_valid                (toplevel_system_cpu_dBus_cmd_halfPipe_valid                       ), //i
        .io_dBus_cmd_ready                (system_mainBusArbiter_io_dBus_cmd_ready                           ), //o
        .io_dBus_cmd_payload_wr           (toplevel_system_cpu_dBus_cmd_halfPipe_payload_wr                  ), //i
        .io_dBus_cmd_payload_mask         (toplevel_system_cpu_dBus_cmd_halfPipe_payload_mask[3:0]           ), //i
        .io_dBus_cmd_payload_address      (toplevel_system_cpu_dBus_cmd_halfPipe_payload_address[31:0]       ), //i
        .io_dBus_cmd_payload_data         (toplevel_system_cpu_dBus_cmd_halfPipe_payload_data[31:0]          ), //i
        .io_dBus_cmd_payload_size         (toplevel_system_cpu_dBus_cmd_halfPipe_payload_size[1:0]           ), //i
        .io_dBus_rsp_ready                (system_mainBusArbiter_io_dBus_rsp_ready                           ), //o
        .io_dBus_rsp_error                (system_mainBusArbiter_io_dBus_rsp_error                           ), //o
        .io_dBus_rsp_data                 (system_mainBusArbiter_io_dBus_rsp_data[31:0]                      ), //o
        .io_masterBus_cmd_valid           (system_mainBusArbiter_io_masterBus_cmd_valid                      ), //o
        .io_masterBus_cmd_ready           (system_mainBusDecoder_logic_masterPipelined_cmd_ready             ), //i
        .io_masterBus_cmd_payload_write   (system_mainBusArbiter_io_masterBus_cmd_payload_write              ), //o
        .io_masterBus_cmd_payload_address (system_mainBusArbiter_io_masterBus_cmd_payload_address[31:0]      ), //o
        .io_masterBus_cmd_payload_data    (system_mainBusArbiter_io_masterBus_cmd_payload_data[31:0]         ), //o
        .io_masterBus_cmd_payload_mask    (system_mainBusArbiter_io_masterBus_cmd_payload_mask[3:0]          ), //o
        .io_masterBus_rsp_valid           (system_mainBusDecoder_logic_masterPipelined_rsp_valid             ), //i
        .io_masterBus_rsp_payload_data    (system_mainBusDecoder_logic_masterPipelined_rsp_payload_data[31:0]), //i
        .io_mainClk                       (io_mainClk                                                        ), //i
        .resetCtrl_systemReset            (resetCtrl_systemReset                                             )  //i
    );
    RAM RAM (
        .io_bus_cmd_valid           (system_ram_io_bus_cmd_valid                                          ), // i
        .io_bus_cmd_ready           (system_ram_io_bus_cmd_ready                                          ), // o
        .io_bus_cmd_payload_write   (_zz_io_bus_cmd_payload_write                                         ), // i
        .io_bus_cmd_payload_address (system_mainBusDecoder_logic_masterPipelined_cmd_payload_address[31:0]), // i
        .io_bus_cmd_payload_data    (system_mainBusDecoder_logic_masterPipelined_cmd_payload_data[31:0]   ), // i
        .io_bus_cmd_payload_mask    (system_mainBusDecoder_logic_masterPipelined_cmd_payload_mask[3:0]    ), // i
        .io_bus_rsp_valid           (system_ram_io_bus_rsp_valid                                          ), // o
        .io_bus_rsp_payload_data    (system_ram_io_bus_rsp_payload_data[31:0]                             ), // o
        .io_mainClk                 (io_mainClk                                                           ), // i
        .resetCtrl_systemReset      (resetCtrl_systemReset                                                )  // i
    );
    Apb3PRouter Apb3PRouter (
        .io_input_PADDR     (system_apbBridge_io_apb_PADDR[19:0]),    // i
        .io_input_PSEL      (system_apbBridge_io_apb_PSEL),           // i
        .io_input_PENABLE   (system_apbBridge_io_apb_PENABLE),        // i
        .io_input_PREADY    (io_apb_decoder_io_input_PREADY),         // o
        .io_input_PWRITE    (system_apbBridge_io_apb_PWRITE),         // i
        .io_input_PWDATA    (system_apbBridge_io_apb_PWDATA[31:0]),   // i
        .io_input_PRDATA    (io_apb_decoder_io_input_PRDATA[31:0]),   // o
        .io_input_PSLVERROR (io_apb_decoder_io_input_PSLVERROR),      // o

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

        .io_mainClk            (io_mainClk),                              // i
        .resetCtrl_systemReset (resetCtrl_systemReset)                    // i
    );
    Apb3Bridge Apb3Bridge (
        .io_pipelinedMemoryBus_cmd_valid           (system_apbBridge_io_pipelinedMemoryBus_cmd_valid                     ), // i
        .io_pipelinedMemoryBus_cmd_ready           (system_apbBridge_io_pipelinedMemoryBus_cmd_ready                     ), // o
        .io_pipelinedMemoryBus_cmd_payload_write   (_zz_io_pipelinedMemoryBus_cmd_payload_write                          ), // i
        .io_pipelinedMemoryBus_cmd_payload_address (system_mainBusDecoder_logic_masterPipelined_cmd_payload_address[31:0]), // i
        .io_pipelinedMemoryBus_cmd_payload_data    (system_mainBusDecoder_logic_masterPipelined_cmd_payload_data[31:0]   ), // i
        .io_pipelinedMemoryBus_cmd_payload_mask    (system_mainBusDecoder_logic_masterPipelined_cmd_payload_mask[3:0]    ), // i
        .io_pipelinedMemoryBus_rsp_valid           (system_apbBridge_io_pipelinedMemoryBus_rsp_valid                     ), // o
        .io_pipelinedMemoryBus_rsp_payload_data    (system_apbBridge_io_pipelinedMemoryBus_rsp_payload_data[31:0]        ), // o
        .io_apb_PADDR                              (system_apbBridge_io_apb_PADDR[19:0]                                  ), // o
        .io_apb_PSEL                               (system_apbBridge_io_apb_PSEL                                         ), // o
        .io_apb_PENABLE                            (system_apbBridge_io_apb_PENABLE                                      ), // o
        .io_apb_PREADY                             (io_apb_decoder_io_input_PREADY                                       ), // i
        .io_apb_PWRITE                             (system_apbBridge_io_apb_PWRITE                                       ), // o
        .io_apb_PWDATA                             (system_apbBridge_io_apb_PWDATA[31:0]                                 ), // o
        .io_apb_PRDATA                             (io_apb_decoder_io_input_PRDATA[31:0]                                 ), // i
        .io_apb_PSLVERROR                          (io_apb_decoder_io_input_PSLVERROR                                    ), // i
        .io_mainClk                                (io_mainClk                                                           ), // i
        .resetCtrl_systemReset                     (resetCtrl_systemReset                                                )  // i
    );
    Apb3GPIORouter Apb3GPIORouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_gpioCtrl_io_apb_PADDR),                // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_0_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_0_PENABLE),           // i
        .io_apb_PREADY        (system_gpioCtrl_io_apb_PREADY),               // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_0_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_0_PWDATA),            // i
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
        .io_apb_PSEL          (apb3Router_1_io_outputs_1_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_1_PENABLE),           // i
        .io_apb_PREADY        (system_wdgCtrl_io_apb_PREADY),                // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_1_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_1_PWDATA),            // i
        .io_apb_PRDATA        (system_wdgCtrl_io_apb_PRDATA),                // o
        .io_apb_PSLVERROR     (system_wdgCtrl_io_apb_PSLVERROR),             // o
        .IWDG_rst             (),                                            // o
        .WWDG_rst             ()                                             // o
    );
    Apb3USARTRouter Apb3USARTRouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_usartCtrl_io_apb_PADDR),               // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_2_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_2_PENABLE),           // i
        .io_apb_PREADY        (system_usartCtrl_io_apb_PREADY),              // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_2_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_2_PWDATA),            // i
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
        .io_apb_PSEL          (apb3Router_1_io_outputs_3_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_3_PENABLE),           // i
        .io_apb_PREADY        (system_i2cCtrl_io_apb_PREADY),                // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_3_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_3_PWDATA),            // i
        .io_apb_PRDATA        (system_i2cCtrl_io_apb_PRDATA),                // o
        .io_apb_PSLVERROR     (system_i2cCtrl_io_apb_PSLVERROR),             // o
        .I2C1_SDA             (I2C1_SDA),                                    // i
        .I2C1_SCL             (I2C1_SCL),                                    // o
        .I2C1_interrupt       (),                                            // o  // SPI interrupt
        .I2C2_SDA             (I2C1_SDA),                                    // i
        .I2C2_SCL             (I2C2_SCL),                                    // o
        .I2C2_interrupt       ()                                             // o
    );
    Apb3SPIRouter Apb3SPIRouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_spiCtrl_io_apb_PADDR),                 // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_4_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_4_PENABLE),           // i
        .io_apb_PREADY        (system_spiCtrl_io_apb_PREADY),                // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_4_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_4_PWDATA),            // i
        .io_apb_PRDATA        (system_spiCtrl_io_apb_PRDATA),                // o
        .io_apb_PSLVERROR     (system_spiCtrl_io_apb_PSLVERROR),             // o
        .SPI1_SCK             (SPI1_SCK),                                    // o
        .SPI1_MOSI            (SPI1_MOSI),                                   // o
        .SPI1_MISO            (SPI1_MISO),                                   // i
        .SPI1_CS              (SPI1_CS),                                     // o
        .SPI1_interrupt       (),                                            // o  // SPI interrupt
        .SPI2_SCK             (SPI2_SCK),                                    // o
        .SPI2_MOSI            (SPI2_MOSI),                                   // o
        .SPI2_MISO            (SPI2_MISO),                                   // i
        .SPI2_CS              (SPI2_CS),                                     // o
        .SPI2_interrupt       ()                                             // o
    );
    Apb3TIMRouter Apb3TIMRouter (
        .io_apb_PCLK          (io_mainClk),                                  // i
        .io_apb_PRESET        (resetCtrl_systemReset),                       // i
        .io_apb_PADDR         (system_timCtrl_io_apb_PADDR),                 // i
        .io_apb_PSEL          (apb3Router_1_io_outputs_5_PSEL),              // i
        .io_apb_PENABLE       (apb3Router_1_io_outputs_5_PENABLE),           // i
        .io_apb_PREADY        (system_timCtrl_io_apb_PREADY),                // o
        .io_apb_PWRITE        (apb3Router_1_io_outputs_5_PWRITE),            // i
        .io_apb_PWDATA        (apb3Router_1_io_outputs_5_PWDATA),            // i
        .io_apb_PRDATA        (system_timCtrl_io_apb_PRDATA),                // o
        .io_apb_PSLVERROR     (system_timCtrl_io_apb_PSLVERROR),             // o
        .TIM2_CH              (TIM2_CH),                                     // o
        .TIM2_interrupt       (TIM2_interrupt),                              // o  // TIM interrupt
        .TIM3_CH              (TIM3_CH),                                     // o
        .TIM3_interrupt       (TIM3_interrupt)                               // o
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
        if (TIM2_interrupt | TIM3_interrupt) begin
            system_timerInterrupt = 1'b1;
        end
    end

    always @(*) begin
        system_externalInterrupt = 1'b0;
        if (USART1_interrupt | USART2_interrupt) begin
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
    assign system_mainBusDecoder_logic_masterPipelined_cmd_valid = system_mainBusArbiter_io_masterBus_cmd_valid;
    assign system_mainBusDecoder_logic_masterPipelined_cmd_payload_write = system_mainBusArbiter_io_masterBus_cmd_payload_write;
    assign system_mainBusDecoder_logic_masterPipelined_cmd_payload_address = system_mainBusArbiter_io_masterBus_cmd_payload_address;
    assign system_mainBusDecoder_logic_masterPipelined_cmd_payload_data = system_mainBusArbiter_io_masterBus_cmd_payload_data;
    assign system_mainBusDecoder_logic_masterPipelined_cmd_payload_mask = system_mainBusArbiter_io_masterBus_cmd_payload_mask;
    assign system_mainBusDecoder_logic_hits_0 = ((system_mainBusDecoder_logic_masterPipelined_cmd_payload_address & (~ 32'h0003ffff)) == 32'h80000000);
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


module BufferCC_RST (
    input  wire io_dataIn,
    output wire io_dataOut,
    input  wire io_mainClk
);

    (* async_reg = "true" *)reg buffers_0;
    (* async_reg = "true" *)reg buffers_1;

    assign io_dataOut = buffers_1;
    always @(posedge io_mainClk) begin
        buffers_0 <= io_dataIn;
        buffers_1 <= buffers_0;
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
    input  wire        io_mainClk,
    input  wire        resetCtrl_mainClkReset
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
        .io_mainClk                (io_mainClk),                                         //i
        .resetCtrl_mainClkReset    (resetCtrl_mainClkReset)                              //i
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
    assign _zz_jtag_tap_fsm_stateNext_9 = (io_jtag_tms ? JtagState_IR_SELECT : JtagState_DR_CAPTURE);
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
    always @(posedge io_mainClk) begin
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


module Debugger (
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
    input  wire        io_mainClk,
    input  wire        resetCtrl_mainClkReset
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

    assign dispatcher_header = dispatcher_headerShifter[7 : 0];
    assign when_Fragment_l356 = (dispatcher_headerLoaded == 1'b0);
    assign when_Fragment_l359 = (dispatcher_counter == 3'b111);
    assign io_remote_cmd_ready = (!dispatcher_dataLoaded);
    assign _zz_io_mem_cmd_payload_address = dispatcher_dataShifter[66 : 0];
    assign io_mem_cmd_payload_address = _zz_io_mem_cmd_payload_address[31 : 0];
    assign io_mem_cmd_payload_data = _zz_io_mem_cmd_payload_address[63 : 32];
    assign io_mem_cmd_payload_wr = _zz_io_mem_cmd_payload_address[64];
    assign io_mem_cmd_payload_size = _zz_io_mem_cmd_payload_address[66 : 65];
    assign io_mem_cmd_valid = (dispatcher_dataLoaded && (dispatcher_header == 8'h0));
    assign io_mem_cmd_isStall = (io_mem_cmd_valid && (!io_mem_cmd_ready));
    assign when_Fragment_l382 = ((dispatcher_headerLoaded && dispatcher_dataLoaded) && (! io_mem_cmd_isStall));
    assign io_remote_rsp_valid = io_mem_rsp_valid;
    assign io_remote_rsp_payload_error = 1'b0;
    assign io_remote_rsp_payload_data = io_mem_rsp_payload;
    always @(posedge io_mainClk or posedge resetCtrl_mainClkReset) begin
        if (resetCtrl_mainClkReset) begin
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

    always @(posedge io_mainClk) begin
        if (io_remote_cmd_valid) begin
            if (when_Fragment_l356) begin
                dispatcher_headerShifter <= ({io_remote_cmd_payload_fragment,dispatcher_headerShifter} >>> 1'd1);
            end else begin
                dispatcher_dataShifter <= ({io_remote_cmd_payload_fragment,dispatcher_dataShifter} >>> 1'd1);
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
    input  wire       io_mainClk,
    input  wire       resetCtrl_mainClkReset
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

    (* keep_hierarchy = "TRUE" *) BufferCC_JTAG BufferCC_JTAG (
        .io_dataIn             (inputArea_target),                      //i
        .io_dataOut            (inputArea_target_buffercc_io_dataOut),  //o
        .io_mainClk            (io_mainClk),                            //i
        .resetCtrl_mainClkReset(resetCtrl_mainClkReset)                 //i
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

    always @(posedge io_mainClk) begin
        outputArea_hit <= outputArea_target;
        if (outputArea_flow_valid) begin
            outputArea_flow_m2sPipe_payload_last <= outputArea_flow_payload_last;
            outputArea_flow_m2sPipe_payload_fragment <= outputArea_flow_payload_fragment;
        end
    end

    always @(posedge io_mainClk or posedge resetCtrl_mainClkReset) begin
        if (resetCtrl_mainClkReset) begin
            outputArea_flow_m2sPipe_valid <= 1'b0;
        end else begin
            outputArea_flow_m2sPipe_valid <= outputArea_flow_valid;
        end
    end

endmodule


module BufferCC_JTAG (
    input  wire io_dataIn,
    output wire io_dataOut,
    input  wire io_mainClk,
    input  wire resetCtrl_mainClkReset
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
    always @(posedge io_mainClk) begin
        buffers_0 <= io_dataIn;
        buffers_1 <= buffers_0;
    end

endmodule


module VexRiscv (
    output wire        iBus_cmd_valid,
    input  wire        iBus_cmd_ready,
    output wire [31:0] iBus_cmd_payload_pc,
    input  wire        iBus_rsp_valid,
    input  wire        iBus_rsp_payload_error,
    input  wire [31:0] iBus_rsp_payload_inst,
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
    output wire        dBus_cmd_valid,
    input  wire        dBus_cmd_ready,
    output wire        dBus_cmd_payload_wr,
    output wire [ 3:0] dBus_cmd_payload_mask,
    output wire [31:0] dBus_cmd_payload_address,
    output wire [31:0] dBus_cmd_payload_data,
    output wire [ 1:0] dBus_cmd_payload_size,
    input  wire        dBus_rsp_ready,
    input  wire        dBus_rsp_error,
    input  wire [31:0] dBus_rsp_data,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset,
    input  wire        resetCtrl_mainClkReset
);
    localparam BranchCtrlEnum_INC = 2'd0;
    localparam BranchCtrlEnum_B = 2'd1;
    localparam BranchCtrlEnum_JAL = 2'd2;
    localparam BranchCtrlEnum_JALR = 2'd3;
    localparam ShiftCtrlEnum_DISABLE_1 = 2'd0;
    localparam ShiftCtrlEnum_SLL_1 = 2'd1;
    localparam ShiftCtrlEnum_SRL_1 = 2'd2;
    localparam ShiftCtrlEnum_SRA_1 = 2'd3;
    localparam AluBitwiseCtrlEnum_XOR_1 = 2'd0;
    localparam AluBitwiseCtrlEnum_OR_1 = 2'd1;
    localparam AluBitwiseCtrlEnum_AND_1 = 2'd2;
    localparam AluCtrlEnum_ADD_SUB = 2'd0;
    localparam AluCtrlEnum_SLT_SLTU = 2'd1;
    localparam AluCtrlEnum_BITWISE = 2'd2;
    localparam EnvCtrlEnum_NONE = 1'd0;
    localparam EnvCtrlEnum_XRET = 1'd1;
    localparam Src2CtrlEnum_RS = 2'd0;
    localparam Src2CtrlEnum_IMI = 2'd1;
    localparam Src2CtrlEnum_IMS = 2'd2;
    localparam Src2CtrlEnum_PC = 2'd3;
    localparam Src1CtrlEnum_RS = 2'd0;
    localparam Src1CtrlEnum_IMU = 2'd1;
    localparam Src1CtrlEnum_PC_INCREMENT = 2'd2;
    localparam Src1CtrlEnum_URS1 = 2'd3;

    wire        IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready;
    reg  [31:0] RegFilePlugin_regFile_spinal_port0;
    reg  [31:0] RegFilePlugin_regFile_spinal_port1;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error;
    wire [31:0] IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst;
    wire [ 0:0] IBusSimplePlugin_rspJoin_rspBuffer_c_io_occupancy;
    wire [ 0:0] IBusSimplePlugin_rspJoin_rspBuffer_c_io_availability;
    wire [51:0] _zz_memory_MUL_LOW;
    wire [51:0] _zz_memory_MUL_LOW_1;
    wire [51:0] _zz_memory_MUL_LOW_2;
    wire [32:0] _zz_memory_MUL_LOW_3;
    wire [51:0] _zz_memory_MUL_LOW_4;
    wire [49:0] _zz_memory_MUL_LOW_5;
    wire [51:0] _zz_memory_MUL_LOW_6;
    wire [49:0] _zz_memory_MUL_LOW_7;
    wire [ 1:0] _zz_IBusSimplePlugin_jump_pcLoad_payload_1;
    wire [ 1:0] _zz_IBusSimplePlugin_jump_pcLoad_payload_2;
    wire [31:0] _zz_IBusSimplePlugin_fetchPc_pc;
    wire [ 2:0] _zz_IBusSimplePlugin_fetchPc_pc_1;
    wire [ 2:0] _zz_IBusSimplePlugin_pending_next;
    wire [ 2:0] _zz_IBusSimplePlugin_pending_next_1;
    wire [ 0:0] _zz_IBusSimplePlugin_pending_next_2;
    wire [ 2:0] _zz_IBusSimplePlugin_pending_next_3;
    wire [ 0:0] _zz_IBusSimplePlugin_pending_next_4;
    wire [ 2:0] _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter;
    wire [ 0:0] _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1;
    wire        _zz__zz_decode_IS_RS2_SIGNED;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_1;
    wire        _zz__zz_decode_IS_RS2_SIGNED_2;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_3;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_4;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_5;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_6;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_7;
    wire [22:0] _zz__zz_decode_IS_RS2_SIGNED_8;
    wire        _zz__zz_decode_IS_RS2_SIGNED_9;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_10;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_11;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_12;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_13;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_14;
    wire        _zz__zz_decode_IS_RS2_SIGNED_15;
    wire        _zz__zz_decode_IS_RS2_SIGNED_16;
    wire        _zz__zz_decode_IS_RS2_SIGNED_17;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_18;
    wire        _zz__zz_decode_IS_RS2_SIGNED_19;
    wire [18:0] _zz__zz_decode_IS_RS2_SIGNED_20;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_21;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_22;
    wire        _zz__zz_decode_IS_RS2_SIGNED_23;
    wire        _zz__zz_decode_IS_RS2_SIGNED_24;
    wire        _zz__zz_decode_IS_RS2_SIGNED_25;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_26;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_27;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_28;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_29;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_30;
    wire [15:0] _zz__zz_decode_IS_RS2_SIGNED_31;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_32;
    wire        _zz__zz_decode_IS_RS2_SIGNED_33;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_34;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_35;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_36;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_37;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_38;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_39;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_40;
    wire [12:0] _zz__zz_decode_IS_RS2_SIGNED_41;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_42;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_43;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_44;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_45;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_46;
    wire        _zz__zz_decode_IS_RS2_SIGNED_47;
    wire        _zz__zz_decode_IS_RS2_SIGNED_48;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_49;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_50;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_51;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_52;
    wire        _zz__zz_decode_IS_RS2_SIGNED_53;
    wire [ 9:0] _zz__zz_decode_IS_RS2_SIGNED_54;
    wire [ 4:0] _zz__zz_decode_IS_RS2_SIGNED_55;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_56;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_57;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_58;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_59;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_60;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_61;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_62;
    wire        _zz__zz_decode_IS_RS2_SIGNED_63;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_64;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_65;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_66;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_67;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_68;
    wire [ 4:0] _zz__zz_decode_IS_RS2_SIGNED_69;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_70;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_71;
    wire        _zz__zz_decode_IS_RS2_SIGNED_72;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_73;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_74;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_75;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_76;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_77;
    wire        _zz__zz_decode_IS_RS2_SIGNED_78;
    wire        _zz__zz_decode_IS_RS2_SIGNED_79;
    wire [ 6:0] _zz__zz_decode_IS_RS2_SIGNED_80;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_81;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_82;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_83;
    wire        _zz__zz_decode_IS_RS2_SIGNED_84;
    wire        _zz__zz_decode_IS_RS2_SIGNED_85;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_86;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_87;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_88;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_89;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_90;
    wire [ 2:0] _zz__zz_decode_IS_RS2_SIGNED_91;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_92;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_93;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_94;
    wire [ 3:0] _zz__zz_decode_IS_RS2_SIGNED_95;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_96;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_97;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_98;
    wire        _zz__zz_decode_IS_RS2_SIGNED_99;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_100;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_101;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_102;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_103;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_104;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_105;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_106;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_107;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_108;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_109;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_110;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_111;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_112;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_113;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_114;
    wire        _zz_RegFilePlugin_regFile_port;
    wire        _zz_decode_RegFilePlugin_rs1Data;
    wire        _zz_RegFilePlugin_regFile_port_1;
    wire        _zz_decode_RegFilePlugin_rs2Data;
    wire [ 0:0] _zz__zz_execute_REGFILE_WRITE_DATA;
    wire [ 2:0] _zz__zz_decode_SRC1;
    wire [ 4:0] _zz__zz_decode_SRC1_1;
    wire [11:0] _zz__zz_decode_SRC2_2;
    wire [31:0] _zz_execute_SrcPlugin_addSub;
    wire [31:0] _zz_execute_SrcPlugin_addSub_1;
    wire [31:0] _zz_execute_SrcPlugin_addSub_2;
    wire [31:0] _zz_execute_SrcPlugin_addSub_3;
    wire [31:0] _zz_execute_SrcPlugin_addSub_4;
    wire [31:0] _zz__zz_decode_RS2_3;
    wire [32:0] _zz__zz_decode_RS2_3_1;
    wire [19:0] _zz__zz_execute_BranchPlugin_branch_src2;
    wire [11:0] _zz__zz_execute_BranchPlugin_branch_src2_4;
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
    wire [51:0] memory_MUL_LOW;
    wire [31:0] memory_MEMORY_READ_DATA;
    wire [33:0] memory_MUL_HH;
    wire [33:0] execute_MUL_HH;
    wire [33:0] execute_MUL_HL;
    wire [33:0] execute_MUL_LH;
    wire [31:0] execute_MUL_LL;
    wire [31:0] execute_BRANCH_CALC;
    wire        execute_BRANCH_DO;
    wire [31:0] writeBack_REGFILE_WRITE_DATA;
    wire [31:0] execute_REGFILE_WRITE_DATA;
    wire [ 1:0] memory_MEMORY_ADDRESS_LOW;
    wire [ 1:0] execute_MEMORY_ADDRESS_LOW;
    wire        decode_DO_EBREAK;
    wire [31:0] decode_SRC2;
    wire [31:0] decode_SRC1;
    wire        decode_SRC2_FORCE_ZERO;
    wire        decode_IS_RS2_SIGNED;
    wire        decode_IS_RS1_SIGNED;
    wire        decode_IS_DIV;
    wire        memory_IS_MUL;
    wire        execute_IS_MUL;
    wire        decode_IS_MUL;
    wire [ 1:0] decode_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_to_execute_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_to_execute_BRANCH_CTRL_1;
    wire [ 1:0] decode_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SHIFT_CTRL_1;
    wire [ 1:0] decode_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
    wire        decode_SRC_LESS_UNSIGNED;
    wire [ 1:0] decode_ALU_CTRL;
    wire [ 1:0] _zz_decode_ALU_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_CTRL_1;
    wire [ 0:0] _zz_memory_to_writeBack_ENV_CTRL;
    wire [ 0:0] _zz_memory_to_writeBack_ENV_CTRL_1;
    wire [ 0:0] _zz_execute_to_memory_ENV_CTRL;
    wire [ 0:0] _zz_execute_to_memory_ENV_CTRL_1;
    wire [ 0:0] decode_ENV_CTRL;
    wire [ 0:0] _zz_decode_ENV_CTRL;
    wire [ 0:0] _zz_decode_to_execute_ENV_CTRL;
    wire [ 0:0] _zz_decode_to_execute_ENV_CTRL_1;
    wire        decode_IS_CSR;
    wire        decode_MEMORY_STORE;
    wire        execute_BYPASSABLE_MEMORY_STAGE;
    wire        decode_BYPASSABLE_MEMORY_STAGE;
    wire        decode_BYPASSABLE_EXECUTE_STAGE;
    wire        decode_MEMORY_ENABLE;
    wire        decode_CSR_READ_OPCODE;
    wire        decode_CSR_WRITE_OPCODE;
    wire [31:0] writeBack_FORMAL_PC_NEXT;
    wire [31:0] memory_FORMAL_PC_NEXT;
    wire [31:0] execute_FORMAL_PC_NEXT;
    wire [31:0] decode_FORMAL_PC_NEXT;
    wire [31:0] memory_PC;
    wire        execute_DO_EBREAK;
    wire        decode_IS_EBREAK;
    wire        execute_IS_RS1_SIGNED;
    wire        execute_IS_DIV;
    wire        execute_IS_RS2_SIGNED;
    wire        memory_IS_DIV;
    wire        writeBack_IS_MUL;
    wire [33:0] writeBack_MUL_HH;
    wire [51:0] writeBack_MUL_LOW;
    wire [33:0] memory_MUL_HL;
    wire [33:0] memory_MUL_LH;
    wire [31:0] memory_MUL_LL;
    wire [31:0] memory_BRANCH_CALC;
    wire        memory_BRANCH_DO;
    wire [31:0] execute_PC;
    (* keep , syn_keep *)wire [31:0] execute_RS1  /* synthesis syn_keep = 1 */;
    wire [ 1:0] execute_BRANCH_CTRL;
    wire [ 1:0] _zz_execute_BRANCH_CTRL;
    wire        decode_RS2_USE;
    wire        decode_RS1_USE;
    wire        execute_REGFILE_WRITE_VALID;
    wire        execute_BYPASSABLE_EXECUTE_STAGE;
    reg  [31:0] _zz_decode_RS2;
    wire        memory_REGFILE_WRITE_VALID;
    wire [31:0] memory_INSTRUCTION;
    wire        memory_BYPASSABLE_MEMORY_STAGE;
    wire        writeBack_REGFILE_WRITE_VALID;
    reg  [31:0] decode_RS2;
    reg  [31:0] decode_RS1;
    wire [31:0] memory_REGFILE_WRITE_DATA;
    wire [ 1:0] execute_SHIFT_CTRL;
    wire [ 1:0] _zz_execute_SHIFT_CTRL;
    wire        execute_SRC_LESS_UNSIGNED;
    wire        execute_SRC2_FORCE_ZERO;
    wire        execute_SRC_USE_SUB_LESS;
    wire [31:0] _zz_decode_to_execute_PC;
    wire [31:0] _zz_decode_to_execute_RS2;
    wire [ 1:0] decode_SRC2_CTRL;
    wire [ 1:0] _zz_decode_SRC2_CTRL;
    wire [31:0] _zz_decode_to_execute_RS1;
    wire [ 1:0] decode_SRC1_CTRL;
    wire [ 1:0] _zz_decode_SRC1_CTRL;
    wire        decode_SRC_USE_SUB_LESS;
    wire        decode_SRC_ADD_ZERO;
    wire [31:0] execute_SRC_ADD_SUB;
    wire        execute_SRC_LESS;
    wire [ 1:0] execute_ALU_CTRL;
    wire [ 1:0] _zz_execute_ALU_CTRL;
    wire [31:0] execute_SRC2;
    wire [ 1:0] execute_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_execute_ALU_BITWISE_CTRL;
    wire [31:0] _zz_lastStageRegFileWrite_payload_address;
    wire        _zz_lastStageRegFileWrite_valid;
    reg         _zz_1;
    wire [31:0] decode_INSTRUCTION_ANTICIPATED;
    reg         decode_REGFILE_WRITE_VALID;
    wire [ 1:0] _zz_decode_BRANCH_CTRL_1;
    wire [ 1:0] _zz_decode_SHIFT_CTRL_1;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL_1;
    wire [ 1:0] _zz_decode_ALU_CTRL_1;
    wire [ 0:0] _zz_decode_ENV_CTRL_1;
    wire [ 1:0] _zz_decode_SRC2_CTRL_1;
    wire [ 1:0] _zz_decode_SRC1_CTRL_1;
    reg  [31:0] _zz_decode_RS2_1;
    wire [31:0] execute_SRC1;
    wire        execute_CSR_READ_OPCODE;
    wire        execute_CSR_WRITE_OPCODE;
    wire        execute_IS_CSR;
    wire [ 0:0] memory_ENV_CTRL;
    wire [ 0:0] _zz_memory_ENV_CTRL;
    wire [ 0:0] execute_ENV_CTRL;
    wire [ 0:0] _zz_execute_ENV_CTRL;
    wire [ 0:0] writeBack_ENV_CTRL;
    wire [ 0:0] _zz_writeBack_ENV_CTRL;
    reg  [31:0] _zz_decode_RS2_2;
    wire        writeBack_MEMORY_ENABLE;
    wire [ 1:0] writeBack_MEMORY_ADDRESS_LOW;
    wire [31:0] writeBack_MEMORY_READ_DATA;
    wire        memory_MEMORY_STORE;
    wire        memory_MEMORY_ENABLE;
    wire [31:0] execute_SRC_ADD;
    (* keep , syn_keep *)wire [31:0] execute_RS2  /* synthesis syn_keep = 1 */;
    wire [31:0] execute_INSTRUCTION;
    wire        execute_MEMORY_STORE;
    wire        execute_MEMORY_ENABLE;
    wire        execute_ALIGNEMENT_FAULT;
    reg  [31:0] _zz_memory_to_writeBack_FORMAL_PC_NEXT;
    wire [31:0] decode_PC;
    wire [31:0] decode_INSTRUCTION;
    wire [31:0] writeBack_PC;
    wire [31:0] writeBack_INSTRUCTION;
    reg         decode_arbitration_haltItself;
    reg         decode_arbitration_haltByOther;
    reg         decode_arbitration_removeIt;
    wire        decode_arbitration_flushIt;
    wire        decode_arbitration_flushNext;
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
    wire        writeBack_arbitration_haltItself;
    wire        writeBack_arbitration_haltByOther;
    reg         writeBack_arbitration_removeIt;
    wire        writeBack_arbitration_flushIt;
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
    reg         IBusSimplePlugin_fetcherHalt;
    wire        IBusSimplePlugin_forceNoDecodeCond;
    reg         IBusSimplePlugin_incomingInstruction;
    wire        IBusSimplePlugin_pcValids_0;
    wire        IBusSimplePlugin_pcValids_1;
    wire        IBusSimplePlugin_pcValids_2;
    wire        IBusSimplePlugin_pcValids_3;
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
    wire        BranchPlugin_jumpInterface_valid;
    wire [31:0] BranchPlugin_jumpInterface_payload;
    reg         BranchPlugin_inDebugNoFetchFlag;
    reg         DebugPlugin_injectionPort_valid;
    reg         DebugPlugin_injectionPort_ready;
    wire [31:0] DebugPlugin_injectionPort_payload;
    wire        IBusSimplePlugin_externalFlush;
    wire        IBusSimplePlugin_jump_pcLoad_valid;
    wire [31:0] IBusSimplePlugin_jump_pcLoad_payload;
    wire [ 1:0] _zz_IBusSimplePlugin_jump_pcLoad_payload;
    wire        IBusSimplePlugin_fetchPc_output_valid;
    wire        IBusSimplePlugin_fetchPc_output_ready;
    wire [31:0] IBusSimplePlugin_fetchPc_output_payload;
    reg  [31:0] IBusSimplePlugin_fetchPc_pcReg  /* verilator public */;
    reg         IBusSimplePlugin_fetchPc_correction;
    reg         IBusSimplePlugin_fetchPc_correctionReg;
    wire        IBusSimplePlugin_fetchPc_output_fire;
    wire        IBusSimplePlugin_fetchPc_corrected;
    reg         IBusSimplePlugin_fetchPc_pcRegPropagate;
    reg         IBusSimplePlugin_fetchPc_booted;
    reg         IBusSimplePlugin_fetchPc_inc;
    wire        when_Fetcher_l133;
    wire        when_Fetcher_l133_1;
    reg  [31:0] IBusSimplePlugin_fetchPc_pc;
    reg         IBusSimplePlugin_fetchPc_flushed;
    wire        when_Fetcher_l160;
    wire        IBusSimplePlugin_iBusRsp_redoFetch;
    wire        IBusSimplePlugin_iBusRsp_stages_0_input_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_0_input_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_input_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_0_output_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_0_output_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_output_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_0_halt;
    wire        IBusSimplePlugin_iBusRsp_stages_1_input_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_1_input_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_input_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_1_output_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_1_output_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_output_payload;
    reg         IBusSimplePlugin_iBusRsp_stages_1_halt;
    wire        IBusSimplePlugin_iBusRsp_stages_2_input_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_2_input_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_2_input_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_2_output_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_2_output_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_2_output_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_2_halt;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_2_input_ready;
    wire        IBusSimplePlugin_iBusRsp_flush;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_0_output_ready;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid;
    reg         _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1;
    wire        IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    reg         _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    reg  [31:0] _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    reg         IBusSimplePlugin_iBusRsp_readyForError;
    wire        IBusSimplePlugin_iBusRsp_output_valid;
    wire        IBusSimplePlugin_iBusRsp_output_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_output_payload_pc;
    wire        IBusSimplePlugin_iBusRsp_output_payload_rsp_error;
    wire [31:0] IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
    wire        IBusSimplePlugin_iBusRsp_output_payload_isRvc;
    wire        when_Fetcher_l242;
    wire        IBusSimplePlugin_injector_decodeInput_valid;
    wire        IBusSimplePlugin_injector_decodeInput_ready;
    wire [31:0] IBusSimplePlugin_injector_decodeInput_payload_pc;
    wire        IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
    wire [31:0] IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
    wire        IBusSimplePlugin_injector_decodeInput_payload_isRvc;
    reg         _zz_IBusSimplePlugin_injector_decodeInput_valid;
    reg  [31:0] _zz_IBusSimplePlugin_injector_decodeInput_payload_pc;
    reg         _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
    reg  [31:0] _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
    reg         _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc;
    wire        when_Fetcher_l322;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_0;
    wire        when_Fetcher_l331;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_1;
    wire        when_Fetcher_l331_1;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_2;
    wire        when_Fetcher_l331_2;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_3;
    wire        when_Fetcher_l331_3;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_4;
    wire        when_Fetcher_l331_4;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_5;
    wire        when_Fetcher_l331_5;
    reg  [31:0] IBusSimplePlugin_injector_formal_rawInDecode;
    wire        IBusSimplePlugin_cmd_valid;
    wire        IBusSimplePlugin_cmd_ready;
    wire [31:0] IBusSimplePlugin_cmd_payload_pc;
    wire        IBusSimplePlugin_pending_inc;
    wire        IBusSimplePlugin_pending_dec;
    reg  [ 2:0] IBusSimplePlugin_pending_value;
    wire [ 2:0] IBusSimplePlugin_pending_next;
    wire        IBusSimplePlugin_cmdFork_canEmit;
    wire        when_IBusSimplePlugin_l305;
    wire        IBusSimplePlugin_cmd_fire;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_output_valid;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_output_ready;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error;
    wire [31:0] IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst;
    reg  [ 2:0] IBusSimplePlugin_rspJoin_rspBuffer_discardCounter;
    wire        iBus_rsp_toStream_valid;
    wire        iBus_rsp_toStream_ready;
    wire        iBus_rsp_toStream_payload_error;
    wire [31:0] iBus_rsp_toStream_payload_inst;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_flush;
    wire        system_cpu_IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire;
    wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_pc;
    reg         IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
    wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
    wire        IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
    wire        when_IBusSimplePlugin_l376;
    wire        IBusSimplePlugin_rspJoin_join_valid;
    wire        IBusSimplePlugin_rspJoin_join_ready;
    wire [31:0] IBusSimplePlugin_rspJoin_join_payload_pc;
    wire        IBusSimplePlugin_rspJoin_join_payload_rsp_error;
    wire [31:0] IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
    wire        IBusSimplePlugin_rspJoin_join_payload_isRvc;
    wire        IBusSimplePlugin_rspJoin_exceptionDetected;
    wire        IBusSimplePlugin_rspJoin_join_fire;
    wire        _zz_IBusSimplePlugin_iBusRsp_output_valid;
    wire        _zz_dBus_cmd_valid;
    reg         execute_DBusSimplePlugin_skipCmd;
    reg  [31:0] _zz_dBus_cmd_payload_data;
    wire        when_DBusSimplePlugin_l434;
    reg  [ 3:0] _zz_execute_DBusSimplePlugin_formalMask;
    wire [ 3:0] execute_DBusSimplePlugin_formalMask;
    wire        when_DBusSimplePlugin_l489;
    reg  [31:0] writeBack_DBusSimplePlugin_rspShifted;
    wire [ 1:0] switch_Misc_l241;
    wire        _zz_writeBack_DBusSimplePlugin_rspFormated;
    reg  [31:0] _zz_writeBack_DBusSimplePlugin_rspFormated_1;
    wire        _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    reg  [31:0] _zz_writeBack_DBusSimplePlugin_rspFormated_3;
    reg  [31:0] writeBack_DBusSimplePlugin_rspFormated;
    wire        when_DBusSimplePlugin_l565;
    wire [ 1:0] CsrPlugin_misa_base;
    wire [25:0] CsrPlugin_misa_extensions;
    wire [ 1:0] CsrPlugin_mtvec_mode;
    wire [29:0] CsrPlugin_mtvec_base;
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
    wire        CsrPlugin_interruptJump  /* verilator public */;
    reg         CsrPlugin_hadException  /* verilator public */;
    wire [ 1:0] CsrPlugin_targetPrivilege;
    wire [ 3:0] CsrPlugin_trapCause;
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
    wire        switch_Misc_l241_1;
    reg  [31:0] _zz_CsrPlugin_csrMapping_writeDataSignal;
    wire        when_CsrPlugin_l1587;
    wire        when_CsrPlugin_l1591;
    wire [11:0] execute_CsrPlugin_csrAddress;
    wire [29:0] _zz_decode_IS_RS2_SIGNED;
    wire        _zz_decode_IS_RS2_SIGNED_1;
    wire        _zz_decode_IS_RS2_SIGNED_2;
    wire        _zz_decode_IS_RS2_SIGNED_3;
    wire        _zz_decode_IS_RS2_SIGNED_4;
    wire        _zz_decode_IS_RS2_SIGNED_5;
    wire        _zz_decode_IS_RS2_SIGNED_6;
    wire        _zz_decode_IS_RS2_SIGNED_7;
    wire [ 1:0] _zz_decode_SRC1_CTRL_2;
    wire [ 1:0] _zz_decode_SRC2_CTRL_2;
    wire [ 0:0] _zz_decode_ENV_CTRL_2;
    wire [ 1:0] _zz_decode_ALU_CTRL_2;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL_2;
    wire [ 1:0] _zz_decode_SHIFT_CTRL_2;
    wire [ 1:0] _zz_decode_BRANCH_CTRL_2;
    wire        when_RegFilePlugin_l63;
    wire [ 4:0] decode_RegFilePlugin_regFileReadAddress1;
    wire [ 4:0] decode_RegFilePlugin_regFileReadAddress2;
    wire [31:0] decode_RegFilePlugin_rs1Data;
    wire [31:0] decode_RegFilePlugin_rs2Data;
    reg         lastStageRegFileWrite_valid  /* verilator public */;
    reg  [ 4:0] lastStageRegFileWrite_payload_address  /* verilator public */;
    reg  [31:0] lastStageRegFileWrite_payload_data  /* verilator public */;
    reg         _zz_5;
    reg  [31:0] execute_IntAluPlugin_bitwise;
    reg  [31:0] _zz_execute_REGFILE_WRITE_DATA;
    reg  [31:0] _zz_decode_SRC1;
    wire        _zz_decode_SRC2;
    reg  [19:0] _zz_decode_SRC2_1;
    wire        _zz_decode_SRC2_2;
    reg  [19:0] _zz_decode_SRC2_3;
    reg  [31:0] _zz_decode_SRC2_4;
    reg  [31:0] execute_SrcPlugin_addSub;
    wire        execute_SrcPlugin_less;
    reg         execute_LightShifterPlugin_isActive;
    wire        execute_LightShifterPlugin_isShift;
    reg  [ 4:0] execute_LightShifterPlugin_amplitudeReg;
    wire [ 4:0] execute_LightShifterPlugin_amplitude;
    wire [31:0] execute_LightShifterPlugin_shiftInput;
    wire        execute_LightShifterPlugin_done;
    wire        when_ShiftPlugins_l169;
    reg  [31:0] _zz_decode_RS2_3;
    wire        when_ShiftPlugins_l175;
    wire        when_ShiftPlugins_l184;
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
    wire [ 2:0] switch_Misc_l241_2;
    reg         _zz_execute_BRANCH_DO;
    reg         _zz_execute_BRANCH_DO_1;
    wire [31:0] execute_BranchPlugin_branch_src1;
    wire        _zz_execute_BranchPlugin_branch_src2;
    reg  [10:0] _zz_execute_BranchPlugin_branch_src2_1;
    wire        _zz_execute_BranchPlugin_branch_src2_2;
    reg  [19:0] _zz_execute_BranchPlugin_branch_src2_3;
    wire        _zz_execute_BranchPlugin_branch_src2_4;
    reg  [18:0] _zz_execute_BranchPlugin_branch_src2_5;
    reg  [31:0] _zz_execute_BranchPlugin_branch_src2_6;
    wire [31:0] execute_BranchPlugin_branch_src2;
    wire [31:0] execute_BranchPlugin_branchAdder;
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
    reg         decode_to_execute_CSR_WRITE_OPCODE;
    wire        when_Pipeline_l124_10;
    reg         decode_to_execute_CSR_READ_OPCODE;
    wire        when_Pipeline_l124_11;
    reg         decode_to_execute_SRC_USE_SUB_LESS;
    wire        when_Pipeline_l124_12;
    reg         decode_to_execute_MEMORY_ENABLE;
    wire        when_Pipeline_l124_13;
    reg         execute_to_memory_MEMORY_ENABLE;
    wire        when_Pipeline_l124_14;
    reg         memory_to_writeBack_MEMORY_ENABLE;
    wire        when_Pipeline_l124_15;
    reg         decode_to_execute_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_16;
    reg         execute_to_memory_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_17;
    reg         memory_to_writeBack_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_18;
    reg         decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
    wire        when_Pipeline_l124_19;
    reg         decode_to_execute_BYPASSABLE_MEMORY_STAGE;
    wire        when_Pipeline_l124_20;
    reg         execute_to_memory_BYPASSABLE_MEMORY_STAGE;
    wire        when_Pipeline_l124_21;
    reg         decode_to_execute_MEMORY_STORE;
    wire        when_Pipeline_l124_22;
    reg         execute_to_memory_MEMORY_STORE;
    wire        when_Pipeline_l124_23;
    reg         decode_to_execute_IS_CSR;
    wire        when_Pipeline_l124_24;
    reg  [ 0:0] decode_to_execute_ENV_CTRL;
    wire        when_Pipeline_l124_25;
    reg  [ 0:0] execute_to_memory_ENV_CTRL;
    wire        when_Pipeline_l124_26;
    reg  [ 0:0] memory_to_writeBack_ENV_CTRL;
    wire        when_Pipeline_l124_27;
    reg  [ 1:0] decode_to_execute_ALU_CTRL;
    wire        when_Pipeline_l124_28;
    reg         decode_to_execute_SRC_LESS_UNSIGNED;
    wire        when_Pipeline_l124_29;
    reg  [ 1:0] decode_to_execute_ALU_BITWISE_CTRL;
    wire        when_Pipeline_l124_30;
    reg  [ 1:0] decode_to_execute_SHIFT_CTRL;
    wire        when_Pipeline_l124_31;
    reg  [ 1:0] decode_to_execute_BRANCH_CTRL;
    wire        when_Pipeline_l124_32;
    reg         decode_to_execute_IS_MUL;
    wire        when_Pipeline_l124_33;
    reg         execute_to_memory_IS_MUL;
    wire        when_Pipeline_l124_34;
    reg         memory_to_writeBack_IS_MUL;
    wire        when_Pipeline_l124_35;
    reg         decode_to_execute_IS_DIV;
    wire        when_Pipeline_l124_36;
    reg         execute_to_memory_IS_DIV;
    wire        when_Pipeline_l124_37;
    reg         decode_to_execute_IS_RS1_SIGNED;
    wire        when_Pipeline_l124_38;
    reg         decode_to_execute_IS_RS2_SIGNED;
    wire        when_Pipeline_l124_39;
    reg  [31:0] decode_to_execute_RS1;
    wire        when_Pipeline_l124_40;
    reg  [31:0] decode_to_execute_RS2;
    wire        when_Pipeline_l124_41;
    reg         decode_to_execute_SRC2_FORCE_ZERO;
    wire        when_Pipeline_l124_42;
    reg  [31:0] decode_to_execute_SRC1;
    wire        when_Pipeline_l124_43;
    reg  [31:0] decode_to_execute_SRC2;
    wire        when_Pipeline_l124_44;
    reg         decode_to_execute_DO_EBREAK;
    wire        when_Pipeline_l124_45;
    reg  [ 1:0] execute_to_memory_MEMORY_ADDRESS_LOW;
    wire        when_Pipeline_l124_46;
    reg  [ 1:0] memory_to_writeBack_MEMORY_ADDRESS_LOW;
    wire        when_Pipeline_l124_47;
    reg  [31:0] execute_to_memory_REGFILE_WRITE_DATA;
    wire        when_Pipeline_l124_48;
    reg  [31:0] memory_to_writeBack_REGFILE_WRITE_DATA;
    wire        when_Pipeline_l124_49;
    reg         execute_to_memory_BRANCH_DO;
    wire        when_Pipeline_l124_50;
    reg  [31:0] execute_to_memory_BRANCH_CALC;
    wire        when_Pipeline_l124_51;
    reg  [31:0] execute_to_memory_MUL_LL;
    wire        when_Pipeline_l124_52;
    reg  [33:0] execute_to_memory_MUL_LH;
    wire        when_Pipeline_l124_53;
    reg  [33:0] execute_to_memory_MUL_HL;
    wire        when_Pipeline_l124_54;
    reg  [33:0] execute_to_memory_MUL_HH;
    wire        when_Pipeline_l124_55;
    reg  [33:0] memory_to_writeBack_MUL_HH;
    wire        when_Pipeline_l124_56;
    reg  [31:0] memory_to_writeBack_MEMORY_READ_DATA;
    wire        when_Pipeline_l124_57;
    reg  [51:0] memory_to_writeBack_MUL_LOW;
    wire        when_Pipeline_l151;
    wire        when_Pipeline_l154;
    wire        when_Pipeline_l151_1;
    wire        when_Pipeline_l154_1;
    wire        when_Pipeline_l151_2;
    wire        when_Pipeline_l154_2;
    reg  [ 2:0] IBusSimplePlugin_injector_port_state;
    wire        when_Fetcher_l391;
    wire        when_Fetcher_l411;
    wire        when_CsrPlugin_l1669;
    reg         execute_CsrPlugin_csr_768;
    wire        when_CsrPlugin_l1669_1;
    reg         execute_CsrPlugin_csr_836;
    wire        when_CsrPlugin_l1669_2;
    reg         execute_CsrPlugin_csr_772;
    wire        when_CsrPlugin_l1669_3;
    reg         execute_CsrPlugin_csr_833;
    wire        when_CsrPlugin_l1669_4;
    reg         execute_CsrPlugin_csr_834;
    wire        when_CsrPlugin_l1669_5;
    reg         execute_CsrPlugin_csr_835;
    wire [ 1:0] switch_CsrPlugin_l1031;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_1;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_2;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_3;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_4;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_5;
    wire        when_CsrPlugin_l1702;
    wire [11:0] _zz_when_CsrPlugin_l1709;
    wire        when_CsrPlugin_l1709;
    reg         when_CsrPlugin_l1719;
    wire        when_CsrPlugin_l1717;
    wire        when_CsrPlugin_l1725;
`ifndef SYNTHESIS
    reg [31:0] decode_BRANCH_CTRL_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_string;
    reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_string;
    reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_1_string;
    reg [71:0] decode_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_1_string;
    reg [39:0] decode_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string;
    reg [63:0] decode_ALU_CTRL_string;
    reg [63:0] _zz_decode_ALU_CTRL_string;
    reg [63:0] _zz_decode_to_execute_ALU_CTRL_string;
    reg [63:0] _zz_decode_to_execute_ALU_CTRL_1_string;
    reg [31:0] _zz_memory_to_writeBack_ENV_CTRL_string;
    reg [31:0] _zz_memory_to_writeBack_ENV_CTRL_1_string;
    reg [31:0] _zz_execute_to_memory_ENV_CTRL_string;
    reg [31:0] _zz_execute_to_memory_ENV_CTRL_1_string;
    reg [31:0] decode_ENV_CTRL_string;
    reg [31:0] _zz_decode_ENV_CTRL_string;
    reg [31:0] _zz_decode_to_execute_ENV_CTRL_string;
    reg [31:0] _zz_decode_to_execute_ENV_CTRL_1_string;
    reg [31:0] execute_BRANCH_CTRL_string;
    reg [31:0] _zz_execute_BRANCH_CTRL_string;
    reg [71:0] execute_SHIFT_CTRL_string;
    reg [71:0] _zz_execute_SHIFT_CTRL_string;
    reg [23:0] decode_SRC2_CTRL_string;
    reg [23:0] _zz_decode_SRC2_CTRL_string;
    reg [95:0] decode_SRC1_CTRL_string;
    reg [95:0] _zz_decode_SRC1_CTRL_string;
    reg [63:0] execute_ALU_CTRL_string;
    reg [63:0] _zz_execute_ALU_CTRL_string;
    reg [39:0] execute_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_execute_ALU_BITWISE_CTRL_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_1_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_1_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_1_string;
    reg [63:0] _zz_decode_ALU_CTRL_1_string;
    reg [31:0] _zz_decode_ENV_CTRL_1_string;
    reg [23:0] _zz_decode_SRC2_CTRL_1_string;
    reg [95:0] _zz_decode_SRC1_CTRL_1_string;
    reg [31:0] memory_ENV_CTRL_string;
    reg [31:0] _zz_memory_ENV_CTRL_string;
    reg [31:0] execute_ENV_CTRL_string;
    reg [31:0] _zz_execute_ENV_CTRL_string;
    reg [31:0] writeBack_ENV_CTRL_string;
    reg [31:0] _zz_writeBack_ENV_CTRL_string;
    reg [95:0] _zz_decode_SRC1_CTRL_2_string;
    reg [23:0] _zz_decode_SRC2_CTRL_2_string;
    reg [31:0] _zz_decode_ENV_CTRL_2_string;
    reg [63:0] _zz_decode_ALU_CTRL_2_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_2_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_2_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_2_string;
    reg [31:0] decode_to_execute_ENV_CTRL_string;
    reg [31:0] execute_to_memory_ENV_CTRL_string;
    reg [31:0] memory_to_writeBack_ENV_CTRL_string;
    reg [63:0] decode_to_execute_ALU_CTRL_string;
    reg [39:0] decode_to_execute_ALU_BITWISE_CTRL_string;
    reg [71:0] decode_to_execute_SHIFT_CTRL_string;
    reg [31:0] decode_to_execute_BRANCH_CTRL_string;
`endif

    reg [31:0] RegFilePlugin_regFile[0:31]  /* verilator public */;

    assign _zz_memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW_1) + $signed(_zz_memory_MUL_LOW_4));
    assign _zz_memory_MUL_LOW_1 = ($signed(52'h0) + $signed(_zz_memory_MUL_LOW_2));
    assign _zz_memory_MUL_LOW_3 = {1'b0, memory_MUL_LL};
    assign _zz_memory_MUL_LOW_2 = {{19{_zz_memory_MUL_LOW_3[32]}}, _zz_memory_MUL_LOW_3};
    assign _zz_memory_MUL_LOW_5 = ({16'd0, memory_MUL_LH} <<< 5'd16);
    assign _zz_memory_MUL_LOW_4 = {{2{_zz_memory_MUL_LOW_5[49]}}, _zz_memory_MUL_LOW_5};
    assign _zz_memory_MUL_LOW_7 = ({16'd0, memory_MUL_HL} <<< 5'd16);
    assign _zz_memory_MUL_LOW_6 = {{2{_zz_memory_MUL_LOW_7[49]}}, _zz_memory_MUL_LOW_7};
    assign _zz_IBusSimplePlugin_jump_pcLoad_payload_1 = (_zz_IBusSimplePlugin_jump_pcLoad_payload & (~ _zz_IBusSimplePlugin_jump_pcLoad_payload_2));
    assign _zz_IBusSimplePlugin_jump_pcLoad_payload_2 = (_zz_IBusSimplePlugin_jump_pcLoad_payload - 2'b01);
    assign _zz_IBusSimplePlugin_fetchPc_pc_1 = {IBusSimplePlugin_fetchPc_inc, 2'b00};
    assign _zz_IBusSimplePlugin_fetchPc_pc = {29'd0, _zz_IBusSimplePlugin_fetchPc_pc_1};
    assign _zz_IBusSimplePlugin_pending_next = (IBusSimplePlugin_pending_value + _zz_IBusSimplePlugin_pending_next_1);
    assign _zz_IBusSimplePlugin_pending_next_2 = IBusSimplePlugin_pending_inc;
    assign _zz_IBusSimplePlugin_pending_next_1 = {2'd0, _zz_IBusSimplePlugin_pending_next_2};
    assign _zz_IBusSimplePlugin_pending_next_4 = IBusSimplePlugin_pending_dec;
    assign _zz_IBusSimplePlugin_pending_next_3 = {2'd0, _zz_IBusSimplePlugin_pending_next_4};
    assign _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1 = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter != 3'b000));
    assign _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter = {
        2'd0, _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1
    };
    assign _zz__zz_execute_REGFILE_WRITE_DATA = execute_SRC_LESS;
    assign _zz__zz_decode_SRC1 = 3'b100;
    assign _zz__zz_decode_SRC1_1 = decode_INSTRUCTION[19 : 15];
    assign _zz__zz_decode_SRC2_2 = {decode_INSTRUCTION[31 : 25], decode_INSTRUCTION[11 : 7]};
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
    assign _zz__zz_decode_RS2_3 = (_zz__zz_decode_RS2_3_1 >>> 1'd1);
    assign _zz__zz_decode_RS2_3_1 = {
        ((execute_SHIFT_CTRL == ShiftCtrlEnum_SRA_1) && execute_LightShifterPlugin_shiftInput[31]),
        execute_LightShifterPlugin_shiftInput
    };
    assign _zz__zz_execute_BranchPlugin_branch_src2 = {
        {{execute_INSTRUCTION[31], execute_INSTRUCTION[19 : 12]}, execute_INSTRUCTION[20]},
        execute_INSTRUCTION[30 : 21]
    };
    assign _zz__zz_execute_BranchPlugin_branch_src2_4 = {
        {{execute_INSTRUCTION[31], execute_INSTRUCTION[7]}, execute_INSTRUCTION[30 : 25]},
        execute_INSTRUCTION[11 : 8]
    };
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
    assign _zz_decode_RegFilePlugin_rs1Data = 1'b1;
    assign _zz_decode_RegFilePlugin_rs2Data = 1'b1;
    assign _zz__zz_decode_IS_RS2_SIGNED = ((decode_INSTRUCTION & 32'h02004064) == 32'h02004020);
    assign _zz__zz_decode_IS_RS2_SIGNED_1 = ((decode_INSTRUCTION & 32'h02004074) == 32'h02000030);
    assign _zz__zz_decode_IS_RS2_SIGNED_2 = (|{_zz_decode_IS_RS2_SIGNED_5,(_zz__zz_decode_IS_RS2_SIGNED_3 == _zz__zz_decode_IS_RS2_SIGNED_4)});
    assign _zz__zz_decode_IS_RS2_SIGNED_5 = (|(_zz__zz_decode_IS_RS2_SIGNED_6 == _zz__zz_decode_IS_RS2_SIGNED_7));
    assign _zz__zz_decode_IS_RS2_SIGNED_8 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_9),
        {
            (|_zz__zz_decode_IS_RS2_SIGNED_10),
            {
                _zz__zz_decode_IS_RS2_SIGNED_15,
                {_zz__zz_decode_IS_RS2_SIGNED_18, _zz__zz_decode_IS_RS2_SIGNED_20}
            }
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_3 = (decode_INSTRUCTION & 32'h0000001c);
    assign _zz__zz_decode_IS_RS2_SIGNED_4 = 32'h00000004;
    assign _zz__zz_decode_IS_RS2_SIGNED_6 = (decode_INSTRUCTION & 32'h00000058);
    assign _zz__zz_decode_IS_RS2_SIGNED_7 = 32'h00000040;
    assign _zz__zz_decode_IS_RS2_SIGNED_9 = ((decode_INSTRUCTION & 32'h02007054) == 32'h00005010);
    assign _zz__zz_decode_IS_RS2_SIGNED_10 = {
        (_zz__zz_decode_IS_RS2_SIGNED_11 == _zz__zz_decode_IS_RS2_SIGNED_12),
        (_zz__zz_decode_IS_RS2_SIGNED_13 == _zz__zz_decode_IS_RS2_SIGNED_14)
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_15 = (|{_zz__zz_decode_IS_RS2_SIGNED_16,_zz__zz_decode_IS_RS2_SIGNED_17});
    assign _zz__zz_decode_IS_RS2_SIGNED_18 = (|_zz__zz_decode_IS_RS2_SIGNED_19);
    assign _zz__zz_decode_IS_RS2_SIGNED_20 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_21),
        {
            _zz__zz_decode_IS_RS2_SIGNED_23,
            {_zz__zz_decode_IS_RS2_SIGNED_26, _zz__zz_decode_IS_RS2_SIGNED_31}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_11 = (decode_INSTRUCTION & 32'h40003054);
    assign _zz__zz_decode_IS_RS2_SIGNED_12 = 32'h40001010;
    assign _zz__zz_decode_IS_RS2_SIGNED_13 = (decode_INSTRUCTION & 32'h02007054);
    assign _zz__zz_decode_IS_RS2_SIGNED_14 = 32'h00001010;
    assign _zz__zz_decode_IS_RS2_SIGNED_16 = ((decode_INSTRUCTION & 32'h00000064) == 32'h00000024);
    assign _zz__zz_decode_IS_RS2_SIGNED_17 = ((decode_INSTRUCTION & 32'h02003054) == 32'h00001010);
    assign _zz__zz_decode_IS_RS2_SIGNED_19 = ((decode_INSTRUCTION & 32'h00001000) == 32'h00001000);
    assign _zz__zz_decode_IS_RS2_SIGNED_21 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_22) == 32'h00002000);
    assign _zz__zz_decode_IS_RS2_SIGNED_23 = (|{_zz__zz_decode_IS_RS2_SIGNED_24,_zz__zz_decode_IS_RS2_SIGNED_25});
    assign _zz__zz_decode_IS_RS2_SIGNED_26 = (|{_zz__zz_decode_IS_RS2_SIGNED_27,_zz__zz_decode_IS_RS2_SIGNED_29});
    assign _zz__zz_decode_IS_RS2_SIGNED_31 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_32),
        {
            _zz__zz_decode_IS_RS2_SIGNED_33,
            {_zz__zz_decode_IS_RS2_SIGNED_36, _zz__zz_decode_IS_RS2_SIGNED_41}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_22 = 32'h00003000;
    assign _zz__zz_decode_IS_RS2_SIGNED_24 = ((decode_INSTRUCTION & 32'h00002010) == 32'h00002000);
    assign _zz__zz_decode_IS_RS2_SIGNED_25 = ((decode_INSTRUCTION & 32'h00005000) == 32'h00001000);
    assign _zz__zz_decode_IS_RS2_SIGNED_27 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_28) == 32'h00006000);
    assign _zz__zz_decode_IS_RS2_SIGNED_29 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_30) == 32'h00004000);
    assign _zz__zz_decode_IS_RS2_SIGNED_32 = _zz_decode_IS_RS2_SIGNED_2;
    assign _zz__zz_decode_IS_RS2_SIGNED_33 = (|(_zz__zz_decode_IS_RS2_SIGNED_34 == _zz__zz_decode_IS_RS2_SIGNED_35));
    assign _zz__zz_decode_IS_RS2_SIGNED_36 = (|{_zz__zz_decode_IS_RS2_SIGNED_37,_zz__zz_decode_IS_RS2_SIGNED_39});
    assign _zz__zz_decode_IS_RS2_SIGNED_41 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_42),
        {
            _zz__zz_decode_IS_RS2_SIGNED_47,
            {_zz__zz_decode_IS_RS2_SIGNED_52, _zz__zz_decode_IS_RS2_SIGNED_54}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_28 = 32'h00006004;
    assign _zz__zz_decode_IS_RS2_SIGNED_30 = 32'h00005004;
    assign _zz__zz_decode_IS_RS2_SIGNED_34 = (decode_INSTRUCTION & 32'h00103050);
    assign _zz__zz_decode_IS_RS2_SIGNED_35 = 32'h00000050;
    assign _zz__zz_decode_IS_RS2_SIGNED_37 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_38) == 32'h00001050);
    assign _zz__zz_decode_IS_RS2_SIGNED_39 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_40) == 32'h00002050);
    assign _zz__zz_decode_IS_RS2_SIGNED_42 = {
        (_zz__zz_decode_IS_RS2_SIGNED_43 == _zz__zz_decode_IS_RS2_SIGNED_44),
        (_zz__zz_decode_IS_RS2_SIGNED_45 == _zz__zz_decode_IS_RS2_SIGNED_46)
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_47 = (|{_zz__zz_decode_IS_RS2_SIGNED_48, {
        _zz__zz_decode_IS_RS2_SIGNED_49, _zz__zz_decode_IS_RS2_SIGNED_50
    }});
    assign _zz__zz_decode_IS_RS2_SIGNED_52 = (|_zz__zz_decode_IS_RS2_SIGNED_53);
    assign _zz__zz_decode_IS_RS2_SIGNED_54 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_55),
        {
            _zz__zz_decode_IS_RS2_SIGNED_63,
            {_zz__zz_decode_IS_RS2_SIGNED_67, _zz__zz_decode_IS_RS2_SIGNED_80}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_38 = 32'h00001050;
    assign _zz__zz_decode_IS_RS2_SIGNED_40 = 32'h00002050;
    assign _zz__zz_decode_IS_RS2_SIGNED_43 = (decode_INSTRUCTION & 32'h00000034);
    assign _zz__zz_decode_IS_RS2_SIGNED_44 = 32'h00000020;
    assign _zz__zz_decode_IS_RS2_SIGNED_45 = (decode_INSTRUCTION & 32'h00000064);
    assign _zz__zz_decode_IS_RS2_SIGNED_46 = 32'h00000020;
    assign _zz__zz_decode_IS_RS2_SIGNED_48 = ((decode_INSTRUCTION & 32'h00000050) == 32'h00000040);
    assign _zz__zz_decode_IS_RS2_SIGNED_49 = _zz_decode_IS_RS2_SIGNED_3;
    assign _zz__zz_decode_IS_RS2_SIGNED_50 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_51) == 32'h00000040);
    assign _zz__zz_decode_IS_RS2_SIGNED_53 = ((decode_INSTRUCTION & 32'h00000020) == 32'h00000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_55 = {
        (_zz__zz_decode_IS_RS2_SIGNED_56 == _zz__zz_decode_IS_RS2_SIGNED_57),
        {
            _zz_decode_IS_RS2_SIGNED_4,
            {_zz__zz_decode_IS_RS2_SIGNED_58, _zz__zz_decode_IS_RS2_SIGNED_60}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_63 = (|{_zz_decode_IS_RS2_SIGNED_4, {
        _zz__zz_decode_IS_RS2_SIGNED_64, _zz__zz_decode_IS_RS2_SIGNED_65
    }});
    assign _zz__zz_decode_IS_RS2_SIGNED_67 = (|{_zz__zz_decode_IS_RS2_SIGNED_68,_zz__zz_decode_IS_RS2_SIGNED_69});
    assign _zz__zz_decode_IS_RS2_SIGNED_80 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_81),
        {
            _zz__zz_decode_IS_RS2_SIGNED_84,
            {_zz__zz_decode_IS_RS2_SIGNED_87, _zz__zz_decode_IS_RS2_SIGNED_95}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_51 = 32'h00103040;
    assign _zz__zz_decode_IS_RS2_SIGNED_56 = (decode_INSTRUCTION & 32'h00000040);
    assign _zz__zz_decode_IS_RS2_SIGNED_57 = 32'h00000040;
    assign _zz__zz_decode_IS_RS2_SIGNED_58 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_59) == 32'h00004020);
    assign _zz__zz_decode_IS_RS2_SIGNED_60 = {
        _zz_decode_IS_RS2_SIGNED_6,
        (_zz__zz_decode_IS_RS2_SIGNED_61 == _zz__zz_decode_IS_RS2_SIGNED_62)
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_64 = _zz_decode_IS_RS2_SIGNED_6;
    assign _zz__zz_decode_IS_RS2_SIGNED_65 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_66) == 32'h00000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_68 = _zz_decode_IS_RS2_SIGNED_5;
    assign _zz__zz_decode_IS_RS2_SIGNED_69 = {
        (_zz__zz_decode_IS_RS2_SIGNED_70 == _zz__zz_decode_IS_RS2_SIGNED_71),
        {
            _zz__zz_decode_IS_RS2_SIGNED_72,
            {_zz__zz_decode_IS_RS2_SIGNED_74, _zz__zz_decode_IS_RS2_SIGNED_77}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_81 = {
        _zz_decode_IS_RS2_SIGNED_4,
        (_zz__zz_decode_IS_RS2_SIGNED_82 == _zz__zz_decode_IS_RS2_SIGNED_83)
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_84 = (|{_zz_decode_IS_RS2_SIGNED_4,_zz__zz_decode_IS_RS2_SIGNED_85});
    assign _zz__zz_decode_IS_RS2_SIGNED_87 = (|{_zz__zz_decode_IS_RS2_SIGNED_88,_zz__zz_decode_IS_RS2_SIGNED_91});
    assign _zz__zz_decode_IS_RS2_SIGNED_95 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_96),
        {
            _zz__zz_decode_IS_RS2_SIGNED_99,
            {_zz__zz_decode_IS_RS2_SIGNED_107, _zz__zz_decode_IS_RS2_SIGNED_111}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_59 = 32'h00004020;
    assign _zz__zz_decode_IS_RS2_SIGNED_61 = (decode_INSTRUCTION & 32'h02000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_62 = 32'h00000020;
    assign _zz__zz_decode_IS_RS2_SIGNED_66 = 32'h02000060;
    assign _zz__zz_decode_IS_RS2_SIGNED_70 = (decode_INSTRUCTION & 32'h00001010);
    assign _zz__zz_decode_IS_RS2_SIGNED_71 = 32'h00001010;
    assign _zz__zz_decode_IS_RS2_SIGNED_72 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_73) == 32'h00002010);
    assign _zz__zz_decode_IS_RS2_SIGNED_74 = (_zz__zz_decode_IS_RS2_SIGNED_75 == _zz__zz_decode_IS_RS2_SIGNED_76);
    assign _zz__zz_decode_IS_RS2_SIGNED_77 = {
        _zz__zz_decode_IS_RS2_SIGNED_78, _zz__zz_decode_IS_RS2_SIGNED_79
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_82 = (decode_INSTRUCTION & 32'h00000070);
    assign _zz__zz_decode_IS_RS2_SIGNED_83 = 32'h00000020;
    assign _zz__zz_decode_IS_RS2_SIGNED_85 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_86) == 32'h0);
    assign _zz__zz_decode_IS_RS2_SIGNED_88 = (_zz__zz_decode_IS_RS2_SIGNED_89 == _zz__zz_decode_IS_RS2_SIGNED_90);
    assign _zz__zz_decode_IS_RS2_SIGNED_91 = {
        _zz_decode_IS_RS2_SIGNED_3,
        {_zz__zz_decode_IS_RS2_SIGNED_92, _zz__zz_decode_IS_RS2_SIGNED_93}
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_96 = (_zz__zz_decode_IS_RS2_SIGNED_97 == _zz__zz_decode_IS_RS2_SIGNED_98);
    assign _zz__zz_decode_IS_RS2_SIGNED_99 = (|{_zz__zz_decode_IS_RS2_SIGNED_100,_zz__zz_decode_IS_RS2_SIGNED_102});
    assign _zz__zz_decode_IS_RS2_SIGNED_107 = (|_zz__zz_decode_IS_RS2_SIGNED_108);
    assign _zz__zz_decode_IS_RS2_SIGNED_111 = (|_zz__zz_decode_IS_RS2_SIGNED_112);
    assign _zz__zz_decode_IS_RS2_SIGNED_73 = 32'h00002010;
    assign _zz__zz_decode_IS_RS2_SIGNED_75 = (decode_INSTRUCTION & 32'h00000050);
    assign _zz__zz_decode_IS_RS2_SIGNED_76 = 32'h00000010;
    assign _zz__zz_decode_IS_RS2_SIGNED_78 = ((decode_INSTRUCTION & 32'h0000000c) == 32'h00000004);
    assign _zz__zz_decode_IS_RS2_SIGNED_79 = ((decode_INSTRUCTION & 32'h00000028) == 32'h0);
    assign _zz__zz_decode_IS_RS2_SIGNED_86 = 32'h00000020;
    assign _zz__zz_decode_IS_RS2_SIGNED_89 = (decode_INSTRUCTION & 32'h00000044);
    assign _zz__zz_decode_IS_RS2_SIGNED_90 = 32'h0;
    assign _zz__zz_decode_IS_RS2_SIGNED_92 = _zz_decode_IS_RS2_SIGNED_2;
    assign _zz__zz_decode_IS_RS2_SIGNED_93 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_94) == 32'h00001000);
    assign _zz__zz_decode_IS_RS2_SIGNED_97 = (decode_INSTRUCTION & 32'h00000058);
    assign _zz__zz_decode_IS_RS2_SIGNED_98 = 32'h0;
    assign _zz__zz_decode_IS_RS2_SIGNED_100 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_101) == 32'h00000040);
    assign _zz__zz_decode_IS_RS2_SIGNED_102 = {
        (_zz__zz_decode_IS_RS2_SIGNED_103 == _zz__zz_decode_IS_RS2_SIGNED_104),
        (_zz__zz_decode_IS_RS2_SIGNED_105 == _zz__zz_decode_IS_RS2_SIGNED_106)
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_108 = {
        (_zz__zz_decode_IS_RS2_SIGNED_109 == _zz__zz_decode_IS_RS2_SIGNED_110),
        _zz_decode_IS_RS2_SIGNED_1
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_112 = {
        (_zz__zz_decode_IS_RS2_SIGNED_113 == _zz__zz_decode_IS_RS2_SIGNED_114),
        _zz_decode_IS_RS2_SIGNED_1
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_94 = 32'h00005004;
    assign _zz__zz_decode_IS_RS2_SIGNED_101 = 32'h00000044;
    assign _zz__zz_decode_IS_RS2_SIGNED_103 = (decode_INSTRUCTION & 32'h00002014);
    assign _zz__zz_decode_IS_RS2_SIGNED_104 = 32'h00002010;
    assign _zz__zz_decode_IS_RS2_SIGNED_105 = (decode_INSTRUCTION & 32'h40004034);
    assign _zz__zz_decode_IS_RS2_SIGNED_106 = 32'h40000030;
    assign _zz__zz_decode_IS_RS2_SIGNED_109 = (decode_INSTRUCTION & 32'h00000014);
    assign _zz__zz_decode_IS_RS2_SIGNED_110 = 32'h00000004;
    assign _zz__zz_decode_IS_RS2_SIGNED_113 = (decode_INSTRUCTION & 32'h00000044);
    assign _zz__zz_decode_IS_RS2_SIGNED_114 = 32'h00000004;
    always @(posedge io_mainClk) begin
        if (_zz_decode_RegFilePlugin_rs1Data) begin
            RegFilePlugin_regFile_spinal_port0 <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress1];
        end
    end

    always @(posedge io_mainClk) begin
        if (_zz_decode_RegFilePlugin_rs2Data) begin
            RegFilePlugin_regFile_spinal_port1 <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress2];
        end
    end

    always @(posedge io_mainClk) begin
        if (_zz_1) begin
            RegFilePlugin_regFile[lastStageRegFileWrite_payload_address] <= lastStageRegFileWrite_payload_data;
        end
    end

    StreamFifoLowLatency IBusSimplePlugin_rspJoin_rspBuffer_c (
        .io_push_valid        (iBus_rsp_toStream_valid),                                         //i
        .io_push_ready        (IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready),              //o
        .io_push_payload_error(iBus_rsp_toStream_payload_error),                                 //i
        .io_push_payload_inst (iBus_rsp_toStream_payload_inst[31:0]),                            //i
        .io_pop_valid         (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid),               //o
        .io_pop_ready         (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready),               //i
        .io_pop_payload_error (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error),       //o
        .io_pop_payload_inst  (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst[31:0]),  //o
        .io_flush             (1'b0),                                                            //i
        .io_occupancy         (IBusSimplePlugin_rspJoin_rspBuffer_c_io_occupancy),               //o
        .io_availability      (IBusSimplePlugin_rspJoin_rspBuffer_c_io_availability),            //o
        .io_mainClk           (io_mainClk),                                                      //i
        .resetCtrl_systemReset(resetCtrl_systemReset)                                            //i
    );
`ifndef SYNTHESIS
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
        case (_zz_decode_BRANCH_CTRL)
            BranchCtrlEnum_INC: _zz_decode_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_BRANCH_CTRL_string = "JALR";
            default: _zz_decode_BRANCH_CTRL_string = "????";
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
        case (_zz_decode_BRANCH_CTRL_1)
            BranchCtrlEnum_INC: _zz_decode_BRANCH_CTRL_1_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_BRANCH_CTRL_1_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_BRANCH_CTRL_1_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_BRANCH_CTRL_1_string = "JALR";
            default: _zz_decode_BRANCH_CTRL_1_string = "????";
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
        case (_zz_decode_ALU_CTRL_1)
            AluCtrlEnum_ADD_SUB: _zz_decode_ALU_CTRL_1_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_ALU_CTRL_1_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_ALU_CTRL_1_string = "BITWISE ";
            default: _zz_decode_ALU_CTRL_1_string = "????????";
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
        case (_zz_decode_SRC2_CTRL_1)
            Src2CtrlEnum_RS: _zz_decode_SRC2_CTRL_1_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_SRC2_CTRL_1_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_SRC2_CTRL_1_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_SRC2_CTRL_1_string = "PC ";
            default: _zz_decode_SRC2_CTRL_1_string = "???";
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
        case (_zz_decode_SRC1_CTRL_2)
            Src1CtrlEnum_RS: _zz_decode_SRC1_CTRL_2_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_SRC1_CTRL_2_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_SRC1_CTRL_2_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_SRC1_CTRL_2_string = "URS1        ";
            default: _zz_decode_SRC1_CTRL_2_string = "????????????";
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
        case (_zz_decode_ENV_CTRL_2)
            EnvCtrlEnum_NONE: _zz_decode_ENV_CTRL_2_string = "NONE";
            EnvCtrlEnum_XRET: _zz_decode_ENV_CTRL_2_string = "XRET";
            default: _zz_decode_ENV_CTRL_2_string = "????";
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
    always @(*) begin
        case (decode_to_execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: decode_to_execute_ALU_CTRL_string = "BITWISE ";
            default: decode_to_execute_ALU_CTRL_string = "????????";
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
        case (decode_to_execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: decode_to_execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: decode_to_execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: decode_to_execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: decode_to_execute_BRANCH_CTRL_string = "JALR";
            default: decode_to_execute_BRANCH_CTRL_string = "????";
        endcase
    end
`endif

    assign memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW) + $signed(_zz_memory_MUL_LOW_6));
    assign memory_MEMORY_READ_DATA = dBus_rsp_data;
    assign memory_MUL_HH = execute_to_memory_MUL_HH;
    assign execute_MUL_HH = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bHigh));
    assign execute_MUL_HL = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bSLow));
    assign execute_MUL_LH = ($signed(execute_MulPlugin_aSLow) * $signed(execute_MulPlugin_bHigh));
    assign execute_MUL_LL = (execute_MulPlugin_aULow * execute_MulPlugin_bULow);
    assign execute_BRANCH_CALC = {execute_BranchPlugin_branchAdder[31 : 1], 1'b0};
    assign execute_BRANCH_DO = _zz_execute_BRANCH_DO_1;
    assign writeBack_REGFILE_WRITE_DATA = memory_to_writeBack_REGFILE_WRITE_DATA;
    assign execute_REGFILE_WRITE_DATA = _zz_execute_REGFILE_WRITE_DATA;
    assign memory_MEMORY_ADDRESS_LOW = execute_to_memory_MEMORY_ADDRESS_LOW;
    assign execute_MEMORY_ADDRESS_LOW = dBus_cmd_payload_address[1 : 0];
    assign decode_DO_EBREAK = (((! DebugPlugin_haltIt) && (decode_IS_EBREAK || 1'b0)) && DebugPlugin_allowEBreak);
    assign decode_SRC2 = _zz_decode_SRC2_4;
    assign decode_SRC1 = _zz_decode_SRC1;
    assign decode_SRC2_FORCE_ZERO = (decode_SRC_ADD_ZERO && (!decode_SRC_USE_SUB_LESS));
    assign decode_IS_RS2_SIGNED = _zz_decode_IS_RS2_SIGNED[28];
    assign decode_IS_RS1_SIGNED = _zz_decode_IS_RS2_SIGNED[27];
    assign decode_IS_DIV = _zz_decode_IS_RS2_SIGNED[26];
    assign memory_IS_MUL = execute_to_memory_IS_MUL;
    assign execute_IS_MUL = decode_to_execute_IS_MUL;
    assign decode_IS_MUL = _zz_decode_IS_RS2_SIGNED[25];
    assign decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL;
    assign _zz_decode_to_execute_BRANCH_CTRL = _zz_decode_to_execute_BRANCH_CTRL_1;
    assign decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL;
    assign _zz_decode_to_execute_SHIFT_CTRL = _zz_decode_to_execute_SHIFT_CTRL_1;
    assign decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL;
    assign _zz_decode_to_execute_ALU_BITWISE_CTRL = _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
    assign decode_SRC_LESS_UNSIGNED = _zz_decode_IS_RS2_SIGNED[17];
    assign decode_ALU_CTRL = _zz_decode_ALU_CTRL;
    assign _zz_decode_to_execute_ALU_CTRL = _zz_decode_to_execute_ALU_CTRL_1;
    assign _zz_memory_to_writeBack_ENV_CTRL = _zz_memory_to_writeBack_ENV_CTRL_1;
    assign _zz_execute_to_memory_ENV_CTRL = _zz_execute_to_memory_ENV_CTRL_1;
    assign decode_ENV_CTRL = _zz_decode_ENV_CTRL;
    assign _zz_decode_to_execute_ENV_CTRL = _zz_decode_to_execute_ENV_CTRL_1;
    assign decode_IS_CSR = _zz_decode_IS_RS2_SIGNED[13];
    assign decode_MEMORY_STORE = _zz_decode_IS_RS2_SIGNED[10];
    assign execute_BYPASSABLE_MEMORY_STAGE = decode_to_execute_BYPASSABLE_MEMORY_STAGE;
    assign decode_BYPASSABLE_MEMORY_STAGE = _zz_decode_IS_RS2_SIGNED[9];
    assign decode_BYPASSABLE_EXECUTE_STAGE = _zz_decode_IS_RS2_SIGNED[8];
    assign decode_MEMORY_ENABLE = _zz_decode_IS_RS2_SIGNED[3];
    assign decode_CSR_READ_OPCODE = (decode_INSTRUCTION[13 : 7] != 7'h20);
    assign decode_CSR_WRITE_OPCODE = (! (((decode_INSTRUCTION[14 : 13] == 2'b01) && (decode_INSTRUCTION[19 : 15] == 5'h0)) || ((decode_INSTRUCTION[14 : 13] == 2'b11) && (decode_INSTRUCTION[19 : 15] == 5'h0))));
    assign writeBack_FORMAL_PC_NEXT = memory_to_writeBack_FORMAL_PC_NEXT;
    assign memory_FORMAL_PC_NEXT = execute_to_memory_FORMAL_PC_NEXT;
    assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
    assign decode_FORMAL_PC_NEXT = (decode_PC + 32'h00000004);
    assign memory_PC = execute_to_memory_PC;
    assign execute_DO_EBREAK = decode_to_execute_DO_EBREAK;
    assign decode_IS_EBREAK = _zz_decode_IS_RS2_SIGNED[29];
    assign execute_IS_RS1_SIGNED = decode_to_execute_IS_RS1_SIGNED;
    assign execute_IS_DIV = decode_to_execute_IS_DIV;
    assign execute_IS_RS2_SIGNED = decode_to_execute_IS_RS2_SIGNED;
    assign memory_IS_DIV = execute_to_memory_IS_DIV;
    assign writeBack_IS_MUL = memory_to_writeBack_IS_MUL;
    assign writeBack_MUL_HH = memory_to_writeBack_MUL_HH;
    assign writeBack_MUL_LOW = memory_to_writeBack_MUL_LOW;
    assign memory_MUL_HL = execute_to_memory_MUL_HL;
    assign memory_MUL_LH = execute_to_memory_MUL_LH;
    assign memory_MUL_LL = execute_to_memory_MUL_LL;
    assign memory_BRANCH_CALC = execute_to_memory_BRANCH_CALC;
    assign memory_BRANCH_DO = execute_to_memory_BRANCH_DO;
    assign execute_PC = decode_to_execute_PC;
    assign execute_RS1 = decode_to_execute_RS1;
    assign execute_BRANCH_CTRL = _zz_execute_BRANCH_CTRL;
    assign decode_RS2_USE = _zz_decode_IS_RS2_SIGNED[12];
    assign decode_RS1_USE = _zz_decode_IS_RS2_SIGNED[4];
    assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
    assign execute_BYPASSABLE_EXECUTE_STAGE = decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
    always @(*) begin
        _zz_decode_RS2 = memory_REGFILE_WRITE_DATA;
        if (when_MulDivIterativePlugin_l128) begin
            _zz_decode_RS2 = memory_DivPlugin_div_result;
        end
    end

    assign memory_REGFILE_WRITE_VALID = execute_to_memory_REGFILE_WRITE_VALID;
    assign memory_INSTRUCTION = execute_to_memory_INSTRUCTION;
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
                    decode_RS2 = _zz_decode_RS2;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_2) begin
            if (execute_BYPASSABLE_EXECUTE_STAGE) begin
                if (when_HazardSimplePlugin_l51_2) begin
                    decode_RS2 = _zz_decode_RS2_1;
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
                    decode_RS1 = _zz_decode_RS2;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_2) begin
            if (execute_BYPASSABLE_EXECUTE_STAGE) begin
                if (when_HazardSimplePlugin_l48_2) begin
                    decode_RS1 = _zz_decode_RS2_1;
                end
            end
        end
    end

    assign memory_REGFILE_WRITE_DATA = execute_to_memory_REGFILE_WRITE_DATA;
    assign execute_SHIFT_CTRL = _zz_execute_SHIFT_CTRL;
    assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
    assign execute_SRC2_FORCE_ZERO = decode_to_execute_SRC2_FORCE_ZERO;
    assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
    assign _zz_decode_to_execute_PC = decode_PC;
    assign _zz_decode_to_execute_RS2 = decode_RS2;
    assign decode_SRC2_CTRL = _zz_decode_SRC2_CTRL;
    assign _zz_decode_to_execute_RS1 = decode_RS1;
    assign decode_SRC1_CTRL = _zz_decode_SRC1_CTRL;
    assign decode_SRC_USE_SUB_LESS = _zz_decode_IS_RS2_SIGNED[2];
    assign decode_SRC_ADD_ZERO = _zz_decode_IS_RS2_SIGNED[20];
    assign execute_SRC_ADD_SUB = execute_SrcPlugin_addSub;
    assign execute_SRC_LESS = execute_SrcPlugin_less;
    assign execute_ALU_CTRL = _zz_execute_ALU_CTRL;
    assign execute_SRC2 = decode_to_execute_SRC2;
    assign execute_ALU_BITWISE_CTRL = _zz_execute_ALU_BITWISE_CTRL;
    assign _zz_lastStageRegFileWrite_payload_address = writeBack_INSTRUCTION;
    assign _zz_lastStageRegFileWrite_valid = writeBack_REGFILE_WRITE_VALID;
    always @(*) begin
        _zz_1 = 1'b0;
        if (lastStageRegFileWrite_valid) begin
            _zz_1 = 1'b1;
        end
    end

    assign decode_INSTRUCTION_ANTICIPATED = (decode_arbitration_isStuck ? decode_INSTRUCTION : IBusSimplePlugin_iBusRsp_output_payload_rsp_inst);
    always @(*) begin
        decode_REGFILE_WRITE_VALID = _zz_decode_IS_RS2_SIGNED[7];
        if (when_RegFilePlugin_l63) begin
            decode_REGFILE_WRITE_VALID = 1'b0;
        end
    end

    always @(*) begin
        _zz_decode_RS2_1 = execute_REGFILE_WRITE_DATA;
        if (when_CsrPlugin_l1587) begin
            _zz_decode_RS2_1 = CsrPlugin_csrMapping_readDataSignal;
        end
        if (when_ShiftPlugins_l169) begin
            _zz_decode_RS2_1 = _zz_decode_RS2_3;
        end
    end

    assign execute_SRC1 = decode_to_execute_SRC1;
    assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
    assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
    assign execute_IS_CSR = decode_to_execute_IS_CSR;
    assign memory_ENV_CTRL = _zz_memory_ENV_CTRL;
    assign execute_ENV_CTRL = _zz_execute_ENV_CTRL;
    assign writeBack_ENV_CTRL = _zz_writeBack_ENV_CTRL;
    always @(*) begin
        _zz_decode_RS2_2 = writeBack_REGFILE_WRITE_DATA;
        if (when_DBusSimplePlugin_l565) begin
            _zz_decode_RS2_2 = writeBack_DBusSimplePlugin_rspFormated;
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

    assign writeBack_MEMORY_ENABLE = memory_to_writeBack_MEMORY_ENABLE;
    assign writeBack_MEMORY_ADDRESS_LOW = memory_to_writeBack_MEMORY_ADDRESS_LOW;
    assign writeBack_MEMORY_READ_DATA = memory_to_writeBack_MEMORY_READ_DATA;
    assign memory_MEMORY_STORE = execute_to_memory_MEMORY_STORE;
    assign memory_MEMORY_ENABLE = execute_to_memory_MEMORY_ENABLE;
    assign execute_SRC_ADD = execute_SrcPlugin_addSub;
    assign execute_RS2 = decode_to_execute_RS2;
    assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
    assign execute_MEMORY_STORE = decode_to_execute_MEMORY_STORE;
    assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
    assign execute_ALIGNEMENT_FAULT = 1'b0;
    always @(*) begin
        _zz_memory_to_writeBack_FORMAL_PC_NEXT = memory_FORMAL_PC_NEXT;
        if (BranchPlugin_jumpInterface_valid) begin
            _zz_memory_to_writeBack_FORMAL_PC_NEXT = BranchPlugin_jumpInterface_payload;
        end
    end

    assign decode_PC = IBusSimplePlugin_injector_decodeInput_payload_pc;
    assign decode_INSTRUCTION = IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
    assign writeBack_PC = memory_to_writeBack_PC;
    assign writeBack_INSTRUCTION = memory_to_writeBack_INSTRUCTION;
    always @(*) begin
        decode_arbitration_haltItself = 1'b0;
        case (IBusSimplePlugin_injector_port_state)
            3'b010: begin
                decode_arbitration_haltItself = 1'b1;
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        decode_arbitration_haltByOther = 1'b0;
        if (CsrPlugin_pipelineLiberator_active) begin
            decode_arbitration_haltByOther = 1'b1;
        end
        if (when_CsrPlugin_l1527) begin
            decode_arbitration_haltByOther = 1'b1;
        end
        if (when_HazardSimplePlugin_l113) begin
            decode_arbitration_haltByOther = 1'b1;
        end
    end

    always @(*) begin
        decode_arbitration_removeIt = 1'b0;
        if (decode_arbitration_isFlushed) begin
            decode_arbitration_removeIt = 1'b1;
        end
    end

    assign decode_arbitration_flushIt   = 1'b0;
    assign decode_arbitration_flushNext = 1'b0;
    always @(*) begin
        execute_arbitration_haltItself = 1'b0;
        if (when_DBusSimplePlugin_l434) begin
            execute_arbitration_haltItself = 1'b1;
        end
        if (when_CsrPlugin_l1591) begin
            if (execute_CsrPlugin_blockedBySideEffects) begin
                execute_arbitration_haltItself = 1'b1;
            end
        end
        if (when_ShiftPlugins_l169) begin
            if (when_ShiftPlugins_l184) begin
                execute_arbitration_haltItself = 1'b1;
            end
        end
    end

    always @(*) begin
        execute_arbitration_haltByOther = 1'b0;
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
        if (when_DBusSimplePlugin_l489) begin
            memory_arbitration_haltItself = 1'b1;
        end
        if (when_MulDivIterativePlugin_l128) begin
            if (when_MulDivIterativePlugin_l129) begin
                memory_arbitration_haltItself = 1'b1;
            end
        end
    end

    assign memory_arbitration_haltByOther = 1'b0;
    always @(*) begin
        memory_arbitration_removeIt = 1'b0;
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
    end

    assign writeBack_arbitration_haltItself  = 1'b0;
    assign writeBack_arbitration_haltByOther = 1'b0;
    always @(*) begin
        writeBack_arbitration_removeIt = 1'b0;
        if (writeBack_arbitration_isFlushed) begin
            writeBack_arbitration_removeIt = 1'b1;
        end
    end

    assign writeBack_arbitration_flushIt = 1'b0;
    always @(*) begin
        writeBack_arbitration_flushNext = 1'b0;
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
        IBusSimplePlugin_fetcherHalt = 1'b0;
        if (when_CsrPlugin_l1390) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
        if (when_CsrPlugin_l1456) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
        if (when_DebugPlugin_l308) begin
            if (when_DebugPlugin_l311) begin
                IBusSimplePlugin_fetcherHalt = 1'b1;
            end
        end
        if (DebugPlugin_haltIt) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
        if (when_DebugPlugin_l324) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
    end

    assign IBusSimplePlugin_forceNoDecodeCond = 1'b0;
    always @(*) begin
        IBusSimplePlugin_incomingInstruction = 1'b0;
        if (when_Fetcher_l242) begin
            IBusSimplePlugin_incomingInstruction = 1'b1;
        end
        if (IBusSimplePlugin_injector_decodeInput_valid) begin
            IBusSimplePlugin_incomingInstruction = 1'b1;
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
    always @(*) begin
        BranchPlugin_inDebugNoFetchFlag = 1'b0;
        if (DebugPlugin_godmode) begin
            BranchPlugin_inDebugNoFetchFlag = 1'b1;
        end
    end

    assign IBusSimplePlugin_externalFlush = (|{writeBack_arbitration_flushNext, {
        memory_arbitration_flushNext, {execute_arbitration_flushNext, decode_arbitration_flushNext}
    }});
    assign IBusSimplePlugin_jump_pcLoad_valid = (|{BranchPlugin_jumpInterface_valid,CsrPlugin_jumpInterface_valid});
    assign _zz_IBusSimplePlugin_jump_pcLoad_payload = {
        BranchPlugin_jumpInterface_valid, CsrPlugin_jumpInterface_valid
    };
    assign IBusSimplePlugin_jump_pcLoad_payload = (_zz_IBusSimplePlugin_jump_pcLoad_payload_1[0] ? CsrPlugin_jumpInterface_payload : BranchPlugin_jumpInterface_payload);
    always @(*) begin
        IBusSimplePlugin_fetchPc_correction = 1'b0;
        if (IBusSimplePlugin_jump_pcLoad_valid) begin
            IBusSimplePlugin_fetchPc_correction = 1'b1;
        end
    end

    assign IBusSimplePlugin_fetchPc_output_fire = (IBusSimplePlugin_fetchPc_output_valid && IBusSimplePlugin_fetchPc_output_ready);
    assign IBusSimplePlugin_fetchPc_corrected = (IBusSimplePlugin_fetchPc_correction || IBusSimplePlugin_fetchPc_correctionReg);
    always @(*) begin
        IBusSimplePlugin_fetchPc_pcRegPropagate = 1'b0;
        if (IBusSimplePlugin_iBusRsp_stages_1_input_ready) begin
            IBusSimplePlugin_fetchPc_pcRegPropagate = 1'b1;
        end
    end

    assign when_Fetcher_l133 = (IBusSimplePlugin_fetchPc_correction || IBusSimplePlugin_fetchPc_pcRegPropagate);
    assign when_Fetcher_l133_1 = ((! IBusSimplePlugin_fetchPc_output_valid) && IBusSimplePlugin_fetchPc_output_ready);
    always @(*) begin
        IBusSimplePlugin_fetchPc_pc = (IBusSimplePlugin_fetchPc_pcReg + _zz_IBusSimplePlugin_fetchPc_pc);
        if (IBusSimplePlugin_jump_pcLoad_valid) begin
            IBusSimplePlugin_fetchPc_pc = IBusSimplePlugin_jump_pcLoad_payload;
        end
        IBusSimplePlugin_fetchPc_pc[0] = 1'b0;
        IBusSimplePlugin_fetchPc_pc[1] = 1'b0;
    end

    always @(*) begin
        IBusSimplePlugin_fetchPc_flushed = 1'b0;
        if (IBusSimplePlugin_jump_pcLoad_valid) begin
            IBusSimplePlugin_fetchPc_flushed = 1'b1;
        end
    end

    assign when_Fetcher_l160 = (IBusSimplePlugin_fetchPc_booted && ((IBusSimplePlugin_fetchPc_output_ready || IBusSimplePlugin_fetchPc_correction) || IBusSimplePlugin_fetchPc_pcRegPropagate));
    assign IBusSimplePlugin_fetchPc_output_valid = ((! IBusSimplePlugin_fetcherHalt) && IBusSimplePlugin_fetchPc_booted);
    assign IBusSimplePlugin_fetchPc_output_payload = IBusSimplePlugin_fetchPc_pc;
    assign IBusSimplePlugin_iBusRsp_redoFetch = 1'b0;
    assign IBusSimplePlugin_iBusRsp_stages_0_input_valid = IBusSimplePlugin_fetchPc_output_valid;
    assign IBusSimplePlugin_fetchPc_output_ready = IBusSimplePlugin_iBusRsp_stages_0_input_ready;
    assign IBusSimplePlugin_iBusRsp_stages_0_input_payload = IBusSimplePlugin_fetchPc_output_payload;
    assign IBusSimplePlugin_iBusRsp_stages_0_halt = 1'b0;
    assign _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready = (! IBusSimplePlugin_iBusRsp_stages_0_halt);
    assign IBusSimplePlugin_iBusRsp_stages_0_input_ready = (IBusSimplePlugin_iBusRsp_stages_0_output_ready && _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_0_output_valid = (IBusSimplePlugin_iBusRsp_stages_0_input_valid && _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_0_output_payload = IBusSimplePlugin_iBusRsp_stages_0_input_payload;
    always @(*) begin
        IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b0;
        if (when_IBusSimplePlugin_l305) begin
            IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b1;
        end
    end

    assign _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready = (! IBusSimplePlugin_iBusRsp_stages_1_halt);
    assign IBusSimplePlugin_iBusRsp_stages_1_input_ready = (IBusSimplePlugin_iBusRsp_stages_1_output_ready && _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_1_output_valid = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_1_output_payload = IBusSimplePlugin_iBusRsp_stages_1_input_payload;
    assign IBusSimplePlugin_iBusRsp_stages_2_halt = 1'b0;
    assign _zz_IBusSimplePlugin_iBusRsp_stages_2_input_ready = (! IBusSimplePlugin_iBusRsp_stages_2_halt);
    assign IBusSimplePlugin_iBusRsp_stages_2_input_ready = (IBusSimplePlugin_iBusRsp_stages_2_output_ready && _zz_IBusSimplePlugin_iBusRsp_stages_2_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_2_output_valid = (IBusSimplePlugin_iBusRsp_stages_2_input_valid && _zz_IBusSimplePlugin_iBusRsp_stages_2_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_2_output_payload = IBusSimplePlugin_iBusRsp_stages_2_input_payload;
    assign IBusSimplePlugin_iBusRsp_flush = (IBusSimplePlugin_externalFlush || IBusSimplePlugin_iBusRsp_redoFetch);
    assign IBusSimplePlugin_iBusRsp_stages_0_output_ready = _zz_IBusSimplePlugin_iBusRsp_stages_0_output_ready;
    assign _zz_IBusSimplePlugin_iBusRsp_stages_0_output_ready = ((1'b0 && (! _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid)) || IBusSimplePlugin_iBusRsp_stages_1_input_ready);
    assign _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid = _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1;
    assign IBusSimplePlugin_iBusRsp_stages_1_input_valid = _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid;
    assign IBusSimplePlugin_iBusRsp_stages_1_input_payload = IBusSimplePlugin_fetchPc_pcReg;
    assign IBusSimplePlugin_iBusRsp_stages_1_output_ready = ((1'b0 && (! IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid)) || IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_ready);
    assign IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid = _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    assign IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload = _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    assign IBusSimplePlugin_iBusRsp_stages_2_input_valid = IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    assign IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_ready = IBusSimplePlugin_iBusRsp_stages_2_input_ready;
    assign IBusSimplePlugin_iBusRsp_stages_2_input_payload = IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    always @(*) begin
        IBusSimplePlugin_iBusRsp_readyForError = 1'b1;
        if (IBusSimplePlugin_injector_decodeInput_valid) begin
            IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
        end
        if (when_Fetcher_l322) begin
            IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
        end
    end

    assign when_Fetcher_l242 = (IBusSimplePlugin_iBusRsp_stages_1_input_valid || IBusSimplePlugin_iBusRsp_stages_2_input_valid);
    assign IBusSimplePlugin_iBusRsp_output_ready = ((1'b0 && (! IBusSimplePlugin_injector_decodeInput_valid)) || IBusSimplePlugin_injector_decodeInput_ready);
    assign IBusSimplePlugin_injector_decodeInput_valid = _zz_IBusSimplePlugin_injector_decodeInput_valid;
    assign IBusSimplePlugin_injector_decodeInput_payload_pc = _zz_IBusSimplePlugin_injector_decodeInput_payload_pc;
    assign IBusSimplePlugin_injector_decodeInput_payload_rsp_error = _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
    assign IBusSimplePlugin_injector_decodeInput_payload_rsp_inst = _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
    assign IBusSimplePlugin_injector_decodeInput_payload_isRvc = _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc;
    assign when_Fetcher_l322 = (!IBusSimplePlugin_pcValids_0);
    assign when_Fetcher_l331 = (!(!IBusSimplePlugin_iBusRsp_stages_1_input_ready));
    assign when_Fetcher_l331_1 = (!(!IBusSimplePlugin_iBusRsp_stages_2_input_ready));
    assign when_Fetcher_l331_2 = (!(!IBusSimplePlugin_injector_decodeInput_ready));
    assign when_Fetcher_l331_3 = (!execute_arbitration_isStuck);
    assign when_Fetcher_l331_4 = (!memory_arbitration_isStuck);
    assign when_Fetcher_l331_5 = (!writeBack_arbitration_isStuck);
    assign IBusSimplePlugin_pcValids_0 = IBusSimplePlugin_injector_nextPcCalc_valids_2;
    assign IBusSimplePlugin_pcValids_1 = IBusSimplePlugin_injector_nextPcCalc_valids_3;
    assign IBusSimplePlugin_pcValids_2 = IBusSimplePlugin_injector_nextPcCalc_valids_4;
    assign IBusSimplePlugin_pcValids_3 = IBusSimplePlugin_injector_nextPcCalc_valids_5;
    assign IBusSimplePlugin_injector_decodeInput_ready = (!decode_arbitration_isStuck);
    always @(*) begin
        decode_arbitration_isValid = IBusSimplePlugin_injector_decodeInput_valid;
        case (IBusSimplePlugin_injector_port_state)
            3'b010: begin
                decode_arbitration_isValid = 1'b1;
            end
            3'b011: begin
                decode_arbitration_isValid = 1'b1;
            end
            default: begin
            end
        endcase
        if (IBusSimplePlugin_forceNoDecodeCond) begin
            decode_arbitration_isValid = 1'b0;
        end
    end

    assign iBus_cmd_valid = IBusSimplePlugin_cmd_valid;
    assign IBusSimplePlugin_cmd_ready = iBus_cmd_ready;
    assign iBus_cmd_payload_pc = IBusSimplePlugin_cmd_payload_pc;
    assign IBusSimplePlugin_pending_next = (_zz_IBusSimplePlugin_pending_next - _zz_IBusSimplePlugin_pending_next_3);
    assign IBusSimplePlugin_cmdFork_canEmit = (IBusSimplePlugin_iBusRsp_stages_1_output_ready && (IBusSimplePlugin_pending_value != 3'b111));
    assign when_IBusSimplePlugin_l305 = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && ((! IBusSimplePlugin_cmdFork_canEmit) || (! IBusSimplePlugin_cmd_ready)));
    assign IBusSimplePlugin_cmd_valid = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && IBusSimplePlugin_cmdFork_canEmit);
    assign IBusSimplePlugin_cmd_fire = (IBusSimplePlugin_cmd_valid && IBusSimplePlugin_cmd_ready);
    assign IBusSimplePlugin_pending_inc = IBusSimplePlugin_cmd_fire;
    assign IBusSimplePlugin_cmd_payload_pc = {
        IBusSimplePlugin_iBusRsp_stages_1_input_payload[31 : 2], 2'b00
    };
    assign iBus_rsp_toStream_valid = iBus_rsp_valid;
    assign iBus_rsp_toStream_payload_error = iBus_rsp_payload_error;
    assign iBus_rsp_toStream_payload_inst = iBus_rsp_payload_inst;
    assign iBus_rsp_toStream_ready = IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready;
    assign IBusSimplePlugin_rspJoin_rspBuffer_flush = ((IBusSimplePlugin_rspJoin_rspBuffer_discardCounter != 3'b000) || IBusSimplePlugin_iBusRsp_flush);
    assign IBusSimplePlugin_rspJoin_rspBuffer_output_valid = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter == 3'b000));
    assign IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error;
    assign IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst;
    assign IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready = (IBusSimplePlugin_rspJoin_rspBuffer_output_ready || IBusSimplePlugin_rspJoin_rspBuffer_flush);
    assign system_cpu_IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready);
    assign IBusSimplePlugin_pending_dec = system_cpu_IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire;
    assign IBusSimplePlugin_rspJoin_fetchRsp_pc = IBusSimplePlugin_iBusRsp_stages_2_output_payload;
    always @(*) begin
        IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error;
        if (when_IBusSimplePlugin_l376) begin
            IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = 1'b0;
        end
    end

    assign IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst = IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst;
    assign when_IBusSimplePlugin_l376 = (!IBusSimplePlugin_rspJoin_rspBuffer_output_valid);
    assign IBusSimplePlugin_rspJoin_exceptionDetected = 1'b0;
    assign IBusSimplePlugin_rspJoin_join_valid = (IBusSimplePlugin_iBusRsp_stages_2_output_valid && IBusSimplePlugin_rspJoin_rspBuffer_output_valid);
    assign IBusSimplePlugin_rspJoin_join_payload_pc = IBusSimplePlugin_rspJoin_fetchRsp_pc;
    assign IBusSimplePlugin_rspJoin_join_payload_rsp_error = IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
    assign IBusSimplePlugin_rspJoin_join_payload_rsp_inst = IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
    assign IBusSimplePlugin_rspJoin_join_payload_isRvc = IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
    assign IBusSimplePlugin_rspJoin_join_fire = (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready);
    assign IBusSimplePlugin_iBusRsp_stages_2_output_ready = (IBusSimplePlugin_iBusRsp_stages_2_output_valid ? IBusSimplePlugin_rspJoin_join_fire : IBusSimplePlugin_rspJoin_join_ready);
    assign IBusSimplePlugin_rspJoin_rspBuffer_output_ready = IBusSimplePlugin_rspJoin_join_fire;
    assign _zz_IBusSimplePlugin_iBusRsp_output_valid = (! IBusSimplePlugin_rspJoin_exceptionDetected);
    assign IBusSimplePlugin_rspJoin_join_ready = (IBusSimplePlugin_iBusRsp_output_ready && _zz_IBusSimplePlugin_iBusRsp_output_valid);
    assign IBusSimplePlugin_iBusRsp_output_valid = (IBusSimplePlugin_rspJoin_join_valid && _zz_IBusSimplePlugin_iBusRsp_output_valid);
    assign IBusSimplePlugin_iBusRsp_output_payload_pc = IBusSimplePlugin_rspJoin_join_payload_pc;
    assign IBusSimplePlugin_iBusRsp_output_payload_rsp_error = IBusSimplePlugin_rspJoin_join_payload_rsp_error;
    assign IBusSimplePlugin_iBusRsp_output_payload_rsp_inst = IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
    assign IBusSimplePlugin_iBusRsp_output_payload_isRvc = IBusSimplePlugin_rspJoin_join_payload_isRvc;
    assign _zz_dBus_cmd_valid = 1'b0;
    always @(*) begin
        execute_DBusSimplePlugin_skipCmd = 1'b0;
        if (execute_ALIGNEMENT_FAULT) begin
            execute_DBusSimplePlugin_skipCmd = 1'b1;
        end
    end

    assign dBus_cmd_valid = (((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_arbitration_isStuckByOthers)) && (! execute_arbitration_isFlushed)) && (! execute_DBusSimplePlugin_skipCmd)) && (! _zz_dBus_cmd_valid));
    assign dBus_cmd_payload_wr = execute_MEMORY_STORE;
    assign dBus_cmd_payload_size = execute_INSTRUCTION[13 : 12];
    always @(*) begin
        case (dBus_cmd_payload_size)
            2'b00: begin
                _zz_dBus_cmd_payload_data = {
                    {{execute_RS2[7 : 0], execute_RS2[7 : 0]}, execute_RS2[7 : 0]},
                    execute_RS2[7 : 0]
                };
            end
            2'b01: begin
                _zz_dBus_cmd_payload_data = {execute_RS2[15 : 0], execute_RS2[15 : 0]};
            end
            default: begin
                _zz_dBus_cmd_payload_data = execute_RS2[31 : 0];
            end
        endcase
    end

    assign dBus_cmd_payload_data = _zz_dBus_cmd_payload_data;
    assign when_DBusSimplePlugin_l434 = ((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! dBus_cmd_ready)) && (! execute_DBusSimplePlugin_skipCmd)) && (! _zz_dBus_cmd_valid));
    always @(*) begin
        case (dBus_cmd_payload_size)
            2'b00: begin
                _zz_execute_DBusSimplePlugin_formalMask = 4'b0001;
            end
            2'b01: begin
                _zz_execute_DBusSimplePlugin_formalMask = 4'b0011;
            end
            default: begin
                _zz_execute_DBusSimplePlugin_formalMask = 4'b1111;
            end
        endcase
    end

    assign execute_DBusSimplePlugin_formalMask = (_zz_execute_DBusSimplePlugin_formalMask <<< dBus_cmd_payload_address[1 : 0]);
    assign dBus_cmd_payload_mask = execute_DBusSimplePlugin_formalMask;
    assign dBus_cmd_payload_address = execute_SRC_ADD;
    assign when_DBusSimplePlugin_l489 = (((memory_arbitration_isValid && memory_MEMORY_ENABLE) && (! memory_MEMORY_STORE)) && ((! dBus_rsp_ready) || 1'b0));
    always @(*) begin
        writeBack_DBusSimplePlugin_rspShifted = writeBack_MEMORY_READ_DATA;
        case (writeBack_MEMORY_ADDRESS_LOW)
            2'b01: begin
                writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[15 : 8];
            end
            2'b10: begin
                writeBack_DBusSimplePlugin_rspShifted[15 : 0] = writeBack_MEMORY_READ_DATA[31 : 16];
            end
            2'b11: begin
                writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[31 : 24];
            end
            default: begin
            end
        endcase
    end

    assign switch_Misc_l241 = writeBack_INSTRUCTION[13 : 12];
    assign _zz_writeBack_DBusSimplePlugin_rspFormated = (writeBack_DBusSimplePlugin_rspShifted[7] && (! writeBack_INSTRUCTION[14]));
    always @(*) begin
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[31] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[30] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[29] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[28] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[27] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[26] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[25] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[24] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[23] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[22] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[21] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[20] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[19] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[18] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[17] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[16] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[15] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[14] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[13] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[12] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[11] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[10] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[9] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[8] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[7 : 0] = writeBack_DBusSimplePlugin_rspShifted[7 : 0];
    end

    assign _zz_writeBack_DBusSimplePlugin_rspFormated_2 = (writeBack_DBusSimplePlugin_rspShifted[15] && (! writeBack_INSTRUCTION[14]));
    always @(*) begin
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[31] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[30] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[29] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[28] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[27] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[26] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[25] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[24] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[23] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[22] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[21] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[20] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[19] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[18] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[17] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[16] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[15 : 0] = writeBack_DBusSimplePlugin_rspShifted[15 : 0];
    end

    always @(*) begin
        case (switch_Misc_l241)
            2'b00: begin
                writeBack_DBusSimplePlugin_rspFormated = _zz_writeBack_DBusSimplePlugin_rspFormated_1;
            end
            2'b01: begin
                writeBack_DBusSimplePlugin_rspFormated = _zz_writeBack_DBusSimplePlugin_rspFormated_3;
            end
            default: begin
                writeBack_DBusSimplePlugin_rspFormated = writeBack_DBusSimplePlugin_rspShifted;
            end
        endcase
    end

    assign when_DBusSimplePlugin_l565 = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
    always @(*) begin
        CsrPlugin_privilege = 2'b11;
        if (CsrPlugin_forceMachineWire) begin
            CsrPlugin_privilege = 2'b11;
        end
    end

    assign CsrPlugin_misa_base = 2'b01;
    assign CsrPlugin_misa_extensions = 26'h0000042;
    assign CsrPlugin_mtvec_mode = 2'b00;
    assign CsrPlugin_mtvec_base = 30'h20000008;
    assign _zz_when_CsrPlugin_l1302 = (CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE);
    assign _zz_when_CsrPlugin_l1302_1 = (CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE);
    assign _zz_when_CsrPlugin_l1302_2 = (CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE);
    assign when_CsrPlugin_l1296 = (CsrPlugin_mstatus_MIE || (CsrPlugin_privilege < 2'b11));
    assign when_CsrPlugin_l1302 = ((_zz_when_CsrPlugin_l1302 && 1'b1) && (!1'b0));
    assign when_CsrPlugin_l1302_1 = ((_zz_when_CsrPlugin_l1302_1 && 1'b1) && (!1'b0));
    assign when_CsrPlugin_l1302_2 = ((_zz_when_CsrPlugin_l1302_2 && 1'b1) && (!1'b0));
    assign CsrPlugin_exception = 1'b0;
    assign CsrPlugin_lastStageWasWfi = 1'b0;
    assign CsrPlugin_pipelineLiberator_active = ((CsrPlugin_interrupt_valid && CsrPlugin_allowInterrupts) && decode_arbitration_isValid);
    assign when_CsrPlugin_l1335 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1335_1 = (!memory_arbitration_isStuck);
    assign when_CsrPlugin_l1335_2 = (!writeBack_arbitration_isStuck);
    assign when_CsrPlugin_l1340 = ((! CsrPlugin_pipelineLiberator_active) || decode_arbitration_removeIt);
    always @(*) begin
        CsrPlugin_pipelineLiberator_done = CsrPlugin_pipelineLiberator_pcValids_2;
        if (CsrPlugin_hadException) begin
            CsrPlugin_pipelineLiberator_done = 1'b0;
        end
    end

    assign CsrPlugin_interruptJump = ((CsrPlugin_interrupt_valid && CsrPlugin_pipelineLiberator_done) && CsrPlugin_allowInterrupts);
    assign CsrPlugin_targetPrivilege = CsrPlugin_interrupt_targetPrivilege;
    assign CsrPlugin_trapCause = CsrPlugin_interrupt_code;
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
    assign switch_Misc_l241_1 = execute_INSTRUCTION[13];
    always @(*) begin
        case (switch_Misc_l241_1)
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
    assign _zz_decode_IS_RS2_SIGNED_1 = ((decode_INSTRUCTION & 32'h00004050) == 32'h00004050);
    assign _zz_decode_IS_RS2_SIGNED_2 = ((decode_INSTRUCTION & 32'h00006004) == 32'h00002000);
    assign _zz_decode_IS_RS2_SIGNED_3 = ((decode_INSTRUCTION & 32'h00000018) == 32'h0);
    assign _zz_decode_IS_RS2_SIGNED_4 = ((decode_INSTRUCTION & 32'h00000004) == 32'h00000004);
    assign _zz_decode_IS_RS2_SIGNED_5 = ((decode_INSTRUCTION & 32'h00000048) == 32'h00000048);
    assign _zz_decode_IS_RS2_SIGNED_6 = ((decode_INSTRUCTION & 32'h00000030) == 32'h00000010);
    assign _zz_decode_IS_RS2_SIGNED_7 = ((decode_INSTRUCTION & 32'h00001000) == 32'h0);
    assign _zz_decode_IS_RS2_SIGNED = {
        (|((decode_INSTRUCTION & 32'h10003050) == 32'h00000050)),
        {
            (|_zz_decode_IS_RS2_SIGNED_7),
            {
                (|_zz_decode_IS_RS2_SIGNED_7),
                {
                    (|_zz__zz_decode_IS_RS2_SIGNED),
                    {
                        (|_zz__zz_decode_IS_RS2_SIGNED_1),
                        {
                            _zz__zz_decode_IS_RS2_SIGNED_2,
                            {_zz__zz_decode_IS_RS2_SIGNED_5, _zz__zz_decode_IS_RS2_SIGNED_8}
                        }
                    }
                }
            }
        }
    };
    assign _zz_decode_SRC1_CTRL_2 = _zz_decode_IS_RS2_SIGNED[1 : 0];
    assign _zz_decode_SRC1_CTRL_1 = _zz_decode_SRC1_CTRL_2;
    assign _zz_decode_SRC2_CTRL_2 = _zz_decode_IS_RS2_SIGNED[6 : 5];
    assign _zz_decode_SRC2_CTRL_1 = _zz_decode_SRC2_CTRL_2;
    assign _zz_decode_ENV_CTRL_2 = _zz_decode_IS_RS2_SIGNED[14 : 14];
    assign _zz_decode_ENV_CTRL_1 = _zz_decode_ENV_CTRL_2;
    assign _zz_decode_ALU_CTRL_2 = _zz_decode_IS_RS2_SIGNED[16 : 15];
    assign _zz_decode_ALU_CTRL_1 = _zz_decode_ALU_CTRL_2;
    assign _zz_decode_ALU_BITWISE_CTRL_2 = _zz_decode_IS_RS2_SIGNED[19 : 18];
    assign _zz_decode_ALU_BITWISE_CTRL_1 = _zz_decode_ALU_BITWISE_CTRL_2;
    assign _zz_decode_SHIFT_CTRL_2 = _zz_decode_IS_RS2_SIGNED[22 : 21];
    assign _zz_decode_SHIFT_CTRL_1 = _zz_decode_SHIFT_CTRL_2;
    assign _zz_decode_BRANCH_CTRL_2 = _zz_decode_IS_RS2_SIGNED[24 : 23];
    assign _zz_decode_BRANCH_CTRL_1 = _zz_decode_BRANCH_CTRL_2;
    assign when_RegFilePlugin_l63 = (decode_INSTRUCTION[11 : 7] == 5'h0);
    assign decode_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION_ANTICIPATED[19 : 15];
    assign decode_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION_ANTICIPATED[24 : 20];
    assign decode_RegFilePlugin_rs1Data = RegFilePlugin_regFile_spinal_port0;
    assign decode_RegFilePlugin_rs2Data = RegFilePlugin_regFile_spinal_port1;
    always @(*) begin
        lastStageRegFileWrite_valid = (_zz_lastStageRegFileWrite_valid && writeBack_arbitration_isFiring);
        if (_zz_5) begin
            lastStageRegFileWrite_valid = 1'b1;
        end
    end

    always @(*) begin
        lastStageRegFileWrite_payload_address = _zz_lastStageRegFileWrite_payload_address[11 : 7];
        if (_zz_5) begin
            lastStageRegFileWrite_payload_address = 5'h0;
        end
    end

    always @(*) begin
        lastStageRegFileWrite_payload_data = _zz_decode_RS2_2;
        if (_zz_5) begin
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
        case (decode_SRC1_CTRL)
            Src1CtrlEnum_RS: begin
                _zz_decode_SRC1 = _zz_decode_to_execute_RS1;
            end
            Src1CtrlEnum_PC_INCREMENT: begin
                _zz_decode_SRC1 = {29'd0, _zz__zz_decode_SRC1};
            end
            Src1CtrlEnum_IMU: begin
                _zz_decode_SRC1 = {decode_INSTRUCTION[31 : 12], 12'h0};
            end
            default: begin
                _zz_decode_SRC1 = {27'd0, _zz__zz_decode_SRC1_1};
            end
        endcase
    end

    assign _zz_decode_SRC2 = decode_INSTRUCTION[31];
    always @(*) begin
        _zz_decode_SRC2_1[19] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[18] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[17] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[16] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[15] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[14] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[13] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[12] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[11] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[10] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[9]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[8]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[7]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[6]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[5]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[4]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[3]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[2]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[1]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[0]  = _zz_decode_SRC2;
    end

    assign _zz_decode_SRC2_2 = _zz__zz_decode_SRC2_2[11];
    always @(*) begin
        _zz_decode_SRC2_3[19] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[18] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[17] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[16] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[15] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[14] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[13] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[12] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[11] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[10] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[9]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[8]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[7]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[6]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[5]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[4]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[3]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[2]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[1]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[0]  = _zz_decode_SRC2_2;
    end

    always @(*) begin
        case (decode_SRC2_CTRL)
            Src2CtrlEnum_RS: begin
                _zz_decode_SRC2_4 = _zz_decode_to_execute_RS2;
            end
            Src2CtrlEnum_IMI: begin
                _zz_decode_SRC2_4 = {_zz_decode_SRC2_1, decode_INSTRUCTION[31 : 20]};
            end
            Src2CtrlEnum_IMS: begin
                _zz_decode_SRC2_4 = {
                    _zz_decode_SRC2_3, {decode_INSTRUCTION[31 : 25], decode_INSTRUCTION[11 : 7]}
                };
            end
            default: begin
                _zz_decode_SRC2_4 = _zz_decode_to_execute_PC;
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
    assign execute_LightShifterPlugin_isShift = (execute_SHIFT_CTRL != ShiftCtrlEnum_DISABLE_1);
    assign execute_LightShifterPlugin_amplitude = (execute_LightShifterPlugin_isActive ? execute_LightShifterPlugin_amplitudeReg : execute_SRC2[4 : 0]);
    assign execute_LightShifterPlugin_shiftInput = (execute_LightShifterPlugin_isActive ? memory_REGFILE_WRITE_DATA : execute_SRC1);
    assign execute_LightShifterPlugin_done = (execute_LightShifterPlugin_amplitude[4 : 1] == 4'b0000);
    assign when_ShiftPlugins_l169 = ((execute_arbitration_isValid && execute_LightShifterPlugin_isShift) && (execute_SRC2[4 : 0] != 5'h0));
    always @(*) begin
        case (execute_SHIFT_CTRL)
            ShiftCtrlEnum_SLL_1: begin
                _zz_decode_RS2_3 = (execute_LightShifterPlugin_shiftInput <<< 1);
            end
            default: begin
                _zz_decode_RS2_3 = _zz__zz_decode_RS2_3;
            end
        endcase
    end

    assign when_ShiftPlugins_l175 = (!execute_arbitration_isStuckByOthers);
    assign when_ShiftPlugins_l184 = (!execute_LightShifterPlugin_done);
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
    assign switch_Misc_l241_2 = execute_INSTRUCTION[14 : 12];
    always @(*) begin
        case (switch_Misc_l241_2)
            3'b000: begin
                _zz_execute_BRANCH_DO = execute_BranchPlugin_eq;
            end
            3'b001: begin
                _zz_execute_BRANCH_DO = (!execute_BranchPlugin_eq);
            end
            3'b101: begin
                _zz_execute_BRANCH_DO = (!execute_SRC_LESS);
            end
            3'b111: begin
                _zz_execute_BRANCH_DO = (!execute_SRC_LESS);
            end
            default: begin
                _zz_execute_BRANCH_DO = execute_SRC_LESS;
            end
        endcase
    end

    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: begin
                _zz_execute_BRANCH_DO_1 = 1'b0;
            end
            BranchCtrlEnum_JAL: begin
                _zz_execute_BRANCH_DO_1 = 1'b1;
            end
            BranchCtrlEnum_JALR: begin
                _zz_execute_BRANCH_DO_1 = 1'b1;
            end
            default: begin
                _zz_execute_BRANCH_DO_1 = _zz_execute_BRANCH_DO;
            end
        endcase
    end

    assign execute_BranchPlugin_branch_src1 = ((execute_BRANCH_CTRL == BranchCtrlEnum_JALR) ? execute_RS1 : execute_PC);
    assign _zz_execute_BranchPlugin_branch_src2 = _zz__zz_execute_BranchPlugin_branch_src2[19];
    always @(*) begin
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

    assign _zz_execute_BranchPlugin_branch_src2_2 = execute_INSTRUCTION[31];
    always @(*) begin
        _zz_execute_BranchPlugin_branch_src2_3[19] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[18] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[17] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[16] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[15] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[14] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[13] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[12] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[11] = _zz_execute_BranchPlugin_branch_src2_2;
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

    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_JAL: begin
                _zz_execute_BranchPlugin_branch_src2_6 = {
                    {
                        _zz_execute_BranchPlugin_branch_src2_1,
                        {
                            {
                                {execute_INSTRUCTION[31], execute_INSTRUCTION[19 : 12]},
                                execute_INSTRUCTION[20]
                            },
                            execute_INSTRUCTION[30 : 21]
                        }
                    },
                    1'b0
                };
            end
            BranchCtrlEnum_JALR: begin
                _zz_execute_BranchPlugin_branch_src2_6 = {
                    _zz_execute_BranchPlugin_branch_src2_3, execute_INSTRUCTION[31 : 20]
                };
            end
            default: begin
                _zz_execute_BranchPlugin_branch_src2_6 = {
                    {
                        _zz_execute_BranchPlugin_branch_src2_5,
                        {
                            {
                                {execute_INSTRUCTION[31], execute_INSTRUCTION[7]},
                                execute_INSTRUCTION[30 : 25]
                            },
                            execute_INSTRUCTION[11 : 8]
                        }
                    },
                    1'b0
                };
            end
        endcase
    end

    assign execute_BranchPlugin_branch_src2 = _zz_execute_BranchPlugin_branch_src2_6;
    assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
    assign BranchPlugin_jumpInterface_valid = ((memory_arbitration_isValid && memory_BRANCH_DO) && (! 1'b0));
    assign BranchPlugin_jumpInterface_payload = memory_BRANCH_CALC;
    assign execute_MulPlugin_a = execute_RS1;
    assign execute_MulPlugin_b = execute_RS2;
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

    assign when_DebugPlugin_l238   = (DebugPlugin_haltIt && (!DebugPlugin_isPipBusy));
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
    assign when_DebugPlugin_l324 = (DebugPlugin_stepIt && IBusSimplePlugin_incomingInstruction);
    assign debug_resetOut = DebugPlugin_resetIt_regNext;
    assign when_DebugPlugin_l344 = (DebugPlugin_haltIt || DebugPlugin_stepIt);
    assign when_Pipeline_l124 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_1 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_2 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_3 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_4 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_5 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_6 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_7 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_8 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_9 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_10 = (!execute_arbitration_isStuck);
    assign _zz_decode_SRC1_CTRL = _zz_decode_SRC1_CTRL_1;
    assign when_Pipeline_l124_11 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_12 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_13 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_14 = (!writeBack_arbitration_isStuck);
    assign _zz_decode_SRC2_CTRL = _zz_decode_SRC2_CTRL_1;
    assign when_Pipeline_l124_15 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_16 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_17 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_18 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_19 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_20 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_21 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_22 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_23 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_ENV_CTRL_1 = decode_ENV_CTRL;
    assign _zz_execute_to_memory_ENV_CTRL_1 = execute_ENV_CTRL;
    assign _zz_memory_to_writeBack_ENV_CTRL_1 = memory_ENV_CTRL;
    assign _zz_decode_ENV_CTRL = _zz_decode_ENV_CTRL_1;
    assign when_Pipeline_l124_24 = (!execute_arbitration_isStuck);
    assign _zz_execute_ENV_CTRL = decode_to_execute_ENV_CTRL;
    assign when_Pipeline_l124_25 = (!memory_arbitration_isStuck);
    assign _zz_memory_ENV_CTRL = execute_to_memory_ENV_CTRL;
    assign when_Pipeline_l124_26 = (!writeBack_arbitration_isStuck);
    assign _zz_writeBack_ENV_CTRL = memory_to_writeBack_ENV_CTRL;
    assign _zz_decode_to_execute_ALU_CTRL_1 = decode_ALU_CTRL;
    assign _zz_decode_ALU_CTRL = _zz_decode_ALU_CTRL_1;
    assign when_Pipeline_l124_27 = (!execute_arbitration_isStuck);
    assign _zz_execute_ALU_CTRL = decode_to_execute_ALU_CTRL;
    assign when_Pipeline_l124_28 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_ALU_BITWISE_CTRL_1 = decode_ALU_BITWISE_CTRL;
    assign _zz_decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL_1;
    assign when_Pipeline_l124_29 = (!execute_arbitration_isStuck);
    assign _zz_execute_ALU_BITWISE_CTRL = decode_to_execute_ALU_BITWISE_CTRL;
    assign _zz_decode_to_execute_SHIFT_CTRL_1 = decode_SHIFT_CTRL;
    assign _zz_decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL_1;
    assign when_Pipeline_l124_30 = (!execute_arbitration_isStuck);
    assign _zz_execute_SHIFT_CTRL = decode_to_execute_SHIFT_CTRL;
    assign _zz_decode_to_execute_BRANCH_CTRL_1 = decode_BRANCH_CTRL;
    assign _zz_decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL_1;
    assign when_Pipeline_l124_31 = (!execute_arbitration_isStuck);
    assign _zz_execute_BRANCH_CTRL = decode_to_execute_BRANCH_CTRL;
    assign when_Pipeline_l124_32 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_33 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_34 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_35 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_36 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_37 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_38 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_39 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_40 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_41 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_42 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_43 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_44 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_45 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_46 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_47 = ((! memory_arbitration_isStuck) && (! execute_arbitration_isStuckByOthers));
    assign when_Pipeline_l124_48 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_49 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_50 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_51 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_52 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_53 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_54 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_55 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_56 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_57 = (!writeBack_arbitration_isStuck);
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
        case (IBusSimplePlugin_injector_port_state)
            3'b100: begin
                DebugPlugin_injectionPort_ready = 1'b1;
            end
            default: begin
            end
        endcase
    end

    assign when_Fetcher_l391 = (!decode_arbitration_isStuck);
    assign when_Fetcher_l411 = (IBusSimplePlugin_injector_port_state != 3'b000);
    assign when_CsrPlugin_l1669 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_1 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_2 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_3 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_4 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_5 = (!execute_arbitration_isStuck);
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
        if (execute_CsrPlugin_csr_833) begin
            _zz_CsrPlugin_csrMapping_readDataInit_3[31 : 0] = CsrPlugin_mepc;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_4 = 32'h0;
        if (execute_CsrPlugin_csr_834) begin
            _zz_CsrPlugin_csrMapping_readDataInit_4[31 : 31] = CsrPlugin_mcause_interrupt;
            _zz_CsrPlugin_csrMapping_readDataInit_4[3 : 0]   = CsrPlugin_mcause_exceptionCode;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_5 = 32'h0;
        if (execute_CsrPlugin_csr_835) begin
            _zz_CsrPlugin_csrMapping_readDataInit_5[31 : 0] = CsrPlugin_mtval;
        end
    end

    assign CsrPlugin_csrMapping_readDataInit = (((_zz_CsrPlugin_csrMapping_readDataInit | _zz_CsrPlugin_csrMapping_readDataInit_1) | (_zz_CsrPlugin_csrMapping_readDataInit_2 | _zz_CsrPlugin_csrMapping_readDataInit_3)) | (_zz_CsrPlugin_csrMapping_readDataInit_4 | _zz_CsrPlugin_csrMapping_readDataInit_5));
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
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            IBusSimplePlugin_fetchPc_pcReg <= 32'h80000000;
            IBusSimplePlugin_fetchPc_correctionReg <= 1'b0;
            IBusSimplePlugin_fetchPc_booted <= 1'b0;
            IBusSimplePlugin_fetchPc_inc <= 1'b0;
            _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1 <= 1'b0;
            _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid <= 1'b0;
            _zz_IBusSimplePlugin_injector_decodeInput_valid <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_5 <= 1'b0;
            IBusSimplePlugin_pending_value <= 3'b000;
            IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= 3'b000;
            CsrPlugin_mstatus_MIE <= 1'b0;
            CsrPlugin_mstatus_MPIE <= 1'b0;
            CsrPlugin_mstatus_MPP <= 2'b11;
            CsrPlugin_mie_MEIE <= 1'b0;
            CsrPlugin_mie_MTIE <= 1'b0;
            CsrPlugin_mie_MSIE <= 1'b0;
            CsrPlugin_mcycle <= 64'h0;
            CsrPlugin_minstret <= 64'h0;
            CsrPlugin_interrupt_valid <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_1 <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_2 <= 1'b0;
            CsrPlugin_hadException <= 1'b0;
            execute_CsrPlugin_wfiWake <= 1'b0;
            _zz_5 <= 1'b1;
            execute_LightShifterPlugin_isActive <= 1'b0;
            HazardSimplePlugin_writeBackBuffer_valid <= 1'b0;
            memory_DivPlugin_div_counter_value <= 6'h0;
            execute_arbitration_isValid <= 1'b0;
            memory_arbitration_isValid <= 1'b0;
            writeBack_arbitration_isValid <= 1'b0;
            IBusSimplePlugin_injector_port_state <= 3'b000;
        end else begin
            if (IBusSimplePlugin_fetchPc_correction) begin
                IBusSimplePlugin_fetchPc_correctionReg <= 1'b1;
            end
            if (IBusSimplePlugin_fetchPc_output_fire) begin
                IBusSimplePlugin_fetchPc_correctionReg <= 1'b0;
            end
            IBusSimplePlugin_fetchPc_booted <= 1'b1;
            if (when_Fetcher_l133) begin
                IBusSimplePlugin_fetchPc_inc <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_output_fire) begin
                IBusSimplePlugin_fetchPc_inc <= 1'b1;
            end
            if (when_Fetcher_l133_1) begin
                IBusSimplePlugin_fetchPc_inc <= 1'b0;
            end
            if (when_Fetcher_l160) begin
                IBusSimplePlugin_fetchPc_pcReg <= IBusSimplePlugin_fetchPc_pc;
            end
            if (IBusSimplePlugin_iBusRsp_flush) begin
                _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1 <= 1'b0;
            end
            if (_zz_IBusSimplePlugin_iBusRsp_stages_0_output_ready) begin
                _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1 <= (IBusSimplePlugin_iBusRsp_stages_0_output_valid && (! 1'b0));
            end
            if (IBusSimplePlugin_iBusRsp_flush) begin
                _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid <= 1'b0;
            end
            if (IBusSimplePlugin_iBusRsp_stages_1_output_ready) begin
                _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid <= (IBusSimplePlugin_iBusRsp_stages_1_output_valid && (! IBusSimplePlugin_iBusRsp_flush));
            end
            if (decode_arbitration_removeIt) begin
                _zz_IBusSimplePlugin_injector_decodeInput_valid <= 1'b0;
            end
            if (IBusSimplePlugin_iBusRsp_output_ready) begin
                _zz_IBusSimplePlugin_injector_decodeInput_valid <= (IBusSimplePlugin_iBusRsp_output_valid && (! IBusSimplePlugin_externalFlush));
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
            end
            if (when_Fetcher_l331) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b1;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            end
            if (when_Fetcher_l331_1) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_1 <= IBusSimplePlugin_injector_nextPcCalc_valids_0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            end
            if (when_Fetcher_l331_2) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_2 <= IBusSimplePlugin_injector_nextPcCalc_valids_1;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            end
            if (when_Fetcher_l331_3) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_3 <= IBusSimplePlugin_injector_nextPcCalc_valids_2;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            end
            if (when_Fetcher_l331_4) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_4 <= IBusSimplePlugin_injector_nextPcCalc_valids_3;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_5 <= 1'b0;
            end
            if (when_Fetcher_l331_5) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_5 <= IBusSimplePlugin_injector_nextPcCalc_valids_4;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_5 <= 1'b0;
            end
            IBusSimplePlugin_pending_value <= IBusSimplePlugin_pending_next;
            IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter - _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter);
            if (IBusSimplePlugin_iBusRsp_flush) begin
                IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= IBusSimplePlugin_pending_next;
            end
            CsrPlugin_mcycle <= (CsrPlugin_mcycle + 64'h0000000000000001);
            if (writeBack_arbitration_isFiring) begin
                CsrPlugin_minstret <= (CsrPlugin_minstret + 64'h0000000000000001);
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
            _zz_5 <= 1'b0;
            if (when_ShiftPlugins_l169) begin
                if (when_ShiftPlugins_l175) begin
                    execute_LightShifterPlugin_isActive <= 1'b1;
                    if (execute_LightShifterPlugin_done) begin
                        execute_LightShifterPlugin_isActive <= 1'b0;
                    end
                end
            end
            if (execute_arbitration_removeIt) begin
                execute_LightShifterPlugin_isActive <= 1'b0;
            end
            HazardSimplePlugin_writeBackBuffer_valid <= HazardSimplePlugin_writeBackWrites_valid;
            memory_DivPlugin_div_counter_value <= memory_DivPlugin_div_counter_valueNext;
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
            case (IBusSimplePlugin_injector_port_state)
                3'b000: begin
                    if (DebugPlugin_injectionPort_valid) begin
                        IBusSimplePlugin_injector_port_state <= 3'b001;
                    end
                end
                3'b001: begin
                    IBusSimplePlugin_injector_port_state <= 3'b010;
                end
                3'b010: begin
                    IBusSimplePlugin_injector_port_state <= 3'b011;
                end
                3'b011: begin
                    if (when_Fetcher_l391) begin
                        IBusSimplePlugin_injector_port_state <= 3'b100;
                    end
                end
                3'b100: begin
                    IBusSimplePlugin_injector_port_state <= 3'b000;
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
        end
    end

    always @(posedge io_mainClk) begin
        if (IBusSimplePlugin_iBusRsp_stages_1_output_ready) begin
            _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload <= IBusSimplePlugin_iBusRsp_stages_1_output_payload;
        end
        if (IBusSimplePlugin_iBusRsp_output_ready) begin
            _zz_IBusSimplePlugin_injector_decodeInput_payload_pc <= IBusSimplePlugin_iBusRsp_output_payload_pc;
            _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error <= IBusSimplePlugin_iBusRsp_output_payload_rsp_error;
            _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst <= IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
            _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc <= IBusSimplePlugin_iBusRsp_output_payload_isRvc;
        end
        if (IBusSimplePlugin_injector_decodeInput_ready) begin
            IBusSimplePlugin_injector_formal_rawInDecode <= IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
        end
        CsrPlugin_mip_MEIP <= externalInterrupt;
        CsrPlugin_mip_MTIP <= timerInterrupt;
        CsrPlugin_mip_MSIP <= softwareInterrupt;
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
                        CsrPlugin_mepc <= decode_PC;
                    end
                    default: begin
                    end
                endcase
            end
        end
        CsrPlugin_mtval <= 32'h0;
        if (when_ShiftPlugins_l169) begin
            if (when_ShiftPlugins_l175) begin
                execute_LightShifterPlugin_amplitudeReg <= (execute_LightShifterPlugin_amplitude - 5'h01);
            end
        end
        HazardSimplePlugin_writeBackBuffer_payload_address <= HazardSimplePlugin_writeBackWrites_payload_address;
        HazardSimplePlugin_writeBackBuffer_payload_data <= HazardSimplePlugin_writeBackWrites_payload_data;
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
        if (when_Pipeline_l124) begin
            decode_to_execute_PC <= _zz_decode_to_execute_PC;
        end
        if (when_Pipeline_l124_1) begin
            execute_to_memory_PC <= execute_PC;
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
            decode_to_execute_FORMAL_PC_NEXT <= decode_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_7) begin
            execute_to_memory_FORMAL_PC_NEXT <= execute_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_8) begin
            memory_to_writeBack_FORMAL_PC_NEXT <= _zz_memory_to_writeBack_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_9) begin
            decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
        end
        if (when_Pipeline_l124_10) begin
            decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
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
            decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_16) begin
            execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_17) begin
            memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_18) begin
            decode_to_execute_BYPASSABLE_EXECUTE_STAGE <= decode_BYPASSABLE_EXECUTE_STAGE;
        end
        if (when_Pipeline_l124_19) begin
            decode_to_execute_BYPASSABLE_MEMORY_STAGE <= decode_BYPASSABLE_MEMORY_STAGE;
        end
        if (when_Pipeline_l124_20) begin
            execute_to_memory_BYPASSABLE_MEMORY_STAGE <= execute_BYPASSABLE_MEMORY_STAGE;
        end
        if (when_Pipeline_l124_21) begin
            decode_to_execute_MEMORY_STORE <= decode_MEMORY_STORE;
        end
        if (when_Pipeline_l124_22) begin
            execute_to_memory_MEMORY_STORE <= execute_MEMORY_STORE;
        end
        if (when_Pipeline_l124_23) begin
            decode_to_execute_IS_CSR <= decode_IS_CSR;
        end
        if (when_Pipeline_l124_24) begin
            decode_to_execute_ENV_CTRL <= _zz_decode_to_execute_ENV_CTRL;
        end
        if (when_Pipeline_l124_25) begin
            execute_to_memory_ENV_CTRL <= _zz_execute_to_memory_ENV_CTRL;
        end
        if (when_Pipeline_l124_26) begin
            memory_to_writeBack_ENV_CTRL <= _zz_memory_to_writeBack_ENV_CTRL;
        end
        if (when_Pipeline_l124_27) begin
            decode_to_execute_ALU_CTRL <= _zz_decode_to_execute_ALU_CTRL;
        end
        if (when_Pipeline_l124_28) begin
            decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
        end
        if (when_Pipeline_l124_29) begin
            decode_to_execute_ALU_BITWISE_CTRL <= _zz_decode_to_execute_ALU_BITWISE_CTRL;
        end
        if (when_Pipeline_l124_30) begin
            decode_to_execute_SHIFT_CTRL <= _zz_decode_to_execute_SHIFT_CTRL;
        end
        if (when_Pipeline_l124_31) begin
            decode_to_execute_BRANCH_CTRL <= _zz_decode_to_execute_BRANCH_CTRL;
        end
        if (when_Pipeline_l124_32) begin
            decode_to_execute_IS_MUL <= decode_IS_MUL;
        end
        if (when_Pipeline_l124_33) begin
            execute_to_memory_IS_MUL <= execute_IS_MUL;
        end
        if (when_Pipeline_l124_34) begin
            memory_to_writeBack_IS_MUL <= memory_IS_MUL;
        end
        if (when_Pipeline_l124_35) begin
            decode_to_execute_IS_DIV <= decode_IS_DIV;
        end
        if (when_Pipeline_l124_36) begin
            execute_to_memory_IS_DIV <= execute_IS_DIV;
        end
        if (when_Pipeline_l124_37) begin
            decode_to_execute_IS_RS1_SIGNED <= decode_IS_RS1_SIGNED;
        end
        if (when_Pipeline_l124_38) begin
            decode_to_execute_IS_RS2_SIGNED <= decode_IS_RS2_SIGNED;
        end
        if (when_Pipeline_l124_39) begin
            decode_to_execute_RS1 <= _zz_decode_to_execute_RS1;
        end
        if (when_Pipeline_l124_40) begin
            decode_to_execute_RS2 <= _zz_decode_to_execute_RS2;
        end
        if (when_Pipeline_l124_41) begin
            decode_to_execute_SRC2_FORCE_ZERO <= decode_SRC2_FORCE_ZERO;
        end
        if (when_Pipeline_l124_42) begin
            decode_to_execute_SRC1 <= decode_SRC1;
        end
        if (when_Pipeline_l124_43) begin
            decode_to_execute_SRC2 <= decode_SRC2;
        end
        if (when_Pipeline_l124_44) begin
            decode_to_execute_DO_EBREAK <= decode_DO_EBREAK;
        end
        if (when_Pipeline_l124_45) begin
            execute_to_memory_MEMORY_ADDRESS_LOW <= execute_MEMORY_ADDRESS_LOW;
        end
        if (when_Pipeline_l124_46) begin
            memory_to_writeBack_MEMORY_ADDRESS_LOW <= memory_MEMORY_ADDRESS_LOW;
        end
        if (when_Pipeline_l124_47) begin
            execute_to_memory_REGFILE_WRITE_DATA <= _zz_decode_RS2_1;
        end
        if (when_Pipeline_l124_48) begin
            memory_to_writeBack_REGFILE_WRITE_DATA <= _zz_decode_RS2;
        end
        if (when_Pipeline_l124_49) begin
            execute_to_memory_BRANCH_DO <= execute_BRANCH_DO;
        end
        if (when_Pipeline_l124_50) begin
            execute_to_memory_BRANCH_CALC <= execute_BRANCH_CALC;
        end
        if (when_Pipeline_l124_51) begin
            execute_to_memory_MUL_LL <= execute_MUL_LL;
        end
        if (when_Pipeline_l124_52) begin
            execute_to_memory_MUL_LH <= execute_MUL_LH;
        end
        if (when_Pipeline_l124_53) begin
            execute_to_memory_MUL_HL <= execute_MUL_HL;
        end
        if (when_Pipeline_l124_54) begin
            execute_to_memory_MUL_HH <= execute_MUL_HH;
        end
        if (when_Pipeline_l124_55) begin
            memory_to_writeBack_MUL_HH <= memory_MUL_HH;
        end
        if (when_Pipeline_l124_56) begin
            memory_to_writeBack_MEMORY_READ_DATA <= memory_MEMORY_READ_DATA;
        end
        if (when_Pipeline_l124_57) begin
            memory_to_writeBack_MUL_LOW <= memory_MUL_LOW;
        end
        if (when_Fetcher_l411) begin
            _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst <= DebugPlugin_injectionPort_payload;
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
            execute_CsrPlugin_csr_833 <= (decode_INSTRUCTION[31 : 20] == 12'h341);
        end
        if (when_CsrPlugin_l1669_4) begin
            execute_CsrPlugin_csr_834 <= (decode_INSTRUCTION[31 : 20] == 12'h342);
        end
        if (when_CsrPlugin_l1669_5) begin
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

    always @(posedge io_mainClk) begin
        DebugPlugin_firstCycle <= 1'b0;
        if (debug_bus_cmd_ready) begin
            DebugPlugin_firstCycle <= 1'b1;
        end
        DebugPlugin_secondCycle <= DebugPlugin_firstCycle;
        DebugPlugin_isPipBusy <= ((|{writeBack_arbitration_isValid,{memory_arbitration_isValid,{execute_arbitration_isValid,decode_arbitration_isValid}}}) || IBusSimplePlugin_incomingInstruction);
        if (writeBack_arbitration_isValid) begin
            DebugPlugin_busReadDataReg <= _zz_decode_RS2_2;
        end
        _zz_when_DebugPlugin_l257 <= debug_bus_cmd_payload_address[2];
        if (when_DebugPlugin_l308) begin
            DebugPlugin_busReadDataReg <= execute_PC;
        end
        DebugPlugin_resetIt_regNext <= DebugPlugin_resetIt;
    end

    always @(posedge io_mainClk or posedge resetCtrl_mainClkReset) begin
        if (resetCtrl_mainClkReset) begin
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


module StreamFifoLowLatency (
    input  wire        io_push_valid,
    output wire        io_push_ready,
    input  wire        io_push_payload_error,
    input  wire [31:0] io_push_payload_inst,
    output wire        io_pop_valid,
    input  wire        io_pop_ready,
    output wire        io_pop_payload_error,
    output wire [31:0] io_pop_payload_inst,
    input  wire        io_flush,
    output wire [ 0:0] io_occupancy,
    output wire [ 0:0] io_availability,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    wire        fifo_io_push_ready;
    wire        fifo_io_pop_valid;
    wire        fifo_io_pop_payload_error;
    wire [31:0] fifo_io_pop_payload_inst;
    wire [ 0:0] fifo_io_occupancy;
    wire [ 0:0] fifo_io_availability;

    StreamFifo_VexRisv StreamFifo_VexRisv (
        .io_push_valid        (io_push_valid),                   // i
        .io_push_ready        (fifo_io_push_ready),              // o
        .io_push_payload_error(io_push_payload_error),           // i
        .io_push_payload_inst (io_push_payload_inst[31:0]),      // i
        .io_pop_valid         (fifo_io_pop_valid),               // o
        .io_pop_ready         (io_pop_ready),                    // i
        .io_pop_payload_error (fifo_io_pop_payload_error),       // o
        .io_pop_payload_inst  (fifo_io_pop_payload_inst[31:0]),  // o
        .io_flush             (io_flush),                        // i
        .io_occupancy         (fifo_io_occupancy),               // o
        .io_availability      (fifo_io_availability),            // o
        .io_mainClk           (io_mainClk),                      // i
        .resetCtrl_systemReset(resetCtrl_systemReset)            // i
    );
    assign io_push_ready = fifo_io_push_ready;
    assign io_pop_valid = fifo_io_pop_valid;
    assign io_pop_payload_error = fifo_io_pop_payload_error;
    assign io_pop_payload_inst = fifo_io_pop_payload_inst;
    assign io_occupancy = fifo_io_occupancy;
    assign io_availability = fifo_io_availability;

endmodule


module StreamFifo_VexRisv (
    input  wire        io_push_valid,
    output reg         io_push_ready,
    input  wire        io_push_payload_error,
    input  wire [31:0] io_push_payload_inst,
    output reg         io_pop_valid,
    input  wire        io_pop_ready,
    output reg         io_pop_payload_error,
    output reg  [31:0] io_pop_payload_inst,
    input  wire        io_flush,
    output wire [ 0:0] io_occupancy,
    output wire [ 0:0] io_availability,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    reg         oneStage_doFlush;
    wire        oneStage_buffer_valid;
    wire        oneStage_buffer_ready;
    wire        oneStage_buffer_payload_error;
    wire [31:0] oneStage_buffer_payload_inst;
    reg         io_push_rValid;
    reg         io_push_rData_error;
    reg  [31:0] io_push_rData_inst;
    wire        when_Stream_l375;
    wire        when_Stream_l1230;

    always @(*) begin
        oneStage_doFlush = io_flush;
        if (when_Stream_l1230) begin
            if (io_pop_ready) begin
                oneStage_doFlush = 1'b1;
            end
        end
    end

    always @(*) begin
        io_push_ready = oneStage_buffer_ready;
        if (when_Stream_l375) begin
            io_push_ready = 1'b1;
        end
    end

    assign when_Stream_l375 = (!oneStage_buffer_valid);
    assign oneStage_buffer_valid = io_push_rValid;
    assign oneStage_buffer_payload_error = io_push_rData_error;
    assign oneStage_buffer_payload_inst = io_push_rData_inst;
    always @(*) begin
        io_pop_valid = oneStage_buffer_valid;
        if (when_Stream_l1230) begin
            io_pop_valid = io_push_valid;
        end
    end

    assign oneStage_buffer_ready = io_pop_ready;
    always @(*) begin
        io_pop_payload_error = oneStage_buffer_payload_error;
        if (when_Stream_l1230) begin
            io_pop_payload_error = io_push_payload_error;
        end
    end

    always @(*) begin
        io_pop_payload_inst = oneStage_buffer_payload_inst;
        if (when_Stream_l1230) begin
            io_pop_payload_inst = io_push_payload_inst;
        end
    end

    assign io_occupancy = oneStage_buffer_valid;
    assign io_availability = (!oneStage_buffer_valid);
    assign when_Stream_l1230 = (!oneStage_buffer_valid);
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            io_push_rValid <= 1'b0;
        end else begin
            if (io_push_ready) begin
                io_push_rValid <= io_push_valid;
            end
            if (oneStage_doFlush) begin
                io_push_rValid <= 1'b0;
            end
        end
    end

    always @(posedge io_mainClk) begin
        if (io_push_ready) begin
            io_push_rData_error <= io_push_payload_error;
            io_push_rData_inst  <= io_push_payload_inst;
        end
    end

endmodule


module RAM #(
    // parameter INIT_FILE = "F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram_.bin",
    parameter ADDR_DEPTH = 65536
    // parameter ADDR_DEPTH = 8192
)(
    input  wire        io_bus_cmd_valid,
    output wire        io_bus_cmd_ready,
    input  wire        io_bus_cmd_payload_write,
    input  wire [31:0] io_bus_cmd_payload_address,
    input  wire [31:0] io_bus_cmd_payload_data,
    input  wire [ 3:0] io_bus_cmd_payload_mask,
    output wire        io_bus_rsp_valid,
    output wire [31:0] io_bus_rsp_payload_data,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    wire [$clog2(ADDR_DEPTH)-1:0] ram_addr1;
    wire [$clog2(ADDR_DEPTH)+1:0] ram_addr2;
    wire io_bus_cmd_fire;
    reg  io_bus_rsp_valid_reg;
    assign ram_addr1 = io_bus_cmd_payload_address[$clog2(ADDR_DEPTH)+1:2];
    assign ram_addr2 = io_bus_cmd_payload_address[$clog2(ADDR_DEPTH)+1:0];

    reg  [31:0] ram [0:ADDR_DEPTH-1];
    initial begin 
        $readmemh(INIT_FILE, ram);
    end

    reg [31:0] ram_reg;
    always @(posedge io_mainClk) 
        if (io_bus_cmd_valid && ~io_bus_cmd_payload_write) ram_reg <= ram[ram_addr1];

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1)
            always @(posedge io_mainClk) 
                if (io_bus_cmd_payload_mask[i] && io_bus_cmd_valid && io_bus_cmd_payload_write) 
                    ram[ram_addr1][8*i+7:8*i] <= io_bus_cmd_payload_data[8*i+7:8*i];
    endgenerate

    assign io_bus_cmd_fire = (io_bus_cmd_valid && io_bus_cmd_ready);
    assign io_bus_rsp_valid = io_bus_rsp_valid_reg;
    assign io_bus_rsp_payload_data = ram_reg;
    assign io_bus_cmd_ready = 1'b1;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset)
            io_bus_rsp_valid_reg <= 1'b0;
        else 
            io_bus_rsp_valid_reg <= (io_bus_cmd_fire && (!io_bus_cmd_payload_write));
    end




    // reg  [31:0] ram_spinal_port0;
    // wire [15:0] _zz_ram_port;
    // // wire [15:0] _zz_io_bus_rsp_payload_data_2;
    // wire [$clog2(ADDR_DEPTH)-1:0] _zz_io_bus_rsp_payload_data_2;
    // wire [$clog2(ADDR_DEPTH)+1:0] _zz_io_bus_rsp_payload_data_3;
    // wire        io_bus_cmd_fire;
    // reg         _zz_io_bus_rsp_valid;
    // wire [29:0] _zz_io_bus_rsp_payload_data;
    // wire [31:0] _zz_io_bus_rsp_payload_data_1;
    // reg  [ 7:0] ram_symbol0 [0:ADDR_DEPTH-1];
    // reg  [ 7:0] ram_symbol1 [0:ADDR_DEPTH-1];
    // reg  [ 7:0] ram_symbol2 [0:ADDR_DEPTH-1];
    // reg  [ 7:0] ram_symbol3 [0:ADDR_DEPTH-1];
    // reg  [ 7:0] _zz_ramsymbol_read;
    // reg  [ 7:0] _zz_ramsymbol_read_1;
    // reg  [ 7:0] _zz_ramsymbol_read_2;
    // reg  [ 7:0] _zz_ramsymbol_read_3;

    // // assign _zz_io_bus_rsp_payload_data_2 = _zz_io_bus_rsp_payload_data[15:0];
    // assign _zz_io_bus_rsp_payload_data_2 = io_bus_cmd_payload_address[$clog2(ADDR_DEPTH)+1:2];
    // assign _zz_io_bus_rsp_payload_data_3 = io_bus_cmd_payload_address[$clog2(ADDR_DEPTH)+1:0];
    // initial begin
    //     $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram0.bin", ram_symbol0);
    //     $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram1.bin", ram_symbol1);
    //     $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram2.bin", ram_symbol2);
    //     $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram3.bin", ram_symbol3);
    // end
    // always @(*) begin
    //     ram_spinal_port0 = {
    //         _zz_ramsymbol_read_3, _zz_ramsymbol_read_2, _zz_ramsymbol_read_1, _zz_ramsymbol_read
    //     };
    // end
    // always @(posedge io_mainClk) begin
    //     if (io_bus_cmd_valid) begin
    //         _zz_ramsymbol_read   <= ram_symbol0[_zz_io_bus_rsp_payload_data_2];
    //         _zz_ramsymbol_read_1 <= ram_symbol1[_zz_io_bus_rsp_payload_data_2];
    //         _zz_ramsymbol_read_2 <= ram_symbol2[_zz_io_bus_rsp_payload_data_2];
    //         _zz_ramsymbol_read_3 <= ram_symbol3[_zz_io_bus_rsp_payload_data_2];
    //     end
    // end

    // always @(posedge io_mainClk) begin
    //     if (io_bus_cmd_payload_mask[0] && io_bus_cmd_valid && io_bus_cmd_payload_write) begin
    //         ram_symbol0[_zz_io_bus_rsp_payload_data_2] <= _zz_io_bus_rsp_payload_data_1[7 : 0];
    //     end
    //     if (io_bus_cmd_payload_mask[1] && io_bus_cmd_valid && io_bus_cmd_payload_write) begin
    //         ram_symbol1[_zz_io_bus_rsp_payload_data_2] <= _zz_io_bus_rsp_payload_data_1[15 : 8];
    //     end
    //     if (io_bus_cmd_payload_mask[2] && io_bus_cmd_valid && io_bus_cmd_payload_write) begin
    //         ram_symbol2[_zz_io_bus_rsp_payload_data_2] <= _zz_io_bus_rsp_payload_data_1[23 : 16];
    //     end
    //     if (io_bus_cmd_payload_mask[3] && io_bus_cmd_valid && io_bus_cmd_payload_write) begin
    //         ram_symbol3[_zz_io_bus_rsp_payload_data_2] <= _zz_io_bus_rsp_payload_data_1[31 : 24];
    //     end
    // end

    // assign io_bus_cmd_fire = (io_bus_cmd_valid && io_bus_cmd_ready);
    // assign io_bus_rsp_valid = _zz_io_bus_rsp_valid;
    // assign _zz_io_bus_rsp_payload_data = (io_bus_cmd_payload_address >>> 2'd2);
    // assign _zz_io_bus_rsp_payload_data_1 = io_bus_cmd_payload_data;
    // assign io_bus_rsp_payload_data = ram_spinal_port0;
    // assign io_bus_cmd_ready = 1'b1;
    // always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
    //     if (resetCtrl_systemReset) begin
    //         _zz_io_bus_rsp_valid <= 1'b0;
    //     end else begin
    //         _zz_io_bus_rsp_valid <= (io_bus_cmd_fire && (!io_bus_cmd_payload_write));
    //     end
    // end

endmodule


module MasterArbiter (
    input  wire        io_iBus_cmd_valid,
    output reg         io_iBus_cmd_ready,
    input  wire [31:0] io_iBus_cmd_payload_pc,
    output wire        io_iBus_rsp_valid,
    output wire        io_iBus_rsp_payload_error,
    output wire [31:0] io_iBus_rsp_payload_inst,
    input  wire        io_dBus_cmd_valid,
    output reg         io_dBus_cmd_ready,
    input  wire        io_dBus_cmd_payload_wr,
    input  wire [ 3:0] io_dBus_cmd_payload_mask,
    input  wire [31:0] io_dBus_cmd_payload_address,
    input  wire [31:0] io_dBus_cmd_payload_data,
    input  wire [ 1:0] io_dBus_cmd_payload_size,
    output wire        io_dBus_rsp_ready,
    output wire        io_dBus_rsp_error,
    output wire [31:0] io_dBus_rsp_data,
    output reg         io_masterBus_cmd_valid,
    input  wire        io_masterBus_cmd_ready,
    output wire        io_masterBus_cmd_payload_write,
    output wire [31:0] io_masterBus_cmd_payload_address,
    output wire [31:0] io_masterBus_cmd_payload_data,
    output wire [ 3:0] io_masterBus_cmd_payload_mask,
    input  wire        io_masterBus_rsp_valid,
    input  wire [31:0] io_masterBus_rsp_payload_data,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    reg  [3:0] _zz_io_masterBus_cmd_payload_mask;
    reg        rspPending;
    reg        rspTarget;
    wire       io_masterBus_cmd_fire;
    wire       when_MuraxUtiles_l31;
    wire       when_MuraxUtiles_l36;

    always @(*) begin
        io_masterBus_cmd_valid = (io_iBus_cmd_valid || io_dBus_cmd_valid);
        if (when_MuraxUtiles_l36) begin
            io_masterBus_cmd_valid = 1'b0;
        end
    end

    assign io_masterBus_cmd_payload_write = (io_dBus_cmd_valid && io_dBus_cmd_payload_wr);
    assign io_masterBus_cmd_payload_address = (io_dBus_cmd_valid ? io_dBus_cmd_payload_address : io_iBus_cmd_payload_pc);
    assign io_masterBus_cmd_payload_data = io_dBus_cmd_payload_data;
    always @(*) begin
        case (io_dBus_cmd_payload_size)
            2'b00: begin
                _zz_io_masterBus_cmd_payload_mask = 4'b0001;
            end
            2'b01: begin
                _zz_io_masterBus_cmd_payload_mask = 4'b0011;
            end
            default: begin
                _zz_io_masterBus_cmd_payload_mask = 4'b1111;
            end
        endcase
    end

    assign io_masterBus_cmd_payload_mask = (_zz_io_masterBus_cmd_payload_mask <<< io_dBus_cmd_payload_address[1 : 0]);
    always @(*) begin
        io_iBus_cmd_ready = (io_masterBus_cmd_ready && (!io_dBus_cmd_valid));
        if (when_MuraxUtiles_l36) begin
            io_iBus_cmd_ready = 1'b0;
        end
    end

    always @(*) begin
        io_dBus_cmd_ready = io_masterBus_cmd_ready;
        if (when_MuraxUtiles_l36) begin
            io_dBus_cmd_ready = 1'b0;
        end
    end

    assign io_masterBus_cmd_fire = (io_masterBus_cmd_valid && io_masterBus_cmd_ready);
    assign when_MuraxUtiles_l31 = (io_masterBus_cmd_fire && (!io_masterBus_cmd_payload_write));
    assign when_MuraxUtiles_l36 = (rspPending && (!io_masterBus_rsp_valid));
    assign io_iBus_rsp_valid = (io_masterBus_rsp_valid && (!rspTarget));
    assign io_iBus_rsp_payload_inst = io_masterBus_rsp_payload_data;
    assign io_iBus_rsp_payload_error = 1'b0;
    assign io_dBus_rsp_ready = (io_masterBus_rsp_valid && rspTarget);
    assign io_dBus_rsp_data = io_masterBus_rsp_payload_data;
    assign io_dBus_rsp_error = 1'b0;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            rspPending <= 1'b0;
            rspTarget  <= 1'b0;
        end else begin
            if (io_masterBus_rsp_valid) begin
                rspPending <= 1'b0;
            end
            if (when_MuraxUtiles_l31) begin
                rspTarget  <= io_dBus_cmd_valid;
                rspPending <= 1'b1;
            end
        end
    end

endmodule


module Apb3Bridge (
    input  wire        io_pipelinedMemoryBus_cmd_valid,
    output wire        io_pipelinedMemoryBus_cmd_ready,
    input  wire        io_pipelinedMemoryBus_cmd_payload_write,
    input  wire [31:0] io_pipelinedMemoryBus_cmd_payload_address,
    input  wire [31:0] io_pipelinedMemoryBus_cmd_payload_data,
    input  wire [ 3:0] io_pipelinedMemoryBus_cmd_payload_mask,
    output wire        io_pipelinedMemoryBus_rsp_valid,
    output wire [31:0] io_pipelinedMemoryBus_rsp_payload_data,
    output wire [19:0] io_apb_PADDR,
    output wire [ 0:0] io_apb_PSEL,
    output wire        io_apb_PENABLE,
    input  wire        io_apb_PREADY,
    output wire        io_apb_PWRITE,
    output wire [31:0] io_apb_PWDATA,
    input  wire [31:0] io_apb_PRDATA,
    input  wire        io_apb_PSLVERROR,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    wire        pipelinedMemoryBusStage_cmd_valid;
    reg         pipelinedMemoryBusStage_cmd_ready;
    wire        pipelinedMemoryBusStage_cmd_payload_write;
    wire [31:0] pipelinedMemoryBusStage_cmd_payload_address;
    wire [31:0] pipelinedMemoryBusStage_cmd_payload_data;
    wire [ 3:0] pipelinedMemoryBusStage_cmd_payload_mask;
    reg         pipelinedMemoryBusStage_rsp_valid;
    wire [31:0] pipelinedMemoryBusStage_rsp_payload_data;
    wire        io_pipelinedMemoryBus_cmd_halfPipe_valid;
    wire        io_pipelinedMemoryBus_cmd_halfPipe_ready;
    wire        io_pipelinedMemoryBus_cmd_halfPipe_payload_write;
    wire [31:0] io_pipelinedMemoryBus_cmd_halfPipe_payload_address;
    wire [31:0] io_pipelinedMemoryBus_cmd_halfPipe_payload_data;
    wire [ 3:0] io_pipelinedMemoryBus_cmd_halfPipe_payload_mask;
    reg         io_pipelinedMemoryBus_cmd_rValid;
    wire        io_pipelinedMemoryBus_cmd_halfPipe_fire;
    reg         io_pipelinedMemoryBus_cmd_rData_write;
    reg  [31:0] io_pipelinedMemoryBus_cmd_rData_address;
    reg  [31:0] io_pipelinedMemoryBus_cmd_rData_data;
    reg  [ 3:0] io_pipelinedMemoryBus_cmd_rData_mask;
    reg         pipelinedMemoryBusStage_rsp_regNext_valid;
    reg  [31:0] pipelinedMemoryBusStage_rsp_regNext_payload_data;
    reg         state;
    wire        when_PipelinedMemoryBus_l369;

    assign io_pipelinedMemoryBus_cmd_halfPipe_fire = (io_pipelinedMemoryBus_cmd_halfPipe_valid && io_pipelinedMemoryBus_cmd_halfPipe_ready);
    assign io_pipelinedMemoryBus_cmd_ready = (!io_pipelinedMemoryBus_cmd_rValid);
    assign io_pipelinedMemoryBus_cmd_halfPipe_valid = io_pipelinedMemoryBus_cmd_rValid;
    assign io_pipelinedMemoryBus_cmd_halfPipe_payload_write = io_pipelinedMemoryBus_cmd_rData_write;
    assign io_pipelinedMemoryBus_cmd_halfPipe_payload_address = io_pipelinedMemoryBus_cmd_rData_address;
    assign io_pipelinedMemoryBus_cmd_halfPipe_payload_data = io_pipelinedMemoryBus_cmd_rData_data;
    assign io_pipelinedMemoryBus_cmd_halfPipe_payload_mask = io_pipelinedMemoryBus_cmd_rData_mask;
    assign pipelinedMemoryBusStage_cmd_valid = io_pipelinedMemoryBus_cmd_halfPipe_valid;
    assign io_pipelinedMemoryBus_cmd_halfPipe_ready = pipelinedMemoryBusStage_cmd_ready;
    assign pipelinedMemoryBusStage_cmd_payload_write = io_pipelinedMemoryBus_cmd_halfPipe_payload_write;
    assign pipelinedMemoryBusStage_cmd_payload_address = io_pipelinedMemoryBus_cmd_halfPipe_payload_address;
    assign pipelinedMemoryBusStage_cmd_payload_data = io_pipelinedMemoryBus_cmd_halfPipe_payload_data;
    assign pipelinedMemoryBusStage_cmd_payload_mask = io_pipelinedMemoryBus_cmd_halfPipe_payload_mask;
    assign io_pipelinedMemoryBus_rsp_valid = pipelinedMemoryBusStage_rsp_regNext_valid;
    assign io_pipelinedMemoryBus_rsp_payload_data = pipelinedMemoryBusStage_rsp_regNext_payload_data;
    always @(*) begin
        pipelinedMemoryBusStage_cmd_ready = 1'b0;
        if (!when_PipelinedMemoryBus_l369) begin
            if (io_apb_PREADY) begin
                pipelinedMemoryBusStage_cmd_ready = 1'b1;
            end
        end
    end

    assign io_apb_PSEL[0] = pipelinedMemoryBusStage_cmd_valid;
    assign io_apb_PENABLE = state;
    assign io_apb_PWRITE  = pipelinedMemoryBusStage_cmd_payload_write;
    assign io_apb_PADDR   = pipelinedMemoryBusStage_cmd_payload_address[19:0];
    assign io_apb_PWDATA  = pipelinedMemoryBusStage_cmd_payload_data;
    always @(*) begin
        pipelinedMemoryBusStage_rsp_valid = 1'b0;
        if (!when_PipelinedMemoryBus_l369) begin
            if (io_apb_PREADY) begin
                pipelinedMemoryBusStage_rsp_valid = (!pipelinedMemoryBusStage_cmd_payload_write);
            end
        end
    end

    assign pipelinedMemoryBusStage_rsp_payload_data = io_apb_PRDATA;
    assign when_PipelinedMemoryBus_l369 = (!state);
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            io_pipelinedMemoryBus_cmd_rValid <= 1'b0;
            pipelinedMemoryBusStage_rsp_regNext_valid <= 1'b0;
            state <= 1'b0;
        end else begin
            if (io_pipelinedMemoryBus_cmd_valid) begin
                io_pipelinedMemoryBus_cmd_rValid <= 1'b1;
            end
            if (io_pipelinedMemoryBus_cmd_halfPipe_fire) begin
                io_pipelinedMemoryBus_cmd_rValid <= 1'b0;
            end
            pipelinedMemoryBusStage_rsp_regNext_valid <= pipelinedMemoryBusStage_rsp_valid;
            if (when_PipelinedMemoryBus_l369) begin
                state <= pipelinedMemoryBusStage_cmd_valid;
            end else begin
                if (io_apb_PREADY) begin
                    state <= 1'b0;
                end
            end
        end
    end

    always @(posedge io_mainClk) begin
        if (io_pipelinedMemoryBus_cmd_ready) begin
            io_pipelinedMemoryBus_cmd_rData_write <= io_pipelinedMemoryBus_cmd_payload_write;
            io_pipelinedMemoryBus_cmd_rData_address <= io_pipelinedMemoryBus_cmd_payload_address;
            io_pipelinedMemoryBus_cmd_rData_data <= io_pipelinedMemoryBus_cmd_payload_data;
            io_pipelinedMemoryBus_cmd_rData_mask <= io_pipelinedMemoryBus_cmd_payload_mask;
        end
        pipelinedMemoryBusStage_rsp_regNext_payload_data <= pipelinedMemoryBusStage_rsp_payload_data;
    end

endmodule


module Apb3PRouter (
    input  wire [19:0] io_input_PADDR,
    input  wire [ 0:0] io_input_PSEL,
    input  wire        io_input_PENABLE,
    output reg         io_input_PREADY,
    input  wire        io_input_PWRITE,
    input  wire [31:0] io_input_PWDATA,
    output wire [31:0] io_input_PRDATA,
    output reg         io_input_PSLVERROR,

    // GPIO
    output wire [19:0] io_outputs_0_PADDR,
    output wire [ 0:0] io_outputs_0_PSEL,
    output wire        io_outputs_0_PENABLE,
    input  wire        io_outputs_0_PREADY,
    output wire        io_outputs_0_PWRITE,
    output wire [31:0] io_outputs_0_PWDATA,
    input  wire [31:0] io_outputs_0_PRDATA,
    input  wire        io_outputs_0_PSLVERROR,
    // WDG
    output wire [19:0] io_outputs_1_PADDR,
    output wire [ 0:0] io_outputs_1_PSEL,
    output wire        io_outputs_1_PENABLE,
    input  wire        io_outputs_1_PREADY,
    output wire        io_outputs_1_PWRITE,
    output wire [31:0] io_outputs_1_PWDATA,
    input  wire [31:0] io_outputs_1_PRDATA,
    input  wire        io_outputs_1_PSLVERROR,
    // USART
    output wire [19:0] io_outputs_2_PADDR,
    output wire [ 0:0] io_outputs_2_PSEL,
    output wire        io_outputs_2_PENABLE,
    input  wire        io_outputs_2_PREADY,
    output wire        io_outputs_2_PWRITE,
    output wire [31:0] io_outputs_2_PWDATA,
    input  wire [31:0] io_outputs_2_PRDATA,
    input  wire        io_outputs_2_PSLVERROR,
    // I2C
    output wire [19:0] io_outputs_3_PADDR,
    output wire [ 0:0] io_outputs_3_PSEL,
    output wire        io_outputs_3_PENABLE,
    input  wire        io_outputs_3_PREADY,
    output wire        io_outputs_3_PWRITE,
    output wire [31:0] io_outputs_3_PWDATA,
    input  wire [31:0] io_outputs_3_PRDATA,
    input  wire        io_outputs_3_PSLVERROR,
    // SPI
    output wire [19:0] io_outputs_4_PADDR,
    output wire [ 0:0] io_outputs_4_PSEL,
    output wire        io_outputs_4_PENABLE,
    input  wire        io_outputs_4_PREADY,
    output wire        io_outputs_4_PWRITE,
    output wire [31:0] io_outputs_4_PWDATA,
    input  wire [31:0] io_outputs_4_PRDATA,
    input  wire        io_outputs_4_PSLVERROR,
    // TIM
    output wire [19:0] io_outputs_5_PADDR,
    output wire [ 0:0] io_outputs_5_PSEL,
    output wire        io_outputs_5_PENABLE,
    input  wire        io_outputs_5_PREADY,
    output wire        io_outputs_5_PWRITE,
    output wire [31:0] io_outputs_5_PWDATA,
    input  wire [31:0] io_outputs_5_PRDATA,
    input  wire        io_outputs_5_PSLVERROR,

    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    wire when_Apb3Decoder_l88;
    reg         _zz_io_input_PREADY;
    reg  [31:0] _zz_io_input_PRDATA;
    reg         _zz_io_input_PSLVERROR;
    reg  [15:0] selIndex;
    reg  [15:0] Apb3PSEL;

    always @(*) begin
        if (resetCtrl_systemReset) begin
            Apb3PSEL <= 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_input_PADDR[19:16] == 4'd0) && io_input_PSEL[0]);
            Apb3PSEL[1] = ((io_input_PADDR[19:16] == 4'd1) && io_input_PSEL[0]);
            Apb3PSEL[2] = ((io_input_PADDR[19:16] == 4'd2) && io_input_PSEL[0]);
            Apb3PSEL[3] = ((io_input_PADDR[19:16] == 4'd3) && io_input_PSEL[0]);  // GPIO
            Apb3PSEL[4] = ((io_input_PADDR[19:16] == 4'd4) && io_input_PSEL[0]);  // WDG
            Apb3PSEL[5] = ((io_input_PADDR[19:16] == 4'd5) && io_input_PSEL[0]);  // USART
            Apb3PSEL[6] = ((io_input_PADDR[19:16] == 4'd6) && io_input_PSEL[0]);  // I2C
            Apb3PSEL[7] = ((io_input_PADDR[19:16] == 4'd7) && io_input_PSEL[0]);  // SPI
            Apb3PSEL[8] = ((io_input_PADDR[19:16] == 4'd8) && io_input_PSEL[0]);  // TIM
        end
    end

    always @(*) begin
        io_input_PREADY = _zz_io_input_PREADY;
        if (when_Apb3Decoder_l88) begin
            io_input_PREADY = 1'b1;
        end
    end

    assign io_input_PRDATA = _zz_io_input_PRDATA;
    always @(*) begin
        io_input_PSLVERROR = _zz_io_input_PSLVERROR;
        if (when_Apb3Decoder_l88) begin
            io_input_PSLVERROR = 1'b1;
        end
    end

    assign when_Apb3Decoder_l88 = (io_input_PSEL[0] && (Apb3PSEL == 16'h0000));




    always @(posedge io_mainClk) selIndex <= Apb3PSEL;
    always @(*) begin
        if (resetCtrl_systemReset) begin
            _zz_io_input_PREADY <= 1'b1;
            _zz_io_input_PRDATA <= 32'h0;
            _zz_io_input_PSLVERROR <= 1'b0;
        end
        else
            case (selIndex)
                16'h0008: begin
                    _zz_io_input_PREADY = io_outputs_0_PREADY;
                    _zz_io_input_PRDATA = io_outputs_0_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_0_PSLVERROR;
                end
                16'h0010: begin
                    _zz_io_input_PREADY = io_outputs_1_PREADY;
                    _zz_io_input_PRDATA = io_outputs_1_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_1_PSLVERROR;
                end
                16'h0020: begin
                    _zz_io_input_PREADY = io_outputs_2_PREADY;
                    _zz_io_input_PRDATA = io_outputs_2_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_2_PSLVERROR;
                end
                16'h0040: begin
                    _zz_io_input_PREADY = io_outputs_3_PREADY;
                    _zz_io_input_PRDATA = io_outputs_3_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_3_PSLVERROR;
                end
                16'h0080: begin
                    _zz_io_input_PREADY = io_outputs_4_PREADY;
                    _zz_io_input_PRDATA = io_outputs_4_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_4_PSLVERROR;
                end
                16'h0100: begin
                    _zz_io_input_PREADY = io_outputs_5_PREADY;
                    _zz_io_input_PRDATA = io_outputs_5_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_5_PSLVERROR;
                end
                default: ;
            endcase
    end

    // GPIO
    assign io_outputs_0_PADDR = io_input_PADDR;
    assign io_outputs_0_PENABLE = io_input_PENABLE;
    assign io_outputs_0_PSEL = Apb3PSEL[3];
    assign io_outputs_0_PWRITE = io_input_PWRITE;
    assign io_outputs_0_PWDATA = io_input_PWDATA;
    // WDG
    assign io_outputs_1_PADDR = io_input_PADDR;
    assign io_outputs_1_PENABLE = io_input_PENABLE;
    assign io_outputs_1_PSEL = Apb3PSEL[4];
    assign io_outputs_1_PWRITE = io_input_PWRITE;
    assign io_outputs_1_PWDATA = io_input_PWDATA;
    // USART
    assign io_outputs_2_PADDR = io_input_PADDR;
    assign io_outputs_2_PENABLE = io_input_PENABLE;
    assign io_outputs_2_PSEL = Apb3PSEL[5];
    assign io_outputs_2_PWRITE = io_input_PWRITE;
    assign io_outputs_2_PWDATA = io_input_PWDATA;
    // I2C
    assign io_outputs_3_PADDR = io_input_PADDR;
    assign io_outputs_3_PENABLE = io_input_PENABLE;
    assign io_outputs_3_PSEL = Apb3PSEL[6];
    assign io_outputs_3_PWRITE = io_input_PWRITE;
    assign io_outputs_3_PWDATA = io_input_PWDATA;
    // SPI
    assign io_outputs_4_PADDR = io_input_PADDR;
    assign io_outputs_4_PENABLE = io_input_PENABLE;
    assign io_outputs_4_PSEL = Apb3PSEL[7];
    assign io_outputs_4_PWRITE = io_input_PWRITE;
    assign io_outputs_4_PWDATA = io_input_PWDATA;
    // TIM
    assign io_outputs_5_PADDR = io_input_PADDR;
    assign io_outputs_5_PENABLE = io_input_PENABLE;
    assign io_outputs_5_PSEL = Apb3PSEL[8];
    assign io_outputs_5_PWRITE = io_input_PWRITE;
    assign io_outputs_5_PWDATA = io_input_PWDATA;

endmodule


module Apb3GPIORouter (
    input  wire        io_apb_PCLK,
    input  wire        io_apb_PRESET,
    input  wire [15:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire [31:0] io_apb_PRDATA,
    output wire        io_apb_PSLVERROR,

    input wire [15:0] AFIOA,
    inout wire [15:0] GPIOA,
    input wire [15:0] AFIOB,
    inout wire [15:0] GPIOB
);

    reg  [15:0] Apb3PSEL = 16'h0000;
    // GPIOA
    wire [ 2:0] io_apb_PADDR_GPIOA = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_GPIOA = Apb3PSEL[0];
    wire        io_apb_PENABLE_GPIOA = io_apb_PENABLE;
    wire        io_apb_PREADY_GPIOA;
    wire        io_apb_PWRITE_GPIOA = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_GPIOA = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_GPIOA;
    wire        io_apb_PSLVERROR_GPIOA = 1'b0;
    // GPIOB
    wire [ 2:0] io_apb_PADDR_GPIOB = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_GPIOB = Apb3PSEL[1];
    wire        io_apb_PENABLE_GPIOB = io_apb_PENABLE;
    wire        io_apb_PREADY_GPIOB;
    wire        io_apb_PWRITE_GPIOB = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_GPIOB = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_GPIOB;
    wire        io_apb_PSLVERROR_GPIOB = 1'b0;

    reg [15:0] selIndex;
    reg        _zz_io_apb_PREADY;
    reg [31:0] _zz_io_apb_PRDATA;
    reg        _zz_io_apb_PSLVERROR;
    assign io_apb_PREADY = _zz_io_apb_PREADY;
    assign io_apb_PRDATA = _zz_io_apb_PRDATA;
    assign io_apb_PSLVERROR = _zz_io_apb_PSLVERROR;
    always @(posedge io_apb_PCLK) selIndex <= Apb3PSEL;
    always @(*) begin
        if (io_apb_PRESET) begin
            _zz_io_apb_PREADY <= 1'b1;
            _zz_io_apb_PRDATA <= 32'h0;
            _zz_io_apb_PSLVERROR <= 1'b0;
        end
        else
            case (selIndex)
                16'h0001: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_GPIOA;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_GPIOA;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_GPIOA;
                end
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_GPIOB;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_GPIOB;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_GPIOB;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL = 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // GPIOA
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // GPIOB
        end
    end

    Apb3GPIO Apb3GPIOA (
        .io_apb_PCLK   (io_apb_PCLK),           // i
        .io_apb_PRESET (io_apb_PRESET),         // i
        .io_apb_PADDR  (io_apb_PADDR_GPIOA),    // i
        .io_apb_PSEL   (io_apb_PSEL_GPIOA),     // i
        .io_apb_PENABLE(io_apb_PENABLE_GPIOA),  // i
        .io_apb_PREADY (io_apb_PREADY_GPIOA),   // o
        .io_apb_PWRITE (io_apb_PWRITE_GPIOA),   // i
        .io_apb_PWDATA (io_apb_PWDATA_GPIOA),   // i
        .io_apb_PRDATA (io_apb_PRDATA_GPIOA),   // o
        .AFIO          (AFIOA),                 // i
        .GPIO          (GPIOA)                  // o
    );

    Apb3GPIO Apb3GPIOB (
        .io_apb_PCLK   (io_apb_PCLK),           // i
        .io_apb_PRESET (io_apb_PRESET),         // i
        .io_apb_PADDR  (io_apb_PADDR_GPIOB),    // i
        .io_apb_PSEL   (io_apb_PSEL_GPIOB),     // i
        .io_apb_PENABLE(io_apb_PENABLE_GPIOB),  // i
        .io_apb_PREADY (io_apb_PREADY_GPIOB),   // o
        .io_apb_PWRITE (io_apb_PWRITE_GPIOB),   // i
        .io_apb_PWDATA (io_apb_PWDATA_GPIOB),   // i
        .io_apb_PRDATA (io_apb_PRDATA_GPIOB),   // o
        .AFIO          (AFIOB),                 // i
        .GPIO          (GPIOB)                  // o
    );

endmodule


module Apb3GPIO (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 2:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    input wire [15:0] AFIO,  // 复用IO引脚
    inout wire [15:0] GPIO   // 双向IO引脚
);

    // GPIO寄存器定义
    reg [31:0] CRL;  // 控制寄存器低字（控制低8个引脚）
    reg [31:0] CRH;  // 控制寄存器高字（控制高8个引脚）
    reg [15:0] IDR;  // 输入数据寄存器 只有低16位有效
    reg [15:0] ODR;  // 输出数据寄存器 只有低16位有效
    reg [15:0] BSR;  // 位设置/复位寄存器 只有低16位有效
    reg [15:0] BRR;  // 位复位寄存器 只有低16位有效
    reg [15:0] LCKR;  // 锁定寄存器 只有低16位有效

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CRL  <= 32'h00000000;
            CRH  <= 32'h00000000;
            BSR  <= 16'h0000;
            BRR  <= 16'h0000;
            LCKR <= 16'h0000;
        end else begin
            BSR <= 16'h0000;  // 复位位设置寄存器
            BRR <= 16'h0000;  // 复位位设置/复位寄存器
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                // 写寄存器
                case (io_apb_PADDR)  // 假设基地址为0x00，寄存器偏移4字节
                    3'b000:  CRL <= io_apb_PWDATA;  // CRL（控制低8个引脚）
                    3'b001:  CRH <= io_apb_PWDATA;  // CRH（控制高8个引脚）
                    3'b100:  BSR <= io_apb_PWDATA[15:0];  // BSR: 不读取 写入后马上复位
                    3'b101:  BRR <= io_apb_PWDATA[15:0];  // BRR: 不读取 写入后马上复位
                    3'b110:  LCKR <= io_apb_PWDATA[15:0];  // LCKR  // TODO: 未实现
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) io_apb_PRDATA = 32'h00000000;
        else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
            case (io_apb_PADDR)
                3'b000:  io_apb_PRDATA = CRL;  // 读 CRL
                3'b001:  io_apb_PRDATA = CRH;  // 读 CRH
                3'b010:  io_apb_PRDATA = {16'h0000, IDR};  // 读 IDR
                3'b011:  io_apb_PRDATA = {16'h0000, ODR};  // 读 ODR
                3'b110:  io_apb_PRDATA = {16'h0000, LCKR};  // 读 LCKR
                default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
            endcase
        end
    end


    // GPIO 的 inout 双向控制逻辑
    wire [15:0] gpio_dir;  // 用于控制每个引脚的输入/输出方向，1为输出，0为输入
    wire [63:0] gpio_ctrl = {CRH, CRL};  // 控制寄存器的低字和高字合并
    generate
        genvar i;
        for (i = 0; i < 16; i = i + 1) begin
            assign GPIO[i] = ODR[i];
            assign gpio_dir[i] = (gpio_ctrl[i*4+:2] == 2'b00) ? 1'b0 : 1'b1;  // gpio_ctrl[i*4+:2]==MODE 输入模式时gpio_dir为0，输出模式时gpio_dir为1
            // always @(*) begin
            always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
                if (io_apb_PRESET) ODR[i] <= 1'bz;
                else if (gpio_dir[i]) begin  // 输出模式
                    IDR[i] <= 1'bz;  // 输出模式时IDR为高阻态
                    if (gpio_ctrl[i*4+3]) begin  // 复用 IO 引脚
                        ODR[i] <= AFIO[i] ? 1'b1 : (gpio_ctrl[i*4+2] ? 1'bz : 1'b0);  // 输出类型为推挽时，输出为0，否则为高阻态
                    end else begin  // 普通 IO 引脚
                        if (BSR[i]) ODR[i] <= 1'b1;
                        if (BRR[i])
                            ODR[i] <= gpio_ctrl[i*4+2] ? 1'bz : 1'b0;  // 输出类型为推挽时，输出为0，否则为高阻态
                    end
                end else begin
                    IDR[i] <= GPIO[i];  // 输入模式时读取GPIO值
                    ODR[i] <= 1'bz;  // 输入模式时GPIO为高阻态
                end
            end

            // assign GPIO[i] = (gpio_dir[i]) ? ODR[i] : 1'bz; // 输出时为gpio_out，否则为高阻态
            // always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
            //     if (io_apb_PRESET) IDR[i] <= 1'bz;  // 默认所有引脚为高阻态
            //     else if (~gpio_dir[i]) IDR[i] <= GPIO[i];  // 输入模式时读取GPIO值
            // end
            // assign gpio_dir[i] = (gpio_ctrl[i*4+:2] == 2'b00) ? 1'b0 : 1'b1;  // gpio_ctrl[i*4+:2]==MODE 输入模式时gpio_dir为0，输出模式时gpio_dir为1
            // always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
            //     if (io_apb_PRESET) begin
            //         ODR[i] <= 1'bz;  // 默认所有引脚为高阻态
            //     // end else if ((BSR[i] | BRR[i]) & gpio_dir[i]) begin
            //     //     case (gpio_ctrl[i*4+3])  // gpio_ctrl[i*4+3]==MODE[1]
            //     //         1'b0: begin
            //     //             if (BSR[i]) ODR[i] <= 1'b1;
            //     //             else if (BRR[i])
            //     //                 ODR[i] <= gpio_ctrl[i*4+2] ? 1'bz : 1'b0;  // 输出类型为推挽时，输出为0，否则为高阻态
            //     //         end
            //     //         default: begin
            //     //             if (AFIO[i]) ODR[i] <= 1'b1;
            //     //             else
            //     //                 ODR[i] <= gpio_ctrl[i*4+2] ? 1'bz : 1'b0;  // 输出类型为推挽时，输出为0，否则为高阻态
            //     //         end
            //     //     endcase
            //     // end
            //     end else begin
            //         if (gpio_ctrl[i*4+3]) begin  // 复用 IO 引脚
            //             ODR[i] <= AFIO[i] ? 1'b1 : (gpio_ctrl[i*4+2] ? 1'bz : 1'b0);  // 输出类型为推挽时，输出为0，否则为高阻态
            //         end else begin  // 普通 IO 引脚
            //             if (BSR[i]) ODR[i] <= 1'b1;
            //             if (BRR[i]) ODR[i] <= gpio_ctrl[i*4+2] ? 1'bz : 1'b0;  // 输出类型为推挽时，输出为0，否则为高阻态
            //         end
            //     end
            // end
        end
    endgenerate

endmodule

// TODO: Buffer模块


module Apb3I2CRouter (
    input  wire        io_apb_PCLK,
    input  wire        io_apb_PRESET,
    input  wire [15:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire [31:0] io_apb_PRDATA,
    output wire        io_apb_PSLVERROR,

    input  wire I2C1_SDA,
    output wire I2C1_SCL,
    output wire I2C1_interrupt,
    input  wire I2C2_SDA,
    output wire I2C2_SCL,
    output wire I2C2_interrupt
);

    reg  [15:0] Apb3PSEL = 16'h0000;
    // I2C1
    wire [ 3:0] io_apb_PADDR_I2C1 = io_apb_PADDR[5:2];
    wire        io_apb_PSEL_I2C1 = Apb3PSEL[0];
    wire        io_apb_PENABLE_I2C1 = io_apb_PENABLE;
    wire        io_apb_PREADY_I2C1;
    wire        io_apb_PWRITE_I2C1 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_I2C1 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_I2C1;
    wire        io_apb_PSLVERROR_I2C1 = 1'b0;
    // I2C2
    wire [ 3:0] io_apb_PADDR_I2C2 = io_apb_PADDR[5:2];
    wire        io_apb_PSEL_I2C2 = Apb3PSEL[1];
    wire        io_apb_PENABLE_I2C2 = io_apb_PENABLE;
    wire        io_apb_PREADY_I2C2;
    wire        io_apb_PWRITE_I2C2 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_I2C2 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_I2C2;
    wire        io_apb_PSLVERROR_I2C2 = 1'b0;

    reg [15:0] selIndex;
    reg        _zz_io_apb_PREADY;
    reg [31:0] _zz_io_apb_PRDATA;
    reg        _zz_io_apb_PSLVERROR;
    assign io_apb_PREADY = _zz_io_apb_PREADY;
    assign io_apb_PRDATA = _zz_io_apb_PRDATA;
    assign io_apb_PSLVERROR = _zz_io_apb_PSLVERROR;
    always @(posedge io_apb_PCLK) selIndex <= Apb3PSEL;
    always @(*) begin
        if (io_apb_PRESET) begin
            _zz_io_apb_PREADY <= 1'b1;
            _zz_io_apb_PRDATA <= 32'h0;
            _zz_io_apb_PSLVERROR <= 1'b0;
        end
        else
            case (selIndex)
                16'h0001: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_I2C1;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_I2C1;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_I2C1;
                end
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_I2C2;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_I2C2;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_I2C2;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL = 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // I2C1
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // I2C2
        end
    end

    Apb3I2C Apb3I2C1 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_I2C1),    // i
        .io_apb_PSEL   (io_apb_PSEL_I2C1),     // i
        .io_apb_PENABLE(io_apb_PENABLE_I2C1),  // i
        .io_apb_PREADY (io_apb_PREADY_I2C1),   // o
        .io_apb_PWRITE (io_apb_PWRITE_I2C1),   // i
        .io_apb_PWDATA (io_apb_PWDATA_I2C1),   // i
        .io_apb_PRDATA (io_apb_PRDATA_I2C1),   // o
        .I2C_SDA       (I2C1_SDA),             // i
        .I2C_SCL       (I2C1_SCL),             // o
        .interrupt     (I2C1_interrupt)        // o
    );

    Apb3I2C Apb3I2C2 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_I2C2),    // i
        .io_apb_PSEL   (io_apb_PSEL_I2C2),     // i
        .io_apb_PENABLE(io_apb_PENABLE_I2C2),  // i
        .io_apb_PREADY (io_apb_PREADY_I2C2),   // o
        .io_apb_PWRITE (io_apb_PWRITE_I2C2),   // i
        .io_apb_PWDATA (io_apb_PWDATA_I2C2),   // i
        .io_apb_PRDATA (io_apb_PRDATA_I2C2),   // o
        .I2C_SDA       (I2C2_SDA),             // i
        .I2C_SCL       (I2C2_SCL),             // o
        .interrupt     (I2C1_interrupt)        // o
    );

endmodule


module Apb3I2C (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 3:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    // I2C 接口信号
    input  wire I2C_SDA,   // I2C 数据线
    inout  wire I2C_SCL,   // I2C 时钟线
    output wire interrupt  // I2C 中断输出
);

    // I2C 寄存器定义
    reg  [15:0] CR1;  // 控制寄存器1
    reg  [15:0] CR2;  // 控制寄存器2
    reg  [15:0] OAR1;  // 地址寄存器1
    reg  [15:0] OAR2;  // 地址寄存器2
    reg  [15:0] DR;  // 数据寄存器
    wire [15:0] SR1;  // 状态寄存器1
    wire [15:0] SR2;  // 状态寄存器2
    reg  [15:0] CCR;  // 时钟控制寄存器
    reg  [15:0] TRISE;  // 上升时间寄存器

    // I2C 中断输出
    assign interrupt = 1'b0;  // 未实现中断输出

    // I2C Config 接口定义
    // CR1
    wire       PE = CR1[0];  // I2C 使能
    wire       START = CR1[8];  // 启动条件产生
    wire       STOP = CR1[9];  // 停止条件产生
    wire       ACK = CR1[10];  // 应答使能
    // CR2
    wire       ITERREN = CR2[8];  // 出错中断使能
    wire       ITEVTEN = CR2[9];  // 事件中断使能
    wire       ITBUFEN = CR2[10];  // 缓冲区中断使能
    wire       DMAEN = CR2[11];  // DMA 使能
    // OAR1
    wire [6:0] ADD_7 = OAR1[7:1];  // 7位 从机地址
    wire [9:0] ADD_10 = OAR1[9:0];  // 10位 从机地址
    wire       ADDMODE = OAR1[15];  // 地址模式
    // SR1
    reg        SB = 1'b0;  // 起始位(主模式)
    wire       ADDR = 1'b0;  // 地址已被发送(主模式)/地址匹配(从模式)
    wire       BTF = 1'b0;  // 字节发送结束
    wire       ADD10 = 1'b0;  // 10位头序列已发送(主模式)
    wire       STOPF = 1'b0;  // 停止条件检测位(从模式)
    wire       RXNE = 1'b0;  // 数据寄存器非空(接收时)
    wire       TXE = 1'b0;  // 数据寄存器为空(发送时)
    wire       BERR = 1'b0;  // 总线出错
    wire       ARLO = 1'b0;  // 仲裁丢失(主模式)
    wire       AF = 1'b0;  // 应答失败
    wire       OVR = 1'b0;  // 过载/欠载
    wire       PECERR = 1'b0;  // 在接收时发生PEC错误
    wire       TMOUT = 1'b0;  // 超时或Tlow错误
    wire       SMBALERT = 1'b0;  // SMBus 提醒
    assign     SR1 = {SMBALERT, TMOUT, 1'b0, PECERR, OVR, AF, ARLO, BERR, TXE, RXNE, 1'b0, STOPF, ADD10, BTF, ADDR, SB};  // 状态寄存器1
    // SR2
    wire       MSL = 1'b0;  // 主从模式
    wire       BUSY = 1'b0;  // 总线忙
    wire       TRA = 1'b0;  // 发送/接收
    wire       GENCALL = 1'b0;  // 广播呼叫地址(从模式)
    wire       SMBDEFAULT = 1'b0;  // SMB 默认
    wire       SMBHOST = 1'b0;  // SMB 主机
    wire       DUALF = 1'b0;  // 双工模式
    wire [7:0] PEC = 1'b0;  // 错误校验位
    assign     SR2 = {PEC, DUALF, SMBHOST, SMBDEFAULT, GENCALL, 1'b0, TRA, BUSY, MSL};  // 状态寄存器2

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR1 <= 16'h0000;
            CR2 <= 16'h0000;
            OAR1 <= 16'h0000;
            OAR2 <= 16'h0000;
            DR <= 16'h0000;
            CCR <= 16'h0000;
            TRISE <= 16'h0000;
            SB <= 1'b0;
        end else begin
            CR1[8] <= 1'b0;  // 启动条件清除
            CR1[9] <= 1'b0;  // 停止条件清除
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    4'h0: CR1 <= io_apb_PWDATA[15:0];
                    4'h1: CR2 <= io_apb_PWDATA[15:0];
                    4'h2: OAR1 <= io_apb_PWDATA[15:0];
                    4'h3: OAR2 <= io_apb_PWDATA[15:0];
                    4'h4: DR <= io_apb_PWDATA[15:0];
                    4'h7: CCR <= io_apb_PWDATA[15:0];
                    4'h8: TRISE <= io_apb_PWDATA[15:0];
                    default: ;  // 其他寄存器不处理
                endcase
            end
            if (io_apb_PSEL)
                SB <= 1'b1;  // 已发送出起始条件
            if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE && io_apb_PADDR == 4'h5)
                SB <= 1'b0;
        end
    end

    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) begin
            io_apb_PRDATA = 32'h00000000;  // 复位时返回0
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    4'h0: io_apb_PRDATA <= {16'b0, CR1};
                    4'h1: io_apb_PRDATA <= {16'b0, CR2};
                    4'h2: io_apb_PRDATA <= {16'b0, OAR1};
                    4'h3: io_apb_PRDATA <= {16'b0, OAR2};
                    4'h4: io_apb_PRDATA <= {16'b0, DR};
                    4'h5: io_apb_PRDATA <= {16'b0, SR1};
                    4'h6: io_apb_PRDATA <= {16'b0, SR2};
                    4'h7: io_apb_PRDATA <= {16'b0, CCR};
                    4'h8: io_apb_PRDATA <= {16'b0, TRISE};
                    default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end

    // I2C 收发逻辑

endmodule


// module I2CCtrl(
//     input wire clk,               // 时钟信号
//     input wire rst_n,             // 复位信号，低电平有效
//     input wire start,             // 启动信号
//     input wire [6:0] dev_addr,    // 从设备7位地址
//     input wire [7:0] reg_addr,    // 寄存器地址
//     input wire [7:0] data_in,     // 要写入的数据
//     output reg sda,               // I2C数据线
//     output reg scl,               // I2C时钟线
//     output reg busy,              // 表示模块是否忙碌
//     output reg done,              // 表示传输是否完成
//     output reg [7:0] flags        // 标志位输出
// );

//     // 定义 I2C 状态机的状态
//     typedef enum reg [3:0] {
//         IDLE,         // 空闲状态
//         START,        // 生成起始条件
//         ADDR,         // 发送设备地址
//         ADDR_ACK,     // 检查ADDR应答（ACK）
//         REG_ADDR,     // 发送寄存器地址
//         REG_ADDR_ACK, // 检查寄存器地址ACK
//         DATA,         // 发送数据
//         DATA_ACK,     // 检查数据ACK
//         STOP,         // 生成停止条件
//         DONE          // 完成状态
//     } state_t;

//     state_t state, next_state;

//     // I2C 信号控制
//     reg [7:0] bit_counter;        // 位计数器，用于跟踪发送的位数
//     reg scl_out;                  // 用于驱动 SCL 的寄存器
//     reg sda_out;                  // 用于驱动 SDA 的寄存器

//     // I2C 时钟分频
//     reg [15:0] clk_div;           // 时钟分频器，用于生成 SCL 时钟
//     reg scl_enable;               // 控制 SCL 的时钟
//     reg [7:0] flags_reg;          // 状态标志寄存器（模拟 STM32 中的标志）

//     // 将 sda 和 scl 信号分别连接到外部信号
//     assign sda = sda_out;
//     assign scl = scl_out;

//     // 定义标志位
//     localparam BUSY = 1;  // 总线忙标志
//     localparam MSL = 2;   // 主模式标志
//     localparam SB = 4;    // 起始条件标志
//     localparam ADDR = 8;  // 地址发送完成标志
//     localparam TXE = 16;  // 数据寄存器空标志
//     localparam TRA = 32;  // 传输状态标志
//     localparam BTF = 64;  // 数据传输完成标志
//     localparam RXNE = 128;// 接收寄存器非空标志

//     // I2C 时钟分频，假设SCL频率为100kHz
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             clk_div <= 16'd0;
//             scl_enable <= 1'b0;
//         end else begin
//             if (clk_div == 16'd5000) begin
//                 clk_div <= 16'd0;
//                 scl_enable <= 1'b1;
//             end else begin
//                 clk_div <= clk_div + 1'b1;
//                 scl_enable <= 1'b0;
//             end
//         end
//     end

//     // 状态机的状态切换
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             state <= IDLE;
//         end else if (scl_enable) begin
//             state <= next_state;
//         end
//     end

//     // 根据当前状态计算下一个状态
//     always @(*) begin
//         case (state)
//             IDLE: begin
//                 if (start) begin
//                     next_state = START;
//                 end else begin
//                     next_state = IDLE;
//                 end
//             end

//             START: begin
//                 next_state = ADDR;
//             end

//             ADDR: begin
//                 if (bit_counter == 7) begin
//                     next_state = ADDR_ACK;
//                 end else begin
//                     next_state = ADDR;
//                 end
//             end

//             ADDR_ACK: begin
//                 if (flags_reg[ADDR]) begin
//                     next_state = REG_ADDR;
//                 end else begin
//                     next_state = IDLE; // 错误处理
//                 end
//             end

//             REG_ADDR: begin
//                 if (bit_counter == 7) begin
//                     next_state = REG_ADDR_ACK;
//                 end else begin
//                     next_state = REG_ADDR;
//                 end
//             end

//             REG_ADDR_ACK: begin
//                 if (flags_reg[TXE]) begin
//                     next_state = DATA;
//                 end else begin
//                     next_state = IDLE; // 错误处理
//                 end
//             end

//             DATA: begin
//                 if (bit_counter == 7) begin
//                     next_state = DATA_ACK;
//                 end else begin
//                     next_state = DATA;
//                 end
//             end

//             DATA_ACK: begin
//                 if (flags_reg[BTF]) begin
//                     next_state = STOP;
//                 end else begin
//                     next_state = IDLE; // 错误处理
//                 end
//             end

//             STOP: begin
//                 next_state = DONE;
//             end

//             DONE: begin
//                 next_state = IDLE;
//             end

//             default: begin
//                 next_state = IDLE;
//             end
//         endcase
//     end

//     // 控制输出信号和标志位
//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) begin
//             sda_out <= 1'b1;
//             scl_out <= 1'b1;
//             flags_reg <= 8'd0;
//             busy <= 1'b0;
//             done <= 1'b0;
//             bit_counter <= 8'd0;
//         end else if (scl_enable) begin
//             case (state)
//                 IDLE: begin
//                     sda_out <= 1'b1;
//                     scl_out <= 1'b1;
//                     busy <= 1'b0;
//                     done <= 1'b0;
//                     flags_reg[BUSY] <= 1'b0;
//                 end

//                 START: begin
//                     sda_out <= 1'b0;  // SDA 拉低，生成起始条件
//                     scl_out <= 1'b1;
//                     busy <= 1'b1;     // 设置忙标志
//                     flags_reg[BUSY] <= 1'b1;   // 总线忙
//                     flags_reg[MSL] <= 1'b1;    // 主模式
//                     flags_reg[SB] <= 1'b1;     // 起始条件
//                 end

//                 ADDR: begin
//                     scl_out <= 1'b0;  // SCL 拉低，准备发送设备地址
//                     sda_out <= dev_addr[7 - bit_counter]; // 发送设备地址
//                     bit_counter <= bit_counter + 1'b1;
//                     flags_reg[TRA] <= 1'b1;    // 传输模式
//                 end

//                 ADDR_ACK: begin
//                     scl_out <= 1'b1;  // SCL 拉高，等待 ACK
//                     if (/* 检测到ACK */) begin
//                         flags_reg[ADDR] <= 1'b1; // 地址传输完成
//                     end
//                 end

//                 REG_ADDR: begin
//                     scl_out <= 1'b0;
//                     sda_out <= reg_addr[7 - bit_counter]; // 发送寄存器地址
//                     bit_counter <= bit_counter + 1'b1;
//                 end

//                 REG_ADDR_ACK: begin
//                     scl_out <= 1'b1;  // SCL 拉高，等待 ACK
//                     if (/* 检测到ACK */) begin
//                         flags_reg[TXE] <= 1'b1; // 数据寄存器为空，准备发送数据
//                     end
//                 end

//                 DATA: begin
//                     scl_out <= 1'b0;
//                     sda_out <= data_in[7 - bit_counter]; // 发送数据
//                     bit_counter <= bit_counter + 1'b1;
//                 end

//                 DATA_ACK: begin
//                     scl_out <= 1'b1;  // SCL 拉高，等待数据传输完成
//                     if (/* 检测到BTF */) begin
//                         flags_reg[BTF] <= 1'b1; // 数据传输完成
//                     end
//                 end

//                 STOP: begin
//                     sda_out <= 1'b0;  // SDA 拉低，准备停止
//                     scl_out <= 1'b1;  // SCL 拉高，生成停止条件
//                     flags_reg[TRA] <= 1'b0;    // 传输结束
//                 end

//                 DONE: begin
//                     sda_out <= 1'b1; // 停止条件，SDA 拉高
//                     scl_out <= 1'b1;
//                     busy <= 1'b0;
//                     done <= 1'b1;
//                     flags_reg <= 8'd0; // 清除所有标志
//                 end
//             endcase
//         end
//     end

//     // 将标志寄存器输出到外部
//     assign flags = flags_reg;

// endmodule

module Apb3RCC (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 2:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    // RCC 接口信号
    output wire interrupt  // RCC 中断输出
);

    // RCC 寄存器定义
    wire [15:0] SR;  // 状态寄存器
    reg  [15:0] DR;  // 数据寄存器
    reg  [15:0] BRR;  // 波特率寄存器
    reg  [15:0] CR1;  // 控制寄存器1
    reg  [15:0] CR2;  // 控制寄存器2
    reg  [15:0] CR3;  // 控制寄存器3  暂时不支持流控制和其他高级功能
    reg  [15:0] GTPR;  // 保护时间和预分频寄存器  暂时不支持

    // RCC StreamFifo 接口定义
    wire       io_push_ready_TX;
    reg        io_push_valid_TX;
    reg  [7:0] io_push_payload_TX;
    wire       io_pop_ready_TX;
    wire       io_pop_valid_TX;
    wire [7:0] io_pop_payload_TX;
    wire [4:0] io_availability_TX;
    wire [4:0] io_occupancy_TX;
    wire       io_push_ready_RX;
    wire       io_push_valid_RX;
    wire [7:0] io_push_payload_RX;
    reg        io_pop_ready_RX;
    wire       io_pop_valid_RX;
    wire [7:0] io_pop_payload_RX;
    wire [4:0] io_availability_RX;
    wire [4:0] io_occupancy_RX;

    // RCC Config 接口定义
    // SR
    wire        PE   = 1'b0;  // 校验错误
    wire        FE   = 1'b0;  // 帧错误
    wire        NF   = 1'b0;  // 噪声错误标志
    wire        ORE  = 1'b0;  // 过载错误
    wire        IDLE = 1'b0;  // 监测到总线空闲
    wire        RXNE = io_occupancy_RX ? 1'b1 : 1'b0;  // 读数据寄存器非空
    wire        TC   = io_availability_TX ? 1'b1 : 1'b0;  // (发送完成) 改为写数据寄存器有空闲
    wire        TXE  = 1'b0;  // 发送数据寄存器空
    wire        LBD  = 1'b0;  // LIN断开检测标志
    wire        CTS  = 1'b0;  // CTS 标志
    assign      SR   = {6'b0, CTS, LBD, TXE, TC, RXNE, IDLE, ORE, NF, FE, PE};
    // CR1
    wire        RE     = CR1[2];
    wire        TE     = CR1[3];
    wire        IDLEIE = CR1[4];
    wire        RXNEIE = CR1[5];
    wire        TCIE   = CR1[6];
    wire        TXEIE  = CR1[7];
    wire        PEIE   = CR1[8];
    wire        PS     = CR1[9];
    wire        PCE    = CR1[10];
    wire [ 2:0] M      = CR1[12] ? 3'b000 : 3'b111;
    wire        UE     = CR1[13];
    // CR2
    wire [ 1:0] STOP = CR2[13:12];
    // CR3
    wire        DMAT = CR3[7];
    wire        DMAR = CR3[6];
    // BRR
    wire [11:0] DIV_Mantissa = BRR[15:4];
    wire [ 3:0] DIV_Fraction = BRR[ 3:0];

    // RCC 状态寄存器
    wire        io_readError;
    wire        io_writeBreak = 1'b0;
    wire        io_readBreak;

    // RCC 中断输出
    assign interrupt = (PEIE & PE) | (TCIE & TC) | (RXNEIE & RXNE) | (TXEIE & TXE) | (IDLEIE & IDLE);

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            // SR   <= 16'h0000;
            DR   <= 16'h0000;
            BRR  <= 16'h0000;
            CR1  <= 16'h0000;
            CR2  <= 16'h0000;
            CR3  <= 16'h0000;
            GTPR <= 16'h0000;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    // 3'b000:  SR <= io_apb_PWDATA[15:0];  // 写 SR  // 暂时不可写入
                    3'b001:  DR <= io_apb_PWDATA[15:0];  // 写 DR
                    3'b010:  BRR <= io_apb_PWDATA[15:0];  // 写 BRR
                    3'b011:  CR1 <= io_apb_PWDATA[15:0];  // 写 CR1
                    3'b100:  CR2 <= io_apb_PWDATA[15:0];  // 写 CR2
                    3'b101:  CR3 <= io_apb_PWDATA[15:0];  // 写 CR3
                    3'b110:  GTPR <= io_apb_PWDATA[15:0];  // 写 GTPR
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) begin
            io_apb_PRDATA = 32'h00000000;  // 复位时返回0
            io_pop_ready_RX = 1'b0;
        end
        else begin
            io_pop_ready_RX = 1'b0;
            if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    3'b000:  io_apb_PRDATA = {16'b0, SR};  // 读 SR
                    3'b001:  begin 
                        io_apb_PRDATA = io_pop_valid_RX ? {16'b0, io_pop_payload_RX} : 32'h00000000;  // 读
                        io_pop_ready_RX = 1'b1;
                    end
                    3'b010:  io_apb_PRDATA = {16'b0, BRR};  // 读 BRR
                    3'b011:  io_apb_PRDATA = {16'b0, CR1};  // 读 CR1
                    3'b100:  io_apb_PRDATA = {16'b0, CR2};  // 读 CR2
                    3'b101:  io_apb_PRDATA = {16'b0, CR3};  // 读 CR3
                    3'b110:  io_apb_PRDATA = {16'b0, GTPR};  // 读 GTPR
                    default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end

    // 时钟、复位逻辑

endmodule



module Apb3SPIRouter (
    input  wire        io_apb_PCLK,
    input  wire        io_apb_PRESET,
    input  wire [15:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire [31:0] io_apb_PRDATA,
    output wire        io_apb_PSLVERROR,

    output wire SPI1_SCK,
    output wire SPI1_MOSI,
    input  wire SPI1_MISO,
    output wire SPI1_CS,
    output wire SPI1_interrupt,
    output wire SPI2_SCK,
    output wire SPI2_MOSI,
    input  wire SPI2_MISO,
    output wire SPI2_CS,
    output wire SPI2_interrupt
);

    reg  [15:0] Apb3PSEL = 16'h0000;
    // SPI1
    wire [ 3:0] io_apb_PADDR_SPI1 = io_apb_PADDR[5:2];
    wire        io_apb_PSEL_SPI1 = Apb3PSEL[0];
    wire        io_apb_PENABLE_SPI1 = io_apb_PENABLE;
    wire        io_apb_PREADY_SPI1;
    wire        io_apb_PWRITE_SPI1 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_SPI1 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_SPI1;
    wire        io_apb_PSLVERROR_SPI1 = 1'b0;
    // SPI2
    wire [ 3:0] io_apb_PADDR_SPI2 = io_apb_PADDR[5:2];
    wire        io_apb_PSEL_SPI2 = Apb3PSEL[1];
    wire        io_apb_PENABLE_SPI2 = io_apb_PENABLE;
    wire        io_apb_PREADY_SPI2;
    wire        io_apb_PWRITE_SPI2 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_SPI2 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_SPI2;
    wire        io_apb_PSLVERROR_SPI2 = 1'b0;

    reg [15:0] selIndex;
    reg        _zz_io_apb_PREADY;
    reg [31:0] _zz_io_apb_PRDATA;
    reg        _zz_io_apb_PSLVERROR;
    assign io_apb_PREADY = _zz_io_apb_PREADY;
    assign io_apb_PRDATA = _zz_io_apb_PRDATA;
    assign io_apb_PSLVERROR = _zz_io_apb_PSLVERROR;
    always @(posedge io_apb_PCLK) selIndex <= Apb3PSEL;
    always @(*) begin
        if (io_apb_PRESET) begin
            _zz_io_apb_PREADY <= 1'b1;
            _zz_io_apb_PRDATA <= 32'h0;
            _zz_io_apb_PSLVERROR <= 1'b0;
        end
        else
            case (selIndex)
                16'h0001: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_SPI1;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_SPI1;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_SPI1;
                end
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_SPI2;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_SPI2;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_SPI2;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL = 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // SPI1
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // SPI2
        end
    end

    Apb3SPI Apb3SPI1 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_SPI1),    // i
        .io_apb_PSEL   (io_apb_PSEL_SPI1),     // i
        .io_apb_PENABLE(io_apb_PENABLE_SPI1),  // i
        .io_apb_PREADY (io_apb_PREADY_SPI1),   // o
        .io_apb_PWRITE (io_apb_PWRITE_SPI1),   // i
        .io_apb_PWDATA (io_apb_PWDATA_SPI1),   // i
        .io_apb_PRDATA (io_apb_PRDATA_SPI1),   // o
        .SPI_SCK       (SPI1_SCK),             // o
        .SPI_MOSI      (SPI1_MOSI),            // o
        .SPI_MISO      (SPI1_MISO),            // i
        .SPI_CS        (SPI1_CS),              // o
        .interrupt     (SPI1_interrupt)        // o
    );

    Apb3SPI Apb3SPI2 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_SPI2),    // i
        .io_apb_PSEL   (io_apb_PSEL_SPI2),     // i
        .io_apb_PENABLE(io_apb_PENABLE_SPI2),  // i
        .io_apb_PREADY (io_apb_PREADY_SPI2),   // o
        .io_apb_PWRITE (io_apb_PWRITE_SPI2),   // i
        .io_apb_PWDATA (io_apb_PWDATA_SPI2),   // i
        .io_apb_PRDATA (io_apb_PRDATA_SPI2),   // o
        .SPI_SCK       (SPI2_SCK),             // o
        .SPI_MOSI      (SPI2_MOSI),            // o
        .SPI_MISO      (SPI2_MISO),            // i
        .SPI_CS        (SPI2_CS),              // o
        .interrupt     (SPI2_interrupt)        // o
    );

endmodule


module Apb3SPI (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 3:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    // SPI 接口信号
    output wire SPI_SCK,   // SPI 时钟
    output wire SPI_MOSI,  // SPI 主输出从输入
    input  wire SPI_MISO,  // SPI 主输入从输出
    output wire SPI_CS,    // SPI 片选信号
    output wire interrupt  // SPI 中断输出
);

    // SPI 寄存器定义
    reg  [15:0] CR1;                  // 控制寄存器1
    reg  [15:0] CR2;                  // 控制寄存器2
    wire [15:0] SR;                   // 状态寄存器
    reg  [15:0] DR;                   // 数据寄存器
    reg  [15:0] CRCPR;                // CRC 寄存器
    wire [15:0] RXCRCR = 16'h0000;    // 接收 CRC 寄存器
    wire [15:0] TXCRCR = 16'h0000;    // 发送 CRC 寄存器
    reg  [15:0] I2SCFGR;              // I2S 配置寄存器
    reg  [15:0] I2SPR;                // I2S 预分频寄存器

    // SPI Config 接口定义
    // CR1
    wire        CPHA = CR1[0];  // 时钟相位
    wire        CPOL = CR1[1];  // 时钟极性
    wire        MSTR = CR1[2];  // 主设备选择
    wire [ 2:0] BR = CR1[5:3];  // 波特率控制
    wire        SPE = CR1[6];   // SPI使能
    wire        LSBFIRST = CR1[7];  // 帧格式  0：先发送MSB；1：先发送LSB。
    wire        SSI = CR1[8];   // 内部从设备选择
    wire        SSM = CR1[9];   // 软件从设备管理
    wire        RXONLY = CR1[10];  // 只接收
    wire        DFF = CR1[11];  // 数据帧格式  0：8位数据帧格式； 1：16位数据帧格式。
    wire        CRCNEXT = CR1[12];  // 下一个发送CRC
    wire        CRCEN = CR1[13];  // 硬件CRC校验使能
    wire        BIDIOE = CR1[14];  // 双向模式下的输出使能
    wire        BIDIMODE = CR1[14];  // 双向数据模式使能
    // CR2
    wire        RXDMAEN = CR2[0];  // 接收缓冲区DMA使能
    wire        TXDMAEN = CR2[1];  // 发送缓冲区DMA使能
    wire        SSOE = CR2[2];   // SS输出使能
    wire        ERRIE = CR2[5];  // 错误中断使能
    wire        RXNEIE = CR2[6];  // 接收缓冲区非空中断使能
    wire        TXEIE = CR2[7];   // 发送缓冲区空中断使能
    // SR
    wire        RXNE = 1'b0;    // 接收缓冲非空
    wire        TXE = 1'b1;     // 发送缓冲为空
    // wire        TXE;     // 发送缓冲为空
    wire        CHSIDE = 1'b0;  // 声道
    wire        UDR = 1'b0;     // 下溢标志位
    wire        CRCERR = 1'b0;  // CRC错误标志
    wire        MODF = 1'b0;    // 模式错误
    wire        OVR = 1'b0;     // 溢出标志
    wire        BSY = 1'b0;     // 忙标志
    assign      SR = {8'b0, BSY, OVR, MODF, CRCERR, UDR, CHSIDE, TXE, RXNE};  // 状态寄存器

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 总线始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR1     <= 16'h0000;
            CR2     <= 16'h0000;
            DR      <= 16'h0000;
            CRCPR   <= 16'h0000;
            I2SCFGR <= 16'h0000;
            I2SPR   <= 16'h0000;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    4'h0: CR1 <= io_apb_PWDATA[15:0];  // 写 CR1
                    4'h1: CR2 <= io_apb_PWDATA[15:0];  // 写 CR2
                    4'h3: DR <= io_apb_PWDATA[15:0];  // 写 DR
                    4'h4: CRCPR <= io_apb_PWDATA[15:0];  // 写 CRCPR
                    4'h7: I2SCFGR <= io_apb_PWDATA[15:0];  // 写 I2SCFGR
                    4'h8: I2SPR <= io_apb_PWDATA[15:0];  // 写 I2SPR
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end

    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) begin
            io_apb_PRDATA = 32'h00000000;  // 复位时返回0
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    4'h0: io_apb_PRDATA <= {16'b0, CR1};
                    4'h1: io_apb_PRDATA <= {16'b0, CR2};
                    4'h2: io_apb_PRDATA <= {16'b0, SR};
                    4'h3: io_apb_PRDATA <= {16'b0, DR};
                    4'h4: io_apb_PRDATA <= {16'b0, CRCPR};
                    4'h5: io_apb_PRDATA <= {16'b0, RXCRCR};
                    4'h6: io_apb_PRDATA <= {16'b0, TXCRCR};
                    4'h7: io_apb_PRDATA <= {16'b0, I2SCFGR};
                    4'h8: io_apb_PRDATA <= {16'b0, I2SPR};
                    default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end

    // 发送 SPI 接口定义
    reg TX_Vaild = 1'b0;
    always @(posedge io_apb_PCLK)
        TX_Vaild <= io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE && io_apb_PADDR == 4'h3;

    // SPI 逻辑
    SPICtrl SPICtrl (
        .clk       (io_apb_PCLK),
        .rst       (io_apb_PRESET),
        .CPOL      (CPOL),
        .CPHA      (CPHA),
        .BR        (BR),
        .DFF       (DFF),
        .LSBFIRST  (LSBFIRST),

        .i_TX_Byte (DR),
        .i_TX_Vaild(TX_Vaild),
        .o_TX_Ready(),
        .o_RX_Vaild(),
        .o_RX_Byte (),

        .o_SPI_SCK (SPI_SCK),
        .i_SPI_MISO(SPI_MISO),
        .o_SPI_MOSI(SPI_MOSI),
        .o_SPI_CS  (SPI_CS)
    );

endmodule


module SPICtrl (
    // Control / Data Signals
    input clk,  // FPGA Clock
    input rst,  // FPGA Reset

    // SPI Config Signals
    input       CPOL,     // Clock Polarity
    input       CPHA,     // Clock Phase
    input [2:0] BR,       // Baud Rate
    input       DFF,      // Data Frame Format
    input       LSBFIRST, // Bit First Config

    // TX (MOSI) Signals
    input      [15:0] i_TX_Byte,   // Byte to transmit on MOSI
    input             i_TX_Vaild,  // Data Valid Pulse with i_TX_Byte
    output reg        o_TX_Ready,  // Transmit Ready for next byte

    // RX (MISO) Signals
    output reg        o_RX_Vaild,  // Data Valid pulse (1 clock cycle)
    output reg [15:0] o_RX_Byte,   // Byte received on MISO

    // SPI Interface
    output reg o_SPI_SCK,
    input      i_SPI_MISO,
    output reg o_SPI_MOSI,
    output reg o_SPI_CS = 1'b0
);

    // CPOL: Clock Polarity
    // CPOL=0 means clock idles at 0, leading edge is rising edge.
    // CPOL=1 means clock idles at 1, leading edge is falling edge.
    // CPHA: Clock Phase
    // CPHA=0 means the "out" side changes the data on trailing edge of clock
    //              the "in" side captures data on leading edge of clock
    // CPHA=1 means the "out" side changes the data on leading edge of clock
    //              the "in" side captures data on the trailing edge of clock

    // SPI Interface (All Runs at SPI Clock Domain)
    reg [7:0] r_SPI_clk_Count, HALF_BIT;  // 000:2 001:4 010:8 011:16 100:32 101:64 110:128 111:256
    reg        r_SPI_clk;
    reg [ 4:0] r_SPI_clk_Edges;
    reg        r_Leading_Edge;
    reg        r_Trailing_Edge;
    reg        r_TX_DV;
    reg [15:0] r_TX_Byte;
    reg [ 3:0] r_RX_Bit_Count;
    reg [ 3:0] r_TX_Bit_Count;

    // HALF_BIT: Number of clock cycles for half bit time.
    always @* begin
        case (BR)
            3'b000: HALF_BIT = 8'b00000001;
            3'b001: HALF_BIT = 8'b00000010;
            3'b010: HALF_BIT = 8'b00000100;
            3'b011: HALF_BIT = 8'b00001000;
            3'b100: HALF_BIT = 8'b00010000;
            3'b101: HALF_BIT = 8'b00100000;
            3'b110: HALF_BIT = 8'b01000000;
            3'b111: HALF_BIT = 8'b10000000;
        endcase
    end

    // Purpose: Generate SPI Clock correct number of times when DV pulse comes
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_TX_Ready      <= 1'b0;
            r_SPI_clk_Edges <= 0;
            r_Leading_Edge  <= 1'b0;
            r_Trailing_Edge <= 1'b0;
            r_SPI_clk       <= CPOL;  // assign default state to idle state
            r_SPI_clk_Count <= 0;
        end else begin
            // Default assignments
            r_Leading_Edge  <= 1'b0;
            r_Trailing_Edge <= 1'b0;
            if (i_TX_Vaild) begin
                o_TX_Ready      <= 1'b0;
                r_SPI_clk_Edges <= 16;  // Total # edges in one byte ALWAYS 16
            end else if (r_SPI_clk_Edges > 0) begin
                o_TX_Ready <= 1'b0;
                if (r_SPI_clk_Count == HALF_BIT * 2 - 1) begin
                    r_SPI_clk_Edges <= r_SPI_clk_Edges - 1'b1;
                    r_Trailing_Edge <= 1'b1;
                    r_SPI_clk_Count <= 0;
                    r_SPI_clk       <= ~r_SPI_clk;
                end else if (r_SPI_clk_Count == HALF_BIT - 1) begin
                    r_SPI_clk_Edges <= r_SPI_clk_Edges - 1'b1;
                    r_Leading_Edge  <= 1'b1;
                    r_SPI_clk_Count <= r_SPI_clk_Count + 1'b1;
                    r_SPI_clk       <= ~r_SPI_clk;
                end else begin
                    r_SPI_clk_Count <= r_SPI_clk_Count + 1'b1;
                end
            end else o_TX_Ready <= 1'b1;
        end
    end

    // Purpose: Register i_TX_Byte when Data Valid is pulsed.
    // Keeps local storage of byte in case higher level module changes the data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_TX_Byte <= 16'h0000;
            r_TX_DV   <= 1'b0;
        end else begin
            r_TX_DV <= i_TX_Vaild;  // 1 clock cycle delay
            if (i_TX_Vaild) r_TX_Byte <= i_TX_Byte;
        end  // else: !if(~rst_n)
    end  // always @ (posedge clk or negedge rst_n)

    // Purpose: Generate MOSI data
    // Works with both CPHA=0 and CPHA=1
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_SPI_MOSI <= 1'b0;
            if (LSBFIRST) r_TX_Bit_Count <= 4'b0000;  // send LSB first
            else r_TX_Bit_Count <= DFF ? 4'b1111 : 4'b0111;  // send MSB first  // 16位 : 8位
        end else begin
            // If ready is high, reset bit counts to default
            if (o_TX_Ready) begin
                if (LSBFIRST) r_TX_Bit_Count <= 4'b0000;  // send LSB first
                else r_TX_Bit_Count <= DFF ? 4'b1111 : 4'b0111;  // send MSB first
            end else if (r_TX_DV & ~CPHA) begin
                o_SPI_MOSI     <= r_TX_Byte[r_TX_Bit_Count];
                r_TX_Bit_Count <= LSBFIRST ? r_TX_Bit_Count + 1'b1 : r_TX_Bit_Count - 1'b1;
            end else if ((r_Leading_Edge & CPHA) | (r_Trailing_Edge & ~CPHA)) begin
                r_TX_Bit_Count <= LSBFIRST ? r_TX_Bit_Count + 1'b1 : r_TX_Bit_Count - 1'b1;
                o_SPI_MOSI     <= r_TX_Byte[r_TX_Bit_Count];
            end
        end
    end

    // Purpose: Read in MISO data.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_RX_Byte  <= 8'h00;
            o_RX_Vaild <= 1'b0;
            if (LSBFIRST) r_RX_Bit_Count <= 4'b0000;  // recv LSB first
            else r_RX_Bit_Count <= DFF ? 4'b1111 : 4'b0111;  // recv MSB first  // 16位 : 8位
        end else begin
            // Default Assignments
            o_RX_Vaild <= 1'b0;
            if (o_TX_Ready) begin  // Check if ready is high, if so reset bit count to default
                if (LSBFIRST) r_RX_Bit_Count <= 4'b0000;  // recv LSB first
                else r_RX_Bit_Count <= DFF ? 4'b1111 : 4'b0111;  // recv MSB first  // 16位 : 8位
            end else if ((r_Leading_Edge & ~CPHA) | (r_Trailing_Edge & CPHA)) begin
                o_RX_Byte[r_RX_Bit_Count] <= i_SPI_MISO;  // Sample data
                r_RX_Bit_Count <= LSBFIRST ? r_RX_Bit_Count + 1'b1 : r_RX_Bit_Count - 1'b1;
                o_RX_Vaild <= LSBFIRST ? (DFF ? 4'b1111 : 4'b0111) : 4'b0000;  // Byte done, pulse Data Valid
            end
        end
    end

    // Purpose: Add clock delay to signals for alignment.
    always @(posedge clk or posedge rst) begin
        if (rst) o_SPI_SCK <= CPOL;
        else o_SPI_SCK <= r_SPI_clk;
    end

endmodule  // SPI_Master


module Apb3TIMRouter (
    input  wire        io_apb_PCLK,
    input  wire        io_apb_PRESET,
    input  wire [15:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire [31:0] io_apb_PRDATA,
    output wire        io_apb_PSLVERROR,

    output wire [3:0] TIM2_CH,
    output wire       TIM2_interrupt,
    output wire [3:0] TIM3_CH,
    output wire       TIM3_interrupt
);

    reg  [15:0] Apb3PSEL = 16'h0000;
    // TIM2
    wire [ 4:0] io_apb_PADDR_TIM2 = io_apb_PADDR[6:2];
    wire        io_apb_PSEL_TIM2 = Apb3PSEL[1];
    wire        io_apb_PENABLE_TIM2 = io_apb_PENABLE;
    wire        io_apb_PREADY_TIM2;
    wire        io_apb_PWRITE_TIM2 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_TIM2 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_TIM2;
    wire        io_apb_PSLVERROR_TIM2 = 1'b0;
    // TIM3
    wire [ 4:0] io_apb_PADDR_TIM3 = io_apb_PADDR[6:2];
    wire        io_apb_PSEL_TIM3 = Apb3PSEL[2];
    wire        io_apb_PENABLE_TIM3 = io_apb_PENABLE;
    wire        io_apb_PREADY_TIM3;
    wire        io_apb_PWRITE_TIM3 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_TIM3 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_TIM3;
    wire        io_apb_PSLVERROR_TIM3 = 1'b0;

    reg [15:0] selIndex;
    reg        _zz_io_apb_PREADY;
    reg [31:0] _zz_io_apb_PRDATA;
    reg        _zz_io_apb_PSLVERROR;
    assign io_apb_PREADY = _zz_io_apb_PREADY;
    assign io_apb_PRDATA = _zz_io_apb_PRDATA;
    assign io_apb_PSLVERROR = _zz_io_apb_PSLVERROR;
    always @(posedge io_apb_PCLK) selIndex <= Apb3PSEL;
    always @(*) begin
        if (io_apb_PRESET) begin
            _zz_io_apb_PREADY <= 1'b1;
            _zz_io_apb_PRDATA <= 32'h0;
            _zz_io_apb_PSLVERROR <= 1'b0;
        end
        else
            case (selIndex)
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_TIM2;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_TIM2;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_TIM2;
                end
                16'h0004: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_TIM3;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_TIM3;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_TIM3;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL = 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // TIM1
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // TIM2
            Apb3PSEL[2] = ((io_apb_PADDR[15:12] == 4'd2) && io_apb_PSEL[0]);  // TIM3
        end
    end

    Apb3TIM Apb3TIM2 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_TIM2),    // i
        .io_apb_PSEL   (io_apb_PSEL_TIM2),     // i
        .io_apb_PENABLE(io_apb_PENABLE_TIM2),  // i
        .io_apb_PREADY (io_apb_PREADY_TIM2),   // o
        .io_apb_PWRITE (io_apb_PWRITE_TIM2),   // i
        .io_apb_PWDATA (io_apb_PWDATA_TIM2),   // i
        .io_apb_PRDATA (io_apb_PRDATA_TIM2),   // o
        .TIM_CH        (TIM2_CH),              // o
        .interrupt     (TIM2_interrupt)        // o
    );

    Apb3TIM Apb3TIM3 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_TIM3),    // i
        .io_apb_PSEL   (io_apb_PSEL_TIM3),     // i
        .io_apb_PENABLE(io_apb_PENABLE_TIM3),  // i
        .io_apb_PREADY (io_apb_PREADY_TIM3),   // o
        .io_apb_PWRITE (io_apb_PWRITE_TIM3),   // i
        .io_apb_PWDATA (io_apb_PWDATA_TIM3),   // i
        .io_apb_PRDATA (io_apb_PRDATA_TIM3),   // o
        .TIM_CH        (TIM3_CH),              // o
        .interrupt     (TIM3_interrupt)        // o
    );

endmodule


module Apb3TIM (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 4:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    output wire [ 3:0] TIM_CH,    // TIM 通道输出
    output wire        interrupt  // TIM 中断输出
);

    // TIM 寄存器定义
    reg [15:0] CR1;  // 控制寄存器1
    reg [15:0] CR2;  // 控制寄存器2
    reg [15:0] SMCR;  // 从模式控制寄存器
    reg [15:0] DIER;  // DMA/中断使能寄存器
    reg [15:0] SR;  // 状态寄存器
    reg [15:0] EGR;  // 事件生成寄存器
    reg [15:0] CCMR1;  // 捕获/比较模式寄存器1
    reg [15:0] CCMR2;  // 捕获/比较模式寄存器2
    reg [15:0] CCER;  // 捕获/比较使能寄存器
    reg [15:0] CNT;  // 计数器
    reg [15:0] PSC;  // 预分频器
    reg [15:0] ARR;  // 自动重装载寄存器
    reg [15:0] RCR;  // 重装载寄存器
    reg [15:0] CCR1;  // 捕获/比较寄存器1
    reg [15:0] CCR2;  // 捕获/比较寄存器2
    reg [15:0] CCR3;  // 捕获/比较寄存器3
    reg [15:0] CCR4;  // 捕获/比较寄存器4
    reg [15:0] BDTR;  // 刹车和死区寄存器
    reg [15:0] DCR;  // DMA 控制寄存器
    reg [15:0] DMAR;  // DMA 地址寄存器

    // TIM Config 接口定义
    // CR1
    wire        CEN = CR1[0];  // 使能计数器
    wire        DIR = CR1[4];  // 方向  0：计数器向上计数；1：计数器向下计数。
    wire [ 1:0] CMS = CR1[6:5];  // 选择中央对齐模式
    wire        ARPE = CR1[7];  // 自动重装载预装载允许位
    wire [ 1:0] CKD = CR1[9:8];  // 时钟分频因子
    // CR2
    wire [ 2:0] MMS = CR2[6:4];  // 主输出模式
    // DIER
    wire        UIE = DIER[0];  // 允许更新中断
    wire        CC1IE = DIER[1];  // 允许捕获/比较1中断
    wire        CC2IE = DIER[2];  // 允许捕获/比较2中断
    wire        CC3IE = DIER[3];  // 允许捕获/比较3中断
    wire        CC4IE = DIER[4];  // 允许捕获/比较4中断
    wire        TIE = DIER[6];  // 触发中断使能
    // SR
    wire        UIF = SR[0];  // 更新中断标志
    wire        CC1IF = SR[1];  // 捕获/比较1中断标志
    wire        CC2IF = SR[2];  // 捕获/比较2中断标志
    wire        CC3IF = SR[3];  // 捕获/比较3中断标志
    wire        CC4IF = SR[4];  // 捕获/比较4中断标志
    wire        TIF = SR[6];  // 触发中断标志

    // TIM 中断输出
    assign interrupt = (UIE & UIF);  // 更新中断

    // 定时器逻辑寄存器
    reg [15:0] prescaler_counter;  // 用于实现预分频的计数器
    reg [ 1:0] clk_div_counter;  // 用于实现时钟分频的计数器

    // APB 写寄存器逻辑  && 定时器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR1 <= 16'h0000;
            CR2 <= 16'h0000;
            SMCR <= 16'h0000;
            DIER <= 16'h0000;
            SR <= 16'h0000;
            EGR <= 16'h0000;
            CCMR1 <= 16'h0000;
            CCMR2 <= 16'h0000;
            CCER <= 16'h0000;
            CNT <= 16'h0000;
            PSC <= 16'h0000;
            ARR <= 16'hFFFF;
            RCR <= 16'h0000;
            CCR1 <= 16'h0000;
            CCR2 <= 16'h0000;
            CCR3 <= 16'h0000;
            CCR4 <= 16'h0000;
            BDTR <= 16'h0000;
            DCR <= 16'h0000;
            DMAR <= 16'h0000;
            prescaler_counter <= 16'h0000;
            clk_div_counter   <= 2'b00;
        end else begin
            // APB 写寄存器逻辑
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) 
                case (io_apb_PADDR)
                    5'd00:   CR1 <= io_apb_PWDATA[15:0];  // 写 CR1
                    5'd01:   CR2 <= io_apb_PWDATA[15:0];  // 写 CR2
                    5'd02:   SMCR <= io_apb_PWDATA[15:0];  // 写 SMCR
                    5'd03:   DIER <= io_apb_PWDATA[15:0];  // 写 DIER
                    5'd04:   SR <= io_apb_PWDATA[15:0];  // 写 SR
                    5'd05:   EGR <= io_apb_PWDATA[15:0];  // 写 EGR
                    5'd06:   CCMR1 <= io_apb_PWDATA[15:0];  // 写 CCMR1
                    5'd07:   CCMR2 <= io_apb_PWDATA[15:0];  // 写 CCMR2
                    5'd08:   CCER <= io_apb_PWDATA[15:0];  // 写 CCER
                    5'd09:   CNT <= io_apb_PWDATA[15:0];  // 写 CNT
                    5'd10:   PSC <= io_apb_PWDATA[15:0];  // 写 PSC
                    5'd11:   ARR <= io_apb_PWDATA[15:0];  // 写 ARR
                    5'd12:   RCR <= io_apb_PWDATA[15:0];  // 写 CCR1
                    5'd13:   CCR1 <= io_apb_PWDATA[15:0];  // 写 CCR1
                    5'd14:   CCR2 <= io_apb_PWDATA[15:0];  // 写 CCR2
                    5'd15:   CCR3 <= io_apb_PWDATA[15:0];  // 写 CCR3
                    5'd16:   CCR4 <= io_apb_PWDATA[15:0];  // 写 CCR4
                    5'd17:   BDTR <= io_apb_PWDATA[15:0];  // 写 BDTR
                    5'd18:   DCR <= io_apb_PWDATA[15:0];  // 写 DCR
                    5'd19:   DMAR <= io_apb_PWDATA[15:0];  // 写 DMAR
                    default: ;  // 其他寄存器不处理
                endcase
            // 计数器逻辑
            if (CEN) begin
                // 时钟分频逻辑 (CKD)
                case (CKD)
                    2'b00:  // 不进行时钟分频，直接使用时钟
                        clk_div_counter <= 2'b00;
                    2'b01:  // tDTS = 2 x tCK_INT
                        clk_div_counter <= (clk_div_counter == 2'b01) ? 2'b00 : clk_div_counter + 1'b1;
                    2'b10:  // tDTS = 4 x tCK_INT
                        clk_div_counter <= (clk_div_counter == 2'b11) ? 2'b00 : clk_div_counter + 1'b1;
                endcase
                // 预分频逻辑 (PSC)
                if (prescaler_counter == PSC) begin
                    prescaler_counter <= 16'h0000;  // 当计数达到预分频器值时，重置计数器
                    if (clk_div_counter == 2'b00 || CKD == 2'b00)
                        if (CNT == ARR) begin
                            CNT <= 16'h0000;    // 当计数器达到自动重装载值时，重置计数器
                            SR[0] <= 1'b1;  // 设置更新中断标志位
                        end else
                            CNT <= CNT + 1'b1;
                end else prescaler_counter <= prescaler_counter + 1'b1;
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) begin
            io_apb_PRDATA = 32'h00000000;  // 复位时返回0
        end else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
            case (io_apb_PADDR)
                5'd00:   io_apb_PRDATA = {16'b0, CR1};  // 读 CR1
                5'd01:   io_apb_PRDATA = {16'b0, CR2};  // 读 CR2
                5'd02:   io_apb_PRDATA = {16'b0, SMCR};  // 读 SMCR
                5'd03:   io_apb_PRDATA = {16'b0, DIER};  // 读 DIER
                5'd04:   io_apb_PRDATA = {16'b0, SR};  // 读 SR
                5'd05:   io_apb_PRDATA = {16'b0, EGR};  // 读 EGR
                5'd06:   io_apb_PRDATA = {16'b0, CCMR1};  // 读 CCMR1
                5'd07:   io_apb_PRDATA = {16'b0, CCMR2};  // 读 CCMR2
                5'd08:   io_apb_PRDATA = {16'b0, CCER};  // 读 CCER
                5'd09:   io_apb_PRDATA = {16'b0, CNT};  // 读 CNT
                5'd10:   io_apb_PRDATA = {16'b0, PSC};  // 读 PSC
                5'd11:   io_apb_PRDATA = {16'b0, ARR};  // 读 ARR
                5'd12:   io_apb_PRDATA = {16'b0, RCR};  // 读 CCR1
                5'd13:   io_apb_PRDATA = {16'b0, CCR1};  // 读 CCR1
                5'd14:   io_apb_PRDATA = {16'b0, CCR2};  // 读 CCR2
                5'd15:   io_apb_PRDATA = {16'b0, CCR3};  // 读 CCR3
                5'd16:   io_apb_PRDATA = {16'b0, CCR4};  // 读 CCR4
                5'd17:   io_apb_PRDATA = {16'b0, BDTR};  // 读 BDTR
                5'd18:   io_apb_PRDATA = {16'b0, DCR};  // 读 DCR
                5'd19:   io_apb_PRDATA = {16'b0, DMAR};  // 读 DMAR
                default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
            endcase
        end
    end

    // 输出通道逻辑
    reg  [ 3:0] TIM_CH_reg;  // 输出通道寄存器
    wire [ 3:0] ccxe, ccxp;  // 输出使能位和输出极性位
    wire [63:0] CCR = {CCR4, CCR3, CCR2, CCR1};  // 合并 CCR1-4
    wire [31:0] CCMR = {CCMR2, CCMR1};  // 合并 CCMR1 和 CCMR2
    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin
            assign ccxe[i] = CCER[i*4];  // CCxE 位，决定是否启用输出
            assign ccxp[i] = CCER[i*4+1];  // CCxP 位，决定输出极性
            assign TIM_CH[i] = ccxp[i] ? ~TIM_CH_reg[i] : TIM_CH_reg[i];  // 输出信号极性控制
            always @(*) begin
                if (ccxe[i])  // 如果输出使能
                    case (CCMR[i*8+6:i*8+4])  // OCxM PWM 模式控制
                        3'b110: begin  // PWM 模式 1
                            if (DIR) TIM_CH_reg[i] = (CNT > CCR[i*16+15:i*16]) ? 1'b0 : 1'b1;  // 向下计数
                            else TIM_CH_reg[i] = (CNT < CCR[i*16+15:i*16]) ? 1'b1 : 1'b0;  // 向上计数
                        end
                        3'b111: begin  // PWM 模式 2
                            if (DIR) TIM_CH_reg[i] = (CNT > CCR[i*16+15:i*16]) ? 1'b1 : 1'b0;  // 向下计数
                            else TIM_CH_reg[i] = (CNT < CCR[i*16+15:i*16]) ? 1'b0 : 1'b1;  // 向上计数
                        end
                        default: TIM_CH_reg[i] = 1'b0;  // 其他模式，默认输出低电平
                    endcase
                else TIM_CH_reg[i] = 1'b0;  // 输出未使能时，输出低电平
            end
        end
    endgenerate

endmodule


module Apb3USARTRouter (
    input  wire        io_apb_PCLK,
    input  wire        io_apb_PRESET,
    input  wire [15:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire [31:0] io_apb_PRDATA,
    output wire        io_apb_PSLVERROR,

    input  wire USART1_RX,
    output wire USART1_TX,
    output wire USART1_interrupt,
    input  wire USART2_RX,
    output wire USART2_TX,
    output wire USART2_interrupt
);

    reg  [15:0] Apb3PSEL;
    // UART1
    wire [ 2:0] io_apb_PADDR_GPIOA = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_GPIOA = Apb3PSEL[0];
    wire        io_apb_PENABLE_GPIOA = io_apb_PENABLE;
    wire        io_apb_PREADY_GPIOA;
    wire        io_apb_PWRITE_GPIOA = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_GPIOA = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_GPIOA;
    wire        io_apb_PSLVERROR_GPIOA = 1'b0;
    // UART2
    wire [ 2:0] io_apb_PADDR_GPIOB = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_GPIOB = Apb3PSEL[1];
    wire        io_apb_PENABLE_GPIOB = io_apb_PENABLE;
    wire        io_apb_PREADY_GPIOB;
    wire        io_apb_PWRITE_GPIOB = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_GPIOB = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_GPIOB;
    wire        io_apb_PSLVERROR_GPIOB = 1'b0;

    reg [15:0] selIndex;
    reg _zz_io_apb_PREADY;
    reg [31:0] _zz_io_apb_PRDATA;
    reg _zz_io_apb_PSLVERROR;
    assign io_apb_PREADY = _zz_io_apb_PREADY;
    assign io_apb_PRDATA = _zz_io_apb_PRDATA;
    assign io_apb_PSLVERROR = _zz_io_apb_PSLVERROR;
    always @(posedge io_apb_PCLK) selIndex <= Apb3PSEL;
    always @(*) begin
        if (io_apb_PRESET) begin
            _zz_io_apb_PREADY <= 1'b1;
            _zz_io_apb_PRDATA <= 32'h0;
            _zz_io_apb_PSLVERROR <= 1'b0;
        end else
            case (selIndex)
                16'h0001: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_GPIOA;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_GPIOA;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_GPIOA;
                end
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_GPIOB;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_GPIOB;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_GPIOB;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL <= 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // GPIOA
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // GPIOB
        end
    end

    Apb3USART Apb3USART1 (
        .io_apb_PCLK   (io_apb_PCLK),           // i
        .io_apb_PRESET (io_apb_PRESET),         // i
        .io_apb_PADDR  (io_apb_PADDR_GPIOA),    // i
        .io_apb_PSEL   (io_apb_PSEL_GPIOA),     // i
        .io_apb_PENABLE(io_apb_PENABLE_GPIOA),  // i
        .io_apb_PREADY (io_apb_PREADY_GPIOA),   // o
        .io_apb_PWRITE (io_apb_PWRITE_GPIOA),   // i
        .io_apb_PWDATA (io_apb_PWDATA_GPIOA),   // i
        .io_apb_PRDATA (io_apb_PRDATA_GPIOA),   // o
        .USART_RX      (USART1_RX),             // i
        .USART_TX      (USART1_TX),             // o
        .interrupt     (USART1_interrupt)       // o
    );

    Apb3USART Apb3USART2 (
        .io_apb_PCLK   (io_apb_PCLK),           // i
        .io_apb_PRESET (io_apb_PRESET),         // i
        .io_apb_PADDR  (io_apb_PADDR_GPIOB),    // i
        .io_apb_PSEL   (io_apb_PSEL_GPIOB),     // i
        .io_apb_PENABLE(io_apb_PENABLE_GPIOB),  // i
        .io_apb_PREADY (io_apb_PREADY_GPIOB),   // o
        .io_apb_PWRITE (io_apb_PWRITE_GPIOB),   // i
        .io_apb_PWDATA (io_apb_PWDATA_GPIOB),   // i
        .io_apb_PRDATA (io_apb_PRDATA_GPIOB),   // o
        .USART_RX      (USART2_RX),             // i
        .USART_TX      (USART2_TX),             // o
        .interrupt     (USART2_interrupt)       // o
    );

endmodule


module Apb3USART (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 2:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    // USART 接口信号
    input  wire USART_RX,  // USART 接收数据输入
    output wire USART_TX,  // USART 发送数据输出
    output wire interrupt  // USART 中断输出
);

    // USART 寄存器定义
    wire [15:0] SR;  // 状态寄存器
    reg  [15:0] DR;  // 数据寄存器
    reg  [15:0] BRR;  // 波特率寄存器
    reg  [15:0] CR1;  // 控制寄存器1
    reg  [15:0] CR2;  // 控制寄存器2
    reg  [15:0] CR3;  // 控制寄存器3  暂时不支持流控制和其他高级功能
    reg  [15:0] GTPR;  // 保护时间和预分频寄存器  暂时不支持

    // USART StreamFifo 接口定义
    wire       io_push_ready_TX;
    reg        io_push_valid_TX;
    reg  [7:0] io_push_payload_TX;
    wire       io_pop_ready_TX;
    wire       io_pop_valid_TX;
    wire [7:0] io_pop_payload_TX;
    wire [4:0] io_availability_TX;
    wire [4:0] io_occupancy_TX;
    wire       io_push_ready_RX;
    wire       io_push_valid_RX;
    wire [7:0] io_push_payload_RX;
    reg        io_pop_ready_RX;
    wire       io_pop_valid_RX;
    wire [7:0] io_pop_payload_RX;
    wire [4:0] io_availability_RX;
    wire [4:0] io_occupancy_RX;

    // USART Config 接口定义
    // SR
    wire        PE   = 1'b0;  // 校验错误
    wire        FE   = 1'b0;  // 帧错误
    wire        NF   = 1'b0;  // 噪声错误标志
    wire        ORE  = 1'b0;  // 过载错误
    wire        IDLE = 1'b0;  // 监测到总线空闲
    wire        RXNE = io_occupancy_RX ? 1'b1 : 1'b0;  // 读数据寄存器非空
    wire        TC   = io_availability_TX ? 1'b1 : 1'b0;  // (发送完成) 改为写数据寄存器有空闲
    wire        TXE  = 1'b0;  // 发送数据寄存器空
    wire        LBD  = 1'b0;  // LIN断开检测标志
    wire        CTS  = 1'b0;  // CTS 标志
    assign      SR   = {6'b0, CTS, LBD, TXE, TC, RXNE, IDLE, ORE, NF, FE, PE};
    // CR1
    wire        RE     = CR1[2];
    wire        TE     = CR1[3];
    wire        IDLEIE = CR1[4];
    wire        RXNEIE = CR1[5];
    wire        TCIE   = CR1[6];
    wire        TXEIE  = CR1[7];
    wire        PEIE   = CR1[8];
    wire        PS     = CR1[9];
    wire        PCE    = CR1[10];
    wire [ 2:0] M      = CR1[12] ? 3'b000 : 3'b111;
    wire        UE     = CR1[13];
    // CR2
    wire [ 1:0] STOP = CR2[13:12];
    // CR3
    wire        DMAT = CR3[7];
    wire        DMAR = CR3[6];
    // BRR
    wire [11:0] DIV_Mantissa = BRR[15:4];
    wire [ 3:0] DIV_Fraction = BRR[ 3:0];

    // USART 状态寄存器
    wire        io_readError;
    wire        io_writeBreak = 1'b0;
    wire        io_readBreak;

    // USART 中断输出
    assign interrupt = (PEIE & PE) | (TCIE & TC) | (RXNEIE & RXNE) | (TXEIE & TXE) | (IDLEIE & IDLE);

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            // SR   <= 16'h0000;
            DR   <= 16'h0000;
            BRR  <= 16'h0000;
            CR1  <= 16'h0000;
            CR2  <= 16'h0000;
            CR3  <= 16'h0000;
            GTPR <= 16'h0000;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    // 3'b000:  SR <= io_apb_PWDATA[15:0];  // 写 SR  // 暂时不可写入
                    3'b001:  DR <= io_apb_PWDATA[15:0];  // 写 DR
                    3'b010:  BRR <= io_apb_PWDATA[15:0];  // 写 BRR
                    3'b011:  CR1 <= io_apb_PWDATA[15:0];  // 写 CR1
                    3'b100:  CR2 <= io_apb_PWDATA[15:0];  // 写 CR2
                    3'b101:  CR3 <= io_apb_PWDATA[15:0];  // 写 CR3
                    3'b110:  GTPR <= io_apb_PWDATA[15:0];  // 写 GTPR
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) begin
            io_apb_PRDATA = 32'h00000000;  // 复位时返回0
            io_pop_ready_RX = 1'b0;
        end
        else begin
            io_pop_ready_RX = 1'b0;
            if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    3'b000:  io_apb_PRDATA = {16'b0, SR};  // 读 SR
                    3'b001:  begin 
                        io_apb_PRDATA = io_pop_valid_RX ? {16'b0, io_pop_payload_RX} : 32'h00000000;  // 读
                        io_pop_ready_RX = 1'b1;
                    end
                    3'b010:  io_apb_PRDATA = {16'b0, BRR};  // 读 BRR
                    3'b011:  io_apb_PRDATA = {16'b0, CR1};  // 读 CR1
                    3'b100:  io_apb_PRDATA = {16'b0, CR2};  // 读 CR2
                    3'b101:  io_apb_PRDATA = {16'b0, CR3};  // 读 CR3
                    3'b110:  io_apb_PRDATA = {16'b0, GTPR};  // 读 GTPR
                    default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end


    // StreamFifo 接口
    reg TXFifo_push = 1'b0;
    always @(posedge io_apb_PCLK)
        TXFifo_push <= io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE && io_apb_PADDR == 3'b001;
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            io_push_valid_TX   <= 1'b0;
            io_push_payload_TX <= 8'h00;
        end else begin
            io_push_valid_TX   <= 1'b0;
            io_push_payload_TX <= 8'h00;
            if (TXFifo_push) begin
                io_push_valid_TX   <= 1'b1;
                io_push_payload_TX <= DR[7:0];
            end
        end
    end

    // 串口收发逻辑
    StreamFifo_UART StreamFifo_UART_TX (
        .io_push_ready        (io_push_ready_TX),           // o
        .io_push_valid        (io_push_valid_TX),           // i
        .io_push_payload      (io_push_payload_TX),         // i
        .io_pop_ready         (io_pop_ready_TX),            // i
        .io_pop_valid         (io_pop_valid_TX),            // o
        .io_pop_payload       (io_pop_payload_TX),          // o
        .io_flush             (1'b0),                       // i
        .io_occupancy         (io_occupancy_TX),            // o
        .io_availability      (io_availability_TX),         // o
        .io_mainClk           (io_apb_PCLK),                // i
        .resetCtrl_systemReset(io_apb_PRESET | ~(RE & UE))  // i
    );
    UartCtrl UartCtrl (
        .io_config_frame_dataLength(M),                     // i
        .io_config_frame_stop      (STOP[1]),               // i
        .io_config_frame_parity    ({PS, PCE}),             // i
        .io_config_clockDivider    ({8'b0, DIV_Mantissa}),  // i
        .io_write_ready            (io_pop_ready_TX),       // o
        .io_write_valid            (io_pop_valid_TX),       // i
        .io_write_payload          (io_pop_payload_TX),     // i
        .io_read_ready             (io_push_ready_RX),      // i
        .io_read_valid             (io_push_valid_RX),      // o
        .io_read_payload           (io_push_payload_RX),    // o
        .io_uart_txd               (USART_TX),              // o
        .io_uart_rxd               (USART_RX),              // i
        .io_readError              (io_readError),          // o
        .io_writeBreak             (io_writeBreak),         // i
        .io_readBreak              (io_readBreak),          // o
        .io_uart_rxen              (RE & UE),               // i
        .io_uart_txen              (TE & UE),               // i
        .io_mainClk                (io_apb_PCLK),           // i
        .resetCtrl_systemReset     (io_apb_PRESET)          // i
    );
    StreamFifo_UART StreamFifo_UART_RX (
        .io_push_ready        (io_push_ready_RX),           // o
        .io_push_valid        (io_push_valid_RX),           // i
        .io_push_payload      (io_push_payload_RX),         // i
        .io_pop_ready         (io_pop_ready_RX),            // i
        .io_pop_valid         (io_pop_valid_RX),            // o
        .io_pop_payload       (io_pop_payload_RX),          // o
        .io_flush             (1'b0),                       // i
        .io_occupancy         (io_occupancy_RX),            // o
        .io_availability      (io_availability_RX),         // o
        .io_mainClk           (io_apb_PCLK),                // i
        .resetCtrl_systemReset(io_apb_PRESET | ~(RE & UE))  // i
    );

endmodule


module StreamFifo_UART (
    input  wire       io_push_valid,
    output wire       io_push_ready,
    input  wire [7:0] io_push_payload,
    output wire       io_pop_valid,
    input  wire       io_pop_ready,
    output wire [7:0] io_pop_payload,
    input  wire       io_flush,
    output wire [4:0] io_occupancy,
    output wire [4:0] io_availability,
    input  wire       io_mainClk,
    input  wire       resetCtrl_systemReset
);

    reg  [7:0] logic_ram_spinal_port1;
    reg        _zz_1;
    wire       logic_ptr_doPush;
    wire       logic_ptr_doPop;
    wire       logic_ptr_full;
    wire       logic_ptr_empty;
    reg  [4:0] logic_ptr_push;
    reg  [4:0] logic_ptr_pop;
    wire [4:0] logic_ptr_occupancy;
    wire [4:0] logic_ptr_popOnIo;
    wire       when_Stream_l1248;
    reg        logic_ptr_wentUp;
    wire       io_push_fire;
    wire       logic_push_onRam_write_valid;
    wire [3:0] logic_push_onRam_write_payload_address;
    wire [7:0] logic_push_onRam_write_payload_data;
    wire       logic_pop_addressGen_valid;
    reg        logic_pop_addressGen_ready;
    wire [3:0] logic_pop_addressGen_payload;
    wire       logic_pop_addressGen_fire;
    wire       logic_pop_sync_readArbitation_valid;
    wire       logic_pop_sync_readArbitation_ready;
    wire [3:0] logic_pop_sync_readArbitation_payload;
    reg        logic_pop_addressGen_rValid;
    reg  [3:0] logic_pop_addressGen_rData;
    wire       when_Stream_l375;
    wire       logic_pop_sync_readPort_cmd_valid;
    wire [3:0] logic_pop_sync_readPort_cmd_payload;
    wire [7:0] logic_pop_sync_readPort_rsp;
    wire       logic_pop_sync_readArbitation_translated_valid;
    wire       logic_pop_sync_readArbitation_translated_ready;
    wire [7:0] logic_pop_sync_readArbitation_translated_payload;
    wire       logic_pop_sync_readArbitation_fire;
    reg  [4:0] logic_pop_sync_popReg;
    reg  [7:0] logic_ram                                        [0:15];

    always @(posedge io_mainClk) begin
        if (_zz_1) begin
            logic_ram[logic_push_onRam_write_payload_address] <= logic_push_onRam_write_payload_data;
        end
    end

    always @(posedge io_mainClk) begin
        if (logic_pop_sync_readPort_cmd_valid) begin
            logic_ram_spinal_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
        end
    end

    always @(*) begin
        _zz_1 = 1'b0;
        if (logic_push_onRam_write_valid) begin
            _zz_1 = 1'b1;
        end
    end

    assign when_Stream_l1248 = (logic_ptr_doPush != logic_ptr_doPop);
    assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 5'h10) == 5'h0);
    assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
    assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
    assign io_push_ready = (!logic_ptr_full);
    assign io_push_fire = (io_push_valid && io_push_ready);
    assign logic_ptr_doPush = io_push_fire;
    assign logic_push_onRam_write_valid = io_push_fire;
    assign logic_push_onRam_write_payload_address = logic_ptr_push[3:0];
    assign logic_push_onRam_write_payload_data = io_push_payload;
    assign logic_pop_addressGen_valid = (!logic_ptr_empty);
    assign logic_pop_addressGen_payload = logic_ptr_pop[3:0];
    assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
    assign logic_ptr_doPop = logic_pop_addressGen_fire;
    always @(*) begin
        logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
        if (when_Stream_l375) begin
            logic_pop_addressGen_ready = 1'b1;
        end
    end

    assign when_Stream_l375 = (!logic_pop_sync_readArbitation_valid);
    assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
    assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
    assign logic_pop_sync_readPort_rsp = logic_ram_spinal_port1;
    assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_fire;
    assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_payload;
    assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
    assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
    assign logic_pop_sync_readArbitation_translated_payload = logic_pop_sync_readPort_rsp;
    assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
    assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
    assign io_pop_payload = logic_pop_sync_readArbitation_translated_payload;
    assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
    assign logic_ptr_popOnIo = logic_pop_sync_popReg;
    assign io_occupancy = logic_ptr_occupancy;
    assign io_availability = (5'h10 - logic_ptr_occupancy);
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            logic_ptr_push <= 5'h0;
            logic_ptr_pop <= 5'h0;
            logic_ptr_wentUp <= 1'b0;
            logic_pop_addressGen_rValid <= 1'b0;
            logic_pop_sync_popReg <= 5'h0;
        end else begin
            if (when_Stream_l1248) begin
                logic_ptr_wentUp <= logic_ptr_doPush;
            end
            if (io_flush) begin
                logic_ptr_wentUp <= 1'b0;
            end
            if (logic_ptr_doPush) begin
                logic_ptr_push <= (logic_ptr_push + 5'h01);
            end
            if (logic_ptr_doPop) begin
                logic_ptr_pop <= (logic_ptr_pop + 5'h01);
            end
            if (io_flush) begin
                logic_ptr_push <= 5'h0;
                logic_ptr_pop  <= 5'h0;
            end
            if (logic_pop_addressGen_ready) begin
                logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
            end
            if (io_flush) begin
                logic_pop_addressGen_rValid <= 1'b0;
            end
            if (logic_pop_sync_readArbitation_fire) begin
                logic_pop_sync_popReg <= logic_ptr_pop;
            end
            if (io_flush) begin
                logic_pop_sync_popReg <= 5'h0;
            end
        end
    end

    always @(posedge io_mainClk) begin
        if (logic_pop_addressGen_ready) begin
            logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
        end
    end

endmodule


module UartCtrl (
    input  wire [ 2:0] io_config_frame_dataLength,
    input  wire [ 0:0] io_config_frame_stop,
    input  wire [ 1:0] io_config_frame_parity,
    input  wire [19:0] io_config_clockDivider,
    input  wire        io_write_valid,
    output reg         io_write_ready,
    input  wire [ 7:0] io_write_payload,
    output wire        io_read_valid,
    input  wire        io_read_ready,
    output wire [ 7:0] io_read_payload,
    output wire        io_uart_txd,
    input  wire        io_uart_rxd,
    output wire        io_readError,
    input  wire        io_writeBreak,
    output wire        io_readBreak,
    input  wire        io_uart_rxen,
    input  wire        io_uart_txen,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);
    localparam UartStopType_ONE = 1'd0;
    localparam UartStopType_TWO = 1'd1;
    localparam UartParityType_NONE = 2'b00;
    localparam UartParityType_EVEN = 2'b10;
    localparam UartParityType_ODD = 2'b11;

    wire        tx_io_write_ready;
    wire        tx_io_txd;
    wire        rx_io_read_valid;
    wire [ 7:0] rx_io_read_payload;
    wire        rx_io_rts;
    wire        rx_io_error;
    wire        rx_io_break;
    reg  [19:0] clockDivider_counter;
    wire        clockDivider_tick;
    reg         clockDivider_tickReg;
    reg         io_write_thrown_valid;
    wire        io_write_thrown_ready;
    wire [ 7:0] io_write_thrown_payload;
`ifndef SYNTHESIS
    reg [23:0] io_config_frame_stop_string;
    reg [31:0] io_config_frame_parity_string;
`endif


    UartCtrlTx tx (
        .io_configFrame_dataLength(io_config_frame_dataLength[2:0]),       //i
        .io_configFrame_stop      (io_config_frame_stop),                  //i
        .io_configFrame_parity    (io_config_frame_parity[1:0]),           //i
        .io_samplingTick          (clockDivider_tickReg),                  //i
        .io_write_valid           (io_write_thrown_valid),                 //i
        .io_write_ready           (tx_io_write_ready),                     //o
        .io_write_payload         (io_write_thrown_payload[7:0]),          //i
        .io_cts                   (1'b0),                                  //i
        .io_txd                   (tx_io_txd),                             //o
        .io_break                 (io_writeBreak),                         //i
        .io_mainClk               (io_mainClk),                            //i
        .resetCtrl_systemReset    (resetCtrl_systemReset | ~io_uart_txen)  //i
    );
    UartCtrlRx rx (
        .io_configFrame_dataLength(io_config_frame_dataLength[2:0]),       //i
        .io_configFrame_stop      (io_config_frame_stop),                  //i
        .io_configFrame_parity    (io_config_frame_parity[1:0]),           //i
        .io_samplingTick          (clockDivider_tickReg),                  //i
        .io_read_valid            (rx_io_read_valid),                      //o
        .io_read_ready            (io_read_ready),                         //i
        .io_read_payload          (rx_io_read_payload[7:0]),               //o
        .io_rxd                   (io_uart_rxd),                           //i
        .io_rts                   (rx_io_rts),                             //o
        .io_error                 (rx_io_error),                           //o
        .io_break                 (rx_io_break),                           //o
        .io_mainClk               (io_mainClk),                            //i
        .resetCtrl_systemReset    (resetCtrl_systemReset | ~io_uart_rxen)  //i
    );
`ifndef SYNTHESIS
    always @(*) begin
        case (io_config_frame_stop)
            UartStopType_ONE: io_config_frame_stop_string = "ONE";
            UartStopType_TWO: io_config_frame_stop_string = "TWO";
            default: io_config_frame_stop_string = "???";
        endcase
    end
    always @(*) begin
        case (io_config_frame_parity)
            UartParityType_NONE: io_config_frame_parity_string = "NONE";
            UartParityType_EVEN: io_config_frame_parity_string = "EVEN";
            UartParityType_ODD: io_config_frame_parity_string = "ODD ";
            default: io_config_frame_parity_string = "????";
        endcase
    end
`endif

    assign clockDivider_tick = (clockDivider_counter == 20'h0);
    always @(*) begin
        io_write_thrown_valid = io_write_valid;
        if (rx_io_break) begin
            io_write_thrown_valid = 1'b0;
        end
    end

    always @(*) begin
        io_write_ready = io_write_thrown_ready;
        if (rx_io_break) begin
            io_write_ready = 1'b1;
        end
    end

    assign io_write_thrown_payload = io_write_payload;
    assign io_write_thrown_ready = tx_io_write_ready;
    assign io_read_valid = rx_io_read_valid;
    assign io_read_payload = rx_io_read_payload;
    assign io_uart_txd = tx_io_txd;
    assign io_readError = rx_io_error;
    assign io_readBreak = rx_io_break;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            clockDivider_counter <= 20'h0;
            clockDivider_tickReg <= 1'b0;
        end else begin
            clockDivider_tickReg <= clockDivider_tick;
            clockDivider_counter <= (clockDivider_counter - 20'h00001);
            if (clockDivider_tick) begin
                clockDivider_counter <= io_config_clockDivider;
            end
        end
    end

endmodule


module UartCtrlTx (
    input  wire [2:0] io_configFrame_dataLength,
    input  wire [0:0] io_configFrame_stop,
    input  wire [1:0] io_configFrame_parity,
    input  wire       io_samplingTick,
    input  wire       io_write_valid,
    output reg        io_write_ready,
    input  wire [7:0] io_write_payload,
    input  wire       io_cts,
    output wire       io_txd,
    input  wire       io_break,
    input  wire       io_mainClk,
    input  wire       resetCtrl_systemReset
);
    localparam UartStopType_ONE = 1'd0;
    localparam UartStopType_TWO = 1'd1;
    localparam UartParityType_NONE = 2'd0;
    localparam UartParityType_EVEN = 2'd1;
    localparam UartParityType_ODD = 2'd2;
    localparam UartCtrlTxState_IDLE = 3'd0;
    localparam UartCtrlTxState_START = 3'd1;
    localparam UartCtrlTxState_DATA = 3'd2;
    localparam UartCtrlTxState_PARITY = 3'd3;
    localparam UartCtrlTxState_STOP = 3'd4;

    wire [2:0] _zz_clockDivider_counter_valueNext;
    wire [0:0] _zz_clockDivider_counter_valueNext_1;
    wire [2:0] _zz_when_UartCtrlTx_l93;
    wire [0:0] _zz_when_UartCtrlTx_l93_1;
    reg        clockDivider_counter_willIncrement;
    wire       clockDivider_counter_willClear;
    reg  [2:0] clockDivider_counter_valueNext;
    reg  [2:0] clockDivider_counter_value;
    wire       clockDivider_counter_willOverflowIfInc;
    wire       clockDivider_counter_willOverflow;
    reg  [2:0] tickCounter_value;
    reg  [2:0] stateMachine_state;
    reg        stateMachine_parity;
    reg        stateMachine_txd;
    wire       when_UartCtrlTx_l58;
    wire       when_UartCtrlTx_l73;
    wire       when_UartCtrlTx_l76;
    wire       when_UartCtrlTx_l93;
    wire [2:0] _zz_stateMachine_state;
    reg        _zz_io_txd;
`ifndef SYNTHESIS
    reg [23:0] io_configFrame_stop_string;
    reg [31:0] io_configFrame_parity_string;
    reg [47:0] stateMachine_state_string;
    reg [47:0] _zz_stateMachine_state_string;
`endif


    assign _zz_clockDivider_counter_valueNext_1 = clockDivider_counter_willIncrement;
    assign _zz_clockDivider_counter_valueNext = {2'd0, _zz_clockDivider_counter_valueNext_1};
    assign _zz_when_UartCtrlTx_l93_1 = ((io_configFrame_stop == UartStopType_ONE) ? 1'b0 : 1'b1);
    assign _zz_when_UartCtrlTx_l93 = {2'd0, _zz_when_UartCtrlTx_l93_1};
`ifndef SYNTHESIS
    always @(*) begin
        case (io_configFrame_stop)
            UartStopType_ONE: io_configFrame_stop_string = "ONE";
            UartStopType_TWO: io_configFrame_stop_string = "TWO";
            default: io_configFrame_stop_string = "???";
        endcase
    end
    always @(*) begin
        case (io_configFrame_parity)
            UartParityType_NONE: io_configFrame_parity_string = "NONE";
            UartParityType_EVEN: io_configFrame_parity_string = "EVEN";
            UartParityType_ODD: io_configFrame_parity_string = "ODD ";
            default: io_configFrame_parity_string = "????";
        endcase
    end
    always @(*) begin
        case (stateMachine_state)
            UartCtrlTxState_IDLE: stateMachine_state_string = "IDLE  ";
            UartCtrlTxState_START: stateMachine_state_string = "START ";
            UartCtrlTxState_DATA: stateMachine_state_string = "DATA  ";
            UartCtrlTxState_PARITY: stateMachine_state_string = "PARITY";
            UartCtrlTxState_STOP: stateMachine_state_string = "STOP  ";
            default: stateMachine_state_string = "??????";
        endcase
    end
    always @(*) begin
        case (_zz_stateMachine_state)
            UartCtrlTxState_IDLE: _zz_stateMachine_state_string = "IDLE  ";
            UartCtrlTxState_START: _zz_stateMachine_state_string = "START ";
            UartCtrlTxState_DATA: _zz_stateMachine_state_string = "DATA  ";
            UartCtrlTxState_PARITY: _zz_stateMachine_state_string = "PARITY";
            UartCtrlTxState_STOP: _zz_stateMachine_state_string = "STOP  ";
            default: _zz_stateMachine_state_string = "??????";
        endcase
    end
`endif

    always @(*) begin
        clockDivider_counter_willIncrement = 1'b0;
        if (io_samplingTick) begin
            clockDivider_counter_willIncrement = 1'b1;
        end
    end

    assign clockDivider_counter_willClear = 1'b0;
    assign clockDivider_counter_willOverflowIfInc = (clockDivider_counter_value == 3'b100);
    assign clockDivider_counter_willOverflow = (clockDivider_counter_willOverflowIfInc && clockDivider_counter_willIncrement);
    always @(*) begin
        if (clockDivider_counter_willOverflow) begin
            clockDivider_counter_valueNext = 3'b000;
        end else begin
            clockDivider_counter_valueNext = (clockDivider_counter_value + _zz_clockDivider_counter_valueNext);
        end
        if (clockDivider_counter_willClear) begin
            clockDivider_counter_valueNext = 3'b000;
        end
    end

    always @(*) begin
        stateMachine_txd = 1'b1;
        case (stateMachine_state)
            UartCtrlTxState_IDLE: begin
            end
            UartCtrlTxState_START: begin
                stateMachine_txd = 1'b0;
            end
            UartCtrlTxState_DATA: begin
                stateMachine_txd = io_write_payload[tickCounter_value];
            end
            UartCtrlTxState_PARITY: begin
                stateMachine_txd = stateMachine_parity;
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        io_write_ready = io_break;
        case (stateMachine_state)
            UartCtrlTxState_IDLE: begin
            end
            UartCtrlTxState_START: begin
            end
            UartCtrlTxState_DATA: begin
                if (clockDivider_counter_willOverflow) begin
                    if (when_UartCtrlTx_l73) begin
                        io_write_ready = 1'b1;
                    end
                end
            end
            UartCtrlTxState_PARITY: begin
            end
            default: begin
            end
        endcase
    end

    assign when_UartCtrlTx_l58 = ((io_write_valid && (! io_cts)) && clockDivider_counter_willOverflow);
    assign when_UartCtrlTx_l73 = (tickCounter_value == io_configFrame_dataLength);
    assign when_UartCtrlTx_l76 = (io_configFrame_parity == UartParityType_NONE);
    assign when_UartCtrlTx_l93 = (tickCounter_value == _zz_when_UartCtrlTx_l93);
    assign _zz_stateMachine_state = (io_write_valid ? UartCtrlTxState_START : UartCtrlTxState_IDLE);
    assign io_txd = _zz_io_txd;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            clockDivider_counter_value <= 3'b000;
            stateMachine_state <= UartCtrlTxState_IDLE;
            _zz_io_txd <= 1'b1;
        end else begin
            clockDivider_counter_value <= clockDivider_counter_valueNext;
            case (stateMachine_state)
                UartCtrlTxState_IDLE: begin
                    if (when_UartCtrlTx_l58) begin
                        stateMachine_state <= UartCtrlTxState_START;
                    end
                end
                UartCtrlTxState_START: begin
                    if (clockDivider_counter_willOverflow) begin
                        stateMachine_state <= UartCtrlTxState_DATA;
                    end
                end
                UartCtrlTxState_DATA: begin
                    if (clockDivider_counter_willOverflow) begin
                        if (when_UartCtrlTx_l73) begin
                            if (when_UartCtrlTx_l76) begin
                                stateMachine_state <= UartCtrlTxState_STOP;
                            end else begin
                                stateMachine_state <= UartCtrlTxState_PARITY;
                            end
                        end
                    end
                end
                UartCtrlTxState_PARITY: begin
                    if (clockDivider_counter_willOverflow) begin
                        stateMachine_state <= UartCtrlTxState_STOP;
                    end
                end
                default: begin
                    if (clockDivider_counter_willOverflow) begin
                        if (when_UartCtrlTx_l93) begin
                            stateMachine_state <= _zz_stateMachine_state;
                        end
                    end
                end
            endcase
            _zz_io_txd <= (stateMachine_txd && (!io_break));
        end
    end

    always @(posedge io_mainClk) begin
        if (clockDivider_counter_willOverflow) begin
            tickCounter_value <= (tickCounter_value + 3'b001);
        end
        if (clockDivider_counter_willOverflow) begin
            stateMachine_parity <= (stateMachine_parity ^ stateMachine_txd);
        end
        case (stateMachine_state)
            UartCtrlTxState_IDLE: begin
            end
            UartCtrlTxState_START: begin
                if (clockDivider_counter_willOverflow) begin
                    stateMachine_parity <= (io_configFrame_parity == UartParityType_ODD);
                    tickCounter_value   <= 3'b000;
                end
            end
            UartCtrlTxState_DATA: begin
                if (clockDivider_counter_willOverflow) begin
                    if (when_UartCtrlTx_l73) begin
                        tickCounter_value <= 3'b000;
                    end
                end
            end
            UartCtrlTxState_PARITY: begin
                if (clockDivider_counter_willOverflow) begin
                    tickCounter_value <= 3'b000;
                end
            end
            default: begin
            end
        endcase
    end

endmodule


module UartCtrlRx (
    input  wire [2:0] io_configFrame_dataLength,
    input  wire [0:0] io_configFrame_stop,
    input  wire [1:0] io_configFrame_parity,
    input  wire       io_samplingTick,
    output wire       io_read_valid,
    input  wire       io_read_ready,
    output wire [7:0] io_read_payload,
    input  wire       io_rxd,
    output wire       io_rts,
    output reg        io_error,
    output wire       io_break,
    input  wire       io_mainClk,
    input  wire       resetCtrl_systemReset
);
    localparam UartStopType_ONE = 1'd0;
    localparam UartStopType_TWO = 1'd1;
    localparam UartParityType_NONE = 2'd0;
    localparam UartParityType_EVEN = 2'd1;
    localparam UartParityType_ODD = 2'd2;
    localparam UartCtrlRxState_IDLE = 3'd0;
    localparam UartCtrlRxState_START = 3'd1;
    localparam UartCtrlRxState_DATA = 3'd2;
    localparam UartCtrlRxState_PARITY = 3'd3;
    localparam UartCtrlRxState_STOP = 3'd4;

    wire       io_rxd_buffercc_io_dataOut;
    wire [2:0] _zz_when_UartCtrlRx_l139;
    wire [0:0] _zz_when_UartCtrlRx_l139_1;
    reg        _zz_io_rts;
    wire       sampler_synchroniser;
    wire       sampler_samples_0;
    reg        sampler_samples_1;
    reg        sampler_samples_2;
    reg        sampler_value;
    reg        sampler_tick;
    reg  [2:0] bitTimer_counter;
    reg        bitTimer_tick;
    wire       when_UartCtrlRx_l43;
    reg  [2:0] bitCounter_value;
    reg  [6:0] break_counter;
    wire       break_valid;
    wire       when_UartCtrlRx_l69;
    reg  [2:0] stateMachine_state;
    reg        stateMachine_parity;
    reg  [7:0] stateMachine_shifter;
    reg        stateMachine_validReg;
    wire       when_UartCtrlRx_l93;
    wire       when_UartCtrlRx_l103;
    wire       when_UartCtrlRx_l111;
    wire       when_UartCtrlRx_l113;
    wire       when_UartCtrlRx_l125;
    wire       when_UartCtrlRx_l136;
    wire       when_UartCtrlRx_l139;
`ifndef SYNTHESIS
    reg [23:0] io_configFrame_stop_string;
    reg [31:0] io_configFrame_parity_string;
    reg [47:0] stateMachine_state_string;
`endif


    assign _zz_when_UartCtrlRx_l139_1 = ((io_configFrame_stop == UartStopType_ONE) ? 1'b0 : 1'b1);
    assign _zz_when_UartCtrlRx_l139   = {2'd0, _zz_when_UartCtrlRx_l139_1};
    (* keep_hierarchy = "TRUE" *) BufferCC_UART BufferCC_UART (
        .io_dataIn            (io_rxd),                      //i
        .io_dataOut           (io_rxd_buffercc_io_dataOut),  //o
        .io_mainClk           (io_mainClk),                  //i
        .resetCtrl_systemReset(resetCtrl_systemReset)        //i
    );
`ifndef SYNTHESIS
    always @(*) begin
        case (io_configFrame_stop)
            UartStopType_ONE: io_configFrame_stop_string = "ONE";
            UartStopType_TWO: io_configFrame_stop_string = "TWO";
            default: io_configFrame_stop_string = "???";
        endcase
    end
    always @(*) begin
        case (io_configFrame_parity)
            UartParityType_NONE: io_configFrame_parity_string = "NONE";
            UartParityType_EVEN: io_configFrame_parity_string = "EVEN";
            UartParityType_ODD: io_configFrame_parity_string = "ODD ";
            default: io_configFrame_parity_string = "????";
        endcase
    end
    always @(*) begin
        case (stateMachine_state)
            UartCtrlRxState_IDLE: stateMachine_state_string = "IDLE  ";
            UartCtrlRxState_START: stateMachine_state_string = "START ";
            UartCtrlRxState_DATA: stateMachine_state_string = "DATA  ";
            UartCtrlRxState_PARITY: stateMachine_state_string = "PARITY";
            UartCtrlRxState_STOP: stateMachine_state_string = "STOP  ";
            default: stateMachine_state_string = "??????";
        endcase
    end
`endif

    always @(*) begin
        io_error = 1'b0;
        case (stateMachine_state)
            UartCtrlRxState_IDLE: begin
            end
            UartCtrlRxState_START: begin
            end
            UartCtrlRxState_DATA: begin
            end
            UartCtrlRxState_PARITY: begin
                if (bitTimer_tick) begin
                    if (!when_UartCtrlRx_l125) begin
                        io_error = 1'b1;
                    end
                end
            end
            default: begin
                if (bitTimer_tick) begin
                    if (when_UartCtrlRx_l136) begin
                        io_error = 1'b1;
                    end
                end
            end
        endcase
    end

    assign io_rts = _zz_io_rts;
    assign sampler_synchroniser = io_rxd_buffercc_io_dataOut;
    assign sampler_samples_0 = sampler_synchroniser;
    always @(*) begin
        bitTimer_tick = 1'b0;
        if (sampler_tick) begin
            if (when_UartCtrlRx_l43) begin
                bitTimer_tick = 1'b1;
            end
        end
    end

    assign when_UartCtrlRx_l43 = (bitTimer_counter == 3'b000);
    assign break_valid = (break_counter == 7'h41);
    assign when_UartCtrlRx_l69 = (io_samplingTick && (!break_valid));
    assign io_break = break_valid;
    assign io_read_valid = stateMachine_validReg;
    assign when_UartCtrlRx_l93 = ((sampler_tick && (!sampler_value)) && (!break_valid));
    assign when_UartCtrlRx_l103 = (sampler_value == 1'b1);
    assign when_UartCtrlRx_l111 = (bitCounter_value == io_configFrame_dataLength);
    assign when_UartCtrlRx_l113 = (io_configFrame_parity == UartParityType_NONE);
    assign when_UartCtrlRx_l125 = (stateMachine_parity == sampler_value);
    assign when_UartCtrlRx_l136 = (!sampler_value);
    assign when_UartCtrlRx_l139 = (bitCounter_value == _zz_when_UartCtrlRx_l139);
    assign io_read_payload = stateMachine_shifter;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            _zz_io_rts <= 1'b0;
            sampler_samples_1 <= 1'b1;
            sampler_samples_2 <= 1'b1;
            sampler_value <= 1'b1;
            sampler_tick <= 1'b0;
            break_counter <= 7'h0;
            stateMachine_state <= UartCtrlRxState_IDLE;
            stateMachine_validReg <= 1'b0;
        end else begin
            _zz_io_rts <= (!io_read_ready);
            if (io_samplingTick) begin
                sampler_samples_1 <= sampler_samples_0;
            end
            if (io_samplingTick) begin
                sampler_samples_2 <= sampler_samples_1;
            end
            sampler_value <= (((1'b0 || ((1'b1 && sampler_samples_0) && sampler_samples_1)) || ((1'b1 && sampler_samples_0) && sampler_samples_2)) || ((1'b1 && sampler_samples_1) && sampler_samples_2));
            sampler_tick <= io_samplingTick;
            if (sampler_value) begin
                break_counter <= 7'h0;
            end else begin
                if (when_UartCtrlRx_l69) begin
                    break_counter <= (break_counter + 7'h01);
                end
            end
            stateMachine_validReg <= 1'b0;
            case (stateMachine_state)
                UartCtrlRxState_IDLE: begin
                    if (when_UartCtrlRx_l93) begin
                        stateMachine_state <= UartCtrlRxState_START;
                    end
                end
                UartCtrlRxState_START: begin
                    if (bitTimer_tick) begin
                        stateMachine_state <= UartCtrlRxState_DATA;
                        if (when_UartCtrlRx_l103) begin
                            stateMachine_state <= UartCtrlRxState_IDLE;
                        end
                    end
                end
                UartCtrlRxState_DATA: begin
                    if (bitTimer_tick) begin
                        if (when_UartCtrlRx_l111) begin
                            if (when_UartCtrlRx_l113) begin
                                stateMachine_state <= UartCtrlRxState_STOP;
                                stateMachine_validReg <= 1'b1;
                            end else begin
                                stateMachine_state <= UartCtrlRxState_PARITY;
                            end
                        end
                    end
                end
                UartCtrlRxState_PARITY: begin
                    if (bitTimer_tick) begin
                        if (when_UartCtrlRx_l125) begin
                            stateMachine_state <= UartCtrlRxState_STOP;
                            stateMachine_validReg <= 1'b1;
                        end else begin
                            stateMachine_state <= UartCtrlRxState_IDLE;
                        end
                    end
                end
                default: begin
                    if (bitTimer_tick) begin
                        if (when_UartCtrlRx_l136) begin
                            stateMachine_state <= UartCtrlRxState_IDLE;
                        end else begin
                            if (when_UartCtrlRx_l139) begin
                                stateMachine_state <= UartCtrlRxState_IDLE;
                            end
                        end
                    end
                end
            endcase
        end
    end

    always @(posedge io_mainClk) begin
        if (sampler_tick) begin
            bitTimer_counter <= (bitTimer_counter - 3'b001);
            if (when_UartCtrlRx_l43) begin
                bitTimer_counter <= 3'b100;
            end
        end
        if (bitTimer_tick) begin
            bitCounter_value <= (bitCounter_value + 3'b001);
        end
        if (bitTimer_tick) begin
            stateMachine_parity <= (stateMachine_parity ^ sampler_value);
        end
        case (stateMachine_state)
            UartCtrlRxState_IDLE: begin
                if (when_UartCtrlRx_l93) begin
                    bitTimer_counter <= 3'b001;
                end
            end
            UartCtrlRxState_START: begin
                if (bitTimer_tick) begin
                    bitCounter_value <= 3'b000;
                    stateMachine_parity <= (io_configFrame_parity == UartParityType_ODD);
                end
            end
            UartCtrlRxState_DATA: begin
                if (bitTimer_tick) begin
                    stateMachine_shifter[bitCounter_value] <= sampler_value;
                    if (when_UartCtrlRx_l111) begin
                        bitCounter_value <= 3'b000;
                    end
                end
            end
            UartCtrlRxState_PARITY: begin
                if (bitTimer_tick) begin
                    bitCounter_value <= 3'b000;
                end
            end
            default: begin
            end
        endcase
    end

endmodule


module BufferCC_UART (
    input  wire io_dataIn,
    output wire io_dataOut,
    input  wire io_mainClk,
    input  wire resetCtrl_systemReset
);

    (* async_reg = "true" *)reg buffers_0;
    (* async_reg = "true" *)reg buffers_1;

    assign io_dataOut = buffers_1;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            buffers_0 <= 1'b0;
            buffers_1 <= 1'b0;
        end else begin
            buffers_0 <= io_dataIn;
            buffers_1 <= buffers_0;
        end
    end

endmodule


module Apb3WDGRouter (
    input  wire        io_apb_PCLK,
    input  wire        io_apb_PRESET,
    input  wire [15:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire [31:0] io_apb_PRDATA,
    output wire        io_apb_PSLVERROR,

    output wire IWDG_rst,
    output wire WWDG_rst
);

    reg  [15:0] Apb3PSEL;
    // IWDG
    wire [ 1:0] io_apb_PADDR_IWDG = io_apb_PADDR[3:2];
    wire        io_apb_PSEL_IWDG = Apb3PSEL[0];
    wire        io_apb_PENABLE_IWDG = io_apb_PENABLE;
    wire        io_apb_PREADY_IWDG;
    wire        io_apb_PWRITE_IWDG = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_IWDG = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_IWDG;
    wire        io_apb_PSLVERROR_IWDG = 1'b0;
    //WWDG
    wire [ 1:0] io_apb_PADDR_WWDG = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_WWDG = Apb3PSEL[1];
    wire        io_apb_PENABLE_WWDG = io_apb_PENABLE;
    wire        io_apb_PREADY_WWDG;
    wire        io_apb_PWRITE_WWDG = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_WWDG = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_WWDG;
    wire        io_apb_PSLVERROR_WWDG = 1'b0;

    reg [15:0] selIndex;
    reg        _zz_io_apb_PREADY;
    reg [31:0] _zz_io_apb_PRDATA;
    reg        _zz_io_apb_PSLVERROR;
    assign io_apb_PREADY = _zz_io_apb_PREADY;
    assign io_apb_PRDATA = _zz_io_apb_PRDATA;
    assign io_apb_PSLVERROR = _zz_io_apb_PSLVERROR;
    always @(posedge io_apb_PCLK) selIndex <= Apb3PSEL;
    always @(*) begin
        if (io_apb_PRESET) begin
            _zz_io_apb_PREADY <= 1'b1;
            _zz_io_apb_PRDATA <= 32'h0;
            _zz_io_apb_PSLVERROR <= 1'b0;
        end
        else
            case (selIndex)
                16'h0001: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_IWDG;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_IWDG;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_IWDG;
                end
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_WWDG;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_WWDG;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_WWDG;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL <= 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // IWDT
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // WWDT
        end
    end

    IWDG IWDG (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_IWDG),    // i
        .io_apb_PSEL   (io_apb_PSEL_IWDG),     // i
        .io_apb_PENABLE(io_apb_PENABLE_IWDG),  // i
        .io_apb_PREADY (io_apb_PREADY_IWDG),   // o
        .io_apb_PWRITE (io_apb_PWRITE_IWDG),   // i
        .io_apb_PWDATA (io_apb_PWDATA_IWDG),   // i
        .io_apb_PRDATA (io_apb_PRDATA_IWDG),   // o
        .IWDG_rst      (IWDG_rst)              // o
    );

    WWDG WWDG (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_WWDG),    // i
        .io_apb_PSEL   (io_apb_PSEL_WWDG),     // i
        .io_apb_PENABLE(io_apb_PENABLE_WWDG),  // i
        .io_apb_PREADY (io_apb_PREADY_WWDG),   // o
        .io_apb_PWRITE (io_apb_PWRITE_WWDG),   // i
        .io_apb_PWDATA (io_apb_PWDATA_WWDG),   // i
        .io_apb_PRDATA (io_apb_PRDATA_WWDG),   // o
        .WWDG_rst      (WWDG_rst)              // o
    );

endmodule


module IWDG (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 1:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    output reg IWDG_rst  // 看门狗复位信号
);

    // IWDG寄存器定义
    reg [15:0] KR;  // Key register
    reg [ 2:0] PR;  // Prescaler register (使用 3 位预分频器)
    reg [11:0] RLR;  // Reload register (12 位)
    reg [ 1:0] SR;  // Status register (使用 2 位状态寄存器)

    // IWDG内部计数器和状态
    reg [31:0] counter, prescaler_counter;
    reg IWDG_en, write_en;

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            KR  <= 16'h0000;
            PR  <= 3'b000;
            RLR <= 12'hFFF;
        end else begin
            // APB 写操作
            KR <= 16'h0000;
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    2'b00:   KR <= io_apb_PWDATA[15:0];  // 写 Key register
                    2'b01:   if (write_en) PR <= io_apb_PWDATA[2:0];  // 写 Prescaler register
                    2'b10:   if (write_en) RLR <= io_apb_PWDATA[11:0];  // 写 Reload register
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) io_apb_PRDATA = 32'h00000000;
        else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
            case (io_apb_PADDR)
                2'b00:   io_apb_PRDATA = {16'b0, KR};  // 读 Key register
                2'b01:   io_apb_PRDATA = {29'b0, PR};  // 读 Prescaler register
                2'b10:   io_apb_PRDATA = {20'b0, RLR};  // 读 Reload register
                2'b11:   io_apb_PRDATA = {30'b0, SR};  // 读 Status register
                default: io_apb_PRDATA = 32'h00000000;
            endcase
        end
    end

    // 计数器和分频逻辑
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            counter <= 32'h00000000;
            write_en <= 1'b0;
            IWDG_en <= 1'b0;
            IWDG_rst <= 1'b0;
            prescaler_counter <= 16'h0000;
            SR <= 2'b00;
        end else begin
            // 看门狗计时器启用条件
            if (KR)
                case (KR)
                    16'h5555: write_en <= 1'b1;  // 写使能
                    16'hAAAA: if (write_en) counter <= {20'b0, RLR};  // 重载计数器
                    16'hCCCC: begin  // 看门狗使能
                        if (write_en) begin
                            IWDG_en <= 1'b1;
                            SR      <= 2'b00;  // 清除状态寄存器
                        end
                    end
                    default: write_en <= 1'b0;  // 写失能
                endcase

            // 分频器计数逻辑
            if (IWDG_en) begin
                if (prescaler_counter == (4 << PR) - 1) begin
                    prescaler_counter <= 16'h0000;  // 分频计数器重置
                    if (counter > 0) begin
                        counter <= counter - 1;  // 分频后主计数器减少
                    end else begin
                        IWDG_rst <= 1'b1;  // 计数器达到 0 时发出复位信号
                        SR       <= 2'b01;  // 状态寄存器置位
                    end
                end else prescaler_counter <= prescaler_counter + 1;  // 分频计数器增加
            end
        end
    end

endmodule


module WWDG (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 1:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    output reg WWDG_rst  // 看门狗复位信号
);

    // WWDG寄存器定义
    reg [7:0] CR;  // Control register
    reg [15:0] CFR;  // Configuration register
    reg SR;  // Status register

    // WWDG内部计数器和状态
    reg [15:0] prescaler_counter;
    wire [6:0] T = CR[6:0];
    wire [6:0] W = CFR[6:0];
    wire [2:0] prescaler_value = CFR[9:7];  // CFR中的预分频器
    wire WWDG_en = CR[7];  // 看门狗使能标志

    // APB 写寄存器逻辑 && 计数器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR <= 8'h7F;  // 初始计数器值最大
            CFR <= 16'h7F;  // 初始窗口值最大
            SR <= 1'b0;  // 初始状态寄存器清零
            WWDG_rst <= 1'b0;  // 看门狗复位信号清零
            prescaler_counter <= 16'h0000;
        end else begin
            // APB 写寄存器逻辑
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    2'b00: begin
                        if ((T > W) && WWDG_en) WWDG_rst <= 1'b1;  // 如果重载计数器时，计数器值大于窗口值，触发看门狗复位
                        else CR <= io_apb_PWDATA[15:0];  // 重载计数器
                    end
                    2'b01:   CFR <= io_apb_PWDATA;
                    2'b10:   SR <= io_apb_PWDATA;  // 写状态寄存器 (手动清除)
                    default: ;  // 其他寄存器不处理
                endcase
            end
            // 计数器逻辑
            if (WWDG_en) begin
                if (prescaler_counter == (1 << prescaler_value) - 1) begin
                    prescaler_counter <= 16'h0000;  // 分频计数器重置
                    if (T > 7'h40) begin
                        CR <= CR - 1;  // 计数器递减
                    end else begin
                        WWDG_rst <= 1'b1;  // 计数器达到 0 时发出复位信号
                        SR    <= 1'b1;  // 设置 SR 中的超时标志位
                    end
                end else prescaler_counter <= prescaler_counter + 1;  // 分频计数器增加
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) io_apb_PRDATA = 32'h00000000;
        // else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
        else begin
            case (io_apb_PADDR)
                2'b00:   io_apb_PRDATA = {24'h000000, CR};  // 读 Control register
                2'b01:   io_apb_PRDATA = {16'h000000, CFR};  // 读 Configuration register
                2'b10:   io_apb_PRDATA = {31'h0, SR};  // 读 Status register
                default: io_apb_PRDATA = 32'h00000000;
            endcase
        end
    end

endmodule
