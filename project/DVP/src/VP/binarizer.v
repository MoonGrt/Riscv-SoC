module binarizer (
    // module clock
    input clk,    // ʱ���ź�
    input rst_n,  // ��λ�źţ�����Ч��
    input EN,     // ʹ���ź�
    input [7:0] threshold,  // ��ֵ
 
    // ͼ����ǰ�����ݽӿ�
    input       pre_vs,  // vs�ź�
    input       pre_de,  // data enable�ź�
    input [7:0] pre_data,

    // ͼ���������ݽӿ�
    output     post_vs,  // vs�ź�
    output     post_de,  // data enable�ź�
    output reg post_bit  // bit��1=�ף�0=�ڣ�
);

    // reg define
    reg bit_d0;
    reg pre_vs_d;
    reg pre_de_d;

    //*****************************************************
    //**                    main code
    //*****************************************************

    assign bit_fall = (!post_bit) & bit_d0;
    assign post_vs = pre_vs_d;
    assign post_de = pre_de_d;

    // �Ĵ������½���
    always @(posedge clk) begin
        bit_d0 <= post_bit;
    end

    // ��ֵ��
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) post_bit <= 1'b0;
        else if (pre_data > threshold)  // ��ֵ
            post_bit <= 1'b1;
        else post_bit <= 1'b0;
    end

    // ��ʱ2����ͬ��ʱ���ź�
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pre_vs_d <= 1'd0;
            pre_de_d <= 1'd0;
        end else begin
            pre_vs_d <= pre_vs;
            pre_de_d <= pre_de;
        end
    end

endmodule
