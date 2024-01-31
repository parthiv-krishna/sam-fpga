import argparse
import enum
import logging
import pathlib
import serial
from typing import Tuple, List

class SamFpgaDriver:
    class OpCode(enum.Enum):
        STORE = 0b00
        LOAD = 0b01
        GO = 0b10

    OPCODE_BITS = 2
    DATA_BITS = 30

    def __init__(self, serial_port: pathlib.Path, serial_baud: int):
        self.serial_port = serial.Serial(serial_port, serial_baud)
        logging.info(f"Opened serial port at {self.serial_port.port} with baud rate {self.serial_port.baudrate}")
    
    def __del__(self):
        self.serial_port.close()
        logging.info(f"Closed serial port")

    def send_uint32(self, i: int):
        # assert 0 < i < 2^32?
        bytestring = i.to_bytes(4, "big")
        logging.debug(f"Sending {bytestring}")
        self.serial_port.write(bytestring)

    def read_uint32(self) -> int:
        bytestring = self.serial_port.read(4)
        logging.debug(f"Received {bytestring}")
        return int.from_bytes(bytestring, "big")
            
    def store(self, addr: int, value: int):
        # assert 0 < addr < 2^14?
        # assert 0 < value < 2^16?
        inst = 0
        inst = inst | self.OpCode.STORE.value << self.DATA_BITS
        inst = inst | (addr << 16)
        inst = inst | value
        logging.debug(f"Store {addr=} {value=}")
        self.send_uint32(inst)

    def load(self, start_addr: int, end_addr: int) -> List[Tuple[int, int]]:

        # assert 0 < start_addr < 2^14?
        # assert 0 < end_addr < 2^14?
        inst = 0
        inst = inst | self.OpCode.LOAD.value << self.DATA_BITS
        inst = inst | (start_addr << 16)
        inst = inst | end_addr
        logging.debug(f"Load {start_addr=} {end_addr=}")
        self.send_uint32(inst)

        data = []
        for addr in range(start_addr, end_addr):
            rx = self.read_uint32()
            rx_addr = rx >> 16
            rx_value = rx & 0xFFFF
            data.append((rx_addr, rx_value))

        return data

    def go(self):
        inst = 0
        inst = inst | self.OpCode.GO.value << self.DATA_BITS
        logging.debug(f"Go")
        self.send_uint32(inst)

def main(serial_port: pathlib.Path, serial_baud: int):
    sam = SamFpgaDriver(serial_port, serial_baud)

    # example
    sam.store(0, 42)
    rx = sam.load(0, 1)
    print(f"loaded {rx}")
    sam.go()

if __name__ == "__main__":
     parser = argparse.ArgumentParser()
     parser.add_argument("-s", "--serial_port", help="serial port to connect to", default="/dev/ttyUSB0")
     parser.add_argument("-b", "--serial_baud", help="baud rate for serial port", default=115200)

     args = parser.parse_args()

     main(args.serial_port, args.serial_baud)
