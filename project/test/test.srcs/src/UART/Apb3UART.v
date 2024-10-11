`timescale 1ns / 1ps

module Apb3UART (
    input wire io_mainClk,
    input wire resetCtrl_systemReset,

    input  wire [ 4:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire        io_apb_PREADY,
    output reg  [31:0] io_apb_PRDATA,

    input  wire io_uart_rxd,
    output wire io_uart_txd,
    output wire io_interrupt
);
    localparam UartStopType_ONE = 1'd0;
    localparam UartStopType_TWO = 1'd1;
    localparam UartParityType_NONE = 2'd0;
    localparam UartParityType_EVEN = 2'd1;
    localparam UartParityType_ODD = 2'd2;

    reg         system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_ready;
    wire        uartCtrl_1_io_write_ready;
    wire        uartCtrl_1_io_read_valid;
    wire [ 7:0] uartCtrl_1_io_read_payload;
    wire        uartCtrl_1_io_uart_txd;
    wire        uartCtrl_1_io_readError;
    wire        uartCtrl_1_io_readBreak;
    wire        bridge_write_streamUnbuffered_queueWithOccupancy_io_push_ready;
    wire        bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid;
    wire [ 7:0] bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_payload;
    wire [ 4:0] bridge_write_streamUnbuffered_queueWithOccupancy_io_occupancy;
    wire [ 4:0] bridge_write_streamUnbuffered_queueWithOccupancy_io_availability;
    wire        system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_push_ready;
    wire        system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_valid;
    wire [ 7:0] system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_payload;
    wire [ 4:0] system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_occupancy;
    wire [ 4:0] system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_availability;
    wire [ 0:0] _zz_bridge_misc_readError;
    wire [ 0:0] _zz_bridge_misc_readOverflowError;
    wire [ 0:0] _zz_bridge_misc_breakDetected;
    wire [ 0:0] _zz_bridge_misc_doBreak;
    wire [ 0:0] _zz_bridge_misc_doBreak_1;
    wire [ 4:0] _zz_io_apb_PRDATA;
    wire        busCtrl_readErrorFlag;
    wire        busCtrl_writeErrorFlag;
    wire        busCtrl_askWrite;
    wire        busCtrl_askRead;
    wire        busCtrl_doWrite;
    wire        busCtrl_doRead;
    wire        bridge_busCtrlWrapped_readErrorFlag;
    wire        bridge_busCtrlWrapped_writeErrorFlag;
    wire [ 2:0] bridge_uartConfigReg_frame_dataLength;
    wire [ 0:0] bridge_uartConfigReg_frame_stop;
    wire [ 1:0] bridge_uartConfigReg_frame_parity;
    reg  [19:0] bridge_uartConfigReg_clockDivider;
    reg         _zz_bridge_write_streamUnbuffered_valid;
    wire        bridge_write_streamUnbuffered_valid;
    wire        bridge_write_streamUnbuffered_ready;
    wire [ 7:0] bridge_write_streamUnbuffered_payload;
    reg         bridge_read_streamBreaked_valid;
    reg         bridge_read_streamBreaked_ready;
    wire [ 7:0] bridge_read_streamBreaked_payload;
    reg         bridge_interruptCtrl_writeIntEnable;
    reg         bridge_interruptCtrl_readIntEnable;
    wire        bridge_interruptCtrl_readInt;
    wire        bridge_interruptCtrl_writeInt;
    wire        bridge_interruptCtrl_interrupt;
    reg         bridge_misc_readError;
    reg         when_BusSlaveFactory_l341;
    wire        when_BusSlaveFactory_l347;
    reg         bridge_misc_readOverflowError;
    reg         when_BusSlaveFactory_l341_1;
    wire        when_BusSlaveFactory_l347_1;
    wire        system_uartCtrl_uartCtrl_1_io_read_isStall;
    reg         bridge_misc_breakDetected;
    reg         system_uartCtrl_uartCtrl_1_io_readBreak_regNext;
    wire        when_UartCtrl_l155;
    reg         when_BusSlaveFactory_l341_2;
    wire        when_BusSlaveFactory_l347_2;
    reg         bridge_misc_doBreak;
    reg         when_BusSlaveFactory_l377;
    wire        when_BusSlaveFactory_l379;
    reg         when_BusSlaveFactory_l341_3;
    wire        when_BusSlaveFactory_l347_3;
`ifndef SYNTHESIS
    reg [23:0] bridge_uartConfigReg_frame_stop_string;
    reg [31:0] bridge_uartConfigReg_frame_parity_string;
