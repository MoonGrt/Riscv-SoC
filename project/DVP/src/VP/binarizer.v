module binarizer (
    // module clock
    input clk,    // 时钟信号
    input rst_n,  // 复位信号（低有效）
    input EN,     // 使能信号
    input [7:0] threshold,  // 阈值
 
    // 图像处理前的数据接口
    input       pre_vs,  // vs信号
    input       pre_de,  // data enable信号
    input [7:0] pre_data,

    // 图像处理后的数据接口
    output     post_vs,  // vs信号
    output     post_de,  // data enable信号
    output reg post_bit  // bit（1=白，0=黑）
);

    // reg define
    reg bit_d0;
    reg pre_vs_d;
    reg pre_de_d;

    //*****************************************************
    //**                    main code
    //*****************************************************

    assign bit_fall = (!post_bit) & bit_d0;
    assign post_vs = pre_vs_d;
    assign post_de = pre_de_d;

    // 寄存以找下降沿
    always @(posedge clk) begin
        bit_d0 <= post_bit;
    end

    // 二值化
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) post_bit <= 1'b0;
        else if (pre_data > threshold)  // 阈值
            post_bit <= 1'b1;
        else post_bit <= 1'b0;
    end

    // 延时2拍以同步时钟信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_vs_d <= 1'd0;
            pre_de_d <= 1'd0;
        end else begin
            pre_vs_d <= pre_vs;
            pre_de_d <= pre_de;
        end
    end

endmodule
