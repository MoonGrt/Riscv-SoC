`timescale 1ns / 1ps

module Apb3TIMRouter (
    input  wire        io_apb_PCLK,
    input  wire        io_apb_PRESET,
    input  wire [15:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire [31:0] io_apb_PRDATA,
    output wire        io_apb_PSLVERROR,

    output wire [3:0] TIM2_CH,
    output wire       TIM2_interrupt,
    output wire [3:0] TIM3_CH,
    output wire       TIM3_interrupt
);

    reg  [15:0] Apb3PSEL = 16'h0000;
    // TIM2
    wire [ 4:0] io_apb_PADDR_TIM2 = io_apb_PADDR[6:2];
    wire        io_apb_PSEL_TIM2 = Apb3PSEL[1];
    wire        io_apb_PENABLE_TIM2 = io_apb_PENABLE;
    wire        io_apb_PREADY_TIM2;
    wire        io_apb_PWRITE_TIM2 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_TIM2 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_TIM2;
    wire        io_apb_PSLVERROR_TIM2 = 1'b0;
    // TIM3
    wire [ 4:0] io_apb_PADDR_TIM3 = io_apb_PADDR[6:2];
    wire        io_apb_PSEL_TIM3 = Apb3PSEL[2];
    wire        io_apb_PENABLE_TIM3 = io_apb_PENABLE;
    wire        io_apb_PREADY_TIM3;
    wire        io_apb_PWRITE_TIM3 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_TIM3 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_TIM3;
    wire        io_apb_PSLVERROR_TIM3 = 1'b0;

    reg [15:0] selIndex;
    reg        _zz_io_apb_PREADY;
    reg [31:0] _zz_io_apb_PRDATA;
    reg        _zz_io_apb_PSLVERROR;
    assign io_apb_PREADY = _zz_io_apb_PREADY;
    assign io_apb_PRDATA = _zz_io_apb_PRDATA;
    assign io_apb_PSLVERROR = _zz_io_apb_PSLVERROR;
    always @(posedge io_apb_PCLK) selIndex <= Apb3PSEL;
    always @(*) begin
        if (io_apb_PRESET) begin
            _zz_io_apb_PREADY <= 1'b1;
            _zz_io_apb_PRDATA <= 32'h0;
            _zz_io_apb_PSLVERROR <= 1'b0;
        end
        else
            case (selIndex)
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_TIM2;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_TIM2;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_TIM2;
                end
                16'h0004: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_TIM3;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_TIM3;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_TIM3;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL = 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // TIM1
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // TIM2
            Apb3PSEL[2] = ((io_apb_PADDR[15:12] == 4'd2) && io_apb_PSEL[0]);  // TIM3
        end
    end

    Apb3TIM Apb3TIM2 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_TIM2),    // i
        .io_apb_PSEL   (io_apb_PSEL_TIM2),     // i
        .io_apb_PENABLE(io_apb_PENABLE_TIM2),  // i
        .io_apb_PREADY (io_apb_PREADY_TIM2),   // o
        .io_apb_PWRITE (io_apb_PWRITE_TIM2),   // i
        .io_apb_PWDATA (io_apb_PWDATA_TIM2),   // i
        .io_apb_PRDATA (io_apb_PRDATA_TIM2),   // o
        .TIM_CH        (TIM2_CH),              // o
        .interrupt     (TIM2_interrupt)        // o
    );

    Apb3TIM Apb3TIM3 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_TIM3),    // i
        .io_apb_PSEL   (io_apb_PSEL_TIM3),     // i
        .io_apb_PENABLE(io_apb_PENABLE_TIM3),  // i
        .io_apb_PREADY (io_apb_PREADY_TIM3),   // o
        .io_apb_PWRITE (io_apb_PWRITE_TIM3),   // i
        .io_apb_PWDATA (io_apb_PWDATA_TIM3),   // i
        .io_apb_PRDATA (io_apb_PRDATA_TIM3),   // o
        .TIM_CH        (TIM3_CH),              // o
        .interrupt     (TIM3_interrupt)        // o
    );

endmodule
