module VexRiscv (
    output wire        iBus_cmd_valid,
    input  wire        iBus_cmd_ready,
    output wire [31:0] iBus_cmd_payload_pc,
    input  wire        iBus_rsp_valid,
    input  wire        iBus_rsp_payload_error,
    input  wire [31:0] iBus_rsp_payload_inst,
    input  wire        timerInterrupt,
    input  wire        externalInterrupt,
    input  wire        softwareInterrupt,
    input  wire        debug_bus_cmd_valid,
    output reg         debug_bus_cmd_ready,
    input  wire        debug_bus_cmd_payload_wr,
    input  wire [ 7:0] debug_bus_cmd_payload_address,
    input  wire [31:0] debug_bus_cmd_payload_data,
    output reg  [31:0] debug_bus_rsp_data,
    output wire        debug_resetOut,
    output wire        dBus_cmd_valid,
    input  wire        dBus_cmd_ready,
    output wire        dBus_cmd_payload_wr,
    output wire [ 3:0] dBus_cmd_payload_mask,
    output wire [31:0] dBus_cmd_payload_address,
    output wire [31:0] dBus_cmd_payload_data,
    output wire [ 1:0] dBus_cmd_payload_size,
    input  wire        dBus_rsp_ready,
    input  wire        dBus_rsp_error,
    input  wire [31:0] dBus_rsp_data,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset,
    input  wire        resetCtrl_mainClkReset
);
    localparam ShiftCtrlEnum_DISABLE_1 = 2'd0;
    localparam ShiftCtrlEnum_SLL_1 = 2'd1;
    localparam ShiftCtrlEnum_SRL_1 = 2'd2;
    localparam ShiftCtrlEnum_SRA_1 = 2'd3;
    localparam BranchCtrlEnum_INC = 2'd0;
    localparam BranchCtrlEnum_B = 2'd1;
    localparam BranchCtrlEnum_JAL = 2'd2;
    localparam BranchCtrlEnum_JALR = 2'd3;
    localparam AluBitwiseCtrlEnum_XOR_1 = 2'd0;
    localparam AluBitwiseCtrlEnum_OR_1 = 2'd1;
    localparam AluBitwiseCtrlEnum_AND_1 = 2'd2;
    localparam AluCtrlEnum_ADD_SUB = 2'd0;
    localparam AluCtrlEnum_SLT_SLTU = 2'd1;
    localparam AluCtrlEnum_BITWISE = 2'd2;
    localparam EnvCtrlEnum_NONE = 2'd0;
    localparam EnvCtrlEnum_XRET = 2'd1;
    localparam EnvCtrlEnum_ECALL = 2'd2;
    localparam Src2CtrlEnum_RS = 2'd0;
    localparam Src2CtrlEnum_IMI = 2'd1;
    localparam Src2CtrlEnum_IMS = 2'd2;
    localparam Src2CtrlEnum_PC = 2'd3;
    localparam Src1CtrlEnum_RS = 2'd0;
    localparam Src1CtrlEnum_IMU = 2'd1;
    localparam Src1CtrlEnum_PC_INCREMENT = 2'd2;
    localparam Src1CtrlEnum_URS1 = 2'd3;

    wire        IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready;
    reg  [31:0] RegFilePlugin_regFile_spinal_port0;
    reg  [31:0] RegFilePlugin_regFile_spinal_port1;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error;
    wire [31:0] IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst;
    wire [ 0:0] IBusSimplePlugin_rspJoin_rspBuffer_c_io_occupancy;
    wire [ 0:0] IBusSimplePlugin_rspJoin_rspBuffer_c_io_availability;
    wire [51:0] _zz_memory_MUL_LOW;
    wire [51:0] _zz_memory_MUL_LOW_1;
    wire [51:0] _zz_memory_MUL_LOW_2;
    wire [32:0] _zz_memory_MUL_LOW_3;
    wire [51:0] _zz_memory_MUL_LOW_4;
    wire [49:0] _zz_memory_MUL_LOW_5;
    wire [51:0] _zz_memory_MUL_LOW_6;
    wire [49:0] _zz_memory_MUL_LOW_7;
    wire [31:0] _zz_execute_SHIFT_RIGHT;
    wire [32:0] _zz_execute_SHIFT_RIGHT_1;
    wire [32:0] _zz_execute_SHIFT_RIGHT_2;
    wire [ 1:0] _zz_IBusSimplePlugin_jump_pcLoad_payload_1;
    wire [ 1:0] _zz_IBusSimplePlugin_jump_pcLoad_payload_2;
    wire [31:0] _zz_IBusSimplePlugin_fetchPc_pc;
    wire [ 2:0] _zz_IBusSimplePlugin_fetchPc_pc_1;
    wire [ 2:0] _zz_IBusSimplePlugin_pending_next;
    wire [ 2:0] _zz_IBusSimplePlugin_pending_next_1;
    wire [ 0:0] _zz_IBusSimplePlugin_pending_next_2;
    wire [ 2:0] _zz_IBusSimplePlugin_pending_next_3;
    wire [ 0:0] _zz_IBusSimplePlugin_pending_next_4;
    wire [ 2:0] _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter;
    wire [ 0:0] _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_1;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_2;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_3;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_4;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_5;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_6;
    wire        _zz__zz_decode_IS_RS2_SIGNED_7;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_8;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_9;
    wire [24:0] _zz__zz_decode_IS_RS2_SIGNED_10;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_11;
    wire        _zz__zz_decode_IS_RS2_SIGNED_12;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_13;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_14;
    wire [20:0] _zz__zz_decode_IS_RS2_SIGNED_15;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_16;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_17;
    wire        _zz__zz_decode_IS_RS2_SIGNED_18;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_19;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_20;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_21;
    wire        _zz__zz_decode_IS_RS2_SIGNED_22;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_23;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_24;
    wire [15:0] _zz__zz_decode_IS_RS2_SIGNED_25;
    wire        _zz__zz_decode_IS_RS2_SIGNED_26;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_27;
    wire        _zz__zz_decode_IS_RS2_SIGNED_28;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_29;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_30;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_31;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_32;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_33;
    wire        _zz__zz_decode_IS_RS2_SIGNED_34;
    wire        _zz__zz_decode_IS_RS2_SIGNED_35;
    wire [11:0] _zz__zz_decode_IS_RS2_SIGNED_36;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_37;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_38;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_39;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_40;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_41;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_42;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_43;
    wire        _zz__zz_decode_IS_RS2_SIGNED_44;
    wire        _zz__zz_decode_IS_RS2_SIGNED_45;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_46;
    wire [ 2:0] _zz__zz_decode_IS_RS2_SIGNED_47;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_48;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_49;
    wire        _zz__zz_decode_IS_RS2_SIGNED_50;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_51;
    wire        _zz__zz_decode_IS_RS2_SIGNED_52;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_53;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_54;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_55;
    wire [ 3:0] _zz__zz_decode_IS_RS2_SIGNED_56;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_57;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_58;
    wire        _zz__zz_decode_IS_RS2_SIGNED_59;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_60;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_61;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_62;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_63;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_64;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_65;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_66;
    wire [ 7:0] _zz__zz_decode_IS_RS2_SIGNED_67;
    wire [ 5:0] _zz__zz_decode_IS_RS2_SIGNED_68;
    wire        _zz__zz_decode_IS_RS2_SIGNED_69;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_70;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_71;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_72;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_73;
    wire [ 2:0] _zz__zz_decode_IS_RS2_SIGNED_74;
    wire        _zz__zz_decode_IS_RS2_SIGNED_75;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_76;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_77;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_78;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_79;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_80;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_81;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_82;
    wire        _zz__zz_decode_IS_RS2_SIGNED_83;
    wire        _zz__zz_decode_IS_RS2_SIGNED_84;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_85;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_86;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_87;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_88;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_89;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_90;
    wire [ 4:0] _zz__zz_decode_IS_RS2_SIGNED_91;
    wire [ 3:0] _zz__zz_decode_IS_RS2_SIGNED_92;
    wire        _zz__zz_decode_IS_RS2_SIGNED_93;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_94;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_95;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_96;
    wire        _zz__zz_decode_IS_RS2_SIGNED_97;
    wire        _zz__zz_decode_IS_RS2_SIGNED_98;
    wire        _zz__zz_decode_IS_RS2_SIGNED_99;
    wire [31:0] _zz__zz_decode_IS_RS2_SIGNED_100;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_101;
    wire [ 2:0] _zz__zz_decode_IS_RS2_SIGNED_102;
    wire        _zz__zz_decode_IS_RS2_SIGNED_103;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_104;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_105;
    wire [ 1:0] _zz__zz_decode_IS_RS2_SIGNED_106;
    wire        _zz__zz_decode_IS_RS2_SIGNED_107;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_108;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_109;
    wire        _zz__zz_decode_IS_RS2_SIGNED_110;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_111;
    wire [ 0:0] _zz__zz_decode_IS_RS2_SIGNED_112;
    wire        _zz_RegFilePlugin_regFile_port;
    wire        _zz_decode_RegFilePlugin_rs1Data;
    wire        _zz_RegFilePlugin_regFile_port_1;
    wire        _zz_decode_RegFilePlugin_rs2Data;
    wire [ 0:0] _zz__zz_execute_REGFILE_WRITE_DATA;
    wire [ 2:0] _zz__zz_decode_SRC1;
    wire [ 4:0] _zz__zz_decode_SRC1_1;
    wire [11:0] _zz__zz_decode_SRC2_2;
    wire [31:0] _zz_execute_SrcPlugin_addSub;
    wire [31:0] _zz_execute_SrcPlugin_addSub_1;
    wire [31:0] _zz_execute_SrcPlugin_addSub_2;
    wire [31:0] _zz_execute_SrcPlugin_addSub_3;
    wire [31:0] _zz_execute_SrcPlugin_addSub_4;
    wire [65:0] _zz_writeBack_MulPlugin_result;
    wire [65:0] _zz_writeBack_MulPlugin_result_1;
    wire [31:0] _zz__zz_decode_RS2_2;
    wire [31:0] _zz__zz_decode_RS2_2_1;
    wire [ 5:0] _zz_memory_DivPlugin_div_counter_valueNext;
    wire [ 0:0] _zz_memory_DivPlugin_div_counter_valueNext_1;
    wire [32:0] _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator;
    wire [31:0] _zz_memory_DivPlugin_div_stage_0_outRemainder;
    wire [31:0] _zz_memory_DivPlugin_div_stage_0_outRemainder_1;
    wire [32:0] _zz_memory_DivPlugin_div_stage_0_outNumerator;
    wire [32:0] _zz_memory_DivPlugin_div_result_1;
    wire [32:0] _zz_memory_DivPlugin_div_result_2;
    wire [32:0] _zz_memory_DivPlugin_div_result_3;
    wire [32:0] _zz_memory_DivPlugin_div_result_4;
    wire [ 0:0] _zz_memory_DivPlugin_div_result_5;
    wire [32:0] _zz_memory_DivPlugin_rs1_2;
    wire [ 0:0] _zz_memory_DivPlugin_rs1_3;
    wire [31:0] _zz_memory_DivPlugin_rs2_1;
    wire [ 0:0] _zz_memory_DivPlugin_rs2_2;
    wire [19:0] _zz__zz_execute_BranchPlugin_branch_src2;
    wire [11:0] _zz__zz_execute_BranchPlugin_branch_src2_4;
    wire [51:0] memory_MUL_LOW;
    wire [31:0] memory_MEMORY_READ_DATA;
    wire [31:0] execute_SHIFT_RIGHT;
    wire [31:0] execute_BRANCH_CALC;
    wire        execute_BRANCH_DO;
    wire [33:0] memory_MUL_HH;
    wire [33:0] execute_MUL_HH;
    wire [33:0] execute_MUL_HL;
    wire [33:0] execute_MUL_LH;
    wire [31:0] execute_MUL_LL;
    wire [31:0] writeBack_REGFILE_WRITE_DATA;
    wire [31:0] memory_REGFILE_WRITE_DATA;
    wire [31:0] execute_REGFILE_WRITE_DATA;
    wire [ 1:0] memory_MEMORY_ADDRESS_LOW;
    wire [ 1:0] execute_MEMORY_ADDRESS_LOW;
    wire        decode_DO_EBREAK;
    wire [31:0] decode_SRC2;
    wire [31:0] decode_SRC1;
    wire        decode_SRC2_FORCE_ZERO;
    wire [ 1:0] _zz_execute_to_memory_SHIFT_CTRL;
    wire [ 1:0] _zz_execute_to_memory_SHIFT_CTRL_1;
    wire [ 1:0] decode_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SHIFT_CTRL;
    wire [ 1:0] _zz_decode_to_execute_SHIFT_CTRL_1;
    wire [ 1:0] decode_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_to_execute_BRANCH_CTRL;
    wire [ 1:0] _zz_decode_to_execute_BRANCH_CTRL_1;
    wire        decode_IS_RS2_SIGNED;
    wire        decode_IS_RS1_SIGNED;
    wire        decode_IS_DIV;
    wire        memory_IS_MUL;
    wire        execute_IS_MUL;
    wire        decode_IS_MUL;
    wire [ 1:0] decode_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
    wire        decode_SRC_LESS_UNSIGNED;
    wire [ 1:0] decode_ALU_CTRL;
    wire [ 1:0] _zz_decode_ALU_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ALU_CTRL_1;
    wire [ 1:0] _zz_memory_to_writeBack_ENV_CTRL;
    wire [ 1:0] _zz_memory_to_writeBack_ENV_CTRL_1;
    wire [ 1:0] _zz_execute_to_memory_ENV_CTRL;
    wire [ 1:0] _zz_execute_to_memory_ENV_CTRL_1;
    wire [ 1:0] decode_ENV_CTRL;
    wire [ 1:0] _zz_decode_ENV_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ENV_CTRL;
    wire [ 1:0] _zz_decode_to_execute_ENV_CTRL_1;
    wire        decode_IS_CSR;
    wire        decode_MEMORY_STORE;
    wire        execute_BYPASSABLE_MEMORY_STAGE;
    wire        decode_BYPASSABLE_MEMORY_STAGE;
    wire        decode_BYPASSABLE_EXECUTE_STAGE;
    wire        decode_MEMORY_ENABLE;
    wire        decode_CSR_READ_OPCODE;
    wire        decode_CSR_WRITE_OPCODE;
    wire [31:0] writeBack_FORMAL_PC_NEXT;
    wire [31:0] memory_FORMAL_PC_NEXT;
    wire [31:0] execute_FORMAL_PC_NEXT;
    wire [31:0] decode_FORMAL_PC_NEXT;
    wire [31:0] memory_PC;
    wire        execute_DO_EBREAK;
    wire        decode_IS_EBREAK;
    wire [31:0] memory_SHIFT_RIGHT;
    wire [ 1:0] memory_SHIFT_CTRL;
    wire [ 1:0] _zz_memory_SHIFT_CTRL;
    wire [ 1:0] execute_SHIFT_CTRL;
    wire [ 1:0] _zz_execute_SHIFT_CTRL;
    wire [31:0] memory_BRANCH_CALC;
    wire        memory_BRANCH_DO;
    wire [31:0] execute_PC;
    wire [ 1:0] execute_BRANCH_CTRL;
    wire [ 1:0] _zz_execute_BRANCH_CTRL;
    wire        execute_IS_RS1_SIGNED;
    wire        execute_IS_DIV;
    wire        execute_IS_RS2_SIGNED;
    wire        memory_IS_DIV;
    wire        writeBack_IS_MUL;
    wire [33:0] writeBack_MUL_HH;
    wire [51:0] writeBack_MUL_LOW;
    wire [33:0] memory_MUL_HL;
    wire [33:0] memory_MUL_LH;
    wire [31:0] memory_MUL_LL;
    (* keep , syn_keep *)wire [31:0] execute_RS1  /* synthesis syn_keep = 1 */;
    wire        decode_RS2_USE;
    wire        decode_RS1_USE;
    wire        execute_REGFILE_WRITE_VALID;
    wire        execute_BYPASSABLE_EXECUTE_STAGE;
    reg  [31:0] _zz_decode_RS2;
    wire        memory_REGFILE_WRITE_VALID;
    wire [31:0] memory_INSTRUCTION;
    wire        memory_BYPASSABLE_MEMORY_STAGE;
    wire        writeBack_REGFILE_WRITE_VALID;
    reg  [31:0] decode_RS2;
    reg  [31:0] decode_RS1;
    wire        execute_SRC_LESS_UNSIGNED;
    wire        execute_SRC2_FORCE_ZERO;
    wire        execute_SRC_USE_SUB_LESS;
    wire [31:0] _zz_decode_to_execute_PC;
    wire [31:0] _zz_decode_to_execute_RS2;
    wire [ 1:0] decode_SRC2_CTRL;
    wire [ 1:0] _zz_decode_SRC2_CTRL;
    wire [31:0] _zz_decode_to_execute_RS1;
    wire [ 1:0] decode_SRC1_CTRL;
    wire [ 1:0] _zz_decode_SRC1_CTRL;
    wire        decode_SRC_USE_SUB_LESS;
    wire        decode_SRC_ADD_ZERO;
    wire [31:0] execute_SRC_ADD_SUB;
    wire        execute_SRC_LESS;
    wire [ 1:0] execute_ALU_CTRL;
    wire [ 1:0] _zz_execute_ALU_CTRL;
    wire [31:0] execute_SRC2;
    wire [ 1:0] execute_ALU_BITWISE_CTRL;
    wire [ 1:0] _zz_execute_ALU_BITWISE_CTRL;
    wire [31:0] _zz_lastStageRegFileWrite_payload_address;
    wire        _zz_lastStageRegFileWrite_valid;
    reg         _zz_1;
    wire [31:0] decode_INSTRUCTION_ANTICIPATED;
    reg         decode_REGFILE_WRITE_VALID;
    wire [ 1:0] _zz_decode_SHIFT_CTRL_1;
    wire [ 1:0] _zz_decode_BRANCH_CTRL_1;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL_1;
    wire [ 1:0] _zz_decode_ALU_CTRL_1;
    wire [ 1:0] _zz_decode_ENV_CTRL_1;
    wire [ 1:0] _zz_decode_SRC2_CTRL_1;
    wire [ 1:0] _zz_decode_SRC1_CTRL_1;
    reg  [31:0] _zz_decode_RS2_1;
    wire [31:0] execute_SRC1;
    wire        execute_CSR_READ_OPCODE;
    wire        execute_CSR_WRITE_OPCODE;
    wire        execute_IS_CSR;
    wire [ 1:0] memory_ENV_CTRL;
    wire [ 1:0] _zz_memory_ENV_CTRL;
    wire [ 1:0] execute_ENV_CTRL;
    wire [ 1:0] _zz_execute_ENV_CTRL;
    wire [ 1:0] writeBack_ENV_CTRL;
    wire [ 1:0] _zz_writeBack_ENV_CTRL;
    reg  [31:0] _zz_decode_RS2_2;
    wire        writeBack_MEMORY_ENABLE;
    wire [ 1:0] writeBack_MEMORY_ADDRESS_LOW;
    wire [31:0] writeBack_MEMORY_READ_DATA;
    wire        memory_MEMORY_STORE;
    wire        memory_MEMORY_ENABLE;
    wire [31:0] execute_SRC_ADD;
    (* keep , syn_keep *)wire [31:0] execute_RS2  /* synthesis syn_keep = 1 */;
    wire [31:0] execute_INSTRUCTION;
    wire        execute_MEMORY_STORE;
    wire        execute_MEMORY_ENABLE;
    wire        execute_ALIGNEMENT_FAULT;
    reg  [31:0] _zz_memory_to_writeBack_FORMAL_PC_NEXT;
    wire [31:0] decode_PC;
    wire [31:0] decode_INSTRUCTION;
    wire [31:0] writeBack_PC;
    wire [31:0] writeBack_INSTRUCTION;
    reg         decode_arbitration_haltItself;
    reg         decode_arbitration_haltByOther;
    reg         decode_arbitration_removeIt;
    wire        decode_arbitration_flushIt;
    wire        decode_arbitration_flushNext;
    reg         decode_arbitration_isValid;
    wire        decode_arbitration_isStuck;
    wire        decode_arbitration_isStuckByOthers;
    wire        decode_arbitration_isFlushed;
    wire        decode_arbitration_isMoving;
    wire        decode_arbitration_isFiring;
    reg         execute_arbitration_haltItself;
    reg         execute_arbitration_haltByOther;
    reg         execute_arbitration_removeIt;
    reg         execute_arbitration_flushIt;
    reg         execute_arbitration_flushNext;
    reg         execute_arbitration_isValid;
    wire        execute_arbitration_isStuck;
    wire        execute_arbitration_isStuckByOthers;
    wire        execute_arbitration_isFlushed;
    wire        execute_arbitration_isMoving;
    wire        execute_arbitration_isFiring;
    reg         memory_arbitration_haltItself;
    wire        memory_arbitration_haltByOther;
    reg         memory_arbitration_removeIt;
    wire        memory_arbitration_flushIt;
    reg         memory_arbitration_flushNext;
    reg         memory_arbitration_isValid;
    wire        memory_arbitration_isStuck;
    wire        memory_arbitration_isStuckByOthers;
    wire        memory_arbitration_isFlushed;
    wire        memory_arbitration_isMoving;
    wire        memory_arbitration_isFiring;
    wire        writeBack_arbitration_haltItself;
    wire        writeBack_arbitration_haltByOther;
    reg         writeBack_arbitration_removeIt;
    wire        writeBack_arbitration_flushIt;
    reg         writeBack_arbitration_flushNext;
    reg         writeBack_arbitration_isValid;
    wire        writeBack_arbitration_isStuck;
    wire        writeBack_arbitration_isStuckByOthers;
    wire        writeBack_arbitration_isFlushed;
    wire        writeBack_arbitration_isMoving;
    wire        writeBack_arbitration_isFiring;
    wire [31:0] lastStageInstruction  /* verilator public */;
    wire [31:0] lastStagePc  /* verilator public */;
    wire        lastStageIsValid  /* verilator public */;
    wire        lastStageIsFiring  /* verilator public */;
    reg         IBusSimplePlugin_fetcherHalt;
    wire        IBusSimplePlugin_forceNoDecodeCond;
    reg         IBusSimplePlugin_incomingInstruction;
    wire        IBusSimplePlugin_pcValids_0;
    wire        IBusSimplePlugin_pcValids_1;
    wire        IBusSimplePlugin_pcValids_2;
    wire        IBusSimplePlugin_pcValids_3;
    wire [31:0] CsrPlugin_csrMapping_readDataSignal;
    wire [31:0] CsrPlugin_csrMapping_readDataInit;
    wire [31:0] CsrPlugin_csrMapping_writeDataSignal;
    reg         CsrPlugin_csrMapping_allowCsrSignal;
    wire        CsrPlugin_csrMapping_hazardFree;
    wire        CsrPlugin_csrMapping_doForceFailCsr;
    wire        CsrPlugin_inWfi  /* verilator public */;
    reg         CsrPlugin_thirdPartyWake;
    reg         CsrPlugin_jumpInterface_valid;
    reg  [31:0] CsrPlugin_jumpInterface_payload;
    wire        CsrPlugin_exceptionPendings_0;
    wire        CsrPlugin_exceptionPendings_1;
    wire        CsrPlugin_exceptionPendings_2;
    wire        CsrPlugin_exceptionPendings_3;
    wire        contextSwitching;
    reg  [ 1:0] CsrPlugin_privilege;
    reg         CsrPlugin_forceMachineWire;
    reg         CsrPlugin_selfException_valid;
    reg  [ 3:0] CsrPlugin_selfException_payload_code;
    wire [31:0] CsrPlugin_selfException_payload_badAddr;
    reg         CsrPlugin_allowInterrupts;
    reg         CsrPlugin_allowException;
    reg         CsrPlugin_allowEbreakException;
    wire        CsrPlugin_xretAwayFromMachine;
    wire        BranchPlugin_jumpInterface_valid;
    wire [31:0] BranchPlugin_jumpInterface_payload;
    reg         BranchPlugin_inDebugNoFetchFlag;
    reg         DebugPlugin_injectionPort_valid;
    reg         DebugPlugin_injectionPort_ready;
    wire [31:0] DebugPlugin_injectionPort_payload;
    wire        IBusSimplePlugin_externalFlush;
    wire        IBusSimplePlugin_jump_pcLoad_valid;
    wire [31:0] IBusSimplePlugin_jump_pcLoad_payload;
    wire [ 1:0] _zz_IBusSimplePlugin_jump_pcLoad_payload;
    wire        IBusSimplePlugin_fetchPc_output_valid;
    wire        IBusSimplePlugin_fetchPc_output_ready;
    wire [31:0] IBusSimplePlugin_fetchPc_output_payload;
    reg  [31:0] IBusSimplePlugin_fetchPc_pcReg  /* verilator public */;
    reg         IBusSimplePlugin_fetchPc_correction;
    reg         IBusSimplePlugin_fetchPc_correctionReg;
    wire        IBusSimplePlugin_fetchPc_output_fire;
    wire        IBusSimplePlugin_fetchPc_corrected;
    reg         IBusSimplePlugin_fetchPc_pcRegPropagate;
    reg         IBusSimplePlugin_fetchPc_booted;
    reg         IBusSimplePlugin_fetchPc_inc;
    wire        when_Fetcher_l133;
    wire        when_Fetcher_l133_1;
    reg  [31:0] IBusSimplePlugin_fetchPc_pc;
    reg         IBusSimplePlugin_fetchPc_flushed;
    wire        when_Fetcher_l160;
    wire        IBusSimplePlugin_iBusRsp_redoFetch;
    wire        IBusSimplePlugin_iBusRsp_stages_0_input_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_0_input_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_input_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_0_output_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_0_output_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_output_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_0_halt;
    wire        IBusSimplePlugin_iBusRsp_stages_1_input_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_1_input_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_input_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_1_output_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_1_output_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_output_payload;
    reg         IBusSimplePlugin_iBusRsp_stages_1_halt;
    wire        IBusSimplePlugin_iBusRsp_stages_2_input_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_2_input_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_2_input_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_2_output_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_2_output_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_2_output_payload;
    wire        IBusSimplePlugin_iBusRsp_stages_2_halt;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_2_input_ready;
    wire        IBusSimplePlugin_iBusRsp_flush;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_0_output_ready;
    wire        _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid;
    reg         _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1;
    wire        IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    wire        IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    reg         _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    reg  [31:0] _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    reg         IBusSimplePlugin_iBusRsp_readyForError;
    wire        IBusSimplePlugin_iBusRsp_output_valid;
    wire        IBusSimplePlugin_iBusRsp_output_ready;
    wire [31:0] IBusSimplePlugin_iBusRsp_output_payload_pc;
    wire        IBusSimplePlugin_iBusRsp_output_payload_rsp_error;
    wire [31:0] IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
    wire        IBusSimplePlugin_iBusRsp_output_payload_isRvc;
    wire        when_Fetcher_l242;
    wire        IBusSimplePlugin_injector_decodeInput_valid;
    wire        IBusSimplePlugin_injector_decodeInput_ready;
    wire [31:0] IBusSimplePlugin_injector_decodeInput_payload_pc;
    wire        IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
    wire [31:0] IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
    wire        IBusSimplePlugin_injector_decodeInput_payload_isRvc;
    reg         _zz_IBusSimplePlugin_injector_decodeInput_valid;
    reg  [31:0] _zz_IBusSimplePlugin_injector_decodeInput_payload_pc;
    reg         _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
    reg  [31:0] _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
    reg         _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc;
    wire        when_Fetcher_l322;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_0;
    wire        when_Fetcher_l331;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_1;
    wire        when_Fetcher_l331_1;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_2;
    wire        when_Fetcher_l331_2;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_3;
    wire        when_Fetcher_l331_3;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_4;
    wire        when_Fetcher_l331_4;
    reg         IBusSimplePlugin_injector_nextPcCalc_valids_5;
    wire        when_Fetcher_l331_5;
    reg  [31:0] IBusSimplePlugin_injector_formal_rawInDecode;
    wire        IBusSimplePlugin_cmd_valid;
    wire        IBusSimplePlugin_cmd_ready;
    wire [31:0] IBusSimplePlugin_cmd_payload_pc;
    wire        IBusSimplePlugin_pending_inc;
    wire        IBusSimplePlugin_pending_dec;
    reg  [ 2:0] IBusSimplePlugin_pending_value;
    wire [ 2:0] IBusSimplePlugin_pending_next;
    wire        IBusSimplePlugin_cmdFork_canEmit;
    wire        when_IBusSimplePlugin_l305;
    wire        IBusSimplePlugin_cmd_fire;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_output_valid;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_output_ready;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error;
    wire [31:0] IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst;
    reg  [ 2:0] IBusSimplePlugin_rspJoin_rspBuffer_discardCounter;
    wire        iBus_rsp_toStream_valid;
    wire        iBus_rsp_toStream_ready;
    wire        iBus_rsp_toStream_payload_error;
    wire [31:0] iBus_rsp_toStream_payload_inst;
    wire        IBusSimplePlugin_rspJoin_rspBuffer_flush;
    wire        system_cpu_IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire;
    wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_pc;
    reg         IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
    wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
    wire        IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
    wire        when_IBusSimplePlugin_l377;
    wire        IBusSimplePlugin_rspJoin_join_valid;
    wire        IBusSimplePlugin_rspJoin_join_ready;
    wire [31:0] IBusSimplePlugin_rspJoin_join_payload_pc;
    wire        IBusSimplePlugin_rspJoin_join_payload_rsp_error;
    wire [31:0] IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
    wire        IBusSimplePlugin_rspJoin_join_payload_isRvc;
    wire        IBusSimplePlugin_rspJoin_exceptionDetected;
    wire        IBusSimplePlugin_rspJoin_join_fire;
    wire        _zz_IBusSimplePlugin_iBusRsp_output_valid;
    wire        _zz_dBus_cmd_valid;
    reg         execute_DBusSimplePlugin_skipCmd;
    reg  [31:0] _zz_dBus_cmd_payload_data;
    wire        when_DBusSimplePlugin_l434;
    reg  [ 3:0] _zz_execute_DBusSimplePlugin_formalMask;
    wire [ 3:0] execute_DBusSimplePlugin_formalMask;
    wire        when_DBusSimplePlugin_l489;
    reg  [31:0] writeBack_DBusSimplePlugin_rspShifted;
    wire [ 1:0] switch_Misc_l241;
    wire        _zz_writeBack_DBusSimplePlugin_rspFormated;
    reg  [31:0] _zz_writeBack_DBusSimplePlugin_rspFormated_1;
    wire        _zz_writeBack_DBusSimplePlugin_rspFormated_2;
    reg  [31:0] _zz_writeBack_DBusSimplePlugin_rspFormated_3;
    reg  [31:0] writeBack_DBusSimplePlugin_rspFormated;
    wire        when_DBusSimplePlugin_l565;
    wire [ 1:0] CsrPlugin_misa_base;
    wire [25:0] CsrPlugin_misa_extensions;
    wire [ 1:0] CsrPlugin_mtvec_mode;
    reg  [29:0] CsrPlugin_mtvec_base;
    reg  [31:0] CsrPlugin_mepc;
    reg         CsrPlugin_mstatus_MIE;
    reg         CsrPlugin_mstatus_MPIE;
    reg  [ 1:0] CsrPlugin_mstatus_MPP;
    reg         CsrPlugin_mip_MEIP;
    reg         CsrPlugin_mip_MTIP;
    reg         CsrPlugin_mip_MSIP;
    reg         CsrPlugin_mie_MEIE;
    reg         CsrPlugin_mie_MTIE;
    reg         CsrPlugin_mie_MSIE;
    reg         CsrPlugin_mcause_interrupt;
    reg  [ 3:0] CsrPlugin_mcause_exceptionCode;
    reg  [31:0] CsrPlugin_mtval;
    reg  [63:0] CsrPlugin_mcycle;
    reg  [63:0] CsrPlugin_minstret;
    wire        _zz_when_CsrPlugin_l1302;
    wire        _zz_when_CsrPlugin_l1302_1;
    wire        _zz_when_CsrPlugin_l1302_2;
    wire        CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack;
    wire        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
    reg         CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
    reg  [ 3:0] CsrPlugin_exceptionPortCtrl_exceptionContext_code;
    reg  [31:0] CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
    wire [ 1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped;
    wire [ 1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
    wire        when_CsrPlugin_l1259;
    wire        when_CsrPlugin_l1259_1;
    wire        when_CsrPlugin_l1259_2;
    wire        when_CsrPlugin_l1272;
    reg         CsrPlugin_interrupt_valid;
    reg  [ 3:0] CsrPlugin_interrupt_code  /* verilator public */;
    reg  [ 1:0] CsrPlugin_interrupt_targetPrivilege;
    wire        when_CsrPlugin_l1296;
    wire        when_CsrPlugin_l1302;
    wire        when_CsrPlugin_l1302_1;
    wire        when_CsrPlugin_l1302_2;
    wire        CsrPlugin_exception;
    wire        CsrPlugin_lastStageWasWfi;
    reg         CsrPlugin_pipelineLiberator_pcValids_0;
    reg         CsrPlugin_pipelineLiberator_pcValids_1;
    reg         CsrPlugin_pipelineLiberator_pcValids_2;
    wire        CsrPlugin_pipelineLiberator_active;
    wire        when_CsrPlugin_l1335;
    wire        when_CsrPlugin_l1335_1;
    wire        when_CsrPlugin_l1335_2;
    wire        when_CsrPlugin_l1340;
    reg         CsrPlugin_pipelineLiberator_done;
    wire        when_CsrPlugin_l1346;
    wire        CsrPlugin_interruptJump  /* verilator public */;
    reg         CsrPlugin_hadException  /* verilator public */;
    reg  [ 1:0] CsrPlugin_targetPrivilege;
    reg  [ 3:0] CsrPlugin_trapCause;
    wire        CsrPlugin_trapCauseEbreakDebug;
    reg  [ 1:0] CsrPlugin_xtvec_mode;
    reg  [29:0] CsrPlugin_xtvec_base;
    wire        CsrPlugin_trapEnterDebug;
    wire        when_CsrPlugin_l1390;
    wire        when_CsrPlugin_l1398;
    wire        when_CsrPlugin_l1456;
    wire [ 1:0] switch_CsrPlugin_l1460;
    reg         execute_CsrPlugin_wfiWake;
    wire        when_CsrPlugin_l1527;
    wire        execute_CsrPlugin_blockedBySideEffects;
    reg         execute_CsrPlugin_illegalAccess;
    reg         execute_CsrPlugin_illegalInstruction;
    wire        when_CsrPlugin_l1547;
    wire        when_CsrPlugin_l1548;
    wire        when_CsrPlugin_l1555;
    reg         execute_CsrPlugin_writeInstruction;
    reg         execute_CsrPlugin_readInstruction;
    wire        execute_CsrPlugin_writeEnable;
    wire        execute_CsrPlugin_readEnable;
    wire [31:0] execute_CsrPlugin_readToWriteData;
    wire        switch_Misc_l241_1;
    reg  [31:0] _zz_CsrPlugin_csrMapping_writeDataSignal;
    wire        when_CsrPlugin_l1587;
    wire        when_CsrPlugin_l1591;
    wire [11:0] execute_CsrPlugin_csrAddress;
    wire [30:0] _zz_decode_IS_RS2_SIGNED;
    wire        _zz_decode_IS_RS2_SIGNED_1;
    wire        _zz_decode_IS_RS2_SIGNED_2;
    wire        _zz_decode_IS_RS2_SIGNED_3;
    wire        _zz_decode_IS_RS2_SIGNED_4;
    wire        _zz_decode_IS_RS2_SIGNED_5;
    wire        _zz_decode_IS_RS2_SIGNED_6;
    wire [ 1:0] _zz_decode_SRC1_CTRL_2;
    wire [ 1:0] _zz_decode_SRC2_CTRL_2;
    wire [ 1:0] _zz_decode_ENV_CTRL_2;
    wire [ 1:0] _zz_decode_ALU_CTRL_2;
    wire [ 1:0] _zz_decode_ALU_BITWISE_CTRL_2;
    wire [ 1:0] _zz_decode_BRANCH_CTRL_2;
    wire [ 1:0] _zz_decode_SHIFT_CTRL_2;
    wire        when_RegFilePlugin_l63;
    wire [ 4:0] decode_RegFilePlugin_regFileReadAddress1;
    wire [ 4:0] decode_RegFilePlugin_regFileReadAddress2;
    wire [31:0] decode_RegFilePlugin_rs1Data;
    wire [31:0] decode_RegFilePlugin_rs2Data;
    reg         lastStageRegFileWrite_valid  /* verilator public */;
    reg  [ 4:0] lastStageRegFileWrite_payload_address  /* verilator public */;
    reg  [31:0] lastStageRegFileWrite_payload_data  /* verilator public */;
    reg         _zz_5;
    reg  [31:0] execute_IntAluPlugin_bitwise;
    reg  [31:0] _zz_execute_REGFILE_WRITE_DATA;
    reg  [31:0] _zz_decode_SRC1;
    wire        _zz_decode_SRC2;
    reg  [19:0] _zz_decode_SRC2_1;
    wire        _zz_decode_SRC2_2;
    reg  [19:0] _zz_decode_SRC2_3;
    reg  [31:0] _zz_decode_SRC2_4;
    reg  [31:0] execute_SrcPlugin_addSub;
    wire        execute_SrcPlugin_less;
    reg         HazardSimplePlugin_src0Hazard;
    reg         HazardSimplePlugin_src1Hazard;
    wire        HazardSimplePlugin_writeBackWrites_valid;
    wire [ 4:0] HazardSimplePlugin_writeBackWrites_payload_address;
    wire [31:0] HazardSimplePlugin_writeBackWrites_payload_data;
    reg         HazardSimplePlugin_writeBackBuffer_valid;
    reg  [ 4:0] HazardSimplePlugin_writeBackBuffer_payload_address;
    reg  [31:0] HazardSimplePlugin_writeBackBuffer_payload_data;
    wire        HazardSimplePlugin_addr0Match;
    wire        HazardSimplePlugin_addr1Match;
    wire        when_HazardSimplePlugin_l47;
    wire        when_HazardSimplePlugin_l48;
    wire        when_HazardSimplePlugin_l51;
    wire        when_HazardSimplePlugin_l45;
    wire        when_HazardSimplePlugin_l57;
    wire        when_HazardSimplePlugin_l58;
    wire        when_HazardSimplePlugin_l48_1;
    wire        when_HazardSimplePlugin_l51_1;
    wire        when_HazardSimplePlugin_l45_1;
    wire        when_HazardSimplePlugin_l57_1;
    wire        when_HazardSimplePlugin_l58_1;
    wire        when_HazardSimplePlugin_l48_2;
    wire        when_HazardSimplePlugin_l51_2;
    wire        when_HazardSimplePlugin_l45_2;
    wire        when_HazardSimplePlugin_l57_2;
    wire        when_HazardSimplePlugin_l58_2;
    wire        when_HazardSimplePlugin_l105;
    wire        when_HazardSimplePlugin_l108;
    wire        when_HazardSimplePlugin_l113;
    reg         execute_MulPlugin_aSigned;
    reg         execute_MulPlugin_bSigned;
    wire [31:0] execute_MulPlugin_a;
    wire [31:0] execute_MulPlugin_b;
    wire [ 1:0] switch_MulPlugin_l87;
    wire [15:0] execute_MulPlugin_aULow;
    wire [15:0] execute_MulPlugin_bULow;
    wire [16:0] execute_MulPlugin_aSLow;
    wire [16:0] execute_MulPlugin_bSLow;
    wire [16:0] execute_MulPlugin_aHigh;
    wire [16:0] execute_MulPlugin_bHigh;
    wire [65:0] writeBack_MulPlugin_result;
    wire        when_MulPlugin_l147;
    wire [ 1:0] switch_MulPlugin_l148;
    reg  [32:0] memory_DivPlugin_rs1;
    reg  [31:0] memory_DivPlugin_rs2;
    reg  [64:0] memory_DivPlugin_accumulator;
    wire        memory_DivPlugin_frontendOk;
    reg         memory_DivPlugin_div_needRevert;
    reg         memory_DivPlugin_div_counter_willIncrement;
    reg         memory_DivPlugin_div_counter_willClear;
    reg  [ 5:0] memory_DivPlugin_div_counter_valueNext;
    reg  [ 5:0] memory_DivPlugin_div_counter_value;
    wire        memory_DivPlugin_div_counter_willOverflowIfInc;
    wire        memory_DivPlugin_div_counter_willOverflow;
    reg         memory_DivPlugin_div_done;
    wire        when_MulDivIterativePlugin_l126;
    wire        when_MulDivIterativePlugin_l126_1;
    reg  [31:0] memory_DivPlugin_div_result;
    wire        when_MulDivIterativePlugin_l128;
    wire        when_MulDivIterativePlugin_l129;
    wire        when_MulDivIterativePlugin_l132;
    wire [31:0] _zz_memory_DivPlugin_div_stage_0_remainderShifted;
    wire [32:0] memory_DivPlugin_div_stage_0_remainderShifted;
    wire [32:0] memory_DivPlugin_div_stage_0_remainderMinusDenominator;
    wire [31:0] memory_DivPlugin_div_stage_0_outRemainder;
    wire [31:0] memory_DivPlugin_div_stage_0_outNumerator;
    wire        when_MulDivIterativePlugin_l151;
    wire [31:0] _zz_memory_DivPlugin_div_result;
    wire        when_MulDivIterativePlugin_l162;
    wire        _zz_memory_DivPlugin_rs2;
    wire        _zz_memory_DivPlugin_rs1;
    reg  [32:0] _zz_memory_DivPlugin_rs1_1;
    wire        execute_BranchPlugin_eq;
    wire [ 2:0] switch_Misc_l241_2;
    reg         _zz_execute_BRANCH_DO;
    reg         _zz_execute_BRANCH_DO_1;
    wire [31:0] execute_BranchPlugin_branch_src1;
    wire        _zz_execute_BranchPlugin_branch_src2;
    reg  [10:0] _zz_execute_BranchPlugin_branch_src2_1;
    wire        _zz_execute_BranchPlugin_branch_src2_2;
    reg  [19:0] _zz_execute_BranchPlugin_branch_src2_3;
    wire        _zz_execute_BranchPlugin_branch_src2_4;
    reg  [18:0] _zz_execute_BranchPlugin_branch_src2_5;
    reg  [31:0] _zz_execute_BranchPlugin_branch_src2_6;
    wire [31:0] execute_BranchPlugin_branch_src2;
    wire [31:0] execute_BranchPlugin_branchAdder;
    wire [ 4:0] execute_FullBarrelShifterPlugin_amplitude;
    reg  [31:0] _zz_execute_FullBarrelShifterPlugin_reversed;
    wire [31:0] execute_FullBarrelShifterPlugin_reversed;
    reg  [31:0] _zz_decode_RS2_3;
    reg         DebugPlugin_firstCycle;
    reg         DebugPlugin_secondCycle;
    reg         DebugPlugin_resetIt;
    reg         DebugPlugin_haltIt;
    reg         DebugPlugin_stepIt;
    reg         DebugPlugin_isPipBusy;
    reg         DebugPlugin_godmode;
    wire        when_DebugPlugin_l238;
    reg         DebugPlugin_haltedByBreak;
    reg         DebugPlugin_debugUsed  /* verilator public */;
    reg         DebugPlugin_disableEbreak;
    wire        DebugPlugin_allowEBreak;
    reg  [31:0] DebugPlugin_busReadDataReg;
    reg         _zz_when_DebugPlugin_l257;
    wire        when_DebugPlugin_l257;
    wire [ 5:0] switch_DebugPlugin_l280;
    wire        when_DebugPlugin_l284;
    wire        when_DebugPlugin_l284_1;
    wire        when_DebugPlugin_l285;
    wire        when_DebugPlugin_l285_1;
    wire        when_DebugPlugin_l286;
    wire        when_DebugPlugin_l287;
    wire        when_DebugPlugin_l288;
    wire        when_DebugPlugin_l288_1;
    wire        when_DebugPlugin_l308;
    wire        when_DebugPlugin_l311;
    wire        when_DebugPlugin_l324;
    reg         DebugPlugin_resetIt_regNext;
    wire        when_DebugPlugin_l344;
    wire        when_Pipeline_l124;
    reg  [31:0] decode_to_execute_PC;
    wire        when_Pipeline_l124_1;
    reg  [31:0] execute_to_memory_PC;
    wire        when_Pipeline_l124_2;
    reg  [31:0] memory_to_writeBack_PC;
    wire        when_Pipeline_l124_3;
    reg  [31:0] decode_to_execute_INSTRUCTION;
    wire        when_Pipeline_l124_4;
    reg  [31:0] execute_to_memory_INSTRUCTION;
    wire        when_Pipeline_l124_5;
    reg  [31:0] memory_to_writeBack_INSTRUCTION;
    wire        when_Pipeline_l124_6;
    reg  [31:0] decode_to_execute_FORMAL_PC_NEXT;
    wire        when_Pipeline_l124_7;
    reg  [31:0] execute_to_memory_FORMAL_PC_NEXT;
    wire        when_Pipeline_l124_8;
    reg  [31:0] memory_to_writeBack_FORMAL_PC_NEXT;
    wire        when_Pipeline_l124_9;
    reg         decode_to_execute_CSR_WRITE_OPCODE;
    wire        when_Pipeline_l124_10;
    reg         decode_to_execute_CSR_READ_OPCODE;
    wire        when_Pipeline_l124_11;
    reg         decode_to_execute_SRC_USE_SUB_LESS;
    wire        when_Pipeline_l124_12;
    reg         decode_to_execute_MEMORY_ENABLE;
    wire        when_Pipeline_l124_13;
    reg         execute_to_memory_MEMORY_ENABLE;
    wire        when_Pipeline_l124_14;
    reg         memory_to_writeBack_MEMORY_ENABLE;
    wire        when_Pipeline_l124_15;
    reg         decode_to_execute_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_16;
    reg         execute_to_memory_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_17;
    reg         memory_to_writeBack_REGFILE_WRITE_VALID;
    wire        when_Pipeline_l124_18;
    reg         decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
    wire        when_Pipeline_l124_19;
    reg         decode_to_execute_BYPASSABLE_MEMORY_STAGE;
    wire        when_Pipeline_l124_20;
    reg         execute_to_memory_BYPASSABLE_MEMORY_STAGE;
    wire        when_Pipeline_l124_21;
    reg         decode_to_execute_MEMORY_STORE;
    wire        when_Pipeline_l124_22;
    reg         execute_to_memory_MEMORY_STORE;
    wire        when_Pipeline_l124_23;
    reg         decode_to_execute_IS_CSR;
    wire        when_Pipeline_l124_24;
    reg  [ 1:0] decode_to_execute_ENV_CTRL;
    wire        when_Pipeline_l124_25;
    reg  [ 1:0] execute_to_memory_ENV_CTRL;
    wire        when_Pipeline_l124_26;
    reg  [ 1:0] memory_to_writeBack_ENV_CTRL;
    wire        when_Pipeline_l124_27;
    reg  [ 1:0] decode_to_execute_ALU_CTRL;
    wire        when_Pipeline_l124_28;
    reg         decode_to_execute_SRC_LESS_UNSIGNED;
    wire        when_Pipeline_l124_29;
    reg  [ 1:0] decode_to_execute_ALU_BITWISE_CTRL;
    wire        when_Pipeline_l124_30;
    reg         decode_to_execute_IS_MUL;
    wire        when_Pipeline_l124_31;
    reg         execute_to_memory_IS_MUL;
    wire        when_Pipeline_l124_32;
    reg         memory_to_writeBack_IS_MUL;
    wire        when_Pipeline_l124_33;
    reg         decode_to_execute_IS_DIV;
    wire        when_Pipeline_l124_34;
    reg         execute_to_memory_IS_DIV;
    wire        when_Pipeline_l124_35;
    reg         decode_to_execute_IS_RS1_SIGNED;
    wire        when_Pipeline_l124_36;
    reg         decode_to_execute_IS_RS2_SIGNED;
    wire        when_Pipeline_l124_37;
    reg  [ 1:0] decode_to_execute_BRANCH_CTRL;
    wire        when_Pipeline_l124_38;
    reg  [ 1:0] decode_to_execute_SHIFT_CTRL;
    wire        when_Pipeline_l124_39;
    reg  [ 1:0] execute_to_memory_SHIFT_CTRL;
    wire        when_Pipeline_l124_40;
    reg  [31:0] decode_to_execute_RS1;
    wire        when_Pipeline_l124_41;
    reg  [31:0] decode_to_execute_RS2;
    wire        when_Pipeline_l124_42;
    reg         decode_to_execute_SRC2_FORCE_ZERO;
    wire        when_Pipeline_l124_43;
    reg  [31:0] decode_to_execute_SRC1;
    wire        when_Pipeline_l124_44;
    reg  [31:0] decode_to_execute_SRC2;
    wire        when_Pipeline_l124_45;
    reg         decode_to_execute_DO_EBREAK;
    wire        when_Pipeline_l124_46;
    reg  [ 1:0] execute_to_memory_MEMORY_ADDRESS_LOW;
    wire        when_Pipeline_l124_47;
    reg  [ 1:0] memory_to_writeBack_MEMORY_ADDRESS_LOW;
    wire        when_Pipeline_l124_48;
    reg  [31:0] execute_to_memory_REGFILE_WRITE_DATA;
    wire        when_Pipeline_l124_49;
    reg  [31:0] memory_to_writeBack_REGFILE_WRITE_DATA;
    wire        when_Pipeline_l124_50;
    reg  [31:0] execute_to_memory_MUL_LL;
    wire        when_Pipeline_l124_51;
    reg  [33:0] execute_to_memory_MUL_LH;
    wire        when_Pipeline_l124_52;
    reg  [33:0] execute_to_memory_MUL_HL;
    wire        when_Pipeline_l124_53;
    reg  [33:0] execute_to_memory_MUL_HH;
    wire        when_Pipeline_l124_54;
    reg  [33:0] memory_to_writeBack_MUL_HH;
    wire        when_Pipeline_l124_55;
    reg         execute_to_memory_BRANCH_DO;
    wire        when_Pipeline_l124_56;
    reg  [31:0] execute_to_memory_BRANCH_CALC;
    wire        when_Pipeline_l124_57;
    reg  [31:0] execute_to_memory_SHIFT_RIGHT;
    wire        when_Pipeline_l124_58;
    reg  [31:0] memory_to_writeBack_MEMORY_READ_DATA;
    wire        when_Pipeline_l124_59;
    reg  [51:0] memory_to_writeBack_MUL_LOW;
    wire        when_Pipeline_l151;
    wire        when_Pipeline_l154;
    wire        when_Pipeline_l151_1;
    wire        when_Pipeline_l154_1;
    wire        when_Pipeline_l151_2;
    wire        when_Pipeline_l154_2;
    reg  [ 2:0] IBusSimplePlugin_injector_port_state;
    wire        when_Fetcher_l391;
    wire        when_Fetcher_l411;
    wire        when_CsrPlugin_l1669;
    reg         execute_CsrPlugin_csr_768;
    wire        when_CsrPlugin_l1669_1;
    reg         execute_CsrPlugin_csr_836;
    wire        when_CsrPlugin_l1669_2;
    reg         execute_CsrPlugin_csr_772;
    wire        when_CsrPlugin_l1669_3;
    reg         execute_CsrPlugin_csr_773;
    wire        when_CsrPlugin_l1669_4;
    reg         execute_CsrPlugin_csr_833;
    wire        when_CsrPlugin_l1669_5;
    reg         execute_CsrPlugin_csr_834;
    wire        when_CsrPlugin_l1669_6;
    reg         execute_CsrPlugin_csr_835;
    wire [ 1:0] switch_CsrPlugin_l1031;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_1;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_2;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_3;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_4;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_5;
    reg  [31:0] _zz_CsrPlugin_csrMapping_readDataInit_6;
    wire        when_CsrPlugin_l1702;
    wire [11:0] _zz_when_CsrPlugin_l1709;
    wire        when_CsrPlugin_l1709;
    reg         when_CsrPlugin_l1719;
    wire        when_CsrPlugin_l1717;
    wire        when_CsrPlugin_l1725;
`ifndef SYNTHESIS
    reg [71:0] _zz_execute_to_memory_SHIFT_CTRL_string;
    reg [71:0] _zz_execute_to_memory_SHIFT_CTRL_1_string;
    reg [71:0] decode_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_string;
    reg [71:0] _zz_decode_to_execute_SHIFT_CTRL_1_string;
    reg [31:0] decode_BRANCH_CTRL_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_string;
    reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_string;
    reg [31:0] _zz_decode_to_execute_BRANCH_CTRL_1_string;
    reg [39:0] decode_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string;
    reg [63:0] decode_ALU_CTRL_string;
    reg [63:0] _zz_decode_ALU_CTRL_string;
    reg [63:0] _zz_decode_to_execute_ALU_CTRL_string;
    reg [63:0] _zz_decode_to_execute_ALU_CTRL_1_string;
    reg [39:0] _zz_memory_to_writeBack_ENV_CTRL_string;
    reg [39:0] _zz_memory_to_writeBack_ENV_CTRL_1_string;
    reg [39:0] _zz_execute_to_memory_ENV_CTRL_string;
    reg [39:0] _zz_execute_to_memory_ENV_CTRL_1_string;
    reg [39:0] decode_ENV_CTRL_string;
    reg [39:0] _zz_decode_ENV_CTRL_string;
    reg [39:0] _zz_decode_to_execute_ENV_CTRL_string;
    reg [39:0] _zz_decode_to_execute_ENV_CTRL_1_string;
    reg [71:0] memory_SHIFT_CTRL_string;
    reg [71:0] _zz_memory_SHIFT_CTRL_string;
    reg [71:0] execute_SHIFT_CTRL_string;
    reg [71:0] _zz_execute_SHIFT_CTRL_string;
    reg [31:0] execute_BRANCH_CTRL_string;
    reg [31:0] _zz_execute_BRANCH_CTRL_string;
    reg [23:0] decode_SRC2_CTRL_string;
    reg [23:0] _zz_decode_SRC2_CTRL_string;
    reg [95:0] decode_SRC1_CTRL_string;
    reg [95:0] _zz_decode_SRC1_CTRL_string;
    reg [63:0] execute_ALU_CTRL_string;
    reg [63:0] _zz_execute_ALU_CTRL_string;
    reg [39:0] execute_ALU_BITWISE_CTRL_string;
    reg [39:0] _zz_execute_ALU_BITWISE_CTRL_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_1_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_1_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_1_string;
    reg [63:0] _zz_decode_ALU_CTRL_1_string;
    reg [39:0] _zz_decode_ENV_CTRL_1_string;
    reg [23:0] _zz_decode_SRC2_CTRL_1_string;
    reg [95:0] _zz_decode_SRC1_CTRL_1_string;
    reg [39:0] memory_ENV_CTRL_string;
    reg [39:0] _zz_memory_ENV_CTRL_string;
    reg [39:0] execute_ENV_CTRL_string;
    reg [39:0] _zz_execute_ENV_CTRL_string;
    reg [39:0] writeBack_ENV_CTRL_string;
    reg [39:0] _zz_writeBack_ENV_CTRL_string;
    reg [95:0] _zz_decode_SRC1_CTRL_2_string;
    reg [23:0] _zz_decode_SRC2_CTRL_2_string;
    reg [39:0] _zz_decode_ENV_CTRL_2_string;
    reg [63:0] _zz_decode_ALU_CTRL_2_string;
    reg [39:0] _zz_decode_ALU_BITWISE_CTRL_2_string;
    reg [31:0] _zz_decode_BRANCH_CTRL_2_string;
    reg [71:0] _zz_decode_SHIFT_CTRL_2_string;
    reg [39:0] decode_to_execute_ENV_CTRL_string;
    reg [39:0] execute_to_memory_ENV_CTRL_string;
    reg [39:0] memory_to_writeBack_ENV_CTRL_string;
    reg [63:0] decode_to_execute_ALU_CTRL_string;
    reg [39:0] decode_to_execute_ALU_BITWISE_CTRL_string;
    reg [31:0] decode_to_execute_BRANCH_CTRL_string;
    reg [71:0] decode_to_execute_SHIFT_CTRL_string;
    reg [71:0] execute_to_memory_SHIFT_CTRL_string;
`endif

    reg [31:0] RegFilePlugin_regFile[0:31]  /* verilator public */;

    assign _zz_memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW_1) + $signed(_zz_memory_MUL_LOW_4));
    assign _zz_memory_MUL_LOW_1 = ($signed(52'h0) + $signed(_zz_memory_MUL_LOW_2));
    assign _zz_memory_MUL_LOW_3 = {1'b0, memory_MUL_LL};
    assign _zz_memory_MUL_LOW_2 = {{19{_zz_memory_MUL_LOW_3[32]}}, _zz_memory_MUL_LOW_3};
    assign _zz_memory_MUL_LOW_5 = ({16'd0, memory_MUL_LH} <<< 5'd16);
    assign _zz_memory_MUL_LOW_4 = {{2{_zz_memory_MUL_LOW_5[49]}}, _zz_memory_MUL_LOW_5};
    assign _zz_memory_MUL_LOW_7 = ({16'd0, memory_MUL_HL} <<< 5'd16);
    assign _zz_memory_MUL_LOW_6 = {{2{_zz_memory_MUL_LOW_7[49]}}, _zz_memory_MUL_LOW_7};
    assign _zz_execute_SHIFT_RIGHT_1 = ($signed(
        _zz_execute_SHIFT_RIGHT_2
    ) >>> execute_FullBarrelShifterPlugin_amplitude);
    assign _zz_execute_SHIFT_RIGHT = _zz_execute_SHIFT_RIGHT_1[31 : 0];
    assign _zz_execute_SHIFT_RIGHT_2 = {
        ((execute_SHIFT_CTRL == ShiftCtrlEnum_SRA_1) && execute_FullBarrelShifterPlugin_reversed[31]),
        execute_FullBarrelShifterPlugin_reversed
    };
    assign _zz_IBusSimplePlugin_jump_pcLoad_payload_1 = (_zz_IBusSimplePlugin_jump_pcLoad_payload & (~ _zz_IBusSimplePlugin_jump_pcLoad_payload_2));
    assign _zz_IBusSimplePlugin_jump_pcLoad_payload_2 = (_zz_IBusSimplePlugin_jump_pcLoad_payload - 2'b01);
    assign _zz_IBusSimplePlugin_fetchPc_pc_1 = {IBusSimplePlugin_fetchPc_inc, 2'b00};
    assign _zz_IBusSimplePlugin_fetchPc_pc = {29'd0, _zz_IBusSimplePlugin_fetchPc_pc_1};
    assign _zz_IBusSimplePlugin_pending_next = (IBusSimplePlugin_pending_value + _zz_IBusSimplePlugin_pending_next_1);
    assign _zz_IBusSimplePlugin_pending_next_2 = IBusSimplePlugin_pending_inc;
    assign _zz_IBusSimplePlugin_pending_next_1 = {2'd0, _zz_IBusSimplePlugin_pending_next_2};
    assign _zz_IBusSimplePlugin_pending_next_4 = IBusSimplePlugin_pending_dec;
    assign _zz_IBusSimplePlugin_pending_next_3 = {2'd0, _zz_IBusSimplePlugin_pending_next_4};
    assign _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1 = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter != 3'b000));
    assign _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter = {
        2'd0, _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter_1
    };
    assign _zz__zz_execute_REGFILE_WRITE_DATA = execute_SRC_LESS;
    assign _zz__zz_decode_SRC1 = 3'b100;
    assign _zz__zz_decode_SRC1_1 = decode_INSTRUCTION[19 : 15];
    assign _zz__zz_decode_SRC2_2 = {decode_INSTRUCTION[31 : 25], decode_INSTRUCTION[11 : 7]};
    assign _zz_execute_SrcPlugin_addSub = ($signed(
        _zz_execute_SrcPlugin_addSub_1
    ) + $signed(
        _zz_execute_SrcPlugin_addSub_4
    ));
    assign _zz_execute_SrcPlugin_addSub_1 = ($signed(
        _zz_execute_SrcPlugin_addSub_2
    ) + $signed(
        _zz_execute_SrcPlugin_addSub_3
    ));
    assign _zz_execute_SrcPlugin_addSub_2 = execute_SRC1;
    assign _zz_execute_SrcPlugin_addSub_3 = (execute_SRC_USE_SUB_LESS ? (~ execute_SRC2) : execute_SRC2);
    assign _zz_execute_SrcPlugin_addSub_4 = (execute_SRC_USE_SUB_LESS ? 32'h00000001 : 32'h0);
    assign _zz_writeBack_MulPlugin_result = {{14{writeBack_MUL_LOW[51]}}, writeBack_MUL_LOW};
    assign _zz_writeBack_MulPlugin_result_1 = ({32'd0, writeBack_MUL_HH} <<< 6'd32);
    assign _zz__zz_decode_RS2_2 = writeBack_MUL_LOW[31 : 0];
    assign _zz__zz_decode_RS2_2_1 = writeBack_MulPlugin_result[63 : 32];
    assign _zz_memory_DivPlugin_div_counter_valueNext_1 = memory_DivPlugin_div_counter_willIncrement;
    assign _zz_memory_DivPlugin_div_counter_valueNext = {
        5'd0, _zz_memory_DivPlugin_div_counter_valueNext_1
    };
    assign _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator = {
        1'd0, memory_DivPlugin_rs2
    };
    assign _zz_memory_DivPlugin_div_stage_0_outRemainder = memory_DivPlugin_div_stage_0_remainderMinusDenominator[31:0];
    assign _zz_memory_DivPlugin_div_stage_0_outRemainder_1 = memory_DivPlugin_div_stage_0_remainderShifted[31:0];
    assign _zz_memory_DivPlugin_div_stage_0_outNumerator = {
        _zz_memory_DivPlugin_div_stage_0_remainderShifted,
        (!memory_DivPlugin_div_stage_0_remainderMinusDenominator[32])
    };
    assign _zz_memory_DivPlugin_div_result_1 = _zz_memory_DivPlugin_div_result_2;
    assign _zz_memory_DivPlugin_div_result_2 = _zz_memory_DivPlugin_div_result_3;
    assign _zz_memory_DivPlugin_div_result_3 = ({memory_DivPlugin_div_needRevert,(memory_DivPlugin_div_needRevert ? (~ _zz_memory_DivPlugin_div_result) : _zz_memory_DivPlugin_div_result)} + _zz_memory_DivPlugin_div_result_4);
    assign _zz_memory_DivPlugin_div_result_5 = memory_DivPlugin_div_needRevert;
    assign _zz_memory_DivPlugin_div_result_4 = {32'd0, _zz_memory_DivPlugin_div_result_5};
    assign _zz_memory_DivPlugin_rs1_3 = _zz_memory_DivPlugin_rs1;
    assign _zz_memory_DivPlugin_rs1_2 = {32'd0, _zz_memory_DivPlugin_rs1_3};
    assign _zz_memory_DivPlugin_rs2_2 = _zz_memory_DivPlugin_rs2;
    assign _zz_memory_DivPlugin_rs2_1 = {31'd0, _zz_memory_DivPlugin_rs2_2};
    assign _zz__zz_execute_BranchPlugin_branch_src2 = {
        {{execute_INSTRUCTION[31], execute_INSTRUCTION[19 : 12]}, execute_INSTRUCTION[20]},
        execute_INSTRUCTION[30 : 21]
    };
    assign _zz__zz_execute_BranchPlugin_branch_src2_4 = {
        {{execute_INSTRUCTION[31], execute_INSTRUCTION[7]}, execute_INSTRUCTION[30 : 25]},
        execute_INSTRUCTION[11 : 8]
    };
    assign _zz_decode_RegFilePlugin_rs1Data = 1'b1;
    assign _zz_decode_RegFilePlugin_rs2Data = 1'b1;
    assign _zz__zz_decode_IS_RS2_SIGNED = 32'h00103050;
    assign _zz__zz_decode_IS_RS2_SIGNED_1 = (decode_INSTRUCTION & 32'h02007054);
    assign _zz__zz_decode_IS_RS2_SIGNED_2 = 32'h00005010;
    assign _zz__zz_decode_IS_RS2_SIGNED_3 = ((decode_INSTRUCTION & 32'h40003054) == 32'h40001010);
    assign _zz__zz_decode_IS_RS2_SIGNED_4 = ((decode_INSTRUCTION & 32'h02007054) == 32'h00001010);
    assign _zz__zz_decode_IS_RS2_SIGNED_5 = {
        _zz_decode_IS_RS2_SIGNED_5,
        ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_6) == 32'h00000004)
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_7 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_8) == 32'h00000040));
    assign _zz__zz_decode_IS_RS2_SIGNED_9 = (|_zz_decode_IS_RS2_SIGNED_6);
    assign _zz__zz_decode_IS_RS2_SIGNED_10 = {
        (|_zz_decode_IS_RS2_SIGNED_6),
        {
            (|_zz__zz_decode_IS_RS2_SIGNED_11),
            {
                _zz__zz_decode_IS_RS2_SIGNED_12,
                {_zz__zz_decode_IS_RS2_SIGNED_13, _zz__zz_decode_IS_RS2_SIGNED_15}
            }
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_6 = 32'h0000001c;
    assign _zz__zz_decode_IS_RS2_SIGNED_8 = 32'h00000058;
    assign _zz__zz_decode_IS_RS2_SIGNED_11 = ((decode_INSTRUCTION & 32'h02004064) == 32'h02004020);
    assign _zz__zz_decode_IS_RS2_SIGNED_12 = (|((decode_INSTRUCTION & 32'h02004074) == 32'h02000030));
    assign _zz__zz_decode_IS_RS2_SIGNED_13 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_14) == 32'h00000024));
    assign _zz__zz_decode_IS_RS2_SIGNED_15 = {
        (|(_zz__zz_decode_IS_RS2_SIGNED_16 == _zz__zz_decode_IS_RS2_SIGNED_17)),
        {
            (|_zz__zz_decode_IS_RS2_SIGNED_18),
            {
                (|_zz__zz_decode_IS_RS2_SIGNED_19),
                {
                    _zz__zz_decode_IS_RS2_SIGNED_22,
                    {_zz__zz_decode_IS_RS2_SIGNED_24, _zz__zz_decode_IS_RS2_SIGNED_25}
                }
            }
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_14 = 32'h00000064;
    assign _zz__zz_decode_IS_RS2_SIGNED_16 = (decode_INSTRUCTION & 32'h00001000);
    assign _zz__zz_decode_IS_RS2_SIGNED_17 = 32'h00001000;
    assign _zz__zz_decode_IS_RS2_SIGNED_18 = ((decode_INSTRUCTION & 32'h00003000) == 32'h00002000);
    assign _zz__zz_decode_IS_RS2_SIGNED_19 = {
        ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_20) == 32'h00002000),
        ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_21) == 32'h00001000)
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_22 = (|((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_23) == 32'h00004000));
    assign _zz__zz_decode_IS_RS2_SIGNED_24 = (|_zz_decode_IS_RS2_SIGNED_2);
    assign _zz__zz_decode_IS_RS2_SIGNED_25 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_26),
        {
            (|_zz__zz_decode_IS_RS2_SIGNED_27),
            {
                _zz__zz_decode_IS_RS2_SIGNED_28,
                {_zz__zz_decode_IS_RS2_SIGNED_33, _zz__zz_decode_IS_RS2_SIGNED_36}
            }
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_20 = 32'h00002010;
    assign _zz__zz_decode_IS_RS2_SIGNED_21 = 32'h00005000;
    assign _zz__zz_decode_IS_RS2_SIGNED_23 = 32'h00004004;
    assign _zz__zz_decode_IS_RS2_SIGNED_26 = ((decode_INSTRUCTION & 32'h10103050) == 32'h00000050);
    assign _zz__zz_decode_IS_RS2_SIGNED_27 = ((decode_INSTRUCTION & 32'h10003050) == 32'h10000050);
    assign _zz__zz_decode_IS_RS2_SIGNED_28 = (|{(_zz__zz_decode_IS_RS2_SIGNED_29 == _zz__zz_decode_IS_RS2_SIGNED_30),(_zz__zz_decode_IS_RS2_SIGNED_31 == _zz__zz_decode_IS_RS2_SIGNED_32)});
    assign _zz__zz_decode_IS_RS2_SIGNED_33 = (|{_zz__zz_decode_IS_RS2_SIGNED_34,_zz__zz_decode_IS_RS2_SIGNED_35});
    assign _zz__zz_decode_IS_RS2_SIGNED_36 = {
        (|{_zz__zz_decode_IS_RS2_SIGNED_37, _zz__zz_decode_IS_RS2_SIGNED_39}),
        {
            (|_zz__zz_decode_IS_RS2_SIGNED_42),
            {
                _zz__zz_decode_IS_RS2_SIGNED_44,
                {_zz__zz_decode_IS_RS2_SIGNED_54, _zz__zz_decode_IS_RS2_SIGNED_67}
            }
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_29 = (decode_INSTRUCTION & 32'h00001050);
    assign _zz__zz_decode_IS_RS2_SIGNED_30 = 32'h00001050;
    assign _zz__zz_decode_IS_RS2_SIGNED_31 = (decode_INSTRUCTION & 32'h00002050);
    assign _zz__zz_decode_IS_RS2_SIGNED_32 = 32'h00002050;
    assign _zz__zz_decode_IS_RS2_SIGNED_34 = ((decode_INSTRUCTION & 32'h00000034) == 32'h00000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_35 = ((decode_INSTRUCTION & 32'h00000064) == 32'h00000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_37 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_38) == 32'h00000040);
    assign _zz__zz_decode_IS_RS2_SIGNED_39 = {
        _zz_decode_IS_RS2_SIGNED_3,
        (_zz__zz_decode_IS_RS2_SIGNED_40 == _zz__zz_decode_IS_RS2_SIGNED_41)
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_42 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_43) == 32'h00000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_44 = (|{_zz__zz_decode_IS_RS2_SIGNED_45, {
        _zz__zz_decode_IS_RS2_SIGNED_46, _zz__zz_decode_IS_RS2_SIGNED_47
    }});
    assign _zz__zz_decode_IS_RS2_SIGNED_54 = (|{_zz__zz_decode_IS_RS2_SIGNED_55,_zz__zz_decode_IS_RS2_SIGNED_56});
    assign _zz__zz_decode_IS_RS2_SIGNED_67 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_68),
        {
            _zz__zz_decode_IS_RS2_SIGNED_83,
            {_zz__zz_decode_IS_RS2_SIGNED_86, _zz__zz_decode_IS_RS2_SIGNED_91}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_38 = 32'h00000050;
    assign _zz__zz_decode_IS_RS2_SIGNED_40 = (decode_INSTRUCTION & 32'h00103040);
    assign _zz__zz_decode_IS_RS2_SIGNED_41 = 32'h00000040;
    assign _zz__zz_decode_IS_RS2_SIGNED_43 = 32'h00000020;
    assign _zz__zz_decode_IS_RS2_SIGNED_45 = ((decode_INSTRUCTION & 32'h00000040) == 32'h00000040);
    assign _zz__zz_decode_IS_RS2_SIGNED_46 = _zz_decode_IS_RS2_SIGNED_4;
    assign _zz__zz_decode_IS_RS2_SIGNED_47 = {
        (_zz__zz_decode_IS_RS2_SIGNED_48 == _zz__zz_decode_IS_RS2_SIGNED_49),
        {_zz__zz_decode_IS_RS2_SIGNED_50, _zz__zz_decode_IS_RS2_SIGNED_52}
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_55 = _zz_decode_IS_RS2_SIGNED_4;
    assign _zz__zz_decode_IS_RS2_SIGNED_56 = {
        (_zz__zz_decode_IS_RS2_SIGNED_57 == _zz__zz_decode_IS_RS2_SIGNED_58),
        {
            _zz__zz_decode_IS_RS2_SIGNED_59,
            {_zz__zz_decode_IS_RS2_SIGNED_61, _zz__zz_decode_IS_RS2_SIGNED_64}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_68 = {
        _zz_decode_IS_RS2_SIGNED_5,
        {
            _zz__zz_decode_IS_RS2_SIGNED_69,
            {_zz__zz_decode_IS_RS2_SIGNED_71, _zz__zz_decode_IS_RS2_SIGNED_74}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_83 = (|{_zz_decode_IS_RS2_SIGNED_4,_zz__zz_decode_IS_RS2_SIGNED_84});
    assign _zz__zz_decode_IS_RS2_SIGNED_86 = (|{_zz__zz_decode_IS_RS2_SIGNED_87,_zz__zz_decode_IS_RS2_SIGNED_88});
    assign _zz__zz_decode_IS_RS2_SIGNED_91 = {
        (|_zz__zz_decode_IS_RS2_SIGNED_92),
        {
            _zz__zz_decode_IS_RS2_SIGNED_98,
            {_zz__zz_decode_IS_RS2_SIGNED_101, _zz__zz_decode_IS_RS2_SIGNED_106}
        }
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_48 = (decode_INSTRUCTION & 32'h00004020);
    assign _zz__zz_decode_IS_RS2_SIGNED_49 = 32'h00004020;
    assign _zz__zz_decode_IS_RS2_SIGNED_50 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_51) == 32'h00000010);
    assign _zz__zz_decode_IS_RS2_SIGNED_52 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_53) == 32'h00000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_57 = (decode_INSTRUCTION & 32'h00002030);
    assign _zz__zz_decode_IS_RS2_SIGNED_58 = 32'h00002010;
    assign _zz__zz_decode_IS_RS2_SIGNED_59 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_60) == 32'h00000010);
    assign _zz__zz_decode_IS_RS2_SIGNED_61 = (_zz__zz_decode_IS_RS2_SIGNED_62 == _zz__zz_decode_IS_RS2_SIGNED_63);
    assign _zz__zz_decode_IS_RS2_SIGNED_64 = (_zz__zz_decode_IS_RS2_SIGNED_65 == _zz__zz_decode_IS_RS2_SIGNED_66);
    assign _zz__zz_decode_IS_RS2_SIGNED_69 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_70) == 32'h00001010);
    assign _zz__zz_decode_IS_RS2_SIGNED_71 = (_zz__zz_decode_IS_RS2_SIGNED_72 == _zz__zz_decode_IS_RS2_SIGNED_73);
    assign _zz__zz_decode_IS_RS2_SIGNED_74 = {
        _zz__zz_decode_IS_RS2_SIGNED_75,
        {_zz__zz_decode_IS_RS2_SIGNED_77, _zz__zz_decode_IS_RS2_SIGNED_80}
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_84 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_85) == 32'h00000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_87 = _zz_decode_IS_RS2_SIGNED_4;
    assign _zz__zz_decode_IS_RS2_SIGNED_88 = (_zz__zz_decode_IS_RS2_SIGNED_89 == _zz__zz_decode_IS_RS2_SIGNED_90);
    assign _zz__zz_decode_IS_RS2_SIGNED_92 = {
        _zz__zz_decode_IS_RS2_SIGNED_93,
        {_zz__zz_decode_IS_RS2_SIGNED_95, _zz__zz_decode_IS_RS2_SIGNED_96}
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_98 = (|_zz__zz_decode_IS_RS2_SIGNED_99);
    assign _zz__zz_decode_IS_RS2_SIGNED_101 = (|_zz__zz_decode_IS_RS2_SIGNED_102);
    assign _zz__zz_decode_IS_RS2_SIGNED_106 = {
        _zz__zz_decode_IS_RS2_SIGNED_107, _zz__zz_decode_IS_RS2_SIGNED_110
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_51 = 32'h00000030;
    assign _zz__zz_decode_IS_RS2_SIGNED_53 = 32'h02000020;
    assign _zz__zz_decode_IS_RS2_SIGNED_60 = 32'h00001030;
    assign _zz__zz_decode_IS_RS2_SIGNED_62 = (decode_INSTRUCTION & 32'h02002060);
    assign _zz__zz_decode_IS_RS2_SIGNED_63 = 32'h00002020;
    assign _zz__zz_decode_IS_RS2_SIGNED_65 = (decode_INSTRUCTION & 32'h02003020);
    assign _zz__zz_decode_IS_RS2_SIGNED_66 = 32'h00000020;
    assign _zz__zz_decode_IS_RS2_SIGNED_70 = 32'h00001010;
    assign _zz__zz_decode_IS_RS2_SIGNED_72 = (decode_INSTRUCTION & 32'h00002010);
    assign _zz__zz_decode_IS_RS2_SIGNED_73 = 32'h00002010;
    assign _zz__zz_decode_IS_RS2_SIGNED_75 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_76) == 32'h00000010);
    assign _zz__zz_decode_IS_RS2_SIGNED_77 = (_zz__zz_decode_IS_RS2_SIGNED_78 == _zz__zz_decode_IS_RS2_SIGNED_79);
    assign _zz__zz_decode_IS_RS2_SIGNED_80 = (_zz__zz_decode_IS_RS2_SIGNED_81 == _zz__zz_decode_IS_RS2_SIGNED_82);
    assign _zz__zz_decode_IS_RS2_SIGNED_85 = 32'h00000070;
    assign _zz__zz_decode_IS_RS2_SIGNED_89 = (decode_INSTRUCTION & 32'h00000020);
    assign _zz__zz_decode_IS_RS2_SIGNED_90 = 32'h0;
    assign _zz__zz_decode_IS_RS2_SIGNED_93 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_94) == 32'h0);
    assign _zz__zz_decode_IS_RS2_SIGNED_95 = _zz_decode_IS_RS2_SIGNED_3;
    assign _zz__zz_decode_IS_RS2_SIGNED_96 = {
        _zz_decode_IS_RS2_SIGNED_2, _zz__zz_decode_IS_RS2_SIGNED_97
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_99 = ((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED_100) == 32'h0);
    assign _zz__zz_decode_IS_RS2_SIGNED_102 = {
        _zz__zz_decode_IS_RS2_SIGNED_103,
        {_zz__zz_decode_IS_RS2_SIGNED_104, _zz__zz_decode_IS_RS2_SIGNED_105}
    };
    assign _zz__zz_decode_IS_RS2_SIGNED_107 = (|{_zz__zz_decode_IS_RS2_SIGNED_108,_zz__zz_decode_IS_RS2_SIGNED_109});
    assign _zz__zz_decode_IS_RS2_SIGNED_110 = (|{_zz__zz_decode_IS_RS2_SIGNED_111,_zz__zz_decode_IS_RS2_SIGNED_112});
    assign _zz__zz_decode_IS_RS2_SIGNED_76 = 32'h00000050;
    assign _zz__zz_decode_IS_RS2_SIGNED_78 = (decode_INSTRUCTION & 32'h0000000c);
    assign _zz__zz_decode_IS_RS2_SIGNED_79 = 32'h00000004;
    assign _zz__zz_decode_IS_RS2_SIGNED_81 = (decode_INSTRUCTION & 32'h00000028);
    assign _zz__zz_decode_IS_RS2_SIGNED_82 = 32'h0;
    assign _zz__zz_decode_IS_RS2_SIGNED_94 = 32'h00000044;
    assign _zz__zz_decode_IS_RS2_SIGNED_97 = ((decode_INSTRUCTION & 32'h00005004) == 32'h00001000);
    assign _zz__zz_decode_IS_RS2_SIGNED_100 = 32'h00000058;
    assign _zz__zz_decode_IS_RS2_SIGNED_103 = ((decode_INSTRUCTION & 32'h00000044) == 32'h00000040);
    assign _zz__zz_decode_IS_RS2_SIGNED_104 = ((decode_INSTRUCTION & 32'h00002014) == 32'h00002010);
    assign _zz__zz_decode_IS_RS2_SIGNED_105 = ((decode_INSTRUCTION & 32'h40000034) == 32'h40000030);
    assign _zz__zz_decode_IS_RS2_SIGNED_108 = ((decode_INSTRUCTION & 32'h00000014) == 32'h00000004);
    assign _zz__zz_decode_IS_RS2_SIGNED_109 = _zz_decode_IS_RS2_SIGNED_1;
    assign _zz__zz_decode_IS_RS2_SIGNED_111 = ((decode_INSTRUCTION & 32'h00000044) == 32'h00000004);
    assign _zz__zz_decode_IS_RS2_SIGNED_112 = _zz_decode_IS_RS2_SIGNED_1;
    always @(posedge io_mainClk) begin
        if (_zz_decode_RegFilePlugin_rs1Data) begin
            RegFilePlugin_regFile_spinal_port0 <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress1];
        end
    end

    always @(posedge io_mainClk) begin
        if (_zz_decode_RegFilePlugin_rs2Data) begin
            RegFilePlugin_regFile_spinal_port1 <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress2];
        end
    end

    always @(posedge io_mainClk) begin
        if (_zz_1) begin
            RegFilePlugin_regFile[lastStageRegFileWrite_payload_address] <= lastStageRegFileWrite_payload_data;
        end
    end

    StreamFifoLowLatency IBusSimplePlugin_rspJoin_rspBuffer_c (
        .io_push_valid        (iBus_rsp_toStream_valid),                                         //i
        .io_push_ready        (IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready),              //o
        .io_push_payload_error(iBus_rsp_toStream_payload_error),                                 //i
        .io_push_payload_inst (iBus_rsp_toStream_payload_inst[31:0]),                            //i
        .io_pop_valid         (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid),               //o
        .io_pop_ready         (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready),               //i
        .io_pop_payload_error (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error),       //o
        .io_pop_payload_inst  (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst[31:0]),  //o
        .io_flush             (1'b0),                                                            //i
        .io_occupancy         (IBusSimplePlugin_rspJoin_rspBuffer_c_io_occupancy),               //o
        .io_availability      (IBusSimplePlugin_rspJoin_rspBuffer_c_io_availability),            //o
        .io_mainClk           (io_mainClk),                                                      //i
        .resetCtrl_systemReset(resetCtrl_systemReset)                                            //i
    );
`ifndef SYNTHESIS
    always @(*) begin
        case (_zz_execute_to_memory_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_execute_to_memory_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_execute_to_memory_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_execute_to_memory_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_execute_to_memory_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_execute_to_memory_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_to_memory_SHIFT_CTRL_1)
            ShiftCtrlEnum_DISABLE_1: _zz_execute_to_memory_SHIFT_CTRL_1_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_execute_to_memory_SHIFT_CTRL_1_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_execute_to_memory_SHIFT_CTRL_1_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_execute_to_memory_SHIFT_CTRL_1_string = "SRA_1    ";
            default: _zz_execute_to_memory_SHIFT_CTRL_1_string = "?????????";
        endcase
    end
    always @(*) begin
        case (decode_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: decode_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: decode_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: decode_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: decode_SHIFT_CTRL_string = "SRA_1    ";
            default: decode_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_decode_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_decode_to_execute_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_SHIFT_CTRL_1)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_to_execute_SHIFT_CTRL_1_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_to_execute_SHIFT_CTRL_1_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_to_execute_SHIFT_CTRL_1_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_to_execute_SHIFT_CTRL_1_string = "SRA_1    ";
            default: _zz_decode_to_execute_SHIFT_CTRL_1_string = "?????????";
        endcase
    end
    always @(*) begin
        case (decode_BRANCH_CTRL)
            BranchCtrlEnum_INC: decode_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: decode_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: decode_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: decode_BRANCH_CTRL_string = "JALR";
            default: decode_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_BRANCH_CTRL)
            BranchCtrlEnum_INC: _zz_decode_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_BRANCH_CTRL_string = "JALR";
            default: _zz_decode_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: _zz_decode_to_execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_to_execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_to_execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_to_execute_BRANCH_CTRL_string = "JALR";
            default: _zz_decode_to_execute_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_BRANCH_CTRL_1)
            BranchCtrlEnum_INC: _zz_decode_to_execute_BRANCH_CTRL_1_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_to_execute_BRANCH_CTRL_1_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_to_execute_BRANCH_CTRL_1_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_to_execute_BRANCH_CTRL_1_string = "JALR";
            default: _zz_decode_to_execute_BRANCH_CTRL_1_string = "????";
        endcase
    end
    always @(*) begin
        case (decode_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: decode_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: decode_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: decode_ALU_BITWISE_CTRL_string = "AND_1";
            default: decode_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_ALU_BITWISE_CTRL_string = "AND_1";
            default: _zz_decode_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
            default: _zz_decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ALU_BITWISE_CTRL_1)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "AND_1";
            default: _zz_decode_to_execute_ALU_BITWISE_CTRL_1_string = "?????";
        endcase
    end
    always @(*) begin
        case (decode_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: decode_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: decode_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: decode_ALU_CTRL_string = "BITWISE ";
            default: decode_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: _zz_decode_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_ALU_CTRL_string = "BITWISE ";
            default: _zz_decode_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: _zz_decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_to_execute_ALU_CTRL_string = "BITWISE ";
            default: _zz_decode_to_execute_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ALU_CTRL_1)
            AluCtrlEnum_ADD_SUB: _zz_decode_to_execute_ALU_CTRL_1_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_to_execute_ALU_CTRL_1_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_to_execute_ALU_CTRL_1_string = "BITWISE ";
            default: _zz_decode_to_execute_ALU_CTRL_1_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_memory_to_writeBack_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_memory_to_writeBack_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_memory_to_writeBack_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_memory_to_writeBack_ENV_CTRL_string = "ECALL";
            default: _zz_memory_to_writeBack_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_memory_to_writeBack_ENV_CTRL_1)
            EnvCtrlEnum_NONE: _zz_memory_to_writeBack_ENV_CTRL_1_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_memory_to_writeBack_ENV_CTRL_1_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_memory_to_writeBack_ENV_CTRL_1_string = "ECALL";
            default: _zz_memory_to_writeBack_ENV_CTRL_1_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_to_memory_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_execute_to_memory_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_execute_to_memory_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_execute_to_memory_ENV_CTRL_string = "ECALL";
            default: _zz_execute_to_memory_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_to_memory_ENV_CTRL_1)
            EnvCtrlEnum_NONE: _zz_execute_to_memory_ENV_CTRL_1_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_execute_to_memory_ENV_CTRL_1_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_execute_to_memory_ENV_CTRL_1_string = "ECALL";
            default: _zz_execute_to_memory_ENV_CTRL_1_string = "?????";
        endcase
    end
    always @(*) begin
        case (decode_ENV_CTRL)
            EnvCtrlEnum_NONE: decode_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: decode_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: decode_ENV_CTRL_string = "ECALL";
            default: decode_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_decode_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_decode_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_decode_ENV_CTRL_string = "ECALL";
            default: _zz_decode_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_decode_to_execute_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_decode_to_execute_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_decode_to_execute_ENV_CTRL_string = "ECALL";
            default: _zz_decode_to_execute_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_to_execute_ENV_CTRL_1)
            EnvCtrlEnum_NONE: _zz_decode_to_execute_ENV_CTRL_1_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_decode_to_execute_ENV_CTRL_1_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_decode_to_execute_ENV_CTRL_1_string = "ECALL";
            default: _zz_decode_to_execute_ENV_CTRL_1_string = "?????";
        endcase
    end
    always @(*) begin
        case (memory_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: memory_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: memory_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: memory_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: memory_SHIFT_CTRL_string = "SRA_1    ";
            default: memory_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_memory_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_memory_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_memory_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_memory_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_memory_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_memory_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (execute_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: execute_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: execute_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: execute_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: execute_SHIFT_CTRL_string = "SRA_1    ";
            default: execute_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: _zz_execute_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_execute_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_execute_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_execute_SHIFT_CTRL_string = "SRA_1    ";
            default: _zz_execute_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: execute_BRANCH_CTRL_string = "JALR";
            default: execute_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: _zz_execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: _zz_execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: _zz_execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_execute_BRANCH_CTRL_string = "JALR";
            default: _zz_execute_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (decode_SRC2_CTRL)
            Src2CtrlEnum_RS: decode_SRC2_CTRL_string = "RS ";
            Src2CtrlEnum_IMI: decode_SRC2_CTRL_string = "IMI";
            Src2CtrlEnum_IMS: decode_SRC2_CTRL_string = "IMS";
            Src2CtrlEnum_PC: decode_SRC2_CTRL_string = "PC ";
            default: decode_SRC2_CTRL_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC2_CTRL)
            Src2CtrlEnum_RS: _zz_decode_SRC2_CTRL_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_SRC2_CTRL_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_SRC2_CTRL_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_SRC2_CTRL_string = "PC ";
            default: _zz_decode_SRC2_CTRL_string = "???";
        endcase
    end
    always @(*) begin
        case (decode_SRC1_CTRL)
            Src1CtrlEnum_RS: decode_SRC1_CTRL_string = "RS          ";
            Src1CtrlEnum_IMU: decode_SRC1_CTRL_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: decode_SRC1_CTRL_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: decode_SRC1_CTRL_string = "URS1        ";
            default: decode_SRC1_CTRL_string = "????????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC1_CTRL)
            Src1CtrlEnum_RS: _zz_decode_SRC1_CTRL_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_SRC1_CTRL_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_SRC1_CTRL_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_SRC1_CTRL_string = "URS1        ";
            default: _zz_decode_SRC1_CTRL_string = "????????????";
        endcase
    end
    always @(*) begin
        case (execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: execute_ALU_CTRL_string = "BITWISE ";
            default: execute_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: _zz_execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_execute_ALU_CTRL_string = "BITWISE ";
            default: _zz_execute_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: execute_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: execute_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: execute_ALU_BITWISE_CTRL_string = "AND_1";
            default: execute_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: _zz_execute_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_execute_ALU_BITWISE_CTRL_string = "AND_1";
            default: _zz_execute_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SHIFT_CTRL_1)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_SHIFT_CTRL_1_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_SHIFT_CTRL_1_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_SHIFT_CTRL_1_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_SHIFT_CTRL_1_string = "SRA_1    ";
            default: _zz_decode_SHIFT_CTRL_1_string = "?????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_BRANCH_CTRL_1)
            BranchCtrlEnum_INC: _zz_decode_BRANCH_CTRL_1_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_BRANCH_CTRL_1_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_BRANCH_CTRL_1_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_BRANCH_CTRL_1_string = "JALR";
            default: _zz_decode_BRANCH_CTRL_1_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_BITWISE_CTRL_1)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_ALU_BITWISE_CTRL_1_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_ALU_BITWISE_CTRL_1_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_ALU_BITWISE_CTRL_1_string = "AND_1";
            default: _zz_decode_ALU_BITWISE_CTRL_1_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_CTRL_1)
            AluCtrlEnum_ADD_SUB: _zz_decode_ALU_CTRL_1_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_ALU_CTRL_1_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_ALU_CTRL_1_string = "BITWISE ";
            default: _zz_decode_ALU_CTRL_1_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ENV_CTRL_1)
            EnvCtrlEnum_NONE: _zz_decode_ENV_CTRL_1_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_decode_ENV_CTRL_1_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_decode_ENV_CTRL_1_string = "ECALL";
            default: _zz_decode_ENV_CTRL_1_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC2_CTRL_1)
            Src2CtrlEnum_RS: _zz_decode_SRC2_CTRL_1_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_SRC2_CTRL_1_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_SRC2_CTRL_1_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_SRC2_CTRL_1_string = "PC ";
            default: _zz_decode_SRC2_CTRL_1_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC1_CTRL_1)
            Src1CtrlEnum_RS: _zz_decode_SRC1_CTRL_1_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_SRC1_CTRL_1_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_SRC1_CTRL_1_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_SRC1_CTRL_1_string = "URS1        ";
            default: _zz_decode_SRC1_CTRL_1_string = "????????????";
        endcase
    end
    always @(*) begin
        case (memory_ENV_CTRL)
            EnvCtrlEnum_NONE: memory_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: memory_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: memory_ENV_CTRL_string = "ECALL";
            default: memory_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_memory_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_memory_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_memory_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_memory_ENV_CTRL_string = "ECALL";
            default: _zz_memory_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (execute_ENV_CTRL)
            EnvCtrlEnum_NONE: execute_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: execute_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: execute_ENV_CTRL_string = "ECALL";
            default: execute_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_execute_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_execute_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_execute_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_execute_ENV_CTRL_string = "ECALL";
            default: _zz_execute_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (writeBack_ENV_CTRL)
            EnvCtrlEnum_NONE: writeBack_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: writeBack_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: writeBack_ENV_CTRL_string = "ECALL";
            default: writeBack_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_writeBack_ENV_CTRL)
            EnvCtrlEnum_NONE: _zz_writeBack_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_writeBack_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_writeBack_ENV_CTRL_string = "ECALL";
            default: _zz_writeBack_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC1_CTRL_2)
            Src1CtrlEnum_RS: _zz_decode_SRC1_CTRL_2_string = "RS          ";
            Src1CtrlEnum_IMU: _zz_decode_SRC1_CTRL_2_string = "IMU         ";
            Src1CtrlEnum_PC_INCREMENT: _zz_decode_SRC1_CTRL_2_string = "PC_INCREMENT";
            Src1CtrlEnum_URS1: _zz_decode_SRC1_CTRL_2_string = "URS1        ";
            default: _zz_decode_SRC1_CTRL_2_string = "????????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SRC2_CTRL_2)
            Src2CtrlEnum_RS: _zz_decode_SRC2_CTRL_2_string = "RS ";
            Src2CtrlEnum_IMI: _zz_decode_SRC2_CTRL_2_string = "IMI";
            Src2CtrlEnum_IMS: _zz_decode_SRC2_CTRL_2_string = "IMS";
            Src2CtrlEnum_PC: _zz_decode_SRC2_CTRL_2_string = "PC ";
            default: _zz_decode_SRC2_CTRL_2_string = "???";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ENV_CTRL_2)
            EnvCtrlEnum_NONE: _zz_decode_ENV_CTRL_2_string = "NONE ";
            EnvCtrlEnum_XRET: _zz_decode_ENV_CTRL_2_string = "XRET ";
            EnvCtrlEnum_ECALL: _zz_decode_ENV_CTRL_2_string = "ECALL";
            default: _zz_decode_ENV_CTRL_2_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_CTRL_2)
            AluCtrlEnum_ADD_SUB: _zz_decode_ALU_CTRL_2_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: _zz_decode_ALU_CTRL_2_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: _zz_decode_ALU_CTRL_2_string = "BITWISE ";
            default: _zz_decode_ALU_CTRL_2_string = "????????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_ALU_BITWISE_CTRL_2)
            AluBitwiseCtrlEnum_XOR_1: _zz_decode_ALU_BITWISE_CTRL_2_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: _zz_decode_ALU_BITWISE_CTRL_2_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: _zz_decode_ALU_BITWISE_CTRL_2_string = "AND_1";
            default: _zz_decode_ALU_BITWISE_CTRL_2_string = "?????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_BRANCH_CTRL_2)
            BranchCtrlEnum_INC: _zz_decode_BRANCH_CTRL_2_string = "INC ";
            BranchCtrlEnum_B: _zz_decode_BRANCH_CTRL_2_string = "B   ";
            BranchCtrlEnum_JAL: _zz_decode_BRANCH_CTRL_2_string = "JAL ";
            BranchCtrlEnum_JALR: _zz_decode_BRANCH_CTRL_2_string = "JALR";
            default: _zz_decode_BRANCH_CTRL_2_string = "????";
        endcase
    end
    always @(*) begin
        case (_zz_decode_SHIFT_CTRL_2)
            ShiftCtrlEnum_DISABLE_1: _zz_decode_SHIFT_CTRL_2_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: _zz_decode_SHIFT_CTRL_2_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: _zz_decode_SHIFT_CTRL_2_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: _zz_decode_SHIFT_CTRL_2_string = "SRA_1    ";
            default: _zz_decode_SHIFT_CTRL_2_string = "?????????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_ENV_CTRL)
            EnvCtrlEnum_NONE: decode_to_execute_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: decode_to_execute_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: decode_to_execute_ENV_CTRL_string = "ECALL";
            default: decode_to_execute_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (execute_to_memory_ENV_CTRL)
            EnvCtrlEnum_NONE: execute_to_memory_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: execute_to_memory_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: execute_to_memory_ENV_CTRL_string = "ECALL";
            default: execute_to_memory_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (memory_to_writeBack_ENV_CTRL)
            EnvCtrlEnum_NONE: memory_to_writeBack_ENV_CTRL_string = "NONE ";
            EnvCtrlEnum_XRET: memory_to_writeBack_ENV_CTRL_string = "XRET ";
            EnvCtrlEnum_ECALL: memory_to_writeBack_ENV_CTRL_string = "ECALL";
            default: memory_to_writeBack_ENV_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_ALU_CTRL)
            AluCtrlEnum_ADD_SUB: decode_to_execute_ALU_CTRL_string = "ADD_SUB ";
            AluCtrlEnum_SLT_SLTU: decode_to_execute_ALU_CTRL_string = "SLT_SLTU";
            AluCtrlEnum_BITWISE: decode_to_execute_ALU_CTRL_string = "BITWISE ";
            default: decode_to_execute_ALU_CTRL_string = "????????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_XOR_1: decode_to_execute_ALU_BITWISE_CTRL_string = "XOR_1";
            AluBitwiseCtrlEnum_OR_1: decode_to_execute_ALU_BITWISE_CTRL_string = "OR_1 ";
            AluBitwiseCtrlEnum_AND_1: decode_to_execute_ALU_BITWISE_CTRL_string = "AND_1";
            default: decode_to_execute_ALU_BITWISE_CTRL_string = "?????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: decode_to_execute_BRANCH_CTRL_string = "INC ";
            BranchCtrlEnum_B: decode_to_execute_BRANCH_CTRL_string = "B   ";
            BranchCtrlEnum_JAL: decode_to_execute_BRANCH_CTRL_string = "JAL ";
            BranchCtrlEnum_JALR: decode_to_execute_BRANCH_CTRL_string = "JALR";
            default: decode_to_execute_BRANCH_CTRL_string = "????";
        endcase
    end
    always @(*) begin
        case (decode_to_execute_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: decode_to_execute_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: decode_to_execute_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: decode_to_execute_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: decode_to_execute_SHIFT_CTRL_string = "SRA_1    ";
            default: decode_to_execute_SHIFT_CTRL_string = "?????????";
        endcase
    end
    always @(*) begin
        case (execute_to_memory_SHIFT_CTRL)
            ShiftCtrlEnum_DISABLE_1: execute_to_memory_SHIFT_CTRL_string = "DISABLE_1";
            ShiftCtrlEnum_SLL_1: execute_to_memory_SHIFT_CTRL_string = "SLL_1    ";
            ShiftCtrlEnum_SRL_1: execute_to_memory_SHIFT_CTRL_string = "SRL_1    ";
            ShiftCtrlEnum_SRA_1: execute_to_memory_SHIFT_CTRL_string = "SRA_1    ";
            default: execute_to_memory_SHIFT_CTRL_string = "?????????";
        endcase
    end
`endif

    assign memory_MUL_LOW = ($signed(_zz_memory_MUL_LOW) + $signed(_zz_memory_MUL_LOW_6));
    assign memory_MEMORY_READ_DATA = dBus_rsp_data;
    assign execute_SHIFT_RIGHT = _zz_execute_SHIFT_RIGHT;
    assign execute_BRANCH_CALC = {execute_BranchPlugin_branchAdder[31 : 1], 1'b0};
    assign execute_BRANCH_DO = _zz_execute_BRANCH_DO_1;
    assign memory_MUL_HH = execute_to_memory_MUL_HH;
    assign execute_MUL_HH = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bHigh));
    assign execute_MUL_HL = ($signed(execute_MulPlugin_aHigh) * $signed(execute_MulPlugin_bSLow));
    assign execute_MUL_LH = ($signed(execute_MulPlugin_aSLow) * $signed(execute_MulPlugin_bHigh));
    assign execute_MUL_LL = (execute_MulPlugin_aULow * execute_MulPlugin_bULow);
    assign writeBack_REGFILE_WRITE_DATA = memory_to_writeBack_REGFILE_WRITE_DATA;
    assign memory_REGFILE_WRITE_DATA = execute_to_memory_REGFILE_WRITE_DATA;
    assign execute_REGFILE_WRITE_DATA = _zz_execute_REGFILE_WRITE_DATA;
    assign memory_MEMORY_ADDRESS_LOW = execute_to_memory_MEMORY_ADDRESS_LOW;
    assign execute_MEMORY_ADDRESS_LOW = dBus_cmd_payload_address[1 : 0];
    assign decode_DO_EBREAK = (((! DebugPlugin_haltIt) && (decode_IS_EBREAK || 1'b0)) && DebugPlugin_allowEBreak);
    assign decode_SRC2 = _zz_decode_SRC2_4;
    assign decode_SRC1 = _zz_decode_SRC1;
    assign decode_SRC2_FORCE_ZERO = (decode_SRC_ADD_ZERO && (!decode_SRC_USE_SUB_LESS));
    assign _zz_execute_to_memory_SHIFT_CTRL = _zz_execute_to_memory_SHIFT_CTRL_1;
    assign decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL;
    assign _zz_decode_to_execute_SHIFT_CTRL = _zz_decode_to_execute_SHIFT_CTRL_1;
    assign decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL;
    assign _zz_decode_to_execute_BRANCH_CTRL = _zz_decode_to_execute_BRANCH_CTRL_1;
    assign decode_IS_RS2_SIGNED = _zz_decode_IS_RS2_SIGNED[25];
    assign decode_IS_RS1_SIGNED = _zz_decode_IS_RS2_SIGNED[24];
    assign decode_IS_DIV = _zz_decode_IS_RS2_SIGNED[23];
    assign memory_IS_MUL = execute_to_memory_IS_MUL;
    assign execute_IS_MUL = decode_to_execute_IS_MUL;
    assign decode_IS_MUL = _zz_decode_IS_RS2_SIGNED[22];
    assign decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL;
    assign _zz_decode_to_execute_ALU_BITWISE_CTRL = _zz_decode_to_execute_ALU_BITWISE_CTRL_1;
    assign decode_SRC_LESS_UNSIGNED = _zz_decode_IS_RS2_SIGNED[18];
    assign decode_ALU_CTRL = _zz_decode_ALU_CTRL;
    assign _zz_decode_to_execute_ALU_CTRL = _zz_decode_to_execute_ALU_CTRL_1;
    assign _zz_memory_to_writeBack_ENV_CTRL = _zz_memory_to_writeBack_ENV_CTRL_1;
    assign _zz_execute_to_memory_ENV_CTRL = _zz_execute_to_memory_ENV_CTRL_1;
    assign decode_ENV_CTRL = _zz_decode_ENV_CTRL;
    assign _zz_decode_to_execute_ENV_CTRL = _zz_decode_to_execute_ENV_CTRL_1;
    assign decode_IS_CSR = _zz_decode_IS_RS2_SIGNED[13];
    assign decode_MEMORY_STORE = _zz_decode_IS_RS2_SIGNED[10];
    assign execute_BYPASSABLE_MEMORY_STAGE = decode_to_execute_BYPASSABLE_MEMORY_STAGE;
    assign decode_BYPASSABLE_MEMORY_STAGE = _zz_decode_IS_RS2_SIGNED[9];
    assign decode_BYPASSABLE_EXECUTE_STAGE = _zz_decode_IS_RS2_SIGNED[8];
    assign decode_MEMORY_ENABLE = _zz_decode_IS_RS2_SIGNED[3];
    assign decode_CSR_READ_OPCODE = (decode_INSTRUCTION[13 : 7] != 7'h20);
    assign decode_CSR_WRITE_OPCODE = (! (((decode_INSTRUCTION[14 : 13] == 2'b01) && (decode_INSTRUCTION[19 : 15] == 5'h0)) || ((decode_INSTRUCTION[14 : 13] == 2'b11) && (decode_INSTRUCTION[19 : 15] == 5'h0))));
    assign writeBack_FORMAL_PC_NEXT = memory_to_writeBack_FORMAL_PC_NEXT;
    assign memory_FORMAL_PC_NEXT = execute_to_memory_FORMAL_PC_NEXT;
    assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
    assign decode_FORMAL_PC_NEXT = (decode_PC + 32'h00000004);
    assign memory_PC = execute_to_memory_PC;
    assign execute_DO_EBREAK = decode_to_execute_DO_EBREAK;
    assign decode_IS_EBREAK = _zz_decode_IS_RS2_SIGNED[30];
    assign memory_SHIFT_RIGHT = execute_to_memory_SHIFT_RIGHT;
    assign memory_SHIFT_CTRL = _zz_memory_SHIFT_CTRL;
    assign execute_SHIFT_CTRL = _zz_execute_SHIFT_CTRL;
    assign memory_BRANCH_CALC = execute_to_memory_BRANCH_CALC;
    assign memory_BRANCH_DO = execute_to_memory_BRANCH_DO;
    assign execute_PC = decode_to_execute_PC;
    assign execute_BRANCH_CTRL = _zz_execute_BRANCH_CTRL;
    assign execute_IS_RS1_SIGNED = decode_to_execute_IS_RS1_SIGNED;
    assign execute_IS_DIV = decode_to_execute_IS_DIV;
    assign execute_IS_RS2_SIGNED = decode_to_execute_IS_RS2_SIGNED;
    assign memory_IS_DIV = execute_to_memory_IS_DIV;
    assign writeBack_IS_MUL = memory_to_writeBack_IS_MUL;
    assign writeBack_MUL_HH = memory_to_writeBack_MUL_HH;
    assign writeBack_MUL_LOW = memory_to_writeBack_MUL_LOW;
    assign memory_MUL_HL = execute_to_memory_MUL_HL;
    assign memory_MUL_LH = execute_to_memory_MUL_LH;
    assign memory_MUL_LL = execute_to_memory_MUL_LL;
    assign execute_RS1 = decode_to_execute_RS1;
    assign decode_RS2_USE = _zz_decode_IS_RS2_SIGNED[12];
    assign decode_RS1_USE = _zz_decode_IS_RS2_SIGNED[4];
    assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
    assign execute_BYPASSABLE_EXECUTE_STAGE = decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
    always @(*) begin
        _zz_decode_RS2 = memory_REGFILE_WRITE_DATA;
        if (when_MulDivIterativePlugin_l128) begin
            _zz_decode_RS2 = memory_DivPlugin_div_result;
        end
        if (memory_arbitration_isValid) begin
            case (memory_SHIFT_CTRL)
                ShiftCtrlEnum_SLL_1: begin
                    _zz_decode_RS2 = _zz_decode_RS2_3;
                end
                ShiftCtrlEnum_SRL_1, ShiftCtrlEnum_SRA_1: begin
                    _zz_decode_RS2 = memory_SHIFT_RIGHT;
                end
                default: begin
                end
            endcase
        end
    end

    assign memory_REGFILE_WRITE_VALID = execute_to_memory_REGFILE_WRITE_VALID;
    assign memory_INSTRUCTION = execute_to_memory_INSTRUCTION;
    assign memory_BYPASSABLE_MEMORY_STAGE = execute_to_memory_BYPASSABLE_MEMORY_STAGE;
    assign writeBack_REGFILE_WRITE_VALID = memory_to_writeBack_REGFILE_WRITE_VALID;
    always @(*) begin
        decode_RS2 = decode_RegFilePlugin_rs2Data;
        if (HazardSimplePlugin_writeBackBuffer_valid) begin
            if (HazardSimplePlugin_addr1Match) begin
                decode_RS2 = HazardSimplePlugin_writeBackBuffer_payload_data;
            end
        end
        if (when_HazardSimplePlugin_l45) begin
            if (when_HazardSimplePlugin_l47) begin
                if (when_HazardSimplePlugin_l51) begin
                    decode_RS2 = _zz_decode_RS2_2;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_1) begin
            if (memory_BYPASSABLE_MEMORY_STAGE) begin
                if (when_HazardSimplePlugin_l51_1) begin
                    decode_RS2 = _zz_decode_RS2;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_2) begin
            if (execute_BYPASSABLE_EXECUTE_STAGE) begin
                if (when_HazardSimplePlugin_l51_2) begin
                    decode_RS2 = _zz_decode_RS2_1;
                end
            end
        end
    end

    always @(*) begin
        decode_RS1 = decode_RegFilePlugin_rs1Data;
        if (HazardSimplePlugin_writeBackBuffer_valid) begin
            if (HazardSimplePlugin_addr0Match) begin
                decode_RS1 = HazardSimplePlugin_writeBackBuffer_payload_data;
            end
        end
        if (when_HazardSimplePlugin_l45) begin
            if (when_HazardSimplePlugin_l47) begin
                if (when_HazardSimplePlugin_l48) begin
                    decode_RS1 = _zz_decode_RS2_2;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_1) begin
            if (memory_BYPASSABLE_MEMORY_STAGE) begin
                if (when_HazardSimplePlugin_l48_1) begin
                    decode_RS1 = _zz_decode_RS2;
                end
            end
        end
        if (when_HazardSimplePlugin_l45_2) begin
            if (execute_BYPASSABLE_EXECUTE_STAGE) begin
                if (when_HazardSimplePlugin_l48_2) begin
                    decode_RS1 = _zz_decode_RS2_1;
                end
            end
        end
    end

    assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
    assign execute_SRC2_FORCE_ZERO = decode_to_execute_SRC2_FORCE_ZERO;
    assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
    assign _zz_decode_to_execute_PC = decode_PC;
    assign _zz_decode_to_execute_RS2 = decode_RS2;
    assign decode_SRC2_CTRL = _zz_decode_SRC2_CTRL;
    assign _zz_decode_to_execute_RS1 = decode_RS1;
    assign decode_SRC1_CTRL = _zz_decode_SRC1_CTRL;
    assign decode_SRC_USE_SUB_LESS = _zz_decode_IS_RS2_SIGNED[2];
    assign decode_SRC_ADD_ZERO = _zz_decode_IS_RS2_SIGNED[21];
    assign execute_SRC_ADD_SUB = execute_SrcPlugin_addSub;
    assign execute_SRC_LESS = execute_SrcPlugin_less;
    assign execute_ALU_CTRL = _zz_execute_ALU_CTRL;
    assign execute_SRC2 = decode_to_execute_SRC2;
    assign execute_ALU_BITWISE_CTRL = _zz_execute_ALU_BITWISE_CTRL;
    assign _zz_lastStageRegFileWrite_payload_address = writeBack_INSTRUCTION;
    assign _zz_lastStageRegFileWrite_valid = writeBack_REGFILE_WRITE_VALID;
    always @(*) begin
        _zz_1 = 1'b0;
        if (lastStageRegFileWrite_valid) begin
            _zz_1 = 1'b1;
        end
    end

    assign decode_INSTRUCTION_ANTICIPATED = (decode_arbitration_isStuck ? decode_INSTRUCTION : IBusSimplePlugin_iBusRsp_output_payload_rsp_inst);
    always @(*) begin
        decode_REGFILE_WRITE_VALID = _zz_decode_IS_RS2_SIGNED[7];
        if (when_RegFilePlugin_l63) begin
            decode_REGFILE_WRITE_VALID = 1'b0;
        end
    end

    always @(*) begin
        _zz_decode_RS2_1 = execute_REGFILE_WRITE_DATA;
        if (when_CsrPlugin_l1587) begin
            _zz_decode_RS2_1 = CsrPlugin_csrMapping_readDataSignal;
        end
    end

    assign execute_SRC1 = decode_to_execute_SRC1;
    assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
    assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
    assign execute_IS_CSR = decode_to_execute_IS_CSR;
    assign memory_ENV_CTRL = _zz_memory_ENV_CTRL;
    assign execute_ENV_CTRL = _zz_execute_ENV_CTRL;
    assign writeBack_ENV_CTRL = _zz_writeBack_ENV_CTRL;
    always @(*) begin
        _zz_decode_RS2_2 = writeBack_REGFILE_WRITE_DATA;
        if (when_DBusSimplePlugin_l565) begin
            _zz_decode_RS2_2 = writeBack_DBusSimplePlugin_rspFormated;
        end
        if (when_MulPlugin_l147) begin
            case (switch_MulPlugin_l148)
                2'b00: begin
                    _zz_decode_RS2_2 = _zz__zz_decode_RS2_2;
                end
                default: begin
                    _zz_decode_RS2_2 = _zz__zz_decode_RS2_2_1;
                end
            endcase
        end
    end

    assign writeBack_MEMORY_ENABLE = memory_to_writeBack_MEMORY_ENABLE;
    assign writeBack_MEMORY_ADDRESS_LOW = memory_to_writeBack_MEMORY_ADDRESS_LOW;
    assign writeBack_MEMORY_READ_DATA = memory_to_writeBack_MEMORY_READ_DATA;
    assign memory_MEMORY_STORE = execute_to_memory_MEMORY_STORE;
    assign memory_MEMORY_ENABLE = execute_to_memory_MEMORY_ENABLE;
    assign execute_SRC_ADD = execute_SrcPlugin_addSub;
    assign execute_RS2 = decode_to_execute_RS2;
    assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
    assign execute_MEMORY_STORE = decode_to_execute_MEMORY_STORE;
    assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
    assign execute_ALIGNEMENT_FAULT = 1'b0;
    always @(*) begin
        _zz_memory_to_writeBack_FORMAL_PC_NEXT = memory_FORMAL_PC_NEXT;
        if (BranchPlugin_jumpInterface_valid) begin
            _zz_memory_to_writeBack_FORMAL_PC_NEXT = BranchPlugin_jumpInterface_payload;
        end
    end

    assign decode_PC = IBusSimplePlugin_injector_decodeInput_payload_pc;
    assign decode_INSTRUCTION = IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
    assign writeBack_PC = memory_to_writeBack_PC;
    assign writeBack_INSTRUCTION = memory_to_writeBack_INSTRUCTION;
    always @(*) begin
        decode_arbitration_haltItself = 1'b0;
        case (IBusSimplePlugin_injector_port_state)
            3'b010: begin
                decode_arbitration_haltItself = 1'b1;
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        decode_arbitration_haltByOther = 1'b0;
        if (CsrPlugin_pipelineLiberator_active) begin
            decode_arbitration_haltByOther = 1'b1;
        end
        if (when_CsrPlugin_l1527) begin
            decode_arbitration_haltByOther = 1'b1;
        end
        if (when_HazardSimplePlugin_l113) begin
            decode_arbitration_haltByOther = 1'b1;
        end
    end

    always @(*) begin
        decode_arbitration_removeIt = 1'b0;
        if (decode_arbitration_isFlushed) begin
            decode_arbitration_removeIt = 1'b1;
        end
    end

    assign decode_arbitration_flushIt   = 1'b0;
    assign decode_arbitration_flushNext = 1'b0;
    always @(*) begin
        execute_arbitration_haltItself = 1'b0;
        if (when_DBusSimplePlugin_l434) begin
            execute_arbitration_haltItself = 1'b1;
        end
        if (when_CsrPlugin_l1591) begin
            if (execute_CsrPlugin_blockedBySideEffects) begin
                execute_arbitration_haltItself = 1'b1;
            end
        end
    end

    always @(*) begin
        execute_arbitration_haltByOther = 1'b0;
        if (when_DebugPlugin_l308) begin
            execute_arbitration_haltByOther = 1'b1;
        end
    end

    always @(*) begin
        execute_arbitration_removeIt = 1'b0;
        if (CsrPlugin_selfException_valid) begin
            execute_arbitration_removeIt = 1'b1;
        end
        if (execute_arbitration_isFlushed) begin
            execute_arbitration_removeIt = 1'b1;
        end
    end

    always @(*) begin
        execute_arbitration_flushIt = 1'b0;
        if (when_DebugPlugin_l308) begin
            if (when_DebugPlugin_l311) begin
                execute_arbitration_flushIt = 1'b1;
            end
        end
    end

    always @(*) begin
        execute_arbitration_flushNext = 1'b0;
        if (CsrPlugin_selfException_valid) begin
            execute_arbitration_flushNext = 1'b1;
        end
        if (when_DebugPlugin_l308) begin
            if (when_DebugPlugin_l311) begin
                execute_arbitration_flushNext = 1'b1;
            end
        end
    end

    always @(*) begin
        memory_arbitration_haltItself = 1'b0;
        if (when_DBusSimplePlugin_l489) begin
            memory_arbitration_haltItself = 1'b1;
        end
        if (when_MulDivIterativePlugin_l128) begin
            if (when_MulDivIterativePlugin_l129) begin
                memory_arbitration_haltItself = 1'b1;
            end
        end
    end

    assign memory_arbitration_haltByOther = 1'b0;
    always @(*) begin
        memory_arbitration_removeIt = 1'b0;
        if (memory_arbitration_isFlushed) begin
            memory_arbitration_removeIt = 1'b1;
        end
    end

    assign memory_arbitration_flushIt = 1'b0;
    always @(*) begin
        memory_arbitration_flushNext = 1'b0;
        if (BranchPlugin_jumpInterface_valid) begin
            memory_arbitration_flushNext = 1'b1;
        end
    end

    assign writeBack_arbitration_haltItself  = 1'b0;
    assign writeBack_arbitration_haltByOther = 1'b0;
    always @(*) begin
        writeBack_arbitration_removeIt = 1'b0;
        if (writeBack_arbitration_isFlushed) begin
            writeBack_arbitration_removeIt = 1'b1;
        end
    end

    assign writeBack_arbitration_flushIt = 1'b0;
    always @(*) begin
        writeBack_arbitration_flushNext = 1'b0;
        if (when_CsrPlugin_l1390) begin
            writeBack_arbitration_flushNext = 1'b1;
        end
        if (when_CsrPlugin_l1456) begin
            writeBack_arbitration_flushNext = 1'b1;
        end
    end

    assign lastStageInstruction = writeBack_INSTRUCTION;
    assign lastStagePc = writeBack_PC;
    assign lastStageIsValid = writeBack_arbitration_isValid;
    assign lastStageIsFiring = writeBack_arbitration_isFiring;
    always @(*) begin
        IBusSimplePlugin_fetcherHalt = 1'b0;
        if (when_CsrPlugin_l1272) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
        if (when_CsrPlugin_l1390) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
        if (when_CsrPlugin_l1456) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
        if (when_DebugPlugin_l308) begin
            if (when_DebugPlugin_l311) begin
                IBusSimplePlugin_fetcherHalt = 1'b1;
            end
        end
        if (DebugPlugin_haltIt) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
        if (when_DebugPlugin_l324) begin
            IBusSimplePlugin_fetcherHalt = 1'b1;
        end
    end

    assign IBusSimplePlugin_forceNoDecodeCond = 1'b0;
    always @(*) begin
        IBusSimplePlugin_incomingInstruction = 1'b0;
        if (when_Fetcher_l242) begin
            IBusSimplePlugin_incomingInstruction = 1'b1;
        end
        if (IBusSimplePlugin_injector_decodeInput_valid) begin
            IBusSimplePlugin_incomingInstruction = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_csrMapping_allowCsrSignal = 1'b0;
        if (when_CsrPlugin_l1702) begin
            CsrPlugin_csrMapping_allowCsrSignal = 1'b1;
        end
        if (when_CsrPlugin_l1709) begin
            CsrPlugin_csrMapping_allowCsrSignal = 1'b1;
        end
    end

    assign CsrPlugin_csrMapping_doForceFailCsr = 1'b0;
    assign CsrPlugin_csrMapping_readDataSignal = CsrPlugin_csrMapping_readDataInit;
    assign CsrPlugin_inWfi = 1'b0;
    always @(*) begin
        CsrPlugin_thirdPartyWake = 1'b0;
        if (DebugPlugin_haltIt) begin
            CsrPlugin_thirdPartyWake = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_jumpInterface_valid = 1'b0;
        if (when_CsrPlugin_l1390) begin
            CsrPlugin_jumpInterface_valid = 1'b1;
        end
        if (when_CsrPlugin_l1456) begin
            CsrPlugin_jumpInterface_valid = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_jumpInterface_payload = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        if (when_CsrPlugin_l1390) begin
            CsrPlugin_jumpInterface_payload = {CsrPlugin_xtvec_base, 2'b00};
        end
        if (when_CsrPlugin_l1456) begin
            case (switch_CsrPlugin_l1460)
                2'b11: begin
                    CsrPlugin_jumpInterface_payload = CsrPlugin_mepc;
                end
                default: begin
                end
            endcase
        end
    end

    always @(*) begin
        CsrPlugin_forceMachineWire = 1'b0;
        if (DebugPlugin_godmode) begin
            CsrPlugin_forceMachineWire = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_allowInterrupts = 1'b1;
        if (when_DebugPlugin_l344) begin
            CsrPlugin_allowInterrupts = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_allowException = 1'b1;
        if (DebugPlugin_godmode) begin
            CsrPlugin_allowException = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_allowEbreakException = 1'b1;
        if (DebugPlugin_allowEBreak) begin
            CsrPlugin_allowEbreakException = 1'b0;
        end
    end

    assign CsrPlugin_xretAwayFromMachine = 1'b0;
    always @(*) begin
        BranchPlugin_inDebugNoFetchFlag = 1'b0;
        if (DebugPlugin_godmode) begin
            BranchPlugin_inDebugNoFetchFlag = 1'b1;
        end
    end

    assign IBusSimplePlugin_externalFlush = (|{writeBack_arbitration_flushNext, {
        memory_arbitration_flushNext, {execute_arbitration_flushNext, decode_arbitration_flushNext}
    }});
    assign IBusSimplePlugin_jump_pcLoad_valid = (|{BranchPlugin_jumpInterface_valid,CsrPlugin_jumpInterface_valid});
    assign _zz_IBusSimplePlugin_jump_pcLoad_payload = {
        BranchPlugin_jumpInterface_valid, CsrPlugin_jumpInterface_valid
    };
    assign IBusSimplePlugin_jump_pcLoad_payload = (_zz_IBusSimplePlugin_jump_pcLoad_payload_1[0] ? CsrPlugin_jumpInterface_payload : BranchPlugin_jumpInterface_payload);
    always @(*) begin
        IBusSimplePlugin_fetchPc_correction = 1'b0;
        if (IBusSimplePlugin_jump_pcLoad_valid) begin
            IBusSimplePlugin_fetchPc_correction = 1'b1;
        end
    end

    assign IBusSimplePlugin_fetchPc_output_fire = (IBusSimplePlugin_fetchPc_output_valid && IBusSimplePlugin_fetchPc_output_ready);
    assign IBusSimplePlugin_fetchPc_corrected = (IBusSimplePlugin_fetchPc_correction || IBusSimplePlugin_fetchPc_correctionReg);
    always @(*) begin
        IBusSimplePlugin_fetchPc_pcRegPropagate = 1'b0;
        if (IBusSimplePlugin_iBusRsp_stages_1_input_ready) begin
            IBusSimplePlugin_fetchPc_pcRegPropagate = 1'b1;
        end
    end

    assign when_Fetcher_l133 = (IBusSimplePlugin_fetchPc_correction || IBusSimplePlugin_fetchPc_pcRegPropagate);
    assign when_Fetcher_l133_1 = ((! IBusSimplePlugin_fetchPc_output_valid) && IBusSimplePlugin_fetchPc_output_ready);
    always @(*) begin
        IBusSimplePlugin_fetchPc_pc = (IBusSimplePlugin_fetchPc_pcReg + _zz_IBusSimplePlugin_fetchPc_pc);
        if (IBusSimplePlugin_jump_pcLoad_valid) begin
            IBusSimplePlugin_fetchPc_pc = IBusSimplePlugin_jump_pcLoad_payload;
        end
        IBusSimplePlugin_fetchPc_pc[0] = 1'b0;
        IBusSimplePlugin_fetchPc_pc[1] = 1'b0;
    end

    always @(*) begin
        IBusSimplePlugin_fetchPc_flushed = 1'b0;
        if (IBusSimplePlugin_jump_pcLoad_valid) begin
            IBusSimplePlugin_fetchPc_flushed = 1'b1;
        end
    end

    assign when_Fetcher_l160 = (IBusSimplePlugin_fetchPc_booted && ((IBusSimplePlugin_fetchPc_output_ready || IBusSimplePlugin_fetchPc_correction) || IBusSimplePlugin_fetchPc_pcRegPropagate));
    assign IBusSimplePlugin_fetchPc_output_valid = ((! IBusSimplePlugin_fetcherHalt) && IBusSimplePlugin_fetchPc_booted);
    assign IBusSimplePlugin_fetchPc_output_payload = IBusSimplePlugin_fetchPc_pc;
    assign IBusSimplePlugin_iBusRsp_redoFetch = 1'b0;
    assign IBusSimplePlugin_iBusRsp_stages_0_input_valid = IBusSimplePlugin_fetchPc_output_valid;
    assign IBusSimplePlugin_fetchPc_output_ready = IBusSimplePlugin_iBusRsp_stages_0_input_ready;
    assign IBusSimplePlugin_iBusRsp_stages_0_input_payload = IBusSimplePlugin_fetchPc_output_payload;
    assign IBusSimplePlugin_iBusRsp_stages_0_halt = 1'b0;
    assign _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready = (! IBusSimplePlugin_iBusRsp_stages_0_halt);
    assign IBusSimplePlugin_iBusRsp_stages_0_input_ready = (IBusSimplePlugin_iBusRsp_stages_0_output_ready && _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_0_output_valid = (IBusSimplePlugin_iBusRsp_stages_0_input_valid && _zz_IBusSimplePlugin_iBusRsp_stages_0_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_0_output_payload = IBusSimplePlugin_iBusRsp_stages_0_input_payload;
    always @(*) begin
        IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b0;
        if (when_IBusSimplePlugin_l305) begin
            IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b1;
        end
    end

    assign _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready = (! IBusSimplePlugin_iBusRsp_stages_1_halt);
    assign IBusSimplePlugin_iBusRsp_stages_1_input_ready = (IBusSimplePlugin_iBusRsp_stages_1_output_ready && _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_1_output_valid = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && _zz_IBusSimplePlugin_iBusRsp_stages_1_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_1_output_payload = IBusSimplePlugin_iBusRsp_stages_1_input_payload;
    assign IBusSimplePlugin_iBusRsp_stages_2_halt = 1'b0;
    assign _zz_IBusSimplePlugin_iBusRsp_stages_2_input_ready = (! IBusSimplePlugin_iBusRsp_stages_2_halt);
    assign IBusSimplePlugin_iBusRsp_stages_2_input_ready = (IBusSimplePlugin_iBusRsp_stages_2_output_ready && _zz_IBusSimplePlugin_iBusRsp_stages_2_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_2_output_valid = (IBusSimplePlugin_iBusRsp_stages_2_input_valid && _zz_IBusSimplePlugin_iBusRsp_stages_2_input_ready);
    assign IBusSimplePlugin_iBusRsp_stages_2_output_payload = IBusSimplePlugin_iBusRsp_stages_2_input_payload;
    assign IBusSimplePlugin_iBusRsp_flush = (IBusSimplePlugin_externalFlush || IBusSimplePlugin_iBusRsp_redoFetch);
    assign IBusSimplePlugin_iBusRsp_stages_0_output_ready = _zz_IBusSimplePlugin_iBusRsp_stages_0_output_ready;
    assign _zz_IBusSimplePlugin_iBusRsp_stages_0_output_ready = ((1'b0 && (! _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid)) || IBusSimplePlugin_iBusRsp_stages_1_input_ready);
    assign _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid = _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1;
    assign IBusSimplePlugin_iBusRsp_stages_1_input_valid = _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid;
    assign IBusSimplePlugin_iBusRsp_stages_1_input_payload = IBusSimplePlugin_fetchPc_pcReg;
    assign IBusSimplePlugin_iBusRsp_stages_1_output_ready = ((1'b0 && (! IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid)) || IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_ready);
    assign IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid = _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    assign IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload = _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    assign IBusSimplePlugin_iBusRsp_stages_2_input_valid = IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid;
    assign IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_ready = IBusSimplePlugin_iBusRsp_stages_2_input_ready;
    assign IBusSimplePlugin_iBusRsp_stages_2_input_payload = IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload;
    always @(*) begin
        IBusSimplePlugin_iBusRsp_readyForError = 1'b1;
        if (IBusSimplePlugin_injector_decodeInput_valid) begin
            IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
        end
        if (when_Fetcher_l322) begin
            IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
        end
    end

    assign when_Fetcher_l242 = (IBusSimplePlugin_iBusRsp_stages_1_input_valid || IBusSimplePlugin_iBusRsp_stages_2_input_valid);
    assign IBusSimplePlugin_iBusRsp_output_ready = ((1'b0 && (! IBusSimplePlugin_injector_decodeInput_valid)) || IBusSimplePlugin_injector_decodeInput_ready);
    assign IBusSimplePlugin_injector_decodeInput_valid = _zz_IBusSimplePlugin_injector_decodeInput_valid;
    assign IBusSimplePlugin_injector_decodeInput_payload_pc = _zz_IBusSimplePlugin_injector_decodeInput_payload_pc;
    assign IBusSimplePlugin_injector_decodeInput_payload_rsp_error = _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
    assign IBusSimplePlugin_injector_decodeInput_payload_rsp_inst = _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
    assign IBusSimplePlugin_injector_decodeInput_payload_isRvc = _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc;
    assign when_Fetcher_l322 = (!IBusSimplePlugin_pcValids_0);
    assign when_Fetcher_l331 = (!(!IBusSimplePlugin_iBusRsp_stages_1_input_ready));
    assign when_Fetcher_l331_1 = (!(!IBusSimplePlugin_iBusRsp_stages_2_input_ready));
    assign when_Fetcher_l331_2 = (!(!IBusSimplePlugin_injector_decodeInput_ready));
    assign when_Fetcher_l331_3 = (!execute_arbitration_isStuck);
    assign when_Fetcher_l331_4 = (!memory_arbitration_isStuck);
    assign when_Fetcher_l331_5 = (!writeBack_arbitration_isStuck);
    assign IBusSimplePlugin_pcValids_0 = IBusSimplePlugin_injector_nextPcCalc_valids_2;
    assign IBusSimplePlugin_pcValids_1 = IBusSimplePlugin_injector_nextPcCalc_valids_3;
    assign IBusSimplePlugin_pcValids_2 = IBusSimplePlugin_injector_nextPcCalc_valids_4;
    assign IBusSimplePlugin_pcValids_3 = IBusSimplePlugin_injector_nextPcCalc_valids_5;
    assign IBusSimplePlugin_injector_decodeInput_ready = (!decode_arbitration_isStuck);
    always @(*) begin
        decode_arbitration_isValid = IBusSimplePlugin_injector_decodeInput_valid;
        case (IBusSimplePlugin_injector_port_state)
            3'b010: begin
                decode_arbitration_isValid = 1'b1;
            end
            3'b011: begin
                decode_arbitration_isValid = 1'b1;
            end
            default: begin
            end
        endcase
        if (IBusSimplePlugin_forceNoDecodeCond) begin
            decode_arbitration_isValid = 1'b0;
        end
    end

    assign iBus_cmd_valid = IBusSimplePlugin_cmd_valid;
    assign IBusSimplePlugin_cmd_ready = iBus_cmd_ready;
    assign iBus_cmd_payload_pc = IBusSimplePlugin_cmd_payload_pc;
    assign IBusSimplePlugin_pending_next = (_zz_IBusSimplePlugin_pending_next - _zz_IBusSimplePlugin_pending_next_3);
    assign IBusSimplePlugin_cmdFork_canEmit = (IBusSimplePlugin_iBusRsp_stages_1_output_ready && (IBusSimplePlugin_pending_value != 3'b111));
    assign when_IBusSimplePlugin_l305 = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && ((! IBusSimplePlugin_cmdFork_canEmit) || (! IBusSimplePlugin_cmd_ready)));
    assign IBusSimplePlugin_cmd_valid = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && IBusSimplePlugin_cmdFork_canEmit);
    assign IBusSimplePlugin_cmd_fire = (IBusSimplePlugin_cmd_valid && IBusSimplePlugin_cmd_ready);
    assign IBusSimplePlugin_pending_inc = IBusSimplePlugin_cmd_fire;
    assign IBusSimplePlugin_cmd_payload_pc = {
        IBusSimplePlugin_iBusRsp_stages_1_input_payload[31 : 2], 2'b00
    };
    assign iBus_rsp_toStream_valid = iBus_rsp_valid;
    assign iBus_rsp_toStream_payload_error = iBus_rsp_payload_error;
    assign iBus_rsp_toStream_payload_inst = iBus_rsp_payload_inst;
    assign iBus_rsp_toStream_ready = IBusSimplePlugin_rspJoin_rspBuffer_c_io_push_ready;
    assign IBusSimplePlugin_rspJoin_rspBuffer_flush = ((IBusSimplePlugin_rspJoin_rspBuffer_discardCounter != 3'b000) || IBusSimplePlugin_iBusRsp_flush);
    assign IBusSimplePlugin_rspJoin_rspBuffer_output_valid = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter == 3'b000));
    assign IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_error;
    assign IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst = IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_payload_inst;
    assign IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready = (IBusSimplePlugin_rspJoin_rspBuffer_output_ready || IBusSimplePlugin_rspJoin_rspBuffer_flush);
    assign system_cpu_IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire = (IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_valid && IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_ready);
    assign IBusSimplePlugin_pending_dec = system_cpu_IBusSimplePlugin_rspJoin_rspBuffer_c_io_pop_fire;
    assign IBusSimplePlugin_rspJoin_fetchRsp_isRvc = 1'b0;
    assign IBusSimplePlugin_rspJoin_fetchRsp_pc = IBusSimplePlugin_iBusRsp_stages_2_output_payload;
    always @(*) begin
        IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = IBusSimplePlugin_rspJoin_rspBuffer_output_payload_error;
        if (when_IBusSimplePlugin_l377) begin
            IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = 1'b0;
        end
    end

    assign IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst = IBusSimplePlugin_rspJoin_rspBuffer_output_payload_inst;
    assign when_IBusSimplePlugin_l377 = (!IBusSimplePlugin_rspJoin_rspBuffer_output_valid);
    assign IBusSimplePlugin_rspJoin_exceptionDetected = 1'b0;
    assign IBusSimplePlugin_rspJoin_join_valid = (IBusSimplePlugin_iBusRsp_stages_2_output_valid && IBusSimplePlugin_rspJoin_rspBuffer_output_valid);
    assign IBusSimplePlugin_rspJoin_join_payload_pc = IBusSimplePlugin_rspJoin_fetchRsp_pc;
    assign IBusSimplePlugin_rspJoin_join_payload_rsp_error = IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
    assign IBusSimplePlugin_rspJoin_join_payload_rsp_inst = IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
    assign IBusSimplePlugin_rspJoin_join_payload_isRvc = IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
    assign IBusSimplePlugin_rspJoin_join_fire = (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready);
    assign IBusSimplePlugin_iBusRsp_stages_2_output_ready = (IBusSimplePlugin_iBusRsp_stages_2_output_valid ? IBusSimplePlugin_rspJoin_join_fire : IBusSimplePlugin_rspJoin_join_ready);
    assign IBusSimplePlugin_rspJoin_rspBuffer_output_ready = IBusSimplePlugin_rspJoin_join_fire;
    assign _zz_IBusSimplePlugin_iBusRsp_output_valid = (! IBusSimplePlugin_rspJoin_exceptionDetected);
    assign IBusSimplePlugin_rspJoin_join_ready = (IBusSimplePlugin_iBusRsp_output_ready && _zz_IBusSimplePlugin_iBusRsp_output_valid);
    assign IBusSimplePlugin_iBusRsp_output_valid = (IBusSimplePlugin_rspJoin_join_valid && _zz_IBusSimplePlugin_iBusRsp_output_valid);
    assign IBusSimplePlugin_iBusRsp_output_payload_pc = IBusSimplePlugin_rspJoin_join_payload_pc;
    assign IBusSimplePlugin_iBusRsp_output_payload_rsp_error = IBusSimplePlugin_rspJoin_join_payload_rsp_error;
    assign IBusSimplePlugin_iBusRsp_output_payload_rsp_inst = IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
    assign IBusSimplePlugin_iBusRsp_output_payload_isRvc = IBusSimplePlugin_rspJoin_join_payload_isRvc;
    assign _zz_dBus_cmd_valid = 1'b0;
    always @(*) begin
        execute_DBusSimplePlugin_skipCmd = 1'b0;
        if (execute_ALIGNEMENT_FAULT) begin
            execute_DBusSimplePlugin_skipCmd = 1'b1;
        end
    end

    assign dBus_cmd_valid = (((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! execute_arbitration_isStuckByOthers)) && (! execute_arbitration_isFlushed)) && (! execute_DBusSimplePlugin_skipCmd)) && (! _zz_dBus_cmd_valid));
    assign dBus_cmd_payload_wr = execute_MEMORY_STORE;
    assign dBus_cmd_payload_size = execute_INSTRUCTION[13 : 12];
    always @(*) begin
        case (dBus_cmd_payload_size)
            2'b00: begin
                _zz_dBus_cmd_payload_data = {
                    {{execute_RS2[7 : 0], execute_RS2[7 : 0]}, execute_RS2[7 : 0]},
                    execute_RS2[7 : 0]
                };
            end
            2'b01: begin
                _zz_dBus_cmd_payload_data = {execute_RS2[15 : 0], execute_RS2[15 : 0]};
            end
            default: begin
                _zz_dBus_cmd_payload_data = execute_RS2[31 : 0];
            end
        endcase
    end

    assign dBus_cmd_payload_data = _zz_dBus_cmd_payload_data;
    assign when_DBusSimplePlugin_l434 = ((((execute_arbitration_isValid && execute_MEMORY_ENABLE) && (! dBus_cmd_ready)) && (! execute_DBusSimplePlugin_skipCmd)) && (! _zz_dBus_cmd_valid));
    always @(*) begin
        case (dBus_cmd_payload_size)
            2'b00: begin
                _zz_execute_DBusSimplePlugin_formalMask = 4'b0001;
            end
            2'b01: begin
                _zz_execute_DBusSimplePlugin_formalMask = 4'b0011;
            end
            default: begin
                _zz_execute_DBusSimplePlugin_formalMask = 4'b1111;
            end
        endcase
    end

    assign execute_DBusSimplePlugin_formalMask = (_zz_execute_DBusSimplePlugin_formalMask <<< dBus_cmd_payload_address[1 : 0]);
    assign dBus_cmd_payload_mask = execute_DBusSimplePlugin_formalMask;
    assign dBus_cmd_payload_address = execute_SRC_ADD;
    assign when_DBusSimplePlugin_l489 = (((memory_arbitration_isValid && memory_MEMORY_ENABLE) && (! memory_MEMORY_STORE)) && ((! dBus_rsp_ready) || 1'b0));
    always @(*) begin
        writeBack_DBusSimplePlugin_rspShifted = writeBack_MEMORY_READ_DATA;
        case (writeBack_MEMORY_ADDRESS_LOW)
            2'b01: begin
                writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[15 : 8];
            end
            2'b10: begin
                writeBack_DBusSimplePlugin_rspShifted[15 : 0] = writeBack_MEMORY_READ_DATA[31 : 16];
            end
            2'b11: begin
                writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[31 : 24];
            end
            default: begin
            end
        endcase
    end

    assign switch_Misc_l241 = writeBack_INSTRUCTION[13 : 12];
    assign _zz_writeBack_DBusSimplePlugin_rspFormated = (writeBack_DBusSimplePlugin_rspShifted[7] && (! writeBack_INSTRUCTION[14]));
    always @(*) begin
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[31] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[30] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[29] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[28] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[27] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[26] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[25] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[24] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[23] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[22] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[21] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[20] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[19] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[18] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[17] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[16] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[15] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[14] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[13] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[12] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[11] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[10] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[9] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[8] = _zz_writeBack_DBusSimplePlugin_rspFormated;
        _zz_writeBack_DBusSimplePlugin_rspFormated_1[7 : 0] = writeBack_DBusSimplePlugin_rspShifted[7 : 0];
    end

    assign _zz_writeBack_DBusSimplePlugin_rspFormated_2 = (writeBack_DBusSimplePlugin_rspShifted[15] && (! writeBack_INSTRUCTION[14]));
    always @(*) begin
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[31] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[30] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[29] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[28] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[27] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[26] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[25] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[24] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[23] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[22] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[21] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[20] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[19] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[18] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[17] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[16] = _zz_writeBack_DBusSimplePlugin_rspFormated_2;
        _zz_writeBack_DBusSimplePlugin_rspFormated_3[15 : 0] = writeBack_DBusSimplePlugin_rspShifted[15 : 0];
    end

    always @(*) begin
        case (switch_Misc_l241)
            2'b00: begin
                writeBack_DBusSimplePlugin_rspFormated = _zz_writeBack_DBusSimplePlugin_rspFormated_1;
            end
            2'b01: begin
                writeBack_DBusSimplePlugin_rspFormated = _zz_writeBack_DBusSimplePlugin_rspFormated_3;
            end
            default: begin
                writeBack_DBusSimplePlugin_rspFormated = writeBack_DBusSimplePlugin_rspShifted;
            end
        endcase
    end

    assign when_DBusSimplePlugin_l565 = (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE);
    always @(*) begin
        CsrPlugin_privilege = 2'b11;
        if (CsrPlugin_forceMachineWire) begin
            CsrPlugin_privilege = 2'b11;
        end
    end

    assign CsrPlugin_misa_base = 2'b01;
    assign CsrPlugin_misa_extensions = 26'h0000042;
    assign CsrPlugin_mtvec_mode = 2'b00;
    assign _zz_when_CsrPlugin_l1302 = (CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE);
    assign _zz_when_CsrPlugin_l1302_1 = (CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE);
    assign _zz_when_CsrPlugin_l1302_2 = (CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE);
    assign CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode = 1'b0;
    assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped = 2'b11;
    assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege = ((CsrPlugin_privilege < CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped) ? CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilegeUncapped : CsrPlugin_privilege);
    assign CsrPlugin_exceptionPortCtrl_exceptionValids_decode = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
    always @(*) begin
        CsrPlugin_exceptionPortCtrl_exceptionValids_execute = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
        if (CsrPlugin_selfException_valid) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b1;
        end
        if (execute_arbitration_isFlushed) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_exceptionPortCtrl_exceptionValids_memory = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
        if (memory_arbitration_isFlushed) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b0;
        end
    end

    always @(*) begin
        CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
        if (writeBack_arbitration_isFlushed) begin
            CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = 1'b0;
        end
    end

    assign when_CsrPlugin_l1259 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1259_1 = (!memory_arbitration_isStuck);
    assign when_CsrPlugin_l1259_2 = (!writeBack_arbitration_isStuck);
    assign when_CsrPlugin_l1272 = (|{CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack, {
        CsrPlugin_exceptionPortCtrl_exceptionValids_memory,
        {
            CsrPlugin_exceptionPortCtrl_exceptionValids_execute,
            CsrPlugin_exceptionPortCtrl_exceptionValids_decode
        }
    }});
    assign CsrPlugin_exceptionPendings_0 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
    assign CsrPlugin_exceptionPendings_1 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    assign CsrPlugin_exceptionPendings_2 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
    assign CsrPlugin_exceptionPendings_3 = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
    assign when_CsrPlugin_l1296 = (CsrPlugin_mstatus_MIE || (CsrPlugin_privilege < 2'b11));
    assign when_CsrPlugin_l1302 = ((_zz_when_CsrPlugin_l1302 && 1'b1) && (!1'b0));
    assign when_CsrPlugin_l1302_1 = ((_zz_when_CsrPlugin_l1302_1 && 1'b1) && (!1'b0));
    assign when_CsrPlugin_l1302_2 = ((_zz_when_CsrPlugin_l1302_2 && 1'b1) && (!1'b0));
    assign CsrPlugin_exception = (CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack && CsrPlugin_allowException);
    assign CsrPlugin_lastStageWasWfi = 1'b0;
    assign CsrPlugin_pipelineLiberator_active = ((CsrPlugin_interrupt_valid && CsrPlugin_allowInterrupts) && decode_arbitration_isValid);
    assign when_CsrPlugin_l1335 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1335_1 = (!memory_arbitration_isStuck);
    assign when_CsrPlugin_l1335_2 = (!writeBack_arbitration_isStuck);
    assign when_CsrPlugin_l1340 = ((! CsrPlugin_pipelineLiberator_active) || decode_arbitration_removeIt);
    always @(*) begin
        CsrPlugin_pipelineLiberator_done = CsrPlugin_pipelineLiberator_pcValids_2;
        if (when_CsrPlugin_l1346) begin
            CsrPlugin_pipelineLiberator_done = 1'b0;
        end
        if (CsrPlugin_hadException) begin
            CsrPlugin_pipelineLiberator_done = 1'b0;
        end
    end

    assign when_CsrPlugin_l1346 = (|{CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack, {
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory,
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute
    }});
    assign CsrPlugin_interruptJump = ((CsrPlugin_interrupt_valid && CsrPlugin_pipelineLiberator_done) && CsrPlugin_allowInterrupts);
    always @(*) begin
        CsrPlugin_targetPrivilege = CsrPlugin_interrupt_targetPrivilege;
        if (CsrPlugin_hadException) begin
            CsrPlugin_targetPrivilege = CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
        end
    end

    always @(*) begin
        CsrPlugin_trapCause = CsrPlugin_interrupt_code;
        if (CsrPlugin_hadException) begin
            CsrPlugin_trapCause = CsrPlugin_exceptionPortCtrl_exceptionContext_code;
        end
    end

    assign CsrPlugin_trapCauseEbreakDebug = 1'b0;
    always @(*) begin
        CsrPlugin_xtvec_mode = 2'bxx;
        case (CsrPlugin_targetPrivilege)
            2'b11: begin
                CsrPlugin_xtvec_mode = CsrPlugin_mtvec_mode;
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        CsrPlugin_xtvec_base = 30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        case (CsrPlugin_targetPrivilege)
            2'b11: begin
                CsrPlugin_xtvec_base = CsrPlugin_mtvec_base;
            end
            default: begin
            end
        endcase
    end

    assign CsrPlugin_trapEnterDebug = 1'b0;
    assign when_CsrPlugin_l1390 = (CsrPlugin_hadException || CsrPlugin_interruptJump);
    assign when_CsrPlugin_l1398 = (!CsrPlugin_trapEnterDebug);
    assign when_CsrPlugin_l1456 = (writeBack_arbitration_isValid && (writeBack_ENV_CTRL == EnvCtrlEnum_XRET));
    assign switch_CsrPlugin_l1460 = writeBack_INSTRUCTION[29 : 28];
    assign contextSwitching = CsrPlugin_jumpInterface_valid;
    assign when_CsrPlugin_l1527 = (|{(writeBack_arbitration_isValid && (writeBack_ENV_CTRL == EnvCtrlEnum_XRET)),{
        (memory_arbitration_isValid && (memory_ENV_CTRL == EnvCtrlEnum_XRET)),
        (execute_arbitration_isValid && (execute_ENV_CTRL == EnvCtrlEnum_XRET))
    }});
    assign execute_CsrPlugin_blockedBySideEffects = ((|{writeBack_arbitration_isValid,memory_arbitration_isValid}) || 1'b0);
    always @(*) begin
        execute_CsrPlugin_illegalAccess = 1'b1;
        if (execute_CsrPlugin_csr_768) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_836) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_772) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_773) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_833) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (execute_CsrPlugin_csr_834) begin
            if (execute_CSR_READ_OPCODE) begin
                execute_CsrPlugin_illegalAccess = 1'b0;
            end
        end
        if (execute_CsrPlugin_csr_835) begin
            if (execute_CSR_READ_OPCODE) begin
                execute_CsrPlugin_illegalAccess = 1'b0;
            end
        end
        if (CsrPlugin_csrMapping_allowCsrSignal) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
        if (when_CsrPlugin_l1719) begin
            execute_CsrPlugin_illegalAccess = 1'b1;
        end
        if (when_CsrPlugin_l1725) begin
            execute_CsrPlugin_illegalAccess = 1'b0;
        end
    end

    always @(*) begin
        execute_CsrPlugin_illegalInstruction = 1'b0;
        if (when_CsrPlugin_l1547) begin
            if (when_CsrPlugin_l1548) begin
                execute_CsrPlugin_illegalInstruction = 1'b1;
            end
        end
    end

    always @(*) begin
        CsrPlugin_selfException_valid = 1'b0;
        if (when_CsrPlugin_l1555) begin
            CsrPlugin_selfException_valid = 1'b1;
        end
    end

    always @(*) begin
        CsrPlugin_selfException_payload_code = 4'bxxxx;
        if (when_CsrPlugin_l1555) begin
            case (CsrPlugin_privilege)
                2'b00: begin
                    CsrPlugin_selfException_payload_code = 4'b1000;
                end
                default: begin
                    CsrPlugin_selfException_payload_code = 4'b1011;
                end
            endcase
        end
    end

    assign CsrPlugin_selfException_payload_badAddr = execute_INSTRUCTION;
    assign when_CsrPlugin_l1547 = (execute_arbitration_isValid && (execute_ENV_CTRL == EnvCtrlEnum_XRET));
    assign when_CsrPlugin_l1548 = (CsrPlugin_privilege < execute_INSTRUCTION[29 : 28]);
    assign when_CsrPlugin_l1555 = (execute_arbitration_isValid && (execute_ENV_CTRL == EnvCtrlEnum_ECALL));
    always @(*) begin
        execute_CsrPlugin_writeInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_WRITE_OPCODE);
        if (when_CsrPlugin_l1719) begin
            execute_CsrPlugin_writeInstruction = 1'b0;
        end
    end

    always @(*) begin
        execute_CsrPlugin_readInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_READ_OPCODE);
        if (when_CsrPlugin_l1719) begin
            execute_CsrPlugin_readInstruction = 1'b0;
        end
    end

    assign execute_CsrPlugin_writeEnable = (execute_CsrPlugin_writeInstruction && (! execute_arbitration_isStuck));
    assign execute_CsrPlugin_readEnable = (execute_CsrPlugin_readInstruction && (! execute_arbitration_isStuck));
    assign CsrPlugin_csrMapping_hazardFree = (!execute_CsrPlugin_blockedBySideEffects);
    assign execute_CsrPlugin_readToWriteData = CsrPlugin_csrMapping_readDataSignal;
    assign switch_Misc_l241_1 = execute_INSTRUCTION[13];
    always @(*) begin
        case (switch_Misc_l241_1)
            1'b0: begin
                _zz_CsrPlugin_csrMapping_writeDataSignal = execute_SRC1;
            end
            default: begin
                _zz_CsrPlugin_csrMapping_writeDataSignal = (execute_INSTRUCTION[12] ? (execute_CsrPlugin_readToWriteData & (~ execute_SRC1)) : (execute_CsrPlugin_readToWriteData | execute_SRC1));
            end
        endcase
    end

    assign CsrPlugin_csrMapping_writeDataSignal = _zz_CsrPlugin_csrMapping_writeDataSignal;
    assign when_CsrPlugin_l1587 = (execute_arbitration_isValid && execute_IS_CSR);
    assign when_CsrPlugin_l1591 = (execute_arbitration_isValid && (execute_IS_CSR || 1'b0));
    assign execute_CsrPlugin_csrAddress = execute_INSTRUCTION[31 : 20];
    assign _zz_decode_IS_RS2_SIGNED_1 = ((decode_INSTRUCTION & 32'h00004050) == 32'h00004050);
    assign _zz_decode_IS_RS2_SIGNED_2 = ((decode_INSTRUCTION & 32'h00006004) == 32'h00002000);
    assign _zz_decode_IS_RS2_SIGNED_3 = ((decode_INSTRUCTION & 32'h00000018) == 32'h0);
    assign _zz_decode_IS_RS2_SIGNED_4 = ((decode_INSTRUCTION & 32'h00000004) == 32'h00000004);
    assign _zz_decode_IS_RS2_SIGNED_5 = ((decode_INSTRUCTION & 32'h00000048) == 32'h00000048);
    assign _zz_decode_IS_RS2_SIGNED_6 = ((decode_INSTRUCTION & 32'h00001000) == 32'h0);
    assign _zz_decode_IS_RS2_SIGNED = {
        (|((decode_INSTRUCTION & _zz__zz_decode_IS_RS2_SIGNED) == 32'h00100050)),
        {
            (|(_zz__zz_decode_IS_RS2_SIGNED_1 == _zz__zz_decode_IS_RS2_SIGNED_2)),
            {
                (|{_zz__zz_decode_IS_RS2_SIGNED_3, _zz__zz_decode_IS_RS2_SIGNED_4}),
                {
                    (|_zz__zz_decode_IS_RS2_SIGNED_5),
                    {
                        _zz__zz_decode_IS_RS2_SIGNED_7,
                        {_zz__zz_decode_IS_RS2_SIGNED_9, _zz__zz_decode_IS_RS2_SIGNED_10}
                    }
                }
            }
        }
    };
    assign _zz_decode_SRC1_CTRL_2 = _zz_decode_IS_RS2_SIGNED[1 : 0];
    assign _zz_decode_SRC1_CTRL_1 = _zz_decode_SRC1_CTRL_2;
    assign _zz_decode_SRC2_CTRL_2 = _zz_decode_IS_RS2_SIGNED[6 : 5];
    assign _zz_decode_SRC2_CTRL_1 = _zz_decode_SRC2_CTRL_2;
    assign _zz_decode_ENV_CTRL_2 = _zz_decode_IS_RS2_SIGNED[15 : 14];
    assign _zz_decode_ENV_CTRL_1 = _zz_decode_ENV_CTRL_2;
    assign _zz_decode_ALU_CTRL_2 = _zz_decode_IS_RS2_SIGNED[17 : 16];
    assign _zz_decode_ALU_CTRL_1 = _zz_decode_ALU_CTRL_2;
    assign _zz_decode_ALU_BITWISE_CTRL_2 = _zz_decode_IS_RS2_SIGNED[20 : 19];
    assign _zz_decode_ALU_BITWISE_CTRL_1 = _zz_decode_ALU_BITWISE_CTRL_2;
    assign _zz_decode_BRANCH_CTRL_2 = _zz_decode_IS_RS2_SIGNED[27 : 26];
    assign _zz_decode_BRANCH_CTRL_1 = _zz_decode_BRANCH_CTRL_2;
    assign _zz_decode_SHIFT_CTRL_2 = _zz_decode_IS_RS2_SIGNED[29 : 28];
    assign _zz_decode_SHIFT_CTRL_1 = _zz_decode_SHIFT_CTRL_2;
    assign when_RegFilePlugin_l63 = (decode_INSTRUCTION[11 : 7] == 5'h0);
    assign decode_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION_ANTICIPATED[19 : 15];
    assign decode_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION_ANTICIPATED[24 : 20];
    assign decode_RegFilePlugin_rs1Data = RegFilePlugin_regFile_spinal_port0;
    assign decode_RegFilePlugin_rs2Data = RegFilePlugin_regFile_spinal_port1;
    always @(*) begin
        lastStageRegFileWrite_valid = (_zz_lastStageRegFileWrite_valid && writeBack_arbitration_isFiring);
        if (_zz_5) begin
            lastStageRegFileWrite_valid = 1'b1;
        end
    end

    always @(*) begin
        lastStageRegFileWrite_payload_address = _zz_lastStageRegFileWrite_payload_address[11 : 7];
        if (_zz_5) begin
            lastStageRegFileWrite_payload_address = 5'h0;
        end
    end

    always @(*) begin
        lastStageRegFileWrite_payload_data = _zz_decode_RS2_2;
        if (_zz_5) begin
            lastStageRegFileWrite_payload_data = 32'h0;
        end
    end

    always @(*) begin
        case (execute_ALU_BITWISE_CTRL)
            AluBitwiseCtrlEnum_AND_1: begin
                execute_IntAluPlugin_bitwise = (execute_SRC1 & execute_SRC2);
            end
            AluBitwiseCtrlEnum_OR_1: begin
                execute_IntAluPlugin_bitwise = (execute_SRC1 | execute_SRC2);
            end
            default: begin
                execute_IntAluPlugin_bitwise = (execute_SRC1 ^ execute_SRC2);
            end
        endcase
    end

    always @(*) begin
        case (execute_ALU_CTRL)
            AluCtrlEnum_BITWISE: begin
                _zz_execute_REGFILE_WRITE_DATA = execute_IntAluPlugin_bitwise;
            end
            AluCtrlEnum_SLT_SLTU: begin
                _zz_execute_REGFILE_WRITE_DATA = {31'd0, _zz__zz_execute_REGFILE_WRITE_DATA};
            end
            default: begin
                _zz_execute_REGFILE_WRITE_DATA = execute_SRC_ADD_SUB;
            end
        endcase
    end

    always @(*) begin
        case (decode_SRC1_CTRL)
            Src1CtrlEnum_RS: begin
                _zz_decode_SRC1 = _zz_decode_to_execute_RS1;
            end
            Src1CtrlEnum_PC_INCREMENT: begin
                _zz_decode_SRC1 = {29'd0, _zz__zz_decode_SRC1};
            end
            Src1CtrlEnum_IMU: begin
                _zz_decode_SRC1 = {decode_INSTRUCTION[31 : 12], 12'h0};
            end
            default: begin
                _zz_decode_SRC1 = {27'd0, _zz__zz_decode_SRC1_1};
            end
        endcase
    end

    assign _zz_decode_SRC2 = decode_INSTRUCTION[31];
    always @(*) begin
        _zz_decode_SRC2_1[19] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[18] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[17] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[16] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[15] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[14] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[13] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[12] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[11] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[10] = _zz_decode_SRC2;
        _zz_decode_SRC2_1[9]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[8]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[7]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[6]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[5]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[4]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[3]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[2]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[1]  = _zz_decode_SRC2;
        _zz_decode_SRC2_1[0]  = _zz_decode_SRC2;
    end

    assign _zz_decode_SRC2_2 = _zz__zz_decode_SRC2_2[11];
    always @(*) begin
        _zz_decode_SRC2_3[19] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[18] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[17] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[16] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[15] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[14] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[13] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[12] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[11] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[10] = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[9]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[8]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[7]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[6]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[5]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[4]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[3]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[2]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[1]  = _zz_decode_SRC2_2;
        _zz_decode_SRC2_3[0]  = _zz_decode_SRC2_2;
    end

    always @(*) begin
        case (decode_SRC2_CTRL)
            Src2CtrlEnum_RS: begin
                _zz_decode_SRC2_4 = _zz_decode_to_execute_RS2;
            end
            Src2CtrlEnum_IMI: begin
                _zz_decode_SRC2_4 = {_zz_decode_SRC2_1, decode_INSTRUCTION[31 : 20]};
            end
            Src2CtrlEnum_IMS: begin
                _zz_decode_SRC2_4 = {
                    _zz_decode_SRC2_3, {decode_INSTRUCTION[31 : 25], decode_INSTRUCTION[11 : 7]}
                };
            end
            default: begin
                _zz_decode_SRC2_4 = _zz_decode_to_execute_PC;
            end
        endcase
    end

    always @(*) begin
        execute_SrcPlugin_addSub = _zz_execute_SrcPlugin_addSub;
        if (execute_SRC2_FORCE_ZERO) begin
            execute_SrcPlugin_addSub = execute_SRC1;
        end
    end

    assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_addSub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
    always @(*) begin
        HazardSimplePlugin_src0Hazard = 1'b0;
        if (when_HazardSimplePlugin_l57) begin
            if (when_HazardSimplePlugin_l58) begin
                if (when_HazardSimplePlugin_l48) begin
                    HazardSimplePlugin_src0Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l57_1) begin
            if (when_HazardSimplePlugin_l58_1) begin
                if (when_HazardSimplePlugin_l48_1) begin
                    HazardSimplePlugin_src0Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l57_2) begin
            if (when_HazardSimplePlugin_l58_2) begin
                if (when_HazardSimplePlugin_l48_2) begin
                    HazardSimplePlugin_src0Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l105) begin
            HazardSimplePlugin_src0Hazard = 1'b0;
        end
    end

    always @(*) begin
        HazardSimplePlugin_src1Hazard = 1'b0;
        if (when_HazardSimplePlugin_l57) begin
            if (when_HazardSimplePlugin_l58) begin
                if (when_HazardSimplePlugin_l51) begin
                    HazardSimplePlugin_src1Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l57_1) begin
            if (when_HazardSimplePlugin_l58_1) begin
                if (when_HazardSimplePlugin_l51_1) begin
                    HazardSimplePlugin_src1Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l57_2) begin
            if (when_HazardSimplePlugin_l58_2) begin
                if (when_HazardSimplePlugin_l51_2) begin
                    HazardSimplePlugin_src1Hazard = 1'b1;
                end
            end
        end
        if (when_HazardSimplePlugin_l108) begin
            HazardSimplePlugin_src1Hazard = 1'b0;
        end
    end

    assign HazardSimplePlugin_writeBackWrites_valid = (_zz_lastStageRegFileWrite_valid && writeBack_arbitration_isFiring);
    assign HazardSimplePlugin_writeBackWrites_payload_address = _zz_lastStageRegFileWrite_payload_address[11 : 7];
    assign HazardSimplePlugin_writeBackWrites_payload_data = _zz_decode_RS2_2;
    assign HazardSimplePlugin_addr0Match = (HazardSimplePlugin_writeBackBuffer_payload_address == decode_INSTRUCTION[19 : 15]);
    assign HazardSimplePlugin_addr1Match = (HazardSimplePlugin_writeBackBuffer_payload_address == decode_INSTRUCTION[24 : 20]);
    assign when_HazardSimplePlugin_l47 = 1'b1;
    assign when_HazardSimplePlugin_l48 = (writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
    assign when_HazardSimplePlugin_l51 = (writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
    assign when_HazardSimplePlugin_l45 = (writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l57 = (writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l58 = (1'b0 || (!when_HazardSimplePlugin_l47));
    assign when_HazardSimplePlugin_l48_1 = (memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
    assign when_HazardSimplePlugin_l51_1 = (memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
    assign when_HazardSimplePlugin_l45_1 = (memory_arbitration_isValid && memory_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l57_1 = (memory_arbitration_isValid && memory_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l58_1 = (1'b0 || (!memory_BYPASSABLE_MEMORY_STAGE));
    assign when_HazardSimplePlugin_l48_2 = (execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
    assign when_HazardSimplePlugin_l51_2 = (execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
    assign when_HazardSimplePlugin_l45_2 = (execute_arbitration_isValid && execute_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l57_2 = (execute_arbitration_isValid && execute_REGFILE_WRITE_VALID);
    assign when_HazardSimplePlugin_l58_2 = (1'b0 || (!execute_BYPASSABLE_EXECUTE_STAGE));
    assign when_HazardSimplePlugin_l105 = (!decode_RS1_USE);
    assign when_HazardSimplePlugin_l108 = (!decode_RS2_USE);
    assign when_HazardSimplePlugin_l113 = (decode_arbitration_isValid && (HazardSimplePlugin_src0Hazard || HazardSimplePlugin_src1Hazard));
    assign execute_MulPlugin_a = execute_RS1;
    assign execute_MulPlugin_b = execute_RS2;
    assign switch_MulPlugin_l87 = execute_INSTRUCTION[13 : 12];
    always @(*) begin
        case (switch_MulPlugin_l87)
            2'b01: begin
                execute_MulPlugin_aSigned = 1'b1;
            end
            2'b10: begin
                execute_MulPlugin_aSigned = 1'b1;
            end
            default: begin
                execute_MulPlugin_aSigned = 1'b0;
            end
        endcase
    end

    always @(*) begin
        case (switch_MulPlugin_l87)
            2'b01: begin
                execute_MulPlugin_bSigned = 1'b1;
            end
            2'b10: begin
                execute_MulPlugin_bSigned = 1'b0;
            end
            default: begin
                execute_MulPlugin_bSigned = 1'b0;
            end
        endcase
    end

    assign execute_MulPlugin_aULow = execute_MulPlugin_a[15 : 0];
    assign execute_MulPlugin_bULow = execute_MulPlugin_b[15 : 0];
    assign execute_MulPlugin_aSLow = {1'b0, execute_MulPlugin_a[15 : 0]};
    assign execute_MulPlugin_bSLow = {1'b0, execute_MulPlugin_b[15 : 0]};
    assign execute_MulPlugin_aHigh = {
        (execute_MulPlugin_aSigned && execute_MulPlugin_a[31]), execute_MulPlugin_a[31 : 16]
    };
    assign execute_MulPlugin_bHigh = {
        (execute_MulPlugin_bSigned && execute_MulPlugin_b[31]), execute_MulPlugin_b[31 : 16]
    };
    assign writeBack_MulPlugin_result = ($signed(
        _zz_writeBack_MulPlugin_result
    ) + $signed(
        _zz_writeBack_MulPlugin_result_1
    ));
    assign when_MulPlugin_l147 = (writeBack_arbitration_isValid && writeBack_IS_MUL);
    assign switch_MulPlugin_l148 = writeBack_INSTRUCTION[13 : 12];
    assign memory_DivPlugin_frontendOk = 1'b1;
    always @(*) begin
        memory_DivPlugin_div_counter_willIncrement = 1'b0;
        if (when_MulDivIterativePlugin_l128) begin
            if (when_MulDivIterativePlugin_l132) begin
                memory_DivPlugin_div_counter_willIncrement = 1'b1;
            end
        end
    end

    always @(*) begin
        memory_DivPlugin_div_counter_willClear = 1'b0;
        if (when_MulDivIterativePlugin_l162) begin
            memory_DivPlugin_div_counter_willClear = 1'b1;
        end
    end

    assign memory_DivPlugin_div_counter_willOverflowIfInc = (memory_DivPlugin_div_counter_value == 6'h21);
    assign memory_DivPlugin_div_counter_willOverflow = (memory_DivPlugin_div_counter_willOverflowIfInc && memory_DivPlugin_div_counter_willIncrement);
    always @(*) begin
        if (memory_DivPlugin_div_counter_willOverflow) begin
            memory_DivPlugin_div_counter_valueNext = 6'h0;
        end else begin
            memory_DivPlugin_div_counter_valueNext = (memory_DivPlugin_div_counter_value + _zz_memory_DivPlugin_div_counter_valueNext);
        end
        if (memory_DivPlugin_div_counter_willClear) begin
            memory_DivPlugin_div_counter_valueNext = 6'h0;
        end
    end

    assign when_MulDivIterativePlugin_l126 = (memory_DivPlugin_div_counter_value == 6'h20);
    assign when_MulDivIterativePlugin_l126_1 = (!memory_arbitration_isStuck);
    assign when_MulDivIterativePlugin_l128 = (memory_arbitration_isValid && memory_IS_DIV);
    assign when_MulDivIterativePlugin_l129 = ((! memory_DivPlugin_frontendOk) || (! memory_DivPlugin_div_done));
    assign when_MulDivIterativePlugin_l132 = (memory_DivPlugin_frontendOk && (! memory_DivPlugin_div_done));
    assign _zz_memory_DivPlugin_div_stage_0_remainderShifted = memory_DivPlugin_rs1[31 : 0];
    assign memory_DivPlugin_div_stage_0_remainderShifted = {
        memory_DivPlugin_accumulator[31 : 0], _zz_memory_DivPlugin_div_stage_0_remainderShifted[31]
    };
    assign memory_DivPlugin_div_stage_0_remainderMinusDenominator = (memory_DivPlugin_div_stage_0_remainderShifted - _zz_memory_DivPlugin_div_stage_0_remainderMinusDenominator);
    assign memory_DivPlugin_div_stage_0_outRemainder = ((! memory_DivPlugin_div_stage_0_remainderMinusDenominator[32]) ? _zz_memory_DivPlugin_div_stage_0_outRemainder : _zz_memory_DivPlugin_div_stage_0_outRemainder_1);
    assign memory_DivPlugin_div_stage_0_outNumerator = _zz_memory_DivPlugin_div_stage_0_outNumerator[31:0];
    assign when_MulDivIterativePlugin_l151 = (memory_DivPlugin_div_counter_value == 6'h20);
    assign _zz_memory_DivPlugin_div_result = (memory_INSTRUCTION[13] ? memory_DivPlugin_accumulator[31 : 0] : memory_DivPlugin_rs1[31 : 0]);
    assign when_MulDivIterativePlugin_l162 = (!memory_arbitration_isStuck);
    assign _zz_memory_DivPlugin_rs2 = (execute_RS2[31] && execute_IS_RS2_SIGNED);
    assign _zz_memory_DivPlugin_rs1 = (1'b0 || ((execute_IS_DIV && execute_RS1[31]) && execute_IS_RS1_SIGNED));
    always @(*) begin
        _zz_memory_DivPlugin_rs1_1[32] = (execute_IS_RS1_SIGNED && execute_RS1[31]);
        _zz_memory_DivPlugin_rs1_1[31 : 0] = execute_RS1;
    end

    assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
    assign switch_Misc_l241_2 = execute_INSTRUCTION[14 : 12];
    always @(*) begin
        case (switch_Misc_l241_2)
            3'b000: begin
                _zz_execute_BRANCH_DO = execute_BranchPlugin_eq;
            end
            3'b001: begin
                _zz_execute_BRANCH_DO = (!execute_BranchPlugin_eq);
            end
            3'b101: begin
                _zz_execute_BRANCH_DO = (!execute_SRC_LESS);
            end
            3'b111: begin
                _zz_execute_BRANCH_DO = (!execute_SRC_LESS);
            end
            default: begin
                _zz_execute_BRANCH_DO = execute_SRC_LESS;
            end
        endcase
    end

    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_INC: begin
                _zz_execute_BRANCH_DO_1 = 1'b0;
            end
            BranchCtrlEnum_JAL: begin
                _zz_execute_BRANCH_DO_1 = 1'b1;
            end
            BranchCtrlEnum_JALR: begin
                _zz_execute_BRANCH_DO_1 = 1'b1;
            end
            default: begin
                _zz_execute_BRANCH_DO_1 = _zz_execute_BRANCH_DO;
            end
        endcase
    end

    assign execute_BranchPlugin_branch_src1 = ((execute_BRANCH_CTRL == BranchCtrlEnum_JALR) ? execute_RS1 : execute_PC);
    assign _zz_execute_BranchPlugin_branch_src2 = _zz__zz_execute_BranchPlugin_branch_src2[19];
    always @(*) begin
        _zz_execute_BranchPlugin_branch_src2_1[10] = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[9]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[8]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[7]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[6]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[5]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[4]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[3]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[2]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[1]  = _zz_execute_BranchPlugin_branch_src2;
        _zz_execute_BranchPlugin_branch_src2_1[0]  = _zz_execute_BranchPlugin_branch_src2;
    end

    assign _zz_execute_BranchPlugin_branch_src2_2 = execute_INSTRUCTION[31];
    always @(*) begin
        _zz_execute_BranchPlugin_branch_src2_3[19] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[18] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[17] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[16] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[15] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[14] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[13] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[12] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[11] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[10] = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[9]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[8]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[7]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[6]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[5]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[4]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[3]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[2]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[1]  = _zz_execute_BranchPlugin_branch_src2_2;
        _zz_execute_BranchPlugin_branch_src2_3[0]  = _zz_execute_BranchPlugin_branch_src2_2;
    end

    assign _zz_execute_BranchPlugin_branch_src2_4 = _zz__zz_execute_BranchPlugin_branch_src2_4[11];
    always @(*) begin
        _zz_execute_BranchPlugin_branch_src2_5[18] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[17] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[16] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[15] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[14] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[13] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[12] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[11] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[10] = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[9]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[8]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[7]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[6]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[5]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[4]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[3]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[2]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[1]  = _zz_execute_BranchPlugin_branch_src2_4;
        _zz_execute_BranchPlugin_branch_src2_5[0]  = _zz_execute_BranchPlugin_branch_src2_4;
    end

    always @(*) begin
        case (execute_BRANCH_CTRL)
            BranchCtrlEnum_JAL: begin
                _zz_execute_BranchPlugin_branch_src2_6 = {
                    {
                        _zz_execute_BranchPlugin_branch_src2_1,
                        {
                            {
                                {execute_INSTRUCTION[31], execute_INSTRUCTION[19 : 12]},
                                execute_INSTRUCTION[20]
                            },
                            execute_INSTRUCTION[30 : 21]
                        }
                    },
                    1'b0
                };
            end
            BranchCtrlEnum_JALR: begin
                _zz_execute_BranchPlugin_branch_src2_6 = {
                    _zz_execute_BranchPlugin_branch_src2_3, execute_INSTRUCTION[31 : 20]
                };
            end
            default: begin
                _zz_execute_BranchPlugin_branch_src2_6 = {
                    {
                        _zz_execute_BranchPlugin_branch_src2_5,
                        {
                            {
                                {execute_INSTRUCTION[31], execute_INSTRUCTION[7]},
                                execute_INSTRUCTION[30 : 25]
                            },
                            execute_INSTRUCTION[11 : 8]
                        }
                    },
                    1'b0
                };
            end
        endcase
    end

    assign execute_BranchPlugin_branch_src2 = _zz_execute_BranchPlugin_branch_src2_6;
    assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
    assign BranchPlugin_jumpInterface_valid = ((memory_arbitration_isValid && memory_BRANCH_DO) && (! 1'b0));
    assign BranchPlugin_jumpInterface_payload = memory_BRANCH_CALC;
    assign execute_FullBarrelShifterPlugin_amplitude = execute_SRC2[4 : 0];
    always @(*) begin
        _zz_execute_FullBarrelShifterPlugin_reversed[0]  = execute_SRC1[31];
        _zz_execute_FullBarrelShifterPlugin_reversed[1]  = execute_SRC1[30];
        _zz_execute_FullBarrelShifterPlugin_reversed[2]  = execute_SRC1[29];
        _zz_execute_FullBarrelShifterPlugin_reversed[3]  = execute_SRC1[28];
        _zz_execute_FullBarrelShifterPlugin_reversed[4]  = execute_SRC1[27];
        _zz_execute_FullBarrelShifterPlugin_reversed[5]  = execute_SRC1[26];
        _zz_execute_FullBarrelShifterPlugin_reversed[6]  = execute_SRC1[25];
        _zz_execute_FullBarrelShifterPlugin_reversed[7]  = execute_SRC1[24];
        _zz_execute_FullBarrelShifterPlugin_reversed[8]  = execute_SRC1[23];
        _zz_execute_FullBarrelShifterPlugin_reversed[9]  = execute_SRC1[22];
        _zz_execute_FullBarrelShifterPlugin_reversed[10] = execute_SRC1[21];
        _zz_execute_FullBarrelShifterPlugin_reversed[11] = execute_SRC1[20];
        _zz_execute_FullBarrelShifterPlugin_reversed[12] = execute_SRC1[19];
        _zz_execute_FullBarrelShifterPlugin_reversed[13] = execute_SRC1[18];
        _zz_execute_FullBarrelShifterPlugin_reversed[14] = execute_SRC1[17];
        _zz_execute_FullBarrelShifterPlugin_reversed[15] = execute_SRC1[16];
        _zz_execute_FullBarrelShifterPlugin_reversed[16] = execute_SRC1[15];
        _zz_execute_FullBarrelShifterPlugin_reversed[17] = execute_SRC1[14];
        _zz_execute_FullBarrelShifterPlugin_reversed[18] = execute_SRC1[13];
        _zz_execute_FullBarrelShifterPlugin_reversed[19] = execute_SRC1[12];
        _zz_execute_FullBarrelShifterPlugin_reversed[20] = execute_SRC1[11];
        _zz_execute_FullBarrelShifterPlugin_reversed[21] = execute_SRC1[10];
        _zz_execute_FullBarrelShifterPlugin_reversed[22] = execute_SRC1[9];
        _zz_execute_FullBarrelShifterPlugin_reversed[23] = execute_SRC1[8];
        _zz_execute_FullBarrelShifterPlugin_reversed[24] = execute_SRC1[7];
        _zz_execute_FullBarrelShifterPlugin_reversed[25] = execute_SRC1[6];
        _zz_execute_FullBarrelShifterPlugin_reversed[26] = execute_SRC1[5];
        _zz_execute_FullBarrelShifterPlugin_reversed[27] = execute_SRC1[4];
        _zz_execute_FullBarrelShifterPlugin_reversed[28] = execute_SRC1[3];
        _zz_execute_FullBarrelShifterPlugin_reversed[29] = execute_SRC1[2];
        _zz_execute_FullBarrelShifterPlugin_reversed[30] = execute_SRC1[1];
        _zz_execute_FullBarrelShifterPlugin_reversed[31] = execute_SRC1[0];
    end

    assign execute_FullBarrelShifterPlugin_reversed = ((execute_SHIFT_CTRL == ShiftCtrlEnum_SLL_1) ? _zz_execute_FullBarrelShifterPlugin_reversed : execute_SRC1);
    always @(*) begin
        _zz_decode_RS2_3[0]  = memory_SHIFT_RIGHT[31];
        _zz_decode_RS2_3[1]  = memory_SHIFT_RIGHT[30];
        _zz_decode_RS2_3[2]  = memory_SHIFT_RIGHT[29];
        _zz_decode_RS2_3[3]  = memory_SHIFT_RIGHT[28];
        _zz_decode_RS2_3[4]  = memory_SHIFT_RIGHT[27];
        _zz_decode_RS2_3[5]  = memory_SHIFT_RIGHT[26];
        _zz_decode_RS2_3[6]  = memory_SHIFT_RIGHT[25];
        _zz_decode_RS2_3[7]  = memory_SHIFT_RIGHT[24];
        _zz_decode_RS2_3[8]  = memory_SHIFT_RIGHT[23];
        _zz_decode_RS2_3[9]  = memory_SHIFT_RIGHT[22];
        _zz_decode_RS2_3[10] = memory_SHIFT_RIGHT[21];
        _zz_decode_RS2_3[11] = memory_SHIFT_RIGHT[20];
        _zz_decode_RS2_3[12] = memory_SHIFT_RIGHT[19];
        _zz_decode_RS2_3[13] = memory_SHIFT_RIGHT[18];
        _zz_decode_RS2_3[14] = memory_SHIFT_RIGHT[17];
        _zz_decode_RS2_3[15] = memory_SHIFT_RIGHT[16];
        _zz_decode_RS2_3[16] = memory_SHIFT_RIGHT[15];
        _zz_decode_RS2_3[17] = memory_SHIFT_RIGHT[14];
        _zz_decode_RS2_3[18] = memory_SHIFT_RIGHT[13];
        _zz_decode_RS2_3[19] = memory_SHIFT_RIGHT[12];
        _zz_decode_RS2_3[20] = memory_SHIFT_RIGHT[11];
        _zz_decode_RS2_3[21] = memory_SHIFT_RIGHT[10];
        _zz_decode_RS2_3[22] = memory_SHIFT_RIGHT[9];
        _zz_decode_RS2_3[23] = memory_SHIFT_RIGHT[8];
        _zz_decode_RS2_3[24] = memory_SHIFT_RIGHT[7];
        _zz_decode_RS2_3[25] = memory_SHIFT_RIGHT[6];
        _zz_decode_RS2_3[26] = memory_SHIFT_RIGHT[5];
        _zz_decode_RS2_3[27] = memory_SHIFT_RIGHT[4];
        _zz_decode_RS2_3[28] = memory_SHIFT_RIGHT[3];
        _zz_decode_RS2_3[29] = memory_SHIFT_RIGHT[2];
        _zz_decode_RS2_3[30] = memory_SHIFT_RIGHT[1];
        _zz_decode_RS2_3[31] = memory_SHIFT_RIGHT[0];
    end

    assign when_DebugPlugin_l238   = (DebugPlugin_haltIt && (!DebugPlugin_isPipBusy));
    assign DebugPlugin_allowEBreak = (DebugPlugin_debugUsed && (!DebugPlugin_disableEbreak));
    always @(*) begin
        debug_bus_cmd_ready = 1'b1;
        if (debug_bus_cmd_valid) begin
            case (switch_DebugPlugin_l280)
                6'h01: begin
                    if (debug_bus_cmd_payload_wr) begin
                        debug_bus_cmd_ready = DebugPlugin_injectionPort_ready;
                    end
                end
                default: begin
                end
            endcase
        end
    end

    always @(*) begin
        debug_bus_rsp_data = DebugPlugin_busReadDataReg;
        if (when_DebugPlugin_l257) begin
            debug_bus_rsp_data[0] = DebugPlugin_resetIt;
            debug_bus_rsp_data[1] = DebugPlugin_haltIt;
            debug_bus_rsp_data[2] = DebugPlugin_isPipBusy;
            debug_bus_rsp_data[3] = DebugPlugin_haltedByBreak;
            debug_bus_rsp_data[4] = DebugPlugin_stepIt;
        end
    end

    assign when_DebugPlugin_l257 = (!_zz_when_DebugPlugin_l257);
    always @(*) begin
        DebugPlugin_injectionPort_valid = 1'b0;
        if (debug_bus_cmd_valid) begin
            case (switch_DebugPlugin_l280)
                6'h01: begin
                    if (debug_bus_cmd_payload_wr) begin
                        DebugPlugin_injectionPort_valid = 1'b1;
                    end
                end
                default: begin
                end
            endcase
        end
    end

    assign DebugPlugin_injectionPort_payload = debug_bus_cmd_payload_data;
    assign switch_DebugPlugin_l280 = debug_bus_cmd_payload_address[7 : 2];
    assign when_DebugPlugin_l284 = debug_bus_cmd_payload_data[16];
    assign when_DebugPlugin_l284_1 = debug_bus_cmd_payload_data[24];
    assign when_DebugPlugin_l285 = debug_bus_cmd_payload_data[17];
    assign when_DebugPlugin_l285_1 = debug_bus_cmd_payload_data[25];
    assign when_DebugPlugin_l286 = debug_bus_cmd_payload_data[25];
    assign when_DebugPlugin_l287 = debug_bus_cmd_payload_data[25];
    assign when_DebugPlugin_l288 = debug_bus_cmd_payload_data[18];
    assign when_DebugPlugin_l288_1 = debug_bus_cmd_payload_data[26];
    assign when_DebugPlugin_l308 = (execute_arbitration_isValid && execute_DO_EBREAK);
    assign when_DebugPlugin_l311 = ((|{writeBack_arbitration_isValid,memory_arbitration_isValid}) == 1'b0);
    assign when_DebugPlugin_l324 = (DebugPlugin_stepIt && IBusSimplePlugin_incomingInstruction);
    assign debug_resetOut = DebugPlugin_resetIt_regNext;
    assign when_DebugPlugin_l344 = (DebugPlugin_haltIt || DebugPlugin_stepIt);
    assign when_Pipeline_l124 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_1 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_2 = ((! writeBack_arbitration_isStuck) && (! CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack));
    assign when_Pipeline_l124_3 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_4 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_5 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_6 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_7 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_8 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_9 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_10 = (!execute_arbitration_isStuck);
    assign _zz_decode_SRC1_CTRL = _zz_decode_SRC1_CTRL_1;
    assign when_Pipeline_l124_11 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_12 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_13 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_14 = (!writeBack_arbitration_isStuck);
    assign _zz_decode_SRC2_CTRL = _zz_decode_SRC2_CTRL_1;
    assign when_Pipeline_l124_15 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_16 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_17 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_18 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_19 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_20 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_21 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_22 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_23 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_ENV_CTRL_1 = decode_ENV_CTRL;
    assign _zz_execute_to_memory_ENV_CTRL_1 = execute_ENV_CTRL;
    assign _zz_memory_to_writeBack_ENV_CTRL_1 = memory_ENV_CTRL;
    assign _zz_decode_ENV_CTRL = _zz_decode_ENV_CTRL_1;
    assign when_Pipeline_l124_24 = (!execute_arbitration_isStuck);
    assign _zz_execute_ENV_CTRL = decode_to_execute_ENV_CTRL;
    assign when_Pipeline_l124_25 = (!memory_arbitration_isStuck);
    assign _zz_memory_ENV_CTRL = execute_to_memory_ENV_CTRL;
    assign when_Pipeline_l124_26 = (!writeBack_arbitration_isStuck);
    assign _zz_writeBack_ENV_CTRL = memory_to_writeBack_ENV_CTRL;
    assign _zz_decode_to_execute_ALU_CTRL_1 = decode_ALU_CTRL;
    assign _zz_decode_ALU_CTRL = _zz_decode_ALU_CTRL_1;
    assign when_Pipeline_l124_27 = (!execute_arbitration_isStuck);
    assign _zz_execute_ALU_CTRL = decode_to_execute_ALU_CTRL;
    assign when_Pipeline_l124_28 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_ALU_BITWISE_CTRL_1 = decode_ALU_BITWISE_CTRL;
    assign _zz_decode_ALU_BITWISE_CTRL = _zz_decode_ALU_BITWISE_CTRL_1;
    assign when_Pipeline_l124_29 = (!execute_arbitration_isStuck);
    assign _zz_execute_ALU_BITWISE_CTRL = decode_to_execute_ALU_BITWISE_CTRL;
    assign when_Pipeline_l124_30 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_31 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_32 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_33 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_34 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_35 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_36 = (!execute_arbitration_isStuck);
    assign _zz_decode_to_execute_BRANCH_CTRL_1 = decode_BRANCH_CTRL;
    assign _zz_decode_BRANCH_CTRL = _zz_decode_BRANCH_CTRL_1;
    assign when_Pipeline_l124_37 = (!execute_arbitration_isStuck);
    assign _zz_execute_BRANCH_CTRL = decode_to_execute_BRANCH_CTRL;
    assign _zz_decode_to_execute_SHIFT_CTRL_1 = decode_SHIFT_CTRL;
    assign _zz_execute_to_memory_SHIFT_CTRL_1 = execute_SHIFT_CTRL;
    assign _zz_decode_SHIFT_CTRL = _zz_decode_SHIFT_CTRL_1;
    assign when_Pipeline_l124_38 = (!execute_arbitration_isStuck);
    assign _zz_execute_SHIFT_CTRL = decode_to_execute_SHIFT_CTRL;
    assign when_Pipeline_l124_39 = (!memory_arbitration_isStuck);
    assign _zz_memory_SHIFT_CTRL = execute_to_memory_SHIFT_CTRL;
    assign when_Pipeline_l124_40 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_41 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_42 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_43 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_44 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_45 = (!execute_arbitration_isStuck);
    assign when_Pipeline_l124_46 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_47 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_48 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_49 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_50 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_51 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_52 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_53 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_54 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_55 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_56 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_57 = (!memory_arbitration_isStuck);
    assign when_Pipeline_l124_58 = (!writeBack_arbitration_isStuck);
    assign when_Pipeline_l124_59 = (!writeBack_arbitration_isStuck);
    assign decode_arbitration_isFlushed = ((|{writeBack_arbitration_flushNext,{memory_arbitration_flushNext,execute_arbitration_flushNext}}) || (|{writeBack_arbitration_flushIt,{memory_arbitration_flushIt,{execute_arbitration_flushIt,decode_arbitration_flushIt}}}));
    assign execute_arbitration_isFlushed = ((|{writeBack_arbitration_flushNext,memory_arbitration_flushNext}) || (|{writeBack_arbitration_flushIt,{memory_arbitration_flushIt,execute_arbitration_flushIt}}));
    assign memory_arbitration_isFlushed = ((|writeBack_arbitration_flushNext) || (|{writeBack_arbitration_flushIt,memory_arbitration_flushIt}));
    assign writeBack_arbitration_isFlushed = (1'b0 || (|writeBack_arbitration_flushIt));
    assign decode_arbitration_isStuckByOthers = (decode_arbitration_haltByOther || (((1'b0 || execute_arbitration_isStuck) || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
    assign decode_arbitration_isStuck = (decode_arbitration_haltItself || decode_arbitration_isStuckByOthers);
    assign decode_arbitration_isMoving = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
    assign decode_arbitration_isFiring = ((decode_arbitration_isValid && (! decode_arbitration_isStuck)) && (! decode_arbitration_removeIt));
    assign execute_arbitration_isStuckByOthers = (execute_arbitration_haltByOther || ((1'b0 || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
    assign execute_arbitration_isStuck = (execute_arbitration_haltItself || execute_arbitration_isStuckByOthers);
    assign execute_arbitration_isMoving = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
    assign execute_arbitration_isFiring = ((execute_arbitration_isValid && (! execute_arbitration_isStuck)) && (! execute_arbitration_removeIt));
    assign memory_arbitration_isStuckByOthers = (memory_arbitration_haltByOther || (1'b0 || writeBack_arbitration_isStuck));
    assign memory_arbitration_isStuck = (memory_arbitration_haltItself || memory_arbitration_isStuckByOthers);
    assign memory_arbitration_isMoving = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
    assign memory_arbitration_isFiring = ((memory_arbitration_isValid && (! memory_arbitration_isStuck)) && (! memory_arbitration_removeIt));
    assign writeBack_arbitration_isStuckByOthers = (writeBack_arbitration_haltByOther || 1'b0);
    assign writeBack_arbitration_isStuck = (writeBack_arbitration_haltItself || writeBack_arbitration_isStuckByOthers);
    assign writeBack_arbitration_isMoving = ((! writeBack_arbitration_isStuck) && (! writeBack_arbitration_removeIt));
    assign writeBack_arbitration_isFiring = ((writeBack_arbitration_isValid && (! writeBack_arbitration_isStuck)) && (! writeBack_arbitration_removeIt));
    assign when_Pipeline_l151 = ((!execute_arbitration_isStuck) || execute_arbitration_removeIt);
    assign when_Pipeline_l154 = ((!decode_arbitration_isStuck) && (!decode_arbitration_removeIt));
    assign when_Pipeline_l151_1 = ((!memory_arbitration_isStuck) || memory_arbitration_removeIt);
    assign when_Pipeline_l154_1 = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
    assign when_Pipeline_l151_2 = ((! writeBack_arbitration_isStuck) || writeBack_arbitration_removeIt);
    assign when_Pipeline_l154_2 = ((!memory_arbitration_isStuck) && (!memory_arbitration_removeIt));
    always @(*) begin
        DebugPlugin_injectionPort_ready = 1'b0;
        case (IBusSimplePlugin_injector_port_state)
            3'b100: begin
                DebugPlugin_injectionPort_ready = 1'b1;
            end
            default: begin
            end
        endcase
    end

    assign when_Fetcher_l391 = (!decode_arbitration_isStuck);
    assign when_Fetcher_l411 = (IBusSimplePlugin_injector_port_state != 3'b000);
    assign when_CsrPlugin_l1669 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_1 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_2 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_3 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_4 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_5 = (!execute_arbitration_isStuck);
    assign when_CsrPlugin_l1669_6 = (!execute_arbitration_isStuck);
    assign switch_CsrPlugin_l1031 = CsrPlugin_csrMapping_writeDataSignal[12 : 11];
    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit = 32'h0;
        if (execute_CsrPlugin_csr_768) begin
            _zz_CsrPlugin_csrMapping_readDataInit[7 : 7]   = CsrPlugin_mstatus_MPIE;
            _zz_CsrPlugin_csrMapping_readDataInit[3 : 3]   = CsrPlugin_mstatus_MIE;
            _zz_CsrPlugin_csrMapping_readDataInit[12 : 11] = CsrPlugin_mstatus_MPP;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_1 = 32'h0;
        if (execute_CsrPlugin_csr_836) begin
            _zz_CsrPlugin_csrMapping_readDataInit_1[11 : 11] = CsrPlugin_mip_MEIP;
            _zz_CsrPlugin_csrMapping_readDataInit_1[7 : 7]   = CsrPlugin_mip_MTIP;
            _zz_CsrPlugin_csrMapping_readDataInit_1[3 : 3]   = CsrPlugin_mip_MSIP;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_2 = 32'h0;
        if (execute_CsrPlugin_csr_772) begin
            _zz_CsrPlugin_csrMapping_readDataInit_2[11 : 11] = CsrPlugin_mie_MEIE;
            _zz_CsrPlugin_csrMapping_readDataInit_2[7 : 7]   = CsrPlugin_mie_MTIE;
            _zz_CsrPlugin_csrMapping_readDataInit_2[3 : 3]   = CsrPlugin_mie_MSIE;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_3 = 32'h0;
        if (execute_CsrPlugin_csr_773) begin
            _zz_CsrPlugin_csrMapping_readDataInit_3[31 : 2] = CsrPlugin_mtvec_base;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_4 = 32'h0;
        if (execute_CsrPlugin_csr_833) begin
            _zz_CsrPlugin_csrMapping_readDataInit_4[31 : 0] = CsrPlugin_mepc;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_5 = 32'h0;
        if (execute_CsrPlugin_csr_834) begin
            _zz_CsrPlugin_csrMapping_readDataInit_5[31 : 31] = CsrPlugin_mcause_interrupt;
            _zz_CsrPlugin_csrMapping_readDataInit_5[3 : 0]   = CsrPlugin_mcause_exceptionCode;
        end
    end

    always @(*) begin
        _zz_CsrPlugin_csrMapping_readDataInit_6 = 32'h0;
        if (execute_CsrPlugin_csr_835) begin
            _zz_CsrPlugin_csrMapping_readDataInit_6[31 : 0] = CsrPlugin_mtval;
        end
    end

    assign CsrPlugin_csrMapping_readDataInit = (((_zz_CsrPlugin_csrMapping_readDataInit | _zz_CsrPlugin_csrMapping_readDataInit_1) | (_zz_CsrPlugin_csrMapping_readDataInit_2 | _zz_CsrPlugin_csrMapping_readDataInit_3)) | ((_zz_CsrPlugin_csrMapping_readDataInit_4 | _zz_CsrPlugin_csrMapping_readDataInit_5) | _zz_CsrPlugin_csrMapping_readDataInit_6));
    assign when_CsrPlugin_l1702 = ((execute_arbitration_isValid && execute_IS_CSR) && (({execute_CsrPlugin_csrAddress[11 : 2],2'b00} == 12'h3a0) || ({execute_CsrPlugin_csrAddress[11 : 4],4'b0000} == 12'h3b0)));
    assign _zz_when_CsrPlugin_l1709 = (execute_CsrPlugin_csrAddress & 12'hf60);
    assign when_CsrPlugin_l1709 = (((execute_arbitration_isValid && execute_IS_CSR) && (5'h03 <= execute_CsrPlugin_csrAddress[4 : 0])) && (((_zz_when_CsrPlugin_l1709 == 12'hb00) || (((_zz_when_CsrPlugin_l1709 == 12'hc00) && (! execute_CsrPlugin_writeInstruction)) && (CsrPlugin_privilege == 2'b11))) || ((execute_CsrPlugin_csrAddress & 12'hfe0) == 12'h320)));
    always @(*) begin
        when_CsrPlugin_l1719 = CsrPlugin_csrMapping_doForceFailCsr;
        if (when_CsrPlugin_l1717) begin
            when_CsrPlugin_l1719 = 1'b1;
        end
    end

    assign when_CsrPlugin_l1717 = (CsrPlugin_privilege < execute_CsrPlugin_csrAddress[9 : 8]);
    assign when_CsrPlugin_l1725 = ((!execute_arbitration_isValid) || (!execute_IS_CSR));
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            IBusSimplePlugin_fetchPc_pcReg <= 32'h80000000;
            IBusSimplePlugin_fetchPc_correctionReg <= 1'b0;
            IBusSimplePlugin_fetchPc_booted <= 1'b0;
            IBusSimplePlugin_fetchPc_inc <= 1'b0;
            _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1 <= 1'b0;
            _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid <= 1'b0;
            _zz_IBusSimplePlugin_injector_decodeInput_valid <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            IBusSimplePlugin_injector_nextPcCalc_valids_5 <= 1'b0;
            IBusSimplePlugin_pending_value <= 3'b000;
            IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= 3'b000;
            CsrPlugin_mtvec_base <= 30'h20000008;
            CsrPlugin_mstatus_MIE <= 1'b0;
            CsrPlugin_mstatus_MPIE <= 1'b0;
            CsrPlugin_mstatus_MPP <= 2'b11;
            CsrPlugin_mie_MEIE <= 1'b0;
            CsrPlugin_mie_MTIE <= 1'b0;
            CsrPlugin_mie_MSIE <= 1'b0;
            CsrPlugin_mcycle <= 64'h0;
            CsrPlugin_minstret <= 64'h0;
            CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
            CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= 1'b0;
            CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
            CsrPlugin_interrupt_valid <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_1 <= 1'b0;
            CsrPlugin_pipelineLiberator_pcValids_2 <= 1'b0;
            CsrPlugin_hadException <= 1'b0;
            execute_CsrPlugin_wfiWake <= 1'b0;
            _zz_5 <= 1'b1;
            HazardSimplePlugin_writeBackBuffer_valid <= 1'b0;
            memory_DivPlugin_div_counter_value <= 6'h0;
            execute_arbitration_isValid <= 1'b0;
            memory_arbitration_isValid <= 1'b0;
            writeBack_arbitration_isValid <= 1'b0;
            IBusSimplePlugin_injector_port_state <= 3'b000;
        end else begin
            if (IBusSimplePlugin_fetchPc_correction) begin
                IBusSimplePlugin_fetchPc_correctionReg <= 1'b1;
            end
            if (IBusSimplePlugin_fetchPc_output_fire) begin
                IBusSimplePlugin_fetchPc_correctionReg <= 1'b0;
            end
            IBusSimplePlugin_fetchPc_booted <= 1'b1;
            if (when_Fetcher_l133) begin
                IBusSimplePlugin_fetchPc_inc <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_output_fire) begin
                IBusSimplePlugin_fetchPc_inc <= 1'b1;
            end
            if (when_Fetcher_l133_1) begin
                IBusSimplePlugin_fetchPc_inc <= 1'b0;
            end
            if (when_Fetcher_l160) begin
                IBusSimplePlugin_fetchPc_pcReg <= IBusSimplePlugin_fetchPc_pc;
            end
            if (IBusSimplePlugin_iBusRsp_flush) begin
                _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1 <= 1'b0;
            end
            if (_zz_IBusSimplePlugin_iBusRsp_stages_0_output_ready) begin
                _zz_IBusSimplePlugin_iBusRsp_stages_1_input_valid_1 <= (IBusSimplePlugin_iBusRsp_stages_0_output_valid && (! 1'b0));
            end
            if (IBusSimplePlugin_iBusRsp_flush) begin
                _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid <= 1'b0;
            end
            if (IBusSimplePlugin_iBusRsp_stages_1_output_ready) begin
                _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_valid <= (IBusSimplePlugin_iBusRsp_stages_1_output_valid && (! IBusSimplePlugin_iBusRsp_flush));
            end
            if (decode_arbitration_removeIt) begin
                _zz_IBusSimplePlugin_injector_decodeInput_valid <= 1'b0;
            end
            if (IBusSimplePlugin_iBusRsp_output_ready) begin
                _zz_IBusSimplePlugin_injector_decodeInput_valid <= (IBusSimplePlugin_iBusRsp_output_valid && (! IBusSimplePlugin_externalFlush));
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
            end
            if (when_Fetcher_l331) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b1;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            end
            if (when_Fetcher_l331_1) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_1 <= IBusSimplePlugin_injector_nextPcCalc_valids_0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            end
            if (when_Fetcher_l331_2) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_2 <= IBusSimplePlugin_injector_nextPcCalc_valids_1;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_2 <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            end
            if (when_Fetcher_l331_3) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_3 <= IBusSimplePlugin_injector_nextPcCalc_valids_2;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_3 <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            end
            if (when_Fetcher_l331_4) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_4 <= IBusSimplePlugin_injector_nextPcCalc_valids_3;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_4 <= 1'b0;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_5 <= 1'b0;
            end
            if (when_Fetcher_l331_5) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_5 <= IBusSimplePlugin_injector_nextPcCalc_valids_4;
            end
            if (IBusSimplePlugin_fetchPc_flushed) begin
                IBusSimplePlugin_injector_nextPcCalc_valids_5 <= 1'b0;
            end
            IBusSimplePlugin_pending_value <= IBusSimplePlugin_pending_next;
            IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= (IBusSimplePlugin_rspJoin_rspBuffer_discardCounter - _zz_IBusSimplePlugin_rspJoin_rspBuffer_discardCounter);
            if (IBusSimplePlugin_iBusRsp_flush) begin
                IBusSimplePlugin_rspJoin_rspBuffer_discardCounter <= IBusSimplePlugin_pending_next;
            end
            CsrPlugin_mcycle <= (CsrPlugin_mcycle + 64'h0000000000000001);
            if (writeBack_arbitration_isFiring) begin
                CsrPlugin_minstret <= (CsrPlugin_minstret + 64'h0000000000000001);
            end
            if (when_CsrPlugin_l1259) begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
            end else begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
            end
            if (when_CsrPlugin_l1259_1) begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= (CsrPlugin_exceptionPortCtrl_exceptionValids_execute && (! execute_arbitration_isStuck));
            end else begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
            end
            if (when_CsrPlugin_l1259_2) begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= (CsrPlugin_exceptionPortCtrl_exceptionValids_memory && (! memory_arbitration_isStuck));
            end else begin
                CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
            end
            CsrPlugin_interrupt_valid <= 1'b0;
            if (when_CsrPlugin_l1296) begin
                if (when_CsrPlugin_l1302) begin
                    CsrPlugin_interrupt_valid <= 1'b1;
                end
                if (when_CsrPlugin_l1302_1) begin
                    CsrPlugin_interrupt_valid <= 1'b1;
                end
                if (when_CsrPlugin_l1302_2) begin
                    CsrPlugin_interrupt_valid <= 1'b1;
                end
            end
            if (CsrPlugin_pipelineLiberator_active) begin
                if (when_CsrPlugin_l1335) begin
                    CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b1;
                end
                if (when_CsrPlugin_l1335_1) begin
                    CsrPlugin_pipelineLiberator_pcValids_1 <= CsrPlugin_pipelineLiberator_pcValids_0;
                end
                if (when_CsrPlugin_l1335_2) begin
                    CsrPlugin_pipelineLiberator_pcValids_2 <= CsrPlugin_pipelineLiberator_pcValids_1;
                end
            end
            if (when_CsrPlugin_l1340) begin
                CsrPlugin_pipelineLiberator_pcValids_0 <= 1'b0;
                CsrPlugin_pipelineLiberator_pcValids_1 <= 1'b0;
                CsrPlugin_pipelineLiberator_pcValids_2 <= 1'b0;
            end
            if (CsrPlugin_interruptJump) begin
                CsrPlugin_interrupt_valid <= 1'b0;
            end
            CsrPlugin_hadException <= CsrPlugin_exception;
            if (when_CsrPlugin_l1390) begin
                if (when_CsrPlugin_l1398) begin
                    case (CsrPlugin_targetPrivilege)
                        2'b11: begin
                            CsrPlugin_mstatus_MIE  <= 1'b0;
                            CsrPlugin_mstatus_MPIE <= CsrPlugin_mstatus_MIE;
                            CsrPlugin_mstatus_MPP  <= CsrPlugin_privilege;
                        end
                        default: begin
                        end
                    endcase
                end
            end
            if (when_CsrPlugin_l1456) begin
                case (switch_CsrPlugin_l1460)
                    2'b11: begin
                        CsrPlugin_mstatus_MPP  <= 2'b00;
                        CsrPlugin_mstatus_MIE  <= CsrPlugin_mstatus_MPIE;
                        CsrPlugin_mstatus_MPIE <= 1'b1;
                    end
                    default: begin
                    end
                endcase
            end
            execute_CsrPlugin_wfiWake <= ((|{_zz_when_CsrPlugin_l1302_2,{_zz_when_CsrPlugin_l1302_1,_zz_when_CsrPlugin_l1302}}) || CsrPlugin_thirdPartyWake);
            _zz_5 <= 1'b0;
            HazardSimplePlugin_writeBackBuffer_valid <= HazardSimplePlugin_writeBackWrites_valid;
            memory_DivPlugin_div_counter_value <= memory_DivPlugin_div_counter_valueNext;
            if (when_Pipeline_l151) begin
                execute_arbitration_isValid <= 1'b0;
            end
            if (when_Pipeline_l154) begin
                execute_arbitration_isValid <= decode_arbitration_isValid;
            end
            if (when_Pipeline_l151_1) begin
                memory_arbitration_isValid <= 1'b0;
            end
            if (when_Pipeline_l154_1) begin
                memory_arbitration_isValid <= execute_arbitration_isValid;
            end
            if (when_Pipeline_l151_2) begin
                writeBack_arbitration_isValid <= 1'b0;
            end
            if (when_Pipeline_l154_2) begin
                writeBack_arbitration_isValid <= memory_arbitration_isValid;
            end
            case (IBusSimplePlugin_injector_port_state)
                3'b000: begin
                    if (DebugPlugin_injectionPort_valid) begin
                        IBusSimplePlugin_injector_port_state <= 3'b001;
                    end
                end
                3'b001: begin
                    IBusSimplePlugin_injector_port_state <= 3'b010;
                end
                3'b010: begin
                    IBusSimplePlugin_injector_port_state <= 3'b011;
                end
                3'b011: begin
                    if (when_Fetcher_l391) begin
                        IBusSimplePlugin_injector_port_state <= 3'b100;
                    end
                end
                3'b100: begin
                    IBusSimplePlugin_injector_port_state <= 3'b000;
                end
                default: begin
                end
            endcase
            if (execute_CsrPlugin_csr_768) begin
                if (execute_CsrPlugin_writeEnable) begin
                    CsrPlugin_mstatus_MPIE <= CsrPlugin_csrMapping_writeDataSignal[7];
                    CsrPlugin_mstatus_MIE  <= CsrPlugin_csrMapping_writeDataSignal[3];
                    case (switch_CsrPlugin_l1031)
                        2'b11: begin
                            CsrPlugin_mstatus_MPP <= 2'b11;
                        end
                        default: begin
                        end
                    endcase
                end
            end
            if (execute_CsrPlugin_csr_772) begin
                if (execute_CsrPlugin_writeEnable) begin
                    CsrPlugin_mie_MEIE <= CsrPlugin_csrMapping_writeDataSignal[11];
                    CsrPlugin_mie_MTIE <= CsrPlugin_csrMapping_writeDataSignal[7];
                    CsrPlugin_mie_MSIE <= CsrPlugin_csrMapping_writeDataSignal[3];
                end
            end
            if (execute_CsrPlugin_csr_773) begin
                if (execute_CsrPlugin_writeEnable) begin
                    CsrPlugin_mtvec_base <= CsrPlugin_csrMapping_writeDataSignal[31 : 2];
                end
            end
        end
    end

    always @(posedge io_mainClk) begin
        if (IBusSimplePlugin_iBusRsp_stages_1_output_ready) begin
            _zz_IBusSimplePlugin_iBusRsp_stages_1_output_m2sPipe_payload <= IBusSimplePlugin_iBusRsp_stages_1_output_payload;
        end
        if (IBusSimplePlugin_iBusRsp_output_ready) begin
            _zz_IBusSimplePlugin_injector_decodeInput_payload_pc <= IBusSimplePlugin_iBusRsp_output_payload_pc;
            _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_error <= IBusSimplePlugin_iBusRsp_output_payload_rsp_error;
            _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst <= IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
            _zz_IBusSimplePlugin_injector_decodeInput_payload_isRvc <= IBusSimplePlugin_iBusRsp_output_payload_isRvc;
        end
        if (IBusSimplePlugin_injector_decodeInput_ready) begin
            IBusSimplePlugin_injector_formal_rawInDecode <= IBusSimplePlugin_iBusRsp_output_payload_rsp_inst;
        end
        CsrPlugin_mip_MEIP <= externalInterrupt;
        CsrPlugin_mip_MTIP <= timerInterrupt;
        CsrPlugin_mip_MSIP <= softwareInterrupt;
        if (CsrPlugin_selfException_valid) begin
            CsrPlugin_exceptionPortCtrl_exceptionContext_code <= CsrPlugin_selfException_payload_code;
            CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= CsrPlugin_selfException_payload_badAddr;
        end
        if (when_CsrPlugin_l1296) begin
            if (when_CsrPlugin_l1302) begin
                CsrPlugin_interrupt_code <= 4'b0111;
                CsrPlugin_interrupt_targetPrivilege <= 2'b11;
            end
            if (when_CsrPlugin_l1302_1) begin
                CsrPlugin_interrupt_code <= 4'b0011;
                CsrPlugin_interrupt_targetPrivilege <= 2'b11;
            end
            if (when_CsrPlugin_l1302_2) begin
                CsrPlugin_interrupt_code <= 4'b1011;
                CsrPlugin_interrupt_targetPrivilege <= 2'b11;
            end
        end
        if (when_CsrPlugin_l1390) begin
            if (when_CsrPlugin_l1398) begin
                case (CsrPlugin_targetPrivilege)
                    2'b11: begin
                        CsrPlugin_mcause_interrupt <= (!CsrPlugin_hadException);
                        CsrPlugin_mcause_exceptionCode <= CsrPlugin_trapCause;
                        CsrPlugin_mepc <= writeBack_PC;
                        if (CsrPlugin_hadException) begin
                            CsrPlugin_mtval <= CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
                        end
                    end
                    default: begin
                    end
                endcase
            end
        end
        HazardSimplePlugin_writeBackBuffer_payload_address <= HazardSimplePlugin_writeBackWrites_payload_address;
        HazardSimplePlugin_writeBackBuffer_payload_data <= HazardSimplePlugin_writeBackWrites_payload_data;
        if (when_MulDivIterativePlugin_l126) begin
            memory_DivPlugin_div_done <= 1'b1;
        end
        if (when_MulDivIterativePlugin_l126_1) begin
            memory_DivPlugin_div_done <= 1'b0;
        end
        if (when_MulDivIterativePlugin_l128) begin
            if (when_MulDivIterativePlugin_l132) begin
                memory_DivPlugin_rs1[31 : 0] <= memory_DivPlugin_div_stage_0_outNumerator;
                memory_DivPlugin_accumulator[31 : 0] <= memory_DivPlugin_div_stage_0_outRemainder;
                if (when_MulDivIterativePlugin_l151) begin
                    memory_DivPlugin_div_result <= _zz_memory_DivPlugin_div_result_1[31:0];
                end
            end
        end
        if (when_MulDivIterativePlugin_l162) begin
            memory_DivPlugin_accumulator <= 65'h0;
            memory_DivPlugin_rs1 <= ((_zz_memory_DivPlugin_rs1 ? (~ _zz_memory_DivPlugin_rs1_1) : _zz_memory_DivPlugin_rs1_1) + _zz_memory_DivPlugin_rs1_2);
            memory_DivPlugin_rs2 <= ((_zz_memory_DivPlugin_rs2 ? (~ execute_RS2) : execute_RS2) + _zz_memory_DivPlugin_rs2_1);
            memory_DivPlugin_div_needRevert <= ((_zz_memory_DivPlugin_rs1 ^ (_zz_memory_DivPlugin_rs2 && (! execute_INSTRUCTION[13]))) && (! (((execute_RS2 == 32'h0) && execute_IS_RS2_SIGNED) && (! execute_INSTRUCTION[13]))));
        end
        if (when_Pipeline_l124) begin
            decode_to_execute_PC <= _zz_decode_to_execute_PC;
        end
        if (when_Pipeline_l124_1) begin
            execute_to_memory_PC <= execute_PC;
        end
        if (when_Pipeline_l124_2) begin
            memory_to_writeBack_PC <= memory_PC;
        end
        if (when_Pipeline_l124_3) begin
            decode_to_execute_INSTRUCTION <= decode_INSTRUCTION;
        end
        if (when_Pipeline_l124_4) begin
            execute_to_memory_INSTRUCTION <= execute_INSTRUCTION;
        end
        if (when_Pipeline_l124_5) begin
            memory_to_writeBack_INSTRUCTION <= memory_INSTRUCTION;
        end
        if (when_Pipeline_l124_6) begin
            decode_to_execute_FORMAL_PC_NEXT <= decode_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_7) begin
            execute_to_memory_FORMAL_PC_NEXT <= execute_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_8) begin
            memory_to_writeBack_FORMAL_PC_NEXT <= _zz_memory_to_writeBack_FORMAL_PC_NEXT;
        end
        if (when_Pipeline_l124_9) begin
            decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
        end
        if (when_Pipeline_l124_10) begin
            decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
        end
        if (when_Pipeline_l124_11) begin
            decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
        end
        if (when_Pipeline_l124_12) begin
            decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
        end
        if (when_Pipeline_l124_13) begin
            execute_to_memory_MEMORY_ENABLE <= execute_MEMORY_ENABLE;
        end
        if (when_Pipeline_l124_14) begin
            memory_to_writeBack_MEMORY_ENABLE <= memory_MEMORY_ENABLE;
        end
        if (when_Pipeline_l124_15) begin
            decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_16) begin
            execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_17) begin
            memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
        end
        if (when_Pipeline_l124_18) begin
            decode_to_execute_BYPASSABLE_EXECUTE_STAGE <= decode_BYPASSABLE_EXECUTE_STAGE;
        end
        if (when_Pipeline_l124_19) begin
            decode_to_execute_BYPASSABLE_MEMORY_STAGE <= decode_BYPASSABLE_MEMORY_STAGE;
        end
        if (when_Pipeline_l124_20) begin
            execute_to_memory_BYPASSABLE_MEMORY_STAGE <= execute_BYPASSABLE_MEMORY_STAGE;
        end
        if (when_Pipeline_l124_21) begin
            decode_to_execute_MEMORY_STORE <= decode_MEMORY_STORE;
        end
        if (when_Pipeline_l124_22) begin
            execute_to_memory_MEMORY_STORE <= execute_MEMORY_STORE;
        end
        if (when_Pipeline_l124_23) begin
            decode_to_execute_IS_CSR <= decode_IS_CSR;
        end
        if (when_Pipeline_l124_24) begin
            decode_to_execute_ENV_CTRL <= _zz_decode_to_execute_ENV_CTRL;
        end
        if (when_Pipeline_l124_25) begin
            execute_to_memory_ENV_CTRL <= _zz_execute_to_memory_ENV_CTRL;
        end
        if (when_Pipeline_l124_26) begin
            memory_to_writeBack_ENV_CTRL <= _zz_memory_to_writeBack_ENV_CTRL;
        end
        if (when_Pipeline_l124_27) begin
            decode_to_execute_ALU_CTRL <= _zz_decode_to_execute_ALU_CTRL;
        end
        if (when_Pipeline_l124_28) begin
            decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
        end
        if (when_Pipeline_l124_29) begin
            decode_to_execute_ALU_BITWISE_CTRL <= _zz_decode_to_execute_ALU_BITWISE_CTRL;
        end
        if (when_Pipeline_l124_30) begin
            decode_to_execute_IS_MUL <= decode_IS_MUL;
        end
        if (when_Pipeline_l124_31) begin
            execute_to_memory_IS_MUL <= execute_IS_MUL;
        end
        if (when_Pipeline_l124_32) begin
            memory_to_writeBack_IS_MUL <= memory_IS_MUL;
        end
        if (when_Pipeline_l124_33) begin
            decode_to_execute_IS_DIV <= decode_IS_DIV;
        end
        if (when_Pipeline_l124_34) begin
            execute_to_memory_IS_DIV <= execute_IS_DIV;
        end
        if (when_Pipeline_l124_35) begin
            decode_to_execute_IS_RS1_SIGNED <= decode_IS_RS1_SIGNED;
        end
        if (when_Pipeline_l124_36) begin
            decode_to_execute_IS_RS2_SIGNED <= decode_IS_RS2_SIGNED;
        end
        if (when_Pipeline_l124_37) begin
            decode_to_execute_BRANCH_CTRL <= _zz_decode_to_execute_BRANCH_CTRL;
        end
        if (when_Pipeline_l124_38) begin
            decode_to_execute_SHIFT_CTRL <= _zz_decode_to_execute_SHIFT_CTRL;
        end
        if (when_Pipeline_l124_39) begin
            execute_to_memory_SHIFT_CTRL <= _zz_execute_to_memory_SHIFT_CTRL;
        end
        if (when_Pipeline_l124_40) begin
            decode_to_execute_RS1 <= _zz_decode_to_execute_RS1;
        end
        if (when_Pipeline_l124_41) begin
            decode_to_execute_RS2 <= _zz_decode_to_execute_RS2;
        end
        if (when_Pipeline_l124_42) begin
            decode_to_execute_SRC2_FORCE_ZERO <= decode_SRC2_FORCE_ZERO;
        end
        if (when_Pipeline_l124_43) begin
            decode_to_execute_SRC1 <= decode_SRC1;
        end
        if (when_Pipeline_l124_44) begin
            decode_to_execute_SRC2 <= decode_SRC2;
        end
        if (when_Pipeline_l124_45) begin
            decode_to_execute_DO_EBREAK <= decode_DO_EBREAK;
        end
        if (when_Pipeline_l124_46) begin
            execute_to_memory_MEMORY_ADDRESS_LOW <= execute_MEMORY_ADDRESS_LOW;
        end
        if (when_Pipeline_l124_47) begin
            memory_to_writeBack_MEMORY_ADDRESS_LOW <= memory_MEMORY_ADDRESS_LOW;
        end
        if (when_Pipeline_l124_48) begin
            execute_to_memory_REGFILE_WRITE_DATA <= _zz_decode_RS2_1;
        end
        if (when_Pipeline_l124_49) begin
            memory_to_writeBack_REGFILE_WRITE_DATA <= _zz_decode_RS2;
        end
        if (when_Pipeline_l124_50) begin
            execute_to_memory_MUL_LL <= execute_MUL_LL;
        end
        if (when_Pipeline_l124_51) begin
            execute_to_memory_MUL_LH <= execute_MUL_LH;
        end
        if (when_Pipeline_l124_52) begin
            execute_to_memory_MUL_HL <= execute_MUL_HL;
        end
        if (when_Pipeline_l124_53) begin
            execute_to_memory_MUL_HH <= execute_MUL_HH;
        end
        if (when_Pipeline_l124_54) begin
            memory_to_writeBack_MUL_HH <= memory_MUL_HH;
        end
        if (when_Pipeline_l124_55) begin
            execute_to_memory_BRANCH_DO <= execute_BRANCH_DO;
        end
        if (when_Pipeline_l124_56) begin
            execute_to_memory_BRANCH_CALC <= execute_BRANCH_CALC;
        end
        if (when_Pipeline_l124_57) begin
            execute_to_memory_SHIFT_RIGHT <= execute_SHIFT_RIGHT;
        end
        if (when_Pipeline_l124_58) begin
            memory_to_writeBack_MEMORY_READ_DATA <= memory_MEMORY_READ_DATA;
        end
        if (when_Pipeline_l124_59) begin
            memory_to_writeBack_MUL_LOW <= memory_MUL_LOW;
        end
        if (when_Fetcher_l411) begin
            _zz_IBusSimplePlugin_injector_decodeInput_payload_rsp_inst <= DebugPlugin_injectionPort_payload;
        end
        if (when_CsrPlugin_l1669) begin
            execute_CsrPlugin_csr_768 <= (decode_INSTRUCTION[31 : 20] == 12'h300);
        end
        if (when_CsrPlugin_l1669_1) begin
            execute_CsrPlugin_csr_836 <= (decode_INSTRUCTION[31 : 20] == 12'h344);
        end
        if (when_CsrPlugin_l1669_2) begin
            execute_CsrPlugin_csr_772 <= (decode_INSTRUCTION[31 : 20] == 12'h304);
        end
        if (when_CsrPlugin_l1669_3) begin
            execute_CsrPlugin_csr_773 <= (decode_INSTRUCTION[31 : 20] == 12'h305);
        end
        if (when_CsrPlugin_l1669_4) begin
            execute_CsrPlugin_csr_833 <= (decode_INSTRUCTION[31 : 20] == 12'h341);
        end
        if (when_CsrPlugin_l1669_5) begin
            execute_CsrPlugin_csr_834 <= (decode_INSTRUCTION[31 : 20] == 12'h342);
        end
        if (when_CsrPlugin_l1669_6) begin
            execute_CsrPlugin_csr_835 <= (decode_INSTRUCTION[31 : 20] == 12'h343);
        end
        if (execute_CsrPlugin_csr_836) begin
            if (execute_CsrPlugin_writeEnable) begin
                CsrPlugin_mip_MSIP <= CsrPlugin_csrMapping_writeDataSignal[3];
            end
        end
        if (execute_CsrPlugin_csr_833) begin
            if (execute_CsrPlugin_writeEnable) begin
                CsrPlugin_mepc <= CsrPlugin_csrMapping_writeDataSignal[31 : 0];
            end
        end
    end

    always @(posedge io_mainClk) begin
        DebugPlugin_firstCycle <= 1'b0;
        if (debug_bus_cmd_ready) begin
            DebugPlugin_firstCycle <= 1'b1;
        end
        DebugPlugin_secondCycle <= DebugPlugin_firstCycle;
        DebugPlugin_isPipBusy <= ((|{writeBack_arbitration_isValid,{memory_arbitration_isValid,{execute_arbitration_isValid,decode_arbitration_isValid}}}) || IBusSimplePlugin_incomingInstruction);
        if (writeBack_arbitration_isValid) begin
            DebugPlugin_busReadDataReg <= _zz_decode_RS2_2;
        end
        _zz_when_DebugPlugin_l257 <= debug_bus_cmd_payload_address[2];
        if (when_DebugPlugin_l308) begin
            DebugPlugin_busReadDataReg <= execute_PC;
        end
        DebugPlugin_resetIt_regNext <= DebugPlugin_resetIt;
    end

    always @(posedge io_mainClk or posedge resetCtrl_mainClkReset) begin
        if (resetCtrl_mainClkReset) begin
            DebugPlugin_resetIt <= 1'b0;
            DebugPlugin_haltIt <= 1'b0;
            DebugPlugin_stepIt <= 1'b0;
            DebugPlugin_godmode <= 1'b0;
            DebugPlugin_haltedByBreak <= 1'b0;
            DebugPlugin_debugUsed <= 1'b0;
            DebugPlugin_disableEbreak <= 1'b0;
        end else begin
            if (when_DebugPlugin_l238) begin
                DebugPlugin_godmode <= 1'b1;
            end
            if (debug_bus_cmd_valid) begin
                DebugPlugin_debugUsed <= 1'b1;
            end
            if (debug_bus_cmd_valid) begin
                case (switch_DebugPlugin_l280)
                    6'h0: begin
                        if (debug_bus_cmd_payload_wr) begin
                            DebugPlugin_stepIt <= debug_bus_cmd_payload_data[4];
                            if (when_DebugPlugin_l284) begin
                                DebugPlugin_resetIt <= 1'b1;
                            end
                            if (when_DebugPlugin_l284_1) begin
                                DebugPlugin_resetIt <= 1'b0;
                            end
                            if (when_DebugPlugin_l285) begin
                                DebugPlugin_haltIt <= 1'b1;
                            end
                            if (when_DebugPlugin_l285_1) begin
                                DebugPlugin_haltIt <= 1'b0;
                            end
                            if (when_DebugPlugin_l286) begin
                                DebugPlugin_haltedByBreak <= 1'b0;
                            end
                            if (when_DebugPlugin_l287) begin
                                DebugPlugin_godmode <= 1'b0;
                            end
                            if (when_DebugPlugin_l288) begin
                                DebugPlugin_disableEbreak <= 1'b1;
                            end
                            if (when_DebugPlugin_l288_1) begin
                                DebugPlugin_disableEbreak <= 1'b0;
                            end
                        end
                    end
                    default: begin
                    end
                endcase
            end
            if (when_DebugPlugin_l308) begin
                if (when_DebugPlugin_l311) begin
                    DebugPlugin_haltIt <= 1'b1;
                    DebugPlugin_haltedByBreak <= 1'b1;
                end
            end
            if (when_DebugPlugin_l324) begin
                if (decode_arbitration_isValid) begin
                    DebugPlugin_haltIt <= 1'b1;
                end
            end
        end
    end

endmodule
