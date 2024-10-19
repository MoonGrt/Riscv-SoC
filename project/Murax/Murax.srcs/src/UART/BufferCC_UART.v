`timescale 1ns / 1ps

module BufferCC_UART (
    input  wire io_dataIn,
    output wire io_dataOut,
    input  wire io_mainClk,
    input  wire resetCtrl_systemReset
);

    (* async_reg = "true" *)reg buffers_0;
    (* async_reg = "true" *)reg buffers_1;

    assign io_dataOut = buffers_1;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            buffers_0 <= 1'b0;
            buffers_1 <= 1'b0;
        end else begin
            buffers_0 <= io_dataIn;
            buffers_1 <= buffers_0;
        end
    end

endmodule
