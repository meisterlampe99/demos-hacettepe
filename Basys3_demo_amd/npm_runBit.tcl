# Function to handle errors and exit Vivado
proc handle_error {msg} {
    puts "Error: $msg"
    exit 1
}

# try catch block for failing commands
if {[catch {
    # Check if at least one argument is provided
	if {$argc < 1} {
	puts "Usage: vivado -mode tcl -source npm_runBit.tcl -tclarg <TopModuleName>"
	exit 1
	}

	# Get the first argument (filename)
	set topmodule [lindex $argv 0]
	
	# Capture the start time
    set start_time [clock seconds]

    # Source settings (part and number of cores used)
    source settings.tcl

    # Set the maximum number of threads
    set_param general.maxThreads $threads

    # Define the target part
    set_part $part

	# Define output directory
	set project_dir "./outputBit"
	
    # Create the output directory if it doesn't exist
    file mkdir $project_dir

    # Read all SystemVerilog files in the root directory
    foreach file [glob *.sv] {
        read_verilog $file
    }

    # Read all XDC files in the root directory
    foreach file [glob *.xdc] {
        read_xdc $file
    }
	
	#change to output directory
	cd $project_dir

    # Run linting in Vivado 2019.2 or later
    # Get the Vivado version
    set vivado_version [version]

    # Extract the year and release number
    regexp {v(\d+)\.(\d+)} $vivado_version -> year release

    # Convert to integers for comparison
    set year [expr {$year}]
    set release [expr {$release}]

    # Check if the version is newer than 2019.1
    if {($year > 2019) || ($year == 2019 && $release > 1)} {
        # Set severity of linter messages
        set_msg_config -id {Synth 37-} -severity {CRITICAL WARNING} -new_severity {ERROR}
        set_msg_config -id {Synth 37-} -severity {WARNING} -new_severity {ERROR}

        # Call the line if the version is newer than 2019.1
        puts "Vivado version is newer than 2019.1 - do Linting"
        synth_design -top $topmodule -lint
    } else {
        puts "Vivado version is 2019.1 or older - no Linter available"
    }

    # Decrease severity of "Parallel synthesis criteria is not met" to INFO
    set_msg_config -id {Synth 8-7080} -new_severity {INFO}
	
	# Increase severity of multiple divers to error
	set_msg_config -id {Synth 8-6859} -new_severity {ERROR}
	
	# Increase severity of inferred latches to error
	set_msg_config -id {Synth 8-7137} -new_severity {ERROR}
	set_msg_config -id {Synth 8-327} -new_severity {ERROR}

    # Synthesize the design
    synth_design -top $topmodule
	#synth_design -directive RuntimeOptimized -effort_level quick -top $topmodule

    # Write checkpoint after synthesis
    write_checkpoint -force ./synth_checkpoint.dcp

    # Optimize the design
    # opt_design

    # Place the design
    place_design

    # Optionally run optimization if there are timing violations after placement
    if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
        puts "Found setup timing violations => running physical optimization"
        phys_opt_design
    }

    # Route the design
    route_design

    # Write checkpoint after implementation
    write_checkpoint -force ./impl_checkpoint.dcp

    # Write the bitstream
    write_bitstream -force ./${topmodule}.bit

    # Not tested: write LTX file if an ILA core is in design
    # write_debug_probes -force my_debug_probes.ltx

    # Generate reports
    report_timing_summary -file ./timing_summary.rpt
    report_utilization -file ./utilization.rpt

    # Capture the end time
    set end_time [clock seconds]

    # Calculate and print the runtime
    set runtime [expr {$end_time - $start_time}]
    puts "Total runtime: $runtime seconds"

    # Exit Vivado console
    exit
} result]} {
    handle_error $result
}