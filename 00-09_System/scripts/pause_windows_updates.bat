@echo off
echo Pause Windows Updates
echo ====================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Run as Administrator!
    pause
    exit /b 1
)

echo Choose an option:
echo 1. Pause updates for 35 days
echo 2. Disable Windows Update service completely
echo 3. Clear failed update and restart
echo.

choice /C 123 /M "Select option"

if %errorlevel%==1 goto :pause35
if %errorlevel%==2 goto :disable
if %errorlevel%==3 goto :clear

:pause35
echo.
echo Pausing updates for 35 days...
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesStartTime /t REG_SZ /d "%DATE%" /f
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesStartTime /t REG_SZ /d "%DATE%" /f
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseFeatureUpdatesEndTime /t REG_SZ /d "%DATE:~0,2%-%DATE:~3,2%-2025" /f
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v PauseQualityUpdatesEndTime /t REG_SZ /d "%DATE:~0,2%-%DATE:~3,2%-2025" /f
echo Updates paused for 35 days.
goto :end

:disable
echo.
echo Disabling Windows Update service...
sc config wuauserv start= disabled
net stop wuauserv
echo Windows Update service disabled.
echo To re-enable: sc config wuauserv start= auto
goto :end

:clear
echo.
echo Clearing failed updates...
net stop wuauserv
del /q /s C:\Windows\SoftwareDistribution\Download\*.*
net start wuauserv
echo Update cache cleared.
goto :end

:end
echo.
echo Done!
pause