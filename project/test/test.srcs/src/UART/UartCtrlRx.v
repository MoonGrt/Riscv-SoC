`timescale 1ns / 1ps

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
