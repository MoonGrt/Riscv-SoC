`timescale 1ns / 1ps

module algorithm #(
    parameter H_SYNC  = 12'd44,
    parameter H_BACK  = 12'd148,
    parameter H_DISP  = 12'd1920,
    parameter H_FRONT = 12'd88,

    parameter V_SYNC  = 12'd5,
    parameter V_BACK  = 12'd36,
    parameter V_DISP  = 12'd1080,
    parameter V_FRONT = 12'd4,

    parameter DATA_WIDTH = 8,
    parameter CHANNELS = 3,
    parameter BUFFER_SIZE = 3,  // Number of RAMs in RAM ring buffer
    parameter DISCARD_CNT_WIDTH = 2,

    parameter INPUT_X_RES_WIDTH  = 11,
    parameter INPUT_Y_RES_WIDTH  = 11,
    parameter OUTPUT_X_RES_WIDTH = 11,
    parameter OUTPUT_Y_RES_WIDTH = 11,

    parameter FRACTION_BITS   = 8,                                // Don't modify
    parameter SCALE_INT_BITS  = 4,                                // Don't modify
    parameter SCALE_FRAC_BITS = 14,                               // Don't modify
    parameter SCALE_BITS      = SCALE_INT_BITS + SCALE_FRAC_BITS
) (
    input wire clk,
    input wire clk_2x,
    //    input wire clk_5x,
    //    input wire rst_n,

    input wire [ INPUT_X_RES_WIDTH-1:0] START_X,  //Resolution of input data minus 1
    input wire [ INPUT_Y_RES_WIDTH-1:0] START_Y,
    input wire [OUTPUT_X_RES_WIDTH-1:0] END_X,    //Resolution of output data minus 1
    input wire [OUTPUT_Y_RES_WIDTH-1:0] END_Y,

    input wire [OUTPUT_X_RES_WIDTH-1:0] outputXRes,  //Resolution of output data minus 1
    input wire [OUTPUT_Y_RES_WIDTH-1:0] outputYRes,  //Resolution of output data minus 1

    input wire algorithm_sel,

    input wire                           hs_i,
    input wire                           vs_i,
    input wire                           de_i,
    input wire [DATA_WIDTH*CHANNELS-1:0] rgb_i,

    output wire vs,
    output wire [DATA_WIDTH*CHANNELS-1:0] algorithm_data,
    output wire                           algorithm_dataValid

    // output wire [DATA_WIDTH*CHANNELS-1:0] scaler_data,
    // output wire                           scaler_dataValid
);

    wire [  INPUT_X_RES_WIDTH-1:0] inputXRes = END_X - START_X - 1;  //Resolution of input data minus 1
    wire [  INPUT_Y_RES_WIDTH-1:0] inputYRes = END_Y - START_Y - 1;

    wire [         SCALE_BITS-1:0] xScale = 32'h4000 * (inputXRes + 1) / (outputXRes + 1);  //Scaling factors. Input resolution scaled up by 1/xScale. Format Q SCALE_INT_BITS.SCALE_FRAC_BITS
    wire [         SCALE_BITS-1:0] yScale = 32'h4000 * (inputYRes + 1) / (outputYRes + 1);  //Scaling factors. Input resolution scaled up by 1/yScale. Format Q SCALE_INT_BITS.SCALE_FRAC_BITS

    wire [DATA_WIDTH*CHANNELS-1:0]                                                                                                                                                             image_cut_rgb;
    wire image_cut_de, image_cut_vs;
    wire [DATA_WIDTH*CHANNELS-1:0] fifo1_data;
    wire fifo1_empty, fifo1_full;
    wire                           fifo1_dataValid;
    wire                           scaler_re;
    wire                           state;
    wire [DATA_WIDTH*CHANNELS-1:0] scaler_data;
    wire                           scaler_dataValid;

    image_cut #(
        .H_DISP(H_DISP),
        .V_DISP(V_DISP),
        .INPUT_X_RES_WIDTH(INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH(INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH)
    ) image_cut (
        .clk(clk),

        .start_x(START_X),
        .start_y(START_Y),
        .end_x  (END_X),
        .end_y  (END_Y),

        .hs_i (hs_i),
        .vs_i (vs_i),
        .de_i (de_i),
        .rgb_i(rgb_i),

        .de_o (image_cut_de),
        .vs_o (image_cut_vs),
        .rgb_o(image_cut_rgb),
        .state(state)
    );

    reg vs_reg1, vs_reg2;
    assign vs = vs_reg1 & ~vs_reg2;
    always @(posedge clk_2x) begin
        vs_reg1 <= image_cut_vs;
        vs_reg2 <= vs_reg1;
    end

    FIFO #(
        .FIFO_MODE ("Normal"),  //"Normal"; //"ShowAhead"
        .DATA_WIDTH(24),
        .FIFO_DEPTH(1024)
    ) FIFO (

        /*i*/.Reset(~state),  //System Reset

        /*i*/.WrClk (clk),           //(I)Wirte Clock
        /*i*/.WrEn  (image_cut_de),  //(I)Write Enable
        /*o*/.WrDNum(),              //(O)Write Data Number In Fifo
        /*o*/.WrFull(fifo1_full),    //(I)Write Full
        /*i*/.WrData(image_cut_rgb), //(I)Write Data

        /*i*/.RdClk  (clk_2x),       //(I)Read Clock
        /*i*/.RdEn   (scaler_re),    //(I)Read Enable
        /*o*/.RdDNum (),             //(O)Radd Data Number In Fifo
        /*o*/.RdEmpty(fifo1_empty),  //(O)Read FifoEmpty
        /*o*/.RdData (fifo1_data)    //(O)Read Data
    );

    streamScaler #(
        .DATA_WIDTH        (DATA_WIDTH),
        .CHANNELS          (CHANNELS),
        .DISCARD_CNT_WIDTH (DISCARD_CNT_WIDTH),
        .INPUT_X_RES_WIDTH (INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH (INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH),
        .BUFFER_SIZE       (BUFFER_SIZE),         //Number of RAMs in RAM ring buffer
        .FRACTION_BITS     (FRACTION_BITS),
        .SCALE_INT_BITS    (SCALE_INT_BITS),
        .SCALE_FRAC_BITS   (SCALE_FRAC_BITS)
    ) streamScaler (
        .clk(clk_2x),

        .dIn     (fifo1_data),
        // .dInValid(fifo1_dataValid),
        .dInValid(scaler_re & ~fifo1_empty),
        .nextDin (scaler_re),
        .start   (vs),

        .dOut     (scaler_data),
        .dOutValid(scaler_dataValid),
        .nextDout (1),

        //Control
        .inputXRes (inputXRes),   //Input data number of pixels per line
        .inputYRes (inputYRes),
        .outputXRes(outputXRes),  //Resolution of output data
        .outputYRes(outputYRes),
        .xScale    (xScale),      //Scaling factors. Input resolution scaled by 1/xScale. Format Q4.14
        .yScale    (yScale),      //Scaling factors. Input resolution scaled by 1/yScale. Format Q4.14

        .nearestNeighbor(algorithm_sel),
        .inputDiscardCnt(0),              //Number of input pixels to discard before processing data. Used for clipping
        .leftOffset     (0),
        .topFracOffset  (0)
    );

    wire [DATA_WIDTH*CHANNELS-1:0] fill_data;
    wire                           fill_dataValid;
    assign algorithm_data      = fill_data;
    assign algorithm_dataValid = fill_dataValid;

    pixel_cnt pixel_cnt (
        .rst(image_cut_vs),
        .clk(clk_2x),
        .de (fill_dataValid)
    );

    fill_brank #(
        .H_DISP(H_DISP)
    ) fill_brank (
        .clk        (clk_2x),
        .data_i     (scaler_data),
        .dataValid_i(scaler_dataValid),
        .data_o     (fill_data),
        .dataValid_o(fill_dataValid)
    );

endmodule
