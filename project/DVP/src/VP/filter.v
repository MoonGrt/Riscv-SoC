module filter #(
    parameter IMG_HDISP = 12'd1280,  // 1280*720
    parameter IMG_VDISP = 12'd720
) (
    // global clock
    input wire       clk,   // cmos video pixel clock
    input wire       rst_n, // global reset
    input wire [1:0] mode,  // enable

    // Image data prepred to be processed
    input wire        pre_vs,   // Prepared Image data vs valid signal
    input wire        pre_de,   // Prepared Image data output/capture enable clock
    input wire [23:0] pre_data, // Prepared Image data

    // Image data has been processed
    output reg        post_vs,   // Processed Image data vs valid signal
    output reg        post_de,   // Processed Image data output/capture enable clock
    output reg [23:0] post_data  // Processed Image data
);

    wire gaussian_en = (mode == 2'b01);  // enable gaussian filter
    wire median_en = (mode == 2'b10);  // enable median filter
    wire mean_en = (mode == 2'b11);  // enable mean filter

    wire        post_vs_gaussian;  // Processed Image data vs valid signal
    wire        post_de_gaussian;  // Processed Image data output/capture enable clock
    wire [23:0] post_data_gaussian;  // Processed Image brightness output
    gaussian #(
        .IMG_HDISP(IMG_HDISP),  // 1280*720
        .IMG_VDISP(IMG_VDISP)
    ) gaussian (
        // global clock
        .clk  (clk),  // cmos video pixel clock
        .rst_n(rst_n),  // global reset
        .EN   (gaussian_en),  // enable

        // Image data prepred to be processd
        .pre_vs  (pre_vs),  // Prepared Image data vs valid signal
        .pre_de  (pre_de),  // Prepared Image data output/capture enable clock
        .pre_data(pre_data),

        // Image data has been processd
        .post_vs  (post_vs_gaussian),  // Processed Image data vs valid signal
        .post_de  (post_de_gaussian),  // Processed Image data output/capture enable clock
        .post_data(post_data_gaussian)
    );

    wire  [7:0] post_y, post_Cr, post_Cb;  // Processed Image brightness output
    wire        post_vs_median;  // Processed Image data vs valid signal
    wire        post_de_median;  // Processed Image data output/capture enable clock
    wire [23:0] post_data_median;  // Processed Image brightness output
    // median #(
    //     .IMG_HDISP(H_DISP),  // 1280*720
    //     .IMG_VDISP(V_DISP)
    // ) median (
    //     // global clock
    //     .clk  (clk),  // cmos video pixel clock
    //     .rst_n(rst_n),  // global reset

    //     // Image data prepred to be processd
    //     .pre_vs(post_vs_ycbcr),  // Prepared Image data vs valid signal
    //     .pre_clken(post_clken_ycbcr),  // Prepared Image data output/capture enable clock
    //     .pre_y(img_y),  // Prepared Image brightness input
    //     .pre_Cr(img_Cr),
    //     .pre_Cb(img_Cb),

    //     // Image data has been processd
    //     .post_vs(post_vs_mid_value),  // Processed Image data vs valid signal
    //     .post_clken(post_clken_mid_value),  // Processed Image data output/capture enable clock
    //     .post_y(post_y)
    // );

    wire        post_vs_mean;  // Processed Image data vs valid signal
    wire        post_de_mean;  // Processed Image data output/capture enable clock
    wire [23:0] post_data_mean;  // Processed Image brightness output


    always @(*) begin
        if(~rst_n) begin
            post_vs   = 1'b0;
            post_de   = 1'b0;
            post_data = 24'b0;
        end else begin
            case(mode)
                2'b01: begin
                    post_vs   = post_vs_gaussian;
                    post_de   = post_de_gaussian;
                    post_data = post_data_gaussian;
                end
                2'b10: begin
                    post_vs   = post_vs_median;
                    post_de   = post_de_median;
                    post_data = post_data_median;
                end
                2'b11: begin
                    post_vs   = post_vs_mean;
                    post_de   = post_de_mean;
                    post_data = post_data_mean;
                end
                default: begin
                    post_vs   = pre_vs;
                    post_de   = pre_de;
                    post_data = pre_data;
                end
            endcase
        end
    end

endmodule
