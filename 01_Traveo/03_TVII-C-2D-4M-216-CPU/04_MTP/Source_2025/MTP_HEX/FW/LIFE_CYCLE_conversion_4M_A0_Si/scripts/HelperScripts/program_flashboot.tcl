source [find interface/cmsis-dap.cfg]
# source [find interface/jlink.cfg]
transport select swd
source [find target/traveo2_6m.cfg]
targets traveo2_6m.cpu.cm0

adapter_khz 200
init
reset init

traveo2 sflash_restrictions 3


puts "Disable SysCall Patches"
flash rmw 0x17000004 F0F0F0F0

puts "Program FlashBoot"
program flashboot_tviic2d4m_a0_psvp_3.1.0.438.hex

puts "Enable SysCallPatches at new address"
flash rmw 0x17000004 041C0017

puts "Add SysCallPatches to TOC1"
flash rmw 0x17007834 001C0017

puts "Update Number of HASH objects in TOC1"
flash rmw 0x17007810 09000000

puts "Update TOC1 size"
flash rmw 0x17007800 38000000


puts "3k RSA mode"
flash rmw 0x170001fc 08

puts "Boottime mode"
flash rmw 0x170001fc 02 

puts "PSVP doesn't support OTP. Patching TOC1..."
flash rmw 0x1700782C 00060017

reset run

shutdown
