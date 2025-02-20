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


puts "\nProgramming application which toggles 3 LED from 3:"
program ProgramLedToggleAllCores.hex

shutdown
