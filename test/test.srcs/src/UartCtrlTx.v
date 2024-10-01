`timescale 1ns / 1ps

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
