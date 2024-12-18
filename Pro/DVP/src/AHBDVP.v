module AhbDVP (
    input  wire        io_ahb_PCLK,
    input  wire        io_ahb_PRESET,
    input  wire [ 2:0] io_ahb_PADDR,
    input  wire [ 0:0] io_ahb_PSEL,
    input  wire        io_ahb_PENABLE,
    output wire        io_ahb_PREADY,
    input  wire        io_ahb_PWRITE,
    input  wire [31:0] io_ahb_PWDATA,
    output reg  [31:0] io_ahb_PRDATA,
    output wire        io_ahb_PSLVERROR
);

    // DVP寄存器定义
    reg [31:0] VI_CR;
    reg [31:0] VI_SR;
    reg [31:0] VP_CR;
    reg [31:0] VP_SR;
    reg [31:0] VP_START;
    reg [31:0] VP_END;
    reg [31:0] VP_SCALER;
    reg [31:0] VO_CR;
    reg [31:0] VO_SR;

    // DVP Config 接口定义
    // VI
    wire       VI_EN = VI_CR[0];  // VI使能
    wire [1:0] VI_MODE = VI_CR[2:1];  // VI模式 00: test模式 01: camera模式 10: hdmi模式 11: 未定义
    wire       VI_CUT = VI_CR[3];  // 图像裁剪使能
    // VP
    wire       VP_EN = VP_CR[0];  // VP使能
    wire [1:0] VP_MODE = VP_CR[2:1];  // VP模式 00: 缩放 01: 边缘检测 10: 灰度 11: 滤波
    wire [1:0] VP_FILTER = VP_CR[4:3];  // VP滤波器 00: 均值滤波 01: 中值滤波 10: 双边滤波 11: 高斯滤波
    // VO
    wire       VO_EN = VO_CR[0];  // VO使能
    wire [1:0] VO_MODE = VO_CR[2:1];  // VO模式 00: HDMI输出 01: RGB输出 10: 未定义 11: 未定义

    // AHB 写寄存器逻辑
    assign io_ahb_PREADY = 1'b1;  // AHB 准备信号始终为高，表示设备始终准备好
    assign io_ahb_PSLVERROR = 1'b0;  // AHB 错误信号始终为低，表示无错误
    always @(posedge io_ahb_PCLK or posedge io_ahb_PRESET) begin
        if (io_ahb_PRESET) begin
            VI_CR <= 32'h00000000;
            VP_CR <= 32'h00000000;
            VP_START <= 32'h00000000;
            VP_END <= 32'h00000000;
            VO_CR <= 32'h00000000;
        end else begin
            if (io_ahb_PSEL && io_ahb_PENABLE && io_ahb_PWRITE) begin
                // 写寄存器
                case (io_ahb_PADDR)  // 假设基地址为0x00，寄存器偏移4字节
                    3'd0:  VI_CR <= io_ahb_PWDATA;
                    3'd2:  VP_CR <= io_ahb_PWDATA;
                    3'd4:  VP_START <= io_ahb_PWDATA;
                    3'd5:  VP_END <= io_ahb_PWDATA;
                    3'd6:  VO_CR <= io_ahb_PWDATA;
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end
    // AHB 读寄存器逻辑
    always @(*) begin
        if (io_ahb_PRESET) io_ahb_PRDATA = 32'h00000000;
        else if (io_ahb_PSEL && io_ahb_PENABLE && ~io_ahb_PWRITE) begin
            case (io_ahb_PADDR)
                3'd0:  io_ahb_PRDATA = VI_CR;
                3'd1:  io_ahb_PRDATA = VI_SR;
                3'd2:  io_ahb_PRDATA = VP_CR;
                3'd3:  io_ahb_PRDATA = VP_SR;
                3'd4:  io_ahb_PRDATA = VP_START;
                3'd5:  io_ahb_PRDATA = VP_END;
                3'd6:  io_ahb_PRDATA = VO_CR;
                3'd7:  io_ahb_PRDATA = VO_SR;
                default: io_ahb_PRDATA = 32'h00000000;  // 默认返回0
            endcase
        end
    end



endmodule