#This test script is written to be executed on all TVII devices with out any change.
#DO NOT MODIFY
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]


acquire_TestMode_SROM;


Enable_MainFlash_Operations;
Enable_WorkFlash_Operations;

Silent_IOR 0x4026C000;
Silent_IOR 0x40024A80;
Silent_IOR 0x40024A84;
Silent_IOR 0x40024A88;
Silent_IOR 0x40024A8C;
Silent_IOR 0x40024A90;
Silent_IOR 0x40024A94;
Silent_IOR 0x40024A98;
Silent_IOR 0x40024A9C;
Silent_IOR 0x40024AC0;
Silent_IOR 0x40024AC4;
Silent_IOR 0x40024AE0;
Silent_IOR 0x40024AE4;
# Exit openocd
shutdown