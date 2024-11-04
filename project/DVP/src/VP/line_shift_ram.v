module line_shift_ram #(
    parameter DATA_WIDTH  = 8,    // 数据宽度，默认为8位
    parameter LINE_LENGTH = 1280  // 行长度，默认为1280个像素
) (
    input  wire                  clk,    // 时钟信号
    input  wire                  rst_n,  // 复位信号
    input  wire                  CE,     // 使能信号
    input  wire [DATA_WIDTH-1:0] D,      // 输入数据
    output reg  [DATA_WIDTH-1:0] Q       // 输出数据
);

    // 内部存储器，存储一整行像素数据
    reg [DATA_WIDTH-1:0] line_ram[LINE_LENGTH-1:0];
    integer i;
    initial begin
        for (i = 0; i < LINE_LENGTH; i = i + 1)
            line_ram[i] = {DATA_WIDTH{1'b0}};  // 将所有位设置为0
    end

    // 读写指针，用来指示当前操作的地址
    reg [$clog2(LINE_LENGTH)-1:0] wr_ptr = 0;
    reg [$clog2(LINE_LENGTH)-1:0] rd_ptr = 0;  // 开始时，读指针与写指针相同

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位时，读写指针都置为0
            wr_ptr <= 0;
            rd_ptr <= 0;
            Q <= 0;  // 输出数据复位
        end else if (CE) begin
            // 写入新数据到当前写指针指向的位置
            line_ram[wr_ptr] <= D;
            // 更新写指针
            wr_ptr <= (wr_ptr + 1) % LINE_LENGTH;
            // 读取当前读指针指向的数据
            Q <= line_ram[rd_ptr];
            // 更新读指针
            rd_ptr <= (rd_ptr + 1) % LINE_LENGTH;
        end
    end

endmodule
