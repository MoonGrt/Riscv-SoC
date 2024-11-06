module AhbDVP #(
    parameter USE_TPG = "false",
    parameter H_DISP = 12'd1280,
    parameter V_DISP = 12'd720
) (
    // AHB interface
    input  wire        io_ahb_PCLK,
    input  wire        io_ahb_PRESET,
    input  wire [ 2:0] io_ahb_PADDR,
    input  wire [ 0:0] io_ahb_PSEL,
    input  wire        io_ahb_PENABLE,
    output wire        io_ahb_PREADY,
    input  wire        io_ahb_PWRITE,
    input  wire [31:0] io_ahb_PWDATA,
    output reg  [31:0] io_ahb_PRDATA,
    output wire        io_ahb_PSLVERROR,

    // Clock
    output wire pll_stop,
    input  wire cmos_clk,
    input  wire serial_clk,
    input  wire video_clk,
    input  wire memory_clk,
    input  wire clk_vp,
    input  wire DDR_pll_lock,
    input  wire TMDS_DDR_pll_lock,

    // CAM interface
    output [2:0] i2c_sel,
    inout        cmos_scl,    // cmos i2c clock
    inout        cmos_sda,    // cmos i2c data
    input        cmos_vsync,  // cmos vsync
    input        cmos_href,   // cmos hsync refrence,data valid
    input        cmos_pclk,   // cmos pxiel clock
    output       cmos_xclk,   // cmos externl clock
    input  [7:0] cmos_db,     // cmos data
    output       cmos_rst_n,  // cmos reset
    output       cmos_pwdn,   // cmos power down

    // DDR3 interface
    output [16-1:0] ddr_addr,  // ROW_WIDTH=16
    output [ 3-1:0] ddr_bank,  // BANK_WIDTH=3
    output          ddr_cs,
    output          ddr_ras,
    output          ddr_cas,
    output          ddr_we,
    output          ddr_ck,
    output          ddr_ck_n,
    output          ddr_cke,
    output          ddr_odt,
    output          ddr_reset_n,
    output [ 4-1:0] ddr_dm,     // DM_WIDTH=4
    inout  [32-1:0] ddr_dq,     // DQ_WIDTH=32
    inout  [ 4-1:0] ddr_dqs,    // DQS_WIDTH=4
    inout  [ 4-1:0] ddr_dqs_n,  // DQS_WIDTH=4

    // HDMI interface
    output       tmds_clk_n_0,
    output       tmds_clk_p_0,
    output [2:0] tmds_d_n_0,  // {r,g,b}
    output [2:0] tmds_d_p_0
);

    // DVP寄存器定义
    reg [31:0] VI_CR = {29'h0, 2'b10, 1'b1};  // VI 默认使能，camera模式
    reg [31:0] VI_SR;
    reg [31:0] VP_CR = {21'h0, 1'b1, 1'b1, 1'b1, 1'b1, 2'b01, 1'b1, 1'b1, 2'b01, 1'b1};  // VP 默认使能
    reg [31:0] VP_SR;
    reg [31:0] VP_START = {16'd0, 16'd0};
    reg [31:0] VP_END = {16'd720, 16'd1280};
    reg [31:0] VP_SCALER = {16'd720, 16'd1280};
    reg [31:0] VP_THRESHOLD = {16'h0, 8'h80, 8'h40};
    reg [31:0] VO_CR = {29'h0, 2'b01, 1'b1};  // VI 默认使能，HDMI模式
    reg [31:0] VO_SR;

    // DVP Config 接口定义
    // VI
    wire       VI_EN = VI_CR[0];  // VI使能
    wire [1:0] VI_MODE = VI_CR[2:1];  // VI模式 00: test模式 01: camera模式 10: hdmi模式 11: 未定义
    // VP
    wire       VP_EN = VP_CR[0];  // VP使能
    // VO
    wire       VO_EN = VO_CR[0];  // VO使能
    wire [1:0] VO_MODE = VO_CR[2:1];  // VO模式 00: HDMI输出 01: RGB输出 10: 未定义 11: 未定义

    // AHB 写寄存器逻辑
    assign io_ahb_PREADY = 1'b1;  // AHB 准备信号始终为高，表示设备始终准备好
    assign io_ahb_PSLVERROR = 1'b0;  // AHB 错误信号始终为低，表示无错误
    always @(posedge io_ahb_PCLK or posedge io_ahb_PRESET) begin
        if (io_ahb_PRESET) begin
            VI_CR <= {29'h0, 2'b10, 1'b1};  // VI 默认使能，camera模式
            VP_CR <= {21'h0, 1'b1, 1'b1, 1'b1, 1'b1, 2'b01, 1'b1, 1'b1, 2'b01, 1'b1};  // VP 默认使能
            VP_START <= {16'd0, 16'd0};
            VP_END <= {16'd720, 16'd1280};
            VP_SCALER <= {16'd720, 16'd1280};
            VP_THRESHOLD <= {16'h0, 8'h80, 8'h40};
            VO_CR <= {29'h0, 2'b01, 1'b1};  // VI 默认使能，HDMI模式
        end else begin
            if (io_ahb_PSEL && io_ahb_PENABLE && io_ahb_PWRITE) begin
                // 写寄存器
                case (io_ahb_PADDR)  // 假设基地址为0x00，寄存器偏移4字节
                    4'd0:  VI_CR <= io_ahb_PWDATA;
                    4'd2:  VP_CR <= io_ahb_PWDATA;
                    4'd4:  VP_START <= io_ahb_PWDATA;
                    4'd5:  VP_END <= io_ahb_PWDATA;
                    4'd6:  VP_SCALER <= io_ahb_PWDATA;
                    4'd7:  VP_THRESHOLD <= io_ahb_PWDATA;
                    4'd8:  VO_CR <= io_ahb_PWDATA;
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
                4'd0: io_ahb_PRDATA = VI_CR;
                4'd1: io_ahb_PRDATA = VI_SR;
                4'd2: io_ahb_PRDATA = VP_CR;
                4'd3: io_ahb_PRDATA = VP_SR;
                4'd4: io_ahb_PRDATA = VP_START;
                4'd5: io_ahb_PRDATA = VP_END;
                4'd6: io_ahb_PRDATA = VP_SCALER;
                4'd7: io_ahb_PRDATA = VP_THRESHOLD;
                4'd8: io_ahb_PRDATA = VO_CR;
                4'd9: io_ahb_PRDATA = VO_SR;
                default: io_ahb_PRDATA = 32'h00000000;  // 默认返回0
            endcase
        end
    end


    wire clk = io_ahb_PCLK;
    wire rst_n = ~io_ahb_PRESET;

    // video interface
    wire        vi_clk;
    wire        vi_vs;
    wire [15:0] vi_data;
    wire        vi_de;

    wire        vp_clk;
    wire        vp_vs;
    wire        vp_de;
    wire [15:0] vp_data;

    wire        vo_de;
    wire        vo_vs;
    wire        video_de;
    wire [15:0] video_data;

    // 视频输入模块
    AHBVI BVI (
        .clk      (clk),
        .cmos_clk (cmos_clk),
        .video_clk(video_clk),
        .rst_n    (rst_n),
        .mode     (VI_MODE),

        .i2c_sel (i2c_sel),
        .cmos_scl(cmos_scl),
        .cmos_sda(cmos_sda),
        .cmos_vsync(cmos_vsync),
        .cmos_href (cmos_href),
        .cmos_pclk (cmos_pclk),
        .cmos_db   (cmos_db),
        .cmos_xclk (cmos_xclk),
        .cmos_rst_n(cmos_rst_n),
        .cmos_pwdn (cmos_pwdn),

        .vi_clk (vi_clk),
        .vi_vs  (vi_vs),
        .vi_data(vi_data),
        .vi_de  (vi_de)
    );

    // 视频处理模块
    AHBVP #(
        .H_DISP(H_DISP),
        .V_DISP(V_DISP)
    ) AHBVP (
        .clk_vp(clk_vp),
        .rst_n (rst_n),

        .VP_CR       (VP_CR),
        .VP_START    (VP_START),
        .VP_END      (VP_END),
        .VP_SCALER   (VP_SCALER),
        .VP_THRESHOLD(VP_THRESHOLD),

        .vi_clk (vi_clk),
        .vi_vs  (vi_vs),
        .vi_de  (vi_de),
        .vi_data(vi_data),

        .vp_clk (vp_clk),
        .vp_vs  (vp_vs),
        .vp_de  (vp_de),
        .vp_data(vp_data)
    );

generate
if (USE_TPG == "true")begin
end else begin
    // 视频存储模块
    AHBDMA AHBDMA (
        .clk         (clk),
        .memory_clk  (memory_clk),
        .rst_n       (rst_n),
        .DDR_pll_lock(DDR_pll_lock),
        .pll_stop    (pll_stop),

        // .vi_clk (vi_clk),
        // .vi_vs  (vi_vs),
        // .vi_de  (vi_de),
        // .vi_data(vi_data),
        .vi_clk (vp_clk),
        .vi_vs  (vp_vs),
        .vi_de  (vp_de),
        .vi_data(vp_data),

        .ddr_addr   (ddr_addr),
        .ddr_bank   (ddr_bank),
        .ddr_cs     (ddr_cs),
        .ddr_ras    (ddr_ras),
        .ddr_cas    (ddr_cas),
        .ddr_we     (ddr_we),
        .ddr_ck     (ddr_ck),
        .ddr_ck_n   (ddr_ck_n),
        .ddr_cke    (ddr_cke),
        .ddr_odt    (ddr_odt),
        .ddr_reset_n(ddr_reset_n),
        .ddr_dm     (ddr_dm),
        .ddr_dq     (ddr_dq),
        .ddr_dqs    (ddr_dqs),
        .ddr_dqs_n  (ddr_dqs_n),

        .video_clk (video_clk),
        .vo_vs     (vo_vs),
        .vo_de     (vo_de),
        .video_de  (video_de),
        .video_data(video_data)
    );

    // 视频输出模块
    AHBVO AHBVO (
        .video_clk        (video_clk),
        .serial_clk       (serial_clk),
        .rst_n            (rst_n),
        .TMDS_DDR_pll_lock(TMDS_DDR_pll_lock),

        // 向 ddr 请求数据
        .vo_vs   (vo_vs),
        .vo_de   (vo_de),
        // ddr 输出数据
        .video_data(video_data),
        .video_de  (video_de),

        .tmds_clk_n_0(tmds_clk_n_0),
        .tmds_clk_p_0(tmds_clk_p_0),
        .tmds_d_n_0  (tmds_d_n_0),
        .tmds_d_p_0  (tmds_d_p_0)
    );
end
endgenerate

endmodule
