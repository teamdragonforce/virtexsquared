RUN ?= $(shell date +R%Y%m%d-%H%M)
RUNDIR ?= runs/$(RUN)

default:
	@echo "targets:"
	@echo "  fpga         runs a complete pass through the tool flow"
	@echo "  sim          produces a Verilator binary"
	@echo "  tests        rebuilds tests"
	@echo "  auto         re-autoizes all RTL"
	@echo ""
	@echo "variables:"
	@echo "  RUN=[...]    name of run (for runs/ directory; defaults to date+time)"
	@echo
	@echo "error: you must specify a valid target"
	@exit 1

sim: .DUMMY $(RUNDIR)/stamps/sim

fpga: .DUMMY $(RUNDIR)/stamps/fpga

$(RUNDIR)/stamps/sim-genrtl:
	@echo "Copying RTL for simulation to $(RUNDIR)/sim/rtl..."
	@mkdir -p $(RUNDIR)/stamps
	@mkdir -p $(RUNDIR)/sim/rtl
	@cp `find rtl -iname '*.v' | grep -v fpga/` $(RUNDIR)/sim/rtl
	@echo "Copying testbench for simulation to $(RUNDIR)/sim..."
	@cp sim/* $(RUNDIR)/sim
	@touch $(RUNDIR)/stamps/sim-genrtl

$(RUNDIR)/stamps/sim-verilate: $(RUNDIR)/stamps/sim-genrtl
	@echo "Building simulator source with Verilator into $(RUNDIR)/sim/obj_dir..."
	@mkdir -p $(RUNDIR)/sim/obj_dir
	cd $(RUNDIR)/sim; verilator -Irtl --cc rtl/system.v testbench.cpp --exe
	@touch $(RUNDIR)/stamps/sim-verilate

$(RUNDIR)/stamps/sim-build: $(RUNDIR)/stamps/sim-verilate
	@echo "Building simulator from Verilated source into $(RUNDIR)/sim/obj_dir..."
	make -C $(RUNDIR)/sim/obj_dir -f Vsystem.mk
	ln -sf obj_dir/Vsystem $(RUNDIR)/sim/
	@touch $(RUNDIR)/stamps/sim-build

$(RUNDIR)/stamps/sim: $(RUNDIR)/stamps/sim-build
	@echo "Simulator built in $(RUNDIR)/sim."
	@touch $(RUNDIR)/stamps/sim

auto: .DUMMY
	@echo "XXX: this does not autoize enough!"
	emacs -l ~/elisp/verilog-mode.el --batch system.v -f verilog-batch-auto

tests: .DUMMY
	make -C tests

.DUMMY:
