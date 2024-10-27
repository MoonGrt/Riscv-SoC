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
    reg [31:0] VI_START;
    reg [31:0] VI_END;
    reg [31:0] VI_SR;
    reg [31:0] VP_CR;
    reg [31:0] VP_SR;
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
    wire [1:0] VO_MODE = VO_CR[2:1];  // VO模式 00: 输出模式 01: 输入模式 10: 未定义 11: 未定义

    // AHB 写寄存器逻辑
    assign io_ahb_PREADY = 1'b1;  // AHB 准备信号始终为高，表示设备始终准备好
    assign io_ahb_PSLVERROR = 1'b0;  // AHB 错误信号始终为低，表示无错误
    always @(posedge io_ahb_PCLK or posedge io_ahb_PRESET) begin
        if (io_ahb_PRESET) begin
            VI_CR <= 32'h00000000;
            VI_START <= 32'h00000000;
            VI_END <= 32'h00000000;
            VP_CR <= 32'h00000000;
            VO_CR <= 32'h00000000;
        end else begin
            if (io_ahb_PSEL && io_ahb_PENABLE && io_ahb_PWRITE) begin
                // 写寄存器
                case (io_ahb_PADDR)  // 假设基地址为0x00，寄存器偏移4字节
                    3'd0:  VI_CR <= io_ahb_PWDATA;
                    3'd1:  VI_START <= io_ahb_PWDATA;
                    3'd2:  VI_END <= io_ahb_PWDATA;
                    3'd4:  VP_CR <= io_ahb_PWDATA;
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
                3'd1:  io_ahb_PRDATA = VI_START;
                3'd2:  io_ahb_PRDATA = VI_END;
                3'd3:  io_ahb_PRDATA = VI_SR;
                3'd4:  io_ahb_PRDATA = VP_CR;
                3'd5:  io_ahb_PRDATA = VP_SR;
                3'd6:  io_ahb_PRDATA = VO_CR;
                3'd7:  io_ahb_PRDATA = VO_SR;
                default: io_ahb_PRDATA = 32'h00000000;  // 默认返回0
            endcase
        end
    end











endmodule

/*
    I_mode[2:0] = "000" : color bar
    I_mode[2:0] = "001" : net grid
    I_mode[2:0] = "010" : gray
    I_mode[2:0] = "011" : single color
*/
module test (
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
    // Color bar //8色彩条
    reg  [ 11:0] Color_trig_num;
    reg          Color_trig;
    reg  [  3:0] Color_cnt;
    reg  [ 23:0] Color_bar;

    //----------------------------
    // Net grid //32网格
    reg          Net_h_trig;
    reg          Net_v_trig;
    wire [  1:0] Net_pos;
    reg  [ 23:0] Net_grid;

    //----------------------------
    // Gray  //黑白灰阶
    reg  [ 23:0] Gray;
    reg  [ 23:0] Gray_d1;

    //-----------------------------
    wire [ 23:0] Single_color;

    //-------------------------------
    wire [ 23:0] Data_sel;

    //-------------------------------
    reg  [ 23:0] Data_tmp  /* synthesis syn_keep=1 */;

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
    assign De_neg = Pout_de_dn[1] & !Pout_de_dn[0];  // de falling edge
    assign Vs_pos = !Pout_vs_dn[1] & Pout_vs_dn[0];  // vs rising edge

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
        else if (Pout_de_dn[1] == 1'b0) Color_trig_num <= I_h_res[11:3];  //8色彩条宽度
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
    assign Data_sel = (I_mode[2:0] == 3'b000) ? Color_bar :
                  (I_mode[2:0] == 3'b001) ? Net_grid :
                  (I_mode[2:0] == 3'b010) ? Gray_d1 :
                  (I_mode[2:0] == 3'b011) ? Single_color : BLUE;

    //---------------------------------------------------
    always @(posedge I_pxl_clk or negedge I_rst_n) begin
        if (!I_rst_n) Data_tmp <= 24'd0;
        else Data_tmp <= Data_sel;
    end

    assign O_data_r = Data_tmp[7:0];
    assign O_data_g = Data_tmp[15:8];
    assign O_data_b = Data_tmp[23:16];

endmodule
