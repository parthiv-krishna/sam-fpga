`timescale 1ns / 1ps
// instruction_decoder: reads in 32 bit micro-instructions
// and decodes into various signals for other modules

import instruction_decoder_params::*;

module instruction_decoder
#(
	parameter INPUT_SIGNAL_LENGTH = instruction_decoder_params::INPUT_SIGNAL_LENGTH,
	parameter WRITE_DATA_LENGTH = instruction_decoder_params::WRITE_DATA_LENGTH,
	parameter WRITE_ADDRESS_LENGTH = instruction_decoder_params::WRITE_ADDRESS_LENGTH,
	parameter READ_ADDRESS_LENGTH = instruction_decoder_params::READ_ADDRESS_LENGTH
)
(
	input logic [INPUT_SIGNAL_LENGTH-1:0] input_signal,
	output logic wr_en,
	output logic rd_en,
	output logic go,
	output logic [WRITE_ADDRESS_LENGTH-1:0] wr_addr,
	output logic [WRITE_DATA_LENGTH-1:0] wr_data,
	output logic [READ_ADDRESS_LENGTH-1:0] rd_start_addr,
	output logic [READ_ADDRESS_LENGTH-1:0] rd_end_addr
);
//if the first bit of input_signal is a 1, assign go to be a 1
assign go = (input_signal[INPUT_SIGNAL_LENGTH] == 1'b1) ? 1 : 0;
//check first two bits of the input signal to see if we should read or write
assign wr_en = (input_signal[INPUT_SIGNAL_LENGTH-1:INPUT_SIGNAL_LENGTH-2] == 2'b00) ? 1 : 0;
assign rd_en = (input_signal[INPUT_SIGNAL_LENGTH-1:INPUT_SIGNAL_LENGTH-2] == 2'b01) ? 1 : 0;

//assigning values to the remaining outputs in the module declaration
always @(*) begin
	if (wr_en) begin
		//write data, bits 0-15 of original input (16 bits data)
		//write address, bits 16-29 of original input (14 bits address)
		wr_addr = input_signal[INPUT_SIGNAL_LENGTH-3:INPUT_SIGNAL_LENGTH-WRITE_ADDRESS_LENGTH-2];
		wr_data = input_signal[WRITE_DATA_LENGTH-1:0];
		rd_start_addr = {READ_ADDRESS_LENGTH{1'b0}};
		rd_end_addr = {READ_ADDRESS_LENGTH{1'b0}};
	end
	else if (rd_en) begin
		//read start address, bits 15-28 of original input (14 bits)
		//read end address, bits 0-13 of original input (14 bits)
		rd_start_addr = input_signal[INPUT_SIGNAL_LENGTH-4:READ_ADDRESS_LENGTH+1];
		rd_end_addr = input_signal[READ_ADDRESS_LENGTH-1:0];
		wr_addr = {WRITE_ADDRESS_LENGTH{1'b0}};
		wr_data = {WRITE_DATA_LENGTH{1'b0}};
	end
	else begin
		//initialize all output vars to 0
		wr_addr = {WRITE_ADDRESS_LENGTH{1'b0}};
		wr_data = {WRITE_DATA_LENGTH{1'b0}};
		rd_start_addr = {READ_ADDRESS_LENGTH{1'b0}};
		rd_end_addr = {READ_ADDRESS_LENGTH{1'b0}};
	end
end

endmodule
