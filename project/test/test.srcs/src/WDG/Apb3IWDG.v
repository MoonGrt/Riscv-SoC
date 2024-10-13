module IWDG (
    input  wire        io_apb_PCLK,     // APB 时钟
    input  wire        io_apb_PRESET,   // APB 复位信号，高电平复位
    input  wire [ 1:0] io_apb_PADDR,    // 地址总线
    input  wire        io_apb_PSEL,     // 选择信号
    input  wire        io_apb_PENABLE,  // 使能信号
    input  wire        io_apb_PWRITE,   // 写信号
    input  wire [31:0] io_apb_PWDATA,   // 写数据总线
    output wire        io_apb_PREADY,   // APB 准备信号
    output reg  [31:0] io_apb_PRDATA,   // 读数据总线

    output reg IWDG_rst  // 看门狗复位信号
);

    // IWDG寄存器定义
    reg [15:0] KR;  // Key register
    reg [ 2:0] PR;  // Prescaler register (假设使用 3 位预分频器)
    reg [11:0] RLR;  // Reload register (12 位)
    reg [ 1:0] SR;  // Status register (假设使用 2 位状态寄存器)

    // IWDG内部计数器和状态
    reg [31:0] counter, prescaler_counter;
    reg IWDG_en, write_en;

    // APB 写寄存器逻辑
    assign io_apb_PREADY = 1'b1;  // APB 准备信号始终为高，表示设备始终准备好
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            KR  <= 16'h0000;
            PR  <= 3'b000;
            RLR <= 12'hFFF;
        end else begin
            // APB 写操作
            KR <= 16'h0000;
            if (io_apb_PSEL && io_apb_PENABLE && io_apb_PWRITE) begin
                case (io_apb_PADDR)
                    2'b00:   KR <= io_apb_PWDATA[15:0];  // 写 Key register
                    2'b01:   PR <= io_apb_PWDATA[2:0];  // 写 Prescaler register
                    2'b10:   RLR <= io_apb_PWDATA[11:0];  // 写 Reload register
                    default: ;  // 其他寄存器不处理
                endcase
            end
        end
    end
    // APB 读寄存器逻辑
    always @(*) begin
        if (io_apb_PRESET) io_apb_PRDATA = 32'h00000000;
        else if (io_apb_PSEL && io_apb_PENABLE && ~io_apb_PWRITE) begin
            case (io_apb_PADDR)
                2'b00:   io_apb_PRDATA <= {16'b0, KR};  // 读 Key register
                2'b01:   io_apb_PRDATA <= {29'b0, PR};  // 读 Prescaler register
                2'b10:   io_apb_PRDATA <= {20'b0, RLR};  // 读 Reload register
                2'b11:   io_apb_PRDATA <= {30'b0, SR};  // 读 Status register
                default: io_apb_PRDATA <= 32'h00000000;
            endcase
        end
    end

    // 计数器和分频逻辑
    always @(posedge io_apb_PCLK or posedge io_apb_PRESET) begin
        if (io_apb_PRESET) begin
            counter <= 32'h00000000;
            IWDG_en <= 1'b0;
            IWDG_rst <= 1'b0;
            prescaler_counter <= 16'h0000;
            SR <= 2'b00;
        end else begin
            // 看门狗计时器启用条件
            case (KR)
                16'h5555: write_en <= 1'b1;  // 写使能
                16'h0000: write_en <= 1'b0;  // 写失能
                16'hAAAA: if (write_en) counter <= {20'b0, RLR};  // 重载计数器
                16'hCCCC: begin  // 看门狗使能
                    if (write_en) begin
                        IWDG_en <= 1'b1;
                        SR      <= 2'b00;  // 清除状态寄存器
                    end
                end
            endcase

            // 分频器计数逻辑
            if (IWDG_en) begin
                if (prescaler_counter == (1 << PR) - 1) begin
                    prescaler_counter <= 16'h0000;  // 分频计数器重置
                    if (counter > 0) begin
                        counter <= counter - 1;  // 分频后主计数器减少
                    end else begin
                        IWDG_rst <= 1'b1;  // 计数器达到 0 时发出复位信号
                        SR        <= 2'b01;  // 状态寄存器置位
                    end
                end else begin
                    prescaler_counter <= prescaler_counter + 1;  // 分频计数器增加
                end
            end
        end
    end

endmodule
