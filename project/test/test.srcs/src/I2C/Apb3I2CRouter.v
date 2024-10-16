`timescale 1ns / 1ps

module Apb3I2CRouter (
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

    input  wire I2C1_SDA,
    output wire I2C1_SCL,
    output wire I2C1_interrupt,
    input  wire I2C2_SDA,
    output wire I2C2_SCL,
    output wire I2C2_interrupt
);

    reg  [15:0] Apb3PSEL = 16'h0000;
    // I2C1
    wire [ 3:0] io_apb_PADDR_I2C1 = io_apb_PADDR[5:2];
    wire        io_apb_PSEL_I2C1 = Apb3PSEL[0];
    wire        io_apb_PENABLE_I2C1 = io_apb_PENABLE;
    wire        io_apb_PREADY_I2C1;
    wire        io_apb_PWRITE_I2C1 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_I2C1 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_I2C1;
    wire        io_apb_PSLVERROR_I2C1 = 1'b0;
    // I2C2
    wire [ 3:0] io_apb_PADDR_I2C2 = io_apb_PADDR[5:2];
    wire        io_apb_PSEL_I2C2 = Apb3PSEL[1];
    wire        io_apb_PENABLE_I2C2 = io_apb_PENABLE;
    wire        io_apb_PREADY_I2C2;
    wire        io_apb_PWRITE_I2C2 = io_apb_PWRITE;
    wire [31:0] io_apb_PWDATA_I2C2 = io_apb_PWDATA;
    wire [31:0] io_apb_PRDATA_I2C2;
    wire        io_apb_PSLVERROR_I2C2 = 1'b0;

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
                    _zz_io_apb_PREADY = io_apb_PREADY_I2C1;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_I2C1;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_I2C1;
                end
                16'h0002: begin
                    _zz_io_apb_PREADY = io_apb_PREADY_I2C2;
                    _zz_io_apb_PRDATA = io_apb_PRDATA_I2C2;
                    _zz_io_apb_PSLVERROR = io_apb_PSLVERROR_I2C2;
                end
                default: ;
            endcase
    end

    always @(*) begin
        if (io_apb_PRESET) begin
            Apb3PSEL = 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_apb_PADDR[15:12] == 4'd0) && io_apb_PSEL[0]);  // I2C1
            Apb3PSEL[1] = ((io_apb_PADDR[15:12] == 4'd1) && io_apb_PSEL[0]);  // I2C2
        end
    end

    Apb3I2C Apb3I2C1 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_I2C1),    // i
        .io_apb_PSEL   (io_apb_PSEL_I2C1),     // i
        .io_apb_PENABLE(io_apb_PENABLE_I2C1),  // i
        .io_apb_PREADY (io_apb_PREADY_I2C1),   // o
        .io_apb_PWRITE (io_apb_PWRITE_I2C1),   // i
        .io_apb_PWDATA (io_apb_PWDATA_I2C1),   // i
        .io_apb_PRDATA (io_apb_PRDATA_I2C1),   // o
        .I2C_SDA       (I2C1_SDA),             // i
        .I2C_SCL       (I2C1_SCL),             // o
        .interrupt     (I2C1_interrupt)        // o
    );

    Apb3I2C Apb3I2C2 (
        .io_apb_PCLK   (io_apb_PCLK),          // i
        .io_apb_PRESET (io_apb_PRESET),        // i
        .io_apb_PADDR  (io_apb_PADDR_I2C2),    // i
        .io_apb_PSEL   (io_apb_PSEL_I2C2),     // i
        .io_apb_PENABLE(io_apb_PENABLE_I2C2),  // i
        .io_apb_PREADY (io_apb_PREADY_I2C2),   // o
        .io_apb_PWRITE (io_apb_PWRITE_I2C2),   // i
        .io_apb_PWDATA (io_apb_PWDATA_I2C2),   // i
        .io_apb_PRDATA (io_apb_PRDATA_I2C2),   // o
        .I2C_SDA       (I2C2_SDA),             // i
        .I2C_SCL       (I2C2_SCL),             // o
        .interrupt     (I2C1_interrupt)        // o
    );

endmodule
