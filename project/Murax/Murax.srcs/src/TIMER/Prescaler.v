`timescale 1ns / 1ps

module Prescaler (
    input  wire        io_clear,
    input  wire [15:0] io_limit,
    output wire        io_overflow,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    reg  [15:0] counter;
    wire        when_Prescaler_l17;

    assign when_Prescaler_l17 = (io_clear || io_overflow);
    assign io_overflow = (counter == io_limit);
    always @(posedge io_mainClk) begin
        counter <= (counter + 16'h0001);
        if (when_Prescaler_l17) begin
            counter <= 16'h0;
        end
    end

endmodule
