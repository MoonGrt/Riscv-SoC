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

    // 状态机
    localparam IDLE = 2'b00;
    localparam RECV = 2'b01;
    localparam FILL = 2'b10;

    // 行内像素计数
    reg [ 1:0] state = IDLE;
    reg [11:0] pixel_count;  // 计数器，支持到H_DISP的最大值

    // 状态机与输出逻辑
    always @* begin
        if (~rst_n | pre_vs) begin
            state = IDLE;
        end else begin
            if (EN) begin
                case (state)
                    IDLE: if (pre_de) state = RECV;  // 检测到行开始，进入接收状态
                    RECV: if (~pre_de)  // 行结束，如果像素数不足H_DISP，进入FILL状态
                            if (pixel_count < H_DISP) state = FILL;
                            else state = IDLE;
                    FILL: if (pixel_count == H_DISP)
                            state = IDLE;  // 达到H_DISP后回到IDLE
                endcase
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // 复位所有信号
            pixel_count <= 12'd0;
            post_vs <= 1'b0;
            post_de <= 1'b0;
            post_data <= 24'h000000;
        end else if (pre_vs) begin
            post_vs <= 1'b0;
            post_de <= 1'b0;
            post_data <= 24'h000000;
        end else begin
            post_vs <= pre_vs;
            // 默认信号赋值
            if (EN) begin
                post_de <= 1'b0;       // 默认不输出数据
                post_data <= 24'h000000; // 默认填充黑色
                case (state)
                    IDLE:  // 等待一行的开始
                        pixel_count <= 12'd0;  // 重置像素计数器
                    RECV: begin
                        post_de <= 1'b1;
                        post_data <= pre_data;
                        if (pre_de) pixel_count <= pixel_count + 1'b1;
                    end
                    FILL: begin
                        post_de <= 1'b1;
                        post_data <= 24'h000000;  // 填充黑色
                        pixel_count <= pixel_count + 1'b1;
                    end
                endcase
            end else begin
                post_de <= pre_de;
                post_data <= pre_data;
            end
        end
    end

endmodule
