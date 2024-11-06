module median #(
    parameter IMG_HDISP = 9'd1280,  // 1280*720
    parameter IMG_VDISP = 8'd720
) (
    // global clock
    input wire clk,   // cmos video pixel clock
    input wire rst_n, // global reset
    input wire EN,    // enable signal for image processing

    // Image data prepred to be processd
    input wire        pre_vs,    // Prepared Image data vs valid signal
    input wire        pre_de,    // Prepared Image data output/capture enable clock
    input wire [23:0] pre_data,  // Prepared Image input

    // Image data has been processd
    output wire        post_vs,  // Processed Image data vs valid signal
    output wire        post_de,  // Processed Image data output/capture enable clock
    output wire [23:0] post_data
);

    wire [7:0] pre_r = pre_data[23:16];  // Red channel
    wire [7:0] pre_g = pre_data[15:8];  // Green channel
    wire [7:0] pre_b = pre_data[7:0];  // Blue channel
    wire [7:0] post_r;  // Processed Red channel
    wire [7:0] post_g;  // Processed Green channel
    wire [7:0] post_b;  // Processed Blue channel

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
        // global clock
        .clk  (clk),    // cmos video pixel clock
        .rst_n(rst_n),  // global reset

        // Image data prepred to be processd
        .pre_vs  (pre_vs),  // Prepared Image data vs valid signal
        .pre_de  (pre_de),  // Prepared Image data output/capture enable clock
        .pre_data(pre_r),  // Prepared Image input

        // Image data has been processd
        .matrix_vs(matrix_vs),  // Processed Image data vs valid signal
        .matrix_de(matrix_de),  // Processed Image data output/capture enable clock
        .matrix_p11(matrix_p11_r), .matrix_p12(matrix_p12_r), .matrix_p13(matrix_p13_r),  // 3X3 Matrix output
        .matrix_p21(matrix_p21_r), .matrix_p22(matrix_p22_r), .matrix_p23(matrix_p23_r),
        .matrix_p31(matrix_p31_r), .matrix_p32(matrix_p32_r), .matrix_p33(matrix_p33_r)
    );
    // Median filter for each channel
    Matrix3x3Median Matrix3x3Median_r (
        // global clock
        .clk  (clk),    // cmos video pixel clock
        .rst_n(rst_n),  // global reset

        // Image data prepred to be processd
        .pre_de (matrix_de),  // Prepared Image data output/capture enable clock

        // Image data has been processd
        .matrix_p11(matrix_p11_r), .matrix_p12(matrix_p12_r), .matrix_p13(matrix_p13_r),  // 3X3 Matrix output
        .matrix_p21(matrix_p21_r), .matrix_p22(matrix_p22_r), .matrix_p23(matrix_p23_r),
        .matrix_p31(matrix_p31_r), .matrix_p32(matrix_p32_r), .matrix_p33(matrix_p33_r),

        // Median filter output
        .post_data(post_r)  // Processed Image output
    );

    matrix3x3 #(
        .IMG_HDISP(IMG_HDISP),
        .IMG_VDISP(IMG_VDISP)
    ) matrix3x3_g (
        // global clock
        .clk  (clk),    // cmos video pixel clock
        .rst_n(rst_n),  // global reset

        // Image data prepred to be processd
        .pre_vs  (pre_vs),  // Prepared Image data vs valid signal
        .pre_de  (pre_de),  // Prepared Image data output/capture enable clock
        .pre_data(pre_g),  // Prepared Image input

        // Image data has been processd
        // .matrix_vs(matrix_vs),  // Processed Image data vs valid signal
        // .matrix_de(matrix_de),  // Processed Image data output/capture enable clock
        .matrix_p11(matrix_p11_g), .matrix_p12(matrix_p12_g), .matrix_p13(matrix_p13_g),  // 3X3 Matrix output
        .matrix_p21(matrix_p21_g), .matrix_p22(matrix_p22_g), .matrix_p23(matrix_p23_g),
        .matrix_p31(matrix_p31_g), .matrix_p32(matrix_p32_g), .matrix_p33(matrix_p33_g)
    );
    Matrix3x3Median Matrix3x3Median_g (
        // global clock
        .clk  (clk),    // cmos video pixel clock
        .rst_n(rst_n),  // global reset

        // Image data prepred to be processd
        .pre_de (matrix_de),  // Prepared Image data output/capture enable clock

        // Image data has been processd
        .matrix_p11(matrix_p11_g), .matrix_p12(matrix_p12_g), .matrix_p13(matrix_p13_g),  // 3X3 Matrix output
        .matrix_p21(matrix_p21_g), .matrix_p22(matrix_p22_g), .matrix_p23(matrix_p23_g),
        .matrix_p31(matrix_p31_g), .matrix_p32(matrix_p32_g), .matrix_p33(matrix_p33_g),

        // Median filter output
        .post_data(post_g)  // Processed Image output
    );

    matrix3x3 #(
        .IMG_HDISP(IMG_HDISP),
        .IMG_VDISP(IMG_VDISP)
    ) matrix3x3_b (
        // global clock
        .clk  (clk),    // cmos video pixel clock
        .rst_n(rst_n),  // global reset

        // Image data prepred to be processd
        .pre_vs  (pre_vs),  // Prepared Image data vs valid signal
        .pre_de  (pre_de),  // Prepared Image data output/capture enable clock
        .pre_data(pre_b),  // Prepared Image input

        // Image data has been processd
        // .matrix_vs(matrix_vs),  // Processed Image data vs valid signal
        // .matrix_de(matrix_de),  // Processed Image data output/capture enable clock
        .matrix_p11(matrix_p11_b), .matrix_p12(matrix_p12_b), .matrix_p13(matrix_p13_b),  // 3X3 Matrix output
        .matrix_p21(matrix_p21_b), .matrix_p22(matrix_p22_b), .matrix_p23(matrix_p23_b),
        .matrix_p31(matrix_p31_b), .matrix_p32(matrix_p32_b), .matrix_p33(matrix_p33_b)
    );
    Matrix3x3Median Matrix3x3Median_b (
        // global clock
        .clk  (clk),    // cmos video pixel clock
        .rst_n(rst_n),  // global reset

        // Image data prepred to be processd
        .pre_de (matrix_de),  // Prepared Image data output/capture enable clock

        // Image data has been processd
        .matrix_p11(matrix_p11_b), .matrix_p12(matrix_p12_b), .matrix_p13(matrix_p13_b),  // 3X3 Matrix output
        .matrix_p21(matrix_p21_b), .matrix_p22(matrix_p22_b), .matrix_p23(matrix_p23_b),
        .matrix_p31(matrix_p31_b), .matrix_p32(matrix_p32_b), .matrix_p33(matrix_p33_b),

        // Median filter output
        .post_data(post_b)  // Processed Image output
    );

    //---------------------------------------
    // lag 4 clocks signal sync  
    reg [3:0] pre_vs_r;
    reg [3:0] pre_de_r;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            pre_vs_r <= 0;
            pre_de_r <= 0;
        end else begin
            pre_vs_r <= {pre_vs_r[2:0], matrix_vs};
            pre_de_r <= {pre_de_r[2:0], matrix_de};
        end
    end

    assign post_vs   = EN ? pre_vs_r : pre_vs;
    assign post_de   = EN ? pre_de_r : pre_de;
    assign post_data = EN ? {post_r, post_g, post_b} : pre_data;

