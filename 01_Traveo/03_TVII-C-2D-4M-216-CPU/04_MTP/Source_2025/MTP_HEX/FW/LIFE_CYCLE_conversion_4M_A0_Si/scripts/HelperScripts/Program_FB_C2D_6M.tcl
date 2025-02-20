#source [find interface/cmsis-dap.cfg]
 source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_6m.cfg]

targets traveo2_6m.cpu.cm0
adapter_khz 200
traveo2 sflash_restrictions 3
init
reset init
halt

puts "Disable syscall Patches"
flash rmw 0x17000004 F0F0F0F0

puts "Program FlashBoot"
program flashboot_tviic2d6m_a0_3.1.0.521.hex

puts "Enable Syscall Patches at new Address"
flash rmw 0x17000004 041C0017

puts "Add Syscall Patches to TOC1"
flash rmw 0x17007834 001C0017

puts "Update number of HASH objects in TOC1"
flash rmw 0x17007810 09000000

puts "Update Toc1 size"
flash rmw 0x17007800 38000000

shutdown
