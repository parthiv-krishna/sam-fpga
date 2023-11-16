#ifndef INSTRUCTIONS_H
#define INSTRUCTIONS_H

class Instruction {
public:
	u32 toWord() {
		return (opCode() << (kBitsPerWord - 2) | data());
	};

	// only the lower 2 bits should be set
	virtual u32 opCode() const = 0;

	// only the lower 30 bits should be set
	virtual u32 data() const = 0;

	static const size_t kBitsPerWord;
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

	u32 data() const override {
		return (_addr << 16) |  _value;
	}

private:
	static const u16 kOpCode = 00;

	u16 _addr;
	u16 _value;
};

class LoadInstruction : Instruction {
	// TODO
};

class GoInstruction : Instruction {
	// TODO
};

#endif // INSTRUCTIONS_H
