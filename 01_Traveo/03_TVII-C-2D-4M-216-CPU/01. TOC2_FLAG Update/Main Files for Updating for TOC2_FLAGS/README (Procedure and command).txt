Steps for the updating of the TOC2_FLAG - 

1. Extract the TVII-C2D-4M zipped file
2. Copy the extracted file and paste it into Windows C:
3. See the all .tcl files on -   C:\TVII-C-2D-4M\DAP\scripts\HelperScripts\UpdateTOC2.tcl
4. If needed then make some changes in UpdateTOC2.tcl file
5. Go to C:\TVII-C-2D-4M\DAP\scripts and open the command prompt by typing 'cmd' on the path
6. Then copy the below command and run it into command prompt



..\bin\openocd.exe -f HelperScripts\UpdateTOC2.tcl            // For accessing the UpdateTOC2.tcl file (This is the right one for updating the TOC2_FLAG)

..\bin\openocd.exe -f HelperScripts\UpdateSflashRow.tcl       // For accessing the UpdateSflashRow.tcl file





..\bin\openocd.exe -f HelperScripts\ReadSflash.tcl


..\bin\openocd.exe -f HelperScripts\BasicTest.tcl



..\bin\openocd.exe -f CQ_SCRIPTS\mxs40srom_func_108_vn.tcl >log18.txt


..\bin\openocd.exe -f HelperScripts\UpdateTOC2.tcl >log18.txt