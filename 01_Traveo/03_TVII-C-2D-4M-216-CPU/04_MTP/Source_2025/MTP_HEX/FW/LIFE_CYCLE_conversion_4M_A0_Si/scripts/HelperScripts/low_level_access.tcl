#source [find interface/jlink.cfg]
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

puts "ReadPC: Start";
# Halt core, Read PC of CM0p and resume
set cm0p_ap	0;
mdw_ll $cm0p_ap 0xE000EDF0;
mww_ll $cm0p_ap 0xE000EDF0 0xA05F0003;

mww_ll $cm0p_ap 0xE000EDF4 15;
set regVal [mrw_ll $cm0p_ap 0xE000EDF8;]
set regVal [expr $regVal >> 31];

mdw_ll $cm0p_ap 0xE000EDF0;
mww_ll $cm0p_ap 0xE000EDF0 0xA05F0001;
puts "ReadPC: End";
	

mdw_ll 0 0x40220010;
mdw_ll 0 0x4022000C;
mdw_ll 0 0x40220070;
mdw_ll 0 0x4022006C;
shutdown
###mdw_ll 0 0x40220060;
###set FamilyId_Low [mrw_ll 1 0xF0000FE0]
###set FamilyId_Hi  [mrw_ll 1 0xF0000FE4];
###set MajorRevId   [mrw_ll 1 0xF0000FE8];
###set MinorRevId   [mrw_ll 1 0xF0000FEC];
###set ExpectedResultType1 [expr 0xa0000000 | [expr (0xF & ($MajorRevId>>4)) << 20] | [expr (0xF & ($MinorRevId>>4))<<16] |[expr (0xF & $FamilyId_Hi)<<8] |[expr $FamilyId_Low]];
###puts $ExpectedResultType1
#IORap 0x1 0xF0000FE0;
#IORap 0x2 0xF0000FE0;
#IORap 0x3 0xF0000FE0;
#IORap 0x0 0xF0000FE0;
#mdw_ll 0 0x40220060 ;
#mww_ll 0 0x40220060 0x80000f02;
#after 10;
#mww_ll 0 0x4022006c 0x10000001;
#mdw_ll 0 0x4022006c ;
#mww_ll 0 0x40220068 0x00000001;
#after 100;
#mdw_ll 0 0x4022007c ;
#mdw_ll 0 0x4022006c

#shutdown








exit
