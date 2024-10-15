`timescale 1ns / 1ps

module Apb3SPIRouter (
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

    output wire SPI1_SCK,
    output wire SPI1_MOSI,
    input  wire SPI1_MISO,
    output wire SPI1_CS,
    output wire SPI1_interrupt,
    output wire SPI2_SCK,
    output wire SPI2_MOSI,
    input  wire SPI2_MISO,
    output wire SPI2_CS,
    output wire SPI2_interrupt
);

    reg  [15:0] Apb3PSEL = 16'h0000;
    // GPIOA
    wire [ 2:0] io_apb_PADDR_GPIOA = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_GPIOA = Apb3PSEL[0];
    wire        io_apb_PENABLE_GPIOA = io_apb_PENABLE;
    wire        io_apb_PREADY_GPIOA;
    wire        io_apb_PWRITE_GPIOA = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_GPIOA = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_GPIOA;
    wire        io_apb_PSLVERROR_GPIOA = 1'b0;
    // GPIOB
    wire [ 2:0] io_apb_PADDR_GPIOB = io_apb_PADDR[4:2];
    wire        io_apb_PSEL_GPIOB = Apb3PSEL[1];
    wire        io_apb_PENABLE_GPIOB = io_apb_PENABLE;
    wire        io_apb_PREADY_GPIOB;
    wire        io_apb_PWRITE_GPIOB = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_GPIOB = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_GPIOB;
    wire        io_apb_PSLVERROR_GPIOB = 1'b0;

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
                    _zz_io_apb_PREADY = io_apb_PREADY_GPIOA;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_GPIOA;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_GPIOA;
                end
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_GPIOB;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_GPIOB;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_GPIOB;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL = 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // GPIOA
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // GPIOB
        end
    end

    Apb3SPI Apb3SPI1 (
        .io_apb_PCLK   (io_apb_PCLK),           // i
        .io_apb_PRESET (io_apb_PRESET),         // i
        .io_apb_PADDR  (io_apb_PADDR_GPIOA),    // i
        .io_apb_PSEL   (io_apb_PSEL_GPIOA),     // i
        .io_apb_PENABLE(io_apb_PENABLE_GPIOA),  // i
        .io_apb_PREADY (io_apb_PREADY_GPIOA),   // o
        .io_apb_PWRITE (io_apb_PWRITE_GPIOA),   // i
        .io_apb_PWDATA (io_apb_PWDATA_GPIOA),   // i
        .io_apb_PRDATA (io_apb_PRDATA_GPIOA),   // o
        .SPI_SCK       (SPI1_SCK),              // o
        .SPI_MOSI      (SPI1_MOSI),             // o
        .SPI_MISO      (SPI1_MISO),             // i
        .SPI_CS        (SPI1_CS),               // o
        .interrupt     (SPI1_interrupt)         // o
    );

    Apb3SPI Apb3SPI2 (
        .io_apb_PCLK   (io_apb_PCLK),           // i
        .io_apb_PRESET (io_apb_PRESET),         // i
        .io_apb_PADDR  (io_apb_PADDR_GPIOA),    // i
        .io_apb_PSEL   (io_apb_PSEL_GPIOA),     // i
        .io_apb_PENABLE(io_apb_PENABLE_GPIOA),  // i
        .io_apb_PREADY (io_apb_PREADY_GPIOA),   // o
        .io_apb_PWRITE (io_apb_PWRITE_GPIOA),   // i
        .io_apb_PWDATA (io_apb_PWDATA_GPIOA),   // i
        .io_apb_PRDATA (io_apb_PRDATA_GPIOA),   // o
        .SPI_SCK       (SPI2_SCK),              // o
        .SPI_MOSI      (SPI2_MOSI),             // o
        .SPI_MISO      (SPI2_MISO),             // i
        .SPI_CS        (SPI2_CS),               // o
        .interrupt     (SPI2_interrupt)         // o
    );

endmodule
