`timescale 1ns / 1ps

module gpio_apb (
    input wire clk,   // 主时钟
    input wire rst_n, // 系统复位信号

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
    reg [31:0] IDR;  // 输入数据寄存器
    reg [31:0] ODR;  // 输出数据寄存器
    reg [31:0] BSRR;  // 位设置/复位寄存器
    reg [31:0] BRR;  // 位复位寄存器
    reg [31:0] LCKR;  // 锁定寄存器

    // GPIO寄存器的输入输出方向和数据
    reg  [31:0] gpio_dir; // 用于控制每个引脚的输入/输出方向，1为输出，0为输入

    // 寄存器读写逻辑
    assign io_apb_PREADY = 1'b1;  // 总线准备信号始终为高电平
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            CRL <= 32'h00000000;
            CRH <= 32'h00000000;
            BSRR <= 32'h00000000;
            BRR <= 32'h00000000;
            LCKR <= 32'h00000000;
            io_apb_PRDATA <= 32'h00000000;
        end else if (io_apb_PSEL && io_apb_PENABLE) begin
            BSRR <= 32'h00000000;  // 复位位设置寄存器
            BRR  <= 32'h00000000;  // 复位位设置/复位寄存器
            if (io_apb_PWRITE) begin
                // 写寄存器
                case (io_apb_PADDR)  // 假设基地址为0x00，寄存器偏移4字节
                    3'b000:  CRL <= io_apb_PWDATA;  // CRL（控制低8个引脚）
                    3'b001:  CRH <= io_apb_PWDATA;  // CRH（控制高8个引脚）
                    3'b010:  BSRR <= io_apb_PWDATA;  // BSRR: 不读取 写入后马上复位
                    3'b011:  BRR <= io_apb_PWDATA;  // BRR: 不读取 写入后马上复位
                    3'b100:  LCKR <= io_apb_PWDATA;  // LCKR  // TODO: 未实现
                    default: ;  // 其他寄存器不处理
                endcase
            end else begin
                // 读寄存器
                case (io_apb_PADDR)
                    3'b000:  io_apb_PRDATA <= CRL;  // 读CRL
                    3'b001:  io_apb_PRDATA <= CRH;  // 读CRH
                    3'b010:  io_apb_PRDATA <= IDR;  // 读IDR
                    3'b011:  io_apb_PRDATA <= ODR;  // 读ODR
                    3'b110:  io_apb_PRDATA <= LCKR;  // 读LCKR
                    default: io_apb_PRDATA <= 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end

    // GPIO的inout双向控制逻辑
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin
            assign GPIO[i] = (gpio_dir[i]) ? ODR[i] : 1'bz; // 输出时为gpio_out，否则为高阻态
            always @(posedge clk or negedge rst_n) begin
                if (~rst_n) IDR[i] <= 1'b0;  // 默认所有引脚为低电平
                else if (!gpio_dir[i]) IDR[i] <= GPIO[i];  // 输入模式时读取GPIO值
            end
        end
    endgenerate

    // 根据CRL、CRH的设置来设置GPIO的方向和状态
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            gpio_dir <= 32'h00000000;  // 默认所有引脚为输入模式
            ODR <= 32'h00000000;  // 默认所有引脚为低电平
        end else begin
            for (integer i = 0; i < 8; i = i + 1) begin
                // 处理CRL配置（控制低8个引脚）
                case (CRL[i*4+:2])  // MODE[1:0]
                    2'b00:   gpio_dir[i] <= 1'b0;  // 输入模式
                    2'b01:   gpio_dir[i] <= 1'b1;  // 输出模式，10MHZ
                    2'b10:   gpio_dir[i] <= 1'b1;  // 输出模式， 2MHZ
                    2'b11:   gpio_dir[i] <= 1'b1;  // 输出模式，50MHZ
                    default: ;
                endcase
                case (CRL[i*4+2+:2])  // CNF[1:0]
                    2'b00: begin
                        if (CRL[i*4+:2] != 2'b00)  // 非输入模式
                            if (BSRR[i]) ODR[i] <= 1'b1;
                            else if (BSRR[i+8] | BRR[i]) ODR[i] <= 1'b0;  // 推挽输出
                        else
                            ODR[i] <= 1'b0;
                    end
                    2'b01: begin
                        if (CRL[i*4+:2] != 2'b00)  // 非输入模式
                            if (BSRR[i]) ODR[i] <= 1'b1;
                            else if (BSRR[i+8] | BRR[i]) ODR[i] <= 1'bz;  // 开漏输出
                        else
                            ODR[i] <= 1'bz;  // 高阻态
                    end
                    2'b10: begin
                        if (CRL[i*4+:2] != 2'b00)  // 非输入模式
                            if (AFIO[i]) ODR[i] <= 1'b1;
                            else ODR[i] <= 1'b0;  // 复用推挽输出
                        else
                            ODR[i] <= 1'b0;
                    end
                    2'b11: begin
                        if (CRL[i*4+:2] != 2'b00)  // 非输入模式
                            if (AFIO[i]) ODR[i] <= 1'b1;
                            else ODR[i] <= 1'bz;  // 复用开漏输出
                        else
                            ODR[i] <= 1'bz;  // 高阻态
                    end
                    default: ;
                endcase
                // 处理CRH配置（控制低8个引脚）
                case (CRH[i*4+:2])  // MODE[1:0]
                    2'b00:   gpio_dir[i+8] <= 1'b0;  // 输入模式
                    2'b01:   gpio_dir[i+8] <= 1'b1;  // 输出模式，10MHZ
                    2'b10:   gpio_dir[i+8] <= 1'b1;  // 输出模式， 2MHZ
                    2'b11:   gpio_dir[i+8] <= 1'b1;  // 输出模式，50MHZ
                    default: ;
                endcase
                case (CRH[i*4+2+:2])  // CNF[1:0]
                    2'b00: begin
                        if (CRH[i*4+:2] != 2'b00)  // 非输入模式
                            if (BSRR[i]) ODR[i+8] <= 1'b1;
                            else if (BSRR[i+8] | BRR[i]) ODR[i+8] <= 1'b0;  // 推挽输出
                        else
                            ODR[i+8] <= 1'b0;
                    end
                    2'b01: begin
                        if (CRH[i*4+:2] != 2'b00)  // 非输入模式
                            if (BSRR[i]) ODR[i+8] <= 1'b1;
                            else if (BSRR[i+8] | BRR[i]) ODR[i+8] <= 1'bz;  // 开漏输出
                        else
                            ODR[i+8] <= 1'bz;  // 高阻态
                    end
                    2'b10: begin
                        if (CRH[i*4+:2] != 2'b00)  // 非输入模式
                            if (AFIO[i]) ODR[i+8] <= 1'b1;
                            else ODR[i+8] <= 1'b0;  // 复用推挽输出
                        else
                            ODR[i+8] <= 1'b0;
                    end
                    2'b11: begin
                        if (CRH[i*4+:2] != 2'b00)  // 非输入模式
                            if (AFIO[i]) ODR[i+8] <= 1'b1;
                            else ODR[i+8] <= 1'bz;  // 复用开漏输出
                        else
                            ODR[i+8] <= 1'bz;  // 高阻态
                    end
                    default: ;
                endcase
            end
        end
    end

endmodule
