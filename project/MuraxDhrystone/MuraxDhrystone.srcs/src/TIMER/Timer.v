module Timer (
    input  wire        io_tick,
    input  wire        io_clear,
    input  wire [15:0] io_limit,
    output wire        io_full,
    output wire [15:0] io_value,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    wire [15:0] _zz_counter;
    wire [ 0:0] _zz_counter_1;
    reg  [15:0] counter;
    wire        limitHit;
    reg         inhibitFull;

    assign _zz_counter_1 = (!limitHit);
    assign _zz_counter = {15'd0, _zz_counter_1};
    assign limitHit = (counter == io_limit);
    assign io_full = ((limitHit && io_tick) && (!inhibitFull));
    assign io_value = counter;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            inhibitFull <= 1'b0;
        end else begin
            if (io_tick) begin
                inhibitFull <= limitHit;
            end
            if (io_clear) begin
                inhibitFull <= 1'b0;
            end
        end
    end

    always @(posedge io_mainClk) begin
        if (io_tick) begin
            counter <= (counter + _zz_counter);
        end
        if (io_clear) begin
            counter <= 16'h0;
        end
    end


endmodule
