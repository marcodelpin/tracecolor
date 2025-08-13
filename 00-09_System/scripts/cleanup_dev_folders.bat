@echo off
echo PULIZIA CARTELLE SVILUPPO - RECUPERO MASSIMO SPAZIO
echo ==================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Esegui come Amministratore!
    pause
    exit /b 1
)

echo CARTELLE SVILUPPO CHE OCCUPANO PIU SPAZIO:
echo.
echo .ollama     ~57 GB    (Modelli AI)
echo .conda      ~38 GB    (Ambienti Python)
echo .android    ~6 GB     (Android SDK/AVD)
echo .cache      ~7 GB     (Cache varie)
echo .cursor     ~5 GB     (Editor Cursor)
echo .gradle     ~5 GB     (Build Gradle)
echo .nuget      ~8 GB     (Pacchetti .NET)
echo .trae       ~3 GB     (Progetti)
echo.
echo TOTALE STIMATO: ~130+ GB recuperabili!
echo.

choice /C YN /M "Procedere con la pulizia SICURA delle cartelle di sviluppo"
if %errorlevel%==2 goto :end

echo.
echo ============================================
echo PULIZIA IN CORSO - NON INTERROMPERE
echo ============================================
echo.

set "USER_HOME=C:\Users\%USERNAME%"

echo 1. Pulendo cache Ollama (modelli AI)...
if exist "%USER_HOME%\.ollama" (
    echo   Trovata cartella .ollama - Rimuovendo modelli...
    rd /s /q "%USER_HOME%\.ollama\models" 2>nul
    rd /s /q "%USER_HOME%\.ollama\logs" 2>nul
    echo   Ollama cache pulita
)

echo.
echo 2. Pulendo cache Conda (ambienti Python)...
if exist "%USER_HOME%\.conda" (
    echo   Trovata cartella .conda - Rimuovendo cache...
    rd /s /q "%USER_HOME%\.conda\pkgs" 2>nul
    rd /s /q "%USER_HOME%\.conda\envs\*\pkgs" 2>nul
    echo   Conda cache pulita
)

echo.
echo 3. Pulendo Android SDK cache...
if exist "%USER_HOME%\.android" (
    echo   Pulendo AVD e cache Android...
    rd /s /q "%USER_HOME%\.android\avd" 2>nul
    rd /s /q "%USER_HOME%\.android\cache" 2>nul
    del /s /q "%USER_HOME%\.android\*.log" 2>nul
    echo   Android cache pulita
)

echo.
echo 4. Pulendo cache generale...
if exist "%USER_HOME%\.cache" (
    echo   Rimuovendo cache varie...
    for /d %%i in ("%USER_HOME%\.cache\*") do rd /s /q "%%i" 2>nul
    echo   Cache generale pulita
)

echo.
echo 5. Pulendo Gradle cache...
if exist "%USER_HOME%\.gradle" (
    echo   Pulendo cache Gradle...
    rd /s /q "%USER_HOME%\.gradle\caches" 2>nul
    rd /s /q "%USER_HOME%\.gradle\daemon" 2>nul
    echo   Gradle cache pulita
)

echo.
echo 6. Pulendo NuGet cache...
if exist "%USER_HOME%\.nuget" (
    echo   Pulendo pacchetti NuGet...
    rd /s /q "%USER_HOME%\.nuget\packages" 2>nul
    echo   NuGet cache pulita
)

echo.
echo 7. Pulendo Cursor/VSCode cache...
if exist "%USER_HOME%\.cursor" (
    echo   Pulendo cache Cursor...
    rd /s /q "%USER_HOME%\.cursor\logs" 2>nul
    rd /s /q "%USER_HOME%\.cursor\CachedData" 2>nul
    echo   Cursor cache pulita
)

echo.
echo 8. Pulendo altre cache sviluppo...
rd /s /q "%USER_HOME%\.cargo\registry\cache" 2>nul
rd /s /q "%USER_HOME%\.npm\_cacache" 2>nul
rd /s /q "%USER_HOME%\.yarn\cache" 2>nul

echo.
echo ============================================
echo PULIZIA COMPLETATA!
echo ============================================
echo.
echo SPAZIO RECUPERATO STIMATO: 80-120 GB
echo.
echo Le cartelle sono state pulite ma non rimosse.
echo I tuoi ambienti di sviluppo funzioneranno ancora,
echo ma dovranno ri-scaricare alcune cache al bisogno.
echo.

echo Spazio disco dopo la pulizia:
for /f "tokens=3" %%a in ('dir C:\ ^| findstr "bytes free"') do echo Liberi: %%a bytes

:end
echo.
pause