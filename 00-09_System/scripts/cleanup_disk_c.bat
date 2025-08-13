@echo off
echo PULIZIA AUTOMATICA DISCO C:
echo ============================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Esegui come Amministratore!
    pause
    exit /b 1
)

echo Spazio libero prima della pulizia:
dir C:\ | findstr "bytes free"
echo.

echo 1. Pulendo file temporanei Windows...
del /s /q "C:\Windows\Temp\*.*" 2>nul
for /d %%i in ("C:\Windows\Temp\*") do rd /s /q "%%i" 2>nul

echo 2. Pulendo file temporanei utente...
del /s /q "%TEMP%\*.*" 2>nul
for /d %%i in ("%TEMP%\*") do rd /s /q "%%i" 2>nul

echo 3. Pulendo cache Windows Update...
net stop wuauserv
del /s /q "C:\Windows\SoftwareDistribution\Download\*.*" 2>nul
for /d %%i in ("C:\Windows\SoftwareDistribution\Download\*") do rd /s /q "%%i" 2>nul
net start wuauserv

echo 4. Pulendo log di Windows...
del /s /q "C:\Windows\Logs\*.*" 2>nul
del /s /q "C:\Windows\Panther\*.*" 2>nul

echo 5. Pulendo Cestino...
rd /s /q "C:\$Recycle.Bin" 2>nul

echo 6. Pulendo cache browser...
del /s /q "%LOCALAPPDATA%\Microsoft\Windows\INetCache\*.*" 2>nul
del /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" 2>nul
del /s /q "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2\*.*" 2>nul

echo 7. Pulendo file di crash dump...
del /q "C:\Windows\MEMORY.DMP" 2>nul
del /q "C:\Windows\Minidump\*.*" 2>nul

echo 8. Avviando Pulizia Disco automatica...
cleanmgr /sagerun:1

echo.
echo Spazio libero dopo la pulizia:
dir C:\ | findstr "bytes free"
echo.
echo Pulizia completata!
pause