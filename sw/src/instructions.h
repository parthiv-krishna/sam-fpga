#ifndef INSTRUCTIONS_H
#define INSTRUCTIONS_H

class Instruction {
public:
	static const size_t kBitsPerWord = 32;
  static const size_t kOpcodeBits = 2;
  static const size_t kArgBits = kBitsPerWord - kOpcodeBits;

	u32 toWord() {
		return (opCode() << kArgBits | args());
	};

	// only the lower 2 bits should be set
	virtual u32 opCode() const = 0;

	// only the lower 30 bits should be set
	virtual u32 args() const = 0;
};

class StoreInstruction : Instruction {
public:
	StoreInstruction(u16 addr, u16 value) {
		// addr should be 14 bits
		// value should be 16 bits
		// should we assert these facts?
		_addr = addr;
		_value = value;
	}

	u32 opCode() const override {
		return kOpCode;
	}

	u32 args() const override {
		return (_addr << 16) | _value;
	}

private:
	static const u16 kOpCode = 00;

	u16 _addr;
	u16 _value;
};

class LoadInstruction : Instruction {
	// TODO
public:
	LoadInstruction(u16 startaddr, u16 endaddr) {
		//start and end addresses should be 14 bits each
		_startaddr = startaddr;
		_endaddr = endaddr;
	}

	u32 opCode() const override {
		return kOpCode;
	}
	//potentially rename method below?
	u32 args() const override {
		return (_startaddr << 16) | _endaddr;
	}
private:
	static const u16 kOpCode = 01;

	u16 _startaddr;
	u16 _endaddr;
};

class GoInstruction : Instruction {
	// TODO
public:
	GoInstruction() {
	}

	u32 opCode() const override {
		return kOpCode;
	}

  u32 args() const override {
    return 0;
  }

private:
	static const u16 kOpCode = 10;
};

#endif // INSTRUCTIONS_H
