`timescale 1ns / 1ps

module pixel_cnt(
    input wire rst,
    input wire clk,
    input wire de
    );

reg [25:0] pixel_cnt = 0;

always @(posedge clk)
begin
    if(rst)
        pixel_cnt <=0;
	else if(de)
		pixel_cnt <= pixel_cnt + 1;
	else
	    pixel_cnt <= pixel_cnt;
end

endmodule
