`timescale 1ns / 1ps

module Apb3Timer (
    input  wire [ 7:0] io_apb_PADDR,
    input  wire [ 0:0] io_apb_PSEL,
    input  wire        io_apb_PENABLE,
    output wire        io_apb_PREADY,
    input  wire        io_apb_PWRITE,
    input  wire [31:0] io_apb_PWDATA,
    output reg  [31:0] io_apb_PRDATA,

    output wire        io_apb_PSLVERROR,
    output wire        io_interrupt,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    wire        timerA_io_tick;
    wire        timerA_io_clear;
    wire        timerB_io_tick;
    wire        timerB_io_clear;
    reg  [ 1:0] interruptCtrl_1_io_inputs;
    reg  [ 1:0] interruptCtrl_1_io_clears;
    wire        prescaler_1_io_overflow;
    wire        timerA_io_full;
    wire [15:0] timerA_io_value;
    wire        timerB_io_full;
    wire [15:0] timerB_io_value;
    wire [ 1:0] interruptCtrl_1_io_pendings;
    wire        busCtrl_readErrorFlag;
    wire        busCtrl_writeErrorFlag;
    wire        busCtrl_askWrite;
    wire        busCtrl_askRead;
    wire        busCtrl_doWrite;
    wire        busCtrl_doRead;
    reg  [15:0] _zz_io_limit;
    reg         _zz_io_clear;
    reg  [ 1:0] timerABridge_ticksEnable;
    reg  [ 0:0] timerABridge_clearsEnable;
    reg         timerABridge_busClearing;
    reg  [15:0] system_timer_timerA_io_limit_driver;
    reg         when_Timer_l40;
    reg         when_Timer_l44;
    reg  [ 1:0] timerBBridge_ticksEnable;
    reg  [ 0:0] timerBBridge_clearsEnable;
    reg         timerBBridge_busClearing;
    reg  [15:0] system_timer_timerB_io_limit_driver;
    reg         when_Timer_l40_1;
    reg         when_Timer_l44_1;
    reg  [ 1:0] system_timer_interruptCtrl_1_io_masks_driver;

    Prescaler Prescaler (
        .io_clear             (_zz_io_clear),             //i
        .io_limit             (_zz_io_limit[15:0]),       //i
        .io_overflow          (prescaler_1_io_overflow),  //o
        .io_mainClk           (io_mainClk),               //i
        .resetCtrl_systemReset(resetCtrl_systemReset)     //i
    );
    Timer timerA (
        .io_tick              (timerA_io_tick),                             //i
        .io_clear             (timerA_io_clear),                            //i
        .io_limit             (system_timer_timerA_io_limit_driver[15:0]),  //i
        .io_full              (timerA_io_full),                             //o
        .io_value             (timerA_io_value[15:0]),                      //o
        .io_mainClk           (io_mainClk),                                 //i
        .resetCtrl_systemReset(resetCtrl_systemReset)                       //i
    );
    Timer timerB (
        .io_tick              (timerB_io_tick),                             //i
        .io_clear             (timerB_io_clear),                            //i
        .io_limit             (system_timer_timerB_io_limit_driver[15:0]),  //i
        .io_full              (timerB_io_full),                             //o
        .io_value             (timerB_io_value[15:0]),                      //o
        .io_mainClk           (io_mainClk),                                 //i
        .resetCtrl_systemReset(resetCtrl_systemReset)                       //i
    );
    InterruptCtrl InterruptCtrl (
        .io_inputs            (interruptCtrl_1_io_inputs[1:0]),                     //i
        .io_clears            (interruptCtrl_1_io_clears[1:0]),                     //i
        .io_masks             (system_timer_interruptCtrl_1_io_masks_driver[1:0]),  //i
        .io_pendings          (interruptCtrl_1_io_pendings[1:0]),                   //o
        .io_mainClk           (io_mainClk),                                         //i
        .resetCtrl_systemReset(resetCtrl_systemReset)                               //i
    );
    assign busCtrl_readErrorFlag = 1'b0;
    assign busCtrl_writeErrorFlag = 1'b0;
    assign io_apb_PREADY = 1'b1;
    always @(*) begin
        io_apb_PRDATA = 32'h0;
        case (io_apb_PADDR)
            8'h0: begin
                io_apb_PRDATA[15 : 0] = _zz_io_limit;
            end
            8'h40: begin
                io_apb_PRDATA[1 : 0]   = timerABridge_ticksEnable;
                io_apb_PRDATA[16 : 16] = timerABridge_clearsEnable;
            end
            8'h44: begin
                io_apb_PRDATA[15 : 0] = system_timer_timerA_io_limit_driver;
            end
            8'h48: begin
                io_apb_PRDATA[15 : 0] = timerA_io_value;
            end
            8'h50: begin
                io_apb_PRDATA[1 : 0]   = timerBBridge_ticksEnable;
                io_apb_PRDATA[16 : 16] = timerBBridge_clearsEnable;
            end
            8'h54: begin
                io_apb_PRDATA[15 : 0] = system_timer_timerB_io_limit_driver;
            end
            8'h58: begin
                io_apb_PRDATA[15 : 0] = timerB_io_value;
            end
            8'h10: begin
                io_apb_PRDATA[1 : 0] = interruptCtrl_1_io_pendings;
            end
            8'h14: begin
                io_apb_PRDATA[1 : 0] = system_timer_interruptCtrl_1_io_masks_driver;
            end
            default: begin
            end
        endcase
    end

    assign busCtrl_askWrite = ((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PWRITE);
    assign busCtrl_askRead = ((io_apb_PSEL[0] && io_apb_PENABLE) && (!io_apb_PWRITE));
    assign busCtrl_doWrite = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && io_apb_PWRITE);
    assign busCtrl_doRead = (((io_apb_PSEL[0] && io_apb_PENABLE) && io_apb_PREADY) && (! io_apb_PWRITE));
    assign io_apb_PSLVERROR = ((busCtrl_doWrite && busCtrl_writeErrorFlag) || (busCtrl_doRead && busCtrl_readErrorFlag));
    always @(*) begin
        _zz_io_clear = 1'b0;
        case (io_apb_PADDR)
            8'h0: begin
                if (busCtrl_doWrite) begin
                    _zz_io_clear = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        timerABridge_busClearing = 1'b0;
        if (when_Timer_l40) begin
            timerABridge_busClearing = 1'b1;
        end
        if (when_Timer_l44) begin
            timerABridge_busClearing = 1'b1;
        end
    end

    always @(*) begin
        when_Timer_l40 = 1'b0;
        case (io_apb_PADDR)
            8'h44: begin
                if (busCtrl_doWrite) begin
                    when_Timer_l40 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        when_Timer_l44 = 1'b0;
        case (io_apb_PADDR)
            8'h48: begin
                if (busCtrl_doWrite) begin
                    when_Timer_l44 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign timerA_io_clear = ((|(timerABridge_clearsEnable & timerA_io_full)) || timerABridge_busClearing);
    assign timerA_io_tick = (|(timerABridge_ticksEnable &{prescaler_1_io_overflow, 1'b1}));
    always @(*) begin
        timerBBridge_busClearing = 1'b0;
        if (when_Timer_l40_1) begin
            timerBBridge_busClearing = 1'b1;
        end
        if (when_Timer_l44_1) begin
            timerBBridge_busClearing = 1'b1;
        end
    end

    always @(*) begin
        when_Timer_l40_1 = 1'b0;
        case (io_apb_PADDR)
            8'h54: begin
                if (busCtrl_doWrite) begin
                    when_Timer_l40_1 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        when_Timer_l44_1 = 1'b0;
        case (io_apb_PADDR)
            8'h58: begin
                if (busCtrl_doWrite) begin
                    when_Timer_l44_1 = 1'b1;
                end
            end
            default: begin
            end
        endcase
    end

    assign timerB_io_clear = ((|(timerBBridge_clearsEnable & timerB_io_full)) || timerBBridge_busClearing);
    assign timerB_io_tick = (|(timerBBridge_ticksEnable &{prescaler_1_io_overflow, 1'b1}));
    always @(*) begin
        interruptCtrl_1_io_clears = 2'b00;
        case (io_apb_PADDR)
            8'h10: begin
                if (busCtrl_doWrite) begin
                    interruptCtrl_1_io_clears = io_apb_PWDATA[1 : 0];
                end
            end
            default: begin
            end
        endcase
    end

    always @(*) begin
        interruptCtrl_1_io_inputs[0] = timerA_io_full;
        interruptCtrl_1_io_inputs[1] = timerB_io_full;
    end

    assign io_interrupt = (|interruptCtrl_1_io_pendings);
    always @(posedge io_mainClk or posedge resetCtrl_systemReset) begin
        if (resetCtrl_systemReset) begin
            timerABridge_ticksEnable <= 2'b00;
            timerABridge_clearsEnable <= 1'b0;
            timerBBridge_ticksEnable <= 2'b00;
            timerBBridge_clearsEnable <= 1'b0;
            system_timer_interruptCtrl_1_io_masks_driver <= 2'b00;
        end else begin
            case (io_apb_PADDR)
                8'h40: begin
                    if (busCtrl_doWrite) begin
                        timerABridge_ticksEnable  <= io_apb_PWDATA[1 : 0];
                        timerABridge_clearsEnable <= io_apb_PWDATA[16 : 16];
                    end
                end
                8'h50: begin
                    if (busCtrl_doWrite) begin
                        timerBBridge_ticksEnable  <= io_apb_PWDATA[1 : 0];
                        timerBBridge_clearsEnable <= io_apb_PWDATA[16 : 16];
                    end
                end
                8'h14: begin
                    if (busCtrl_doWrite) begin
                        system_timer_interruptCtrl_1_io_masks_driver <= io_apb_PWDATA[1 : 0];
                    end
                end
                default: begin
                end
            endcase
        end
    end

    always @(posedge io_mainClk) begin
        case (io_apb_PADDR)
            8'h0: begin
                if (busCtrl_doWrite) begin
                    _zz_io_limit <= io_apb_PWDATA[15 : 0];
                end
            end
            8'h44: begin
                if (busCtrl_doWrite) begin
                    system_timer_timerA_io_limit_driver <= io_apb_PWDATA[15 : 0];
                end
            end
            8'h54: begin
                if (busCtrl_doWrite) begin
                    system_timer_timerB_io_limit_driver <= io_apb_PWDATA[15 : 0];
                end
            end
            default: begin
            end
        endcase
    end

endmodule
