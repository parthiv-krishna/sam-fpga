`timescale 1ns / 1ps
// sam_wrapper: wraps around all custom HDL logic
// and exposes a basic interface to the block diagram

module sam_wrapper(
    input clk,
    input rstn,
    input [31:0] in_data,
    output in_ready,
    input in_valid,
    input in_last,
    output [31:0] out_data,
    input out_ready,
    output out_valid,
    output out_last
    );
    
    
    assign out_data = in_data + 1;
    assign in_ready = out_ready;
    assign out_valid = in_valid;
    assign out_last = in_last;
endmodule
