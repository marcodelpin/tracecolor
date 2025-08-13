@echo off
echo Opera Registry Permission Fix
echo =============================
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run this script as Administrator!
    pause
    exit /b 1
)

echo Stopping Windows Explorer to release locks...
taskkill /f /im explorer.exe
timeout /t 2 /nobreak >nul

echo.
echo Attempting to fix permissions via registry...

REM Reset permissions using SYSTEM account
psexec -i -s -accepteula cmd.exe /c "takeown /f \"%APPDATA%\Opera Software\" /r /d y & icacls \"%APPDATA%\Opera Software\" /reset /t /c /q" 2>nul

if not exist "%APPDATA%\Opera Software" (
    echo SUCCESS: Folder removed!
) else (
    echo Trying to rename with SYSTEM privileges...
    psexec -i -s -accepteula cmd.exe /c "move /y \"%APPDATA%\Opera Software\" \"%APPDATA%\Opera_Broken_%random%\"" 2>nul
)

echo.
echo Restarting Explorer...
start explorer.exe

echo.
echo Check if Opera starts now. If not, reboot is required.
pause