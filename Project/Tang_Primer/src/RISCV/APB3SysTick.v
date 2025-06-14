module Apb3SysTick (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [15:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // 读数据总线
    output reg  [31:0] io_apb_PRDATA,   // APB 准备信号
    output wire        io_apb_PSLVERROR,// APB 错误信号

    output wire        interrupt  // 中断输出
);

    // 寄存器定义
    reg [31:0] CTRL;    // 控制寄存器
    reg [31:0] LOAD;    // 重装载寄存器
    reg [31:0] VAL;     // 当前计数器值
    reg [31:0] CALIB;   // 校准值寄存器（只读）

    // 接口定义
    wire ENABLE    = CTRL[0];  // ENABLE位
    wire TICKINT   = CTRL[1];  // TICKINT位（是否允许中断）
    wire CLKSRC    = CTRL[2];  // CLK源（忽略）
    wire COUNTFLAG = CTRL[16]; // COUNTFLAG

    assign interrupt = CTRL[16] & TICKINT;

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    assign io_apb_PSLVERROR = 1'b0;  // AHB 错误信号始终为低，表示无错误
    wire [1:0] ADDR = io_apb_PADDR[3:2];
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            CTRL  <= 32'h00000000;
            LOAD  <= 32'hFFFFFFFF;
            VAL   <= 32'hFFFFFFFF;
            CALIB <= 32'h00000000;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                // 写寄存器
                case (ADDR)
                    2'b00: CTRL <= io_apb_PWDATA;
                    2'b01: LOAD <= io_apb_PWDATA;
                    2'b10: VAL  <= io_apb_PWDATA;
                    default: ;  // 其他寄存器不处理
                endcase
            end
            // 计数逻辑
            if (ENABLE) begin
                if (VAL == 0) VAL <= LOAD;
                else begin
                    if (VAL == 1) CTRL[16] <= 1'b1;
                    VAL <= VAL - 1;
                end
            end else CTRL[16] <= 1'b0;
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) io_apb_PRDATA = 32'h00000000;
        else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
            case (ADDR)
                2'b00: io_apb_PRDATA = CTRL;
                2'b01: io_apb_PRDATA = LOAD;
                2'b10: io_apb_PRDATA = VAL;
                2'b11: io_apb_PRDATA = CALIB;
                default: io_apb_PRDATA = 32'h00000000;
            endcase
        end
    end
    
endmodule
