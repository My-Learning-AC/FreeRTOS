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

# Now you can access memory via SYSAP :
puts "Acquire Check"
mww_ll 0 0x28000000 0x12345678
mdw_ll 0 0x28000000
mdw_ll 0 0x4022006C

#mdw_ll 1 0x28000000
#mdw_ll 1 0x4022006C
#
#mdw_ll 2 0x28000000
#mdw_ll 2 0x4022006C
#mdw_ll 3 0x28000000
#mdw_ll 3 0x4022006C

#shutdown


puts "API parameters"
mww_ll 0 0x28000404 0x00000014
mww_ll 0 0x28000408 0x120029f0
mww_ll 0 0x2800040c 0x01947fb4
mww_ll 0 0x28000410 0x02032439
mww_ll 0 0x28000414 0x00000000
mww_ll 0 0x28000418 0x2800041c
mww_ll 0 0x2800041c 0xf1d4ee8e
mww_ll 0 0x28000420 0xdc84f5e1
mww_ll 0 0x28000424 0x7e8af911
mww_ll 0 0x28000428 0xc92e5a00
mww_ll 0 0x2800042c 0xff8c4ffb
mww_ll 0 0x28000430 0xc1eef217
mww_ll 0 0x28000434 0xe06f900f
mww_ll 0 0x28000438 0xf19eb565
mww_ll 0 0x2800043c 0x28fb1869
mww_ll 0 0x28000440 0x237ebfb1
mww_ll 0 0x28000444 0x81bdccd5
mww_ll 0 0x28000448 0x3c2f0fdf
mww_ll 0 0x2800044c 0xf0227bbc
mww_ll 0 0x28000450 0xb9d31b03
mww_ll 0 0x28000454 0xf5175a29
mww_ll 0 0x28000458 0x5a8762ba
mww_ll 0 0x2800045c 0xfe3dfdae
mww_ll 0 0x28000460 0x5f7edd85
mww_ll 0 0x28000464 0xc2794c50
mww_ll 0 0x28000468 0x3fa179ca
mww_ll 0 0x2800046c 0x96c2b019
mww_ll 0 0x28000470 0x997cc569
mww_ll 0 0x28000474 0xbe7187fc
mww_ll 0 0x28000478 0x4cdcd34a
mww_ll 0 0x2800047c 0xbdfb8ac8
mww_ll 0 0x28000480 0xabdd1657
mww_ll 0 0x28000484 0x55123e4c
mww_ll 0 0x28000488 0xdcbe767f
mww_ll 0 0x2800048c 0x7e444e37
mww_ll 0 0x28000490 0xa6c39dbd
mww_ll 0 0x28000494 0xc5d87e00
mww_ll 0 0x28000498 0xbd3df680
mww_ll 0 0x2800049c 0x6dc9e3b2
mww_ll 0 0x280004a0 0xb1c40b04
mww_ll 0 0x280004a4 0xd19cb84f
mww_ll 0 0x280004a8 0x6ac38fe9
mww_ll 0 0x280004ac 0x4f146cd0
mww_ll 0 0x280004b0 0x16f0872c
mww_ll 0 0x280004b4 0xb32a6ef4
mww_ll 0 0x280004b8 0x25d165b7
mww_ll 0 0x280004bc 0xdcb3d813
mww_ll 0 0x280004c0 0x2da51e1c
mww_ll 0 0x280004c4 0x0e462c20
mww_ll 0 0x280004c8 0xeccf8de2
mww_ll 0 0x280004cc 0x08781545
mww_ll 0 0x280004d0 0x2289b3cb
mww_ll 0 0x280004d4 0x09de0b1d
mww_ll 0 0x280004d8 0x5545ff1b
mww_ll 0 0x280004dc 0x77752ea1
mww_ll 0 0x280004e0 0xa36a742d
mww_ll 0 0x280004e4 0xf8edf41e
mww_ll 0 0x280004e8 0x88200799
mww_ll 0 0x280004ec 0x82158490
mww_ll 0 0x280004f0 0x42d48d25
mww_ll 0 0x280004f4 0x2821a9b9
mww_ll 0 0x280004f8 0x83f18680
mww_ll 0 0x280004fc 0x0301c165
mww_ll 0 0x28000500 0xcdfa2d9d
mww_ll 0 0x28000504 0x2234e925
mww_ll 0 0x28000508 0x920b9326
mww_ll 0 0x2800050c 0xcc4597e5
mww_ll 0 0x28000510 0x8d265253
mww_ll 0 0x28000514 0x82875fd4
mww_ll 0 0x28000518 0x6d0991f6

