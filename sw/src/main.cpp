#include "sam_fpga.h"

#include <iostream>

#define FIFO_DEV_ID  XPAR_AXI_FIFO_0_DEVICE_ID

using std::cout;
using std::endl;

int main() {

  cout << "Initializing FIFO device ID " << FIFO_DEV_ID << endl;
  SamFpga sam(FIFO_DEV_ID);

  cout << "sending go" << endl;
  sam.go();
  cout << "sending load" << endl;
  std::vector<u16> result = sam.load(0, 2);

  cout << "receiving" << endl;
  for (u16 r : result) {
    cout << r << endl;
  }

  cout << "Done!" << endl;
}
