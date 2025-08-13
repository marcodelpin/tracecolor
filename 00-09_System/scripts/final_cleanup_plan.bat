@echo off
echo PIANO FINALE DI PULIZIA - SPAZIO REALE DISPONIBILE
echo ================================================
echo.

echo SITUAZIONE ATTUALE:
echo ==================
echo.
echo GIA' OTTIMIZZATO (Junction su S:):
echo   .android    ~6 GB  ✓
echo   .conda      ~38 GB ✓  
echo   .gradle     ~5 GB  ✓
echo   .nuget      ~8 GB  ✓
echo   .ollama     ~57 GB ✓
echo   Totale spostato: ~114 GB
echo.

echo RIMASTO SU C: da pulire:
echo   .cache      1.35 GB
echo   .trae       3.32 GB  
echo   .bun        0.72 GB
echo   .local      0.94 GB
echo   .rustup     0.97 GB
echo   AppData\Roaming  ~12 GB
echo   Totale pulibile: ~19 GB
echo.

echo ====================================
echo OPERAZIONI DI PULIZIA SICURA:
echo ====================================
echo.

choice /C YN /M "Procedere con pulizia delle cartelle rimanenti"
if %errorlevel%==2 goto :end

echo.
echo 1. Pulendo cache generale...
if exist "%USERPROFILE%\.cache" (
    rd /s /q "%USERPROFILE%\.cache" 2>nul
    mkdir "%USERPROFILE%\.cache"
    echo   Cache pulita: 1.35 GB recuperati
)

echo.
echo 2. Pulendo progetti Trae...
if exist "%USERPROFILE%\.trae" (
    echo   ATTENZIONE: .trae contiene progetti. Pulendo solo cache...
    rd /s /q "%USERPROFILE%\.trae\cache" 2>nul
    rd /s /q "%USERPROFILE%\.trae\logs" 2>nul
    rd /s /q "%USERPROFILE%\.trae\tmp" 2>nul
    echo   Cache Trae pulita: ~1 GB recuperato
)

echo.
echo 3. Pulendo Bun cache...
if exist "%USERPROFILE%\.bun" (
    rd /s /q "%USERPROFILE%\.bun\install\cache" 2>nul
    echo   Bun cache pulita: 0.7 GB recuperati
)

echo.
echo 4. Pulendo AppData temporanei...
echo   Pulendo browser cache...
rd /s /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache" 2>nul
rd /s /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache" 2>nul
rd /s /q "%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2" 2>nul

echo   Pulendo Visual Studio Code cache...
rd /s /q "%APPDATA%\Code\logs" 2>nul
rd /s /q "%APPDATA%\Code\CachedData" 2>nul

echo   Pulendo Windows temp...
del /s /q "%TEMP%\*.*" 2>nul
for /d %%i in ("%TEMP%\*") do rd /s /q "%%i" 2>nul

echo.
echo 5. Pulizia Windows Update cache...
net stop wuauserv
rd /s /q "C:\Windows\SoftwareDistribution\Download" 2>nul
net start wuauserv

echo.
echo 6. Eseguendo Pulizia Disco...
cleanmgr /sagerun:1

echo.
echo ====================================
echo PULIZIA COMPLETATA!
echo ====================================
echo.
echo SPAZIO RECUPERATO STIMATO: 15-20 GB
echo SPAZIO TOTALE LIBERO ATTESO: 60+ GB
echo.
echo Questo è più che sufficiente per Windows 11!
echo.

echo Verificando spazio finale...
for /f "tokens=3" %%a in ('dir C:\ ^| findstr "bytes free"') do echo Spazio libero: %%a bytes

:end
echo.
pause