#ifndef SAM_FPGA_H
#define SAM_FPGA_H

#include "axi_fifo.h"
#include "instructions.h"

#include <vector>

class SamFpga {
public:
  SamFpga(u16 axi_fifo_device_id);

  void store(u16 addr, const std::vector<u16>& data);
  std::vector<u16> load(u16 addr, u16 length);
  void go();

private:
  template <typename I>
  void sendInstructions(const std::vector<I>& instrs);
  
  template <typename I>
  void sendInstruction(const I& instr);

  AxiFifo _fifo;
};

#endif // SAM_FPGA_H
