module FlowCCUnsafeByToggle (
    input  wire       io_input_valid,
    input  wire       io_input_payload_last,
    input  wire [0:0] io_input_payload_fragment,
    output wire       io_output_valid,
    output wire       io_output_payload_last,
    output wire [0:0] io_output_payload_fragment,
    input  wire       io_jtag_tck,
    input  wire       io_mainClk,
    input  wire       resetCtrl_mainClkReset
);

    wire       inputArea_target_buffercc_io_dataOut;
    reg        inputArea_target;
    reg        inputArea_data_last;
    reg  [0:0] inputArea_data_fragment;
    wire       outputArea_target;
    reg        outputArea_hit;
    wire       outputArea_flow_valid;
    wire       outputArea_flow_payload_last;
    wire [0:0] outputArea_flow_payload_fragment;
    reg        outputArea_flow_m2sPipe_valid;
    (* async_reg = "true" *)reg        outputArea_flow_m2sPipe_payload_last;
    (* async_reg = "true" *)reg  [0:0] outputArea_flow_m2sPipe_payload_fragment;

    (* keep_hierarchy = "TRUE" *) BufferCC_JTAG BufferCC_JTAG (
        .io_dataIn             (inputArea_target),                      //i
        .io_dataOut            (inputArea_target_buffercc_io_dataOut),  //o
        .io_mainClk            (io_mainClk),                            //i
        .resetCtrl_mainClkReset(resetCtrl_mainClkReset)                 //i
    );
    initial begin
`ifndef SYNTHESIS
        inputArea_target = $urandom;
        outputArea_hit   = $urandom;
`endif
    end

    assign outputArea_target = inputArea_target_buffercc_io_dataOut;
    assign outputArea_flow_valid = (outputArea_target != outputArea_hit);
    assign outputArea_flow_payload_last = inputArea_data_last;
    assign outputArea_flow_payload_fragment = inputArea_data_fragment;
    assign io_output_valid = outputArea_flow_m2sPipe_valid;
    assign io_output_payload_last = outputArea_flow_m2sPipe_payload_last;
    assign io_output_payload_fragment = outputArea_flow_m2sPipe_payload_fragment;
    always @(posedge io_jtag_tck) begin
        if (io_input_valid) begin
            inputArea_target <= (!inputArea_target);
            inputArea_data_last <= io_input_payload_last;
            inputArea_data_fragment <= io_input_payload_fragment;
        end
    end

    always @(posedge io_mainClk) begin
        outputArea_hit <= outputArea_target;
        if (outputArea_flow_valid) begin
            outputArea_flow_m2sPipe_payload_last <= outputArea_flow_payload_last;
            outputArea_flow_m2sPipe_payload_fragment <= outputArea_flow_payload_fragment;
        end
    end

    always @(posedge io_mainClk or posedge resetCtrl_mainClkReset) begin
        if (resetCtrl_mainClkReset) begin
            outputArea_flow_m2sPipe_valid <= 1'b0;
        end else begin
            outputArea_flow_m2sPipe_valid <= outputArea_flow_valid;
        end
    end


endmodule
