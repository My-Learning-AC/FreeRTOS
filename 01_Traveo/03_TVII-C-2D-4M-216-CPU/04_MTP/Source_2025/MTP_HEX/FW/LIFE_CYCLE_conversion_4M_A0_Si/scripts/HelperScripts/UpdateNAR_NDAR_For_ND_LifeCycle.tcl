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
#shutdown
Enable_MainFlash_Operations;



set TestString "Test AAxxx: UPDATE Norman Access Control";
test_start $TestString;
set NAR_CTL [ReturnSFlashRow 0];
puts "NAR_CTL = $NAR_CTL";
lset NAR_CTL 2 0x00000000;

puts "NAR = $NAR_CTL";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17000000 0 $NAR_CTL];

IOR 0x17000000;
IOR 0x17000004;
IOR 0x17000008;
test_end $TestString;

set TestString "Test AAxxx: UPDATE Norman Access/Normal Dead Access Restrictions";
test_start $TestString;
set AP_CTL_CM0_DISABLE 			0x0;	#2-bits
set AP_CTL_CMX_DISABLE 			0x0;	#2-bits
set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
set SYS_AP_MPU_ENABLE 	        0x0;	#1-bits
set DIRECT_EXECUTE_DISABLE 		0x0;	#1-bit
set FLASH_ALLOWED 			    0x0;	#3-bit
set SRAM_ALLOWED 			    0x0;	#3-bit
set WORK_FLASH_ALLOWED 		    0x0;	#2-bits
set SFLASH_ALLOWED	            0x0;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
set MMIO_ALLOWED      	        0x0;    #2-bit
set SMIF_XIP_ENABLE 	        0x0;	#1-bits

set NormalAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];

set AP_CTL_CM0_DISABLE 			0x1;	#2-bits
set AP_CTL_CMX_DISABLE 			0x1;	#2-bits
set AP_CTL_SYS_DISABLE 	        0x0;	#2-bits
set SYS_AP_MPU_ENABLE 	        0x1;	#1-bits
set DIRECT_EXECUTE_DISABLE 		0x0;	#1-bit
set FLASH_ALLOWED 			    0x1;	#3-bit
set SRAM_ALLOWED 			    0x1;	#3-bit
set WORK_FLASH_ALLOWED 		    0x1;	#2-bits
set SFLASH_ALLOWED	            0x1;	#2-bits - NOT USED FOR TVII-BE-1M ** SILICON
set MMIO_ALLOWED      	        0x0;    #2-bit
set SMIF_XIP_ENABLE 	        0x0;	#1-bits

set NormalDeadAccessRestrictions [expr $AP_CTL_CM0_DISABLE + ($AP_CTL_CMX_DISABLE<<2) +($AP_CTL_SYS_DISABLE<<4 ) + ($SYS_AP_MPU_ENABLE<<6) + ($DIRECT_EXECUTE_DISABLE<<7) + ($FLASH_ALLOWED<<8) + ($SRAM_ALLOWED<<11) + ($WORK_FLASH_ALLOWED<<14) + ($SFLASH_ALLOWED<<16) + ($MMIO_ALLOWED<<18) + ($SMIF_XIP_ENABLE<<20)];
set NAR [ReturnSFlashRow $NAR_ROW_IDX];
puts "NAR = $NAR";
lset NAR 0 $NormalAccessRestrictions; #0x19855;
lset NAR 1 $NormalDeadAccessRestrictions; #0x19845;
puts "NAR = $NAR";
test_compare 0xa0000000 [SROM_WriteRow $SYS_CALL_GREATER32BIT 0 0x17001A00 0 $NAR];

IOR 0x17001A00;
IOR 0x17001A04;
test_end $TestString;

set FlowEndTime [clock seconds];
compute_executionTime $FlowStartTime $FlowEndTime;

# Exit openocd
shutdown