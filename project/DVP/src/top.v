module top #(
    parameter USE_TPG = "false"
) (
    input clk,
    input rst_n,

    // CAM interface
    inout        cmos_scl,    //cmos i2c clock
    inout        cmos_sda,    //cmos i2c data
    input        cmos_vsync,  //cmos vsync
    input        cmos_href,   //cmos hsync refrence,data valid
    input        cmos_pclk,   //cmos pxiel clock
    output       cmos_xclk,   //cmos externl clock
    input  [7:0] cmos_db,     //cmos data
    output       cmos_rst_n,  //cmos reset
    output       cmos_pwdn,   //cmos power down
    output [2:0] i2c_sel,

    // LED interface
    output [4:0] state_led,

    // DDR3 interface
    output [16-1:0] ddr_addr,     //ROW_WIDTH=16
    output [ 3-1:0] ddr_bank,     //BANK_WIDTH=3
    output          ddr_cs,
    output          ddr_ras,
    output          ddr_cas,
    output          ddr_we,
    output          ddr_ck,
    output          ddr_ck_n,
    output          ddr_cke,
    output          ddr_odt,
    output          ddr_reset_n,
    output [ 4-1:0] ddr_dm,       //DM_WIDTH=4
    inout  [32-1:0] ddr_dq,       //DQ_WIDTH=32
    inout  [ 4-1:0] ddr_dqs,      //DQS_WIDTH=4
    inout  [ 4-1:0] ddr_dqs_n,    //DQS_WIDTH=4

    // HDMI interface
    output       tmds_clk_n_0,
    output       tmds_clk_p_0,
    output [2:0] tmds_d_n_0,    //{r,g,b}
    output [2:0] tmds_d_p_0
);

    //状态指示灯
    // assign state_led[4] = ~i2c_done;
    // assign state_led[3] = ~cmos_vs_cnt[4];
    // assign state_led[2] = ~TMDS_DDR_pll_lock;
    // assign state_led[1] = ~DDR_pll_lock;
    // assign state_led[0] = ~init_calib_complete;  //DDR3初始化指示灯

    // HDMI clock generation
    wire serial_clk;
    wire hdmi4_rst_n;
    wire video_clk;  //video pixel clock
    wire memory_clk;
    wire DDR_pll_lock;
    wire TMDS_DDR_pll_lock;
    HDMI_PLL HDMI_PLL (
        .clkin  (clk),               //input clk
        .clkout0(serial_clk),        //output clk x5ni
        .clkout1(video_clk),         //output clk x1
        .lock   (TMDS_DDR_pll_lock)  //output lock
    );
    //generate the CMOS sensor clock and the SDRAM controller, I2C controller clock
    SYS_PLL SYS_PLL (
        .clkin  (clk),
        .clkout0(cmos_clk),
        .clkout1(aux_clk),
        .clkout2(memory_clk),
        .lock   (DDR_pll_lock),
        .reset  (1'b0),
        .enclk0 (1'b1),
        .enclk1 (1'b1),
        .enclk2 (pll_stop)
    );

    // 
    wire        fb_vin_clk;
    wire        fb_vin_vsync;
    wire [15:0] fb_vin_data;
    wire        fb_vin_de;
    //syn_code
    wire        out_de;
    wire        syn_off0_re;  // ofifo read enable signal
    wire        syn_off0_vs;
    wire        syn_off0_hs;
    wire        off0_syn_de;
    wire [15:0] off0_syn_data;
    AHBDI #(
        .USE_TPG(USE_TPG)
    ) AHBDI (
        .clk      (clk),
        .cmos_clk (cmos_clk),
        .video_clk(video_clk),
        .rst_n    (rst_n),

        .cmos_scl(cmos_scl),
        .cmos_sda(cmos_sda),

        .cmos_vsync(cmos_vsync),
        .cmos_href (cmos_href),
        .cmos_pclk (cmos_pclk),
        .cmos_db   (cmos_db),
        .cmos_xclk (cmos_xclk),
        .cmos_rst_n(cmos_rst_n),
        .cmos_pwdn (cmos_pwdn),

        .fb_vin_clk  (fb_vin_clk),
        .fb_vin_vsync(fb_vin_vsync),
        .fb_vin_data (fb_vin_data),
        .fb_vin_de   (fb_vin_de)
    );

    AHBDMA AHBDMA (
        .clk       (clk),
        .memory_clk(memory_clk),
        .rst_n     (rst_n),

        .fb_vin_clk  (fb_vin_clk),
        .fb_vin_vsync(fb_vin_vsync),
        .fb_vin_data (fb_vin_data),
        .fb_vin_de   (fb_vin_de),

        .pll_stop    (pll_stop),
        .DDR_pll_lock(DDR_pll_lock),
        .ddr_addr    (ddr_addr),
        .ddr_bank    (ddr_bank),
        .ddr_cs      (ddr_cs),
        .ddr_ras     (ddr_ras),
        .ddr_cas     (ddr_cas),
        .ddr_we      (ddr_we),
        .ddr_ck      (ddr_ck),
        .ddr_ck_n    (ddr_ck_n),
        .ddr_cke     (ddr_cke),
        .ddr_odt     (ddr_odt),
        .ddr_reset_n (ddr_reset_n),
        .ddr_dm      (ddr_dm),
        .ddr_dq      (ddr_dq),
        .ddr_dqs     (ddr_dqs),
        .ddr_dqs_n   (ddr_dqs_n),

        .video_clk    (video_clk),
        .syn_off0_vs  (syn_off0_vs),
        .out_de       (out_de),
        .off0_syn_de  (off0_syn_de),
        .off0_syn_data(off0_syn_data)
    );

    AHBDO AHBDO (
        .video_clk        (video_clk),
        .serial_clk       (serial_clk),
        .rst_n            (rst_n),
        .TMDS_DDR_pll_lock(TMDS_DDR_pll_lock),

        .off0_syn_data(off0_syn_data),
        .off0_syn_de  (off0_syn_de),
        .syn_off0_vs  (syn_off0_vs),
        .out_de       (out_de),

        .tmds_clk_n_0(tmds_clk_n_0),
        .tmds_clk_p_0(tmds_clk_p_0),
        .tmds_d_n_0  (tmds_d_n_0),
        .tmds_d_p_0  (tmds_d_p_0)
    );

endmodule
