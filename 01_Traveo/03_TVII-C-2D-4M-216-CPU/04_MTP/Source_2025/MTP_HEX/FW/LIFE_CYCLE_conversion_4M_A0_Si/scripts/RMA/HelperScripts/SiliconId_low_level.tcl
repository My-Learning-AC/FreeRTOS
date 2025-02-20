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

mdw_ll 0 0x4022000C
mdw_ll 0 0x4022002C
mdw_ll 0 0x4022004C
mdw_ll 0 0x4022006C

# Now you can access memory via SYSAP :
puts "Read IPC DATA"
mdw_ll 0 0x40220010
mdw_ll 0 0x4022000C



mww_ll 0 0x40220010 0x0
mdw_ll 0 0x40220010

puts "IPC Acquire "
mdw_ll 0 0x40220040
mww_ll 0 0x40220040 0x80000f03
mdw_ll 0 0x40220040

puts "API Parameters into IPC3 DATA0"
mww_ll 0 0x4022004c 0x00000101
mdw_ll 0 0x4022004c 
puts "Notify"
mww_ll 0 0x40220048 0x00000001


puts "Wait for IPC Release"
after 100
mdw_ll 0 0x4022005c 
mdw_ll 0 0x4022005c
mdw_ll 0 0x4022005c
mdw_ll 0 0x4022005c
mdw_ll 0 0x4022005c
mdw_ll 0 0x4022005c


puts "Read IPC DATA"
mdw_ll 0 0x4022004c




exit
