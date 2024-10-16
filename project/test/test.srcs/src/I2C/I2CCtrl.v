module I2CCtrl(
    input wire clk,               // 时钟信号
    input wire rst_n,             // 复位信号，低电平有效
    input wire start,             // 启动信号
    input wire [6:0] dev_addr,    // 从设备7位地址
    input wire [7:0] reg_addr,    // 寄存器地址
    input wire [7:0] data_in,     // 要写入的数据
    output reg sda,               // I2C数据线
    output reg scl,               // I2C时钟线
    output reg busy,              // 表示模块是否忙碌
    output reg done,              // 表示传输是否完成
    output reg [7:0] flags        // 标志位输出
);

    // 定义 I2C 状态机的状态
    typedef enum reg [3:0] {
        IDLE,         // 空闲状态
        START,        // 生成起始条件
        ADDR,         // 发送设备地址
        ADDR_ACK,     // 检查ADDR应答（ACK）
        REG_ADDR,     // 发送寄存器地址
        REG_ADDR_ACK, // 检查寄存器地址ACK
        DATA,         // 发送数据
        DATA_ACK,     // 检查数据ACK
        STOP,         // 生成停止条件
        DONE          // 完成状态
    } state_t;

    state_t state, next_state;

    // I2C 信号控制
    reg [7:0] bit_counter;        // 位计数器，用于跟踪发送的位数
    reg scl_out;                  // 用于驱动 SCL 的寄存器
    reg sda_out;                  // 用于驱动 SDA 的寄存器

    // I2C 时钟分频
    reg [15:0] clk_div;           // 时钟分频器，用于生成 SCL 时钟
    reg scl_enable;               // 控制 SCL 的时钟
    reg [7:0] flags_reg;          // 状态标志寄存器（模拟 STM32 中的标志）

    // 将 sda 和 scl 信号分别连接到外部信号
    assign sda = sda_out;
    assign scl = scl_out;

    // 定义标志位
    localparam BUSY = 1;  // 总线忙标志
    localparam MSL = 2;   // 主模式标志
    localparam SB = 4;    // 起始条件标志
    localparam ADDR = 8;  // 地址发送完成标志
    localparam TXE = 16;  // 数据寄存器空标志
    localparam TRA = 32;  // 传输状态标志
    localparam BTF = 64;  // 数据传输完成标志
    localparam RXNE = 128;// 接收寄存器非空标志

    // I2C 时钟分频，假设SCL频率为100kHz
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 16'd0;
            scl_enable <= 1'b0;
        end else begin
            if (clk_div == 16'd5000) begin
                clk_div <= 16'd0;
                scl_enable <= 1'b1;
            end else begin
                clk_div <= clk_div + 1'b1;
                scl_enable <= 1'b0;
            end
        end
    end

    // 状态机的状态切换
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else if (scl_enable) begin
            state <= next_state;
        end
    end

    // 根据当前状态计算下一个状态
    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = START;
                end else begin
                    next_state = IDLE;
                end
            end

            START: begin
                next_state = ADDR;
            end

            ADDR: begin
                if (bit_counter == 7) begin
                    next_state = ADDR_ACK;
                end else begin
                    next_state = ADDR;
                end
            end

            ADDR_ACK: begin
                if (flags_reg[ADDR]) begin
                    next_state = REG_ADDR;
                end else begin
                    next_state = IDLE; // 错误处理
                end
            end

            REG_ADDR: begin
                if (bit_counter == 7) begin
                    next_state = REG_ADDR_ACK;
                end else begin
                    next_state = REG_ADDR;
                end
            end

            REG_ADDR_ACK: begin
                if (flags_reg[TXE]) begin
                    next_state = DATA;
                end else begin
                    next_state = IDLE; // 错误处理
                end
            end

            DATA: begin
                if (bit_counter == 7) begin
                    next_state = DATA_ACK;
                end else begin
                    next_state = DATA;
                end
            end

            DATA_ACK: begin
                if (flags_reg[BTF]) begin
                    next_state = STOP;
                end else begin
                    next_state = IDLE; // 错误处理
                end
            end

            STOP: begin
                next_state = DONE;
            end

            DONE: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // 控制输出信号和标志位
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sda_out <= 1'b1;
            scl_out <= 1'b1;
            flags_reg <= 8'd0;
            busy <= 1'b0;
            done <= 1'b0;
            bit_counter <= 8'd0;
        end else if (scl_enable) begin
            case (state)
                IDLE: begin
                    sda_out <= 1'b1;
                    scl_out <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b0;
                    flags_reg[BUSY] <= 1'b0;
                end

                START: begin
                    sda_out <= 1'b0;  // SDA 拉低，生成起始条件
                    scl_out <= 1'b1;
                    busy <= 1'b1;     // 设置忙标志
                    flags_reg[BUSY] <= 1'b1;   // 总线忙
                    flags_reg[MSL] <= 1'b1;    // 主模式
                    flags_reg[SB] <= 1'b1;     // 起始条件
                end

                ADDR: begin
                    scl_out <= 1'b0;  // SCL 拉低，准备发送设备地址
                    sda_out <= dev_addr[7 - bit_counter]; // 发送设备地址
                    bit_counter <= bit_counter + 1'b1;
                    flags_reg[TRA] <= 1'b1;    // 传输模式
                end

                ADDR_ACK: begin
                    scl_out <= 1'b1;  // SCL 拉高，等待 ACK
                    if (/* 检测到ACK */) begin
                        flags_reg[ADDR] <= 1'b1; // 地址传输完成
                    end
                end

                REG_ADDR: begin
                    scl_out <= 1'b0;
                    sda_out <= reg_addr[7 - bit_counter]; // 发送寄存器地址
                    bit_counter <= bit_counter + 1'b1;
                end

                REG_ADDR_ACK: begin
                    scl_out <= 1'b1;  // SCL 拉高，等待 ACK
                    if (/* 检测到ACK */) begin
                        flags_reg[TXE] <= 1'b1; // 数据寄存器为空，准备发送数据
                    end
                end

                DATA: begin
                    scl_out <= 1'b0;
                    sda_out <= data_in[7 - bit_counter]; // 发送数据
                    bit_counter <= bit_counter + 1'b1;
                end

                DATA_ACK: begin
                    scl_out <= 1'b1;  // SCL 拉高，等待数据传输完成
                    if (/* 检测到BTF */) begin
                        flags_reg[BTF] <= 1'b1; // 数据传输完成
                    end
                end

                STOP: begin
                    sda_out <= 1'b0;  // SDA 拉低，准备停止
                    scl_out <= 1'b1;  // SCL 拉高，生成停止条件
                    flags_reg[TRA] <= 1'b0;    // 传输结束
                end

                DONE: begin
                    sda_out <= 1'b1; // 停止条件，SDA 拉高
                    scl_out <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b1;
                    flags_reg <= 8'd0; // 清除所有标志
                end
            endcase
        end
    end

    // 将标志寄存器输出到外部
    assign flags = flags_reg;

endmodule
