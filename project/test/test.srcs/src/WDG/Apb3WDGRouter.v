`timescale 1ns / 1ps

module Apb3WDGRouter (
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

    output wire IWDG_rst,
    output wire WWDG_rst
);

    reg  [15:0] Apb3PSEL;
    // IWDG
    wire [ 2:0] io_apb_PADDR_IWDG = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_IWDG = Apb3PSEL[0];
    wire        io_apb_PENABLE_IWDG = io_apb_PENABLE;
    wire        io_apb_PREADY_IWDG;
    wire        io_apb_PWRITE_IWDG = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_IWDG = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_IWDG;
    wire        io_apb_PSLVERROR_IWDG = 1'b0;
    //WWDG
    wire [ 2:0] io_apb_PADDR_WWDG = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_WWDG = Apb3PSEL[1];
    wire        io_apb_PENABLE_WWDG = io_apb_PENABLE;
    wire        io_apb_PREADY_WWDG;
    wire        io_apb_PWRITE_WWDG = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_WWDG = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_WWDG;
    wire        io_apb_PSLVERROR_WWDG = 1'b0;

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
                16'h0001: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_IWDG;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_IWDG;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_IWDG;
                end
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_WWDG;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_WWDG;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_WWDG;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL <= 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // IWDT
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // WWDT
        end
    end

    IWDG IWDG (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_IWDG),    // i
        .io_apb_PSEL   (io_apb_PSEL_IWDG),     // i
        .io_apb_PENABLE(io_apb_PENABLE_IWDG),  // i
        .io_apb_PREADY (io_apb_PREADY_IWDG),   // o
        .io_apb_PWRITE (io_apb_PWRITE_IWDG),   // i
        .io_apb_PWDATA (io_apb_PWDATA_IWDG),   // i
        .io_apb_PRDATA (io_apb_PRDATA_IWDG),   // o
        .IWDG_rst      (IWDG_rst)              // o
    );

    WWDG WWDG (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_WWDG),    // i
        .io_apb_PSEL   (io_apb_PSEL_WWDG),     // i
        .io_apb_PENABLE(io_apb_PENABLE_WWDG),  // i
        .io_apb_PREADY (io_apb_PREADY_WWDG),   // o
        .io_apb_PWRITE (io_apb_PWRITE_WWDG),   // i
        .io_apb_PWDATA (io_apb_PWDATA_WWDG),   // i
        .io_apb_PRDATA (io_apb_PRDATA_WWDG),   // o
        .WWDG_rst      (WWDG_rst)              // o
    );

endmodule
