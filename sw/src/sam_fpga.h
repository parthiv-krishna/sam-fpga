#ifndef SAM_FPGA_H
#define SAM_FPGA_H

#include "axi_fifo.h"
#include "instructions.h"

class SamFpga {
public:
	SamFpga(u16 axi_fifo_device_id);

	void store(u16 addr, u16 data);
	u16 load(u16 addr, u16 length);
	void go();

private:
	void sendInstruction(const Instruction& i);

	AxiFifo _fifo;
};

#endif // SAM_FPGA_H
