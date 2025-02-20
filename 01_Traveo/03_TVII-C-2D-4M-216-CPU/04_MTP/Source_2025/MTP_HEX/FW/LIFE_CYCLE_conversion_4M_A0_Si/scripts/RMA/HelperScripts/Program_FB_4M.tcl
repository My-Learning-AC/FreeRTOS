#source [find interface/cmsis-dap.cfg]
 source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_c2d_4m.cfg]

targets traveo2_c2d_4m.cpu.cm0
adapter_khz 200
traveo2 sflash_restrictions 3
init
reset init
halt

puts "Program FlashBoot"
program flashboot_tviic2d4m_a0_psvp_3.1.0.442.hex
flash rmw 0x17000004 041C0017


puts "PSVP doesn't support OTP. Patching TOC1..."
flash rmw 0x1700782C 00200017


shutdown
