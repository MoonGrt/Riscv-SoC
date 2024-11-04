`timescale 1ns / 1ns

module gauss #(
    parameter [8:0] IMG_HDISP = 9'd320,  // 320*240
    parameter [7:0] IMG_VDISP = 8'd240
) (
    // global clock
    input wire clk,   // cmos video pixel clock
    input wire rst_n, // global reset

    // Image data prepred to be processd
    input wire       per_frame_vsync,  // Prepared Image data vsync valid signal
    input wire       per_frame_href,   // Prepared Image data href vaild  signal
    input wire       per_frame_clken,  // Prepared Image data output/capture enable clock
    input wire [7:0] per_y,

    // Image data has been processd
    output wire       post_frame_vsync,  // Processed Image data vsync valid signal
    output wire       post_frame_href,   // Processed Image data href vaild  signal
    output wire       post_frame_clken,  // Processed Image data output/capture enable clock
    output reg  [7:0] post_y
);

    //----------------------------------------------------
    // Generate 8Bit 3X3 Matrix for Video Image Processor.
    // Image data has been processd
    wire matrix_frame_vsync;  // Prepared Image data vsync valid signal
    wire matrix_frame_href;  // Prepared Image data href vaild  signal
    wire matrix_frame_clken;  // Prepared Image data output/capture enable clock

    wire [7:0] matrix_p11_y, matrix_p12_y, matrix_p13_y;  // 3X3 Matrix output
    wire [7:0] matrix_p21_y, matrix_p22_y, matrix_p23_y;
    wire [7:0] matrix_p31_y, matrix_p32_y, matrix_p33_y;

    matrix3x3 #(
        .IMG_HDISP(IMG_HDISP),
        .IMG_VDISP(IMG_VDISP)
    ) matrix3x3_y (
        // global clock
        .clk  (clk),   // cmos video pixel clock
        .rst_n(rst_n), // global reset

        // Image data prepred to be processd
        .per_frame_vsync(per_frame_vsync),  // Prepared Image data vsync valid signal
        .per_frame_href (per_frame_href),   // Prepared Image data href vaild  signal
        .per_frame_clken(per_frame_clken),  // Prepared Image data output/capture enable clock
        .per_img        (per_y),            // Prepared Image brightness input

        // Image data has been processd
        .matrix_frame_vsync(matrix_frame_vsync),  // Processed Image data vsync valid signal
        .matrix_frame_href (matrix_frame_href),   // Processed Image data href vaild  signal
        .matrix_frame_clken(matrix_frame_clken),  // Processed Image data output/capture enable clock
        .matrix_p11(matrix_p11_y), .matrix_p12(matrix_p12_y), .matrix_p13(matrix_p13_y), // 3X3 Matrix output
        .matrix_p21(matrix_p21_y), .matrix_p22(matrix_p22_y), .matrix_p23(matrix_p23_y),
        .matrix_p31(matrix_p31_y), .matrix_p32(matrix_p32_y), .matrix_p33(matrix_p33_y)
    );

    //--------------------------------------------------------------------------
    // 计算最终结果
    //  {1, 2, 1}
    //  {2, 4, 2}
    //  {1, 2, 1}
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_y <= 8'b0;
        end else if (per_frame_clken) begin
            post_y <= (matrix_p11_y + matrix_p12_y*2 + matrix_p13_y + matrix_p21_y*2 + matrix_p22_y*4 +
        	           matrix_p23_y*2 + matrix_p31_y + matrix_p32_y*2 + matrix_p33_y)>>4;
        end else;
    end

    //---------------------------------------
    // lag 1 clocks signal sync
    reg per_frame_vsync_r;
    reg per_frame_href_r;
    reg per_frame_clken_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_frame_vsync_r <= 0;
            per_frame_href_r  <= 0;
            per_frame_clken_r <= 0;
        end else begin
            per_frame_vsync_r <= matrix_frame_vsync;
            per_frame_href_r  <= matrix_frame_href;
            per_frame_clken_r <= matrix_frame_clken;
        end
    end

    assign post_frame_vsync = per_frame_vsync_r;
    assign post_frame_href  = per_frame_href_r;
    assign post_frame_clken = per_frame_clken_r;

endmodule
