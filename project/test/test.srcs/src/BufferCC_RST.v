`timescale 1ns / 1ps

module BufferCC_RST (
    input  wire io_dataIn,
    output wire io_dataOut,
    input  wire io_mainClk
);

    (* async_reg = "true" *)reg buffers_0;
    (* async_reg = "true" *)reg buffers_1;

    assign io_dataOut = buffers_1;
    always @(posedge io_mainClk) begin
        buffers_0 <= io_dataIn;
        buffers_1 <= buffers_0;
    end

endmodule
