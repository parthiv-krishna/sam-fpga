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
	u32 data() const override {
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
	//just defined placeholder u32 in constructor; maybe modify since only thing which is important should be the opcode for the go instruction?
	GoInstruction(u32 placeholder) {
		_placeholder = placeholder;
	}

	u32 opCode() const override {
		return kOpCode;
	}

private:
	static const u16 kOpCode = 10;

	u32 _placeholder;
};

#endif // INSTRUCTIONS_H
