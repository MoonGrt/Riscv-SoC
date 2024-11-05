module filler #(
    parameter H_DISP = 12'd1280
) (
    input wire        clk,
    input wire        rst_n,
    input wire        EN,

    input  wire        pre_vs,
    input  wire        pre_de,
    input  wire [23:0] pre_data,
    output wire        post_vs,
    output wire        post_de,
    output wire [23:0] post_data
);

    localparam BLACK = 24'b0;
    reg  [11:0] pixel_x = 0;
    reg  [11:0] brank_cnt = 0;
    wire [11:0] brank_size = pre_de ? (H_DISP - pixel_x) : brank_size;
    wire        fill_flag = brank_cnt < brank_size;

    always @(posedge clk) begin
        if (~rst_n | pre_vs) pixel_x <= 0;
        else if (pre_de) pixel_x <= pixel_x + 1;
        else pixel_x <= 0;
    end

    always @(posedge clk) begin
        if (~rst_n | pre_vs) brank_cnt <= 0;
        else if (fill_flag && ~pre_de) brank_cnt <= brank_cnt + 1;
        else if (pre_de) brank_cnt <= 0;
        else brank_cnt <= brank_cnt;
    end

    assign post_vs = pre_vs;
    assign post_de = EN ? (pre_de | fill_flag) : pre_de;
    assign post_data = EN ? (pre_de ? pre_data : BLACK) : pre_data;

endmodule
