# Project settings
PROJECT = led
SOURCES = led.sv
CONSTRAINTS = led_prj.cst
DEVICE = GW1NZ-LV1QN48C6/I5
FAMILY = GW1NZ

# Toolchain commands
YOSYS = yosys
NEXTPNR = nextpnr-himbaechel
PACK = gowin_pack
LOADER = openFPGALoader

all: $(PROJECT).fs

# 1. Synthesis (Verilog -> JSON netlist)
$(PROJECT).json: $(SOURCES)
	$(YOSYS) -p "read_verilog -sv $(SOURCES); synth_gowin -json $@"

# 2. Place & Route (JSON -> PNR-JSON)
$(PROJECT)_pnr.json: $(PROJECT).json $(CONSTRAINTS)
	$(NEXTPNR) --json $< --write $@ --device $(DEVICE) --vopt cst=$(CONSTRAINTS)

# 3. Generate Bitstream (PNR-JSON -> .fs)
$(PROJECT).fs: $(PROJECT)_pnr.json
	$(PACK) -d GW1NZ-1 --cst $(CONSTRAINTS) -o $@ $<

# 4. Flash (Upload to the board)
flash: $(PROJECT).fs
	$(LOADER) -b tangnano1k $<

# Clean up
clean:
	rm -f *.json *.fs

.PHONY: all flash clean
