`timescale 1ns / 1ps

module WWDG (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 1:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    output reg WWDG_rst  // 看门狗复位信号
);

    // WWDG寄存器定义
    reg [7:0] CR;  // Control register
    reg [15:0] CFR;  // Configuration register
    reg SR;  // Status register

    // WWDG内部计数器和状态
    reg [15:0] prescaler_counter;
    wire [6:0] T = CR[6:0];
    wire [6:0] W = CFR[6:0];
    wire [2:0] prescaler_value = CFR[9:7];  // CFR中的预分频器
    wire WWDG_en = CR[7];  // 看门狗使能标志

    // APB 写寄存器逻辑 && 计数器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR <= 8'h7F;  // 初始计数器值最大
            CFR <= 16'h7F;  // 初始窗口值最大
            SR <= 1'b0;  // 初始状态寄存器清零
            WWDG_rst <= 1'b0;  // 看门狗复位信号清零
            prescaler_counter <= 16'h0000;
        end else begin
            // APB 写寄存器逻辑
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    2'b00: begin
                        if ((T > W) && WWDG_en) WWDG_rst <= 1'b1;  // 如果重载计数器时，计数器值大于窗口值，触发看门狗复位
                        else CR <= io_apb_PWDATA[15:0];  // 重载计数器
                    end
                    2'b01:   CFR <= io_apb_PWDATA;
                    2'b10:   SR <= io_apb_PWDATA;  // 写状态寄存器 (手动清除)
                    default: ;  // 其他寄存器不处理
                endcase
            end
            // 计数器逻辑
            if (WWDG_en) begin
                if (prescaler_counter == (1 << prescaler_value) - 1) begin
                    prescaler_counter <= 16'h0000;  // 分频计数器重置
                    if (T > 7'h40) begin
                        CR <= CR - 1;  // 计数器递减
                    end else begin
                        WWDG_rst <= 1'b1;  // 计数器达到 0 时发出复位信号
                        SR    <= 1'b1;  // 设置 SR 中的超时标志位
                    end
                end else prescaler_counter <= prescaler_counter + 1;  // 分频计数器增加
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) io_apb_PRDATA = 32'h00000000;
        // else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
        else begin
            case (io_apb_PADDR)
                2'b00:   io_apb_PRDATA = {24'h000000, CR};  // 读 Control register
                2'b01:   io_apb_PRDATA = {16'h000000, CFR};  // 读 Configuration register
                2'b10:   io_apb_PRDATA = {31'h0, SR};  // 读 Status register
                default: io_apb_PRDATA = 32'h00000000;
            endcase
        end
    end

endmodule
