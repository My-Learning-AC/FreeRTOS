source [find interface/cmsis-dap.cfg]
# source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_6m.cfg]
#source [find interface/kitprog3.cfg]
#transport select swd
#source [find target/traveo2_6m.cfg]
targets traveo2_6m.cpu.cm0
adapter_khz 200
traveo2_8m allow_unsafe_sflash on
init
reset init
reset run

resume
shutdown