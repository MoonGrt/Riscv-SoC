`timescale 1ns / 1ps

module Apb3Decoder (
    input  wire [19:0] io_input_PADDR,
    input  wire [ 0:0] io_input_PSEL,
    input  wire        io_input_PENABLE,
    output reg         io_input_PREADY,
    input  wire        io_input_PWRITE,
    input  wire [31:0] io_input_PWDATA,
    output wire [31:0] io_input_PRDATA,
    output reg         io_input_PSLVERROR,
    output wire [19:0] io_output_PADDR,
    output reg  [ 3:0] io_output_PSEL,
    output wire        io_output_PENABLE,
    input  wire        io_output_PREADY,
    output wire        io_output_PWRITE,
    output wire [31:0] io_output_PWDATA,
    input  wire [31:0] io_output_PRDATA,
    input  wire        io_output_PSLVERROR
);

    wire when_Apb3Decoder_l88;

    assign io_output_PADDR   = io_input_PADDR;
    assign io_output_PENABLE = io_input_PENABLE;
    assign io_output_PWRITE  = io_input_PWRITE;
    assign io_output_PWDATA  = io_input_PWDATA;
    always @(*) begin
        io_output_PSEL[0] = (((io_input_PADDR & (20'hFF000)) == 20'h0) && io_input_PSEL[0]);
        io_output_PSEL[1] = (((io_input_PADDR & (20'hFF000)) == 20'h10000) && io_input_PSEL[0]);
        io_output_PSEL[2] = (((io_input_PADDR & (20'hFF000)) == 20'h20000) && io_input_PSEL[0]);
        io_output_PSEL[3] = (((io_input_PADDR & (20'hFF000)) == 20'h30000) && io_input_PSEL[0]);  // new
    end

    always @(*) begin
        io_input_PREADY = io_output_PREADY;
        if (when_Apb3Decoder_l88) begin
            io_input_PREADY = 1'b1;
        end
    end

    assign io_input_PRDATA = io_output_PRDATA;
    always @(*) begin
        io_input_PSLVERROR = io_output_PSLVERROR;
        if (when_Apb3Decoder_l88) begin
            io_input_PSLVERROR = 1'b1;
        end
    end

    assign when_Apb3Decoder_l88 = (io_input_PSEL[0] && (io_output_PSEL == 3'b000));

endmodule
