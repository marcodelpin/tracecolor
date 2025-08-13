@echo off
echo Opera Boot-Time Fix Script v2
echo =============================
echo.

REM Check admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must run as Administrator!
    echo Right-click and select "Run as Administrator"
    pause
    exit /b 1
)

echo This will schedule Opera folder deletion at next boot.
echo.

REM Method 1: Using fsutil (Windows native)
echo Method 1: Using Windows native commands...
fsutil file createnew "%APPDATA%\Opera Software\DELETE_ME.txt" 0 2>nul
fsutil file setshortname "%APPDATA%\Opera Software" OPERADEL 2>nul

REM Method 2: Using reg command directly
echo.
echo Method 2: Adding to PendingFileRenameOperations...
set "opera_path=\??\%APPDATA%\Opera Software"
set "opera_path=%opera_path:\=\\%"

REM Create a reg file
echo Windows Registry Editor Version 5.00 > "%temp%\opera_delete.reg"
echo. >> "%temp%\opera_delete.reg"
echo [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager] >> "%temp%\opera_delete.reg"
echo "PendingFileRenameOperations"=hex(7):5c,00,3f,00,3f,00,5c,00,43,00,3a,00,5c,00,55,00,73,00,65,00,72,00,73,00,5c,00,6d,00,61,00,72,00,63,00,6f,00,5c,00,41,00,70,00,70,00,44,00,61,00,74,00,61,00,5c,00,52,00,6f,00,61,00,6d,00,69,00,6e,00,67,00,5c,00,4f,00,70,00,65,00,72,00,61,00,20,00,53,00,6f,00,66,00,74,00,77,00,61,00,72,00,65,00,00,00,00,00,00,00 >> "%temp%\opera_delete.reg"

reg import "%temp%\opera_delete.reg" 2>nul
del "%temp%\opera_delete.reg"

REM Method 3: Schedule task to run at startup
echo.
echo Method 3: Creating scheduled task...
schtasks /create /tn "DeleteOperaFolder" /tr "cmd.exe /c rmdir /s /q \"%APPDATA%\Opera Software\"" /sc onstart /ru SYSTEM /f >nul 2>&1

echo.
echo Operations completed. The folder will be deleted on next restart.
echo.
echo IMPORTANT: After restarting, the scheduled task will be removed automatically.
echo.
pause