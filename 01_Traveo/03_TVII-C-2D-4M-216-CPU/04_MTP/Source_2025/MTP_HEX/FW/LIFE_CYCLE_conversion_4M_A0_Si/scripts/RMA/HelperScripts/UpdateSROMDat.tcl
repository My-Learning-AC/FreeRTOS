# ####################################################################################################
# This script executes all the DAP ES10 tests for PSoc 6A-2M
# Author: H ANKUR SHENOY
# Tested on PSVP
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;



#source [find interface/kitprog3.cfg]
#transport select swd
source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]
source [find HelperScripts/srom_dat.tcl];

# Acquire the silicon in test mode
acquire_TestMode_SROM;

update_srom $srom_dat;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown