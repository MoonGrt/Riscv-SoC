`timescale 1ns / 1ps

module MuraxPipelinedMemoryBusRam (
    input  wire        io_bus_cmd_valid,
    output wire        io_bus_cmd_ready,
    input  wire        io_bus_cmd_payload_write,
    input  wire [31:0] io_bus_cmd_payload_address,
    input  wire [31:0] io_bus_cmd_payload_data,
    input  wire [ 3:0] io_bus_cmd_payload_mask,
    output wire        io_bus_rsp_valid,
    output wire [31:0] io_bus_rsp_payload_data,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    reg  [31:0] ram_spinal_port0;
    wire [ 9:0] _zz_ram_port;
    wire [ 9:0] _zz_io_bus_rsp_payload_data_2;
    wire        io_bus_cmd_fire;
    reg         _zz_io_bus_rsp_valid;
    wire [29:0] _zz_io_bus_rsp_payload_data;
    wire [31:0] _zz_io_bus_rsp_payload_data_1;
    reg  [ 7:0] ram_symbol0 [0:1023];
    reg  [ 7:0] ram_symbol1 [0:1023];
    reg  [ 7:0] ram_symbol2 [0:1023];
    reg  [ 7:0] ram_symbol3 [0:1023];
    reg  [ 7:0] _zz_ramsymbol_read;
    reg  [ 7:0] _zz_ramsymbol_read_1;
    reg  [ 7:0] _zz_ramsymbol_read_2;
    reg  [ 7:0] _zz_ramsymbol_read_3;

    assign _zz_io_bus_rsp_payload_data_2 = _zz_io_bus_rsp_payload_data[9:0];
    initial begin
        $readmemb("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/test/test.srcs/src/ram/Murax.v_toplevel_system_ram_ram_symbol0.bin",ram_symbol0);
        $readmemb("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/test/test.srcs/src/ram/Murax.v_toplevel_system_ram_ram_symbol1.bin",ram_symbol1);
        $readmemb("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/test/test.srcs/src/ram/Murax.v_toplevel_system_ram_ram_symbol2.bin",ram_symbol2);
        $readmemb("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/test/test.srcs/src/ram/Murax.v_toplevel_system_ram_ram_symbol3.bin",ram_symbol3);
    end
    always @(*) begin
        ram_spinal_port0 = {
            _zz_ramsymbol_read_3, _zz_ramsymbol_read_2, _zz_ramsymbol_read_1, _zz_ramsymbol_read
        };
    end
    always @(posedge io_mainClk) begin
        if (io_bus_cmd_valid) begin
            _zz_ramsymbol_read   <= ram_symbol0[_zz_io_bus_rsp_payload_data_2];
            _zz_ramsymbol_read_1 <= ram_symbol1[_zz_io_bus_rsp_payload_data_2];
            _zz_ramsymbol_read_2 <= ram_symbol2[_zz_io_bus_rsp_payload_data_2];
            _zz_ramsymbol_read_3 <= ram_symbol3[_zz_io_bus_rsp_payload_data_2];
        end
    end

    always @(posedge io_mainClk) begin
        if (io_bus_cmd_payload_mask[0] && io_bus_cmd_valid && io_bus_cmd_payload_write) begin
            ram_symbol0[_zz_io_bus_rsp_payload_data_2] <= _zz_io_bus_rsp_payload_data_1[7 : 0];
        end
        if (io_bus_cmd_payload_mask[1] && io_bus_cmd_valid && io_bus_cmd_payload_write) begin
            ram_symbol1[_zz_io_bus_rsp_payload_data_2] <= _zz_io_bus_rsp_payload_data_1[15 : 8];
        end
        if (io_bus_cmd_payload_mask[2] && io_bus_cmd_valid && io_bus_cmd_payload_write) begin
            ram_symbol2[_zz_io_bus_rsp_payload_data_2] <= _zz_io_bus_rsp_payload_data_1[23 : 16];
        end
        if (io_bus_cmd_payload_mask[3] && io_bus_cmd_valid && io_bus_cmd_payload_write) begin
            ram_symbol3[_zz_io_bus_rsp_payload_data_2] <= _zz_io_bus_rsp_payload_data_1[31 : 24];
        end
    end

    assign io_bus_cmd_fire = (io_bus_cmd_valid && io_bus_cmd_ready);
    assign io_bus_rsp_valid = _zz_io_bus_rsp_valid;
    assign _zz_io_bus_rsp_payload_data = (io_bus_cmd_payload_address >>> 2'd2);
    assign _zz_io_bus_rsp_payload_data_1 = io_bus_cmd_payload_data;
    assign io_bus_rsp_payload_data = ram_spinal_port0;
    assign io_bus_cmd_ready = 1'b1;
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            _zz_io_bus_rsp_valid <= 1'b0;
        end else begin
            _zz_io_bus_rsp_valid <= (io_bus_cmd_fire && (!io_bus_cmd_payload_write));
        end
    end

endmodule
