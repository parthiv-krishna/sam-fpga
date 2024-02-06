`timescale 1ns / 1ps
// sam_wrapper: wraps around all custom HDL logic
// and exposes a basic interface to the block diagram

//import instruction_decoder_params::*;

module sam_wrapper
//#(
//	parameter INPUT_SIGNAL_LENGTH = instruction_decoder_params::INPUT_SIGNAL_LENGTH,
//	parameter WRITE_DATA_LENGTH = instruction_decoder_params::WRITE_DATA_LENGTH,
//	parameter WRITE_ADDRESS_LENGTH = instruction_decoder_params::WRITE_ADDRESS_LENGTH,
//	parameter READ_ADDRESS_LENGTH = instruction_decoder_params::READ_ADDRESS_LENGTH
//)
(
    input clk,
    input rstn,
    input [31:0] in_data,
    output in_ready,
    input in_valid,
    input in_last,
    output [31:0] out_data,
    input out_ready,
    output out_valid,
    output out_last,
    input mode
);
    parameter INPUT_SIGNAL_LENGTH = 32;
    parameter WRITE_DATA_LENGTH = 16;
    parameter WRITE_ADDRESS_LENGTH = 14;
    parameter READ_ADDRESS_LENGTH = 14;
    //assign out_data = in_data + 1;
    //assign in_ready = out_ready;
    //assign out_valid = in_valid;
    //assign out_last = in_last;


    //using wires and registers below as 'intermediate interface' between id and ram signals
    wire [WRITE_ADDRESS_LENGTH-1:0] reg_wr_addr;
    wire [WRITE_DATA_LENGTH-1:0] reg_wr_data;
    wire [READ_ADDRESS_LENGTH-1:0] reg_rd_start_addr;
    wire [READ_ADDRESS_LENGTH-1:0] reg_rd_end_addr;
    wire reg_wr_en, reg_rd_en, reg_go;
    
    wire [WRITE_ADDRESS_LENGTH-1:0] wire_wr_addr;
    wire [WRITE_DATA_LENGTH-1:0] wire_wr_data;
    wire [READ_ADDRESS_LENGTH-1:0] wire_rd_start_addr;
    wire [READ_ADDRESS_LENGTH-1:0] wire_rd_end_addr;
    wire wire_wr_en, wire_rd_en, wire_go;
    
    instruction_decoder id(
	    .input_signal(in_data),
	    .input_valid(in_valid),
	    .wr_en(wire_wr_en),
	    .rd_en(wire_rd_en),
	    .go(wire_go),
	    .wr_addr(wire_wr_addr),
	    .wr_data(wire_wr_data),
	    .rd_start_addr(wire_rd_start_addr),
	    .rd_end_addr(wire_rd_end_addr)
    );


    //Note: confirm if active low or high reset
    dffre #(1) ff_wr_en (
	    .clk(clk),
	    .r(~rstn),
	    .en(1),
	    .d(wire_wr_en),
	    .q(reg_wr_en)
    );
    dffre #(1) ff_rd_en (
	    .clk(clk),
	    .r(~rstn),
	    .en(1),
	    .d(wire_rd_en),
	    .q(reg_rd_en)
    );
    dffre #(1) ff_go (
	    .clk(clk),
	    .r(~rstn),
	    .en(1),
	    .d(wire_go),
	    .q(reg_go)
    );
    
    dffre #(WRITE_ADDRESS_LENGTH) ff_wr_addr (
	    .clk(clk),
	    .r(~rstn),
	    .en(in_valid),
	    .d(wire_wr_addr),
	    .q(reg_wr_addr)
    );
    dffre #(WRITE_DATA_LENGTH) ff_wr_data (
	    .clk(clk),
	    .r(~rstn),
	    .en(in_valid),
	    .d(wire_wr_data),
	    .q(reg_wr_data)
    );
    dffre #(READ_ADDRESS_LENGTH) ff_rd_start_addr (
	    .clk(clk),
	    .r(~rstn),
	    .en(in_valid),
	    .d(wire_rd_start_addr),
	    .q(reg_rd_start_addr)
    );
    dffre #(READ_ADDRESS_LENGTH) ff_rd_end_addr (
	    .clk(clk),
	    .r(~rstn),
	    .en(in_valid),
	    .d(wire_rd_end_addr),
	    .q(reg_rd_end_addr)
    );
/*
    //connecting instruction_decoder outputs to the registers
    always @(posedge clk or negedge rstn) begin
	    //rstn - usually active low asynch reset signal,  low signal (0)
	    //indicates reset condition,  so if this signal is low then we
	    //reset the register vals (all 0's)
	    if(~rstn) begin
		    reg_wr_addr <= {WRITE_ADDRESS_LENGTH{1'b0}};
		    reg_wr_data <= {WRITE_DATA_LENGTH{1'b0}};
		    reg_rd_start_addr <= {READ_ADDRESS_LENGTH{1'b0}};
		    reg_rd_end_addr <= {READ_ADDRESS_LENGTH{1'b0}};
		    reg_wr_en <= 1'b0;
		    reg_rd_en <= 1'b0;
		    reg_go <= 1'b0;
	    //if in_valid, then connect the registers to the id module
	    //signals (the registers connects to the ram instance/ensures that
	    //correct values only get populated if in_valid is true) 
	    end else if (in_valid) begin
		    reg_wr_addr <= id.wr_addr;
		    reg_wr_data <= id.wr_data;
		    reg_rd_start_addr <= id.rd_start_addr;
		    reg_rd_end_addr <= id.rd_end_addr;
		    reg_wr_en <= id.wr_en;
		    reg_rd_en <= id.rd_en;
		    reg_go <= id.go;

	    end
    end 
*/

    //deduce mode using this logic or pass in as input? : wire mode = go && out_ready;
    //Mux to help select between 'id' and 'sam' modes (0 for id, and 1 for sam)
    //If 'id' : use mux_addr_result, reg_wr_data, reg_wr_en
    //If 'sam' : use sam_addr_in, sam_wr_data, sam_wr_en
    //ram_data_out and clk can be the same signal regardless of if operating in sam or id mode
    wire [WRITE_ADDRESS_LENGTH-1:0] sam_addr_in;
    wire [WRITE_DATA_LENGTH-1:0] sam_wr_data;
    wire sam_wr_en;
    wire [WRITE_ADDRESS_LENGTH-1:0] mode_mux_addr;
    wire [WRITE_DATA_LENGTH-1:0] mode_mux_datain;
    wire mode_mux_wr_en;
    reg [WRITE_ADDRESS_LENGTH-1:0] mux_addr_result;

    always @* begin
	    if(mode) begin
		    mode_mux_addr = sam_addr_in;
		    mode_mux_datain = sam_wr_data;
		    mode_mux_wr_en = sam_wr_en;
	    end else begin
		    //Mux for selecting write address or read start address based on read
		    //enable signal (if 0 then write address and if 1 then rd_start_addr)
		    if(reg_rd_en) begin
			    mux_addr_result = reg_rd_start_addr;
		    end else begin
			    mux_addr_result = reg_wr_addr;
		    end
		    mode_mux_addr = mux_addr_result;
		    mode_mux_datain = reg_wr_data;
		    mode_mux_wr_en = reg_wr_en;
	    end
    end


    //instantiating ram_16x16384 module
    wire [15:0] ram_data_out;
    my_ram ram (
	    .addr(mode_mux_addr),
	    .clk(clk),
	    .din(mode_mux_datain),
	    .dout(ram_data_out),
//	    .ena(reg_rd_en),
	    .wen(mode_mux_wr_en)
    );
    
    assign out_data = {16'b0, ram_data_out};

    //connecting remaining signals for the sam_wrapper module
    
    //need one cycle delay for out_valid (out_valid is just rd_en with
    //a 1 cycle delay)
    dffre #(1) ff8 (
	    .clk(clk),
	    .r(~rstn),
	    .en(1),
	    .d(reg_rd_en),
	    .q(out_valid)
    );
    //setting in_ready temporarily to 1, in_ready=1 indicates that no
    //instruction is currently executing/new instruction can be loaded
    assign in_ready = 1'b1;
    //setting out_last temporarily to 1
    assign out_last = 1'b1;

    //TODO: modify following assign statements in future when FSM is implemented
    //(i.e. read or write multiple pieces of data at the same time)
    /*
    assign in_ready = out_ready && out_valid && !(in_last);
    assign out_valid = out_ready && (reg_rd_en || reg_wr_en);
    assign out_last = reg_rd_en && out_ready && in_last;
    */

endmodule
