#include "sam_fpga.h"

SamFpga::SamFpga(u16 axi_fifo_device_id) : _fifo(axi_fifo_device_id) {
  //using the AxiFifo constructor in axi_fifo.cpp/axi_fifo.h to initialize the _fifo object (private member variable of SamFpga class)
}

void SamFpga::store(u16 addr, const std::vector<u16>& data) {
  //store the addr and data passed in to the FPGA via the _fifo object (concatenating addr and data w/ extra 0s to get 32 bit message to pass to the 'send' funtion)
  //Note: format for store instruction is 00_addr_value (addr is 14 bits, value is 16 bits)
  //potentially change this so addr and data get stored in 1 u32 value as opposed to 2 u16 values concatenated with 16 0's in the beginning?
  std::vector<StoreInstruction> store_instrs;
  for (size_t i = 0; i < data.size(); i++) {
    store_instrs.emplace_back(addr + i, data[i]);
  }

  sendInstructions(store_instrs);
}

std::vector<u16> SamFpga::load(u16 addr, u16 length) {
  //load data from the FPGA
  //Main idea: send the addr,length to the FPGA, wait for response, receive data back from FPGA and return it
  //Note: format for load instruction is 01_startAddress_endAddress with start/end address being 14 bits long
  //Therefore, when transmitting data do addr and addr+length for start/stop addresses, and when data is received, the last 16 should be the data
  LoadInstruction load_instr(addr, addr + length);
  sendInstruction(load_instr);

  std::vector<u32> receive_data = _fifo.receive();
  // keep receiving until we get all the requested data
  while (receive_data.size() < length) {
    std::vector<u32> additional = _fifo.receive();
    receive_data.insert(receive_data.end(), additional.begin(), additional.end());
  }

  //extract just last 16 bits for the data which should be returned
  std::vector<u16> result;
  for (u32 recv : receive_data) {
    result.push_back(static_cast<u16>(recv & 0xFFFF));
  }
  return result;
}

void SamFpga::go() {
       //try to create an object of type GoInstruction from instruction.h, then using sendInstruction method defined above (in SamFpga) to send the 'go' command
  GoInstruction go_instr;
  sendInstruction(go_instr);
}

template <typename I>
void SamFpga::sendInstruction(const I& instr) {
  //take instruction which gets passed in, converts it to 32 bits using the toWord function in instruction.h, and send via _fifo
  //push_back adds i.toWord to the end of the 'command' vector
  std::vector<I> instr_v;
  instr_v.push_back(instr);
  sendInstructions(instr_v);
}

template <typename I>
void SamFpga::sendInstructions(const std::vector<I>& instrs) {
  //take instructions which gets passed in, convert them to 32 bits using the toWord function in instruction.h, and send via _fifo
  //push_back adds i.toWord to the end of the 'command' vector
  std::vector<u32> commands;
  for (const I& i : instrs) {
    commands.emplace_back(i.toWord());
  }
  _fifo.send(commands);
}

