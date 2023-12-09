#include "sam_fpga.h"

SamFpga::SamFpga(u16 axi_fifo_device_id) {
	//using the AxiFifo constructor in axi_fifo.cpp/axi_fifo.h to initialize the _fifo object (private member variable of SamFpga class)
	_fifo = AxiFifo(axi_fifo_device_id);
}

void SamFpga::store(u16 addr, u16 data) {
	//store the addr and data passed in to the FPGA via the _fifo object (concatenating addr and data w/ extra 0s to get 32 bit message to pass to the 'send' funtion)
	//Note: format for store instruction is 00_addr_value (addr is 14 bits, value is 16 bits)
	//potentially change this so addr and data get stored in 1 u32 value as opposed to 2 u16 values concatenated with 16 0's in the beginning?
	std::vector<u32> transmit_data = {addr,data};
	_fifo.send(transmit_data);
}

u16 SamFpga::load(u16 addr, u16 length) {
	//load data from the FPGA
	//Main idea: send the addr,length to the FPGA, wait for response, receive data back from FPGA and return it
	//Note: format for load instruction is 01_startAddress_endAddress with start/end address being 14 bits long
	//Therefore, when transmitting data do addr and addr+length for start/stop addresses, and when data is received, the last 16 should be the data
	std::vector<u32> transmit_data = {addr,addr+length};
	_fifo.send(transmit_data);

	std::vector<u32> receive_data = _fifo.receive();
	if(receive_data.size() > 0) {
	       //extract just last 16 bits for the data which should be returned
		u16 data_to_return = static_cast<u16>(receive_data[0] & 0xFFFF);
		return data_to_return;
	}
	else {
		//else, return default value 0/data wasn't received
		return 0;
	}
}

void SamFpga::sendInstruction(const Instruction& i) {
	//take instruction which gets passed in, convert it to 32 bits using the toWord function in instruction.h, and send via _fifo
	//push_back adds i.toWord to the end of the 'command' vector
	std::vector<u32> command;
	command.push_back(i.toWord());
	_fifo.send(command);
}

void SamFpga::go() {
       //try to create an object of type GoInstruction from instruction.h, then using sendInstruction method defined above (in SamFpga) to send the 'go' command
       GoInstruction instruction;
	sendInstruction(instruction);       
}
