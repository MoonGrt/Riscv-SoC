module Axi4SharedToApb3Bridge (
    input  wire        io_axi_arw_valid,
    output reg         io_axi_arw_ready,
    input  wire [19:0] io_axi_arw_payload_addr,
    input  wire [ 3:0] io_axi_arw_payload_id,
    input  wire [ 7:0] io_axi_arw_payload_len,
    input  wire [ 2:0] io_axi_arw_payload_size,
    input  wire [ 1:0] io_axi_arw_payload_burst,
    input  wire        io_axi_arw_payload_write,
    input  wire        io_axi_w_valid,
    output reg         io_axi_w_ready,
    input  wire [31:0] io_axi_w_payload_data,
    input  wire [ 3:0] io_axi_w_payload_strb,
    input  wire        io_axi_w_payload_last,
    output reg         io_axi_b_valid,
    input  wire        io_axi_b_ready,
    output wire [ 3:0] io_axi_b_payload_id,
    output wire [ 1:0] io_axi_b_payload_resp,
    output reg         io_axi_r_valid,
    input  wire        io_axi_r_ready,
    output wire [31:0] io_axi_r_payload_data,
    output wire [ 3:0] io_axi_r_payload_id,
    output wire [ 1:0] io_axi_r_payload_resp,
    output wire        io_axi_r_payload_last,
    output wire [19:0] io_apb_PADDR,
    output reg  [ 0:0] io_apb_PSEL,
    output reg         io_apb_PENABLE,
    input  wire        io_apb_PREADY,
    output wire        io_apb_PWRITE,
    output wire [31:0] io_apb_PWDATA,
    input  wire [31:0] io_apb_PRDATA,
    input  wire        io_apb_PSLVERROR,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);
    localparam Axi4ToApb3BridgePhase_SETUP = 2'd0;
    localparam Axi4ToApb3BridgePhase_ACCESS_1 = 2'd1;
    localparam Axi4ToApb3BridgePhase_RESPONSE = 2'd2;

    reg  [ 1:0] phase;
    reg         write;
    reg  [31:0] readedData;
    reg  [ 3:0] id;
    wire        when_Axi4SharedToApb3Bridge_l91;
    wire        when_Axi4SharedToApb3Bridge_l97;
`ifndef SYNTHESIS
    reg [63:0] phase_string;
`endif


