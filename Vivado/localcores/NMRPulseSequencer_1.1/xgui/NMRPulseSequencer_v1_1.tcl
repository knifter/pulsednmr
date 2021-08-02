# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Group
  set Config [ipgui::add_group $IPINST -name "Config"]
  set US_DIVIDER [ipgui::add_param $IPINST -name "US_DIVIDER" -parent ${Config}]
  set_property tooltip {Clocks per microsecond} ${US_DIVIDER}


}

proc update_PARAM_VALUE.US_DIVIDER { PARAM_VALUE.US_DIVIDER } {
	# Procedure called to update US_DIVIDER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.US_DIVIDER { PARAM_VALUE.US_DIVIDER } {
	# Procedure called to validate US_DIVIDER
	return true
}


proc update_MODELPARAM_VALUE.US_DIVIDER { MODELPARAM_VALUE.US_DIVIDER PARAM_VALUE.US_DIVIDER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.US_DIVIDER}] ${MODELPARAM_VALUE.US_DIVIDER}
}

