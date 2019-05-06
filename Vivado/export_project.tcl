variable design_name
set design_name "PulsedNMR"

# Open Project
puts "INFO: Opening Project"
open_project ./${design_name}/${design_name}.xpr

# # Ensure parameter propagation has been performed
puts "INFO: Validating Design"
open_bd_design [get_files ${design_name}.bd]
validate_bd_design -force
save_bd_design

# Clean project
reset_project

# Export Project tcl only
# help write_project_tcl
  # Name                    Description
  # -----------------------------------
  # [-paths_relative_to]    Override the reference directory variable for 
  #                         source file relative paths
  #                         Default: Script output directory path
  # [-origin_dir_override]  Set 'origin_dir' directory variable to the 
  #                         specified value (Default is value specified with 
  #                         the -paths_relative_to switch)
  #                         Default: None
  # [-target_proj_dir]      Directory where the project needs to be restored
  #                         Default: Current project directory path
  # [-force]                Overwrite existing tcl script file
  # [-all_properties]       Write all properties (default & non-default) for 
  #                         the project object(s)
  # [-no_copy_sources]      Do not import sources even if they were local in 
  #                         the original project
  #                         Default: 1
  # [-absolute_path]        Make all file paths absolute wrt the original 
  #                         project directory
  # [-dump_project_info]    Write object values
  # [-use_bd_files]         Use BD sources directly instead of writing out 
  #                         procs to create them
  # [-internal]             Print basic header information in the generated tcl
  #                         script
  # [-quiet]                Ignore command errors
  # [-verbose]              Suspend message limits during command execution
  # <file>                  Name of the tcl script file to generate
puts "INFO: Writing Project tcl"
write_project_tcl -origin_dir_override ${design_name} -paths_relative_to ./${design_name} -force ./src/${design_name}_project.tcl

# Export Block Design separately
# puts "INFO: Writing blockdesign tcl"
# open_bd_design [get_files ${design_name}.bd]
# write_bd_tcl -force ./src/${design_name}_bd.tcl
