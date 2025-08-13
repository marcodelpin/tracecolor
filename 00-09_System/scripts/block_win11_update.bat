@echo off
echo BLOCCA AGGIORNAMENTO WINDOWS 11 23H2 (KB5063875)
echo ==============================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Esegui come Amministratore!
    pause
    exit /b 1
)

echo Bloccando l'aggiornamento Windows 11 23H2...

REM Add registry key to block the update
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v ExcludeWUDriversInQualityUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v DoNotConnectToWindowsUpdateInternetLocations /t REG_DWORD /d 1 /f

REM Clear update cache and restart services  
net stop wuauserv
rd /s /q "C:\Windows\SoftwareDistribution\Download" 2>nul
net start wuauserv

echo.
echo Aggiornamento 23H2 bloccato!
echo Il tuo Windows 10 continuer\u00e0 a ricevere aggiornamenti di sicurezza
echo ma non verr\u00e0 pi\u00f9 proposto l'upgrade a Windows 11.
echo.

pause