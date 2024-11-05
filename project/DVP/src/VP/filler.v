module filler #(
    parameter H_DISP = 12'd1280  // Horizontal resolution
) (
    // global clock
    input wire clk,    // cmos video pixel clock
    input wire rst_n,  // global reset
    input wire EN,     // enable

    // Image data prepared to be processed
    input wire        pre_vs,   // Prepared Image data vs valid signal
    input wire        pre_de,   // Prepared Image data output/capture enable clock
    input wire [23:0] pre_data, // Prepared Image data (24-bit color)

    // Image data after being processed
    output reg        post_vs,   // Processed Image data vs valid signal
    output reg        post_de,   // Processed Image data output/capture enable clock
    output reg [23:0] post_data  // Processed Image data (24-bit color)
);

    // 行内像素计数
    reg [11:0] pixel_count;  // 计数器，支持到H_DISP的最大值
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位信号
            pixel_count <= 12'd0;
            post_vs <= 1'b0;
            post_de <= 1'b0;
            post_data <= 24'h000000;
        end else begin
            // 传递垂直同步信号
            post_vs <= pre_vs;

            if (EN) begin
                // 检查de信号并执行填充逻辑
                if (pre_de) begin
                    // de信号有效时，逐行处理图像数据
                    post_de <= 1'b1;
                    // 如果像素计数未达到H_DISP，则正常输出
                    if (pixel_count < H_DISP) begin
                        post_data   <= pre_data;  // 传递当前像素数据
                        pixel_count <= pixel_count + 1'b1;
                    end
                end else begin
                    // 如果行结束或无效，则复位计数器并填充黑色像素
                    post_de <= 1'b0;
                    post_data <= 24'h000000;  // 填充黑色像素
                    pixel_count <= 12'd0;     // 行结束，重置计数器
                end
            end else begin
                post_de   <= pre_de;
                post_data <= pre_data;
            end
        end
    end

endmodule
