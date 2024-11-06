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
    input [31:0] VP_SR,
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
    wire       cuter_en = 1'b0;
    wire [1:0] filter_mode = 2'b00;
    wire       scaler_en = 1'b1;
    wire       color_en = 1'b0;
    wire       edge_en = 1'b0;
    wire       binarizer_en = 1'b0;
    // wire [1:0] filler_mode = 2'b00;  // 00: scaler, 01: edge, 10: binarizer, 11: bypass
    wire [1:0] filler_mode = VP_CR[31:30];  // 00: scaler, 01: edge, 10: binarizer, 11: bypass
    // wire [ INPUT_X_RES_WIDTH-1:0] START_X = VP_START[INPUT_X_RES_WIDTH-1:0];
    // wire [ INPUT_Y_RES_WIDTH-1:0] START_Y = VP_START[INPUT_X_RES_WIDTH-1+16:0+16];
    // wire [OUTPUT_X_RES_WIDTH-1:0] END_X = VP_END[OUTPUT_X_RES_WIDTH-1:0];
    // wire [OUTPUT_Y_RES_WIDTH-1:0] END_Y = VP_END[OUTPUT_X_RES_WIDTH-1+16:0+16];
    // wire [OUTPUT_X_RES_WIDTH-1:0] OUTPUT_X_RES = VP_SCALER[INPUT_X_RES_WIDTH-1:0];  // Resolution of output data minus 1
    // wire [OUTPUT_Y_RES_WIDTH-1:0] OUTPUT_Y_RES = VP_SCALER[INPUT_X_RES_WIDTH-1+16:0+16];  // Resolution of output data minus 1

    // Video Parameters
    // 放大
    // reg [ INPUT_X_RES_WIDTH-1:0] START_X = H_DISP / 10 * 1;
    // reg [ INPUT_Y_RES_WIDTH-1:0] START_Y = V_DISP / 10 * 1;
    // reg [OUTPUT_X_RES_WIDTH-1:0] END_X = H_DISP / 10 * 1 + H_DISP / 2;
    // reg [OUTPUT_Y_RES_WIDTH-1:0] END_Y = V_DISP / 10 * 1 + V_DISP / 2;
    // reg [OUTPUT_X_RES_WIDTH-1:0] OUTPUT_X_RES = H_DISP;
    // reg [OUTPUT_Y_RES_WIDTH-1:0] OUTPUT_Y_RES = V_DISP;
    // 原图
    // reg [ INPUT_X_RES_WIDTH-1:0] START_X = 0;
    // reg [ INPUT_Y_RES_WIDTH-1:0] START_Y = 0;
    // reg [OUTPUT_X_RES_WIDTH-1:0] END_X = H_DISP;
    // reg [OUTPUT_Y_RES_WIDTH-1:0] END_Y = V_DISP;
    // reg [OUTPUT_X_RES_WIDTH-1:0] OUTPUT_X_RES = H_DISP;
    // reg [OUTPUT_Y_RES_WIDTH-1:0] OUTPUT_Y_RES = V_DISP;
    // 缩小
    reg [ INPUT_X_RES_WIDTH-1:0] START_X = 0;
    reg [ INPUT_Y_RES_WIDTH-1:0] START_Y = 0;
    reg [OUTPUT_X_RES_WIDTH-1:0] END_X = H_DISP;
    reg [OUTPUT_Y_RES_WIDTH-1:0] END_Y = V_DISP;
    reg [OUTPUT_X_RES_WIDTH-1:0] OUTPUT_X_RES = H_DISP / 2;
    reg [OUTPUT_Y_RES_WIDTH-1:0] OUTPUT_Y_RES = V_DISP / 2;

    //--------------------------------------------------------------------------
    // Scaler
    //--------------------------------------------------------------------------
    wire vs_i = vi_vs;
    wire de_i = vi_de;
    wire [23:0] rgb_i = {vi_data[15:11], 3'b0, vi_data[10:5], 2'b0, vi_data[4:0], 3'b0};
    wire cutter_post_de, cutter_post_vs;
    wire [23:0] cutter_post_data;
    cutter #(
        .H_DISP            (H_DISP),
        .V_DISP            (V_DISP),
        .INPUT_X_RES_WIDTH (INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH (INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH)
    ) cutter (
        .clk  (vi_clk),
        .rst_n(rst_n),
        .EN   (cuter_en),

        .START_X(START_X),
        .START_Y(START_Y),
        .END_X  (END_X),
        .END_Y  (END_Y),

        .pre_vs   (vs_i),
        .pre_de   (de_i),
        .pre_data (rgb_i),
        .post_vs  (cutter_post_vs),
        .post_de  (cutter_post_de),
        .post_data(cutter_post_data)
    );

    //--------------------------------------------------------------------------
    // Filter
    //--------------------------------------------------------------------------
    wire        filter_post_vs;  // Processed Image data vs valid signal
    wire        filter_post_de;  // Processed Image data output/capture enable clock
    wire [23:0] filter_post_data;  // Processed Image output
    filter #(
        .IMG_HDISP(H_DISP),  // 1280*720
        .IMG_VDISP(V_DISP)
    ) filter (
        .clk      (vi_clk),
        .rst_n    (rst_n),
        .mode     (filter_mode),  // 00: bypass, 01: gaussian, 10: median, 11: mean

        .pre_vs   (cutter_post_vs),
        .pre_de   (cutter_post_de),
        .pre_data (cutter_post_data),
        .post_vs  (filter_post_vs),
        .post_de  (filter_post_de),
        .post_data(filter_post_data)
    );

    //--------------------------------------------------------------------------
    // Scaler
    //--------------------------------------------------------------------------
    wire        scaler_post_vs;  // Processed Image data vs valid signal
    wire        scaler_post_de;  // Processed Image data output/capture enable clock
    wire [23:0] scaler_post_data;  // Processed Image output
    wire [ INPUT_X_RES_WIDTH-1:0] inputXRes = END_X - START_X - 1;  // Resolution of input data minus 1
    wire [ INPUT_Y_RES_WIDTH-1:0] inputYRes = END_Y - START_Y - 1;
    wire [OUTPUT_X_RES_WIDTH-1:0] outputXRes = OUTPUT_X_RES - 1;  // Resolution of input data minus 1
    wire [OUTPUT_Y_RES_WIDTH-1:0] outputYRes = OUTPUT_Y_RES - 1;
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
        .pre_vs   (filter_post_vs),
        .pre_de   (filter_post_de),
        .pre_data (filter_post_data),
        .post_clk (clk_vp),
        .post_vs  (scaler_post_vs),
        .post_de  (scaler_post_de),
        .post_data(scaler_post_data)
    );

    //--------------------------------------------------------------------------
    // Color space convert
    //--------------------------------------------------------------------------
    wire       color_post_vs;  // Processed Image data vs valid signal
    wire       color_post_de;  // Processed Image data output/capture enable clock
    wire [7:0] color_post_y;  // Processed Image output
    rgb2ycbcr rgb2ycbcr (
        .clk     (vi_clk),
        .rst_n   (rst_n),
        .EN      (color_en),

        .pre_vs  (filter_post_vs),
        .pre_de  (filter_post_de),
        .pre_data(filter_post_data),
        .post_vs (color_post_vs),
        .post_de (color_post_de),
        .post_y  (color_post_y),
        .post_cb (),
        .post_cr ()
    );

    //--------------------------------------------------------------------------
    // Edge Detector
    //--------------------------------------------------------------------------
    wire        edge_post_vs;  // Processed Image data vs valid signal
    wire        edge_post_de;  // Processed Image data output/capture enable clock
    wire [23:0] edge_post_data;  // Processed Image output
    edge_detector #(
        .IMG_HDISP(H_DISP),
        .IMG_VDISP(V_DISP)
    ) edge_detector (
        .clk      (vi_clk),
        .rst_n    (rst_n),
        .EN       (edge_en),
        .threshold(8'd0),

        .pre_vs  (color_post_vs),
        .pre_de  (color_post_de),
        .pre_img (color_post_y),
        .post_vs (edge_post_vs),
        .post_de (edge_post_de),
        .post_img(edge_post_data)
    );

    //--------------------------------------------------------------------------
    // Binarization
    //--------------------------------------------------------------------------
    wire        binarizer_post_vs;  // Processed Image data vs valid signal
    wire        binarizer_post_de;  // Processed Image data output/capture enable clock
    wire [23:0] binarizer_post_data;  // Processed Image output
    binarizer binarizer (
        .clk      (vi_clk),
        .rst_n    (rst_n),
        .EN       (binarizer_en),
        .threshold(8'd0),

        .pre_vs  (color_post_vs),
        .pre_de  (color_post_de),
        .pre_data(color_post_y),
        .post_vs (binarizer_post_vs),
        .post_de (binarizer_post_de),
        .post_bit(binarizer_post_data)
    );

    //--------------------------------------------------------------------------
    // Fill Brank
    //--------------------------------------------------------------------------
    reg         filler_pre_vs;  // Prepared Image data vs valid signal
    reg         filler_pre_de;  // Prepared Image data output/capture enable clock
    reg  [23:0] filler_pre_data;  // Prepared Image output
    wire        filler_post_vs;  // Processed Image data vs valid signal
    wire        filler_post_de;  // Processed Image data output/capture enable clock
    wire [23:0] filler_post_data;  // Processed Image output
    wire        filler_en = (filler_mode == 2'b00) & (OUTPUT_X_RES < H_DISP);
    always @ (*) begin
        if (~rst_n) begin
            filler_pre_vs   = 1'b0;
            filler_pre_de   = 1'b0;
            filler_pre_data = 24'd0;
        end else begin
            case (filler_mode)
                2'b00: begin
                    filler_pre_vs   = scaler_post_vs;
                    filler_pre_de   = scaler_post_de;
                    filler_pre_data = scaler_post_data;
                end
                2'b01: begin
                    filler_pre_vs   = edge_post_vs;
                    filler_pre_de   = edge_post_de;
                    filler_pre_data = edge_post_data;
                end
                2'b10: begin
                    filler_pre_vs   = binarizer_post_vs;
                    filler_pre_de   = binarizer_post_de;
                    filler_pre_data = binarizer_post_data;
                end
                2'b11: begin
                    filler_pre_vs   = vs_i;
                    filler_pre_de   = de_i;
                    filler_pre_data = rgb_i;
                end
            endcase
        end
    end
    filler #(
        .H_DISP(H_DISP)
    ) filler (
        .clk      (clk_vp),
        .rst_n    (rst_n),
        .EN       (1),
        // .pre_vs   (scaler_post_vs),
        // .pre_de   (scaler_post_de),
        // .pre_data (scaler_post_data),
        .pre_vs   (filler_pre_vs),
        .pre_de   (filler_pre_de),
        .pre_data (filler_pre_data),
        .post_vs  (filler_post_vs),
        .post_de  (filler_post_de),
        .post_data(filler_post_data)
    );
    // wire [23:0] fill_data;
    // wire        fill_dataValid;
    // assign algorithm_data      = fill_data;
    // assign algorithm_dataValid = fill_dataValid;
    // fill_brank #(
    //     .H_DISP(H_DISP)
    // ) fill_brank (
    //     .clk        (clk_vp),
    //     .data_i     (scaler_post_data),
    //     .dataValid_i(scaler_post_de),
    //     // .data_i     (filler_pre_data),
    //     // .dataValid_i(filler_pre_de),
    //     .data_o     (fill_data),
    //     .dataValid_o(fill_dataValid)
    // );

    //--------------------------------------------------------------------------
    // Output
    //--------------------------------------------------------------------------
    assign vp_clk  = clk_vp;
    assign vp_vs   = filler_post_vs;
    assign vp_de   = filler_post_de;
    assign vp_data = {filler_post_data[23:19], filler_post_data[15:10], filler_post_data[7:3]};
    // assign vp_vs   = scaler_post_vs;
    // assign vp_de   = fill_dataValid;
    // assign vp_data = {fill_data[23:19], fill_data[15:10], fill_data[7:3]};

    // pixel_cnt pixel_cnt1(
    //     .clk(clk_vp),
    //     // .rst(filler_post_vs),
    //     .de (fill_dataValid)
    //     // .de (filler_post_de)
    // );
    // pixel_cnt pixel_cnt2(
    //     .clk(clk_vp),
    //     // .rst(filler_post_vs),
    //     // .de (fill_dataValid)
    //     .de (filler_post_de)
    // );

endmodule

