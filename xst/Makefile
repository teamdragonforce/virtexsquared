TARGET = FireARM
VLOGS = Console.v  ARM_Constants.v  BigBlockRAM.v  BlockRAM.v  BusArbiter.v  DCache.v  Decode.v  Execute.v  Fetch.v  ICache.v  Issue.v  Memory.v  RegFile.v  system.v  Terminal.v  Writeback.v
VLOGS_ALL = $(VLOGS) ram.hex

all: fpga_target

BITGEN_OPTS = \
	-w \
	-g DebugBitstream:No \
	-g Binary:no \
	-g CRC:Enable \
	-g ProgPin:PullUp \
	-g DonePin:PullUp \
	-g TckPin:PullUp \
	-g TdiPin:PullUp \
	-g TdoPin:PullUp \
	-g TmsPin:PullUp \
	-g UnusedPin:PullDown \
	-g UserID:0xFFFFFFFF \
	-g StartUpClk:CClk \
	-g DONE_cycle:4 \
	-g GTS_cycle:5 \
	-g GWE_cycle:6 \
	-g Security:None \
	-g DonePipe:No \
	-g Match_cycle:2 \
	-g DriveDone:No

fpga_target: $(TARGET).bit

$(TARGET).ngc: $(TARGET).xst $(VLOGS_ALL)
	@mkdir -p xst/projnav.tmp
	@echo work > $(TARGET).lso
	@rm -f $(TARGET).prj
	@for i in $(VLOGS); do echo verilog work '"'$$i'"' >> $(TARGET).prj; done
	xst -ifn $(TARGET).xst -ofn $(TARGET).syr

# for post-synth simulation
$(TARGET)-bare.ngc: $(TARGET)-bare.xst $(VLOGS_ALL)
	@mkdir -p xst/projnav.tmp
	@echo work > $(TARGET).lso
	@rm -f $(TARGET).prj
	@for i in $(VLOGS); do echo verilog work '"'$$i'"' >> $(TARGET).prj; done
	xst -ifn $(TARGET)-bare.xst -ofn $(TARGET)-bare.syr


# for synth mismatch diagnostics
$(TARGET)-memory.ngc: $(TARGET)-memory.xst $(VLOGS_ALL)
	@mkdir -p xst/projnav.tmp
	@echo work > $(TARGET).lso
	@rm -f $(TARGET).prj
	@for i in $(VLOGS); do echo verilog work '"'$$i'"' >> $(TARGET).prj; done
	xst -ifn $(TARGET)-memory.xst -ofn $(TARGET)-memory.syr

sim/%.v: %.ngc
	netgen -ofmt verilog -w -dir sim $<

$(TARGET).ngd: $(TARGET).ngc $(TARGET).ucf
	ngdbuild -dd _ngo -uc $(TARGET).ucf -nt timestamp -p xc5vlx110t-ff1136-1 "$(TARGET).ngc" $(TARGET).ngd

$(TARGET)_map.ncd: $(TARGET).ngd
	map -w -p xc5vlx110t-ff1136-1 -cm area -pr off -k 4 -c 100 -o $(TARGET)_map.ncd $(TARGET).ngd $(TARGET).pcf

$(TARGET).ncd: $(TARGET)_map.ncd
	par -w -ol std -t 1 $(TARGET)_map.ncd $(TARGET).ncd $(TARGET).pcf

$(TARGET).twr: $(TARGET)_map.ncd
	trce -e 3 -s 5 -xml $(TARGET) $(TARGET).ncd -o $(TARGET).twr $(TARGET).pcf -ucf $(TARGET).ucf

$(TARGET).bit: $(TARGET).ncd
	bitgen $(BITGEN_OPTS) $(TARGET).ncd

$(TARGET).svf: $(TARGET).bit impact.cmd
	sed -e s/XXX/$(subst .bit,,$<)/ < impact.cmd > tmp.cmd
	impact -batch tmp.cmd

clean:
	rm -f $(TARGET).bgn $(TARGET).ngc $(TARGET).svf $(TARGET).ngd $(TARGET).bit $(TARGET).twr $(TARGET).ncd $(TARGET)_map.ncd $(TARGET)_map.*
	rm -f $(TARGET).bld $(TARGET).drc $(TARGET)_ngdbuild.xrpt $(TARGET)_pad.* $(TARGET).pad $(TARGET).par $(TARGET)_par.xrpt $(TARGET).ngr
	rm -f $(TARGET).pcf $(TARGET)_summary.xml $(TARGET).unroutes $(TARGET)_usage.xml $(TARGET)_xst.xrpt $(TARGET).syr $(TARGET).ptwx $(TARGET).xpi
	rm -rf xst
	rm -rf xlnx_auto_*
	rm -rf _ngo
	rm -f tmp.cmd
	rm -f _impactbatch.log
	rm -f $(TARGET).prj
	rm -f $(TARGET).lso

