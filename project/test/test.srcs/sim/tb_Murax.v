`timescale 1ns / 1ps
 
module tb_Murax;

    // Murax Parameters
    parameter T = 10;

    // Murax Inputs
    reg         rst_n = 0;
    reg         clk = 0;
    reg         io_jtag_tms = 0;
    reg         io_jtag_tdi = 0;
    reg         io_jtag_tck = 0;
    reg  [31:0] io_gpioA_read = 0;
    reg         io_uart_rxd = 0;

    // Murax Outputs
    wire        io_jtag_tdo;
    wire [31:0] io_gpioA_write;
    wire [31:0] io_gpioA_writeEnable;
    wire        io_uart_txd;

    initial begin
        forever #(T / 2) clk = ~clk;
    end

    initial begin
        #(T * 2) rst_n = 1;
    end

    Murax Murax (
        .io_asyncReset       (~rst_n),
        .io_mainClk          (clk),

        .io_jtag_tms         (io_jtag_tms),
        .io_jtag_tdi         (io_jtag_tdi),
        .io_jtag_tck         (io_jtag_tck),
        .io_gpioA_read       (io_gpioA_read),
        .io_uart_rxd         (io_uart_rxd),
        .io_jtag_tdo         (io_jtag_tdo),
        .io_gpioA_write      (io_gpioA_write),
        .io_gpioA_writeEnable(io_gpioA_writeEnable),
        .io_uart_txd         (io_uart_txd)
    );

endmodule
