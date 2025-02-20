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



puts "\nProgramming FLL_CTL->FLL_OFF = 1 to turn off FLL at the end of ROM boot:"
#flash rmw 0x1700000A 01
flash rmw 0x17001a00 00000000
shutdown
