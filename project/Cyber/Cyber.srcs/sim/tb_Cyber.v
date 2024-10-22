`timescale 1ns / 1ps

module tb_Cyber;

    // Murax Parameters
    parameter T = 10;

    reg         rst_n = 0;
    reg         clk = 0;

    wire USART1_TX = GPIOB[0];
    reg  USART1_RX = 1'b1;
    wire USART2_TX = GPIOB[2];
    reg  USART2_RX = 1'b1;

    wire [15:0] GPIOA, GPIOB;
    assign GPIOB = {12'bz, USART2_RX, 1'bz, USART1_RX, 1'bz};

    initial begin
        forever #(T / 2) clk = ~clk;
    end

    initial begin
        #(T * 2) rst_n = 1;
        // #17000 sim_uart_tx(8'b10101010);  // 调用task 模拟 UART 发送数据
    end

    Cyber Cyber (
        .io_asyncReset (~rst_n),
        .io_axiClk     (clk),
        .io_jtag_tms   (0),
        .io_jtag_tdi   (0),
        .io_jtag_tck   (0),
        .io_jtag_tdo   (),
        .GPIOA         (GPIOA),
        .GPIOB         (GPIOB)
    );

    // 模拟 UART 发送波形
    task sim_uart_tx(input [7:0] data);
        integer i;
        begin
            USART1_RX = 1'b1;  // Idle状态
            #150;
            USART1_RX = 1'b0;  // 开始位
            #150;
            // 发送数据位
            for (i = 0; i < 8; i = i + 1) begin
                USART1_RX = data[i];  // 发送数据位
                #150;
            end
            USART1_RX = 1'b1;  // 停止位
            #150;
        end
    endtask

endmodule
