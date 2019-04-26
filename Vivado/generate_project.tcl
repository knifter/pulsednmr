
variable design_name
set design_name "pulsed_nmr"

# Create the project with the (modified) Vivado Project Tcl
puts "INFO: Start Importing src/${design_name}_project.tcl"
source src/${design_name}_project.tcl

# Set IP repository paths
#set obj [get_filesets sources_1]
#set_property "ip_repo_paths" "[file normalize "./cores"]" $obj

# Rebuild user ip_repo's index before adding any source files
#update_ip_catalog -rebuild

# Create block design
#source ./src/${design_name}_bd.tcl

# Generate the wrapper
# make_wrapper -files [get_files *${design_name}.bd] -top
#add_files -norecurse ${design_name}/${design_name}.srcs/sources_1/bd/${design_name}/hdl/${design_name}_wrapper.v

# Or add a manually managed wrapper
#add_files -norecurse src/${design_name}_wrapper.v

# Open the block design

# # Update the compile order
puts "INFO: Update Compile Order"
open_bd_design [get_files ${design_name}.bd]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
close_bd_design [current_bd_design]

# # Ensure parameter propagation has been performed
puts "INFO: Validating Design"
open_bd_design [get_files ${design_name}.bd]
validate_bd_design -force
save_bd_design

# And build the bitstream if you like
# launch_runs impl_1 -to_step write_bitstream -jobs 4

