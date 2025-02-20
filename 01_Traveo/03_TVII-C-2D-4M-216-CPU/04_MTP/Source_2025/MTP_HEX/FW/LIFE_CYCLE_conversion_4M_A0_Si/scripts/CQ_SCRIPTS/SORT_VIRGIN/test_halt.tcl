#source [find interface/cmsis-dap.cfg]
set ENABLE_ACQUIRE 0
 source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_8m.cfg]

targets traveo2_8m.cpu.cm0
adapter_khz 200
traveo2 sflash_restrictions 3
init
reset run
halt







shutdown