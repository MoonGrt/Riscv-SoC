module top #(
    parameter USE_TPG = "false",
    parameter H_DISP  = 12'd1280,
    parameter V_DISP  = 12'd720
) (
    input clk,
    input rst_n,
    

    // CAM interface
    input        cmos_scl,    // cmos i2c clock
    inout        cmos_sda,    // cmos i2c data
    input        cmos_vsync,  // cmos vsync
    input        cmos_href,   // cmos hsync refrence,data valid
    input        cmos_pclk,   // cmos pxiel clock
    output       cmos_xclk,   // cmos externl clock
    input  [7:0] cmos_db,     // cmos data
    output       cmos_rst_n,  // cmos reset
    output       cmos_pwdn,   // cmos power down
    output [2:0] i2c_sel,

    // DDR3 interface
    output [16-1:0] ddr_addr,     // ROW_WIDTH=16
    output [ 3-1:0] ddr_bank,     // BANK_WIDTH=3
    output          ddr_cs,
    output          ddr_ras,
    output          ddr_cas,
    output          ddr_we,
    output          ddr_ck,
    output          ddr_ck_n,
    output          ddr_cke,
    output          ddr_odt,
    output          ddr_reset_n,
    output [ 4-1:0] ddr_dm,       // DM_WIDTH=4
    inout  [32-1:0] ddr_dq,       // DQ_WIDTH=32
    inout  [ 4-1:0] ddr_dqs,      // DQS_WIDTH=4
    inout  [ 4-1:0] ddr_dqs_n,    // DQS_WIDTH=4

    // HDMI interface
    output       tmds_clk_n_0,
    output       tmds_clk_p_0,
    output [2:0] tmds_d_n_0,    // {r,g,b}
    output [2:0] tmds_d_p_0,

    input       tmds_clk_n_1,
    input       tmds_clk_p_1,
    input [2:0] tmds_d_n_1,    // {r,g,b}
    input [2:0] tmds_d_p_1
);

    assign i2c_sel = 3'b100;


    reg  [31:0] VP_CR = {2'b00, 30'b0};
    reg  [31:0] VP_SR = 32'h00000000;
    reg  [31:0] VP_START = 32'h00000000;
    reg  [31:0] VP_END = 32'h00000000;
    reg  [31:0] VP_SCALER = 32'h00000000;

    // 状态指示灯
    // assign state_led[4] = ~i2c_done;
    // assign state_led[3] = ~cmos_vs_cnt[4];
    // assign state_led[2] = ~TMDS_DDR_pll_lock;
    // assign state_led[1] = ~DDR_pll_lock;
    // assign state_led[0] = ~init_calib_complete;  // DDR3初始化指示灯

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

    // HDMI clock generation
    wire        serial_clk;
    wire        video_clk;  // video pixel clock
    wire        memory_clk;
    wire        clk_vp;
    wire        DDR_pll_lock;
    wire        TMDS_DDR_pll_lock;
    wire        clk_10m;
    HDMI_PLL HDMI_PLL (
        .clkin  (clk),               // input clk
        .clkout0(serial_clk),        // output clk x5
        .clkout1(video_clk),         // output clk x1
        .lock   (TMDS_DDR_pll_lock)  // output lock
    );
    // generate the CMOS sensor clock and the SDRAM controller, I2C controller clock
    SYS_PLL SYS_PLL (
        .clkin  (clk),
        .clkout0(cmos_clk),
        .clkout1(clk_vp),
        .clkout2(memory_clk),
        .clkout3(clk_10m),
        .lock   (DDR_pll_lock),
        .reset  (1'b0),
        .enclk0 (1'b1),
        .enclk1 (1'b1),
        .enclk2 (pll_stop),
        .enclk3 (1'b1)
    );


    //===========================================================================
    EDID_PROM_Top EDID_PROM_Top (
        .I_clk  (clk),    //>= 5MHz, <=200MHz 
        .I_rst_n(rst_n),
        .I_scl  (cmos_scl),
        .IO_sda (cmos_sda)
    );
    wire HDMI_clk, HDMI_vs, HDMI_hs, HDMI_de;
    wire [7:0] HDMI_r, HDMI_g, HDMI_b;
    DVI_RX DVI_RX (
        .I_rst_n         (rst_n),             //input I_rst_n
        .I_tmds_clk_p    (tmds_clk_p_1),      //input I_tmds_clk_p
        .I_tmds_clk_n    (tmds_clk_n_1),      //input I_tmds_clk_n
        .I_tmds_data_p   (tmds_d_p_1),        //input [2:0] I_tmds_data_p
        .I_tmds_data_n   (tmds_d_n_1),        //input [2:0] I_tmds_data_n
        .O_pll_phase     (O_pll_phase),       //output [3:0] O_pll_phase
        .O_pll_phase_lock(O_pll_phase_lock),  //output O_pll_phase_lock
        .O_rgb_clk       (HDMI_clk),          // output O_rgb_clk
        .O_rgb_vs        (HDMI_vs),           // output O_rgb_vs
        .O_rgb_hs        (HDMI_hs),           // output O_rgb_hs
        .O_rgb_de        (HDMI_de),           // output O_rgb_de
        .O_rgb_r         (HDMI_r),            // output [7:0] O_rgb_r
        .O_rgb_g         (HDMI_g),            // output [7:0] O_rgb_g
        .O_rgb_b         (HDMI_b)             // output [7:0] O_rgb_b
    );

    // 视频输入模块
    AHBVI #(
        .USE_TPG(USE_TPG)
    ) AHBVI (
        .clk       (clk),
        .clk_10m   (clk_10m),
        .cmos_clk  (cmos_clk),
        .video_clk (video_clk),
        .serial_clk(serial_clk),
        .rst_n     (rst_n),

//        .i2c_sel (i2c_sel),
        // .cmos_scl(cmos_scl),
        // .cmos_sda(cmos_sda),

        .cmos_vsync(cmos_vsync),
        .cmos_href (cmos_href),
        .cmos_pclk (cmos_pclk),
        .cmos_db   (cmos_db),
        .cmos_xclk (cmos_xclk),
        .cmos_rst_n(cmos_rst_n),
        .cmos_pwdn (cmos_pwdn),
        // HDMI interface
        // .tmds_clk_n_1(tmds_clk_n_1),
        // .tmds_clk_p_1(tmds_clk_p_1),
        // .tmds_d_n_1  (tmds_d_n_1),
        // .tmds_d_p_1  (tmds_d_p_1),

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

        .VP_CR    (VP_CR),
        .VP_START (VP_START),
        .VP_END   (VP_END),
        .VP_SCALER(VP_SCALER),

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
        if (USE_TPG == "true") begin
        end else begin
            // 视频存储模块
            AHBDMA AHBDMA (
                .clk         (clk),
                .memory_clk  (memory_clk),
                .rst_n       (rst_n),
                .DDR_pll_lock(DDR_pll_lock),
                .pll_stop    (pll_stop),

                .vi_clk (HDMI_clk),
                .vi_vs  (HDMI_vs),
                .vi_de  (HDMI_de),
                .vi_data({HDMI_r[7:3], HDMI_g[7:2], HDMI_b[7:3]}),
                // .vi_clk (vp_clk),
                // .vi_vs  (vp_vs),
                // .vi_de  (vp_de),
                // .vi_data(vp_data),

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
                .vo_vs     (vo_vs),
                .vo_de     (vo_de),
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
