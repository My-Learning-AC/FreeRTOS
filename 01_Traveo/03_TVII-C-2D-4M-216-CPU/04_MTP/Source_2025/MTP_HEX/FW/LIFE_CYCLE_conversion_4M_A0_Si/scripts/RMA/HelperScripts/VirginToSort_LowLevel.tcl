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
mdw_ll 0 0x4022006c
mdw_ll 0 0x40220060 ;
mww_ll 0 0x40220060 0x80000f02;
after 10;
mww_ll 0 0x4022006c 0x10000001;
mdw_ll 0 0x4022006c ;
mww_ll 0 0x40220068 0x00000001;
after 100;
mdw_ll 0 0x4022007c ;
mdw_ll 0 0x4022006c

#shutdown








exit
