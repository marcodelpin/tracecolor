@echo off
echo SPOSTAMENTO CARTELLE SU S: CON JUNCTION
echo =======================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Esegui come Amministratore!
    pause
    exit /b 1
)

echo ATTENZIONE: Questo script spostarà le tue cartelle personali su S:
echo usando junction points. Le cartelle rimarranno accessibili
echo dalla stessa posizione ma i dati saranno fisicamente su S:
echo.

set "TARGET_ROOT=S:\Users\%USERNAME%"
echo Cartelle di destinazione: %TARGET_ROOT%
echo.

echo Cartelle da spostare:
echo 1. Documenti     (~5-10 GB tipici)
echo 2. Download      (~2-5 GB tipici)
echo 3. Immagini      (~1-3 GB tipici)
echo 4. Video         (~0-10 GB variabile)
echo 5. Musica        (~0-5 GB variabile)
echo 6. Desktop       (~0.1-1 GB)
echo.

choice /C YN /M "Procedere con lo spostamento"
if %errorlevel%==2 goto :end

echo.
echo Creando struttura su S:...
mkdir "%TARGET_ROOT%" 2>nul
mkdir "%TARGET_ROOT%\Documents" 2>nul
mkdir "%TARGET_ROOT%\Downloads" 2>nul
mkdir "%TARGET_ROOT%\Pictures" 2>nul
mkdir "%TARGET_ROOT%\Videos" 2>nul
mkdir "%TARGET_ROOT%\Music" 2>nul
mkdir "%TARGET_ROOT%\Desktop" 2>nul

echo.
echo Spostando Documenti...
if exist "%USERPROFILE%\Documents" (
    echo Copiando contenuto di Documents...
    robocopy "%USERPROFILE%\Documents" "%TARGET_ROOT%\Documents" /E /MOVE /R:1 /W:1
    rmdir "%USERPROFILE%\Documents" /s /q 2>nul
    mklink /J "%USERPROFILE%\Documents" "%TARGET_ROOT%\Documents"
    echo Junction creato per Documents
)

echo.
echo Spostando Download...
if exist "%USERPROFILE%\Downloads" (
    echo Copiando contenuto di Downloads...
    robocopy "%USERPROFILE%\Downloads" "%TARGET_ROOT%\Downloads" /E /MOVE /R:1 /W:1
    rmdir "%USERPROFILE%\Downloads" /s /q 2>nul
    mklink /J "%USERPROFILE%\Downloads" "%TARGET_ROOT%\Downloads"
    echo Junction creato per Downloads
)

echo.
echo Spostando Immagini...
if exist "%USERPROFILE%\Pictures" (
    echo Copiando contenuto di Pictures...
    robocopy "%USERPROFILE%\Pictures" "%TARGET_ROOT%\Pictures" /E /MOVE /R:1 /W:1
    rmdir "%USERPROFILE%\Pictures" /s /q 2>nul
    mklink /J "%USERPROFILE%\Pictures" "%TARGET_ROOT%\Pictures"
    echo Junction creato per Pictures
)

echo.
echo Spostando Video...
if exist "%USERPROFILE%\Videos" (
    echo Copiando contenuto di Videos...
    robocopy "%USERPROFILE%\Videos" "%TARGET_ROOT%\Videos" /E /MOVE /R:1 /W:1
    rmdir "%USERPROFILE%\Videos" /s /q 2>nul
    mklink /J "%USERPROFILE%\Videos" "%TARGET_ROOT%\Videos"
    echo Junction creato per Videos
)

echo.
echo Spostando Musica...
if exist "%USERPROFILE%\Music" (
    echo Copiando contenuto di Music...
    robocopy "%USERPROFILE%\Music" "%TARGET_ROOT%\Music" /E /MOVE /R:1 /W:1
    rmdir "%USERPROFILE%\Music" /s /q 2>nul
    mklink /J "%USERPROFILE%\Music" "%TARGET_ROOT%\Music"
    echo Junction creato per Music
)

echo.
echo Spostando Desktop...
if exist "%USERPROFILE%\Desktop" (
    echo Copiando contenuto di Desktop...
    robocopy "%USERPROFILE%\Desktop" "%TARGET_ROOT%\Desktop" /E /MOVE /R:1 /W:1
    rmdir "%USERPROFILE%\Desktop" /s /q 2>nul
    mklink /J "%USERPROFILE%\Desktop" "%TARGET_ROOT%\Desktop"
    echo Junction creato per Desktop
)

echo.
echo =======================================
echo OPERAZIONE COMPLETATA!
echo =======================================
echo.
echo Le tue cartelle personali sono ora fisicamente su S:
echo ma accessibili dalla stessa posizione di sempre.
echo.
echo Per verificare:
echo - Apri Esplora File e vai alle tue cartelle
echo - Dovrebbero funzionare normalmente
echo - I file sono fisicamente in: %TARGET_ROOT%
echo.

:end
pause