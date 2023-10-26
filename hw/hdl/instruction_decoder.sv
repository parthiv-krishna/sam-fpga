`timescale 1ns / 1ps
// instruction_decoder: reads in 32 bit micro-instructions
// and decodes into various signals for other modules

module instruction_decoder(
	input logic [31:0] input_signal,
	output logic wr_en,
	output logic rd_en,
	output logic go,
	output logic [14:0] wr_addr,
	output logic [14:0] wr_data,
	output logic [14:0] rd_start_addr,
	output logic [14:0] rd_end_addr
);
//if the first bit of input_signal is a 1, assign go to be a 1
assign go = (input_signal[31] == 1'b1) ? 1 : 0;
//check first two bits of the input signal to see if we should read or write
assign wr_en = (input_signal[31:30] == 2'b00) ? 1 : 0;
assign rd_en = (input_signal[31:30] == 2'b01) ? 1 : 0;

//assigning values to the remaining outputs in the module declaration
initial begin
	if (wr_en) begin
		wr_addr = input_signal[29:15];
		wr_data = input_signal[14:0];
		rd_start_addr = 15'b0;
		rd_end_addr = 15'b0;
	end
	else if (rd_en) begin
		rd_start_addr = input_signal[29:15];
		rd_end_addr = input_signal[14:0];
		wr_addr = 15'b0;
		wr_data = 15'b0;
	end
	else begin
		//initialize all output vars to 0
		wr_addr = 15'b0;
		wr_data = 15'b0;
		rd_start_addr = 15'b0;
		rd_end_addr = 15'b0;
	end
end

endmodule
