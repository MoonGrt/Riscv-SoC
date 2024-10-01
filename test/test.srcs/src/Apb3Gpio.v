`timescale 1ns / 1ps

module Apb3Gpio (
    input  wire [ 3:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output reg  [31:0] io_apb_PRDATA,
    output wire        io_apb_PSLVERROR,
    input  wire [31:0] io_gpio_read,
    output wire [31:0] io_gpio_write,
    output wire [31:0] io_gpio_writeEnable,
    output wire [31:0] io_value,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    wire [31:0] io_gpio_read_buffercc_io_dataOut;
    wire        ctrl_readErrorFlag;
    wire        ctrl_writeErrorFlag;
    wire        ctrl_askWrite;
    wire        ctrl_askRead;
    wire        ctrl_doWrite;
    wire        ctrl_doRead;
    reg  [31:0] io_gpio_write_driver;
    reg  [31:0] io_gpio_writeEnable_driver;

    (* keep_hierarchy = "TRUE" *) BufferCC_1 io_gpio_read_buffercc (
        .io_dataIn            (io_gpio_read[31:0]),                      //i
        .io_dataOut           (io_gpio_read_buffercc_io_dataOut[31:0]),  //o
        .io_mainClk           (io_mainClk),                              //i
        .resetCtrl_systemReset(resetCtrl_systemReset)                    //i
    );
    assign io_value = io_gpio_read_buffercc_io_dataOut;
    assign ctrl_readErrorFlag = 1'b0;
    assign ctrl_writeErrorFlag = 1'b0;
    assign io_apb_PREADY = 1'b1;
    always @(*) begin
        io_apb_PRDATA = 32'h0;
        case (io_apb_PADDR)
            4'b0000: begin
                io_apb_PRDATA[31 : 0] = io_value;
            end
            4'b0100: begin
                io_apb_PRDATA[31 : 0] = io_gpio_write_driver;
            end
            4'b1000: begin
                io_apb_PRDATA[31 : 0] = io_gpio_writeEnable_driver;
            end
            default: begin
            end
        endcase
    end

    assign ctrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
    assign ctrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (!io_apb_PWRITE));
    assign ctrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
    assign ctrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
    assign io_apb_PSLVERROR = ((ctrl_doWrite && ctrl_writeErrorFlag) || (ctrl_doRead && ctrl_readErrorFlag));
    assign io_gpio_write = io_gpio_write_driver;
    assign io_gpio_writeEnable = io_gpio_writeEnable_driver;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            io_gpio_writeEnable_driver <= 32'h0;
        end else begin
            case (io_apb_PADDR)
                4'b1000: begin
                    if (ctrl_doWrite) begin
                        io_gpio_writeEnable_driver <= io_apb_PWDATA[31 : 0];
                    end
                end
                default: begin
                end
            endcase
        end
    end

    always @(posedge io_mainClk) begin
        case (io_apb_PADDR)
            4'b0100: begin
                if (ctrl_doWrite) begin
                    io_gpio_write_driver <= io_apb_PWDATA[31 : 0];
                end
            end
            default: begin
            end
        endcase
    end

endmodule
