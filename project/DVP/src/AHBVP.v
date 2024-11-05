module AHBVP #(
    parameter H_DISP = 12'd1280,
    parameter V_DISP = 12'd720,
    parameter INPUT_X_RES_WIDTH = 11,
    parameter INPUT_Y_RES_WIDTH = 11,
    parameter OUTPUT_X_RES_WIDTH = 11,
    parameter OUTPUT_Y_RES_WIDTH = 11
) (
    input clk_vp,
    input rst_n,

    // VP parameters
    input [31:0] VP_CR,
    input [31:0] VP_START,
    input [31:0] VP_END,
    input [31:0] VP_SCALER,

    // video input
    input        vi_clk,
    input        vi_vs,
    input        vi_de,
    input [15:0] vi_data,

    // video process
    output        vp_clk,
    output        vp_vs,
    output        vp_de,
    output [15:0] vp_data
);

    // VP parameters
    // wire       cuter_en = VP_CR[0];
    // wire [1:0] filter_mode = VP_CR[2:1];
    // wire       scaler_en = VP_CR[3];
    wire       cuter_en = 1'b0;
    wire [1:0] filter_mode = 2'b01;
    wire       scaler_en = 1'b1;
    // wire [ INPUT_X_RES_WIDTH-1:0] START_X = VP_START[INPUT_X_RES_WIDTH-1:0];
    // wire [ INPUT_Y_RES_WIDTH-1:0] START_Y = VP_START[INPUT_X_RES_WIDTH-1+16:0+16];
    // wire [OUTPUT_X_RES_WIDTH-1:0] END_X = VP_END[OUTPUT_X_RES_WIDTH-1:0];
    // wire [OUTPUT_Y_RES_WIDTH-1:0] END_Y = VP_END[OUTPUT_X_RES_WIDTH-1+16:0+16];


    // Video Parameters
    // 放大
    // reg [ INPUT_X_RES_WIDTH-1:0] START_X = H_DISP / 10 * 1 /*synthesis preserve*/;
    // reg [ INPUT_Y_RES_WIDTH-1:0] START_Y = V_DISP / 10 * 1 /*synthesis preserve*/;
    // reg [OUTPUT_X_RES_WIDTH-1:0] END_X = H_DISP / 10 * 1 + H_DISP / 2 /*synthesis preserve*/;
    // reg [OUTPUT_Y_RES_WIDTH-1:0] END_Y = V_DISP / 10 * 1 + V_DISP / 2 /*synthesis preserve*/;
    // reg [OUTPUT_X_RES_WIDTH-1:0] OUTPUT_X_RES = H_DISP - 1 /*synthesis preserve*/;  // Resolution of output data minus 1
    // reg [OUTPUT_Y_RES_WIDTH-1:0] OUTPUT_Y_RES = V_DISP - 1 /*synthesis preserve*/;  // Resolution of output data minus 1
    // 原图
    reg [ INPUT_X_RES_WIDTH-1:0] START_X = 0 /*synthesis preserve*/;
    reg [ INPUT_Y_RES_WIDTH-1:0] START_Y = 0 /*synthesis preserve*/;
    reg [OUTPUT_X_RES_WIDTH-1:0] END_X = H_DISP /*synthesis preserve*/;
    reg [OUTPUT_Y_RES_WIDTH-1:0] END_Y = V_DISP /*synthesis preserve*/;
    reg [OUTPUT_X_RES_WIDTH-1:0] OUTPUT_X_RES = H_DISP - 1 /*synthesis preserve*/;  // Resolution of output data minus 1
    reg [OUTPUT_Y_RES_WIDTH-1:0] OUTPUT_Y_RES = V_DISP - 1 /*synthesis preserve*/;  // Resolution of output data minus 1
    // 缩小
    // reg [ INPUT_X_RES_WIDTH-1:0] START_X = 0 /*synthesis preserve*/;
    // reg [ INPUT_Y_RES_WIDTH-1:0] START_Y = 0 /*synthesis preserve*/;
    // reg [OUTPUT_X_RES_WIDTH-1:0] END_X = H_DISP /*synthesis preserve*/;
    // reg [OUTPUT_Y_RES_WIDTH-1:0] END_Y = V_DISP /*synthesis preserve*/;
    // reg [OUTPUT_X_RES_WIDTH-1:0] OUTPUT_X_RES = H_DISP / 2 - 1 /*synthesis preserve*/;  // Resolution of output data minus 1
    // reg [OUTPUT_Y_RES_WIDTH-1:0] OUTPUT_Y_RES = V_DISP / 2 - 1 /*synthesis preserve*/;  // Resolution of output data minus 1

    //--------------------------------------------------------------------------
    // Scaler
    //--------------------------------------------------------------------------
    wire vs_i = vi_vs;
    wire de_i = vi_de;
    wire [23:0] rgb_i = {vi_data[15:11], 3'b0, vi_data[10:5], 2'b0, vi_data[4:0], 3'b0};
    wire image_cut_de, image_cut_vs;
    wire [23:0] image_cut_rgb;
    image_cut #(
        .H_DISP(H_DISP),
        .V_DISP(V_DISP),
        .INPUT_X_RES_WIDTH(INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH(INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH)
    ) image_cut (
        .clk   (vi_clk),
        .clk_vp(clk_vp),
        .rst_n (rst_n),
        .EN    (cuter_en),

        .START_X(START_X),
        .START_Y(START_Y),
        .END_X  (END_X),
        .END_Y  (END_Y),

        .vs_i (vs_i),
        .de_i (de_i),
        .rgb_i(rgb_i),
        .vs_o (image_cut_vs),
        .de_o (image_cut_de),
        .rgb_o(image_cut_rgb)
    );

    //--------------------------------------------------------------------------
    // Filter
    //--------------------------------------------------------------------------
    wire        post_vs_filter;  // Processed Image data vs valid signal
    wire        post_de_filter;  // Processed Image data output/capture enable clock
    wire [23:0] post_data_filter;  // Processed Image brightness output
    filter #(
        .IMG_HDISP(H_DISP),  // 1280*720
        .IMG_VDISP(V_DISP)
    ) filter (
        .clk      (vi_clk),
        .rst_n    (rst_n),
        .mode     (filter_mode),  // 00: bypass, 01: gaussian, 10: median, 11: mean

        .pre_vs   (image_cut_vs),
        .pre_de   (image_cut_de),
        .pre_data (image_cut_rgb),
        .post_vs  (post_vs_filter),
        .post_de  (post_de_filter),
        .post_data(post_data_filter)
    );

    //--------------------------------------------------------------------------
    // Scaler
    //--------------------------------------------------------------------------
    // Scaler Parameters
    wire        post_vs_scaler;  // Processed Image data vs valid signal
    wire        post_de_scaler;  // Processed Image data output/capture enable clock
    wire [23:0] post_data_scaler;  // Processed Image output
    wire [ INPUT_X_RES_WIDTH-1:0] inputXRes = END_X - START_X - 1;  // Resolution of input data minus 1
    wire [ INPUT_Y_RES_WIDTH-1:0] inputYRes = END_Y - START_Y - 1;
    wire [OUTPUT_X_RES_WIDTH-1:0] outputXRes = OUTPUT_X_RES;  // Resolution of input data minus 1
    wire [OUTPUT_Y_RES_WIDTH-1:0] outputYRes = OUTPUT_Y_RES;
    scaler #(
        .INPUT_X_RES_WIDTH (INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH (INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH)
    ) scaler (
        .EN   (scaler_en),

        .inputXRes  (inputXRes),
        .inputYRes  (inputYRes),
        .outputXRes (outputXRes),
        .outputYRes (outputYRes),

        .pre_clk  (vi_clk),
        .pre_vs   (vs_i),
        .pre_de   (de_i),
        .pre_data (rgb_i),
        // .pre_vs   (image_cut_vs),
        // .pre_de   (image_cut_de),
        // .pre_data (image_cut_rgb),
        // .pre_vs   (post_vs_filter),
        // .pre_de   (post_de_filter),
        // .pre_data (post_data_filter),
        .post_clk (clk_vp),
        .post_vs  (post_vs_scaler),
        .post_de  (post_de_scaler),
        .post_data(post_data_scaler)
    );

    //--------------------------------------------------------------------------
    // Fill Brank
    //--------------------------------------------------------------------------
    wire [23:0] fill_data;
    wire        fill_dataValid;
    fill_brank #(
        .H_DISP(H_DISP)
    ) fill_brank (
        .clk        (clk_vp),
        .dataValid_i(post_de_scaler),
        .data_i     (post_data_scaler),
        .dataValid_o(fill_dataValid),
        .data_o     (fill_data)
    );

    //--------------------------------------------------------------------------
    // Output
    //--------------------------------------------------------------------------
    assign vp_clk  = clk_vp;
    assign vp_vs   = post_vs_scaler;
    assign vp_de   = fill_dataValid;
    assign vp_data = {fill_data[23:19], fill_data[15:10], fill_data[7:3]};
    // assign vp_de   = post_de_scaler;
    // assign vp_data = {post_data_scaler[23:19], post_data_scaler[15:10], post_data_scaler[7:3]};

endmodule
