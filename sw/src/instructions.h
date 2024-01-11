#ifndef INSTRUCTIONS_H
#define INSTRUCTIONS_H

#include "assert.h"

class Instruction {
public:
  static const size_t kBitsPerWord = 32;
  static const size_t kOpcodeBits = 2;
  static const size_t kArgBits = kBitsPerWord - kOpcodeBits;

  static const size_t kAddrBits = 14;
  static const size_t kValueBits = 16;

  u32 toWord() const {
    u32 o = opcode();
    assert(o < (1 << kOpcodeBits)); // opcode is at most kOpcodeBits bits
    u32 a = args(); 
    assert(a < (1 << kArgBits)); // opcode is at most kArgBits bits
    return (opcode() << kArgBits | args());
  };

  // only the lower 2 bits should be set
  virtual u32 opcode() const {
    return 0;
  }

  // only the lower 30 bits should be set
  virtual u32 args() const {
    return 0;
  }
};

class StoreInstruction : public Instruction {
public:
  StoreInstruction(u16 addr, u16 value) {
    // addr should be 14 bits
    // value should be 16 bits
    // should we assert these facts?
    _addr = addr;
    _value = value;
  }

  u32 opcode() const override {
    return kOpcode;
  }

  u32 args() const override {
    return (_addr << 16) | _value;
  }

private:
  static const u16 kOpcode = 0b00;

  u16 _addr;
  u16 _value;
};

class LoadInstruction : public Instruction {
public:
  LoadInstruction(u16 startaddr, u16 endaddr) {
    //start and end addresses should be 14 bits each
    _startaddr = startaddr;
    _endaddr = endaddr;
  }

  u32 opcode() const override {
    return kOpcode;
  }
  //potentially rename method below?
  u32 args() const override {
    return (_startaddr << 16) | _endaddr;
  }
private:
  static const u16 kOpcode = 0b01;

  u16 _startaddr;
  u16 _endaddr;
};

class GoInstruction : public Instruction {
public:
  GoInstruction() {}

  u32 opcode() const override {
    return kOpcode;
  }

  u32 args() const override {
    return 0;
  }

private:
  static const u16 kOpcode = 0b10;
};

#endif // INSTRUCTIONS_H
