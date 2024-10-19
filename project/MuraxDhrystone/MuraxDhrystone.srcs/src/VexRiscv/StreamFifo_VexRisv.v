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
