# -------------------------------------------------------------------------------------#
#  ScriptName : NARCheck.tcl
#  Description :
#  This script allows the check for lifecycle stages when Widen enable = 1 
# 
#  This script follows the following steps before conversion:
#  1.  It logs lifecycle stage and widen ebale condition
#  2.  It tries all life cycle conversions in sequence and checks if we can enter all combinations 
# -------------------------------------------------------------------------------------#

# Acquire the part
source [find interface/cmsis-dap.cfg]
transport select swd
source [find target/psoc6.cfg]
source [find SROM_Defines_P6.tcl]
source [find utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]

puts "Acquiring using acquire_TestMode_SROM";
psoc6.cpu.cm0 configure -defer-examine
psoc6.cpu.cm4 configure -defer-examine
init
cmsis-dap acquire_psoc 2 0 5
poll off;

# --------------------------------------#
# Edit following values before running 
# the script
# --------------------------------------#
set DEAD_AP_CTL_M0_DISABLE		   0x00;
set DEAD_AP_CTL_M4_DISABLE         0x00;
set DEAD_AP_CTL_SYS_DISABLE        0x00;
set DEAD_SYS_AP_MPU_ENABLE         0x00;
set DEAD_FLASH_ENABLE              0x00;
set DEAD_SFLASH_ENABLE             0x00;
set DEAD_RAM0_ENABLE               0x00;
set DEAD_MMIO_ENABLE               0x00;
set DEAD_SMIF_XIP_ENABLE           0x00;
set DEAD_DIRECT_EXECUTE_DISABLE    0x00;

set SECURE_AP_CTL_M0_DISABLE	   0x00;
set SECURE_AP_CTL_M4_DISABLE       0x00;
set SECURE_AP_CTL_SYS_DISABLE      0x00;
set SECURE_SYS_AP_MPU_ENABLE       0x00;
set SECURE_FLASH_ENABLE            0x00;
set SECURE_SFLASH_ENABLE           0x00;
set SECURE_RAM0_ENABLE             0x00;
set SECURE_MMIO_ENABLE             0x00;
set SECURE_SMIF_XIP_ENABLE         0x00;
set SECURE_DIRECT_EXECUTE_DISABLE  0x00;

# -------------- Do not Edit here ---------------#
set DEAD_ACCESS_RESTRICT0      [expr ($DEAD_MMIO_ENABLE<<6)+($DEAD_SFLASH_ENABLE<<4)+($DEAD_SYS_AP_MPU_ENABLE<<3)+($DEAD_AP_CTL_SYS_DISABLE<<2)+($DEAD_AP_CTL_M4_DISABLE<<1)+($DEAD_AP_CTL_M0_DISABLE<<0)];
set DEAD_ACCESS_RESTRICT1      [expr ($DEAD_DIRECT_EXECUTE_DISABLE<<7)+($DEAD_SMIF_XIP_ENABLE<<6)+($DEAD_RAM0_ENABLE<<3)+($DEAD_FLASH_ENABLE<<0)];

set SECURE_ACCESS_RESTRICT0    [expr ($SECURE_MMIO_ENABLE<<6)+($SECURE_SFLASH_ENABLE<<4)+($SECURE_SYS_AP_MPU_ENABLE<<3)+($SECURE_AP_CTL_SYS_DISABLE<<2)+($SECURE_AP_CTL_M4_DISABLE<<1)+($SECURE_AP_CTL_M0_DISABLE<<0)];
set SECURE_ACCESS_RESTRICT1    [expr ($SECURE_DIRECT_EXECUTE_DISABLE<<7)+($SECURE_SMIF_XIP_ENABLE<<6)+($SECURE_RAM0_ENABLE<<3)+($SECURE_FLASH_ENABLE<<0)];
# -------------- Do not Edit here ---------------#

GetProtectionState;

