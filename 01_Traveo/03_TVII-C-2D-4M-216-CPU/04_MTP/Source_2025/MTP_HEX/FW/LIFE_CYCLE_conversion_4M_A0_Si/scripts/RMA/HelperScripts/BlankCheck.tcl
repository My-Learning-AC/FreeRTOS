# ####################################################################################################
# This script executes the Calibrate API for TVII-8M
# Author: H ANKUR SHENOY
# Tested on PSVP
# ####################################################################################################
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find interface/kitprog3.cfg]
transport select swd
source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]

# Acquire the silicon in test mode
acquire_TestMode_SROM;

set TestString "Test AA131	VALIDATE THE BLANKCHECK API on WORK FLASH."
test_start $TestString;
test_compare 0xA0000000 [SROM_EraseSector $SYS_CALL_GREATER32BIT 0x01 0x14000000 0x00];
test_compare 0xA0000000 [SROM_BlankCheck $SYS_CALL_GREATER32BIT 0x14000000 0x1];
test_compare 0xA0000000 [SROM_ProgramRow $SYS_CALL_GREATER32BIT 0x01 0x00 0x2 0x01 0x0 0x14000000 [list 0x55555555]];
test_compare 0xF00000A4 [SROM_BlankCheck $SYS_CALL_GREATER32BIT 0x14000000 0x1]; 
test_end $TestString;

set TestString "Test AA132	VALIDATE THE UNIQUE ID API."
test_start $TestString;
IOW [expr $SRAM_SCRATCH + 0x4] 0x0;
IOW [expr $SRAM_SCRATCH + 0x8] 0x0;
test_compare 0x00000000 [IOR [expr $SRAM_SCRATCH + 0x4]];
test_compare 0x00000000 [IOR [expr $SRAM_SCRATCH + 0x8]];
test_compare 0xA0FFFFFF [SROM_ReadUniqueID $SYS_CALL_GREATER32BIT]; 
test_compare 0xFFFFFFFF [IOR [expr $SRAM_SCRATCH + 0x4]];
test_compare 0xFFFFFFFF [IOR [expr $SRAM_SCRATCH + 0x8]];
test_end $TestString;

set TestString "Test AA132	VALIDATE THE DEBUGPOWERUPDOWN API."
test_start $TestString;
# Check Reghc is on or off, does API enable reghc?
# Check clock configs are off, if not make off
# Turn on
# Check RegHc is on, clocks are on
# Turn off
# Check RegHc Status
IOR 0x4026102C;
# # Clk hf sel is enabled!
# 	IOW 0x40261244 0x80000000
# 	IOW 0x40261248 0x80000000
# # Disable PPB lock for CM7_0 CM7_1
# 	IOW 0x4020040C 15
# 	IOW 0x4020000C 15
# # Power up CM7, ensure that clocks are running when you do this!
# 	IOW 0x40201200 0x05FA0001
# 	IOW 0x40201200 0x05FA0003
# 	IOW 0x40201210 0x05FA0001
# 	IOW 0x40201210 0x05FA0003
# Check RegHc Status for enable, should be 0x01
IOR 0x4026102C 0x01;
# # Power down CM7, ensure that clocks are running when you do this!
IOW 0x40201200 0xFA050000;
IOW 0x40201210 0xFA050000;
# Disable clock to CM7_0 and CM7_1
IOW 0x40261244 0x00000000;
IOR 0x40261244 0x00000000;
IOW 0x40261248 0x00000000;
IOR 0x40261248 0x00000000;
test_compare 0xA0000000 [SROM_DebugPowerUpDown $SYS_CALL_GREATER32BIT 0x01]; 
# Read power state of CM7_0 and CM7_1
IOR 0x40261244 0x80000000;
IOR 0x40261248 0x80000000;
IOR 0x40201200 0xFA050003;
IOR 0x40201210 0xFA050003;
test_compare 0xA0000000 [SROM_DebugPowerUpDown $SYS_CALL_GREATER32BIT 0x00]; 
IOR 0x40261244 0x00000000;
IOR 0x40261248 0x00000000;
IOR 0x40201200 0xFA050000;
IOR 0x40201210 0xFA050000;
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown