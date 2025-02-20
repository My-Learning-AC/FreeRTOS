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

puts "Program FlashBoot"
program flashboot_tviibe2m_a2_3.1.0.512.hex



shutdown
