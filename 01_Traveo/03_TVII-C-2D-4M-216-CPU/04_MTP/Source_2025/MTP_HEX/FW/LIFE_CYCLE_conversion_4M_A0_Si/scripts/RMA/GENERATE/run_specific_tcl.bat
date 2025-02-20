set OPEN_OCD="C:/CypressAutoFlashUtility/bin/openocd.exe"
set OCD_SCRIPTS_PATH="C:/CypressAutoFlashUtility/scripts"

%OPEN_OCD% -s %OCD_SCRIPTS_PATH% -f %1 %2 %3 %4
