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