# CheckDeviceInfo $SYS_CALL_GREATER32BIT 1 1 2;
CheckLifeCycle;
# Check values of Normal and Dead access restrictions from sflash
#set regValue [IOR 0x16000008];
#puts "widen Enable is $regValue";
#set regValue [IOR 0x16001A00];
#puts "NAR Enable is $regValue";

global SYS_CALL_GREATER32BIT SYS_CALL_LESS32BIT;

proc writeCheck {} {
	puts "Writing to SRAM0 locations";
	puts "Writing SRAM0"
	#IOW 0x08080000 0xDEADBEEF;
	IOWap 0x0 0x08000000 0xDEADBEEF;
	IOWap 0x0 0x08007FFC 0xDEADBEEF;
	IOWap 0x0 0x08008000 0xDEADBEEF;
	IOWap 0x0 0x0800FFFC 0xDEADBEEF;
	IOWap 0x0 0x08010000 0xDEADBEEF;
	IOWap 0x0 0x0801FFFC 0xDEADBEEF;
	IOWap 0x0 0x08020000 0xDEADBEEF;
	IOWap 0x0 0x0803FFFC 0xDEADBEEF;
	IOWap 0x0 0x08040000 0xDEADBEEF;
	IOWap 0x0 0x0805FFFC 0xDEADBEEF;
	IOWap 0x0 0x08060000 0xDEADBEEF;
	IOWap 0x0 0x0806FFFC 0xDEADBEEF;
	IOWap 0x0 0x08070000 0xDEADBEEF;
	IOWap 0x0 0x0807FFFC 0xDEADBEEF;

	puts "Reading SRAM1"
	#IOW 0x08080000 0xDEADBEEF;
	IOWap 0x0 0x08080000 0xDEADBEEF;
	IOWap 0x0 0x080BFFFC 0xDEADBEEF;

	puts "Reading SRAM2"
	IOWap 0x0 0x080C0000 0xDEADBEEF;
	IOWap 0x0 0x080FFFFC 0xDEADBEEF;
}

proc Enablesmif {} {
# This procedure enables smif in XIP mode
IOWap 0x0 0x40310580 0xE4
IOWap 0x0 0x403105C4 0x6EE00600
IOWap 0x0 0x403000B0 0x00110000
IOWap 0x0 0x403000B4 0x11111100

IOWap 0x0 0x40420988 0x18000000
IOWap 0x0 0x404209A0 0x2
IOWap 0x0 0x4042098C 0xFFF00000
IOWap 0x0 0x404209C0 0x80000003
IOWap 0x0 0x404209C4 0x00
IOWap 0x0 0x40420980 0x80000000
IORap 0x0 0x40420980

IOWap 0x0 0x40260388 0x80000030
IOWap 0x0 0x40420000 0x81033001
IORap 0x0 0x40420000
IOWap 0x0 0x40420180 0x0
IOWap 0x0 0x40420100 0x0
}

