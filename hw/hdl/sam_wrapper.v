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
    output out_last
);
    parameter INPUT_SIGNAL_LENGTH = 32;
    parameter WRITE_DATA_LENGTH = 16;
    parameter WRITE_ADDRESS_LENGTH = 14;
    parameter READ_ADDRESS_LENGTH = 14;
    //assign out_data = in_data + 1;
    //assign in_ready = out_ready;
    //assign out_valid = in_valid;
    //assign out_last = in_last;

    instruction_decoder id(
	    .input_signal(in_data),
	    .wr_en(reg_wr_en),
	    .rd_en(reg_rd_en),
	    .go(reg_go),
	    .wr_addr(reg_wr_addr),
	    .wr_data(reg_wr_data),
	    .rd_start_addr(reg_rd_start_addr),
	    .rd_end_addr(reg_rd_end_addr)
    );

    //using registers below as 'intermediate interface' between id and ram signals
    reg [WRITE_ADDRESS_LENGTH-1:0] reg_wr_addr;
    reg [WRITE_DATA_LENGTH-1:0] reg_wr_data;
    reg [READ_ADDRESS_LENGTH-1:0] reg_rd_start_addr;
    reg [READ_ADDRESS_LENGTH-1:0] reg_rd_end_addr;
    reg reg_wr_en, reg_rd_en, reg_go;
    
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

    //Mux for selecting write address or read start address based on read
    //enable signal (if 0 then write address and if 1 then rd_start_addr)
    reg[WRITE_ADDRESS_LENGTH-1:0] mux_addr_result;
    always @* begin
	    if(reg_rd_en) begin
		    mux_addr_result = reg_rd_start_addr;
	    end else begin
		    mux_addr_result = reg_wr_addr;
	    end
    end

    //instantiating ram_16x1024 module
    ram_16x1024 ram_inst (
	    .addr(mux_addr_result),
	    .din(reg_wr_data),
	    .dout(out_data),
	    .en(reg_rd_en),
	    .wen(reg_wr_en)
    );

    //connecting remaining signals for the sam_wrapper module
    //**double check these assign statements/add any additional ones
    assign in_ready = out_ready && out_valid && !(in_last);
    assign out_valid = out_ready && (reg_rd_en || reg_wr_en);
    assign out_last = reg_rd_en && out_ready && in_last;


endmodule
