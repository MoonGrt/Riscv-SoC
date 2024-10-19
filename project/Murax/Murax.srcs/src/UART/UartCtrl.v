`timescale 1ns / 1ps

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
