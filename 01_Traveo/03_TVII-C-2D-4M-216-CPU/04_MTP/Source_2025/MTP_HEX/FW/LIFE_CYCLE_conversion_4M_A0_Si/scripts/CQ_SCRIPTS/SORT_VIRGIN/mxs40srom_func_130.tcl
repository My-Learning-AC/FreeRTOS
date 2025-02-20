#source [find interface/jlink.cfg]
set FlowStartTime [clock seconds];
set FlowEndTime [clock seconds];
set TestStartTime [clock seconds];
set TestEndTime [clock seconds];
set TestString NoTestStarted;

source [find HelperScripts/SROM_Defines.tcl]
source [find HelperScripts/utility_srom.tcl]
source [find HelperScripts/CustomFunctions.tcl]

source [find interface/kitprog3.cfg]
transport select swd
adapter_khz 1000

set _CHIPNAME generic_dap_access
source [find target/swj-dp.tcl]
swj_newdap $_CHIPNAME cpu -irlen 4 -ircapture 0x1 -irmask 0xf
dap create $_CHIPNAME.dap -chain-position $_CHIPNAME.cpu

# Writes 'val' to address 'addr' via AP 'ap'
proc mww_ll { ap addr val } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C $val
}

# Reads and displays data from address 'addr' via AP 'ap'
proc mdw_ll { ap addr } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	$_CHIPNAME.dap apreg $ap 0x0C
}

# Reads data from address 'addr' via AP 'ap' and returns it
# Can be used to read data and pass it to other commands
proc mrw_ll { ap addr } {
	global _CHIPNAME
	$_CHIPNAME.dap apreg $ap 0x04 $addr
	set ap [ocd_$_CHIPNAME.dap apreg $ap 0x0C]
	regsub -all {(\s*\n)+} $ap "" ap
	return $ap
}


init

# Now you can access memory via SYSAP :
puts "Acquire Check"
mww_ll 0 $SRAM_SCRATCH 0x12345678
mdw_ll 0 $SRAM_SCRATCH
mdw_ll 0 $CYREG_IPC_STRUCT_DATA

puts "API parameters"
set i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x00000014;   # Object Size = 0x14, fixed for TVII
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x120029f0;   # CommandId = 0x120029F0 , fixed for OpenRma 
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x01947fb4;   # Uid Word0
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x02032439;   # Uid Word1
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x00000000;   # Uid Word2 (3 bytes)
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x2800041c;   # SRAM address where signature is passed.
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xf1d4ee80;   # Corrupt the signature (correct signature-> mww_ll 0 0x2800041c 0xf1d4ee8e;)
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xdc84f5e1;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x7e8af911;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xc92e5a00;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xff8c4ffb;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xc1eef217;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xe06f900f;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xf19eb565;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x28fb1869;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x237ebfb1;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x81bdccd5;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x3c2f0fdf;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xf0227bbc;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xb9d31b03;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xf5175a29;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x5a8762ba;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xfe3dfdae;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x5f7edd85;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xc2794c50;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x3fa179ca;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x96c2b019;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x997cc569;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xbe7187fc;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x4cdcd34a;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xbdfb8ac8;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xabdd1657;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x55123e4c;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xdcbe767f;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x7e444e37;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xa6c39dbd;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xc5d87e00;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xbd3df680;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x6dc9e3b2;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xb1c40b04;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xd19cb84f;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x6ac38fe9;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x4f146cd0;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x16f0872c;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xb32a6ef4;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x25d165b7;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xdcb3d813;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x2da51e1c;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x0e462c20;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xeccf8de2;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x08781545;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x2289b3cb;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x09de0b1d;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x5545ff1b;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x77752ea1;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xa36a742d;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xf8edf41e;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x88200799;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x82158490;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x42d48d25;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x2821a9b9;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x83f18680;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x0301c165;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xcdfa2d9d;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x2234e925;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x920b9326;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0xcc4597e5;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x8d265253;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x82875fd4;
incr i 4;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x6d0991f6;

set i 0x4;
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];
incr i 4;                                   
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];



set i 0;
mww_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i] 0x29000000;
mdw_ll 0 [expr $SRAM_SCRATCH_DATA_ADDR + $i];

puts "IPC Acquire "
mdw_ll 0 $CYREG_IPC_STRUCT_ACQUIRE
mww_ll 0 $CYREG_IPC_STRUCT_ACQUIRE 0x80000f03
mdw_ll 0 $CYREG_IPC_STRUCT_ACQUIRE

puts "SRAM SCRATCH into IPC3 DATA0"
mww_ll 0 $CYREG_IPC_STRUCT_DATA 0x28000400
mdw_ll 0 $CYREG_IPC_STRUCT_DATA 
puts "Notify"
mww_ll 0 $CYREG_IPC_STRUCT_NOTIFY 0x00000001


puts "Wait for IPC Release"
after 100
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS 
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS
mdw_ll 0 $CYREG_IPC3_STRUCT_LOCK_STATUS

puts "Read IPC DATA"
mdw_ll 0 $CYREG_IPC_STRUCT_DATA
mdw_ll 0 $SRAM_SCRATCH_DATA_ADDR

puts "IPC7_STRUCT_DATA0:";
mdw_ll 0 0x402200EC

puts "IPC3_STRUCT_DATA0:";
mdw_ll 0 0x4022006C 

test_compare  $STATUS_INVALID_SIGN [mdw_ll 0 $CYREG_IPC_STRUCT_DATA_RMA];


puts " SRAM location 0x28010000"
mdw_ll 0 [expr $SRAM_START_ADDR + 0x10000];
puts " FlashBoot location"
mdw_ll 0 0x17002000
puts " SFLASH Row 0"
mdw_ll 0 0x17000000
puts " FM CTL"
mdw_ll 0 0x40240000
puts " WOUNDING"
mdw_ll 0 0x402020c0
puts " PROTECTION Register"
mdw_ll 0 0x402020c4





exit
