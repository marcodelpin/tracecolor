@echo off
echo Block Specific Windows Update
echo =============================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run as Administrator!
    pause
    exit /b 1
)

echo First, let's identify the problematic update.
echo.
echo Checking update history...
echo.
wmic qfe list brief /format:table | more

echo.
echo =====================================
echo Enter the KB number to block (e.g., KB5034441)
echo Or press Enter to see currently hidden updates
echo =====================================
set /p KB_NUMBER=KB Number: 

if "%KB_NUMBER%"=="" goto :show_hidden

echo.
echo Downloading Microsoft Show/Hide Update Tool...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'http://download.microsoft.com/download/f/2/2/f22d5fdb-59cd-4275-8c95-1be17bf70b21/wushowhide.diagcab' -OutFile '%TEMP%\wushowhide.diagcab'}"

if exist "%TEMP%\wushowhide.diagcab" (
    echo.
    echo Starting Show/Hide Updates tool...
    echo.
    echo INSTRUCTIONS:
    echo 1. Click "Next" in the troubleshooter
    echo 2. Select "Hide updates"
    echo 3. Check the box for %KB_NUMBER%
    echo 4. Click "Next" to hide the update
    echo.
    start "" "%TEMP%\wushowhide.diagcab"
) else (
    echo Failed to download tool. Using alternative method...
    goto :registry_method
)

goto :end

:show_hidden
echo.
echo Checking for hidden updates...
powershell -Command "Get-WindowsUpdate -IsHidden"
echo.
pause
goto :end

:registry_method
echo.
echo Blocking %KB_NUMBER% via registry...

REM Create registry key to block the update
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\DriverExclude" /v "%KB_NUMBER%" /t REG_SZ /d "1" /f

echo.
echo Update %KB_NUMBER% has been blocked via registry.

:end
echo.
echo Additional options:
echo - To unblock: Run wushowhide.diagcab and select "Show hidden updates"
echo - To see all blocked updates: Run this script without entering a KB number
echo.
pause