`timescale 1ns / 1ps

module image_cut #(
    parameter H_DISP = 12'd1280,
    parameter V_DISP = 12'd720,
    parameter INPUT_X_RES_WIDTH = 11,  // Widths of input/output resolution control signals
    parameter INPUT_Y_RES_WIDTH = 11,
    parameter OUTPUT_X_RES_WIDTH = 11,
    parameter OUTPUT_Y_RES_WIDTH = 11
) (
    input wire clk,
    input wire clk_vp,
    input wire rst_n,
    input wire EN,

    input wire [ INPUT_X_RES_WIDTH-1:0] START_X,
    input wire [ INPUT_Y_RES_WIDTH-1:0] START_Y,
    input wire [OUTPUT_X_RES_WIDTH-1:0] END_X,
    input wire [OUTPUT_Y_RES_WIDTH-1:0] END_Y,

    input wire        vs_i,
    input wire        de_i,
    input wire [23:0] rgb_i,

    output wire        de_o,
    output wire        vs_o,
    output wire [23:0] rgb_o
);

    wire vs = vs_i;
    reg vs_reg1, vs_reg2;
    always @(posedge clk_vp) begin
        vs_reg1 <= vs;
        vs_reg2 <= vs_reg1;
    end

    reg [11:0] pixel_x, pixel_y;
    wire image_cut = (pixel_x >= START_X && pixel_x < END_X) && (pixel_y >= START_Y && pixel_y < END_Y);
    // wire vs = (START_X == 0 && START_Y == 0) ? vs_i : (pixel_x == START_X) & (pixel_y == START_Y);

    always @(posedge clk) begin
        if (~rst_n | vs_o) pixel_x <= 0;
        else if (de_i)
            if (pixel_x == H_DISP - 1) pixel_x <= 0;
            else pixel_x <= pixel_x + 1;
        else pixel_x <= pixel_x;
    end

    always @(posedge clk) begin
        if (~rst_n | vs_o) pixel_y <= 0;
        else if (pixel_x == H_DISP - 1)
            if (pixel_y == V_DISP - 1) pixel_y <= 0;
            else pixel_y <= pixel_y + 1;
        else pixel_y <= pixel_y;
    end

    assign vs_o  = EN ? (vs_reg1 & ~vs_reg2) : vs_i;
    assign de_o  = EN ? (image_cut & de_i) : de_i;
    assign rgb_o = EN ? rgb_i : rgb_i;

endmodule
