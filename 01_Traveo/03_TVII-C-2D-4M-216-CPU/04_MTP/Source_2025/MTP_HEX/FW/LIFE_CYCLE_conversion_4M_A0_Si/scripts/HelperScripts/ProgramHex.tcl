# ####################################################################################################
# This script executes programming of the required hexfile
# Author: H ANKUR SHENOY
# Tested on PSVP
# ####################################################################################################
#source [find interface/cmsis-dap.cfg]
#transport select swd
##source [find target/psoc6.cfg]
#source [find target/traveo2.cfg]
##source [find SROM_Defines_P6.tcl]
##source [find utility_srom.tcl]
##source [find HelperScripts/CustomFunctions.tcl]
##source [find sflash_dat.tcl]
##source [find srom_dat.tcl]

source [find interface/cmsis-dap.cfg]
# source [find interface/kitprog3.cfg]
transport select swd
source [find target/traveo2_6m.cfg]

targets traveo2_6m.cpu.cm0
adapter_khz 200
traveo2 sflash_restrictions 3
init
reset init
halt

puts "\nProgramming Secure application:"
program cm0plus.hex

shutdown