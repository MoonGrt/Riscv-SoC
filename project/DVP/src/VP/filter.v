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

    wire        gaussian_post_vs;  // Processed Image data vs valid signal
    wire        gaussian_post_de;  // Processed Image data output/capture enable clock
    wire [23:0] gaussian_post_data;  // Processed Image output
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
        .post_vs  (gaussian_post_vs),  // Processed Image data vs valid signal
        .post_de  (gaussian_post_de),  // Processed Image data output/capture enable clock
        .post_data(gaussian_post_data)
    );

    wire        mean_post_vs;  // Processed Image data vs valid signal
    wire        mean_post_de;  // Processed Image data output/capture enable clock
    wire [23:0] mean_post_data;  // Processed Image output
    mean #(
        .IMG_HDISP(IMG_HDISP),  // 1280*720
        .IMG_VDISP(IMG_VDISP)
    ) mean (
        // global clock
        .clk  (clk),  // cmos video pixel clock
        .rst_n(rst_n),  // global reset
        .EN   (mean_en),  // enable

        // Image data prepred to be processd
        .pre_vs  (pre_vs),  // Prepared Image data vs valid signal
        .pre_de  (pre_de),  // Prepared Image data output/capture enable clock
        .pre_data(pre_data),

        // Image data has been processd
        .post_vs  (mean_post_vs),  // Processed Image data vs valid signal
        .post_de  (mean_post_de),  // Processed Image data output/capture enable clock
        .post_data(mean_post_data)
    );

    wire        median_post_vs;  // Processed Image data vs valid signal
    wire        median_post_de;  // Processed Image data output/capture enable clock
    wire [23:0] median_post_data;  // Processed Image output
    median #(
        .IMG_HDISP(IMG_HDISP),  // 1280*720
        .IMG_VDISP(IMG_VDISP)
    ) median (
        // global clock
        .clk  (clk),  // cmos video pixel clock
        .rst_n(rst_n),  // global reset
        .EN   (median_en),  // enable

        // Image data prepred to be processd
        .pre_vs  (pre_vs),  // Prepared Image data vs valid signal
        .pre_de  (pre_de),  // Prepared Image data output/capture enable clock
        .pre_data(pre_data),

        // Image data has been processd
        .post_vs  (median_post_vs),  // Processed Image data vs valid signal
        .post_de  (median_post_de),  // Processed Image data output/capture enable clock
        .post_data(median_post_data)
    );

    always @(*) begin
        if(~rst_n) begin
            post_vs   = 1'b0;
            post_de   = 1'b0;
            post_data = 24'b0;
        end else begin
            case(mode)
                2'b01: begin
                    post_vs   = gaussian_post_vs;
                    post_de   = gaussian_post_de;
                    post_data = gaussian_post_data;
                end
                2'b10: begin
                    post_vs   = mean_post_vs;
                    post_de   = mean_post_de;
                    post_data = mean_post_data;
                end
                2'b11: begin
                    post_vs   = median_post_vs;
                    post_de   = median_post_de;
                    post_data = median_post_data;
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
