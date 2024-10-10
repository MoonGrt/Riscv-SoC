`timescale 1ns / 1ps

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
