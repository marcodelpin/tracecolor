@echo off
echo Renaming Opera folder to backup...

REM Close any Opera processes
taskkill /f /im opera.exe 2>nul
taskkill /f /im opera_crashreporter.exe 2>nul
taskkill /f /im opera_autoupdate.exe 2>nul

REM Rename the folder
if exist "%APPDATA%\Opera Software" (
    ren "%APPDATA%\Opera Software" "Opera Software_backup_%date:~0,2%-%date:~3,2%-%date:~6,4%"
    echo.
    echo Opera folder renamed. Opera will create a new clean profile folder.
    echo Your old data is in the backup folder.
) else (
    echo Opera folder not found!
)

pause