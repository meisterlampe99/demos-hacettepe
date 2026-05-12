# Function to handle errors and exit Vivado
proc handle_error {msg} {
    puts "Error: $msg"
    exit 1
}

# try catch block for failing commands
if {[catch {
 	# Check if at least one argument is provided
	if {$argc < 1} {
	puts "Usage: vivado -mode tcl -source npm_runSim.tcl -tclarg <TopModuleName> [Optional:<DUTname>]"
	exit 1
	}

	# Get the first argument (topmodule)
	set topmodule [lindex $argv 0]

    if {$argc == 2} {
    # Get the second argument (dutname) if available
    set dutname [lindex $argv 1]
    }

	# Capture the start time
    set start_time [clock seconds]

    # Source settings (part and number of cores used)
    source settings.tcl

    # Set the maximum number of threads
    set_param general.maxThreads $threads

    # Define the target part
    set_part $part
	
	# Define output directory
	set project_dir "./outputSim"

    # Create the output directory if it doesn't exist
    file mkdir $project_dir

    # Add all SystemVerilog files in the root directory
    foreach file [glob *.sv] {
        read_verilog $file
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

    # Compile all SystemVerilog files in the root directory
    foreach file [glob ../*.sv] {
        exec xvlog -sv $file
    }

    # Send this command to OS shell, create sim files
    exec xelab -debug typical work.${topmodule}_tb -s ${topmodule}_tb_sim

    # Capture the end time
    set end_time [clock seconds]

    # Calculate and print the total runtime
    puts "Total simulation runtime: [expr {$end_time - $start_time}] seconds"

	# passing an argument to sim.tcl doesn't seem work in xsim! 
	#exec xsim ${topmodule}_tb_sim -gui -tclbatch "../sim.tcl $topmodule"
	
	# export environment variable
    set env(XSIM_ARGC) 1
	set env(XSIM_TOPMODULE) $topmodule
    if {$argc == 2} {
        set env(XSIM_DUTNAME) $dutname
        set env(XSIM_ARGC) 2
    }

    # Open simulation GUI via launching xsim and sourcing another tcl script
	exec xsim ${topmodule}_tb_sim -gui -tclbatch ../sim.tcl

    # Exit Vivado console
    exit
} result]} {
    handle_error $result
}