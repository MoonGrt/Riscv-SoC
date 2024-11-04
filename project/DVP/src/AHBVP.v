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

    parameter START_X = 0;
    parameter START_Y = 0;
    parameter END_X = 12'd1280;
    parameter END_Y = 12'd720;
    parameter INPUT_X_RES_WIDTH = 11;
    parameter INPUT_Y_RES_WIDTH = 11;
    parameter OUTPUT_X_RES_WIDTH = 11;
    parameter OUTPUT_Y_RES_WIDTH = 11;

    //--------------------------------------------------------------------------
    // Scaler
    //--------------------------------------------------------------------------
    wire vs_i = vi_vs;
    wire de_i = vi_de;
    wire [23:0] rgb_i = {vi_data[15:11], 3'b0, vi_data[10:5], 2'b0, vi_data[4:0], 3'b0};
    wire image_cut_de, image_cut_vs;
    wire [23:0] image_cut_rgb;
    wire state;
    image_cut #(
        .H_DISP(H_DISP),
        .V_DISP(V_DISP),
        .INPUT_X_RES_WIDTH(INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH(INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH)
    ) image_cut (
        .clk(vi_clk),

        .start_x(START_X),
        .start_y(START_Y),
        .end_x  (END_X),
        .end_y  (END_Y),

        .vs_i (vs_i),
        .de_i (de_i),
        .rgb_i(rgb_i),

        .vs_o (image_cut_vs),
        .de_o (image_cut_de),
        .rgb_o(image_cut_rgb),
        .state(state)
    );

    reg vs_reg1, vs_reg2;
    assign vs = vs_reg1 & ~vs_reg2;
    always @(posedge clk_vpm) begin
        vs_reg1 <= image_cut_vs;
        vs_reg2 <= vs_reg1;
    end

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
    // // Scaler Parameters
    // parameter DATA_WIDTH = 8;
    // parameter CHANNELS = 3;
    // parameter BUFFER_SIZE = 3;

    // parameter DISCARD_CNT_WIDTH = 2;
    // parameter FRACTION_BITS = 8;  // Don't modify
    // parameter SCALE_INT_BITS = 4;  // Don't modify
    // parameter SCALE_FRAC_BITS = 14;  // Don't modify
    // parameter SCALE_BITS = SCALE_INT_BITS + SCALE_FRAC_BITS;

    // // algorithm Inputs
    // // parameter START_X = 12'd1280 / 4;
    // // parameter START_Y = 12'd720 / 4;
    // // parameter END_X = 12'd1280 * 3 / 4;
    // // parameter END_Y = 12'd720 * 3 / 4;
    // // parameter OUTPUT_X_RES = 12'd1280 - 1;  // Resolution of output data minus 1
    // // parameter OUTPUT_Y_RES = 12'd720 - 1;  // Resolution of output data minus 1

    // parameter OUTPUT_X_RES = 12'd1280 - 1;  // Resolution of output data minus 1
    // parameter OUTPUT_Y_RES = 12'd720 - 1;  // Resolution of output data minus 1

    // // parameter START_X = 0;
    // // parameter START_Y = 0;
    // // parameter END_X = 12'd1280;
    // // parameter END_Y = 12'd720;
    // // parameter OUTPUT_X_RES = 12'd1280 / 2 - 1;  // Resolution of output data minus 1
    // // parameter OUTPUT_Y_RES = 12'd720 / 2 - 1;  // Resolution of output data minus 1

    // wire [ INPUT_X_RES_WIDTH-1:0] inputXRes = END_X - START_X - 1;  // Resolution of input data minus 1
    // wire [ INPUT_Y_RES_WIDTH-1:0] inputYRes = END_Y - START_Y - 1;
    // wire [OUTPUT_X_RES_WIDTH-1:0] outputXRes = OUTPUT_X_RES;  // Resolution of input data minus 1
    // wire [OUTPUT_Y_RES_WIDTH-1:0] outputYRes = OUTPUT_Y_RES;
    // wire [        SCALE_BITS-1:0] xScale = 32'h4000 * (inputXRes + 1) / (outputXRes + 1);  // Scaling factors. Input resolution scaled up by 1/xScale. Format Q SCALE_INT_BITS.SCALE_FRAC_BITS
    // wire [        SCALE_BITS-1:0] yScale = 32'h4000 * (inputYRes + 1) / (outputYRes + 1);  // Scaling factors. Input resolution scaled up by 1/yScale. Format Q SCALE_INT_BITS.SCALE_FRAC_BITS

    // wire fifo1_empty, fifo1_full;
    // wire [23:0] fifo1_data;
    // wire        scaler_re;

    // reg  algorithm_sel = 1'b1;
    // wire [23:0] scaler_data;
    // wire        scaler_dataValid;
    // FIFO #(
    //     .FIFO_MODE ("Normal"),  //"Normal"; //"ShowAhead"
    //     .DATA_WIDTH(24),
    //     .FIFO_DEPTH(1024)
    // ) FIFO (
    //     /*i*/.Reset(~state|vs),  // System Reset

    //     /*i*/.WrClk (vi_clk),        // (I)Wirte Clock
    //     /*i*/.WrEn  (image_cut_de),  // (I)Write Enable
    //     /*o*/.WrDNum(),              // (O)Write Data Number In Fifo
    //     /*o*/.WrFull(fifo1_full),    // (I)Write Full
    //     /*i*/.WrData(image_cut_rgb), // (I)Write Data

    //     /*i*/.RdClk  (clk_vpm),      // (I)Read Clock
    //     /*i*/.RdEn   (scaler_re),    // (I)Read Enable
    //     /*o*/.RdDNum (),             // (O)Radd Data Number In Fifo
    //     /*o*/.RdEmpty(fifo1_empty),  // (O)Read FifoEmpty
    //     /*o*/.RdData (fifo1_data)    // (O)Read Data
    // );

    // streamScaler #(
    //     .DATA_WIDTH        (DATA_WIDTH),
    //     .CHANNELS          (CHANNELS),
    //     .DISCARD_CNT_WIDTH (DISCARD_CNT_WIDTH),
    //     .INPUT_X_RES_WIDTH (INPUT_X_RES_WIDTH),
    //     .INPUT_Y_RES_WIDTH (INPUT_Y_RES_WIDTH),
    //     .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
    //     .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH),
    //     .BUFFER_SIZE       (BUFFER_SIZE),  // Number of RAMs in RAM ring buffer
    //     .FRACTION_BITS     (FRACTION_BITS),
    //     .SCALE_INT_BITS    (SCALE_INT_BITS),
    //     .SCALE_FRAC_BITS   (SCALE_FRAC_BITS)
    // ) streamScaler (
    //     .clk(clk_vpm),

    //     .dIn     (fifo1_data),
    //     .dInValid(scaler_re & ~fifo1_empty),
    //     .nextDin (scaler_re),
    //     .start   (vs),

    //     .dOut     (scaler_data),
    //     .dOutValid(scaler_dataValid),
    //     .nextDout (1),

    //     // Control
    //     .inputXRes(inputXRes),  // Input data number of pixels per line
    //     .inputYRes(inputYRes),
    //     .outputXRes(outputXRes),  // Resolution of output data
    //     .outputYRes(outputYRes),
    //     .xScale(xScale),  // Scaling factors. Input resolution scaled by 1/xScale. Format Q4.14
    //     .yScale(yScale),  // Scaling factors. Input resolution scaled by 1/yScale. Format Q4.14

    //     .nearestNeighbor(algorithm_sel),
    //     .inputDiscardCnt(0),              // Number of input pixels to discard before processing data. Used for clipping
    //     .leftOffset(0),
    //     .topFracOffset(0)
    // );

    wire        post_vs_scaler;  // Processed Image data vs valid signal
    wire        post_de_scaler;  // Processed Image data output/capture enable clock
    wire [23:0] post_data_scaler;  // Processed Image output
    scaler #(
        .INPUT_X_RES_WIDTH (INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH (INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH)
    ) scaler (
        .state    (state),
        .EN       (1'b1),

        .START_X(START_X),
        .START_Y(START_Y),
        .END_X  (END_X),
        .END_Y  (END_Y),

        .pre_clk  (vi_clk),
        // .pre_vs   (image_cut_vs),
        .pre_vs   (vs),
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
