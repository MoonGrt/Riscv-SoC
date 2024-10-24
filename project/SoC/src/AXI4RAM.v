module AXI4RAM (
    input  wire        io_axi_arw_valid,
    output reg         io_axi_arw_ready,
    input  wire [17:0] io_axi_arw_payload_addr,
    input  wire [ 3:0] io_axi_arw_payload_id,
    input  wire [ 7:0] io_axi_arw_payload_len,
    input  wire [ 2:0] io_axi_arw_payload_size,
    input  wire [ 1:0] io_axi_arw_payload_burst,
    input  wire        io_axi_arw_payload_write,
    input  wire        io_axi_w_valid,
    output wire        io_axi_w_ready,
    input  wire [31:0] io_axi_w_payload_data,
    input  wire [ 3:0] io_axi_w_payload_strb,
    input  wire        io_axi_w_payload_last,
    output wire        io_axi_b_valid,
    input  wire        io_axi_b_ready,
    output wire [ 3:0] io_axi_b_payload_id,
    output wire [ 1:0] io_axi_b_payload_resp,
    output wire        io_axi_r_valid,
    input  wire        io_axi_r_ready,
    output wire [31:0] io_axi_r_payload_data,
    output wire [ 3:0] io_axi_r_payload_id,
    output wire [ 1:0] io_axi_r_payload_resp,
    output wire        io_axi_r_payload_last,
    input  wire        io_axiClk,
    input  wire        resetCtrl_axiReset
);

    reg  [31:0] ram_spinal_port0;
    wire [ 1:0] _zz_Axi4Incr_alignMask;
    wire [11:0] _zz_Axi4Incr_baseIncr;
    wire [ 2:0] _zz_Axi4Incr_wrapCase_1;
    wire [ 2:0] _zz_Axi4Incr_wrapCase_2;
    reg  [11:0] _zz_Axi4Incr_result;
    wire [10:0] _zz_Axi4Incr_result_1;
    wire [ 0:0] _zz_Axi4Incr_result_2;
    wire [ 9:0] _zz_Axi4Incr_result_3;
    wire [ 1:0] _zz_Axi4Incr_result_4;
    wire [ 8:0] _zz_Axi4Incr_result_5;
    wire [ 2:0] _zz_Axi4Incr_result_6;
    wire [ 7:0] _zz_Axi4Incr_result_7;
    wire [ 3:0] _zz_Axi4Incr_result_8;
    wire [ 6:0] _zz_Axi4Incr_result_9;
    wire [ 4:0] _zz_Axi4Incr_result_10;
    wire [ 5:0] _zz_Axi4Incr_result_11;
    wire [ 5:0] _zz_Axi4Incr_result_12;
    reg         unburstify_result_valid;
    wire        unburstify_result_ready;
    reg         unburstify_result_payload_last;
    reg  [17:0] unburstify_result_payload_fragment_addr;
    reg  [ 3:0] unburstify_result_payload_fragment_id;
    reg  [ 2:0] unburstify_result_payload_fragment_size;
    reg  [ 1:0] unburstify_result_payload_fragment_burst;
    reg         unburstify_result_payload_fragment_write;
    wire        unburstify_doResult;
    reg         unburstify_buffer_valid;
    reg  [ 7:0] unburstify_buffer_len;
    reg  [ 7:0] unburstify_buffer_beat;
    reg  [17:0] unburstify_buffer_transaction_addr;
    reg  [ 3:0] unburstify_buffer_transaction_id;
    reg  [ 2:0] unburstify_buffer_transaction_size;
    reg  [ 1:0] unburstify_buffer_transaction_burst;
    reg         unburstify_buffer_transaction_write;
    wire        unburstify_buffer_last;
    wire [ 1:0] Axi4Incr_validSize;
    reg  [17:0] Axi4Incr_result;
    wire [ 5:0] Axi4Incr_highCat;
    wire [ 2:0] Axi4Incr_sizeValue;
    wire [11:0] Axi4Incr_alignMask;
    wire [11:0] Axi4Incr_base;
    wire [11:0] Axi4Incr_baseIncr;
    reg  [ 1:0] _zz_Axi4Incr_wrapCase;
    wire [ 2:0] Axi4Incr_wrapCase;
    wire        when_Axi4Channel_l322;
    wire        _zz_unburstify_result_ready;
    wire        stage0_valid;
    reg         stage0_ready;
    wire        stage0_payload_last;
    wire [17:0] stage0_payload_fragment_addr;
    wire [ 3:0] stage0_payload_fragment_id;
    wire [ 2:0] stage0_payload_fragment_size;
    wire [ 1:0] stage0_payload_fragment_burst;
    wire        stage0_payload_fragment_write;
    wire [15:0] _zz_io_axi_r_payload_data;
    wire        stage0_fire;
    wire [31:0] _zz_io_axi_r_payload_data_1;
    wire        stage1_valid;
    wire        stage1_ready;
    wire        stage1_payload_last;
    wire [17:0] stage1_payload_fragment_addr;
    wire [ 3:0] stage1_payload_fragment_id;
    wire [ 2:0] stage1_payload_fragment_size;
    wire [ 1:0] stage1_payload_fragment_burst;
    wire        stage1_payload_fragment_write;
    reg         stage0_rValid;
    reg         stage0_rData_last;
    reg  [17:0] stage0_rData_fragment_addr;
    reg  [ 3:0] stage0_rData_fragment_id;
    reg  [ 2:0] stage0_rData_fragment_size;
    reg  [ 1:0] stage0_rData_fragment_burst;
    reg         stage0_rData_fragment_write;
    wire        when_Stream_l375;
    reg  [ 7:0] ram_symbol0 [0:65535];
    reg  [ 7:0] ram_symbol1 [0:65535];
    reg  [ 7:0] ram_symbol2 [0:65535];
    reg  [ 7:0] ram_symbol3 [0:65535];
    reg  [ 7:0] _zz_ramsymbol_read;
    reg  [ 7:0] _zz_ramsymbol_read_1;
    reg  [ 7:0] _zz_ramsymbol_read_2;
    reg  [ 7:0] _zz_ramsymbol_read_3;

    assign _zz_Axi4Incr_alignMask  = {(2'b01 < Axi4Incr_validSize), (2'b00 < Axi4Incr_validSize)};
    assign _zz_Axi4Incr_baseIncr   = {9'd0, Axi4Incr_sizeValue};
    assign _zz_Axi4Incr_wrapCase_1 = {1'd0, Axi4Incr_validSize};
    assign _zz_Axi4Incr_wrapCase_2 = {1'd0, _zz_Axi4Incr_wrapCase};
    assign _zz_Axi4Incr_result_1   = Axi4Incr_base[11:1];
    assign _zz_Axi4Incr_result_2   = Axi4Incr_baseIncr[0:0];
    assign _zz_Axi4Incr_result_3   = Axi4Incr_base[11:2];
    assign _zz_Axi4Incr_result_4   = Axi4Incr_baseIncr[1:0];
    assign _zz_Axi4Incr_result_5   = Axi4Incr_base[11:3];
    assign _zz_Axi4Incr_result_6   = Axi4Incr_baseIncr[2:0];
    assign _zz_Axi4Incr_result_7   = Axi4Incr_base[11:4];
    assign _zz_Axi4Incr_result_8   = Axi4Incr_baseIncr[3:0];
    assign _zz_Axi4Incr_result_9   = Axi4Incr_base[11:5];
    assign _zz_Axi4Incr_result_10  = Axi4Incr_baseIncr[4:0];
    assign _zz_Axi4Incr_result_11  = Axi4Incr_base[11:6];
    assign _zz_Axi4Incr_result_12  = Axi4Incr_baseIncr[5:0];
//    initial begin
//        $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram0.bin", ram_symbol0);
//        $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram1.bin", ram_symbol1);
//        $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram2.bin", ram_symbol2);
//        $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/tool/ram3.bin", ram_symbol3);
//    end
    always @(*) begin
        ram_spinal_port0 = {
            _zz_ramsymbol_read_3, _zz_ramsymbol_read_2, _zz_ramsymbol_read_1, _zz_ramsymbol_read
        };
    end
    always @(posedge io_axiClk) begin
        if (stage0_fire && ~stage0_payload_fragment_write) begin
            _zz_ramsymbol_read   <= ram_symbol0[_zz_io_axi_r_payload_data];
            _zz_ramsymbol_read_1 <= ram_symbol1[_zz_io_axi_r_payload_data];
            _zz_ramsymbol_read_2 <= ram_symbol2[_zz_io_axi_r_payload_data];
            _zz_ramsymbol_read_3 <= ram_symbol3[_zz_io_axi_r_payload_data];
        end
    end

    always @(posedge io_axiClk) begin
        if (io_axi_w_payload_strb[0] && stage0_fire && stage0_payload_fragment_write) begin
            ram_symbol0[_zz_io_axi_r_payload_data] <= _zz_io_axi_r_payload_data_1[7:0];
        end
        if (io_axi_w_payload_strb[1] && stage0_fire && stage0_payload_fragment_write) begin
            ram_symbol1[_zz_io_axi_r_payload_data] <= _zz_io_axi_r_payload_data_1[15:8];
        end
        if (io_axi_w_payload_strb[2] && stage0_fire && stage0_payload_fragment_write) begin
            ram_symbol2[_zz_io_axi_r_payload_data] <= _zz_io_axi_r_payload_data_1[23:16];
        end
        if (io_axi_w_payload_strb[3] && stage0_fire && stage0_payload_fragment_write) begin
            ram_symbol3[_zz_io_axi_r_payload_data] <= _zz_io_axi_r_payload_data_1[31:24];
        end
    end

    always @(*) begin
        case (Axi4Incr_wrapCase)
            3'b000:  _zz_Axi4Incr_result = {_zz_Axi4Incr_result_1, _zz_Axi4Incr_result_2};
            3'b001:  _zz_Axi4Incr_result = {_zz_Axi4Incr_result_3, _zz_Axi4Incr_result_4};
            3'b010:  _zz_Axi4Incr_result = {_zz_Axi4Incr_result_5, _zz_Axi4Incr_result_6};
            3'b011:  _zz_Axi4Incr_result = {_zz_Axi4Incr_result_7, _zz_Axi4Incr_result_8};
            3'b100:  _zz_Axi4Incr_result = {_zz_Axi4Incr_result_9, _zz_Axi4Incr_result_10};
            default: _zz_Axi4Incr_result = {_zz_Axi4Incr_result_11, _zz_Axi4Incr_result_12};
        endcase
    end

    assign unburstify_buffer_last = (unburstify_buffer_beat == 8'h01);
    assign Axi4Incr_validSize = unburstify_buffer_transaction_size[1:0];
    assign Axi4Incr_highCat = unburstify_buffer_transaction_addr[17:12];
    assign Axi4Incr_sizeValue = {
        (2'b10 == Axi4Incr_validSize),
        {(2'b01 == Axi4Incr_validSize), (2'b00 == Axi4Incr_validSize)}
    };
    assign Axi4Incr_alignMask = {10'd0, _zz_Axi4Incr_alignMask};
    assign Axi4Incr_base = (unburstify_buffer_transaction_addr[11:0] & (~Axi4Incr_alignMask));
    assign Axi4Incr_baseIncr = (Axi4Incr_base + _zz_Axi4Incr_baseIncr);
    always @(*) begin
        casez (unburstify_buffer_len)
            8'b????1???: begin
                _zz_Axi4Incr_wrapCase = 2'b11;
            end
            8'b????01??: begin
                _zz_Axi4Incr_wrapCase = 2'b10;
            end
            8'b????001?: begin
                _zz_Axi4Incr_wrapCase = 2'b01;
            end
            default: begin
                _zz_Axi4Incr_wrapCase = 2'b00;
            end
        endcase
    end

    assign Axi4Incr_wrapCase = (_zz_Axi4Incr_wrapCase_1 + _zz_Axi4Incr_wrapCase_2);
    always @(*) begin
        case (unburstify_buffer_transaction_burst)
            2'b00: begin
                Axi4Incr_result = unburstify_buffer_transaction_addr;
            end
            2'b10: begin
                Axi4Incr_result = {Axi4Incr_highCat, _zz_Axi4Incr_result};
            end
            default: begin
                Axi4Incr_result = {Axi4Incr_highCat, Axi4Incr_baseIncr};
            end
        endcase
    end

    always @(*) begin
        io_axi_arw_ready = 1'b0;
        if (!unburstify_buffer_valid) begin
            io_axi_arw_ready = unburstify_result_ready;
        end
    end

    always @(*) begin
        if (unburstify_buffer_valid) begin
            unburstify_result_valid = 1'b1;
        end else begin
            unburstify_result_valid = io_axi_arw_valid;
        end
    end

    always @(*) begin
        if (unburstify_buffer_valid) begin
            unburstify_result_payload_last = unburstify_buffer_last;
        end else begin
            unburstify_result_payload_last = 1'b1;
            if (when_Axi4Channel_l322) begin
                unburstify_result_payload_last = 1'b0;
            end
        end
    end

    always @(*) begin
        if (unburstify_buffer_valid) begin
            unburstify_result_payload_fragment_id = unburstify_buffer_transaction_id;
        end else begin
            unburstify_result_payload_fragment_id = io_axi_arw_payload_id;
        end
    end

    always @(*) begin
        if (unburstify_buffer_valid) begin
            unburstify_result_payload_fragment_size = unburstify_buffer_transaction_size;
        end else begin
            unburstify_result_payload_fragment_size = io_axi_arw_payload_size;
        end
    end

    always @(*) begin
        if (unburstify_buffer_valid) begin
            unburstify_result_payload_fragment_burst = unburstify_buffer_transaction_burst;
        end else begin
            unburstify_result_payload_fragment_burst = io_axi_arw_payload_burst;
        end
    end

    always @(*) begin
        if (unburstify_buffer_valid) begin
            unburstify_result_payload_fragment_write = unburstify_buffer_transaction_write;
        end else begin
            unburstify_result_payload_fragment_write = io_axi_arw_payload_write;
        end
    end

    always @(*) begin
        if (unburstify_buffer_valid) begin
            unburstify_result_payload_fragment_addr = Axi4Incr_result;
        end else begin
            unburstify_result_payload_fragment_addr = io_axi_arw_payload_addr;
        end
    end

    assign when_Axi4Channel_l322 = (io_axi_arw_payload_len != 8'h0);
    assign _zz_unburstify_result_ready = (! (unburstify_result_payload_fragment_write && (! io_axi_w_valid)));
    assign stage0_valid = (unburstify_result_valid && _zz_unburstify_result_ready);
    assign unburstify_result_ready = (stage0_ready && _zz_unburstify_result_ready);
    assign stage0_payload_last = unburstify_result_payload_last;
    assign stage0_payload_fragment_addr = unburstify_result_payload_fragment_addr;
    assign stage0_payload_fragment_id = unburstify_result_payload_fragment_id;
    assign stage0_payload_fragment_size = unburstify_result_payload_fragment_size;
    assign stage0_payload_fragment_burst = unburstify_result_payload_fragment_burst;
    assign stage0_payload_fragment_write = unburstify_result_payload_fragment_write;
    assign _zz_io_axi_r_payload_data = stage0_payload_fragment_addr[17:2];
    assign stage0_fire = (stage0_valid && stage0_ready);
    assign _zz_io_axi_r_payload_data_1 = io_axi_w_payload_data;
    assign io_axi_r_payload_data = ram_spinal_port0;
    assign io_axi_w_ready = ((unburstify_result_valid && unburstify_result_payload_fragment_write) && stage0_ready);
    always @(*) begin
        stage0_ready = stage1_ready;
        if (when_Stream_l375) begin
            stage0_ready = 1'b1;
        end
    end

    assign when_Stream_l375 = (!stage1_valid);
    assign stage1_valid = stage0_rValid;
    assign stage1_payload_last = stage0_rData_last;
    assign stage1_payload_fragment_addr = stage0_rData_fragment_addr;
    assign stage1_payload_fragment_id = stage0_rData_fragment_id;
    assign stage1_payload_fragment_size = stage0_rData_fragment_size;
    assign stage1_payload_fragment_burst = stage0_rData_fragment_burst;
    assign stage1_payload_fragment_write = stage0_rData_fragment_write;
    assign stage1_ready = ((io_axi_r_ready && (! stage1_payload_fragment_write)) || ((io_axi_b_ready || (! stage1_payload_last)) && stage1_payload_fragment_write));
    assign io_axi_r_valid = (stage1_valid && (!stage1_payload_fragment_write));
    assign io_axi_r_payload_id = stage1_payload_fragment_id;
    assign io_axi_r_payload_last = stage1_payload_last;
    assign io_axi_r_payload_resp = 2'b00;
    assign io_axi_b_valid = ((stage1_valid && stage1_payload_fragment_write) && stage1_payload_last);
    assign io_axi_b_payload_resp = 2'b00;
    assign io_axi_b_payload_id = stage1_payload_fragment_id;
    always @(posedge io_axiClk or posedge resetCtrl_axiReset) begin
        if (resetCtrl_axiReset) begin
            unburstify_buffer_valid <= 1'b0;
            stage0_rValid <= 1'b0;
        end else begin
            if (unburstify_result_ready) begin
                if (unburstify_buffer_last) begin
                    unburstify_buffer_valid <= 1'b0;
                end
            end
            if (!unburstify_buffer_valid) begin
                if (when_Axi4Channel_l322) begin
                    if (unburstify_result_ready) begin
                        unburstify_buffer_valid <= io_axi_arw_valid;
                    end
                end
            end
            if (stage0_ready) begin
                stage0_rValid <= stage0_valid;
            end
        end
    end

    always @(posedge io_axiClk) begin
        if (unburstify_result_ready) begin
            unburstify_buffer_beat <= (unburstify_buffer_beat - 8'h01);
            unburstify_buffer_transaction_addr[11:0] <= Axi4Incr_result[11:0];
        end
        if (!unburstify_buffer_valid) begin
            if (when_Axi4Channel_l322) begin
                if (unburstify_result_ready) begin
                    unburstify_buffer_transaction_addr <= io_axi_arw_payload_addr;
                    unburstify_buffer_transaction_id <= io_axi_arw_payload_id;
                    unburstify_buffer_transaction_size <= io_axi_arw_payload_size;
                    unburstify_buffer_transaction_burst <= io_axi_arw_payload_burst;
                    unburstify_buffer_transaction_write <= io_axi_arw_payload_write;
                    unburstify_buffer_beat <= io_axi_arw_payload_len;
                    unburstify_buffer_len <= io_axi_arw_payload_len;
                end
            end
        end
        if (stage0_ready) begin
            stage0_rData_last <= stage0_payload_last;
            stage0_rData_fragment_addr <= stage0_payload_fragment_addr;
            stage0_rData_fragment_id <= stage0_payload_fragment_id;
            stage0_rData_fragment_size <= stage0_payload_fragment_size;
            stage0_rData_fragment_burst <= stage0_payload_fragment_burst;
            stage0_rData_fragment_write <= stage0_payload_fragment_write;
        end
    end

endmodule
