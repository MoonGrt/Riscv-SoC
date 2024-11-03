module AHBVI #(
    parameter USE_TPG = "false"
) (
    input clk,        // system clock
    input cmos_clk,   // cmos pixel clock
    input video_clk,  // video clock
    input rst_n,      // system reset

    inout        cmos_scl,    // cmos i2c clock
    inout        cmos_sda,    // cmos i2c data
    input        cmos_vsync,  // cmos vsync
    input        cmos_href,   // cmos hsync refrence,data valid
    input        cmos_pclk,   // cmos pxiel clock
    output       cmos_xclk,   // cmos externl clock
    input  [7:0] cmos_db,     // cmos data
    output       cmos_rst_n,  // cmos reset
    output       cmos_pwdn,   // cmos power down

    output        vin_clk,
    output        vin_vs,
    output [15:0] vin_data,
    output        vin_de
);

    wire cmos_16bit_clk, cmos_16bit_wr;
    wire [15:0] write_data;
    CAM CAM (
        .clk     (clk),
        .cmos_clk(cmos_clk),
        .rst_n   (rst_n),

        .cmos_scl  (cmos_scl),
        .cmos_sda  (cmos_sda),
        .cmos_vsync(cmos_vsync),
        .cmos_href (cmos_href),
        .cmos_pclk (cmos_pclk),
        .cmos_db   (cmos_db),
        .cmos_xclk (cmos_xclk),
        .cmos_rst_n(cmos_rst_n),
        .cmos_pwdn (cmos_pwdn),

        .write_data    (write_data),
        .cmos_16bit_wr (cmos_16bit_wr),
        .cmos_16bit_clk(cmos_16bit_clk)
    );


    // 输入测试图
    //--------------------------
    wire       tp0_vs_in;
    wire       tp0_hs_in;
    wire       tp0_de_in;
    wire [7:0] tp0_data_r;
    wire [7:0] tp0_data_g;
    wire [7:0] tp0_data_b;
    testpattern testpattern (
        // .I_pxl_clk(video_clk),  // pixel clock
        .I_pxl_clk(cmos_clk),
        .I_rst_n(rst_n),  // low active
        .I_mode(3'b000),  // data select
        .I_single_r(8'd255),
        .I_single_g(8'd255),
        .I_single_b(8'd255),  // 800x600    // 1024x768   // 1280x720   // 1920x1080
        .I_h_total(12'd1650),  // hor total time  // 12'd1056  // 12'd1344  // 12'd1650  // 12'd2200
        .I_h_sync(12'd40),  // hor sync time   // 12'd128   // 12'd136   // 12'd40    // 12'd44
        .I_h_bporch(12'd220),  // hor back porch  // 12'd88    // 12'd160   // 12'd220   // 12'd148
        .I_h_res(12'd1280),  // hor resolution  // 12'd800   // 12'd1024  // 12'd1280  // 12'd1920
        .I_v_total(12'd750),  // ver total time  // 12'd628   // 12'd806   // 12'd750   // 12'd1125
        .I_v_sync(12'd5),  // ver sync time   // 12'd4     // 12'd6     // 12'd5     // 12'd5
        .I_v_bporch(12'd20),  // ver back porch  // 12'd23    // 12'd29    // 12'd20    // 12'd36
        .I_v_res(12'd720),  // ver resolution  // 12'd600   // 12'd768   // 12'd720   // 12'd1080
        .I_hs_pol(1'b1),  // 0,负极性;1,正极性
        .I_vs_pol(1'b1),  // 0,负极性;1,正极性
        .O_de(tp0_de_in),
        .O_hs(tp0_hs_in),
        .O_vs(tp0_vs_in),
        .O_data_r(tp0_data_r),
        .O_data_g(tp0_data_g),
        .O_data_b(tp0_data_b)
    );

    generate
        if (USE_TPG == "true") begin
            // assign vin_clk  = video_clk;
            assign vin_clk  = cmos_clk;
            assign vin_vs   = tp0_vs_in;
            assign vin_data = {tp0_data_r[7:3], tp0_data_g[7:2], tp0_data_b[7:3]};
            assign vin_de   = tp0_de_in;
        end else begin  // CMOS DATA
            assign vin_clk  = cmos_16bit_clk;
            assign vin_vs   = cmos_vsync;
            assign vin_data = write_data;
            assign vin_de   = cmos_16bit_wr;
        end
    endgenerate

endmodule


// ---------------------------------------------------------------------
// File name         : testpattern.v
// Module name       : testpattern
// Created by        : Caojie
// Module Description: 
//						I_mode[2:0] = "000" : color bar     
//						I_mode[2:0] = "001" : net grid     
//						I_mode[2:0] = "010" : gray         
//						I_mode[2:0] = "011" : single color
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 24-Sep-2009 | Caojie  |    initial
// --------------------------------------------------------------------

module testpattern (
    input             I_pxl_clk,   // pixel clock
    input             I_rst_n,     // low active 
    input      [ 2:0] I_mode,      // data select
    input      [ 7:0] I_single_r,
    input      [ 7:0] I_single_g,
    input      [ 7:0] I_single_b,
    input      [11:0] I_h_total,   // hor total time 
    input      [11:0] I_h_sync,    // hor sync time
    input      [11:0] I_h_bporch,  // hor back porch
    input      [11:0] I_h_res,     // hor resolution
    input      [11:0] I_v_total,   // ver total time 
    input      [11:0] I_v_sync,    // ver sync time  
    input      [11:0] I_v_bporch,  // ver back porch  
    input      [11:0] I_v_res,     // ver resolution 
    input             I_hs_pol,    // HS polarity , 0:负极性，1：正极性
    input             I_vs_pol,    // VS polarity , 0:负极性，1：正极性
    output            O_de,
    output reg        O_hs,        // 负极性
    output reg        O_vs,        // 负极性
    output     [ 7:0] O_data_r,
    output     [ 7:0] O_data_g,
    output     [ 7:0] O_data_b
);

    //====================================================
    localparam N = 5;  // delay N clocks

    localparam WHITE = {8'd255, 8'd255, 8'd255};  // {B,G,R}
    localparam YELLOW = {8'd0, 8'd255, 8'd255};
    localparam CYAN = {8'd255, 8'd255, 8'd0};
    localparam GREEN = {8'd0, 8'd255, 8'd0};
    localparam MAGENTA = {8'd255, 8'd0, 8'd255};
    localparam RED = {8'd0, 8'd0, 8'd255};
    localparam BLUE = {8'd255, 8'd0, 8'd0};
    localparam BLACK = {8'd0, 8'd0, 8'd0};

    //====================================================
    reg  [ 11:0] V_cnt;
    reg  [ 11:0] H_cnt;

    wire         Pout_de_w;
    wire         Pout_hs_w;
    wire         Pout_vs_w;

    reg  [N-1:0] Pout_de_dn;
    reg  [N-1:0] Pout_hs_dn;
    reg  [N-1:0] Pout_vs_dn;

    //----------------------------
    wire         De_pos;
    wire         De_neg;
    wire         Vs_pos;

    reg  [ 11:0] De_vcnt;
    reg  [ 11:0] De_hcnt;
    reg  [ 11:0] De_hcnt_d1;
    reg  [ 11:0] De_hcnt_d2;

    //-------------------------
    // Color bar // 8色彩条
    reg  [ 11:0] Color_trig_num;
    reg          Color_trig;
    reg  [  3:0] Color_cnt;
    reg  [ 23:0] Color_bar;

    //----------------------------
    // Net grid // 32网格
    reg          Net_h_trig;
    reg          Net_v_trig;
    wire [  1:0] Net_pos;
    reg  [ 23:0] Net_grid;

    //----------------------------
    // Gray  // 黑白灰阶
    reg  [ 23:0] Gray;
    reg  [ 23:0] Gray_d1;

    //-----------------------------
    wire [ 23:0] Single_color;

    //-------------------------------
    wire [ 23:0] Data_sel;

    //-------------------------------
    reg  [ 23:0] Data_tmp  /*synthesis syn_keep=1*/;

    //==============================================================================
    // Generate HS, VS, DE signals
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) V_cnt <= 12'd0;
        else begin
            if ((V_cnt >= (I_v_total - 1'b1)) && (H_cnt >= (I_h_total - 1'b1))) V_cnt <= 12'd0;
            else if (H_cnt >= (I_h_total - 1'b1)) V_cnt <= V_cnt + 1'b1;
            else V_cnt <= V_cnt;
        end
    end

    //-------------------------------------------------------------    
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) H_cnt <= 12'd0;
        else if (H_cnt >= (I_h_total - 1'b1)) H_cnt <= 12'd0;
        else H_cnt <= H_cnt + 1'b1;
    end

    //-------------------------------------------------------------
    assign  Pout_de_w = ((H_cnt>=(I_h_sync+I_h_bporch))&(H_cnt<=(I_h_sync+I_h_bporch+I_h_res-1'b1)))&
                    ((V_cnt>=(I_v_sync+I_v_bporch))&(V_cnt<=(I_v_sync+I_v_bporch+I_v_res-1'b1))) ;
    assign Pout_hs_w = ~((H_cnt >= 12'd0) & (H_cnt <= (I_h_sync - 1'b1)));
    assign Pout_vs_w = ~((V_cnt >= 12'd0) & (V_cnt <= (I_v_sync - 1'b1)));

    //-------------------------------------------------------------
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) begin
            Pout_de_dn <= {N{1'b0}};
            Pout_hs_dn <= {N{1'b1}};
            Pout_vs_dn <= {N{1'b1}};
        end else begin
            Pout_de_dn <= {Pout_de_dn[N-2:0], Pout_de_w};
            Pout_hs_dn <= {Pout_hs_dn[N-2:0], Pout_hs_w};
            Pout_vs_dn <= {Pout_vs_dn[N-2:0], Pout_vs_w};
        end
    end

    assign O_de = Pout_de_dn[4];  // 注意与数据对齐

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) begin
            O_hs <= 1'b1;
            O_vs <= 1'b1;
        end else begin
            O_hs <= I_hs_pol ? ~Pout_hs_dn[3] : Pout_hs_dn[3];
            O_vs <= I_vs_pol ? ~Pout_vs_dn[3] : Pout_vs_dn[3];
        end
    end

    //=================================================================================
    // Test Pattern
    assign De_pos = !Pout_de_dn[1] & Pout_de_dn[0];  // de rising edge
    assign De_neg = Pout_de_dn[1] && !Pout_de_dn[0];  // de falling edge
    assign Vs_pos = !Pout_vs_dn[1] && Pout_vs_dn[0];  // vs rising edge

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) De_hcnt <= 12'd0;
        else if (De_pos == 1'b1) De_hcnt <= 12'd0;
        else if (Pout_de_dn[1] == 1'b1) De_hcnt <= De_hcnt + 1'b1;
        else De_hcnt <= De_hcnt;
    end

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) De_vcnt <= 12'd0;
        else if (Vs_pos == 1'b1) De_vcnt <= 12'd0;
        else if (De_neg == 1'b1) De_vcnt <= De_vcnt + 1'b1;
        else De_vcnt <= De_vcnt;
    end

    //---------------------------------------------------
    // Color bar
    //---------------------------------------------------
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Color_trig_num <= 12'd0;
        else if (Pout_de_dn[1] == 1'b0) Color_trig_num <= I_h_res[11:3];  // 8色彩条宽度
        else if ((Color_trig == 1'b1) && (Pout_de_dn[1] == 1'b1))
            Color_trig_num <= Color_trig_num + I_h_res[11:3];
        else Color_trig_num <= Color_trig_num;
    end

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Color_trig <= 1'b0;
        else if (De_hcnt == (Color_trig_num - 1'b1)) Color_trig <= 1'b1;
        else Color_trig <= 1'b0;
    end

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Color_cnt <= 3'd0;
        else if (Pout_de_dn[1] == 1'b0) Color_cnt <= 3'd0;
        else if ((Color_trig == 1'b1) && (Pout_de_dn[1] == 1'b1)) Color_cnt <= Color_cnt + 1'b1;
        else Color_cnt <= Color_cnt;
    end

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Color_bar <= 24'd0;
        else if (Pout_de_dn[2] == 1'b1)
            case (Color_cnt)
                3'd0:    Color_bar <= WHITE;
                3'd1:    Color_bar <= YELLOW;
                3'd2:    Color_bar <= CYAN;
                3'd3:    Color_bar <= GREEN;
                3'd4:    Color_bar <= MAGENTA;
                3'd5:    Color_bar <= RED;
                3'd6:    Color_bar <= BLACK;
                3'd7:    Color_bar <= BLUE;
                default: Color_bar <= BLACK;
            endcase
        else Color_bar <= BLACK;
    end

    //---------------------------------------------------
    // Net grid
    //---------------------------------------------------
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Net_h_trig <= 1'b0;
        else if (((De_hcnt[4:0] == 5'd0) || (De_hcnt == (I_h_res-1'b1))) && (Pout_de_dn[1] == 1'b1))
            Net_h_trig <= 1'b1;
        else Net_h_trig <= 1'b0;
    end

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Net_v_trig <= 1'b0;
        else if (((De_vcnt[4:0] == 5'd0) || (De_vcnt == (I_v_res-1'b1))) && (Pout_de_dn[1] == 1'b1))
            Net_v_trig <= 1'b1;
        else Net_v_trig <= 1'b0;
    end

    assign Net_pos = {Net_v_trig, Net_h_trig};

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Net_grid <= 24'd0;
        else if (Pout_de_dn[2] == 1'b1)
            case (Net_pos)
                2'b00:   Net_grid <= BLACK;
                2'b01:   Net_grid <= RED;
                2'b10:   Net_grid <= RED;
                2'b11:   Net_grid <= RED;
                default: Net_grid <= BLACK;
            endcase
        else Net_grid <= BLACK;
    end

    //---------------------------------------------------
    // Gray
    //---------------------------------------------------
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Gray <= 24'd0;
        else Gray <= {De_hcnt[7:0], De_hcnt[7:0], De_hcnt[7:0]};
    end

    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Gray_d1 <= 24'd0;
        else Gray_d1 <= Gray;
    end

    //---------------------------------------------------
    // Single color
    //---------------------------------------------------
    assign Single_color = {I_single_b, I_single_g, I_single_r};

    //============================================================
    assign Data_sel = (I_mode[2:0] == 3'b000) ? Color_bar		: 
                  (I_mode[2:0] == 3'b001) ? Net_grid 		: 
                  (I_mode[2:0] == 3'b010) ? Gray_d1    		: 
				  (I_mode[2:0] == 3'b011) ? Single_color	: BLUE;

    //---------------------------------------------------
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Data_tmp <= 24'd0;
        else Data_tmp <= Data_sel;
    end

    assign O_data_r = Data_tmp[7:0];
    assign O_data_g = Data_tmp[15:8];
    assign O_data_b = Data_tmp[23:16];

endmodule
