set OPEN_OCD="..\bin\openocd.exe"

set CUR_YYYY=%date:~10,4%
set CUR_MM=%date:~4,2%
set CUR_DD=%date:~7,2%

set CUR_HH=%time:~0,2%
if %CUR_HH% lss 10 (set CUR_HH=0%time:~1,1%)

set CUR_NN=%time:~3,2%
set CUR_SS=%time:~6,2%
set CUR_MS=%time:~9,2%
set SUBFILENAME="%CUR_YYYY%_%CUR_MM%_%CUR_DD%-%CUR_HH%_%CUR_NN%_%CUR_SS%"
set LOGPATH="Log_LifeCycleConversion\TVIIBH8M_B0\SECURE_DEAD_%SUBFILENAME%"

if not exist "%LOGPATH%" mkdir "%LOGPATH%"

%OPEN_OCD% -f HelperScripts\ReadSflash.tcl > %LOGPATH%\1_Sflash.txt
%OPEN_OCD% -f HelperScripts\Program_FB_8M_B0_Si.tcl >%LOGPATH%\2_Program_FB_8M_B0_Si.txt
%OPEN_OCD% -f HelperScripts\Update_PGM_RD_Delay.tcl > %LOGPATH%\2A_PreReq_1_Update_PGM_RD_Delay.txt
@rem %OPEN_OCD% -f HelperScripts\UpdateNAR_NDAR_For_SD_LifeCycle.tcl >%LOGPATH%\2B_PreReq_2_UpdateNAR_NDAR.txt
%OPEN_OCD% -f HelperScripts\UpdateTOC2_DisableAuth_ClkCfg3.tcl > %LOGPATH%\2C_PreReq_3_UpdateTOC2_DisableAuth_ClkCfg3.txt
%OPEN_OCD% -f HelperScripts\UpdateUID.tcl > %LOGPATH%\2D_PreReq_4_UpdateUID.txt
@rem %OPEN_OCD% -f CQ_SCRIPTS\Enable_SkipHash_FllCtl_NarCtl.tcl > %LOGPATH%\1B_Enable_SkipHash_FllCtl_NarCtl.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\3_BasicTest.txt
%OPEN_OCD% -f HelperScripts\ReadSflash.tcl > %LOGPATH%\4_Sflash.txt
%OPEN_OCD% -f HelperScripts\VirginToSort_ApplyTrimsFromSflash.tcl > %LOGPATH%\5_ApplyTrimsFromSflash.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\6_BasicTest.txt
%OPEN_OCD% -f HelperScripts\SortToProvisioned.tcl > %LOGPATH%\7_SortToProvisioned.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\8_BasicTest.txt
%OPEN_OCD% -f HelperScripts\ReadSflash.tcl > %LOGPATH%\9_Sflash.txt
%OPEN_OCD% -f HelperScripts\ProvisionedToNormalProvisioned.tcl > %LOGPATH%\10_ProvToNormP.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\11_BasicTest.txt
%OPEN_OCD% -f HelperScripts\NormalProvisionedToSecure.tcl > %LOGPATH%\12_NormalProvisionedToSecure.txt
%OPEN_OCD% -f HelperScripts\BasicTest.tcl > %LOGPATH%\13_BasicTest.txt
