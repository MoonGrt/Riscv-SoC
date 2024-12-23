
module Apb3HRouter (
    input  wire [19:0] io_input_PADDR,
    input  wire [ 0:0] io_input_PSEL,
    input  wire        io_input_PENABLE,
    output reg         io_input_PREADY,
    input  wire        io_input_PWRITE,
    input  wire [31:0] io_input_PWDATA,
    output wire [31:0] io_input_PRDATA,
    output reg         io_input_PSLVERROR,

    // RCC
    output wire [19:0] io_outputs_0_PADDR,
    output wire [ 0:0] io_outputs_0_PSEL,
    output wire        io_outputs_0_PENABLE,
    input  wire        io_outputs_0_PREADY,
    output wire        io_outputs_0_PWRITE,
    output wire [31:0] io_outputs_0_PWDATA,
    input  wire [31:0] io_outputs_0_PRDATA,
    input  wire        io_outputs_0_PSLVERROR,
    // WDG
    output wire [19:0] io_outputs_1_PADDR,
    output wire [ 0:0] io_outputs_1_PSEL,
    output wire        io_outputs_1_PENABLE,
    input  wire        io_outputs_1_PREADY,
    output wire        io_outputs_1_PWRITE,
    output wire [31:0] io_outputs_1_PWDATA,
    input  wire [31:0] io_outputs_1_PRDATA,
    input  wire        io_outputs_1_PSLVERROR,
    // USART
    output wire [19:0] io_outputs_2_PADDR,
    output wire [ 0:0] io_outputs_2_PSEL,
    output wire        io_outputs_2_PENABLE,
    input  wire        io_outputs_2_PREADY,
    output wire        io_outputs_2_PWRITE,
    output wire [31:0] io_outputs_2_PWDATA,
    input  wire [31:0] io_outputs_2_PRDATA,
    input  wire        io_outputs_2_PSLVERROR,

    input  wire        io_axiClk,
    input  wire        resetCtrl_systemReset
);

    wire when_Apb3Decoder_l88;
    reg         _zz_io_input_PREADY;
    reg  [31:0] _zz_io_input_PRDATA;
    reg         _zz_io_input_PSLVERROR;
    reg  [15:0] selIndex;
    reg  [15:0] Apb3PSEL;

    always @(*) begin
        if (resetCtrl_systemReset) begin
            Apb3PSEL <= 16'h0000;
        end else begin
            Apb3PSEL[0] = ((io_input_PADDR[19:16] == 4'd0) && io_input_PSEL[0]);
            Apb3PSEL[1] = ((io_input_PADDR[19:16] == 4'd1) && io_input_PSEL[0]);
            Apb3PSEL[2] = ((io_input_PADDR[19:16] == 4'd2) && io_input_PSEL[0]);
        end
    end

    always @(*) begin
        io_input_PREADY = _zz_io_input_PREADY;
        if (when_Apb3Decoder_l88) begin
            io_input_PREADY = 1'b1;
        end
    end

    assign io_input_PRDATA = _zz_io_input_PRDATA;
    always @(*) begin
        io_input_PSLVERROR = _zz_io_input_PSLVERROR;
        if (when_Apb3Decoder_l88) begin
            io_input_PSLVERROR = 1'b1;
        end
    end

    assign when_Apb3Decoder_l88 = (io_input_PSEL[0] && (Apb3PSEL == 16'h0000));


    always @(posedge io_axiClk) selIndex <= Apb3PSEL;
    always @(*) begin
        if (resetCtrl_systemReset) begin
            _zz_io_input_PREADY <= 1'b1;
            _zz_io_input_PRDATA <= 32'h0;
            _zz_io_input_PSLVERROR <= 1'b0;
        end
        else
            case (selIndex)
                16'h0008: begin
                    _zz_io_input_PREADY = io_outputs_0_PREADY;
                    _zz_io_input_PRDATA = io_outputs_0_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_0_PSLVERROR;
                end
                16'h0010: begin
                    _zz_io_input_PREADY = io_outputs_1_PREADY;
                    _zz_io_input_PRDATA = io_outputs_1_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_1_PSLVERROR;
                end
                16'h0020: begin
                    _zz_io_input_PREADY = io_outputs_2_PREADY;
                    _zz_io_input_PRDATA = io_outputs_2_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_2_PSLVERROR;
                end
                16'h0040: begin
                    _zz_io_input_PREADY = io_outputs_3_PREADY;
                    _zz_io_input_PRDATA = io_outputs_3_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_3_PSLVERROR;
                end
                16'h0080: begin
                    _zz_io_input_PREADY = io_outputs_4_PREADY;
                    _zz_io_input_PRDATA = io_outputs_4_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_4_PSLVERROR;
                end
                16'h0100: begin
                    _zz_io_input_PREADY = io_outputs_5_PREADY;
                    _zz_io_input_PRDATA = io_outputs_5_PRDATA;
                    _zz_io_input_PSLVERROR = io_outputs_5_PSLVERROR;
                end
                default: ;
            endcase
    end

    // GPIO
    assign io_outputs_0_PADDR = io_input_PADDR;
    assign io_outputs_0_PENABLE = io_input_PENABLE;
    assign io_outputs_0_PSEL = Apb3PSEL[3];
    assign io_outputs_0_PWRITE = io_input_PWRITE;
    assign io_outputs_0_PWDATA = io_input_PWDATA;
    // WDG
    assign io_outputs_1_PADDR = io_input_PADDR;
    assign io_outputs_1_PENABLE = io_input_PENABLE;
    assign io_outputs_1_PSEL = Apb3PSEL[4];
    assign io_outputs_1_PWRITE = io_input_PWRITE;
    assign io_outputs_1_PWDATA = io_input_PWDATA;
    // USART
    assign io_outputs_2_PADDR = io_input_PADDR;
    assign io_outputs_2_PENABLE = io_input_PENABLE;
    assign io_outputs_2_PSEL = Apb3PSEL[5];
    assign io_outputs_2_PWRITE = io_input_PWRITE;
    assign io_outputs_2_PWDATA = io_input_PWDATA;
    // I2C
    assign io_outputs_3_PADDR = io_input_PADDR;
    assign io_outputs_3_PENABLE = io_input_PENABLE;
    assign io_outputs_3_PSEL = Apb3PSEL[6];
    assign io_outputs_3_PWRITE = io_input_PWRITE;
    assign io_outputs_3_PWDATA = io_input_PWDATA;
    // SPI
    assign io_outputs_4_PADDR = io_input_PADDR;
    assign io_outputs_4_PENABLE = io_input_PENABLE;
    assign io_outputs_4_PSEL = Apb3PSEL[7];
    assign io_outputs_4_PWRITE = io_input_PWRITE;
    assign io_outputs_4_PWDATA = io_input_PWDATA;
    // TIM
    assign io_outputs_5_PADDR = io_input_PADDR;
    assign io_outputs_5_PENABLE = io_input_PENABLE;
    assign io_outputs_5_PSEL = Apb3PSEL[8];
    assign io_outputs_5_PWRITE = io_input_PWRITE;
    assign io_outputs_5_PWDATA = io_input_PWDATA;

endmodule

