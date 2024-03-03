import argparse
import enum
import logging
import pathlib
import random
import serial
import json
from typing import List, Optional, Tuple

logging.basicConfig(level=logging.INFO)

class DummySerial:
    def __init__(self):
        self.port = "DUMMY"
        self.baudrate = 0

    def write(self, bytestring: bytes):
        logging.info(f"DummySerial.write(): Would have sent 0x{bytestring.hex()}")

    def read(self, n: int) -> bytes:
        bytestring = bytes(random.getrandbits(8) for _ in range(n))
        logging.info(f"DummySerial.read(): returning random data 0x{bytestring.hex()}")
        return bytestring

    def close(self):
        logging.info(f"DummySerial.close()")

class SamFpgaDriver:
    class OpCode(enum.Enum):
        STORE = 0b00
        LOAD = 0b01
        GO = 0b10

    OPCODE_BITS = 2
    DATA_BITS = 30

    def __init__(self, serial_port: pathlib.Path, serial_baud: int):
        if serial_port is None:
            self.serial_port = DummySerial()
        else:
            self.serial_port = serial.Serial(serial_port, serial_baud)
        logging.info(f"Opened serial port at {self.serial_port.port} with baud rate {self.serial_port.baudrate}")
    
    def __del__(self):
        self.serial_port.close()
        logging.info(f"Closed serial port")

    def send_uint32(self, i: int):
        # assert 0 < i < 2^32?
        bytestring = i.to_bytes(4, "big")
        logging.debug(f"Sending 0x{bytestring.hex()}")
        self.serial_port.write(bytestring)

    def read_uint32(self) -> int:
        bytestring = self.serial_port.read(4)
        logging.debug(f"Received 0x{bytestring.hex()}")
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

def read_file(file_path, basedir):
    with open(f"{basedir}/{file_path}", 'r') as f:
        return f.readlines()

def main(config: pathlib.Path, serial_port: pathlib.Path, serial_baud: int):
    sam = SamFpgaDriver(serial_port, serial_baud)

    with open(config, 'r') as json_file:
        data = json.load(json_file)

    config_basedir = config.parent

    # Iterate over each key-value pair in the JSON data
    for key, value in data.items():
        #keys are B, C in this case,  value refers to all the info entered under each matrix/tensor name
        banks_crd_seg = value['banks_crd_seg'] 
        input_seg = value['input_seg']
        input_crd = value['input_crd']
        value_file = value['value']
        shape_file = value['shape']

        logging.info(f"Writing tensor {key}")
        logging.info(f"Writing crd, seg for {key}")
        for i in banks_crd_seg:
            seg_data = read_file(input_seg[i%5], config_basedir) #right now mod 5 bcz reading in two tensors, all with modes 0,1,2 - might need to change this later
            crd_data = read_file(input_crd[i%5], config_basedir)

            bank = i #takes i val (bank number) and converts to 4 bit binary representation
            addr_needed = len(seg_data)+len(crd_data)
            combined_list = seg_data + crd_data
            combined_list = [item.strip() for item in combined_list] #remove '/n' chars
            for addr in range(addr_needed):
                spec_addr_to_store = addr
                full_addr_store = (bank << 10) | spec_addr_to_store
                sam.store(full_addr_store, int(combined_list[addr]))
            
        #storing value and shape
        logging.info(f"Writing value for {key}")
        value_data = read_file(value_file, config_basedir)
        value_data_final = [item.strip() for item in value_data] 
        value_bank = data[key]["bank_value"]
        val_spec_addr = 0
        for value in value_data_final:
            full_addr_val_store = (value_bank << 10) | val_spec_addr
            sam.store(full_addr_val_store, int(value_data_final[val_spec_addr]))
            val_spec_addr = val_spec_addr+1

        logging.info(f"Writing shape for {key}")
        shape_data = read_file(shape_file, config_basedir)
        shape_data_final = [item.strip() for item in shape_data] 
        shape_bank = data[key]["bank_shape"]
        shape_spec_addr = 0
        for shape_dim in shape_data_final:
            full_addr_shape_store = (shape_bank << 10) | shape_spec_addr
            sam.store(full_addr_shape_store, int(shape_data_final[shape_spec_addr]))
            shape_spec_addr = shape_spec_addr+1

    sam.go() #wait until complete - potentially can be added to sam.go functionality

    #can read out output tensors using sam.load when an app completes running

    # example
    sam.store(0, 42)
    rx = sam.load(0, 1)
    logging.info(f"loaded {rx}")
    sam.go()

if __name__ == "__main__":
     parser = argparse.ArgumentParser()
     parser.add_argument("config", help="config json file describing tensors")
     parser.add_argument("-s", "--serial_port", help="serial port to connect to", default=None)
     parser.add_argument("-b", "--serial_baud", help="baud rate for serial port", default=115200)

     args = parser.parse_args()

     config = pathlib.Path(args.config)

     main(config, args.serial_port, args.serial_baud)
