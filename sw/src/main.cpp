#include "axi_fifo.h"

#include <iostream>

#define FIFO_DEV_ID	XPAR_AXI_FIFO_0_DEVICE_ID

// number of words to send
#define N 25

using std::cout;
using std::endl;

int main() {

	cout << "Initializing FIFO device ID " << FIFO_DEV_ID << endl;
	AxiFifo fifo(FIFO_DEV_ID);

	std::vector<u32> txData;

	for (size_t i = 0; i < N; i++) {
		txData.push_back(i);
	}

	cout << "TX" << endl;
	fifo.Send(txData);

	cout << "RX" << endl;
	std::vector<u32> rxData = fifo.Receive();

	for (int i = 0; i < N; i++) {
		cout << "tx " << txData[i] << " rx " << rxData[i];
		if (txData[i] + 1 != rxData[i]) {
			cout << " mismatch!!!";
		}
		cout << endl;
	}

	cout << "Done!" << endl;
}
