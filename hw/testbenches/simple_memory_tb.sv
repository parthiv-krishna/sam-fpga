`timescale 1ns / 1ps

module simple_memory_tb(

    );
    
    reg clk;
    reg rstn;
    reg [31:0] in_data;
    reg in_ready;
    reg in_valid;
    reg in_last;
    reg [31:0] out_data;
    reg out_ready;
    reg out_valid;
    reg out_last;
    reg mode = 1'b0;
    
    // connect all ports that have the same name as signals (which is all of them)
    sam_wrapper sam(.*);
    
    // clock 
    initial begin
        clk = 1;
        repeat (200) begin
            #5 clk = ~clk;
        end
    end
    
    initial begin
        // reset
        rstn = 0;
        #15
        rstn = 1;
        in_valid = 0;
        
        // send write
        #20
        in_data = {2'b00, 14'd5, 16'hFEED}; // STORE mem[5] = 0xFEED
        in_valid = 1;
        #10
        in_valid = 0;
        
        // send write
        #20
        in_data = {2'b00, 14'd20, 16'hFACE}; // STORE mem[20] = 0xFACE
        in_valid = 1;
        #10
        in_valid = 0;
        
        // send read
        #100
        in_data = {2'b01, 14'd5, 1'b0, 1'b0, 14'b0}; // LOAD mem[5]
        in_valid = 1;
        #10
        in_valid = 0;
        
        // send read
        #100
        in_data = {2'b01, 14'd20, 1'b0, 1'b0, 14'b0}; // LOAD mem[20]
        in_valid = 1;
        #10
        in_valid = 0;
    end
endmodule
