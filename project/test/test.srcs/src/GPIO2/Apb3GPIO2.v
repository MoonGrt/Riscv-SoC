`timescale 1ns / 1ps

module Apb3GPIO2 (
    input wire clk,  // 主时钟
    input wire rst,  // 系统复位信号

    input  wire [ 2:0] io_apb_PADDR,    // 地址总线
    input  wire [ 0:0] io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    input wire [15:0] AFIO,  // 复用IO引脚
    inout wire [15:0] GPIO   // 双向IO引脚
);

    // GPIO寄存器定义
    reg [31:0] CRL;  // 控制寄存器低字（控制低8个引脚）
    reg [31:0] CRH;  // 控制寄存器高字（控制高8个引脚）
    reg [15:0] IDR;  // 输入数据寄存器 只有低16位有效
    reg [15:0] ODR;  // 输出数据寄存器 只有低16位有效
    reg [15:0] BSRR;  // 位设置/复位寄存器 只有低16位有效
    reg [15:0] BRR;  // 位复位寄存器 只有低16位有效
    reg [15:0] LCKR;  // 锁定寄存器 只有低16位有效

    // GPIO寄存器的输入输出方向和数据
    // reg [15:0] gpio_dir; // 用于控制每个引脚的输入/输出方向，1为输出，0为输入


    // 寄存器读写逻辑
    assign io_apb_PREADY = 1'b1;  // 总线准备信号始终为高电平
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            CRL <= 32'h00000000;
            CRH <= 32'h00000000;
            BSRR <= 32'h00000000;
            BRR <= 32'h00000000;
            LCKR <= 32'h00000000;
            io_apb_PRDATA <= 32'h00000000;
        end else if (io_apb_PSEL && io_apb_PENABLE) begin
            if (io_apb_PWRITE) begin
                // 写寄存器
                case (io_apb_PADDR)  // 假设基地址为0x00，寄存器偏移4字节
                    3'b000:  CRL <= io_apb_PWDATA;  // CRL（控制低8个引脚）
                    3'b001:  CRH <= io_apb_PWDATA;  // CRH（控制高8个引脚）
                    3'b100:  BSRR <= io_apb_PWDATA[15:0];  // BSRR: 不读取 写入后马上复位
                    3'b101:  BRR <= io_apb_PWDATA[15:0];  // BRR: 不读取 写入后马上复位
                    3'b110:  LCKR <= io_apb_PWDATA[15:0];  // LCKR  // TODO: 未实现
                    default: ;  // 其他寄存器不处理
                endcase
            end else begin
                // 读寄存器
                case (io_apb_PADDR)
                    3'b000:  io_apb_PRDATA <= CRL;  // 读CRL
                    3'b001:  io_apb_PRDATA <= CRH;  // 读CRH
                    3'b010:  io_apb_PRDATA <= {16'h0000, IDR};  // 读IDR
                    3'b011:  io_apb_PRDATA <= {16'h0000, ODR};  // 读ODR
                    3'b110:  io_apb_PRDATA <= {16'h0000, LCKR};  // 读LCKR
                    default: io_apb_PRDATA <= 32'h00000000;  // 默认返回0
                endcase
            end
        end
        else begin
            BSRR <= 32'h00000000;  // 复位位设置寄存器
            BRR  <= 32'h00000000;  // 复位位设置/复位寄存器
        end
    end

    // GPIO的inout双向控制逻辑
    wire [15:0] gpio_dir;
    wire [63:0] gpio_ctrl = {BRR, BSRR};
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin
            assign GPIO[i] = (gpio_dir[i]) ? ODR[i] : 1'bz; // 输出时为gpio_out，否则为高阻态
            always @(posedge clk or posedge rst) begin
                if (rst) IDR[i] <= 1'bz;  // 默认所有引脚为高阻态
                else if (!gpio_dir[i]) IDR[i] <= GPIO[i];  // 输入模式时读取GPIO值
            end

            assign gpio_dir[i] = (gpio_ctrl[i*4+:2] == 2'b00) ? 1'b0 : 1'b1;  // gpio_ctrl[i*4+:2]==MODE 输入模式时gpio_dir为0，输出模式时gpio_dir为1
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    ODR[i] <= 1'bz;  // 默认所有引脚为高阻态
                end else if (BSRR[i]|BRR[i]) begin
                    // 设置ODR和输出类型
                    case (gpio_ctrl[i*4+3])  // gpio_ctrl[i*4+3]==MODE[1]
                        1'b0: begin
                            if (BSRR[i]) ODR[i] <= 1'b1;
                            else if (BRR[i]) begin
                                case (gpio_ctrl[i*4+2])  // gpio_ctrl[i*4+2]==CNF[0]
                                    1'b0: ODR[i] <= 1'b1;  // 推挽输出
                                    1'b1: ODR[i] <= 1'bz;  // 开漏输出
                                endcase
                            end
                        end
                        1'b1: begin
                            if (AFIO[i]) ODR[i] <= 1'b1;
                            else begin
                                case (gpio_ctrl[i*4+2])  // gpio_ctrl[i*4+2]==CNF[0]
                                    1'b0: ODR[i] <= 1'b1;  // 推挽输出
                                    1'b1: ODR[i] <= 1'bz;  // 开漏输出
                                endcase
                            end
                        end
                        default: ;
                    endcase
                end
            end
        end
    endgenerate

endmodule
