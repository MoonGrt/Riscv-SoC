`timescale 1ns / 1ps

module Apb3SPI (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 2:0] io_apb_PADDR,    // 地址总线
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
    reg [15:0] CR1;       // 控制寄存器1
    reg [15:0] CR2;       // 控制寄存器2
    reg [15:0] SR;        // 状态寄存器
    reg [15:0] DR;        // 数据寄存器
    reg [15:0] CRCPR;     // CRC 寄存器
    reg [15:0] RXCRCR;    // 接收 CRC 寄存器
    reg [15:0] TXCRCR;    // 发送 CRC 寄存器
    reg [15:0] I2SCFGR;   // I2S 配置寄存器
    reg [15:0] I2SPR;     // I2S 预分频寄存器

    // APB 接口准备信号
    assign io_apb_PREADY = 1'b1;  // APB 总线始终准备好

    // APB 写寄存器逻辑
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR1     <= 16'h0000;
            CR2     <= 16'h0000;
            SR      <= 16'h0002;  // 默认设置TXE=1, 表示发送缓冲区空
            DR      <= 16'h0000;
            CRCPR   <= 16'h0007;
            RXCRCR  <= 16'h0000;
            TXCRCR  <= 16'h0000;
            I2SCFGR <= 16'h0000;
            I2SPR   <= 16'h0002;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    3'b000: CR1     <= io_apb_PWDATA[15:0];  // 写 CR1
                    3'b001: CR2     <= io_apb_PWDATA[15:0];  // 写 CR2
                    3'b010: DR      <= io_apb_PWDATA[15:0];  // 写 DR
                    3'b011: CRCPR   <= io_apb_PWDATA[15:0];  // 写 CRCPR
                    3'b100: I2SCFGR <= io_apb_PWDATA[15:0];  // 写 I2SCFGR
                    3'b101: I2SPR   <= io_apb_PWDATA[15:0];  // 写 I2SPR
                    default: ;  // 保留字段不处理
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
                    3'b000: io_apb_PRDATA = {16'b0, CR1};      // 读 CR1
                    3'b001: io_apb_PRDATA = {16'b0, CR2};      // 读 CR2
                    3'b010: io_apb_PRDATA = {16'b0, SR};       // 读 SR
                    3'b011: io_apb_PRDATA = {16'b0, DR};       // 读 DR
                    3'b100: io_apb_PRDATA = {16'b0, CRCPR};    // 读 CRCPR
                    3'b101: io_apb_PRDATA = {16'b0, RXCRCR};   // 读 RXCRCR
                    3'b110: io_apb_PRDATA = {16'b0, TXCRCR};   // 读 TXCRCR
                    3'b111: io_apb_PRDATA = {16'b0, I2SCFGR};  // 读 I2SCFGR
                    default: io_apb_PRDATA = 32'h00000000;     // 默认返回0
                endcase
            end
        end
    end

    // SPI 时钟生成逻辑
    reg [15:0] clk_div_counter;
    reg spi_clk;
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            clk_div_counter <= 16'h0000;
            spi_clk <= 1'b0;
        end else if (CR1[8]) begin  // 如果SPI使能
            if (clk_div_counter == I2SPR) begin
                clk_div_counter <= 16'h0000;
                spi_clk <= ~spi_clk;  // 时钟翻转
            end else begin
                clk_div_counter <= clk_div_counter + 1;
            end
        end else begin
            spi_clk <= 1'b0;  // 禁止时钟
        end
    end


    // SPI 传输逻辑


endmodule