`endif

    function [19:0] zz_bridge_uartConfigReg_clockDivider(input dummy);
        begin
            zz_bridge_uartConfigReg_clockDivider = 20'h0;
            zz_bridge_uartConfigReg_clockDivider = 20'h00013;
        end
    endfunction
    wire [19:0] _zz_1;

    assign _zz_bridge_misc_readError = 1'b0;
    assign _zz_bridge_misc_readOverflowError = 1'b0;
    assign _zz_bridge_misc_breakDetected = 1'b0;
    assign _zz_bridge_misc_doBreak = 1'b1;
    assign _zz_bridge_misc_doBreak_1 = 1'b0;
    assign _zz_io_apb_PRDATA = (5'h10 - bridge_write_streamUnbuffered_queueWithOccupancy_io_occupancy);
    UartCtrl UartCtrl (
        .io_config_frame_dataLength(bridge_uartConfigReg_frame_dataLength[2:0]),  //i
        .io_config_frame_stop(bridge_uartConfigReg_frame_stop),  //i
        .io_config_frame_parity(bridge_uartConfigReg_frame_parity[1:0]),  //i
        .io_config_clockDivider(bridge_uartConfigReg_clockDivider[19:0]),  //i
        .io_write_valid(bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid),  //i
        .io_write_ready(uartCtrl_1_io_write_ready),  //o
        .io_write_payload           (bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_payload[7:0]), //i
        .io_read_valid(uartCtrl_1_io_read_valid),  //o
        .io_read_ready(system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_push_ready),  //i
        .io_read_payload(uartCtrl_1_io_read_payload[7:0]),  //o
        .io_uart_txd(uartCtrl_1_io_uart_txd),  //o
        .io_uart_rxd(io_uart_rxd),  //i
        .io_readError(uartCtrl_1_io_readError),  //o
        .io_writeBreak(bridge_misc_doBreak),  //i
        .io_readBreak(uartCtrl_1_io_readBreak),  //o
        .io_mainClk(io_mainClk),  //i
        .resetCtrl_systemReset(resetCtrl_systemReset)  //i
    );
    StreamFifo_UART StreamFifo_UART_TX (
        .io_push_valid(bridge_write_streamUnbuffered_valid),  //i
        .io_push_ready(bridge_write_streamUnbuffered_queueWithOccupancy_io_push_ready),  //o
        .io_push_payload(bridge_write_streamUnbuffered_payload[7:0]),  //i
        .io_pop_valid(bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid),  //o
        .io_pop_ready(uartCtrl_1_io_write_ready),  //i
        .io_pop_payload(bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_payload[7:0]),  //o
        .io_flush(1'b0),  //i
        .io_occupancy(bridge_write_streamUnbuffered_queueWithOccupancy_io_occupancy[4:0]),  //o
        .io_availability       (bridge_write_streamUnbuffered_queueWithOccupancy_io_availability[4:0]), //o
        .io_mainClk(io_mainClk),  //i
        .resetCtrl_systemReset(resetCtrl_systemReset)  //i
    );
    StreamFifo_UART StreamFifo_UART_RX (
        .io_push_valid(uartCtrl_1_io_read_valid),  //i
        .io_push_ready(system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_push_ready),  //o
        .io_push_payload(uartCtrl_1_io_read_payload[7:0]),  //i
        .io_pop_valid(system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_valid),  //o
        .io_pop_ready(system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_ready),  //i
        .io_pop_payload        (system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_payload[7:0] ), //o
        .io_flush(1'b0),  //i
        .io_occupancy(system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_occupancy[4:0]),  //o
        .io_availability       (system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_availability[4:0]), //o
        .io_mainClk(io_mainClk),  //i
        .resetCtrl_systemReset(resetCtrl_systemReset)  //i
    );
`ifndef SYNTHESIS
    always @(*) begin
        case (bridge_uartConfigReg_frame_stop)
            UartStopType_ONE: bridge_uartConfigReg_frame_stop_string = "ONE";
            UartStopType_TWO: bridge_uartConfigReg_frame_stop_string = "TWO";
            default: bridge_uartConfigReg_frame_stop_string = "???";
        endcase
    end
    always @(*) begin
        case (bridge_uartConfigReg_frame_parity)
            UartParityType_NONE: bridge_uartConfigReg_frame_parity_string = "NONE";
            UartParityType_EVEN: bridge_uartConfigReg_frame_parity_string = "EVEN";
            UartParityType_ODD: bridge_uartConfigReg_frame_parity_string = "ODD ";
            default: bridge_uartConfigReg_frame_parity_string = "????";
        endcase
    end
