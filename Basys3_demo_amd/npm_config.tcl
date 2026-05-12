# Function to handle errors and exit Vivado
proc handle_error {msg} {
    puts "Error: $msg"
    exit 1
}

# try catch block for failing commands
if {[catch {
    # Check if at least one argument is provided
	if {$argc < 1} {
	puts "Usage: vivado -mode tcl -source npm_config.tcl -tclarg <TopModuleName>"
	exit 1
	}

	# Get the first argument (topmodule)
	set topmodule [lindex $argv 0]
	
	# Pre 2019.2 used different commands for HW manager
	# Get the Vivado version
	set vivado_version [version]

	# Extract the year and release number
	regexp {v(\d+)\.(\d+)} $vivado_version -> year release

	# Convert to integers for comparison
	set year [expr {$year}]
	set release [expr {$release}]

	# Check if the version is newer than 2019.1
	if {($year > 2019) || ($year == 2019 && $release > 1)} {
		# use new commands introduced in 2019.2
		# Open the Hardware Manager
		open_hw_manager

		# Connect to the target (adjust the target connection details as needed)
		connect_hw_server -allow_non_jtag
		open_hw_target

		# Download the bitstream to the target
		set_property PROBES.FILE {} [get_hw_devices]
		set_property FULL_PROBES.FILE {} [get_hw_devices]
		set_property PROGRAM.FILE ./outputBit/${topmodule}.bit [get_hw_devices]
		program_hw_devices [get_hw_devices]

		# Close the Hardware Manager
		close_hw_manager
	} else {
		# use older commands until 2019.1
		# Open the Hardware Manager
		open_hw

		# Connect to the target (adjust the target connection details as needed)
		connect_hw_server
		open_hw_target

		# Download the bitstream to the target
		
		set_property PROBES.FILE {} [get_hw_devices]
		set_property FULL_PROBES.FILE {} [get_hw_devices]
		set_property PROGRAM.FILE ./outputBit/${topmodule}.bit [get_hw_devices]
		program_hw_devices [get_hw_devices]

		# Close the Hardware Manager
		close_hw
	}

    # Exit Vivado
    exit
} result]} {
    handle_error $result
}