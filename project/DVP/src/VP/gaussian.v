module gaussian #(
    parameter IMG_HDISP = 12'd1280,  // 1280*720
    parameter IMG_VDISP = 12'd720
) (
    // global clock
    input wire clk,   // cmos video pixel clock
    input wire rst_n, // global reset
    input wire EN,    // enable

    // Image data prepred to be processed
    input wire        per_vs,   // Prepared Image data vs valid signal
    input wire        per_de,   // Prepared Image data output/capture enable clock
    input wire [23:0] per_data, // Prepared Image data

    // Image data has been processed
    output wire        post_vs,   // Processed Image data vs valid signal
    output wire        post_de,   // Processed Image data output/capture enable clock
    output wire [23:0] post_data  // Prepared Image data
);

    wire [7:0] per_r = per_data[23:16];  // Red channel
    wire [7:0] per_g = per_data[15:8];  // Green channel
    wire [7:0] per_b = per_data[7:0];  // Blue channel
    reg  [7:0] post_r;  // Processed Red channel
    reg  [7:0] post_g;  // Processed Green channel
    reg  [7:0] post_b;  // Processed Blue channel

    //----------------------------------------------------
    // Generate 8Bit 3X3 Matrix for Video Image Processor.
    // Image data has been processed
    wire matrix_vs;  // Prepared Image data vs valid signal
    wire matrix_href;  // Prepared Image data href valid signal
    wire matrix_de;  // Prepared Image data output/capture enable clock

    // Define the 3x3 matrix for R, G, B channels
    wire [7:0] matrix_p11_r, matrix_p12_r, matrix_p13_r;
    wire [7:0] matrix_p21_r, matrix_p22_r, matrix_p23_r;
    wire [7:0] matrix_p31_r, matrix_p32_r, matrix_p33_r;

    wire [7:0] matrix_p11_g, matrix_p12_g, matrix_p13_g;
    wire [7:0] matrix_p21_g, matrix_p22_g, matrix_p23_g;
    wire [7:0] matrix_p31_g, matrix_p32_g, matrix_p33_g;

    wire [7:0] matrix_p11_b, matrix_p12_b, matrix_p13_b;
    wire [7:0] matrix_p21_b, matrix_p22_b, matrix_p23_b;
    wire [7:0] matrix_p31_b, matrix_p32_b, matrix_p33_b;

    // Instantiate 3x3 matrix generator for each channel
    matrix3x3 #(
        .IMG_HDISP(IMG_HDISP),
        .IMG_VDISP(IMG_VDISP)
    ) matrix3x3_r (
        .clk        (clk),
        .rst_n      (rst_n),
        .per_vs     (per_vs),
        .per_de     (per_de),
        .per_data   (per_r),
        .matrix_vs  (matrix_vs),
        .matrix_de  (matrix_de),
        .matrix_p11 (matrix_p11_r), .matrix_p12(matrix_p12_r), .matrix_p13(matrix_p13_r),
        .matrix_p21 (matrix_p21_r), .matrix_p22(matrix_p22_r), .matrix_p23(matrix_p23_r),
        .matrix_p31 (matrix_p31_r), .matrix_p32(matrix_p32_r), .matrix_p33(matrix_p33_r)
    );

    matrix3x3 #(
        .IMG_HDISP(IMG_HDISP),
        .IMG_VDISP(IMG_VDISP)
    ) matrix3x3_g (
        .clk        (clk),
        .rst_n      (rst_n),
        .per_vs     (per_vs),
        .per_de     (per_de),
        .per_data   (per_g),
        // .matrix_vs  (matrix_vs),
        // .matrix_de  (matrix_de),
        .matrix_p11 (matrix_p11_g), .matrix_p12(matrix_p12_g), .matrix_p13(matrix_p13_g),
        .matrix_p21 (matrix_p21_g), .matrix_p22(matrix_p22_g), .matrix_p23(matrix_p23_g),
        .matrix_p31 (matrix_p31_g), .matrix_p32(matrix_p32_g), .matrix_p33(matrix_p33_g)
    );

    matrix3x3 #(
        .IMG_HDISP(IMG_HDISP),
        .IMG_VDISP(IMG_VDISP)
    ) matrix3x3_b (
        .clk        (clk),
        .rst_n      (rst_n),
        .per_vs     (per_vs),
        .per_de     (per_de),
        .per_data   (per_b),
        // .matrix_vs  (matrix_vs),
        // .matrix_de  (matrix_de),
        .matrix_p11 (matrix_p11_b), .matrix_p12(matrix_p12_b), .matrix_p13(matrix_p13_b),
        .matrix_p21 (matrix_p21_b), .matrix_p22(matrix_p22_b), .matrix_p23(matrix_p23_b),
        .matrix_p31 (matrix_p31_b), .matrix_p32(matrix_p32_b), .matrix_p33(matrix_p33_b)
    );

    //--------------------------------------------------------------------------
    // �������ս��
    //  {1, 2, 1}
    //  {2, 4, 2}
    //  {1, 2, 1}
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_r <= 8'b0;
            post_g <= 8'b0;
            post_b <= 8'b0;
        end else if (per_de) begin
            post_r <= (matrix_p11_r + matrix_p12_r*2 + matrix_p13_r + matrix_p21_r*2 + matrix_p22_r*4 +
                       matrix_p23_r*2 + matrix_p31_r + matrix_p32_r*2 + matrix_p33_r) >> 4;
            post_g <= (matrix_p11_g + matrix_p12_g*2 + matrix_p13_g + matrix_p21_g*2 + matrix_p22_g*4 +
                       matrix_p23_g*2 + matrix_p31_g + matrix_p32_g*2 + matrix_p33_g) >> 4;
            post_b <= (matrix_p11_b + matrix_p12_b*2 + matrix_p13_b + matrix_p21_b*2 + matrix_p22_b*4 +
                       matrix_p23_b*2 + matrix_p31_b + matrix_p32_b*2 + matrix_p33_b) >> 4;
        end else;
    end

    //---------------------------------------
    // lag 1 clocks signal sync
    reg per_vs_r;
    reg per_de_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_vs_r   <= 0;
            per_de_r   <= 0;
        end else begin
            per_vs_r   <= matrix_vs;
            per_de_r   <= matrix_de;
        end
    end

    assign post_vs   = EN ? per_vs_r : per_vs;
    assign post_de   = EN ? per_de_r : per_de;
    assign post_data = EN ? {post_b, post_g, post_r} : per_data;

endmodule