`timescale 1ns / 1ps

module BufferCC_GPIO (
    input  wire [31:0] io_dataIn,
    output wire [31:0] io_dataOut,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    (* async_reg = "true" *)reg [31:0] buffers_0;
    (* async_reg = "true" *)reg [31:0] buffers_1;

    assign io_dataOut = buffers_1;
    always @(posedge io_mainClk) begin
        buffers_0 <= io_dataIn;
        buffers_1 <= buffers_0;
    end

endmodule
