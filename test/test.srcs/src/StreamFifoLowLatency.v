`timescale 1ns / 1ps

module StreamFifoLowLatency (
    input  wire        io_push_valid,
    output wire        io_push_ready,
    input  wire        io_push_payload_error,
    input  wire [31:0] io_push_payload_inst,
    output wire        io_pop_valid,
    input  wire        io_pop_ready,
    output wire        io_pop_payload_error,
    output wire [31:0] io_pop_payload_inst,
    input  wire        io_flush,
    output wire [ 0:0] io_occupancy,
    output wire [ 0:0] io_availability,
    input  wire        io_mainClk,
    input  wire        resetCtrl_systemReset
);

    wire        fifo_io_push_ready;
    wire        fifo_io_pop_valid;
    wire        fifo_io_pop_payload_error;
    wire [31:0] fifo_io_pop_payload_inst;
    wire [ 0:0] fifo_io_occupancy;
    wire [ 0:0] fifo_io_availability;

    StreamFifo_2 fifo (
        .io_push_valid        (io_push_valid),                   //i
        .io_push_ready        (fifo_io_push_ready),              //o
        .io_push_payload_error(io_push_payload_error),           //i
        .io_push_payload_inst (io_push_payload_inst[31:0]),      //i
        .io_pop_valid         (fifo_io_pop_valid),               //o
        .io_pop_ready         (io_pop_ready),                    //i
        .io_pop_payload_error (fifo_io_pop_payload_error),       //o
        .io_pop_payload_inst  (fifo_io_pop_payload_inst[31:0]),  //o
        .io_flush             (io_flush),                        //i
        .io_occupancy         (fifo_io_occupancy),               //o
        .io_availability      (fifo_io_availability),            //o
        .io_mainClk           (io_mainClk),                      //i
        .resetCtrl_systemReset(resetCtrl_systemReset)            //i
    );
    assign io_push_ready = fifo_io_push_ready;
    assign io_pop_valid = fifo_io_pop_valid;
    assign io_pop_payload_error = fifo_io_pop_payload_error;
    assign io_pop_payload_inst = fifo_io_pop_payload_inst;
    assign io_occupancy = fifo_io_occupancy;
    assign io_availability = fifo_io_availability;

endmodule
