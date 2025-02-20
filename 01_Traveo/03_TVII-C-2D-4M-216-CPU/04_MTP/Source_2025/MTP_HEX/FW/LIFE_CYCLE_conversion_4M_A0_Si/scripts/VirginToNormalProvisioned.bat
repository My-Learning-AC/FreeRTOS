set OPEN_OCD="..\bin\openocd.exe"             
set BITFILE="B0\srom28"
set LOGPATH="4M_Silicon\R01_SortToNormalP"

if not exist "%LOGPATH%" mkdir "%LOGPATH%"
%OPEN_OCD% -f HelperScripts\ReadSflash.tcl > %LOGPATH%\1_Sflash.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\2_BasicTest.txt
@rem %OPEN_OCD% -f HelperScripts\Program_FB_4M.tcl > %LOGPATH%\2A_UpdateFB.txt
%OPEN_OCD% -f HelperScripts\VirginToSort_ApplyTrimsFromSflash.tcl > %LOGPATH%\3_ApplyTrimsFromSflash.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\4_BasicTest.txt
%OPEN_OCD% -f HelperScripts\SortToProvisioned.tcl > %LOGPATH%\5_SortToProvisioned.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\6_BasicTest.txt
%OPEN_OCD% -f HelperScripts\ReadSflash.tcl > %LOGPATH%\6C_Sflash.txt
%OPEN_OCD% -f HelperScripts\ProvisionedToNormalProvisioned.tcl > %LOGPATH%\7_ProvToNormP.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\8_BasicTest.txt
