module Apb3USART (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [15:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [15:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [15:0] io_apb_PRDATA,   // 读数据总线

    input  wire RX,  // UART 接收数据输入
    output reg  TX   // UART 发送数据输出
);

    // USART 寄存器定义
    reg [15:0] SR;  // 状态寄存器
    reg [15:0] DR;  // 数据寄存器
    reg [15:0] BRR;  // 波特率寄存器
    reg [15:0] CR1;  // 控制寄存器1
    reg [15:0] CR2;  // 控制寄存器2
    reg [15:0] CR3;  // 控制寄存器3
    reg [15:0] GTPR;  // 集团寄存器

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            SR   <= 16'h0000;
            DR   <= 16'h0000;
            BRR  <= 16'h0000;
            CR1  <= 16'h0000;
            CR2  <= 16'h0000;
            CR3  <= 16'h0000;
            GTPR <= 16'h0000;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR[15:0])
                    16'h0000: SR <= io_apb_PWDATA;  // 写状态寄存器
                    16'h0004: DR <= io_apb_PWDATA;  // 写数据寄存器
                    16'h0008: BRR <= io_apb_PWDATA;  // 写波特率寄存器
                    16'h000C: CR1 <= io_apb_PWDATA;  // 写控制寄存器1
                    16'h0010: CR2 <= io_apb_PWDATA;  // 写控制寄存器2
                    16'h0014: CR3 <= io_apb_PWDATA;  // 写控制寄存器3
                    16'h0018: GTPR <= io_apb_PWDATA;  // 写集团寄存器
                    default:  ;  // 其他寄存器不处理
                endcase
            end
        end
    end

    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) io_apb_PRDATA = 16'h0000;
        else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
            case (io_apb_PADDR[15:0])
                16'h0000: io_apb_PRDATA <= SR;  // 读状态寄存器
                16'h0004: io_apb_PRDATA <= DR;  // 读数据寄存器
                16'h0008: io_apb_PRDATA <= BRR;  // 读波特率寄存器
                16'h000C: io_apb_PRDATA <= CR1;  // 读控制寄存器1
                16'h0010: io_apb_PRDATA <= CR2;  // 读控制寄存器2
                16'h0014: io_apb_PRDATA <= CR3;  // 读控制寄存器3
                16'h0018: io_apb_PRDATA <= GTPR;  // 读集团寄存器
                default:  io_apb_PRDATA <= 16'h0000;
            endcase
        end
    end

    // 可以添加发送和接收逻辑的子模块实例化
    wire tx_ready;  // 发送准备信号
    wire rx_ready;  // 接收准备信号

    // // 发送模块实例
    // Tx_Module tx_inst (
    //     .clk  (io_apb_PCLK),
    //     .reset(io_apb_PRESET),
    //     .start(CR1[0]),         // 控制信号
    //     .data (DR),             // 要发送的数据
    //     .TX   (TX),             // 发送输出
    //     .ready(tx_ready)        // 发送准备信号
    // );

    // // 接收模块实例
    // Rx_Module rx_inst (
    //     .clk  (io_apb_PCLK),
    //     .reset(io_apb_PRESET),
    //     .RX   (RX),             // 接收输入
    //     .data (DR),             // 接收的数据
    //     .ready(rx_ready)        // 接收准备信号
    // );

endmodule
