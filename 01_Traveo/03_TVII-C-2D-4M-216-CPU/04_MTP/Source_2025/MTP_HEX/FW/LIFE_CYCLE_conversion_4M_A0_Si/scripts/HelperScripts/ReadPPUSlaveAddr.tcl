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

set addr $CYREG_PERI_MS_PPU_PROG_SL_ADDR_ADDR
for {set cnt 0} {$cnt < 32} {incr cnt} {
  set val [Silent_IOR $addr];
  puts "CYREG_PERI_MS_PPU_PROG_ $cnt _SL_ADDR: $val";
  
  incr addr 0x40;
}

set addr $CYREG_PERI_MS_PPU_FX0_SL_ADDR_ADDR
for {set cnt 0} {$cnt < 992} {incr cnt} {
  set val [Silent_IOR $addr];
  puts "CYREG_PERI_MS_PPU_FX_ $cnt _SL_ADDR: $val";
  
  incr addr 0x40;
}

shutdown 