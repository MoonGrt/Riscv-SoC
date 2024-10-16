`timescale 1ns / 1ps

module SPICtrl (
    // Control / Data Signals
    input clk,  // FPGA Clock
    input rst,  // FPGA Reset

    // SPI Config Signals
    input       CPOL,     // Clock Polarity
    input       CPHA,     // Clock Phase
    input [2:0] BR,       // Baud Rate
    input       DFF,      // Data Frame Format
    input       LSBFIRST, // Bit First Config

    // TX (MOSI) Signals
    input      [15:0] i_TX_Byte,   // Byte to transmit on MOSI
    input             i_TX_Vaild,  // Data Valid Pulse with i_TX_Byte
    output reg        o_TX_Ready,  // Transmit Ready for next byte

    // RX (MISO) Signals
    output reg        o_RX_Vaild,  // Data Valid pulse (1 clock cycle)
    output reg [15:0] o_RX_Byte,   // Byte received on MISO

    // SPI Interface
    output reg o_SPI_SCK,
    input      i_SPI_MISO,
    output reg o_SPI_MOSI,
    output reg o_SPI_CS
);

    // CPOL: Clock Polarity
    // CPOL=0 means clock idles at 0, leading edge is rising edge.
    // CPOL=1 means clock idles at 1, leading edge is falling edge.
    // CPHA: Clock Phase
    // CPHA=0 means the "out" side changes the data on trailing edge of clock
    //              the "in" side captures data on leading edge of clock
    // CPHA=1 means the "out" side changes the data on leading edge of clock
    //              the "in" side captures data on the trailing edge of clock

    // SPI Interface (All Runs at SPI Clock Domain)
    reg [7:0] r_SPI_clk_Count, HALF_BIT;  // 000:2 001:4 010:8 011:16 100:32 101:64 110:128 111:256
    reg        r_SPI_clk;
    reg [ 4:0] r_SPI_clk_Edges;
    reg        r_Leading_Edge;
    reg        r_Trailing_Edge;
    reg        r_TX_DV;
    reg [15:0] r_TX_Byte;
    reg [ 3:0] r_RX_Bit_Count;
    reg [ 3:0] r_TX_Bit_Count;

    // HALF_BIT: Number of clock cycles for half bit time.
    always @* begin
        case (BR)
            3'b000: HALF_BIT = 8'b00000001;
            3'b001: HALF_BIT = 8'b00000010;
            3'b010: HALF_BIT = 8'b00000100;
            3'b011: HALF_BIT = 8'b00001000;
            3'b100: HALF_BIT = 8'b00010000;
            3'b101: HALF_BIT = 8'b00100000;
            3'b110: HALF_BIT = 8'b01000000;
            3'b111: HALF_BIT = 8'b10000000;
        endcase
    end

    // Purpose: Generate SPI Clock correct number of times when DV pulse comes
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_TX_Ready      <= 1'b0;
            r_SPI_clk_Edges <= 0;
            r_Leading_Edge  <= 1'b0;
            r_Trailing_Edge <= 1'b0;
            r_SPI_clk       <= CPOL;  // assign default state to idle state
            r_SPI_clk_Count <= 0;
        end else begin
            // Default assignments
            r_Leading_Edge  <= 1'b0;
            r_Trailing_Edge <= 1'b0;
            if (i_TX_Vaild) begin
                o_TX_Ready      <= 1'b0;
                r_SPI_clk_Edges <= 16;  // Total # edges in one byte ALWAYS 16
            end else if (r_SPI_clk_Edges > 0) begin
                o_TX_Ready <= 1'b0;
                if (r_SPI_clk_Count == HALF_BIT * 2 - 1) begin
                    r_SPI_clk_Edges <= r_SPI_clk_Edges - 1'b1;
                    r_Trailing_Edge <= 1'b1;
                    r_SPI_clk_Count <= 0;
                    r_SPI_clk       <= ~r_SPI_clk;
                end else if (r_SPI_clk_Count == HALF_BIT - 1) begin
                    r_SPI_clk_Edges <= r_SPI_clk_Edges - 1'b1;
                    r_Leading_Edge  <= 1'b1;
                    r_SPI_clk_Count <= r_SPI_clk_Count + 1'b1;
                    r_SPI_clk       <= ~r_SPI_clk;
                end else begin
                    r_SPI_clk_Count <= r_SPI_clk_Count + 1'b1;
                end
            end else o_TX_Ready <= 1'b1;
        end
    end

    // Purpose: Register i_TX_Byte when Data Valid is pulsed.
    // Keeps local storage of byte in case higher level module changes the data
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_TX_Byte <= 16'h0000;
            r_TX_DV   <= 1'b0;
        end else begin
            r_TX_DV <= i_TX_Vaild;  // 1 clock cycle delay
            if (i_TX_Vaild) r_TX_Byte <= i_TX_Byte;
        end  // else: !if(~rst_n)
    end  // always @ (posedge clk or negedge rst_n)

    // Purpose: Generate MOSI data
    // Works with both CPHA=0 and CPHA=1
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_SPI_MOSI <= 1'b0;
            if (LSBFIRST) r_TX_Bit_Count <= 4'b0000;  // send LSB first
            else r_TX_Bit_Count <= DFF ? 4'b1111 : 4'b0111;  // send MSB first  // 16位 : 8位
        end else begin
            // If ready is high, reset bit counts to default
            if (o_TX_Ready) begin
                if (LSBFIRST) r_TX_Bit_Count <= 4'b0000;  // send LSB first
                else r_TX_Bit_Count <= DFF ? 4'b1111 : 4'b0111;  // send MSB first
            end else if (r_TX_DV & ~CPHA) begin
                o_SPI_MOSI     <= r_TX_Byte[r_TX_Bit_Count];
                r_TX_Bit_Count <= LSBFIRST ? r_TX_Bit_Count + 1'b1 : r_TX_Bit_Count - 1'b1;
            end else if ((r_Leading_Edge & CPHA) | (r_Trailing_Edge & ~CPHA)) begin
                r_TX_Bit_Count <= LSBFIRST ? r_TX_Bit_Count + 1'b1 : r_TX_Bit_Count - 1'b1;
                o_SPI_MOSI     <= r_TX_Byte[r_TX_Bit_Count];
            end
        end
    end

    // Purpose: Read in MISO data.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_RX_Byte  <= 8'h00;
            o_RX_Vaild <= 1'b0;
            if (LSBFIRST) r_RX_Bit_Count <= 4'b0000;  // recv LSB first
            else r_RX_Bit_Count <= DFF ? 4'b1111 : 4'b0111;  // recv MSB first  // 16位 : 8位
        end else begin
            // Default Assignments
            o_RX_Vaild <= 1'b0;
            if (o_TX_Ready) begin  // Check if ready is high, if so reset bit count to default
                if (LSBFIRST) r_RX_Bit_Count <= 4'b0000;  // recv LSB first
                else r_RX_Bit_Count <= DFF ? 4'b1111 : 4'b0111;  // recv MSB first  // 16位 : 8位
            end else if ((r_Leading_Edge & ~CPHA) | (r_Trailing_Edge & CPHA)) begin
                o_RX_Byte[r_RX_Bit_Count] <= i_SPI_MISO;  // Sample data
                r_RX_Bit_Count <= LSBFIRST ? r_RX_Bit_Count + 1'b1 : r_RX_Bit_Count - 1'b1;
                o_RX_Vaild <= LSBFIRST ? (DFF ? 4'b1111 : 4'b0111) : 4'b0000;  // Byte done, pulse Data Valid
            end
        end
    end

    // Purpose: Add clock delay to signals for alignment.
    always @(posedge clk or posedge rst) begin
        if (rst) o_SPI_SCK <= CPOL;
        else o_SPI_SCK <= r_SPI_clk;
    end

endmodule  // SPI_Master
