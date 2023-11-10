#ifndef AXI_FIFO_H
#define AXI_FIFO_H

#include <vector>
#include <string>

#include "xllfifo.h"

class AxiFifo {
public:
	AxiFifo(u16 device_id);

	void send(const std::vector<u32>& txData);
	std::vector<u32> receive();

	static const size_t kBytesPerWord = 4;
	static const size_t kWordsPerPacket = 4;
	static const size_t kMaxPackets = 64;
	static const size_t kMaxWordsInBuffer = kWordsPerPacket*kMaxPackets;

private:
	void error(const std::string& s);

	XLlFifo _fifo;
	XLlFifo_Config* _config;

};

#endif // AXI_FIFO_H