`ifndef SYNTHESIS
    always @(*) begin
        case (phase)
            Axi4ToApb3BridgePhase_SETUP: phase_string = "SETUP   ";
            Axi4ToApb3BridgePhase_ACCESS_1: phase_string = "ACCESS_1";
            Axi4ToApb3BridgePhase_RESPONSE: phase_string = "RESPONSE";
            default: phase_string = "????????";
        endcase
    end
`endif

    always @(*) begin
        io_axi_arw_ready = 1'b0;
        case (phase)
            Axi4ToApb3BridgePhase_SETUP: begin
                if (when_Axi4SharedToApb3Bridge_l91) begin
                    if (when_Axi4SharedToApb3Bridge_l97) begin
                        io_axi_arw_ready = 1'b1;
                    end
                end
            end
            Axi4ToApb3BridgePhase_ACCESS_1: begin
                if (io_apb_PREADY) begin
                    io_axi_arw_ready = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        io_axi_w_ready = 1'b0;
        case (phase)
            Axi4ToApb3BridgePhase_SETUP: begin
                if (when_Axi4SharedToApb3Bridge_l91) begin
                    if (when_Axi4SharedToApb3Bridge_l97) begin
                        io_axi_w_ready = 1'b1;
                    end
                end
            end
            Axi4ToApb3BridgePhase_ACCESS_1: begin
                if (io_apb_PREADY) begin
                    io_axi_w_ready = write;
                end
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        io_axi_b_valid = 1'b0;
        case (phase)
            Axi4ToApb3BridgePhase_SETUP: begin
            end
            Axi4ToApb3BridgePhase_ACCESS_1: begin
            end
            default: begin
                if (write) begin
                    io_axi_b_valid = 1'b1;
                end
            end
        endcase
    end

    always @(*) begin
        io_axi_r_valid = 1'b0;
        case (phase)
            Axi4ToApb3BridgePhase_SETUP: begin
            end
            Axi4ToApb3BridgePhase_ACCESS_1: begin
            end
            default: begin
                if (!write) begin
                    io_axi_r_valid = 1'b1;
                end
            end
        endcase
    end

    always @(*) begin
        io_apb_PSEL[0] = 1'b0;
        case (phase)
            Axi4ToApb3BridgePhase_SETUP: begin
                if (when_Axi4SharedToApb3Bridge_l91) begin
                    io_apb_PSEL[0] = 1'b1;
                    if (when_Axi4SharedToApb3Bridge_l97) begin
                        io_apb_PSEL[0] = 1'b0;
                    end
                end
            end
            Axi4ToApb3BridgePhase_ACCESS_1: begin
                io_apb_PSEL[0] = 1'b1;
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        io_apb_PENABLE = 1'b0;
        case (phase)
            Axi4ToApb3BridgePhase_SETUP: begin
            end
            Axi4ToApb3BridgePhase_ACCESS_1: begin
                io_apb_PENABLE = 1'b1;
            end
            default: begin
            end
        endcase
    end

    assign when_Axi4SharedToApb3Bridge_l91 = (io_axi_arw_valid && ((! io_axi_arw_payload_write) || io_axi_w_valid));
    assign when_Axi4SharedToApb3Bridge_l97 = (io_axi_arw_payload_write && (io_axi_w_payload_strb == 4'b0000));
    assign io_apb_PADDR = io_axi_arw_payload_addr;
    assign io_apb_PWDATA = io_axi_w_payload_data;
    assign io_apb_PWRITE = io_axi_arw_payload_write;
    assign io_axi_r_payload_resp = {io_apb_PSLVERROR, 1'b0};
    assign io_axi_b_payload_resp = {io_apb_PSLVERROR, 1'b0};
    assign io_axi_r_payload_id = id;
    assign io_axi_b_payload_id = id;
    assign io_axi_r_payload_data = readedData;
    assign io_axi_r_payload_last = 1'b1;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            phase <= Axi4ToApb3BridgePhase_SETUP;
        end else begin
            case (phase)
                Axi4ToApb3BridgePhase_SETUP: begin
                    if (when_Axi4SharedToApb3Bridge_l91) begin
                        phase <= Axi4ToApb3BridgePhase_ACCESS_1;
                        if (when_Axi4SharedToApb3Bridge_l97) begin
                            phase <= Axi4ToApb3BridgePhase_RESPONSE;
                        end
                    end
                end
                Axi4ToApb3BridgePhase_ACCESS_1: begin
                    if (io_apb_PREADY) begin
                        phase <= Axi4ToApb3BridgePhase_RESPONSE;
                    end
                end
                default: begin
                    if (write) begin
                        if (io_axi_b_ready) begin
                            phase <= Axi4ToApb3BridgePhase_SETUP;
                        end
                    end else begin
                        if (io_axi_r_ready) begin
                            phase <= Axi4ToApb3BridgePhase_SETUP;
                        end
                    end
                end
            endcase
        end
    end

    always @(posedge io_axiClk) begin
        case (phase)
            Axi4ToApb3BridgePhase_SETUP: begin
                write <= io_axi_arw_payload_write;
                id <= io_axi_arw_payload_id;
            end
            Axi4ToApb3BridgePhase_ACCESS_1: begin
                if (io_apb_PREADY) begin
                    readedData <= io_apb_PRDATA;
                end
            end
            default: begin
            end
        endcase
    end

endmodule


module Apb3PRouter (
    input  wire [19:0] io_input_PADDR,
    input  wire [ 0:0] io_input_PSEL,
    input  wire        io_input_PENABLE,
    output reg         io_input_PREADY,
    input  wire        io_input_PWRITE,
    input  wire [31:0] io_input_PWDATA,
    output wire [31:0] io_input_PRDATA,
    output reg         io_input_PSLVERROR,

    // GPIO
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
    // I2C
    output wire [19:0] io_outputs_3_PADDR,
    output wire [ 0:0] io_outputs_3_PSEL,
    output wire        io_outputs_3_PENABLE,
    input  wire        io_outputs_3_PREADY,
    output wire        io_outputs_3_PWRITE,
    output wire [31:0] io_outputs_3_PWDATA,
    input  wire [31:0] io_outputs_3_PRDATA,
    input  wire        io_outputs_3_PSLVERROR,
    // SPI
    output wire [19:0] io_outputs_4_PADDR,
    output wire [ 0:0] io_outputs_4_PSEL,
    output wire        io_outputs_4_PENABLE,
    input  wire        io_outputs_4_PREADY,
    output wire        io_outputs_4_PWRITE,
    output wire [31:0] io_outputs_4_PWDATA,
    input  wire [31:0] io_outputs_4_PRDATA,
    input  wire        io_outputs_4_PSLVERROR,
    // TIM
    output wire [19:0] io_outputs_5_PADDR,
    output wire [ 0:0] io_outputs_5_PSEL,
    output wire        io_outputs_5_PENABLE,
    input  wire        io_outputs_5_PREADY,
    output wire        io_outputs_5_PWRITE,
    output wire [31:0] io_outputs_5_PWDATA,
    input  wire [31:0] io_outputs_5_PRDATA,
    input  wire        io_outputs_5_PSLVERROR,

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
            Apb3PSEL[3] = ((io_input_PADDR[19:16] == 4'd3) && io_input_PSEL[0]);  // GPIO
            Apb3PSEL[4] = ((io_input_PADDR[19:16] == 4'd4) && io_input_PSEL[0]);  // WDG
            Apb3PSEL[5] = ((io_input_PADDR[19:16] == 4'd5) && io_input_PSEL[0]);  // USART
            Apb3PSEL[6] = ((io_input_PADDR[19:16] == 4'd6) && io_input_PSEL[0]);  // I2C
            Apb3PSEL[7] = ((io_input_PADDR[19:16] == 4'd7) && io_input_PSEL[0]);  // SPI
            Apb3PSEL[8] = ((io_input_PADDR[19:16] == 4'd8) && io_input_PSEL[0]);  // TIM
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
