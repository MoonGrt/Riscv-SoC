module matrix3x3 #(
    parameter IMG_HDISP = 12'd1280,  // 1280*720
    parameter IMG_VDISP = 12'd720
) (
    // global clock
    input wire clk,   // cmos video pixel clock
    input wire rst_n, // global reset

    // Image data prepred to be processd
    input wire       pre_vs,   // Prepared Image data vs valid signal
    input wire       pre_de,   // Prepared Image data output/capture enable clock
    input wire [7:0] pre_data, // Prepared Image brightness input

    // Image data has been processd
    output wire       matrix_vs,  // Prepared Image data vs valid signal
    output wire       matrix_de,  // Prepared Image data output/capture enable clock
    output  reg [7:0] matrix_p11, matrix_p12, matrix_p13,  // 3X3 Matrix output
    output  reg [7:0] matrix_p21, matrix_p22, matrix_p23,
    output  reg [7:0] matrix_p31, matrix_p32, matrix_p33
);

    // Generate 3*3 matrix
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    // sync row3_data with pre_de & row1_data & raw2_data
    wire [7:0] row1_data;  // frame data of the 1th row
    wire [7:0] row2_data;  // frame data of the 2th row
    reg  [7:0] row3_data;  // frame data of the 3th row
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) row3_data <= 0;
        else begin
            if (pre_de) row3_data <= pre_data;
            else row3_data <= row3_data;
        end
    end

    //---------------------------------------
    // module of shift ram for raw data
    wire shift_en = pre_de;
    line_shift_ram #(
        .DATA_WIDTH (8),
        .LINE_LENGTH(IMG_HDISP)
    ) line_shift_ram0 (
        .clk  (clk),        // input wire CLK
        .rst_n(rst_n),      // input wire RST_N
        .CE   (shift_en),   // input wire CE
        .D    (row3_data),  // input wire [7:0] D
        .Q    (row2_data)   // output wire [7:0] Q
    );
    line_shift_ram #(
        .DATA_WIDTH (8),
        .LINE_LENGTH(IMG_HDISP)
    ) line_shift_ram1 (
        .clk  (clk),        // input wire CLK
        .rst_n(rst_n),      // input wire RST_N
        .CE   (shift_en),   // input wire CE
        .D    (row2_data),  // input wire [7:0] D
        .Q    (row1_data)   // output wire [7:0] Q
    );

    //------------------------------------------
    // lag 2 clocks signal sync
    reg [1:0] pre_vs_r;
    reg [1:0] pre_de_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            pre_vs_r <= 0;
            pre_de_r <= 0;
        end else begin
            pre_vs_r <= {pre_vs_r[0], pre_vs};
            pre_de_r <= {pre_de_r[0], pre_de};
        end
    end
    // Give up the 1th and 2th row edge data caculate for simple process
    // Give up the 1th and 2th point of 1 line for simple process
    wire read_de = pre_de_r[0];  // RAM read enable
    assign matrix_vs = pre_vs_r[1];
    assign matrix_de = pre_de_r[1];

    //----------------------------------------------------------------------------
    //----------------------------------------------------------------------------
    /******************************************************************************
                    ----------  Convert Matrix  ----------
                [ P31 -> P32 -> P33 -> ] ---> [ P11 P12 P13 ]
                [ P21 -> P22 -> P23 -> ] ---> [ P21 P22 P23 ]
                [ P11 -> P12 -> P11 -> ] ---> [ P31 P32 P33 ]
    ******************************************************************************/
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    /***********************************************
        (1)	Read data from Shift_RAM
        (2) Caculate the Sobel
        (3) Steady data after Sobel generate
    ************************************************/
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            {matrix_p11, matrix_p12, matrix_p13} <= 24'h0;
            {matrix_p21, matrix_p22, matrix_p23} <= 24'h0;
            {matrix_p31, matrix_p32, matrix_p33} <= 24'h0;
        end else begin
            if (read_de) begin  // Shift_RAM data read clock enable
                {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p12, matrix_p13, row1_data};  // 1th shift input
                {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p22, matrix_p23, row2_data};  // 2th shift input
                {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p32, matrix_p33, row3_data};  // 3th shift input
            end else begin
                {matrix_p11, matrix_p12, matrix_p13} <= {matrix_p11, matrix_p12, matrix_p13};
                {matrix_p21, matrix_p22, matrix_p23} <= {matrix_p21, matrix_p22, matrix_p23};
                {matrix_p31, matrix_p32, matrix_p33} <= {matrix_p31, matrix_p32, matrix_p33};
            end
        end
    end

endmodule
