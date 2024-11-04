`timescale 1ns / 1ns
module median #(
    parameter [8:0] IMG_HDISP = 9'd1280,  // 1280*720
    parameter [7:0] IMG_VDISP = 8'd720
) (
    //global clock
    input wire clk,   // cmos video pixel clock
    input wire rst_n, // global reset

    //Image data prepred to be processd
    input wire       per_frame_vsync,  // Prepared Image data vsync valid signal
    input wire       per_frame_href,   // Prepared Image data href vaild  signal
    input wire       per_frame_clken,  // Prepared Image data output/capture enable clock
    input wire [7:0] per_y,            // Prepared Image brightness input
    input wire [7:0] per_Cr,
    input wire [7:0] per_Cb,

    //Image data has been processd
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

    wire [7:0] matrix_p11_y, matrix_p12_y, matrix_p13_y;  //3X3 Matrix output
    wire [7:0] matrix_p21_y, matrix_p22_y, matrix_p23_y;
    wire [7:0] matrix_p31_y, matrix_p32_y, matrix_p33_y;

    reg [7:0] matrix_p1_max, matrix_p1_mid, matrix_p1_min;
    reg [7:0] matrix_p2_max, matrix_p2_mid, matrix_p2_min;
    reg [7:0] matrix_p3_max, matrix_p3_mid, matrix_p3_min;
    reg [7:0] max_min, mid_mid, min_max, mid;

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

    // step1  分别求出 3 行中同一行的最大值、 最小值、 中间值
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_p1_max <= 8'b0;
            matrix_p1_mid <= 8'b0;
            matrix_p1_min <= 8'b0;
        end else if (per_frame_clken) begin
            if(matrix_p11_y >= matrix_p12_y && matrix_p11_y >= matrix_p13_y && matrix_p12_y >= matrix_p13_y)begin // 1>=2>=3
                matrix_p1_max <= matrix_p11_y;
                matrix_p1_mid <= matrix_p12_y;
                matrix_p1_min <= matrix_p13_y;
            end
            else if(matrix_p11_y >= matrix_p12_y && matrix_p11_y >= matrix_p13_y && matrix_p12_y <= matrix_p13_y)begin//1>3>2
                matrix_p1_max <= matrix_p11_y;
                matrix_p1_mid <= matrix_p13_y;
                matrix_p1_min <= matrix_p12_y;
            end
            else if(matrix_p11_y <= matrix_p12_y && matrix_p11_y >= matrix_p13_y && matrix_p12_y >= matrix_p13_y)begin//2>1>3
                matrix_p1_max <= matrix_p12_y;
                matrix_p1_mid <= matrix_p11_y;
                matrix_p1_min <= matrix_p13_y;
            end
            else if(matrix_p11_y <= matrix_p12_y && matrix_p11_y <= matrix_p13_y && matrix_p12_y >= matrix_p13_y)begin//2>3>1
                matrix_p1_max <= matrix_p12_y;
                matrix_p1_mid <= matrix_p13_y;
                matrix_p1_min <= matrix_p11_y;
            end
            else if(matrix_p11_y >= matrix_p12_y && matrix_p11_y <= matrix_p13_y && matrix_p12_y <= matrix_p13_y)begin//3>1>2
                matrix_p1_max <= matrix_p13_y;
                matrix_p1_mid <= matrix_p11_y;
                matrix_p1_min <= matrix_p12_y;
            end
            else if(matrix_p11_y <= matrix_p12_y && matrix_p11_y <= matrix_p13_y && matrix_p12_y <= matrix_p13_y)begin//3>2>1
                matrix_p1_max <= matrix_p13_y;
                matrix_p1_mid <= matrix_p12_y;
                matrix_p1_min <= matrix_p11_y;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_p2_max <= 8'b0;
            matrix_p2_mid <= 8'b0;
            matrix_p2_min <= 8'b0;
        end else if (per_frame_clken) begin
            if(matrix_p21_y >= matrix_p22_y && matrix_p21_y >= matrix_p23_y && matrix_p22_y >= matrix_p23_y)begin // 1>=2>=3
                matrix_p2_max <= matrix_p21_y;
                matrix_p2_mid <= matrix_p22_y;
                matrix_p2_min <= matrix_p23_y;
            end
            else if(matrix_p21_y >= matrix_p22_y && matrix_p21_y >= matrix_p23_y && matrix_p22_y <= matrix_p23_y)begin//1>3>2
                matrix_p2_max <= matrix_p21_y;
                matrix_p2_mid <= matrix_p23_y;
                matrix_p2_min <= matrix_p22_y;
            end
            else if(matrix_p21_y <= matrix_p22_y && matrix_p21_y >= matrix_p23_y && matrix_p22_y >= matrix_p23_y)begin//2>1>3
                matrix_p2_max <= matrix_p22_y;
                matrix_p2_mid <= matrix_p21_y;
                matrix_p2_min <= matrix_p23_y;
            end
            else if(matrix_p21_y <= matrix_p22_y && matrix_p21_y <= matrix_p23_y && matrix_p22_y >= matrix_p23_y)begin//2>3>1
                matrix_p2_max <= matrix_p22_y;
                matrix_p2_mid <= matrix_p23_y;
                matrix_p2_min <= matrix_p21_y;
            end
            else if(matrix_p21_y >= matrix_p22_y && matrix_p21_y <= matrix_p23_y && matrix_p22_y <= matrix_p23_y)begin//3>1>2
                matrix_p2_max <= matrix_p23_y;
                matrix_p2_mid <= matrix_p21_y;
                matrix_p2_min <= matrix_p22_y;
            end
            else if(matrix_p21_y <= matrix_p22_y && matrix_p21_y <= matrix_p23_y && matrix_p22_y <= matrix_p23_y)begin//3>2>1
                matrix_p2_max <= matrix_p23_y;
                matrix_p2_mid <= matrix_p22_y;
                matrix_p2_min <= matrix_p21_y;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            matrix_p3_max <= 8'b0;
            matrix_p3_mid <= 8'b0;
            matrix_p3_min <= 8'b0;
        end else if (per_frame_clken) begin
            if(matrix_p31_y >= matrix_p32_y && matrix_p31_y >= matrix_p33_y && matrix_p32_y >= matrix_p33_y)begin // 1>=2>=3
                matrix_p3_max <= matrix_p31_y;
                matrix_p3_mid <= matrix_p32_y;
                matrix_p3_min <= matrix_p33_y;
            end
            else if(matrix_p31_y >= matrix_p32_y && matrix_p31_y >= matrix_p33_y && matrix_p32_y <= matrix_p33_y)begin//1>3>2
                matrix_p3_max <= matrix_p31_y;
                matrix_p3_mid <= matrix_p33_y;
                matrix_p3_min <= matrix_p32_y;
            end
            else if(matrix_p31_y <= matrix_p32_y && matrix_p31_y >= matrix_p33_y && matrix_p32_y >= matrix_p33_y)begin//2>1>3
                matrix_p3_max <= matrix_p32_y;
                matrix_p3_mid <= matrix_p31_y;
                matrix_p3_min <= matrix_p33_y;
            end
            else if(matrix_p31_y <= matrix_p32_y && matrix_p31_y <= matrix_p33_y && matrix_p32_y >= matrix_p33_y)begin//2>3>1
                matrix_p3_max <= matrix_p32_y;
                matrix_p3_mid <= matrix_p33_y;
                matrix_p3_min <= matrix_p31_y;
            end
            else if(matrix_p31_y >= matrix_p32_y && matrix_p31_y <= matrix_p33_y && matrix_p32_y <= matrix_p33_y)begin//3>1>2
                matrix_p3_max <= matrix_p33_y;
                matrix_p3_mid <= matrix_p31_y;
                matrix_p3_min <= matrix_p32_y;
            end
            else if(matrix_p31_y <= matrix_p32_y && matrix_p31_y <= matrix_p33_y && matrix_p32_y <= matrix_p33_y)begin//3>2>1
                matrix_p3_max <= matrix_p33_y;
                matrix_p3_mid <= matrix_p32_y;
                matrix_p3_min <= matrix_p31_y;
            end
        end
    end

    // step2  3 行的最大值、 最小值、 中间值进行比较
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            max_min <= 8'b0;
        end else if (per_frame_clken) begin
            if(matrix_p1_max >= matrix_p2_max && matrix_p1_max >= matrix_p3_max && matrix_p2_max >= matrix_p3_max)begin // 1>=2>=3
                max_min <= matrix_p3_max;
            end
            else if(matrix_p1_max >= matrix_p2_max && matrix_p1_max >= matrix_p3_max && matrix_p2_max <= matrix_p3_max)begin//1>3>2
                max_min <= matrix_p2_max;
            end
            else if(matrix_p1_max <= matrix_p2_max && matrix_p1_max >= matrix_p3_max && matrix_p2_max >= matrix_p3_max)begin//2>1>3
                max_min <= matrix_p3_max;
            end
            else if(matrix_p1_max <= matrix_p2_max && matrix_p1_max <= matrix_p3_max && matrix_p2_max >= matrix_p3_max)begin//2>3>1
                max_min <= matrix_p1_max;
            end
            else if(matrix_p1_max >= matrix_p2_max && matrix_p1_max <= matrix_p3_max && matrix_p2_max <= matrix_p3_max)begin//3>1>2
                max_min <= matrix_p2_max;
            end
            else if(matrix_p1_max <= matrix_p2_max && matrix_p1_max <= matrix_p3_max && matrix_p2_max <= matrix_p3_max)begin//3>2>1
                max_min <= matrix_p1_max;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mid_mid <= 8'b0;
        end else if (per_frame_clken) begin
            if(matrix_p1_mid >= matrix_p2_mid && matrix_p1_mid >= matrix_p3_mid && matrix_p2_mid >= matrix_p3_mid)begin // 1>=2>=3
                mid_mid <= matrix_p2_mid;
            end
            else if(matrix_p1_mid >= matrix_p2_mid && matrix_p1_mid >= matrix_p3_mid && matrix_p2_mid <= matrix_p3_mid)begin//1>3>2
                mid_mid <= matrix_p3_mid;
            end
            else if(matrix_p1_mid <= matrix_p2_mid && matrix_p1_mid >= matrix_p3_mid && matrix_p2_mid >= matrix_p3_mid)begin//2>1>3
                mid_mid <= matrix_p1_mid;
            end
            else if(matrix_p1_mid <= matrix_p2_mid && matrix_p1_mid <= matrix_p3_mid && matrix_p2_mid >= matrix_p3_mid)begin//2>3>1
                mid_mid <= matrix_p3_mid;
            end
            else if(matrix_p1_mid >= matrix_p2_mid && matrix_p1_mid <= matrix_p3_mid && matrix_p2_mid <= matrix_p3_mid)begin//3>1>2
                mid_mid <= matrix_p1_mid;
            end
            else if(matrix_p1_mid <= matrix_p2_mid && matrix_p1_mid <= matrix_p3_mid && matrix_p2_mid <= matrix_p3_mid)begin//3>2>1
                mid_mid <= matrix_p2_mid;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            min_max <= 8'b0;
        end else if (per_frame_clken) begin
            if(matrix_p1_min >= matrix_p2_min && matrix_p1_min >= matrix_p3_min && matrix_p2_min >= matrix_p3_min)begin // 1>=2>=3
                min_max <= matrix_p1_min;
            end
            else if(matrix_p1_min >= matrix_p2_min && matrix_p1_min >= matrix_p3_min && matrix_p2_min <= matrix_p3_min)begin//1>3>2
                min_max <= matrix_p1_min;
            end
            else if(matrix_p1_min <= matrix_p2_min && matrix_p1_min >= matrix_p3_min && matrix_p2_min >= matrix_p3_min)begin//2>1>3
                min_max <= matrix_p2_min;
            end
            else if(matrix_p1_min <= matrix_p2_min && matrix_p1_min <= matrix_p3_min && matrix_p2_min >= matrix_p3_min)begin//2>3>1
                min_max <= matrix_p2_min;
            end
            else if(matrix_p1_min >= matrix_p2_min && matrix_p1_min <= matrix_p3_min && matrix_p2_min <= matrix_p3_min)begin//3>1>2
                min_max <= matrix_p3_min;
            end
            else if(matrix_p1_min <= matrix_p2_min && matrix_p1_min <= matrix_p3_min && matrix_p2_min <= matrix_p3_min)begin//3>2>1
                min_max <= matrix_p3_min;
            end
        end
    end

    // step3 得到 3x3 矩阵的中间值
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            post_y <= 8'b0;
        end else if (per_frame_clken) begin
            if (max_min >= mid_mid && max_min >= min_max && mid_mid >= min_max) begin  // 1>=2>=3
                post_y <= mid_mid;
            end
            else if(max_min >= mid_mid && max_min >= min_max && mid_mid <= min_max)begin//1>3>2
                post_y <= min_max;
            end
            else if(max_min <= mid_mid && max_min >= min_max && mid_mid >= min_max)begin//2>1>3
                post_y <= max_min;
            end
            else if(max_min <= mid_mid && max_min <= min_max && mid_mid >= min_max)begin//2>3>1
                post_y <= min_max;
            end
            else if(max_min >= mid_mid && max_min <= min_max && mid_mid <= min_max)begin//3>1>2
                post_y <= max_min;
            end
            else if(max_min <= mid_mid && max_min <= min_max && mid_mid <= min_max)begin//3>2>1
                post_y <= mid_mid;
            end
        end
    end

    //---------------------------------------
    // lag 3 clocks signal sync  
    reg [2:0] per_frame_vsync_r;
    reg [2:0] per_frame_href_r;
    reg [2:0] per_frame_clken_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_frame_vsync_r <= 0;
            per_frame_href_r  <= 0;
            per_frame_clken_r <= 0;
        end else begin
            per_frame_vsync_r <= {per_frame_vsync_r[1:0], matrix_frame_vsync};
            per_frame_href_r  <= {per_frame_href_r[1:0], matrix_frame_href};
            per_frame_clken_r <= {per_frame_clken_r[1:0], matrix_frame_clken};
        end
    end

    assign post_frame_vsync = per_frame_vsync_r[2];
    assign post_frame_href  = per_frame_href_r[2];
    assign post_frame_clken = per_frame_clken_r[2];

endmodule
