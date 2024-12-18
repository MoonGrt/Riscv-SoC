module filler #(
    parameter H_DISP = 12'd1280
) (
    input wire        rst_n,
    input wire        EN,

    input  wire        pre_clk,
    input  wire        pre_vs,
    input  wire        pre_de,
    input  wire [23:0] pre_data,
    output wire        post_clk,
    output wire        post_vs,
    output reg         post_de,
    output reg  [23:0] post_data
);

    // localparam BLACK = 24'b0;
    // reg  [11:0] pixel_x = 0;
    // reg  [11:0] brank_cnt = 0;
    // wire [11:0] brank_size = pre_de ? (H_DISP - pixel_x) : brank_size;
    // wire        fill_flag = brank_cnt < brank_size;

    // always @(posedge pre_clk) begin
    //     if (~rst_n | pre_vs) pixel_x <= 0;
    //     else if (pre_de) pixel_x <= pixel_x + 1;
    //     else pixel_x <= 0;
    // end

    // always @(posedge pre_clk) begin
    //     if (~rst_n | pre_vs) brank_cnt <= 0;
    //     else if (fill_flag && ~pre_de) brank_cnt <= brank_cnt + 1;
    //     else if (pre_de) brank_cnt <= 0;
    //     else brank_cnt <= brank_cnt;
    // end

    // assign post_vs = pre_vs;
    // assign post_de = EN ? (pre_de | fill_flag) : pre_de;
    // assign post_data = EN ? (pre_de ? pre_data : BLACK) : pre_data;

    // 定义状态
    localparam IDLE = 2'b00;  // 空闲状态
    localparam RECV = 2'b01;  // 接收像素数据状态
    localparam FILL = 2'b10;  // 填充黑色像素状态
    reg [ 1:0] state;  // 当前状态

    // 状态机与输出逻辑
    reg [11:0] pixel_count;  // 行内像素计数器
    assign post_clk = pre_clk;
    assign post_vs = pre_vs;
    always @(posedge pre_clk or negedge rst_n) begin
        if (~rst_n) begin
            // 复位所有信号
            state <= IDLE;
            pixel_count <= 12'd0;
            post_de <= 1'b0;
            post_data <= 24'h000000;
        end else begin
            // 默认信号赋值
            if (EN) begin
                post_de <= 1'b0;       // 默认不输出数据
                post_data <= 24'h000000; // 默认填充黑色
                case (state)
                    IDLE: begin  // 等待一行的开始
                        pixel_count <= 12'd0;  // 重置像素计数器
                        if (pre_de) state <= RECV;     // 检测到行开始，进入接收状态
                    end
                    RECV: begin
                        post_de <= 1'b1;
                        post_data <= pre_data;
                        if (pre_de) begin
                            pixel_count <= pixel_count + 1'b1;
                            if (pixel_count >= H_DISP - 1) state <= IDLE;  // 行满，回到IDLE状态
                        end else begin  // 行结束，如果像素数不足H_DISP，进入FILL状态
                            if (pixel_count < H_DISP) state <= FILL;
                            else state <= IDLE;
                        end
                    end
                    FILL: begin
                        post_de <= 1'b1;
                        post_data <= 24'h000000;  // 填充黑色
                        pixel_count <= pixel_count + 1'b1;
                        if (pixel_count >= H_DISP - 2) state <= IDLE;  // 达到H_DISP后回到IDLE
                    end
                endcase
            end else begin
                state <= IDLE;
                post_de <= pre_de;
                post_data <= pre_data;
            end
        end
    end

    // pixel 计数器
    reg [25:0] pixel_cnt = 0;
    always @(posedge pre_clk or negedge rst_n) begin
        if (~rst_n | pre_vs) pixel_cnt <= 0;
        else if (post_de) pixel_cnt <= pixel_cnt + 1;
        else pixel_cnt <= pixel_cnt;
    end

endmodule
