module I2CCtrl(
    input wire clk,               // ʱ���ź�
    input wire rst_n,             // ��λ�źţ��͵�ƽ��Ч
    input wire start,             // �����ź�
    input wire [6:0] dev_addr,    // ���豸7λ��ַ
    input wire [7:0] reg_addr,    // �Ĵ�����ַ
    input wire [7:0] data_in,     // Ҫд�������
    output reg sda,               // I2C������
    output reg scl,               // I2Cʱ����
    output reg busy,              // ��ʾģ���Ƿ�æµ
    output reg done,              // ��ʾ�����Ƿ����
    output reg [7:0] flags        // ��־λ���
);

    // ���� I2C ״̬����״̬
    typedef enum reg [3:0] {
        IDLE,         // ����״̬
        START,        // ������ʼ����
        ADDR,         // �����豸��ַ
        ADDR_ACK,     // ���ADDRӦ��ACK��
        REG_ADDR,     // ���ͼĴ�����ַ
        REG_ADDR_ACK, // ���Ĵ�����ַACK
        DATA,         // ��������
        DATA_ACK,     // �������ACK
        STOP,         // ����ֹͣ����
        DONE          // ���״̬
    } state_t;

    state_t state, next_state;

    // I2C �źſ���
    reg [7:0] bit_counter;        // λ�����������ڸ��ٷ��͵�λ��
    reg scl_out;                  // �������� SCL �ļĴ���
    reg sda_out;                  // �������� SDA �ļĴ���

    // I2C ʱ�ӷ�Ƶ
    reg [15:0] clk_div;           // ʱ�ӷ�Ƶ������������ SCL ʱ��
    reg scl_enable;               // ���� SCL ��ʱ��
    reg [7:0] flags_reg;          // ״̬��־�Ĵ�����ģ�� STM32 �еı�־��

    // �� sda �� scl �źŷֱ����ӵ��ⲿ�ź�
    assign sda = sda_out;
    assign scl = scl_out;

    // �����־λ
    localparam BUSY = 1;  // ����æ��־
    localparam MSL = 2;   // ��ģʽ��־
    localparam SB = 4;    // ��ʼ������־
    localparam ADDR = 8;  // ��ַ������ɱ�־
    localparam TXE = 16;  // ���ݼĴ����ձ�־
    localparam TRA = 32;  // ����״̬��־
    localparam BTF = 64;  // ���ݴ�����ɱ�־
    localparam RXNE = 128;// ���ռĴ����ǿձ�־

    // I2C ʱ�ӷ�Ƶ������SCLƵ��Ϊ100kHz
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

    // ״̬����״̬�л�
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else if (scl_enable) begin
            state <= next_state;
        end
    end

    // ���ݵ�ǰ״̬������һ��״̬
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
                    next_state = IDLE; // ������
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
                    next_state = IDLE; // ������
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
                    next_state = IDLE; // ������
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

    // ��������źźͱ�־λ
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
                    sda_out <= 1'b0;  // SDA ���ͣ�������ʼ����
                    scl_out <= 1'b1;
                    busy <= 1'b1;     // ����æ��־
                    flags_reg[BUSY] <= 1'b1;   // ����æ
                    flags_reg[MSL] <= 1'b1;    // ��ģʽ
                    flags_reg[SB] <= 1'b1;     // ��ʼ����
                end

                ADDR: begin
                    scl_out <= 1'b0;  // SCL ���ͣ�׼�������豸��ַ
                    sda_out <= dev_addr[7 - bit_counter]; // �����豸��ַ
                    bit_counter <= bit_counter + 1'b1;
                    flags_reg[TRA] <= 1'b1;    // ����ģʽ
                end

                ADDR_ACK: begin
                    scl_out <= 1'b1;  // SCL ���ߣ��ȴ� ACK
                    if (/* ��⵽ACK */) begin
                        flags_reg[ADDR] <= 1'b1; // ��ַ�������
                    end
                end

                REG_ADDR: begin
                    scl_out <= 1'b0;
                    sda_out <= reg_addr[7 - bit_counter]; // ���ͼĴ�����ַ
                    bit_counter <= bit_counter + 1'b1;
                end

                REG_ADDR_ACK: begin
                    scl_out <= 1'b1;  // SCL ���ߣ��ȴ� ACK
                    if (/* ��⵽ACK */) begin
                        flags_reg[TXE] <= 1'b1; // ���ݼĴ���Ϊ�գ�׼����������
                    end
                end

                DATA: begin
                    scl_out <= 1'b0;
                    sda_out <= data_in[7 - bit_counter]; // ��������
                    bit_counter <= bit_counter + 1'b1;
                end

                DATA_ACK: begin
                    scl_out <= 1'b1;  // SCL ���ߣ��ȴ����ݴ������
                    if (/* ��⵽BTF */) begin
                        flags_reg[BTF] <= 1'b1; // ���ݴ������
                    end
                end

                STOP: begin
                    sda_out <= 1'b0;  // SDA ���ͣ�׼��ֹͣ
                    scl_out <= 1'b1;  // SCL ���ߣ�����ֹͣ����
                    flags_reg[TRA] <= 1'b0;    // �������
                end

                DONE: begin
                    sda_out <= 1'b1; // ֹͣ������SDA ����
                    scl_out <= 1'b1;
                    busy <= 1'b0;
                    done <= 1'b1;
                    flags_reg <= 8'd0; // ������б�־
                end
            endcase
        end
    end

    // ����־�Ĵ���������ⲿ
    assign flags = flags_reg;

endmodule
