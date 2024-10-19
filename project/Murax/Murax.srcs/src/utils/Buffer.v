module Buffer #(
    parameter WIDTH = 16
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             we,
    input  wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout
);

    reg [WIDTH-1:0] buff;
    assign dout = buff;

    //*****************************************************
    //**                 Write Buffer
    //*****************************************************
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) buff[WIDTH-1:0] <= 'b0;
        else if (we) buff[WIDTH-1:0] <= din[WIDTH-1:0];
    end

endmodule
