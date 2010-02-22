VLOGS = ARM_Constants.v BigBlockRAM.v BlockRAM.v BusArbiter.v DCache.v Decode.v Execute.v Fetch.v ICache.v Issue.v Memory.v Minishift.v RegFile.v Terminal.v Writeback.v system.v

all: Vsystem

Vsystem: obj_dir/Vsystem.mk testbench.cpp
	make -C obj_dir -f Vsystem.mk

obj_dir/Vsystem.mk: $(VLOGS)
	mkdir -p obj_dir
	verilator --cc system.v testbench.cpp --exe

auto: .DUMMY
	emacs -l ~/elisp/verilog-mode.el --batch system.v -f verilog-batch-auto

.DUMMY: