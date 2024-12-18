`timescale 1ns / 10ps
module tb_top;

// top Parameters
parameter T        = 20;
parameter USE_TPG  = "true";

// top Inputs
reg   clk   = 0;
reg   rst_n = 0;

initial begin
    forever #(T/2) clk = ~clk;
end

initial begin
    #(T*2) rst_n = 1;
end

top #(
    .USE_TPG ( USE_TPG ),
    .H_DISP  ( 1280  ),
    .V_DISP  ( 720   ))
top (
    .clk   ( clk   ),
    .rst_n ( rst_n )
);

endmodule