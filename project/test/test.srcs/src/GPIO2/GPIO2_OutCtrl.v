`include "../para.v"

module GPIO2_OutCtrl (
    input  wire [`BUTTOMBUS] buttom,
    output wire [  `DATABUS] data
);

    assign data[`BUTTOMBUS] = buttom;
    assign data[`CPU_WIDTH-1:`BUTTOM_NUM] = 'b0;

endmodule
