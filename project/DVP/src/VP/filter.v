module filter(
    input  wire        vi_clk,
    input  wire        rst_n,
    input  wire        post_frame_vsync_ycbcr,
    input  wire        post_frame_clken_ycbcr,
    input  wire [7:0] img_y,
    input  wire [7:0] img_Cr,
    input  wire [7:0] img_Cb,
    output wire        post_frame_vsync_mid_value,
    output wire        post_frame_clken_mid_value,
    output wire [7:0] post_y
);

    // wire [7:0] post_y, post_Cr, post_Cb;  //Processed Image brightness output
    // wire post_frame_vsync_mid_value;  //Processed Image data vsync valid signal
    // wire post_frame_clken_mid_value;  //Processed Image data output/capture enable clock
    // middle #(
    //     .IMG_HDISP(H_DISP),  // 1280*720
    //     .IMG_VDISP(V_DISP)
    // ) middle (
    //     //global clock
    //     .clk  (vi_clk),  //cmos video pixel clock
    //     .rst_n(rst_n),   //global reset

    //     //Image data prepred to be processd
    //     .per_frame_vsync(post_frame_vsync_ycbcr),  //Prepared Image data vsync valid signal
    //     .per_frame_clken(post_frame_clken_ycbcr),  //Prepared Image data output/capture enable clock
    //     .per_y(img_y),  //Prepared Image brightness input
    //     .per_Cr(img_Cr),
    //     .per_Cb(img_Cb),

    //     //Image data has been processd
    //     .post_frame_vsync(post_frame_vsync_mid_value),  //Processed Image data vsync valid signal
    //     .post_frame_clken(post_frame_clken_mid_value),	//Processed Image data output/capture enable clock
    //     .post_y(post_y)
    // );

    // wire        post_vs_gauss;  // Processed Image data vsync valid signal
    // wire        post_de_gauss;  // Processed Image data output/capture enable clock
    // wire [23:0] post_data_gauss;  // Processed Image brightness output
    // gauss #(
    //     .IMG_HDISP(H_DISP),  // 1280*720
    //     .IMG_VDISP(V_DISP)
    // ) gauss (
    //     // global clock
    //     .clk  (vi_clk),  // cmos video pixel clock
    //     .rst_n(rst_n),   // global reset

    //     // Image data prepred to be processd
    //     .per_vs  (),  // Prepared Image data vsync valid signal
    //     .per_de  (),  // Prepared Image data output/capture enable clock
    //     .per_data(),

    //     // Image data has been processd
    //     .post_vs  (post_vs_gauss),  // Processed Image data vsync valid signal
    //     .post_de  (post_de_gauss),  // Processed Image data output/capture enable clock
    //     .post_data(post_data_gauss)
    // );

endmodule
