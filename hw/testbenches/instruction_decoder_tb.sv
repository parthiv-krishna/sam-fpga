`timescale 1ns / 1ps

// instruction_decoder_tb: testbench for instruction_decoder

module instruction_decoder_tb;
	logic [INPUT_SIGNAL_LENGTH-1:0] test_input;
	logic wr_en_test;
	logic rd_en_test;
	logic go_test;
	logic [WRITE_ADDRESS_LENGTH-1:0] wr_addr_test;
	logic [WRITE_DATA_LENGTH-1:0] wr_data_test;
	logic [READ_ADDRESS_LENGTH-1:0] rd_start_addr_test;
	logic [READ_ADDRESS_LENGTH-1:0] rd_end_addr_test;

	instruction_decoder decoder (
		.input_signal(test_input),
		.wr_en(wr_en_test),
		.rd_en(rd_en_test),
		.go(go_test),
		.wr_addr(wr_addr_test),
		.wr_data(wr_data_test),
		.rd_start_addr(rd_start_addr_test),
		.rd_end_addr(rd_end_addr_test)
	);

	//clock creation (check if needed?)
	logic clk = 0;
	always #5 clk = ~clk;

	initial begin
		//initializing test_input
		test_input = 32'b0000_0000_0000_0000_0000_0000_0000_0000;

		//passing in first test_input
		#10 test_input = 32'b01_001000010000100_010000100011100;
		
		#10

		//display results
		$display("Test 1: Input = %b, wr_en = %b, rd_en = %b, go = %b, wr_addr = %b, wr_data = %b, rd_start_addr = %b, rd_end_addr = %b", test_input, wr_en_test, rd_en_test, go_test, wr_addr_test, wr_data_test, rd_start_addr_test, rd_end_addr_test);
		$finish;
	end

endmodule