`endif

    assign io_uart_txd = uartCtrl_1_io_uart_txd;
    assign busCtrl_readErrorFlag = 1'b0;
    assign busCtrl_writeErrorFlag = 1'b0;
    assign io_apb_PREADY = 1'b1;
    always @(*) begin
        io_apb_PRDATA = 32'h0;
        case (io_apb_PADDR)
            5'h0: begin
                io_apb_PRDATA[16:16] = (bridge_read_streamBreaked_valid ^ 1'b0);
                io_apb_PRDATA[7:0]   = bridge_read_streamBreaked_payload;
            end
            5'h04: begin
                io_apb_PRDATA[20:16] = _zz_io_apb_PRDATA;
                io_apb_PRDATA[15:15] = bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid;
                io_apb_PRDATA[28:24] = system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_occupancy;
                io_apb_PRDATA[0:0] = bridge_interruptCtrl_writeIntEnable;
                io_apb_PRDATA[1:1] = bridge_interruptCtrl_readIntEnable;
                io_apb_PRDATA[8:8] = bridge_interruptCtrl_writeInt;
                io_apb_PRDATA[9:9] = bridge_interruptCtrl_readInt;
            end
            5'h10: begin
                io_apb_PRDATA[0:0] = bridge_misc_readError;
                io_apb_PRDATA[1:1] = bridge_misc_readOverflowError;
                io_apb_PRDATA[8:8] = uartCtrl_1_io_readBreak;
                io_apb_PRDATA[9:9] = bridge_misc_breakDetected;
            end
            default: begin
            end
        endcase
    end

    assign busCtrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
    assign busCtrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (!io_apb_PWRITE));
    assign busCtrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
    assign busCtrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
    assign bridge_busCtrlWrapped_readErrorFlag = 1'b0;
    assign bridge_busCtrlWrapped_writeErrorFlag = 1'b0;
    assign _zz_1 = zz_bridge_uartConfigReg_clockDivider(1'b0);
    always @(*) bridge_uartConfigReg_clockDivider = _zz_1;
    assign bridge_uartConfigReg_frame_dataLength = 3'b111;
    assign bridge_uartConfigReg_frame_parity = UartParityType_NONE;
    assign bridge_uartConfigReg_frame_stop = UartStopType_ONE;
    always @(*) begin
        _zz_bridge_write_streamUnbuffered_valid = 1'b0;
        case (io_apb_PADDR)
            5'h0: begin
                if (busCtrl_doWrite) begin
                    _zz_bridge_write_streamUnbuffered_valid = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign bridge_write_streamUnbuffered_valid = _zz_bridge_write_streamUnbuffered_valid;
    assign bridge_write_streamUnbuffered_payload = io_apb_PWDATA[7:0];
    assign bridge_write_streamUnbuffered_ready = bridge_write_streamUnbuffered_queueWithOccupancy_io_push_ready;
    always @(*) begin
        bridge_read_streamBreaked_valid = system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_valid;
        if (uartCtrl_1_io_readBreak) begin
            bridge_read_streamBreaked_valid = 1'b0;
        end
    end

    always @(*) begin
        system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_ready = bridge_read_streamBreaked_ready;
        if (uartCtrl_1_io_readBreak) begin
            system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_ready = 1'b1;
        end
    end

    assign bridge_read_streamBreaked_payload = system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_pop_payload;
    always @(*) begin
        bridge_read_streamBreaked_ready = 1'b0;
        case (io_apb_PADDR)
            5'h0: begin
                if (busCtrl_doRead) begin
                    bridge_read_streamBreaked_ready = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign bridge_interruptCtrl_readInt = (bridge_interruptCtrl_readIntEnable && bridge_read_streamBreaked_valid);
    assign bridge_interruptCtrl_writeInt = (bridge_interruptCtrl_writeIntEnable && (! bridge_write_streamUnbuffered_queueWithOccupancy_io_pop_valid));
    assign bridge_interruptCtrl_interrupt = (bridge_interruptCtrl_readInt || bridge_interruptCtrl_writeInt);
    always @(*) begin
        when_BusSlaveFactory_l341 = 1'b0;
        case (io_apb_PADDR)
            5'h10: begin
                if (busCtrl_doWrite) begin
                    when_BusSlaveFactory_l341 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign when_BusSlaveFactory_l347 = io_apb_PWDATA[0];
    always @(*) begin
        when_BusSlaveFactory_l341_1 = 1'b0;
        case (io_apb_PADDR)
            5'h10: begin
                if (busCtrl_doWrite) begin
                    when_BusSlaveFactory_l341_1 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign when_BusSlaveFactory_l347_1 = io_apb_PWDATA[1];
    assign system_uartCtrl_uartCtrl_1_io_read_isStall = (uartCtrl_1_io_read_valid && (! system_uartCtrl_uartCtrl_1_io_read_queueWithOccupancy_io_push_ready));
    assign when_UartCtrl_l155 = (uartCtrl_1_io_readBreak && (! system_uartCtrl_uartCtrl_1_io_readBreak_regNext));
    always @(*) begin
        when_BusSlaveFactory_l341_2 = 1'b0;
        case (io_apb_PADDR)
            5'h10: begin
                if (busCtrl_doWrite) begin
                    when_BusSlaveFactory_l341_2 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign when_BusSlaveFactory_l347_2 = io_apb_PWDATA[9];
    always @(*) begin
        when_BusSlaveFactory_l377 = 1'b0;
        case (io_apb_PADDR)
            5'h10: begin
                if (busCtrl_doWrite) begin
                    when_BusSlaveFactory_l377 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign when_BusSlaveFactory_l379 = io_apb_PWDATA[10];
    always @(*) begin
        when_BusSlaveFactory_l341_3 = 1'b0;
        case (io_apb_PADDR)
            5'h10: begin
                if (busCtrl_doWrite) begin
                    when_BusSlaveFactory_l341_3 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign when_BusSlaveFactory_l347_3 = io_apb_PWDATA[11];
    assign io_interrupt = bridge_interruptCtrl_interrupt;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            bridge_interruptCtrl_writeIntEnable <= 1'b0;
            bridge_interruptCtrl_readIntEnable <= 1'b0;
            bridge_misc_readError <= 1'b0;
            bridge_misc_readOverflowError <= 1'b0;
            bridge_misc_breakDetected <= 1'b0;
            bridge_misc_doBreak <= 1'b0;
        end else begin
            if (when_BusSlaveFactory_l341) begin
                if (when_BusSlaveFactory_l347) begin
                    bridge_misc_readError <= _zz_bridge_misc_readError[0];
                end
            end
            if (uartCtrl_1_io_readError) begin
                bridge_misc_readError <= 1'b1;
            end
            if (when_BusSlaveFactory_l341_1) begin
                if (when_BusSlaveFactory_l347_1) begin
                    bridge_misc_readOverflowError <= _zz_bridge_misc_readOverflowError[0];
                end
            end
            if (system_uartCtrl_uartCtrl_1_io_read_isStall) begin
                bridge_misc_readOverflowError <= 1'b1;
            end
            if (when_UartCtrl_l155) begin
                bridge_misc_breakDetected <= 1'b1;
            end
            if (when_BusSlaveFactory_l341_2) begin
                if (when_BusSlaveFactory_l347_2) begin
                    bridge_misc_breakDetected <= _zz_bridge_misc_breakDetected[0];
                end
            end
            if (when_BusSlaveFactory_l377) begin
                if (when_BusSlaveFactory_l379) begin
                    bridge_misc_doBreak <= _zz_bridge_misc_doBreak[0];
                end
            end
            if (when_BusSlaveFactory_l341_3) begin
                if (when_BusSlaveFactory_l347_3) begin
                    bridge_misc_doBreak <= _zz_bridge_misc_doBreak_1[0];
                end
            end
            case (io_apb_PADDR)
                5'h04: begin
                    if (busCtrl_doWrite) begin
                        bridge_interruptCtrl_writeIntEnable <= io_apb_PWDATA[0];
                        bridge_interruptCtrl_readIntEnable  <= io_apb_PWDATA[1];
                    end
                end
                default: begin
                end
            endcase
        end
    end

    always @(posedge io_mainClk) begin
        system_uartCtrl_uartCtrl_1_io_readBreak_regNext <= uartCtrl_1_io_readBreak;
    end

endmodule