mdw_ll 0 0x28000404
mdw_ll 0 0x28000408
mdw_ll 0 0x2800040c
mdw_ll 0 0x28000410
mdw_ll 0 0x28000414
mdw_ll 0 0x28000418
mdw_ll 0 0x2800041c
mdw_ll 0 0x28000420
mdw_ll 0 0x28000424
mdw_ll 0 0x28000428
mdw_ll 0 0x2800042c
mdw_ll 0 0x28000430
mdw_ll 0 0x28000434
mdw_ll 0 0x28000438
mdw_ll 0 0x2800043c
mdw_ll 0 0x28000440
mdw_ll 0 0x28000444
mdw_ll 0 0x28000448
mdw_ll 0 0x2800044c
mdw_ll 0 0x28000450
mdw_ll 0 0x28000454
mdw_ll 0 0x28000458
mdw_ll 0 0x2800045c
mdw_ll 0 0x28000460
mdw_ll 0 0x28000464
mdw_ll 0 0x28000468
mdw_ll 0 0x2800046c
mdw_ll 0 0x28000470
mdw_ll 0 0x28000474
mdw_ll 0 0x28000478
mdw_ll 0 0x2800047c
mdw_ll 0 0x28000480
mdw_ll 0 0x28000484
mdw_ll 0 0x28000488
mdw_ll 0 0x2800048c
mdw_ll 0 0x28000490
mdw_ll 0 0x28000494
mdw_ll 0 0x28000498
mdw_ll 0 0x2800049c
mdw_ll 0 0x280004a0
mdw_ll 0 0x280004a4
mdw_ll 0 0x280004a8
mdw_ll 0 0x280004ac
mdw_ll 0 0x280004b0
mdw_ll 0 0x280004b4
mdw_ll 0 0x280004b8
mdw_ll 0 0x280004bc
mdw_ll 0 0x280004c0
mdw_ll 0 0x280004c4
mdw_ll 0 0x280004c8
mdw_ll 0 0x280004cc
mdw_ll 0 0x280004d0
mdw_ll 0 0x280004d4
mdw_ll 0 0x280004d8
mdw_ll 0 0x280004dc
mdw_ll 0 0x280004e0
mdw_ll 0 0x280004e4
mdw_ll 0 0x280004e8
mdw_ll 0 0x280004ec
mdw_ll 0 0x280004f0
mdw_ll 0 0x280004f4
mdw_ll 0 0x280004f8
mdw_ll 0 0x280004fc
mdw_ll 0 0x28000500
mdw_ll 0 0x28000504
mdw_ll 0 0x28000508
mdw_ll 0 0x2800050c
mdw_ll 0 0x28000510
mdw_ll 0 0x28000514
mdw_ll 0 0x28000518


mww_ll 0 0x28000400 0x29000000
mdw_ll 0 0x28000400
puts "IPC Acquire "
mdw_ll 0 0x40220060
mww_ll 0 0x40220060 0x80000f03
mdw_ll 0 0x40220060

puts "SRAM SCRATCH into IPC3 DATA0"
mww_ll 0 0x4022006c 0x28000400
mdw_ll 0 0x4022006c 
puts "Notify"
mww_ll 0 0x40220068 0x00000001


puts "Wait for IPC Release"
after 100
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c 
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c
mdw_ll 0 0x4022007c

puts "Read IPC DATA"
mdw_ll 0 0x4022006c
mdw_ll 0 0x28000400

mdw_ll 0 0x402200EC


puts " SRAM location 0x28010000"
mdw_ll 0 0x28010000
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
