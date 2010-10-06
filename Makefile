RUNTIME := $(shell date +R%Y%m%d-%H%M)
RUN ?= $(RUNTIME)
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

###############################################################################

sim: .DUMMY $(RUNDIR)/stamps/sim

$(RUNDIR)/stamps/sim-genrtl:
	@echo "Copying RTL for simulation to $(RUNDIR)/sim/rtl..."
	@mkdir -p $(RUNDIR)/stamps
	@mkdir -p $(RUNDIR)/sim/rtl
	@cp `find rtl -iname '*.v' | grep -v fpga/` $(RUNDIR)/sim/rtl
	@cp `find rtl -iname '*.vh' | grep -v fpga/` $(RUNDIR)/sim/rtl
	@echo "Copying testbench for simulation to $(RUNDIR)/sim..."
	@cp sim/* $(RUNDIR)/sim
	@touch $(RUNDIR)/stamps/sim-genrtl

$(RUNDIR)/stamps/sim-verilate: $(RUNDIR)/stamps/sim-genrtl
	@echo "Building simulator source with Verilator into $(RUNDIR)/sim/obj_dir..."
	@mkdir -p $(RUNDIR)/sim/obj_dir
	cd $(RUNDIR)/sim; verilator -Irtl --cc rtl/system.v testbench.cpp --exe --assert
	@touch $(RUNDIR)/stamps/sim-verilate

$(RUNDIR)/stamps/sim-build: $(RUNDIR)/stamps/sim-verilate
	@echo "Building simulator from Verilated source into $(RUNDIR)/sim/obj_dir..."
	make -C $(RUNDIR)/sim/obj_dir -f Vsystem.mk
	ln -sf obj_dir/Vsystem $(RUNDIR)/sim/
	@touch $(RUNDIR)/stamps/sim-build

$(RUNDIR)/stamps/sim: $(RUNDIR)/stamps/sim-build
	@echo "Simulator built in $(RUNDIR)/sim."
	@touch $(RUNDIR)/stamps/sim

###############################################################################

FPGA_TARGET = FireARM

# not actually used?
PART = xc5vlx110t-ff1136

fpga: .DUMMY $(RUNDIR)/stamps/fpga

# XXX: should we generate the .xst file?
$(RUNDIR)/stamps/fpga-genrtl:
	@echo "FPGA RTL is currently UNSYNTHESIZABLE...?"
	@echo "Copying RTL for synthesis to $(RUNDIR)/fpga/xst..."
	@mkdir -p $(RUNDIR)/stamps
	@mkdir -p $(RUNDIR)/fpga/xst
	@cp `find rtl -iname '*.v' | grep -v sim/` $(RUNDIR)/fpga/xst
	@cp `find rtl -iname '*.vh' | grep -v sim/` $(RUNDIR)/fpga/xst
	@echo "Copying XST configuration to $(RUNDIR)/fpga/xst..."
	@mkdir -p $(RUNDIR)/fpga/xst/xst/projnav.tmp
	@echo work > $(RUNDIR)/fpga/xst/$(FPGA_TARGET).lso
	@rm -rf $(RUNDIR)/fpga/xst/$(FPGA_TARGET).prj
	@cd $(RUNDIR)/fpga/xst; for i in *.v; do echo verilog work '"'$$i'"' >> $(FPGA_TARGET).prj; done
	@cp fpga/xst/* $(RUNDIR)/fpga/xst
	@touch $(RUNDIR)/stamps/fpga-genrtl

$(RUNDIR)/stamps/fpga-synth: $(RUNDIR)/stamps/fpga-genrtl
	@echo "Synthesizing in $(RUNDIR)/fpga/xst..."
	@touch $(RUNDIR)/stamps/fpga-synth-start
	cd $(RUNDIR)/fpga/xst; xst -ifn $(FPGA_TARGET).xst -ofn $(FPGA_TARGET).syr
	@touch $(RUNDIR)/stamps/fpga-synth

$(RUNDIR)/stamps/fpga-xflow-prep: $(RUNDIR)/stamps/fpga-synth
	@echo "Copying files for back-end flow to $(RUNDIR)/fpga/xflow..."
	@mkdir -p $(RUNDIR)/fpga/xflow
	@cp fpga/xflow/* $(RUNDIR)/fpga/xflow
	@cp $(RUNDIR)/fpga/xst/$(FPGA_TARGET).ngc $(RUNDIR)/fpga/xflow
	@touch $(RUNDIR)/stamps/fpga-xflow-prep

$(RUNDIR)/stamps/fpga-xflow: $(RUNDIR)/stamps/fpga-xflow-prep
	@echo "Running back-end flow in $(RUNDIR)/fpga/xflow..."
	@touch $(RUNDIR)/stamps/fpga-xflow-start
	cd $(RUNDIR)/fpga/xflow; xflow -p xc3s1200e-fg320-5 -implement balanced.opt -config bitgen.opt $(FPGA_TARGET).ngc
	@touch $(RUNDIR)/stamps/fpga-xflow
	@ln -s xflow/$(FPGA_TARGET).bit $(RUNDIR)/fpga/

$(RUNDIR)/stamps/fpga: $(RUNDIR)/stamps/fpga-xflow
	@echo "Bit file generated in $(RUNDIR)/fpga/xflow."
	@touch $(RUNDIR)/stamps/fpga

###############################################################################


# This is gross
auto: .DUMMY
	emacs -l ~/elisp/verilog-mode.el --batch `find rtl -iname '*.v' | xargs echo` -f verilog-batch-auto

tests: .DUMMY
	make -C tests

.DUMMY:
