`include "../para.v"

module GPIO2_InCtrl (
    input  wire [`DATABUS] data,
    output wire [ `LEDBUS] led
);

    // assign led[`LEDBUS] = data[`LEDBUS];
    assign led[`LEDBUS] = ~data[`LEDBUS];

endmodule
