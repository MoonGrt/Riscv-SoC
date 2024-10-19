`timescale 1ns / 1ps

module Apb3Router (
    input  wire [19:0] io_input_PADDR,
    input  wire [15:0] io_input_PSEL,
    input  wire        io_input_PENABLE,
    output wire        io_input_PREADY,
    input  wire        io_input_PWRITE,
    input  wire [31:0] io_input_PWDATA,
    output wire [31:0] io_input_PRDATA,
    output wire        io_input_PSLVERROR,

    output wire [19:0] io_outputs_0_PADDR,
    output wire [ 0:0] io_outputs_0_PSEL,
    output wire        io_outputs_0_PENABLE,
    input  wire        io_outputs_0_PREADY,
    output wire        io_outputs_0_PWRITE,
    output wire [31:0] io_outputs_0_PWDATA,
    input  wire [31:0] io_outputs_0_PRDATA,
    input  wire        io_outputs_0_PSLVERROR,
    output wire [19:0] io_outputs_1_PADDR,
    output wire [ 0:0] io_outputs_1_PSEL,
    output wire        io_outputs_1_PENABLE,
    input  wire        io_outputs_1_PREADY,
    output wire        io_outputs_1_PWRITE,
    output wire [31:0] io_outputs_1_PWDATA,
    input  wire [31:0] io_outputs_1_PRDATA,
    input  wire        io_outputs_1_PSLVERROR,
    output wire [19:0] io_outputs_2_PADDR,
    output wire [ 0:0] io_outputs_2_PSEL,
    output wire        io_outputs_2_PENABLE,
    input  wire        io_outputs_2_PREADY,
    output wire        io_outputs_2_PWRITE,
    output wire [31:0] io_outputs_2_PWDATA,
    input  wire [31:0] io_outputs_2_PRDATA,
    input  wire        io_outputs_2_PSLVERROR,

    output wire [19:0] io_outputs_3_PADDR,  // GPIO2
    output wire [15:0] io_outputs_3_PSEL,  // GPIO2
    output wire        io_outputs_3_PENABLE,  // GPIO2
    input  wire        io_outputs_3_PREADY,  // GPIO2
    output wire        io_outputs_3_PWRITE,  // GPIO2
    output wire [31:0] io_outputs_3_PWDATA,  // GPIO2
    input  wire [31:0] io_outputs_3_PRDATA,  // GPIO2
    input  wire        io_outputs_3_PSLVERROR,  // GPIO2
    output wire [19:0] io_outputs_4_PADDR,  // WDG
    output wire [ 0:0] io_outputs_4_PSEL,  // WDG
    output wire        io_outputs_4_PENABLE,  // WDG
    input  wire        io_outputs_4_PREADY,  // WDG
    output wire        io_outputs_4_PWRITE,  // WDG
    output wire [31:0] io_outputs_4_PWDATA,  // WDG
    input  wire [31:0] io_outputs_4_PRDATA,  // WDG
    input  wire        io_outputs_4_PSLVERROR,  // WDG

    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    reg         _zz_io_input_PREADY;
    reg  [31:0] _zz_io_input_PRDATA;
    reg         _zz_io_input_PSLVERROR;
    reg  [15:0] selIndex;

    always @(*) begin
        case (selIndex)
            16'h0001: begin
                _zz_io_input_PREADY = io_outputs_0_PREADY;
                _zz_io_input_PRDATA = io_outputs_0_PRDATA;
                _zz_io_input_PSLVERROR = io_outputs_0_PSLVERROR;
            end
            16'h0002: begin
                _zz_io_input_PREADY = io_outputs_1_PREADY;
                _zz_io_input_PRDATA = io_outputs_1_PRDATA;
                _zz_io_input_PSLVERROR = io_outputs_1_PSLVERROR;
            end
            16'h0004: begin
                _zz_io_input_PREADY = io_outputs_2_PREADY;
                _zz_io_input_PRDATA = io_outputs_2_PRDATA;
                _zz_io_input_PSLVERROR = io_outputs_2_PSLVERROR;
            end
            16'h0008: begin
                _zz_io_input_PREADY = io_outputs_3_PREADY;
                _zz_io_input_PRDATA = io_outputs_3_PRDATA;
                _zz_io_input_PSLVERROR = io_outputs_3_PSLVERROR;
            end
            16'h0010: begin
                _zz_io_input_PREADY = io_outputs_4_PREADY;
                _zz_io_input_PRDATA = io_outputs_4_PRDATA;
                _zz_io_input_PSLVERROR = io_outputs_4_PSLVERROR;
            end
            default: ;
        endcase
    end

    assign io_outputs_0_PADDR = io_input_PADDR;
    assign io_outputs_0_PENABLE = io_input_PENABLE;
    assign io_outputs_0_PSEL[0] = io_input_PSEL[0];
    assign io_outputs_0_PWRITE = io_input_PWRITE;
    assign io_outputs_0_PWDATA = io_input_PWDATA;
    assign io_outputs_1_PADDR = io_input_PADDR;
    assign io_outputs_1_PENABLE = io_input_PENABLE;
    assign io_outputs_1_PSEL[0] = io_input_PSEL[1];
    assign io_outputs_1_PWRITE = io_input_PWRITE;
    assign io_outputs_1_PWDATA = io_input_PWDATA;
    assign io_outputs_2_PADDR = io_input_PADDR;
    assign io_outputs_2_PENABLE = io_input_PENABLE;
    assign io_outputs_2_PSEL[0] = io_input_PSEL[2];
    assign io_outputs_2_PWRITE = io_input_PWRITE;
    assign io_outputs_2_PWDATA = io_input_PWDATA;

    assign io_outputs_3_PADDR = io_input_PADDR;  // GPIO2
    assign io_outputs_3_PENABLE = io_input_PENABLE;  // GPIO2
    assign io_outputs_3_PSEL[0] = io_input_PSEL[3];  // GPIO2
    assign io_outputs_3_PWRITE = io_input_PWRITE;  // GPIO2
    assign io_outputs_3_PWDATA = io_input_PWDATA;  // GPIO2

    assign io_input_PREADY = _zz_io_input_PREADY;
    assign io_input_PRDATA = _zz_io_input_PRDATA;
    assign io_input_PSLVERROR = _zz_io_input_PSLVERROR;
    always @(posedge io_mainClk) begin
        selIndex <= io_input_PSEL;
    end

endmodule
