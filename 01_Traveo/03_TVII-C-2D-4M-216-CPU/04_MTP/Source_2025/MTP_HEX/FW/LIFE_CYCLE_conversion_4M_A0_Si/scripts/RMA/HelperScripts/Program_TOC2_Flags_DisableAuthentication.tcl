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



puts "\nProgramming TOC2_FLags->APP_AUTH_CTL = 1 to disable app authentication :"
flash rmw 0x17007DF8 C2020000

shutdown
