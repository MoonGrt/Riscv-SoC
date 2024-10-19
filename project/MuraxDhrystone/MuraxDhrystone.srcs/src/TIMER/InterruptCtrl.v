module InterruptCtrl (
    input  wire [1:0] io_inputs,
    input  wire [1:0] io_clears,
    input  wire [1:0] io_masks,
    output wire [1:0] io_pendings,
    input  wire       io_mainClk,
    input  wire       resetCtrl_systemReset
);

    reg [1:0] pendings;

    assign io_pendings = (pendings & io_masks);
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            pendings <= 2'b00;
        end else begin
            pendings <= ((pendings & (~io_clears)) | io_inputs);
        end
    end


endmodule
