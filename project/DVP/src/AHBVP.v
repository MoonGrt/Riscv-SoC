module AHBVP (
    input clk_vpm,
    input rst_n,

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

    parameter H_DISP = 12'd1280;
    parameter V_DISP = 12'd720;
    parameter INPUT_X_RES_WIDTH = 11;
    parameter INPUT_Y_RES_WIDTH = 11;
    parameter OUTPUT_X_RES_WIDTH = 11;
    parameter OUTPUT_Y_RES_WIDTH = 11;

    // parameter START_X = 12'd1280 / 4;
    // parameter START_Y = 12'd720 / 4;
    // parameter END_X = 12'd1280 * 3 / 4;
    // parameter END_Y = 12'd720 * 3 / 4;
    // parameter OUTPUT_X_RES = 12'd1280 - 1;  // Resolution of output data minus 1
    // parameter OUTPUT_Y_RES = 12'd720 - 1;  // Resolution of output data minus 1

    parameter START_X = 0;
    parameter START_Y = 0;
    parameter END_X = 12'd1280;
    parameter END_Y = 12'd720;
    parameter OUTPUT_X_RES = 12'd1280 - 1;  // Resolution of output data minus 1
    parameter OUTPUT_Y_RES = 12'd720 - 1;  // Resolution of output data minus 1

    // parameter START_X = 0;
    // parameter START_Y = 0;
    // parameter END_X = 12'd1280;
    // parameter END_Y = 12'd720;
    // parameter OUTPUT_X_RES = 12'd1280 / 2 - 1;  // Resolution of output data minus 1
    // parameter OUTPUT_Y_RES = 12'd720 / 2 - 1;  // Resolution of output data minus 1

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
        .clk(vi_clk),
        .rst_n(rst_n),

        .start_x(START_X),
        .start_y(START_Y),
        .end_x  (END_X),
        .end_y  (END_Y),

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
        .clk      (clk),
        .rst_n    (rst_n),
        .mode     (2'b01),  // 00: bypass, 01: gaussian, 10: median, 11: mean
        .per_vs   (image_cut_vs),
        .per_de   (image_cut_de),
        .per_data (image_cut_rgb),
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
    scaler #(
        .INPUT_X_RES_WIDTH (INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH (INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH)
    ) scaler (
        .EN   (1'b1),

        .START_X     (START_X),
        .START_Y     (START_Y),
        .END_X       (END_X),
        .END_Y       (END_Y),
        .OUTPUT_X_RES(OUTPUT_X_RES),
        .OUTPUT_Y_RES(OUTPUT_Y_RES),

        .pre_clk  (vi_clk),
        .pre_vs   (image_cut_vs),
        .pre_de   (image_cut_de),
        .pre_data (image_cut_rgb),
        .post_clk (clk_vpm),
        .post_vs  (post_vs_scaler),
        .post_de  (post_de_scaler),
        .post_data(post_data_scaler)
    );

    //--------------------------------------------------------------------------
    // Fill Brank
    //--------------------------------------------------------------------------
    wire [23:0] fill_data;
    wire        fill_dataValid;
    // pixel_cnt pixel_cnt (
    //     .rst(image_cut_vs),
    //     .clk(clk_vpm),
    //     .de (fill_dataValid)
    // );
    fill_brank #(
        .H_DISP(H_DISP)
        // .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
    ) fill_brank (
        .clk        (clk_vpm),
        // .dataValid_i(scaler_dataValid),
        // .data_i     (scaler_data),
        .dataValid_i(post_de_scaler),
        .data_i     (post_data_scaler),
        .dataValid_o(fill_dataValid),
        .data_o     (fill_data)
    );

    //--------------------------------------------------------------------------
    // Output
    //--------------------------------------------------------------------------
    assign vp_clk  = clk_vpm;
    assign vp_vs   = vi_vs;
    assign vp_de   = fill_dataValid;
    assign vp_data = {fill_data[23:19], fill_data[15:10], fill_data[7:3]};

endmodule
