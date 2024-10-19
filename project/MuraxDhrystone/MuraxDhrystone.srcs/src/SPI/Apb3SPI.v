`timescale 1ns / 1ps

module Apb3SPI (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 3:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    // SPI 接口信号
    output wire SPI_SCK,   // SPI 时钟
    output wire SPI_MOSI,  // SPI 主输出从输入
    input  wire SPI_MISO,  // SPI 主输入从输出
    output wire SPI_CS,    // SPI 片选信号
    output wire interrupt  // SPI 中断输出
);

    // SPI 寄存器定义
    reg  [15:0] CR1;                  // 控制寄存器1
    reg  [15:0] CR2;                  // 控制寄存器2
    wire [15:0] SR;                   // 状态寄存器
    reg  [15:0] DR;                   // 数据寄存器
    reg  [15:0] CRCPR;                // CRC 寄存器
    wire [15:0] RXCRCR = 16'h0000;    // 接收 CRC 寄存器
    wire [15:0] TXCRCR = 16'h0000;    // 发送 CRC 寄存器
    reg  [15:0] I2SCFGR;              // I2S 配置寄存器
    reg  [15:0] I2SPR;                // I2S 预分频寄存器

    // SPI Config 接口定义
    // CR1
    wire        CPHA = CR1[0];  // 时钟相位
    wire        CPOL = CR1[1];  // 时钟极性
    wire        MSTR = CR1[2];  // 主设备选择
    wire [ 2:0] BR = CR1[5:3];  // 波特率控制
    wire        SPE = CR1[6];   // SPI使能
    wire        LSBFIRST = CR1[7];  // 帧格式  0：先发送MSB；1：先发送LSB。
    wire        SSI = CR1[8];   // 内部从设备选择
    wire        SSM = CR1[9];   // 软件从设备管理
    wire        RXONLY = CR1[10];  // 只接收
    wire        DFF = CR1[11];  // 数据帧格式  0：8位数据帧格式； 1：16位数据帧格式。
    wire        CRCNEXT = CR1[12];  // 下一个发送CRC
    wire        CRCEN = CR1[13];  // 硬件CRC校验使能
    wire        BIDIOE = CR1[14];  // 双向模式下的输出使能
    wire        BIDIMODE = CR1[14];  // 双向数据模式使能
    // CR2
    wire        RXDMAEN = CR2[0];  // 接收缓冲区DMA使能
    wire        TXDMAEN = CR2[1];  // 发送缓冲区DMA使能
    wire        SSOE = CR2[2];   // SS输出使能
    wire        ERRIE = CR2[5];  // 错误中断使能
    wire        RXNEIE = CR2[6];  // 接收缓冲区非空中断使能
    wire        TXEIE = CR2[7];   // 发送缓冲区空中断使能
    // SR
    wire        RXNE = 1'b0;    // 接收缓冲非空
    wire        TXE = 1'b1;     // 发送缓冲为空
    // wire        TXE;     // 发送缓冲为空
    wire        CHSIDE = 1'b0;  // 声道
    wire        UDR = 1'b0;     // 下溢标志位
    wire        CRCERR = 1'b0;  // CRC错误标志
    wire        MODF = 1'b0;    // 模式错误
    wire        OVR = 1'b0;     // 溢出标志
    wire        BSY = 1'b0;     // 忙标志
    assign      SR = {8'b0, BSY, OVR, MODF, CRCERR, UDR, CHSIDE, TXE, RXNE};  // 状态寄存器

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 总线始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR1     <= 16'h0000;
            CR2     <= 16'h0000;
            DR      <= 16'h0000;
            CRCPR   <= 16'h0000;
            I2SCFGR <= 16'h0000;
            I2SPR   <= 16'h0000;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    4'h0: CR1 <= io_apb_PWDATA[15:0];  // 写 CR1
                    4'h1: CR2 <= io_apb_PWDATA[15:0];  // 写 CR2
                    4'h3: DR <= io_apb_PWDATA[15:0];  // 写 DR
                    4'h4: CRCPR <= io_apb_PWDATA[15:0];  // 写 CRCPR
                    4'h7: I2SCFGR <= io_apb_PWDATA[15:0];  // 写 I2SCFGR
                    4'h8: I2SPR <= io_apb_PWDATA[15:0];  // 写 I2SPR
                    default: ;  // 其他寄存器不处理
                endcase
            end
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
                    4'h2: io_apb_PRDATA <= {16'b0, SR};
                    4'h3: io_apb_PRDATA <= {16'b0, DR};
                    4'h4: io_apb_PRDATA <= {16'b0, CRCPR};
                    4'h5: io_apb_PRDATA <= {16'b0, RXCRCR};
                    4'h6: io_apb_PRDATA <= {16'b0, TXCRCR};
                    4'h7: io_apb_PRDATA <= {16'b0, I2SCFGR};
                    4'h8: io_apb_PRDATA <= {16'b0, I2SPR};
                    default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end

    // 发送 SPI 接口定义
    reg TX_Vaild = 1'b0;
    always @(posedge io_apb_PCLK)
        TX_Vaild <= io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE && io_apb_PADDR == 4'h3;

    // SPI 逻辑
    SPICtrl SPICtrl (
        .clk       (io_apb_PCLK),
        .rst       (io_apb_PRESET),
        .CPOL      (CPOL),
        .CPHA      (CPHA),
        .BR        (BR),
        .DFF       (DFF),
        .LSBFIRST  (LSBFIRST),

        .i_TX_Byte (DR),
        .i_TX_Vaild(TX_Vaild),
        .o_TX_Ready(),
        .o_RX_Vaild(),
        .o_RX_Byte (),

        .o_SPI_SCK (SPI_SCK),
        .i_SPI_MISO(SPI_MISO),
        .o_SPI_MOSI(SPI_MOSI),
        .o_SPI_CS  (SPI_CS)
    );

endmodule
