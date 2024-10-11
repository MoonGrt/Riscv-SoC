`timescale 1ns / 1ps

module Apb3GPIO2 (
    input wire io_mainClk,
    input wire resetCtrl_systemReset,

    input  wire [ 3:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output wire        io_apb_PREADY,
    output reg  [31:0] io_apb_PRDATA,

    input  wire [31:0] io_gpio_read,
    output wire [31:0] io_gpio_write,
    output wire [31:0] io_gpio_Enable,
    output wire        io_apb_PSLVERROR
);

    wire [31:0] io_gpio_read_buffercc;
    wire        ctrl_readErrorFlag;
    wire        ctrl_writeErrorFlag;
    wire        ctrl_askWrite;
    wire        ctrl_askRead;
    wire        ctrl_doWrite;
    wire        ctrl_doRead;

    reg  [31:0] io_gpio_write_driver;
    reg  [31:0] io_gpio_Enable_driver;

    reg  [31:0] gpio_ctrl_reg;  // 控制寄存器（模式+速度）
    reg  [31:0] gpio_enable_reg;  // 使能寄存器

    (* keep_hierarchy = "TRUE" *) BufferCC_GPIO BufferCC_GPIO (
        .io_dataIn            (io_gpio_read[31:0]),           // i
        .io_dataOut           (io_gpio_read_buffercc[31:0]),  // o
        .io_mainClk           (io_mainClk),                   // i
        .resetCtrl_systemReset(resetCtrl_systemReset)         // i
    );

    assign ctrl_readErrorFlag = 1'b0;
    assign ctrl_writeErrorFlag = 1'b0;
    assign io_apb_PREADY = 1'b1;

    always @(*) begin
        io_apb_PRDATA = 32'h0;
        case (io_apb_PADDR)
            4'b0000: begin
                io_apb_PRDATA[31:0] = io_gpio_read_buffercc;  // 读 GPIO 输入状态
            end
            4'b0100: begin
                io_apb_PRDATA[31:0] = io_gpio_write_driver;  // 读输出寄存器
            end
            4'b1000: begin
                io_apb_PRDATA[31:0] = io_gpio_Enable_driver;  // 读使能寄存器
            end
            4'b1100: begin
                io_apb_PRDATA[31:0] = gpio_ctrl_reg;  // 读控制寄存器（模式+速度）
            end
            default: begin
            end
        endcase
    end

    assign ctrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
    assign ctrl_askRead  = ((io_apb_PSEL[0] && io_apb_PENABLE) && (!io_apb_PWRITE));
    assign ctrl_doWrite  = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
    assign ctrl_doRead   = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
    assign io_apb_PSLVERROR = ((ctrl_doWrite && ctrl_writeErrorFlag) || (ctrl_doRead && ctrl_readErrorFlag));

    assign io_gpio_write = io_gpio_write_driver;
    assign io_gpio_Enable = io_gpio_Enable_driver;

    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            io_gpio_Enable_driver <= 32'h0;
            gpio_ctrl_reg <= 32'h0;  // 初始化为输入模式，低速
            gpio_enable_reg <= 32'h0;  // 初始化为禁用
        end else begin
            case (io_apb_PADDR)
                4'b1000: begin
                    if (ctrl_doWrite) begin
                        io_gpio_Enable_driver <= io_apb_PWDATA[31:0];  // 写使能寄存器
                    end
                end
                4'b0100: begin
                    if (ctrl_doWrite) begin
                        io_gpio_write_driver <= io_apb_PWDATA[31 : 0];  // 写输出寄存器
                    end
                end
                4'b1100: begin
                    if (ctrl_doWrite) begin
                        gpio_ctrl_reg <= io_apb_PWDATA[31:0];  // 写控制寄存器
                    end
                end
                default: begin
                end
            endcase
        end
    end

endmodule
