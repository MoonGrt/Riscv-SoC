module binarizer (
    // module clock
    input wire       clk,    // ʱ���ź�
    input wire       rst_n,  // ��λ�źţ�����Ч��
    input wire       EN,     // ʹ���ź�
    input wire [1:0] mode,   // ģʽѡ��00=����ģʽ��01=����ģʽ��10=����ģʽ��11=������ģʽ��

    input wire [7:0] threshold,  // ��ֵ
 
    // ͼ����ǰ�����ݽӿ�
    input wire       pre_vs,  // vs�ź�
    input wire       pre_de,  // data enable�ź�
    input wire [7:0] pre_data,

    // ͼ���������ݽӿ�
    output wire post_vs,  // vs�ź�
    output wire post_de,  // data enable�ź�
    output wire post_bit  // bit��1=�ף�0=�ڣ�
);

    // reg define
    reg bit_d0;
    reg pre_vs_d;
    reg pre_de_d;

    //*****************************************************
    //**                    main code
    //*****************************************************
    // assign bit_fall = (!post_bit_r) & bit_d0;
    // // �Ĵ������½���
    // always @(posedge clk) begin
    //     bit_d0 <= post_bit_r;
    // end

    // ��ֵ��
    reg post_bit_r;
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) post_bit_r <= 1'b0;
        else if (pre_data > threshold) post_bit_r <= 1'b1; // ��ֵ
        else post_bit_r <= 1'b0;
    end

    // ��ʱ2����ͬ��ʱ���ź�
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            pre_vs_d <= 1'd0;
            pre_de_d <= 1'd0;
        end else begin
            pre_vs_d <= pre_vs;
            pre_de_d <= pre_de;
        end
    end

    assign post_vs = EN ? pre_vs_d : pre_vs;
    assign post_de = EN ? pre_de_d : pre_de;
    assign post_bit = EN ? post_bit_r : 1'b0;

endmodule