proc readCheck {NARValue} {
# This procedure checks NAR against passed value
# Read SROM
# Read through 3 APs
# Read sflash
# Read MMIO - Try silicon ID
# Read SRAM0,1,2
# Read flash and work flash
# Read workflash
global SYS_CALL_GREATER32BIT SYS_CALL_LESS32BIT;

puts "Reading sflash NAR"
IORap 0x0 0x17001a00;

puts "Reading SROM"
IORap 0x0 0x00000000;
IORap 0x1 0x00000000;
IORap 0x2 0x00000000;

puts "Reading SRAM0"
#IOW 0x08080000 0xDEADBEEF;
IORap 0x0 0x28000000 0xDEADBEEF;
IORap 0x0 0x28007FFC 0xDEADBEEF;
IORap 0x0 0x28008000 0xDEADBEEF;
IORap 0x0 0x2800FFFC 0xDEADBEEF;
IORap 0x0 0x28010000 0xDEADBEEF;
IORap 0x0 0x2801FFFC 0xDEADBEEF;
IORap 0x0 0x28020000 0xDEADBEEF;
IORap 0x0 0x2803FFFC 0xDEADBEEF;
IORap 0x0 0x28040000 0xDEADBEEF;
IORap 0x0 0x2805FFFC 0xDEADBEEF;
IORap 0x0 0x28060000 0xDEADBEEF;
IORap 0x0 0x2806FFFC 0xDEADBEEF;
IORap 0x0 0x28070000 0xDEADBEEF;
IORap 0x0 0x2807FFFC 0xDEADBEEF;

puts "Reading SRAM1"
#IOW 0x08080000 0xDEADBEEF;
IORap 0x0 0x28080000 0xDEADBEEF;
IORap 0x0 0x280BFFFC 0xDEADBEEF;

puts "Reading SRAM2"
#IOW 0x080C0000 0xDEADBEEF;
IORap 0x0 0x280C0000 0xDEADBEEF;
IORap 0x0 0x280FFFFC 0xDEADBEEF;

puts "Reading sflash"
IORap 0x0 0x17000000;
IORap 0x0 0x17001FFC;
IORap 0x0 0x17002000;
IORap 0x0 0x17003FFC;
IORap 0x0 0x17004000;
IORap 0x0 0x17005FFC;
IORap 0x0 0x17006000;
IORap 0x0 0x17007FFC;

puts "Reading FLASH"
#IOW 0x08080000 0xDEADBEEF;
IORap 0x0 0x10000000;
IORap 0x0 0x1001FFFC;
IORap 0x0 0x10020000;
IORap 0x0 0x1003FFFC;
IORap 0x0 0x10040000;
IORap 0x0 0x1007FFFC;
IORap 0x0 0x10080000;
IORap 0x0 0x100FFFFC;
IORap 0x0 0x10100000;
IORap 0x0 0x1017FFFC;
IORap 0x0 0x10180000;
IORap 0x0 0x101BFFFC;
IORap 0x0 0x101C0000;
IORap 0x0 0x101FFFFC;

puts "Reading MMIO"
IORap 0x0 0x40260580;

puts "Reading workflash"
IORap 0x0 0x14000000;
IORap 0x0 0x14007FFC;

puts "Read xip"
# Assume mxsmif is enabled
IORap 0x0 0x18000000;

if {($NARValue & 0x8000) == 0x8000} {
	puts "Checking DirectExecute API";
	SROM_DirectExecute $SYS_CALL_LESS32BIT 0x0 0xC3C 0x0 0x0 0x1;
}
}

set regValue [expr [IOR 0x40260580] >> 31];
puts "FLL enable value is $regValue";

# For widen enable
set list_of_combinations [list 0xFFF3 0x00 0x08 0x18 0x28 0x38 0x78 0x178 0x278 0x378 0x478 0x578 0x678 0x778 0xF78 0x1778 0x1F78 0x2778 0x2F78 0x3778 0xFF78];
# No widen enable
#set list_of_combinations [list 0x00 0x08 0x18 0x28 0x38 0x78 0x178 0x278 0x378 0x478 0x578 0x678 0x778 0xF78 0x1778 0x1F78 0x2778 0x2F78 0x3778 0x377B 0xFFFF];

set num_combinations [llength $list_of_combinations];

writeCheck;

for {set iter 0} {$iter < $num_combinations} {incr iter 1} {
	puts [format "\n***Run %d: START Check for NAR = 0x%04x***\n" $iter [lindex $list_of_combinations $iter]];
	set nar_value [lindex $list_of_combinations $iter];
	SROM_WriteNormalAccessRestriction $SYS_CALL_GREATER32BIT $nar_value;
	acquire_TestMode_SROM;
	Enablesmif;
	readCheck $nar_value;
	puts [format "\n***Run %d: END Check for NAR = 0x%04x***\n" $iter [lindex $list_of_combinations $iter]];
}

shutdown;
# script_end:
# $pp->quit();
# 1
