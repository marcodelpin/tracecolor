@echo off
echo [INFO] Rimozione forzata driver Parsec...

echo.
echo [STEP 1] Arresto servizio Parsec...
net stop "Parsec" 2>nul
if %errorlevel% equ 0 (
    echo [OK] Servizio Parsec arrestato
) else (
    echo [WARNING] Impossibile arrestare servizio Parsec
)

echo.
echo [STEP 2] Disabilitazione avvio automatico Parsec...
sc config "Parsec" start= disabled 2>nul
if %errorlevel% equ 0 (
    echo [OK] Avvio automatico Parsec disabilitato
) else (
    echo [WARNING] Impossibile modificare configurazione servizio
)

echo.
echo [STEP 3] Terminazione processi Parsec...
taskkill /f /im parsecd.exe 2>nul
if %errorlevel% equ 0 (
    echo [OK] Processi Parsec terminati
) else (
    echo [INFO] Nessun processo Parsec attivo
)

echo.
echo [STEP 4] Controllo installazione Parsec...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Parsec" 2>nul | findstr /i "Parsec"
if %errorlevel% equ 0 (
    echo [FOUND] Installazione Parsec trovata nel registry
) else (
    echo [INFO] Parsec non trovato nel registry programmi
)

echo.
echo [STEP 5] Verifica stato driver...
pnputil /enum-devices /class Display | findstr /i "Parsec"
pnputil /enum-devices /class USB | findstr /i "Parsec"

echo.
echo [INFO] Per completare la rimozione:
echo 1. Aprire "Installazione applicazioni" (appwiz.cpl)
echo 2. Cercare e disinstallare "Parsec"  
echo 3. Riavviare il sistema
echo 4. I suoni USB dovrebbero cessare
echo.
pause