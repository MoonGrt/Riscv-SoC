module AHBVP (
    input clk,
    input rst_n,

    // video input
    input        vin_clk,
    input        vin_vs,
    input        vin_de,
    input [15:0] vin_data,

    // video process
    output        vp_clk,
    output        vp_vs,
    output        vp_de,
    output [15:0] vp_data
);

    // algorithm Parameters
    parameter VIO_DATA_WIDTH = 8;
    parameter CHANNELS = 3;
    parameter BUFFER_SIZE = 3;
    parameter INPUT_X_RES_WIDTH = 11;
    parameter INPUT_Y_RES_WIDTH = 11;
    parameter OUTPUT_X_RES_WIDTH = 11;
    parameter OUTPUT_Y_RES_WIDTH = 11;

    // algorithm Inputs
    // parameter START_X = 12'd1280 / 4;
    // parameter START_Y = 12'd720 / 4;
    // parameter END_X = 12'd1280 * 3 / 4;
    // parameter END_Y = 12'd720 * 3 / 4;
    // parameter OUTPUT_X_RES = 12'd1280 - 1;  //Resolution of output data minus 1
    // parameter OUTPUT_Y_RES = 12'd720 - 1;  //Resolution of output data minus 1

    parameter START_X = 0;
    parameter START_Y = 0;
    parameter END_X = 12'd1280 / 2;
    parameter END_Y = 12'd720 / 2;
    parameter OUTPUT_X_RES = 12'd1280 - 1;  //Resolution of output data minus 1
    parameter OUTPUT_Y_RES = 12'd720 - 1;  //Resolution of output data minus 1

    // parameter START_X = 0;
    // parameter START_Y = 0;
    // parameter END_X = 12'd1280;
    // parameter END_Y = 12'd720;
    // parameter OUTPUT_X_RES = 12'd1280 - 1;  //Resolution of output data minus 1
    // parameter OUTPUT_Y_RES = 12'd720 - 1;  //Resolution of output data minus 1

    // parameter START_X = 0;
    // parameter START_Y = 0;
    // parameter END_X = 12'd1280;
    // parameter END_Y = 12'd720;
    // parameter OUTPUT_X_RES = 12'd1280 / 2 - 1;  //Resolution of output data minus 1
    // parameter OUTPUT_Y_RES = 12'd720 / 2 - 1;  //Resolution of output data minus 1

    reg algorithm_sel = 1;
    wire algorithm_dataValid;
    wire [VIO_DATA_WIDTH*CHANNELS-1:0] algorithm_data;
    wire de_i = vin_de;
    wire [VIO_DATA_WIDTH*CHANNELS-1:0] rgb_i = {
        vin_data[15:11], 3'b0, vin_data[10:5], 2'b0, vin_data[4:0], 3'b0
    };
    algorithm #(
        .H_DISP(12'd1280),
        .V_DISP(12'd720),

        .DATA_WIDTH (VIO_DATA_WIDTH),
        .CHANNELS   (CHANNELS),
        .BUFFER_SIZE(BUFFER_SIZE),

        .INPUT_X_RES_WIDTH (INPUT_X_RES_WIDTH),
        .INPUT_Y_RES_WIDTH (INPUT_Y_RES_WIDTH),
        .OUTPUT_X_RES_WIDTH(OUTPUT_X_RES_WIDTH),
        .OUTPUT_Y_RES_WIDTH(OUTPUT_Y_RES_WIDTH)
    ) algorithm (
        .clk   (vin_clk),
        .clk_2x(clk),

        .START_X   (START_X),
        .START_Y   (START_Y),
        .END_X     (END_X),
        .END_Y     (END_Y),
        .outputXRes(OUTPUT_X_RES),
        .outputYRes(OUTPUT_Y_RES),

        .algorithm_sel(algorithm_sel),
        .hs_i         (),
        .vs_i         (vin_vs),         // 检查极性
        .de_i         (de_i),
        .rgb_i        (rgb_i),

        .algorithm_data     (algorithm_data),
        .algorithm_dataValid(algorithm_dataValid)
    );

    assign vp_clk  = clk;
    assign vp_vs   = vin_vs;
    assign vp_de   = algorithm_dataValid;
    assign vp_data = {algorithm_data[23:19], algorithm_data[15:10], algorithm_data[7:3]};

endmodule
