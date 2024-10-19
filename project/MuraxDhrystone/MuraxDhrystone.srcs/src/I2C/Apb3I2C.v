`timescale 1ns / 1ps

module Apb3I2C (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 3:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    // I2C 接口信号
    input  wire I2C_SDA,   // I2C 数据线
    inout  wire I2C_SCL,   // I2C 时钟线
    output wire interrupt  // I2C 中断输出
);

    // I2C 寄存器定义
    reg  [15:0] CR1;  // 控制寄存器1
    reg  [15:0] CR2;  // 控制寄存器2
    reg  [15:0] OAR1;  // 地址寄存器1
    reg  [15:0] OAR2;  // 地址寄存器2
    reg  [15:0] DR;  // 数据寄存器
    wire [15:0] SR1;  // 状态寄存器1
    wire [15:0] SR2;  // 状态寄存器2
    reg  [15:0] CCR;  // 时钟控制寄存器
    reg  [15:0] TRISE;  // 上升时间寄存器

    // I2C 中断输出
    assign interrupt = 1'b0;  // 未实现中断输出

    // I2C Config 接口定义
    // CR1
    wire       PE = CR1[0];  // I2C 使能
    wire       START = CR1[8];  // 启动条件产生
    wire       STOP = CR1[9];  // 停止条件产生
    wire       ACK = CR1[10];  // 应答使能
    // CR2
    wire       ITERREN = CR2[8];  // 出错中断使能
    wire       ITEVTEN = CR2[9];  // 事件中断使能
    wire       ITBUFEN = CR2[10];  // 缓冲区中断使能
    wire       DMAEN = CR2[11];  // DMA 使能
    // OAR1
    wire [6:0] ADD_7 = OAR1[7:1];  // 7位 从机地址
    wire [9:0] ADD_10 = OAR1[9:0];  // 10位 从机地址
    wire       ADDMODE = OAR1[15];  // 地址模式
    // SR1
    reg        SB = 1'b0;  // 起始位(主模式)
    wire       ADDR = 1'b0;  // 地址已被发送(主模式)/地址匹配(从模式)
    wire       BTF = 1'b0;  // 字节发送结束
    wire       ADD10 = 1'b0;  // 10位头序列已发送(主模式)
    wire       STOPF = 1'b0;  // 停止条件检测位(从模式)
    wire       RXNE = 1'b0;  // 数据寄存器非空(接收时)
    wire       TXE = 1'b0;  // 数据寄存器为空(发送时)
    wire       BERR = 1'b0;  // 总线出错
    wire       ARLO = 1'b0;  // 仲裁丢失(主模式)
    wire       AF = 1'b0;  // 应答失败
    wire       OVR = 1'b0;  // 过载/欠载
    wire       PECERR = 1'b0;  // 在接收时发生PEC错误
    wire       TMOUT = 1'b0;  // 超时或Tlow错误
    wire       SMBALERT = 1'b0;  // SMBus 提醒
    assign     SR1 = {SMBALERT, TMOUT, 1'b0, PECERR, OVR, AF, ARLO, BERR, TXE, RXNE, 1'b0, STOPF, ADD10, BTF, ADDR, SB};  // 状态寄存器1
    // SR2
    wire       MSL = 1'b0;  // 主从模式
    wire       BUSY = 1'b0;  // 总线忙
    wire       TRA = 1'b0;  // 发送/接收
    wire       GENCALL = 1'b0;  // 广播呼叫地址(从模式)
    wire       SMBDEFAULT = 1'b0;  // SMB 默认
    wire       SMBHOST = 1'b0;  // SMB 主机
    wire       DUALF = 1'b0;  // 双工模式
    wire [7:0] PEC = 1'b0;  // 错误校验位
    assign     SR2 = {PEC, DUALF, SMBHOST, SMBDEFAULT, GENCALL, 1'b0, TRA, BUSY, MSL};  // 状态寄存器2

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR1 <= 16'h0000;
            CR2 <= 16'h0000;
            OAR1 <= 16'h0000;
            OAR2 <= 16'h0000;
            DR <= 16'h0000;
            CCR <= 16'h0000;
            TRISE <= 16'h0000;
            SB <= 1'b0;
        end else begin
            CR1[8] <= 1'b0;  // 启动条件清除
            CR1[9] <= 1'b0;  // 停止条件清除
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    4'h0: CR1 <= io_apb_PWDATA[15:0];
                    4'h1: CR2 <= io_apb_PWDATA[15:0];
                    4'h2: OAR1 <= io_apb_PWDATA[15:0];
                    4'h3: OAR2 <= io_apb_PWDATA[15:0];
                    4'h4: DR <= io_apb_PWDATA[15:0];
                    4'h7: CCR <= io_apb_PWDATA[15:0];
                    4'h8: TRISE <= io_apb_PWDATA[15:0];
                    default: ;  // 其他寄存器不处理
                endcase
            end
            if (io_apb_PSEL)
                SB <= 1'b1;  // 已发送出起始条件
            if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE && io_apb_PADDR == 4'h5)
                SB <= 1'b0;
        end
    end

    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) begin
            io_apb_PRDATA = 32'h00000000;  // 复位时返回0
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    4'h0: io_apb_PRDATA <= {16'b0, CR1};
                    4'h1: io_apb_PRDATA <= {16'b0, CR2};
                    4'h2: io_apb_PRDATA <= {16'b0, OAR1};
                    4'h3: io_apb_PRDATA <= {16'b0, OAR2};
                    4'h4: io_apb_PRDATA <= {16'b0, DR};
                    4'h5: io_apb_PRDATA <= {16'b0, SR1};
                    4'h6: io_apb_PRDATA <= {16'b0, SR2};
                    4'h7: io_apb_PRDATA <= {16'b0, CCR};
                    4'h8: io_apb_PRDATA <= {16'b0, TRISE};
                    default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end

    // I2C 收发逻辑
    

endmodule
