module AHBDO (
    input video_clk,   //video clock
    input serial_clk,  //serial clock
    input rst_n,       //system reset
    input TMDS_DDR_pll_lock,

    //
    output        syn_off0_vs,    //hdmi reset
    output        out_de,         //hdmi de
    input  [15:0] off0_syn_data,  //hdmi data
    input         off0_syn_de,    //hdmi de

    //HDMI
    output       tmds_clk_n_0,
    output       tmds_clk_p_0,
    output [2:0] tmds_d_n_0,    //{r,g,b}
    output [2:0] tmds_d_p_0
);

    wire [4:0] lcd_r, lcd_b;
    wire [5:0] lcd_g;
    wire lcd_vs, lcd_de, lcd_hs, lcd_dclk;

    assign {lcd_r, lcd_g, lcd_b} = off0_syn_de ? off0_syn_data[15:0] : 16'h0000;  //{r,g,b}
    assign lcd_vs                = Pout_vs_dn[1];  //syn_off0_vs;
    assign lcd_hs                = Pout_hs_dn[1];  //syn_off0_hs;
    assign lcd_de                = Pout_de_dn[1];  //off0_syn_de;
    assign lcd_dclk              = video_clk;  //video_clk_phs;

    reg [1:0] Pout_hs_dn;
    reg [1:0] Pout_vs_dn;
    reg [1:0] Pout_de_dn;

    always @(posedge video_clk or negedge rst_n) begin
        if (!rst_n) begin
            Pout_hs_dn <= {2'b11};
            Pout_vs_dn <= {2'b11};
            Pout_de_dn <= {2'b00};
        end else begin
            Pout_hs_dn <= {Pout_hs_dn[0], syn_off0_hs};
            Pout_vs_dn <= {Pout_vs_dn[0], syn_off0_vs};
            Pout_de_dn <= {Pout_de_dn[0], out_de};
        end
    end

    assign hdmi4_rst_n = rst_n & TMDS_DDR_pll_lock;

    // DVI1
    wire       dvi0_rgb_clk;
    wire       dvi0_rgb_vs;
    wire       dvi0_rgb_hs;
    wire       dvi0_rgb_de;
    wire [7:0] dvi0_rgb_r;
    wire [7:0] dvi0_rgb_g;
    wire [7:0] dvi0_rgb_b;

    assign dvi0_rgb_clk = lcd_dclk;
    assign dvi0_rgb_vs  = lcd_vs;
    assign dvi0_rgb_hs  = lcd_hs;
    assign dvi0_rgb_de  = lcd_de;
    assign dvi0_rgb_r   = {lcd_r, 3'd0};
    assign dvi0_rgb_g   = {lcd_g, 2'd0};
    assign dvi0_rgb_b   = {lcd_b, 3'd0};

    //The video output timing generator and generate a frame read data request
    //输出
    // wire out_de;
    // wire [9:0] lcd_x, lcd_y;
    vga_timing #(
        .H_ACTIVE(16'd1280),
        .H_FP(16'd110),
        .H_SYNC(16'd40),
        .H_BP(16'd220),
        .V_ACTIVE(16'd720),
        .V_FP(16'd5),
        .V_SYNC(16'd5),
        .V_BP(16'd20),
        .HS_POL(1'b1),
        .VS_POL(1'b1)
    ) vga_timing_m0 (
        .clk(video_clk),
        .rst(~rst_n),
        // .active_x(lcd_x),
        // .active_y(lcd_y),
        .hs (syn_off0_hs),
        .vs (syn_off0_vs),
        .de (out_de)
    );

    DVI_TX DVI_TX_Top_inst0 (
        .I_rst_n     (hdmi4_rst_n),  //asynchronous reset, low active
        .I_serial_clk(serial_clk),

        //CMOS
        .I_rgb_clk(dvi0_rgb_clk),  //pixel clock
        .I_rgb_vs (dvi0_rgb_vs),
        .I_rgb_hs (dvi0_rgb_hs),
        .I_rgb_de (dvi0_rgb_de),
        .I_rgb_r  (dvi0_rgb_r),
        .I_rgb_g  (dvi0_rgb_g),
        .I_rgb_b  (dvi0_rgb_b),

        .O_tmds_clk_p (tmds_clk_p_0),
        .O_tmds_clk_n (tmds_clk_n_0),
        .O_tmds_data_p(tmds_d_p_0),    //{r,g,b}
        .O_tmds_data_n(tmds_d_n_0)
    );

endmodule


module vga_timing #(
    parameter H_ACTIVE = 16'd1280,  //horizontal active time (pixels)
    parameter H_FP     = 16'd110,   //horizontal front porch (pixels)
    parameter H_SYNC   = 16'd40,    //horizontal sync time(pixels)
    parameter H_BP     = 16'd220,   //horizontal back porch (pixels)
    parameter V_ACTIVE = 16'd720,   //vertical active Time (lines)
    parameter V_FP     = 16'd5,     //vertical front porch (lines)
    parameter V_SYNC   = 16'd5,     //vertical sync time (lines)
    parameter V_BP     = 16'd20,    //vertical back porch (lines)
    parameter HS_POL   = 1'b1,      //horizontal sync polarity, 1 : POSITIVE,0 : NEGATIVE;
    parameter VS_POL   = 1'b1       //vertical sync polarity, 1 : POSITIVE,0 : NEGATIVE;
) (
    input  clk,  //pixel clock
    input  rst,  //reset signal high active
    output hs,   //horizontal synchronization
    output vs,   //vertical synchronization
    output de,   //video valid

    output reg [9:0] active_x,  //video x position 
    output reg [9:0] active_y   //video y position 

);

    parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;  //horizontal total time (pixels)
    parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;  //vertical total time (lines)


    /***** FOR REFERENCE *******/

    //VIDEO_1280_720
    ///-----------------------------------------------------------------------
    /*
    parameter H_ACTIVE = 16'd1280;           //horizontal active time (pixels)
    parameter H_FP = 16'd110;                //horizontal front porch (pixels)
    parameter H_SYNC = 16'd40;               //horizontal sync time(pixels)
    parameter H_BP = 16'd220;                //horizontal back porch (pixels)
    parameter V_ACTIVE = 16'd720;            //vertical active Time (lines)
    parameter V_FP  = 16'd5;                 //vertical front porch (lines)
    parameter V_SYNC  = 16'd5;               //vertical sync time (lines)
    parameter V_BP  = 16'd20;                //vertical back porch (lines)
    parameter HS_POL = 1'b1;                 //horizontal sync polarity, 1 : POSITIVE,0 : NEGATIVE;
    parameter VS_POL = 1'b1;                 //vertical sync polarity, 1 : POSITIVE,0 : NEGATIVE;
    parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
    parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)
    */

    //VIDEO_1280_720_30_DMT
    /*//-----------------------------------------------------------------------
    parameter H_ACTIVE = 16'd1280;           //horizontal active time (pixels)
    parameter H_FP = 16'd1760;                //horizontal front porch (pixels)
    parameter H_SYNC = 16'd40;               //horizontal sync time(pixels)
    parameter H_BP = 16'd220;                //horizontal back porch (pixels)
    parameter V_ACTIVE = 16'd720;            //vertical active Time (lines)
    parameter V_FP  = 16'd5;                 //vertical front porch (lines)
    parameter V_SYNC  = 16'd5;               //vertical sync time (lines)
    parameter V_BP  = 16'd20;                //vertical back porch (lines)
    parameter HS_POL = 1'b1;                 //horizontal sync polarity, 1 : POSITIVE,0 : NEGATIVE;
    parameter VS_POL = 1'b1;                 //vertical sync polarity, 1 : POSITIVE,0 : NEGATIVE;

    parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
    parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)
    */

    /*
    //VIDEO_800x600
    ///-----------------------------------------------------------------------
    parameter H_ACTIVE = 16'd800;           //horizontal active time (pixels)
    parameter H_FP = 16'd40;                //horizontal front porch (pixels)
    parameter H_SYNC = 16'd128;               //horizontal sync time(pixels)
    parameter H_BP = 16'd88;                //horizontal back porch (pixels)
    parameter V_ACTIVE = 16'd600;            //vertical active Time (lines)
    parameter V_FP  = 16'd1;                 //vertical front porch (lines)
    parameter V_SYNC  = 16'd4;               //vertical sync time (lines)
    parameter V_BP  = 16'd23;                //vertical back porch (lines)
    parameter HS_POL = 1'b1;                 //horizontal sync polarity, 1 : POSITIVE,0 : NEGATIVE;
    parameter VS_POL = 1'b1;                 //vertical sync polarity, 1 : POSITIVE,0 : NEGATIVE;
    parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
    parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)
    */

    reg        hs_reg;  //horizontal sync register
    reg        vs_reg;  //vertical sync register
    reg [11:0] h_cnt;  //horizontal counter
    reg [11:0] v_cnt;  //vertical counter

    reg        h_active;  //horizontal video active
    reg        v_active;  //vertical video active
    assign hs = hs_reg;
    assign vs = vs_reg;
    assign de = h_active & v_active;

    //列计数
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) h_cnt <= 12'd0;
        else if (h_cnt == H_TOTAL - 1)  //horizontal counter maximum value
            h_cnt <= 12'd0;
        else h_cnt <= h_cnt + 12'd1;
    end
    //显示计数
    always @(posedge clk) begin
        if (h_cnt >= H_FP + H_SYNC + H_BP)  //horizontal video active
            active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0]);
        else active_x <= active_x;
    end
    always @(posedge clk) begin
        if (v_cnt >= V_FP + V_SYNC + V_BP)  //horizontal video active
            active_y <= v_cnt - (V_FP[11:0] + V_SYNC[11:0] + V_BP[11:0]);
        else active_y <= active_y;
    end
    //行计数
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) v_cnt <= 12'd0;
        else if (h_cnt == H_FP - 1)  //horizontal sync time
            if (v_cnt == V_TOTAL - 1)  //vertical counter maximum value
                v_cnt <= 12'd0;
            else v_cnt <= v_cnt + 12'd1;
        else v_cnt <= v_cnt;
    end
    //HS生成
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) hs_reg <= 1'b0;
        else if (h_cnt == H_FP - 1)  //horizontal sync begin
            hs_reg <= HS_POL;
        else if (h_cnt == H_FP + H_SYNC - 1)  //horizontal sync end
            hs_reg <= ~hs_reg;
        else hs_reg <= hs_reg;
    end
    //列有效
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) h_active <= 1'b0;
        else if (h_cnt == H_FP + H_SYNC + H_BP - 1)  //horizontal active begin
            h_active <= 1'b1;
        else if (h_cnt == H_TOTAL - 1)  //horizontal active end
            h_active <= 1'b0;
        else h_active <= h_active;
    end
    //VS生成
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) vs_reg <= 1'd0;
        else if ((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))  //vertical sync begin
            vs_reg <= HS_POL;
        else if ((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1))  //vertical sync end
            vs_reg <= ~vs_reg;
        else vs_reg <= vs_reg;
    end
    //行有效
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) v_active <= 1'd0;
        else if((v_cnt == V_FP + V_SYNC + V_BP - 1) && (h_cnt == H_FP - 1))//vertical active begin
            v_active <= 1'b1;
        else if ((v_cnt == V_TOTAL - 1) && (h_cnt == H_FP - 1))  //vertical active end
            v_active <= 1'b0;
        else v_active <= v_active;
    end

endmodule
