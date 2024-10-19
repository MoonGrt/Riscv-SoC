`timescale 1ns / 1ps

module StreamFifo_UART (
    input  wire       io_push_valid,
    output wire       io_push_ready,
    input  wire [7:0] io_push_payload,
    output wire       io_pop_valid,
    input  wire       io_pop_ready,
    output wire [7:0] io_pop_payload,
    input  wire       io_flush,
    output wire [4:0] io_occupancy,
    output wire [4:0] io_availability,
    input  wire       io_mainClk,
    input  wire       resetCtrl_systemReset
);

    reg  [7:0] logic_ram_spinal_port1;
    reg        _zz_1;
    wire       logic_ptr_doPush;
    wire       logic_ptr_doPop;
    wire       logic_ptr_full;
    wire       logic_ptr_empty;
    reg  [4:0] logic_ptr_push;
    reg  [4:0] logic_ptr_pop;
    wire [4:0] logic_ptr_occupancy;
    wire [4:0] logic_ptr_popOnIo;
    wire       when_Stream_l1248;
    reg        logic_ptr_wentUp;
    wire       io_push_fire;
    wire       logic_push_onRam_write_valid;
    wire [3:0] logic_push_onRam_write_payload_address;
    wire [7:0] logic_push_onRam_write_payload_data;
    wire       logic_pop_addressGen_valid;
    reg        logic_pop_addressGen_ready;
    wire [3:0] logic_pop_addressGen_payload;
    wire       logic_pop_addressGen_fire;
    wire       logic_pop_sync_readArbitation_valid;
    wire       logic_pop_sync_readArbitation_ready;
    wire [3:0] logic_pop_sync_readArbitation_payload;
    reg        logic_pop_addressGen_rValid;
    reg  [3:0] logic_pop_addressGen_rData;
    wire       when_Stream_l375;
    wire       logic_pop_sync_readPort_cmd_valid;
    wire [3:0] logic_pop_sync_readPort_cmd_payload;
    wire [7:0] logic_pop_sync_readPort_rsp;
    wire       logic_pop_sync_readArbitation_translated_valid;
    wire       logic_pop_sync_readArbitation_translated_ready;
    wire [7:0] logic_pop_sync_readArbitation_translated_payload;
    wire       logic_pop_sync_readArbitation_fire;
    reg  [4:0] logic_pop_sync_popReg;
    reg  [7:0] logic_ram[0:15];

    always @(posedge io_mainClk) begin
        if (_zz_1) begin
            logic_ram[logic_push_onRam_write_payload_address] <= logic_push_onRam_write_payload_data;
        end
    end

    always @(posedge io_mainClk) begin
        if (logic_pop_sync_readPort_cmd_valid) begin
            logic_ram_spinal_port1 <= logic_ram[logic_pop_sync_readPort_cmd_payload];
        end
    end

    always @(*) begin
        _zz_1 = 1'b0;
        if (logic_push_onRam_write_valid) begin
            _zz_1 = 1'b1;
        end
    end

    assign when_Stream_l1248 = (logic_ptr_doPush != logic_ptr_doPop);
    assign logic_ptr_full = (((logic_ptr_push ^ logic_ptr_popOnIo) ^ 5'h10) == 5'h0);
    assign logic_ptr_empty = (logic_ptr_push == logic_ptr_pop);
    assign logic_ptr_occupancy = (logic_ptr_push - logic_ptr_popOnIo);
    assign io_push_ready = (!logic_ptr_full);
    assign io_push_fire = (io_push_valid && io_push_ready);
    assign logic_ptr_doPush = io_push_fire;
    assign logic_push_onRam_write_valid = io_push_fire;
    assign logic_push_onRam_write_payload_address = logic_ptr_push[3:0];
    assign logic_push_onRam_write_payload_data = io_push_payload;
    assign logic_pop_addressGen_valid = (!logic_ptr_empty);
    assign logic_pop_addressGen_payload = logic_ptr_pop[3:0];
    assign logic_pop_addressGen_fire = (logic_pop_addressGen_valid && logic_pop_addressGen_ready);
    assign logic_ptr_doPop = logic_pop_addressGen_fire;
    always @(*) begin
        logic_pop_addressGen_ready = logic_pop_sync_readArbitation_ready;
        if (when_Stream_l375) begin
            logic_pop_addressGen_ready = 1'b1;
        end
    end

    assign when_Stream_l375 = (!logic_pop_sync_readArbitation_valid);
    assign logic_pop_sync_readArbitation_valid = logic_pop_addressGen_rValid;
    assign logic_pop_sync_readArbitation_payload = logic_pop_addressGen_rData;
    assign logic_pop_sync_readPort_rsp = logic_ram_spinal_port1;
    assign logic_pop_sync_readPort_cmd_valid = logic_pop_addressGen_fire;
    assign logic_pop_sync_readPort_cmd_payload = logic_pop_addressGen_payload;
    assign logic_pop_sync_readArbitation_translated_valid = logic_pop_sync_readArbitation_valid;
    assign logic_pop_sync_readArbitation_ready = logic_pop_sync_readArbitation_translated_ready;
    assign logic_pop_sync_readArbitation_translated_payload = logic_pop_sync_readPort_rsp;
    assign io_pop_valid = logic_pop_sync_readArbitation_translated_valid;
    assign logic_pop_sync_readArbitation_translated_ready = io_pop_ready;
    assign io_pop_payload = logic_pop_sync_readArbitation_translated_payload;
    assign logic_pop_sync_readArbitation_fire = (logic_pop_sync_readArbitation_valid && logic_pop_sync_readArbitation_ready);
    assign logic_ptr_popOnIo = logic_pop_sync_popReg;
    assign io_occupancy = logic_ptr_occupancy;
    assign io_availability = (5'h10 - logic_ptr_occupancy);
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            logic_ptr_push <= 5'h0;
            logic_ptr_pop <= 5'h0;
            logic_ptr_wentUp <= 1'b0;
            logic_pop_addressGen_rValid <= 1'b0;
            logic_pop_sync_popReg <= 5'h0;
        end else begin
            if (when_Stream_l1248) begin
                logic_ptr_wentUp <= logic_ptr_doPush;
            end
            if (io_flush) begin
                logic_ptr_wentUp <= 1'b0;
            end
            if (logic_ptr_doPush) begin
                logic_ptr_push <= (logic_ptr_push + 5'h01);
            end
            if (logic_ptr_doPop) begin
                logic_ptr_pop <= (logic_ptr_pop + 5'h01);
            end
            if (io_flush) begin
                logic_ptr_push <= 5'h0;
                logic_ptr_pop  <= 5'h0;
            end
            if (logic_pop_addressGen_ready) begin
                logic_pop_addressGen_rValid <= logic_pop_addressGen_valid;
            end
            if (io_flush) begin
                logic_pop_addressGen_rValid <= 1'b0;
            end
            if (logic_pop_sync_readArbitation_fire) begin
                logic_pop_sync_popReg <= logic_ptr_pop;
            end
            if (io_flush) begin
                logic_pop_sync_popReg <= 5'h0;
            end
        end
    end

    always @(posedge io_mainClk) begin
        if (logic_pop_addressGen_ready) begin
            logic_pop_addressGen_rData <= logic_pop_addressGen_payload;
        end
    end

endmodule
