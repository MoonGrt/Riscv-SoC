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
    reg [15:0] CR1;  // 控制寄存器1
    reg [15:0] CR2;  // 控制寄存器2
    reg [15:0] OAR1;  // 地址寄存器1
    reg [15:0] OAR2;  // 地址寄存器2
    reg [15:0] DR;  // 数据寄存器
    reg [15:0] SR1;  // 状态寄存器1
    reg [15:0] SR2;  // 状态寄存器2
    reg [15:0] CCR;  // 时钟控制寄存器
    reg [15:0] TRISE;  // 上升时间寄存器

    // I2C 中断输出
    assign interrupt = (SR1[0] | SR1[1]);

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CR1 <= 16'h0000;
            CR2 <= 16'h0000;
            OAR1 <= 16'h0000;
            OAR2 <= 16'h0000;
            DR <= 16'h0000;
            SR1 <= 16'h0000;
            SR2 <= 16'h0000;
            CCR <= 16'h0000;
            TRISE <= 16'h0000;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    4'h0:  CR1 <= io_apb_PWDATA[15:0];
                    4'h1:  CR2 <= io_apb_PWDATA[15:0];
                    4'h2:  OAR1 <= io_apb_PWDATA[15:0];
                    4'h3:  OAR2 <= io_apb_PWDATA[15:0];
                    4'h4:  DR <= io_apb_PWDATA[15:0];
                    4'h5:  SR1 <= io_apb_PWDATA[15:0];
                    4'h6:  SR2 <= io_apb_PWDATA[15:0];
                    4'h7:  CCR <= io_apb_PWDATA[15:0];
                    4'h8:  TRISE <= io_apb_PWDATA[15:0];
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
                    4'h0:  io_apb_PRDATA <= {16'b0, CR1};
                    4'h1:  io_apb_PRDATA <= {16'b0, CR2};
                    4'h2:  io_apb_PRDATA <= {16'b0, OAR1};
                    4'h3:  io_apb_PRDATA <= {16'b0, OAR2};
                    4'h4:  io_apb_PRDATA <= {16'b0, DR};
                    4'h5:  io_apb_PRDATA <= {16'b0, SR1};
                    4'h6:  io_apb_PRDATA <= {16'b0, SR2};
                    4'h7:  io_apb_PRDATA <= {16'b0, CCR};
                    4'h8:  io_apb_PRDATA <= {16'b0, TRISE};
                    default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end

    // I2C 收发逻辑
    I2CCtrl #(
        .SLAVE_ADDR (),
        .CLK_FREQ   (),
        .I2C_FREQ   ())
    I2CCtrl (
        .clk        (),
        .rst_n      (),
        .i2c_exec   (),
        .bit_ctrl   (),
        .i2c_rh_wl  (),
        .i2c_addr   (),
        .i2c_data_w (),
        .i2c_data_r (),
        .i2c_done   (),
        .i2c_ack    (),
        .scl        (),
        .dri_clk    (),
        .sda        ()
    );

endmodule
