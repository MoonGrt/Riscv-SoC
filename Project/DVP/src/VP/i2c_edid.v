`timescale 1ns / 1ps

module i2c_edid (
    input wire clk,
    input wire rst,
    inout wire scl,
    inout wire sda
);

    //parameter define
    parameter EDID_IDLE = 3'b000;
    parameter EDID_ADDR = 3'b001;
    parameter EDID_ADDR_ACK = 3'b010;
    parameter EDID_ADDR_ACK2 = 3'b011;
    parameter EDID_DATA = 3'b100;
    parameter EDID_DATA_ACK = 3'b101;
    parameter EDID_DATA_ACK2 = 3'b110;

    // reg define
    reg         hiz;
    reg         sda_out;
    reg  [ 4:0] count;
    reg  [15:0] rdata;
    reg  [ 7:0] addr;
    reg  [ 7:0] data;
    reg  [ 2:0] edid_state;
    reg  [ 3:0] scl_data;
    reg  [ 3:0] sda_data;

    // wire define
    wire [ 7:0] dout;
    wire        scl_high;
    wire        scl_negedge;
    wire        scl_posedge;

    //*****************************************************
    //**                    main code
    //*****************************************************

    // 取IIC时钟的上升沿
    assign scl_posedge = (scl_data == 4'b0111) ? 1'b1 : 1'b0;
    // 取IIC时钟的下降沿
    assign scl_negedge = (scl_data == 4'b1000) ? 1'b1 : 1'b0;
    // IIC时钟的全高电平
    assign scl_high    = (scl_data == 4'b1111) ? 1'b1 : 1'b0;
    // IIC数据的三态输出
    assign sda = hiz ? 1'hz : sda_out;

    // 存储edid信息
    // edid_rom edid_rom_0 (
    //     .addra(addr[7:0]),
    //     .clka (clk),
    //     .douta(dout)
    // );
    reg [7:0] edid_rom [0:255];
    initial $readmemh("F:/Project/Sipeed/FPGA/Tang_Mega/Riscv-SoC/Project/DVP/src/VP/edid.mem", edid_rom);
    assign dout = edid_rom[addr];

    always @(posedge clk) begin
        if (rst) begin
            hiz <= 1'b1;
            sda_out <= 1'b0;
            count <= 5'd0;
            rdata <= 24'h0;
            addr <= 8'h0;
            data <= 8'h0;
            scl_data <= 4'h00;
            sda_data <= 4'h00;
        end else begin
            scl_data <= {scl_data[2:0], scl};
            sda_data <= {sda_data[2:0], sda};

            if (sda_data == 4'b1000 && scl_high) begin  // iic开始的标志
                count <= 5'd0;
                hiz <= 1'b1;
                sda_out <= 1'b0;
                edid_state <= EDID_ADDR;
            end else if (sda_data == 4'b0111 && scl_high) begin  // iic结束的标志
                edid_state <= EDID_IDLE;
            end else
                case (edid_state)
                    EDID_IDLE: begin
                        hiz <= 1'b1;
                        sda_out <= 1'b0;
                    end
                    EDID_ADDR: begin
                        if (scl_posedge) begin
                            count <= count + 5'd1;
                            rdata <= {rdata[14:0], sda};
                            if (count[2:0] == 3'd7) begin  // 器件地址写完
                                edid_state <= EDID_ADDR_ACK;
                                if (count == 5'd15)  // 字地址写完
                                    addr <= {rdata[6:0], sda};  // 将字地址赋给ROM地址
                                else addr <= addr;
                            end
                        end
                    end
                    EDID_ADDR_ACK: begin
                        if (scl_negedge) begin
                            hiz <= 1'b0;
                            sda_out <= 1'b0;
                            if (count == 5'd8 && rdata[0] == 1'b1) begin  // 判断是否是读操作
                                data <= dout;
                                edid_state <= EDID_DATA;
                            end else begin
                                edid_state <= EDID_ADDR_ACK2;
                            end
                        end
                    end
                    EDID_ADDR_ACK2: begin
                        if (scl_negedge) begin
                            hiz        <= 1'b1;  // 释放总线
                            edid_state <= EDID_ADDR;
                        end
                    end
                    EDID_DATA: begin
                        if (scl_negedge) begin
                            count <= count + 5'd1;
                            hiz <= 1'b0;
                            sda_out <= data[7];
                            data <= {data[6:0], 1'b0};     // 数据移位
                            if (count[2:0] == 3'd7) begin  // 一个数据读完
                                addr       <= addr + 8'h1;  // rom地址加1
                                edid_state <= EDID_DATA_ACK;
                            end
                        end
                    end
                    EDID_DATA_ACK: begin
                        if (scl_negedge) begin
                            data       <= dout;
                            hiz        <= 1'b1;  // 释放总线
                            sda_out    <= 1'b0;
                            edid_state <= EDID_DATA_ACK2;
                        end
                    end
                    EDID_DATA_ACK2: begin
                        if (scl_posedge) begin
                            if (sda)  // 数据为1，读操作结束，为0，未结束
                                edid_state <= EDID_IDLE;
                            else edid_state <= EDID_DATA;
                        end
                    end
                endcase
        end
    end

endmodule
