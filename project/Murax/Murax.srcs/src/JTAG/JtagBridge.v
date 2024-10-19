`timescale 1ns / 1ps

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
