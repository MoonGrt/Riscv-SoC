module scaler #(
    parameter INPUT_X_RES_WIDTH = 11,  // Widths of input/output resolution control signals
    parameter INPUT_Y_RES_WIDTH = 11,
    parameter OUTPUT_X_RES_WIDTH = 11,
    parameter OUTPUT_Y_RES_WIDTH = 11
) (
    input wire EN,  // Enable

    input wire [ INPUT_X_RES_WIDTH-1:0] inputXRes,  // Resolution of input data minus 1
    input wire [ INPUT_Y_RES_WIDTH-1:0] inputYRes,
    input wire [OUTPUT_X_RES_WIDTH-1:0] outputXRes,  // Resolution of input data minus 1
    input wire [OUTPUT_Y_RES_WIDTH-1:0] outputYRes,

    // Image data prepred to be processed
    input wire        pre_clk,  // Prepared Image data clock
    input wire        pre_vs,   // Prepared Image data vs valid signal
    input wire        pre_de,   // Prepared Image data output/capture enable clock
    input wire [23:0] pre_data, // Prepared Image data

    // Image data has been processed
    input  wire        post_clk,  // Processed Image data clock
    output wire        post_vs,   // Processed Image data vs valid signal
    output wire        post_de,   // Processed Image data output/capture enable clock
    output wire [23:0] post_data  // Processed Image data
);
    // Scaler Parameters
    parameter DATA_WIDTH = 8;
    parameter CHANNELS = 3;
    parameter BUFFER_SIZE = 3;

    parameter DISCARD_CNT_WIDTH = 2;
    parameter FRACTION_BITS = 8;  // Don't modify
    parameter SCALE_INT_BITS = 4;  // Don't modify
    parameter SCALE_FRAC_BITS = 14;  // Don't modify
    parameter SCALE_BITS = SCALE_INT_BITS + SCALE_FRAC_BITS;

    wire [SCALE_BITS-1:0] xScale = 32'h4000 * (inputXRes + 1) / (outputXRes + 1);  // Scaling factors. Input resolution scaled up by 1/xScale. Format Q SCALE_INT_BITS.SCALE_FRAC_BITS
    wire [SCALE_BITS-1:0] yScale = 32'h4000 * (inputYRes + 1) / (outputYRes + 1);  // Scaling factors. Input resolution scaled up by 1/yScale. Format Q SCALE_INT_BITS.SCALE_FRAC_BITS

    wire fifo_empty;
    wire [23:0] fifo_data;
    wire        scaler_re;

    reg         algorithm_sel = 1'b1;
    wire [23:0] scaler_data;
    wire        scaler_dataValid;
    FIFO #(
        .FIFO_MODE ("Normal"),  //"Normal"; //"ShowAhead"
        .DATA_WIDTH(24),
        .FIFO_DEPTH(1024)
    ) FIFO (
        /*i*/.Reset(pre_vs),  // System Reset

        /*i*/.WrClk (pre_clk),  // (I)Wirte Clock
        /*i*/.WrEn  (pre_de),   // (I)Write Enable
        /*o*/.WrDNum(),         // (O)Write Data Number In Fifo
        /*o*/.WrFull(),         // (I)Write Full
        /*i*/.WrData(pre_data), // (I)Write Data

        /*i*/.RdClk  (post_clk),     // (I)Read Clock
        /*i*/.RdEn   (scaler_re),    // (I)Read Enable
        /*o*/.RdDNum (),             // (O)Radd Data Number In Fifo
        /*o*/.RdEmpty(fifo_empty),  // (O)Read FifoEmpty
        /*o*/.RdData (fifo_data)    // (O)Read Data
    );

    streamScaler #(
        .DATA_WIDTH        (DATA_WIDTH),
        .CHANNELS          (CHANNELS),
        .DISCARD_CNT_WIDTH (DISCARD_CNT_WIDTH),
        .INPUT_X_RES_WIDTH (INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH (INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH),
        .BUFFER_SIZE       (BUFFER_SIZE),  // Number of RAMs in RAM ring buffer
        .FRACTION_BITS     (FRACTION_BITS),
        .SCALE_INT_BITS    (SCALE_INT_BITS),
        .SCALE_FRAC_BITS   (SCALE_FRAC_BITS)
    ) streamScaler (
        .clk(post_clk),

        .dIn     (fifo_data),
        .dInValid(scaler_re & ~fifo_empty),
        .nextDin (scaler_re),
        .start   (pre_vs),

        .dOut     (scaler_data),
        .dOutValid(scaler_dataValid),
        .nextDout (1'b1),

        // Control
        .inputXRes (inputXRes),  // Input data number of pixels per line
        .inputYRes (inputYRes),
        .outputXRes(outputXRes),  // Resolution of output data
        .outputYRes(outputYRes),
        .xScale    (xScale),  // Scaling factors. Input resolution scaled by 1/xScale. Format Q4.14
        .yScale    (yScale),  // Scaling factors. Input resolution scaled by 1/yScale. Format Q4.14

        .nearestNeighbor(algorithm_sel),
        .inputDiscardCnt(0),  // Number of input pixels to discard before processing data. Used for clipping
        .leftOffset     (0),
        .topFracOffset  (0)
    );

    assign post_vs   = pre_vs;
    assign post_de   = EN ? scaler_dataValid : pre_de;
    assign post_data = EN ? scaler_data : pre_data;

endmodule
