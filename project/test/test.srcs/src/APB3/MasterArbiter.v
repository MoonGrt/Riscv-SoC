`timescale 1ns / 1ps

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
