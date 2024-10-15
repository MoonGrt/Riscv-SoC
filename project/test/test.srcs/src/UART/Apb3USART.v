`timescale 1ns / 1ps

module Apb3USART (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 2:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    input  wire USART_RX,  // UART 接收数据输入
    output wire USART_TX,  // UART 发送数据输出
    output wire interrupt  // 中断输出
);

    // USART 寄存器定义
    wire [15:0] SR;  // 状态寄存器
    reg  [15:0] DR;  // 数据寄存器
    reg  [15:0] BRR;  // 波特率寄存器
    reg  [15:0] CR1;  // 控制寄存器1
    reg  [15:0] CR2;  // 控制寄存器2
    reg  [15:0] CR3;  // 控制寄存器3  暂时不支持流控制和其他高级功能
    reg  [15:0] GTPR;  // 保护时间和预分频寄存器  暂时不支持

    // USART StreamFifo 接口定义
    wire       io_push_ready_TX;
    reg        io_push_valid_TX;
    reg  [7:0] io_push_payload_TX;
    wire       io_pop_ready_TX;
    wire       io_pop_valid_TX;
    wire [7:0] io_pop_payload_TX;
    wire [4:0] io_availability_TX;
    wire [4:0] io_occupancy_TX;
    wire       io_push_ready_RX;
    wire       io_push_valid_RX;
    wire [7:0] io_push_payload_RX;
    reg        io_pop_ready_RX;
    wire       io_pop_valid_RX;
    wire [7:0] io_pop_payload_RX;
    wire [4:0] io_availability_RX;
    wire [4:0] io_occupancy_RX;

    // USART 中断输出
    assign interrupt = (PEIE & PE) | (TCIE & TC) | (RXNEIE & RXNE) | (TXEIE & TXE) | (IDLEIE & IDLE);

    // USART Config 接口定义
    // SR
    wire        PE   = 1'bz;
    wire        IDLE = 1'bz;
    wire        RXNE = io_occupancy_RX ? 1'b1 : 1'b0;
    wire        TC   = 1'bz;
    wire        TXE  = 1'bz;
    assign      SR   = {8'b0, TXE, TC, RXNE, IDLE, 3'b0, PE};
    // CR1
    wire        RE     = CR1[2];
    wire        TE     = CR1[3];
    wire        IDLEIE = CR1[4];
    wire        RXNEIE = CR1[5];
    wire        TCIE   = CR1[6];
    wire        TXEIE  = CR1[7];
    wire        PEIE   = CR1[8];
    wire        PS     = CR1[9];
    wire        PCE    = CR1[10];
    wire [ 2:0] M      = CR1[12] ? 3'b000 : 3'b111;
    wire        UE     = CR1[13];
    // CR2
    wire [ 1:0] STOP = CR2[13:12];
    // CR3
    wire        DMAT = CR3[7];
    wire        DMAR = CR3[6];
    // BRR
    wire [11:0] DIV_Mantissa = BRR[15:4];
    wire [ 3:0] DIV_Fraction = BRR[ 3:0];

    // USART 状态寄存器
    wire        io_readError;
    wire        io_writeBreak = 1'b0;
    wire        io_readBreak;

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            // SR   <= 16'h0000;
            DR   <= 16'h0000;
            BRR  <= 16'h0000;
            CR1  <= 16'h0000;
            CR2  <= 16'h0000;
            CR3  <= 16'h0000;
            GTPR <= 16'h0000;
        end else begin
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    // 3'b000:  SR <= io_apb_PWDATA[15:0];  // 写 SR  // 暂时不可写入
                    3'b001:  DR <= io_apb_PWDATA[15:0];  // 写 DR
                    3'b010:  BRR <= io_apb_PWDATA[15:0];  // 写 BRR
                    3'b011:  CR1 <= io_apb_PWDATA[15:0];  // 写 CR1
                    3'b100:  CR2 <= io_apb_PWDATA[15:0];  // 写 CR2
                    3'b101:  CR3 <= io_apb_PWDATA[15:0];  // 写 CR3
                    3'b110:  GTPR <= io_apb_PWDATA[15:0];  // 写 GTPR
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) begin
            io_apb_PRDATA = 32'h00000000;  // 复位时返回0
            io_pop_ready_RX = 1'b0;
        end
        else begin
            io_pop_ready_RX = 1'b0;
            if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    3'b000:  io_apb_PRDATA = {16'b0, SR};  // 读 SR
                    3'b001:  begin 
                        io_apb_PRDATA = io_pop_valid_RX ? {16'b0, io_pop_payload_RX} : 32'h00000000;  // 读
                        io_pop_ready_RX = 1'b1;
                    end
                    3'b010:  io_apb_PRDATA = {16'b0, BRR};  // 读 BRR
                    3'b011:  io_apb_PRDATA = {16'b0, CR1};  // 读 CR1
                    3'b100:  io_apb_PRDATA = {16'b0, CR2};  // 读 CR2
                    3'b101:  io_apb_PRDATA = {16'b0, CR3};  // 读 CR3
                    3'b110:  io_apb_PRDATA = {16'b0, GTPR};  // 读 GTPR
                    default: io_apb_PRDATA = 32'h00000000;  // 默认返回0
                endcase
            end
        end
    end


    // StreamFifo 接口
    reg TXFifo_push = 1'b0;
    always @(posedge io_apb_PCLK)
        TXFifo_push <= io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE && io_apb_PADDR == 3'b001;
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            io_push_valid_TX   <= 1'b0;
            io_push_payload_TX <= 8'h00;
        end else begin
            io_push_valid_TX   <= 1'b0;
            io_push_payload_TX <= 8'h00;
            if (TXFifo_push) begin
                io_push_valid_TX   <= 1'b1;
                io_push_payload_TX <= DR[7:0];
            end
        end
    end

    // 串口收发逻辑
    StreamFifo_UART StreamFifo_UART_TX (
        .io_push_ready        (io_push_ready_TX),           // o
        .io_push_valid        (io_push_valid_TX),           // i
        .io_push_payload      (io_push_payload_TX),         // i
        .io_pop_ready         (io_pop_ready_TX),            // i
        .io_pop_valid         (io_pop_valid_TX),            // o
        .io_pop_payload       (io_pop_payload_TX),          // o
        .io_flush             (1'b0),                       // i
        .io_occupancy         (io_occupancy_TX),            // o
        .io_availability      (io_availability_TX),         // o
        .io_mainClk           (io_apb_PCLK),                // i
        .resetCtrl_systemReset(io_apb_PRESET | ~(RE & UE))  // i
    );
    UartCtrl UartCtrl (
        .io_config_frame_dataLength(M),                     // i
        .io_config_frame_stop      (STOP[1]),               // i
        .io_config_frame_parity    ({PS, PCE}),             // i
        .io_config_clockDivider    ({8'b0, DIV_Mantissa}),  // i
        .io_write_ready            (io_pop_ready_TX),       // o
        .io_write_valid            (io_pop_valid_TX),       // i
        .io_write_payload          (io_pop_payload_TX),     // i
        .io_read_ready             (io_push_ready_RX),      // i
        .io_read_valid             (io_push_valid_RX),      // o
        .io_read_payload           (io_push_payload_RX),    // o
        .io_uart_txd               (USART_TX),              // o
        .io_uart_rxd               (USART_RX),              // i
        .io_readError              (io_readError),          // o
        .io_writeBreak             (io_writeBreak),         // i
        .io_readBreak              (io_readBreak),          // o
        .io_uart_rxen              (RE & UE),               // i
        .io_uart_txen              (TE & UE),               // i
        .io_mainClk                (io_apb_PCLK),           // i
        .resetCtrl_systemReset     (io_apb_PRESET)          // i
    );
    StreamFifo_UART StreamFifo_UART_RX (
        .io_push_ready        (io_push_ready_RX),           // o
        .io_push_valid        (io_push_valid_RX),           // i
        .io_push_payload      (io_push_payload_RX),         // i
        .io_pop_ready         (io_pop_ready_RX),            // i
        .io_pop_valid         (io_pop_valid_RX),            // o
        .io_pop_payload       (io_pop_payload_RX),          // o
        .io_flush             (1'b0),                       // i
        .io_occupancy         (io_occupancy_RX),            // o
        .io_availability      (io_availability_RX),         // o
        .io_mainClk           (io_apb_PCLK),                // i
        .resetCtrl_systemReset(io_apb_PRESET | ~(RE & UE))  // i
    );

endmodule
