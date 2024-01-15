#include "axi_fifo.h"

#include <iostream>
#include <sstream>
#include <stdexcept>

#include "xstatus.h"

using std::cout;
using std::endl;
using std::string;
using std::stringstream;

AxiFifo::AxiFifo(u16 device_id) {
  // initialize _config
  // Ffio: there is a typo in the library :(
  _config = XLlFfio_LookupConfig(device_id);
  if (!_config) {
    stringstream errmsg;
    errmsg << "Failed to lookup FIFO device with ID " << device_id;
    error(errmsg.str());
  }

  // setup _fifo pointer with FIFO object
  if (XLlFifo_CfgInitialize(&_fifo, _config, _config->BaseAddress) != XST_SUCCESS) {
    error("Failed to initialize FIFO device");
  }

  // reset interrupt register
  XLlFifo_IntClear(&_fifo, 0xFF'FF'FF'FF); // clear all pending interrupts
  int status = XLlFifo_Status(&_fifo);
  if (status != 0) {
    stringstream errmsg;
    errmsg << "Failed to clear interrupts on FIFO device, ISR: " << status;
    error(errmsg.str());
  }
}

void AxiFifo::send(const std::vector<u32>& txData) {
  size_t num_words = txData.size();
  if (num_words > kMaxWordsInBuffer) {
    stringstream errmsg;
    errmsg << "Too many words in buffer: got " << num_words
         << " max: " << kMaxWordsInBuffer;
    error(errmsg.str());
  }

  for (u32 word : txData) {
    while (XLlFifo_iTxVacancy(&_fifo) == 0) {
      // wait until space available in tx buffer
    }
    XLlFifo_TxPutWord(&_fifo, word); // put word in tx buffer
  }

  // start tx by writing transmission length into
  XLlFifo_iTxSetLen(&_fifo, num_words * kBytesPerWord);

  while (!XLlFifo_IsTxDone(&_fifo)) {
    // wait until tx done
  }
}

std::vector<u32> AxiFifo::receive() {
  std::vector<u32> rxData;

  // while words available
  while (XLlFifo_iRxOccupancy(&_fifo) > 0) {
    // read the available words into our rxData
    u32 rx_num_words = XLlFifo_iRxGetLen(&_fifo) / kBytesPerWord;
    for (u32 i = 0; i < rx_num_words; i++) {
      rxData.push_back(XLlFifo_RxGetWord(&_fifo));
    }
  }

  if (!XLlFifo_IsRxDone(&_fifo)) {
    error("Failed to complete receive");
  }
  return rxData;
}

void AxiFifo::error(const string& s) {
  cout << "AxiFifo: " << s << endl;
  throw std::runtime_error(s);
}