endmodule


module Matrix3x3Median(
    input       clk,
    input       rst_n,
    input       pre_de,
    input [7:0] matrix_p11, matrix_p12, matrix_p13,
    input [7:0] matrix_p21, matrix_p22, matrix_p23,
    input [7:0] matrix_p31, matrix_p32, matrix_p33,
    output reg [7:0] post_data
);

	reg	[7:0] matrix_p1_max, matrix_p1_mid, matrix_p1_min;
    reg	[7:0] matrix_p2_max, matrix_p2_mid, matrix_p2_min;
    reg	[7:0] matrix_p3_max, matrix_p3_mid, matrix_p3_min;	
	reg	[7:0] max_min, mid_mid, min_max;	

    // step1  分别求出 3 行中同一行的最大值、 最小值、 中间值
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            matrix_p1_max <= 8'b0;
            matrix_p1_mid <= 8'b0;
            matrix_p1_min <= 8'b0;
        end else if (pre_de) begin
            if(matrix_p11 >= matrix_p12 && matrix_p11 >= matrix_p13 && matrix_p12 >= matrix_p13) begin  // 1>=2>=3
                matrix_p1_max <= matrix_p11;
                matrix_p1_mid <= matrix_p12;
                matrix_p1_min <= matrix_p13;
            end
            else if(matrix_p11 >= matrix_p12 && matrix_p11 >= matrix_p13 && matrix_p12 <= matrix_p13) begin  // 1>3>2
                matrix_p1_max <= matrix_p11;
                matrix_p1_mid <= matrix_p13;
                matrix_p1_min <= matrix_p12;
            end
            else if(matrix_p11 <= matrix_p12 && matrix_p11 >= matrix_p13 && matrix_p12 >= matrix_p13) begin  // 2>1>3
                matrix_p1_max <= matrix_p12;
                matrix_p1_mid <= matrix_p11;
                matrix_p1_min <= matrix_p13;
            end
            else if(matrix_p11 <= matrix_p12 && matrix_p11 <= matrix_p13 && matrix_p12 >= matrix_p13) begin  // 2>3>1
                matrix_p1_max <= matrix_p12;
                matrix_p1_mid <= matrix_p13;
                matrix_p1_min <= matrix_p11;
            end
            else if(matrix_p11 >= matrix_p12 && matrix_p11 <= matrix_p13 && matrix_p12 <= matrix_p13) begin  // 3>1>2
                matrix_p1_max <= matrix_p13;
                matrix_p1_mid <= matrix_p11;
                matrix_p1_min <= matrix_p12;
            end
            else if(matrix_p11 <= matrix_p12 && matrix_p11 <= matrix_p13 && matrix_p12 <= matrix_p13) begin  // 3>2>1
                matrix_p1_max <= matrix_p13;
                matrix_p1_mid <= matrix_p12;
                matrix_p1_min <= matrix_p11;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            matrix_p2_max <= 8'b0;
            matrix_p2_mid <= 8'b0;
            matrix_p2_min <= 8'b0;
        end else if (pre_de) begin
            if(matrix_p21 >= matrix_p22 && matrix_p21 >= matrix_p23 && matrix_p22 >= matrix_p23) begin  // 1>=2>=3
                matrix_p2_max <= matrix_p21;
                matrix_p2_mid <= matrix_p22;
                matrix_p2_min <= matrix_p23;
            end
            else if(matrix_p21 >= matrix_p22 && matrix_p21 >= matrix_p23 && matrix_p22 <= matrix_p23) begin  // 1>3>2
                matrix_p2_max <= matrix_p21;
                matrix_p2_mid <= matrix_p23;
                matrix_p2_min <= matrix_p22;
            end
            else if(matrix_p21 <= matrix_p22 && matrix_p21 >= matrix_p23 && matrix_p22 >= matrix_p23) begin  // 2>1>3
                matrix_p2_max <= matrix_p22;
                matrix_p2_mid <= matrix_p21;
                matrix_p2_min <= matrix_p23;
            end
            else if(matrix_p21 <= matrix_p22 && matrix_p21 <= matrix_p23 && matrix_p22 >= matrix_p23) begin  // 2>3>1
                matrix_p2_max <= matrix_p22;
                matrix_p2_mid <= matrix_p23;
                matrix_p2_min <= matrix_p21;
            end
            else if(matrix_p21 >= matrix_p22 && matrix_p21 <= matrix_p23 && matrix_p22 <= matrix_p23) begin  // 3>1>2
                matrix_p2_max <= matrix_p23;
                matrix_p2_mid <= matrix_p21;
                matrix_p2_min <= matrix_p22;
            end
            else if(matrix_p21 <= matrix_p22 && matrix_p21 <= matrix_p23 && matrix_p22 <= matrix_p23) begin  // 3>2>1
                matrix_p2_max <= matrix_p23;
                matrix_p2_mid <= matrix_p22;
                matrix_p2_min <= matrix_p21;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            matrix_p3_max <= 8'b0;
            matrix_p3_mid <= 8'b0;
            matrix_p3_min <= 8'b0;
        end else if (pre_de) begin
            if(matrix_p31 >= matrix_p32 && matrix_p31 >= matrix_p33 && matrix_p32 >= matrix_p33) begin  // 1>=2>=3
                matrix_p3_max <= matrix_p31;
                matrix_p3_mid <= matrix_p32;
                matrix_p3_min <= matrix_p33;
            end
            else if(matrix_p31 >= matrix_p32 && matrix_p31 >= matrix_p33 && matrix_p32 <= matrix_p33) begin  // 1>3>2
                matrix_p3_max <= matrix_p31;
                matrix_p3_mid <= matrix_p33;
                matrix_p3_min <= matrix_p32;
            end
            else if(matrix_p31 <= matrix_p32 && matrix_p31 >= matrix_p33 && matrix_p32 >= matrix_p33) begin  // 2>1>3
                matrix_p3_max <= matrix_p32;
                matrix_p3_mid <= matrix_p31;
                matrix_p3_min <= matrix_p33;
            end
            else if(matrix_p31 <= matrix_p32 && matrix_p31 <= matrix_p33 && matrix_p32 >= matrix_p33) begin  // 2>3>1
                matrix_p3_max <= matrix_p32;
                matrix_p3_mid <= matrix_p33;
                matrix_p3_min <= matrix_p31;
            end
            else if(matrix_p31 >= matrix_p32 && matrix_p31 <= matrix_p33 && matrix_p32 <= matrix_p33) begin  // 3>1>2
                matrix_p3_max <= matrix_p33;
                matrix_p3_mid <= matrix_p31;
                matrix_p3_min <= matrix_p32;
            end
            else if(matrix_p31 <= matrix_p32 && matrix_p31 <= matrix_p33 && matrix_p32 <= matrix_p33) begin  // 3>2>1
                matrix_p3_max <= matrix_p33;
                matrix_p3_mid <= matrix_p32;
                matrix_p3_min <= matrix_p31;
            end
        end
    end

    // step2  3 行的最大值、 最小值、 中间值进行比较
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) max_min <= 8'b0;
        else if (pre_de) begin
            if(matrix_p1_max >= matrix_p2_max && matrix_p1_max >= matrix_p3_max && matrix_p2_max >= matrix_p3_max)  // 1>=2>=3
                max_min <= matrix_p3_max;
            else if(matrix_p1_max >= matrix_p2_max && matrix_p1_max >= matrix_p3_max && matrix_p2_max <= matrix_p3_max)  // 1>3>2
                max_min <= matrix_p2_max;
            else if(matrix_p1_max <= matrix_p2_max && matrix_p1_max >= matrix_p3_max && matrix_p2_max >= matrix_p3_max)  // 2>1>3
                max_min <= matrix_p3_max;
            else if(matrix_p1_max <= matrix_p2_max && matrix_p1_max <= matrix_p3_max && matrix_p2_max >= matrix_p3_max)  // 2>3>1
                max_min <= matrix_p1_max;
            else if(matrix_p1_max >= matrix_p2_max && matrix_p1_max <= matrix_p3_max && matrix_p2_max <= matrix_p3_max)  // 3>1>2
                max_min <= matrix_p2_max;
            else if(matrix_p1_max <= matrix_p2_max && matrix_p1_max <= matrix_p3_max && matrix_p2_max <= matrix_p3_max)  // 3>2>1
                max_min <= matrix_p1_max;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) mid_mid <= 8'b0;
        else if (pre_de) begin
            if(matrix_p1_mid >= matrix_p2_mid && matrix_p1_mid >= matrix_p3_mid && matrix_p2_mid >= matrix_p3_mid)  // 1>=2>=3
                mid_mid <= matrix_p2_mid;
            else if(matrix_p1_mid >= matrix_p2_mid && matrix_p1_mid >= matrix_p3_mid && matrix_p2_mid <= matrix_p3_mid)  // 1>3>2
                mid_mid <= matrix_p3_mid;
            else if(matrix_p1_mid <= matrix_p2_mid && matrix_p1_mid >= matrix_p3_mid && matrix_p2_mid >= matrix_p3_mid)  // 2>1>3
                mid_mid <= matrix_p1_mid;
            else if(matrix_p1_mid <= matrix_p2_mid && matrix_p1_mid <= matrix_p3_mid && matrix_p2_mid >= matrix_p3_mid)  // 2>3>1
                mid_mid <= matrix_p3_mid;
            else if(matrix_p1_mid >= matrix_p2_mid && matrix_p1_mid <= matrix_p3_mid && matrix_p2_mid <= matrix_p3_mid)  // 3>1>2
                mid_mid <= matrix_p1_mid;
            else if(matrix_p1_mid <= matrix_p2_mid && matrix_p1_mid <= matrix_p3_mid && matrix_p2_mid <= matrix_p3_mid)  // 3>2>1
                mid_mid <= matrix_p2_mid;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) min_max <= 8'b0;
        else if (pre_de) begin
            if(matrix_p1_min >= matrix_p2_min && matrix_p1_min >= matrix_p3_min && matrix_p2_min >= matrix_p3_min)  // 1>=2>=3
                min_max <= matrix_p1_min;
            else if(matrix_p1_min >= matrix_p2_min && matrix_p1_min >= matrix_p3_min && matrix_p2_min <= matrix_p3_min)  // 1>3>2
                min_max <= matrix_p1_min;
            else if(matrix_p1_min <= matrix_p2_min && matrix_p1_min >= matrix_p3_min && matrix_p2_min >= matrix_p3_min)  // 2>1>3
                min_max <= matrix_p2_min;
            else if(matrix_p1_min <= matrix_p2_min && matrix_p1_min <= matrix_p3_min && matrix_p2_min >= matrix_p3_min)  // 2>3>1
                min_max <= matrix_p2_min;
            else if(matrix_p1_min >= matrix_p2_min && matrix_p1_min <= matrix_p3_min && matrix_p2_min <= matrix_p3_min)  // 3>1>2
                min_max <= matrix_p3_min;
            else if(matrix_p1_min <= matrix_p2_min && matrix_p1_min <= matrix_p3_min && matrix_p2_min <= matrix_p3_min)  // 3>2>1
                min_max <= matrix_p3_min;
        end
    end

    // step3 得到 3x3 矩阵的中间值
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) post_data <= 8'b0;
        else if (pre_de) begin
            if (max_min >= mid_mid && max_min >= min_max && mid_mid >= min_max)  // 1>=2>=3
                post_data <= mid_mid;
            else if(max_min >= mid_mid && max_min >= min_max && mid_mid <= min_max)  // 1>3>2
                post_data <= min_max;
            else if(max_min <= mid_mid && max_min >= min_max && mid_mid >= min_max)  // 2>1>3
                post_data <= max_min;
            else if(max_min <= mid_mid && max_min <= min_max && mid_mid >= min_max)  // 2>3>1
                post_data <= min_max;
            else if(max_min >= mid_mid && max_min <= min_max && mid_mid <= min_max)  // 3>1>2
                post_data <= max_min;
            else if(max_min <= mid_mid && max_min <= min_max && mid_mid <= min_max)  // 3>2>1
                post_data <= mid_mid;
        end
    end

endmodule
