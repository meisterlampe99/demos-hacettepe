# ============================================================
# Makefile — Open-Source FPGA Flow
# Board:   Basys 3 (Digilent)
# Device:  Artix-7 XC7A35TCPG236-1
# Tools:   Yosys + OpenXC7 (nextpnr-xilinx) + openFPGALoader
# ============================================================

# --- Project Settings ---------------------------------------
PROJECT     = top_level
SOURCES     = top_level.sv
CONSTRAINTS = myconstraints_openxc7.xdc
TOP_MODULE  = top_level
BOARD       = basys3
PART        = xc7a35tcpg236-1
TARGETFREQ  = 100
# ------------------------------------------------------------

# --- Tool Paths ---------------------------------------------
YOSYS       = $(HOME)/.apio/packages/oss-cad-suite/bin/yosys
NEXTPNR     = $(HOME)/.apio/packages/openxc7/bin/nextpnr-xilinx
FASM2FRAMES = $(HOME)/.apio/packages/openxc7/bin/fasm2frames
FRAMES2BIT  = $(HOME)/.apio/packages/openxc7/bin/xc7frames2bit
LOADER      = $(HOME)/.apio/packages/oss-cad-suite/bin/openFPGALoader
CHIPDB      = $(HOME)/.apio/packages/openxc7/chipdb/xc7a35tcpg236.bin
XRAY_DB     = $(HOME)/.apio/packages/openxc7/share/nextpnr/external/prjxray-db/artix7
PART_YAML   = $(XRAY_DB)/$(PART)/part.yaml
IVERILOG	= $(HOME)/.apio/packages/oss-cad-suite/bin/iverilog
VVP			= $(HOME)/.apio/packages/oss-cad-suite/bin/vvp
SURFER	 	= $(HOME)/.apio/packages/oss-cad-suite/bin/surfer
GTKWAVE     = $(HOME)/.apio/packages/oss-cad-suite/bin/gtkwave

# ------------------------------------------------------------

# --- Simulation Settings ------------------------------------
TESTBENCH   = top_level_tb.sv
SIM_OUT     = sim_out
VCD_FILE    = dump.vcd
# ------------------------------------------------------------

# Default target: build everything up to bitstream
all: $(PROJECT).bit

# ============================================================
# STEP 1: Synthesis — Verilog -> Netlist
# ============================================================
$(PROJECT).json: $(SOURCES)
	@echo "=== SYNTHESIS with Yosys ==="
	$(YOSYS) -m slang -p "read_slang $(SOURCES); \
	             synth_xilinx -flatten -abc9 -arch xc7 -top $(TOP_MODULE); \
	             write_json $@"
	@echo "=== Synthesis complete: $@ ==="

# ============================================================
# STEP 2: Place & Route — Netlist -> FASM
# ============================================================
$(PROJECT).fasm: $(PROJECT).json $(CONSTRAINTS)
	@echo "=== PLACE & ROUTE with nextpnr-xilinx ==="
	$(NEXTPNR) \
		--chipdb $(CHIPDB) \
		--xdc $(CONSTRAINTS) \
		--freq $(TARGETFREQ) \
		--json $< \
		--fasm $@
	@echo "=== Place & Route complete: $@ ==="

# ============================================================
# STEP 3a: FASM -> Frames
# ============================================================
$(PROJECT).frames: $(PROJECT).fasm
	@echo "=== FASM -> Frames ==="
	$(FASM2FRAMES) \
		--db-root $(XRAY_DB) \
		--part $(PART) \
		$< $@

# ============================================================
# STEP 3b: Frames -> Bitstream
# ============================================================
$(PROJECT).bit: $(PROJECT).frames
	@echo "=== Frames -> Bitstream ==="
	$(FRAMES2BIT) \
		--part-file $(PART_YAML) \
		--frm_file $< \
		--output_file $@
	@echo "=== BITSTREAM READY: $@ ==="
	@ls -lh $@

# ============================================================
# STEP 4: Program the board
# ============================================================
flash: $(PROJECT).bit
	@echo "=== PROGRAM BOARD ==="
	sudo $(LOADER) -b $(BOARD) $<

# ============================================================
# SIMULATION with Icarus Verilog
# ============================================================
sim: $(SOURCES) $(TESTBENCH)
	@echo "=== SIMULATION with Icarus Verilog ==="
	$(IVERILOG) -o $(SIM_OUT) -g2012 $(TESTBENCH) $(SOURCES)
	$(VVP) $(SIM_OUT)
	@echo "=== VCD file created: $(VCD_FILE) ==="
	@echo "=== Open with: surfer $(VCD_FILE) ==="

# Simulation + open Surfer directly
sim-surfer: sim
	$(SURFER) $(VCD_FILE) &

# Simulation + open GTKWave
sim-gtkwave: sim
	$(GTKWAVE) $(VCD_FILE) &

# ============================================================
# Cleanup
# ============================================================
clean:
	rm -f $(PROJECT).json $(PROJECT).fasm $(PROJECT).frames $(PROJECT).bit
	rm -f $(SIM_OUT) $(VCD_FILE)
	@echo "=== Cleanup done ==="

# ============================================================
# Help
# ============================================================
help:
	@echo "Available commands:"
	@echo "  make             -> All: Synthesis + P&R + Bitstream"
	@echo "  make flash       -> Program the board"
	@echo "  make sim         -> Simulation with Icarus Verilog"
	@echo "  make sim-surfer  -> Simulation + open Surfer"
	@echo "  make sim-gtkwave -> Simulation + open GTKWave"
	@echo "  make clean       -> Delete all generated files"
	@echo ""
	@echo "Project settings (edit at top of Makefile):"
	@echo "  PROJECT     = $(PROJECT)"
	@echo "  SOURCES     = $(SOURCES)"
	@echo "  TOP_MODULE  = $(TOP_MODULE)"
	@echo "  BOARD       = $(BOARD)"
	@echo "  PART        = $(PART)"

.PHONY: all flash sim sim-surfer sim-gtkwave clean help
