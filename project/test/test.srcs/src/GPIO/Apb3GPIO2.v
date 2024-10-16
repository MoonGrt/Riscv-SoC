`timescale 1ns / 1ps

module Apb3GPIO2 (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 2:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    input wire [15:0] AFIO,  // 复用IO引脚
    inout wire [15:0] GPIO   // 双向IO引脚
);

    // GPIO寄存器定义
    reg [31:0] CRL;  // 控制寄存器低字（控制低8个引脚）
    reg [31:0] CRH;  // 控制寄存器高字（控制高8个引脚）
    reg [15:0] IDR;  // 输入数据寄存器 只有低16位有效
    reg [15:0] ODR;  // 输出数据寄存器 只有低16位有效
    reg [15:0] BSR;  // 位设置/复位寄存器 只有低16位有效
    reg [15:0] BRR;  // 位复位寄存器 只有低16位有效
    reg [15:0] LCKR;  // 锁定寄存器 只有低16位有效

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CRL  <= 32'h00000000;
            CRH  <= 32'h00000000;
            BSR  <= 16'h0000;
            BRR  <= 16'h0000;
            LCKR <= 16'h0000;
        end else begin
            BSR <= 16'h0000;  // 复位位设置寄存器
            BRR <= 16'h0000;  // 复位位设置/复位寄存器
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                // 写寄存器
                case (io_apb_PADDR)  // 假设基地址为0x00，寄存器偏移4字节
                    3'b000:  CRL <= io_apb_PWDATA;  // CRL（控制低8个引脚）
                    3'b001:  CRH <= io_apb_PWDATA;  // CRH（控制高8个引脚）
                    3'b100:  BSR <= io_apb_PWDATA[15:0];  // BSR: 不读取 写入后马上复位
                    3'b101:  BRR <= io_apb_PWDATA[15:0];  // BRR: 不读取 写入后马上复位
                    3'b110:  LCKR <= io_apb_PWDATA[15:0];  // LCKR  // TODO: 未实现
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) io_apb_PRDATA = 32'h00000000;
        else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
            case (io_apb_PADDR)
                3'b000:  io_apb_PRDATA = CRL;  // 读 CRL
                3'b001:  io_apb_PRDATA = CRH;  // 读 CRH
                3'b010:  io_apb_PRDATA = {16'h0000, IDR};  // 读 IDR
                3'b011:  io_apb_PRDATA = {16'h0000, ODR};  // 读 ODR
                3'b110:  io_apb_PRDATA = {16'h0000, LCKR};  // 读 LCKR
                default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
            endcase
        end
    end


    // GPIO 的 inout 双向控制逻辑
    wire [15:0] gpio_dir;  // 用于控制每个引脚的输入/输出方向，1为输出，0为输入
    wire [63:0] gpio_ctrl = {CRH, CRL};  // 控制寄存器的低字和高字合并
    generate
        genvar i;
        for (i = 0; i < 16; i = i + 1) begin
            assign GPIO[i] = ODR[i];
            assign gpio_dir[i] = (gpio_ctrl[i*4+:2] == 2'b00) ? 1'b0 : 1'b1;  // gpio_ctrl[i*4+:2]==MODE 输入模式时gpio_dir为0，输出模式时gpio_dir为1
            // always @(*) begin
            always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
                if (io_apb_PRESET) ODR[i] <= 1'bz;
                else if (gpio_dir[i]) begin  // 输出模式
                    IDR[i] <= 1'bz;  // 输出模式时IDR为高阻态
                    if (gpio_ctrl[i*4+3]) begin  // 复用 IO 引脚
                        ODR[i] <= AFIO[i] ? 1'b1 : (gpio_ctrl[i*4+2] ? 1'bz : 1'b0);  // 输出类型为推挽时，输出为0，否则为高阻态
                    end else begin  // 普通 IO 引脚
                        if (BSR[i]) ODR[i] <= 1'b1;
                        if (BRR[i])
                            ODR[i] <= gpio_ctrl[i*4+2] ? 1'bz : 1'b0;  // 输出类型为推挽时，输出为0，否则为高阻态
                    end
                end else begin
                    IDR[i] <= GPIO[i];  // 输入模式时读取GPIO值
                    ODR[i] <= 1'bz;  // 输入模式时GPIO为高阻态
                end
            end

            // assign GPIO[i] = (gpio_dir[i]) ? ODR[i] : 1'bz; // 输出时为gpio_out，否则为高阻态
            // always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
            //     if (io_apb_PRESET) IDR[i] <= 1'bz;  // 默认所有引脚为高阻态
            //     else if (~gpio_dir[i]) IDR[i] <= GPIO[i];  // 输入模式时读取GPIO值
            // end
            // assign gpio_dir[i] = (gpio_ctrl[i*4+:2] == 2'b00) ? 1'b0 : 1'b1;  // gpio_ctrl[i*4+:2]==MODE 输入模式时gpio_dir为0，输出模式时gpio_dir为1
            // always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
            //     if (io_apb_PRESET) begin
            //         ODR[i] <= 1'bz;  // 默认所有引脚为高阻态
            //     // end else if ((BSR[i] | BRR[i]) & gpio_dir[i]) begin
            //     //     case (gpio_ctrl[i*4+3])  // gpio_ctrl[i*4+3]==MODE[1]
            //     //         1'b0: begin
            //     //             if (BSR[i]) ODR[i] <= 1'b1;
            //     //             else if (BRR[i])
            //     //                 ODR[i] <= gpio_ctrl[i*4+2] ? 1'bz : 1'b0;  // 输出类型为推挽时，输出为0，否则为高阻态
            //     //         end
            //     //         default: begin
            //     //             if (AFIO[i]) ODR[i] <= 1'b1;
            //     //             else
            //     //                 ODR[i] <= gpio_ctrl[i*4+2] ? 1'bz : 1'b0;  // 输出类型为推挽时，输出为0，否则为高阻态
            //     //         end
            //     //     endcase
            //     // end
            //     end else begin
            //         if (gpio_ctrl[i*4+3]) begin  // 复用 IO 引脚
            //             ODR[i] <= AFIO[i] ? 1'b1 : (gpio_ctrl[i*4+2] ? 1'bz : 1'b0);  // 输出类型为推挽时，输出为0，否则为高阻态
            //         end else begin  // 普通 IO 引脚
            //             if (BSR[i]) ODR[i] <= 1'b1;
            //             if (BRR[i]) ODR[i] <= gpio_ctrl[i*4+2] ? 1'bz : 1'b0;  // 输出类型为推挽时，输出为0，否则为高阻态
            //         end
            //     end
            // end
        end
    endgenerate

endmodule

// TODO: Buffer模块
