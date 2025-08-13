@echo off
echo TENTATIVO AGGIORNAMENTO WINDOWS 11 CON SPAZIO SUFFICIENTE
echo ========================================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Esegui come Amministratore!
    pause
    exit /b 1
)

echo Spazio disco attuale:
wmic logicaldisk where "caption='C:'" get size,freespace,caption
echo.

echo Resettando componenti Windows Update...
echo.

echo 1. Fermando servizi Windows Update...
net stop wuauserv
net stop cryptSvc  
net stop bits
net stop msiserver

echo.
echo 2. Pulendo cache download corrotta...
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 catroot2.old

echo.
echo 3. Riavviando servizi...
net start cryptSvc
net start bits
net start msiserver  
net start wuauserv

echo.
echo 4. Verificando aggiornamenti disponibili...
powershell -Command "Get-WindowsUpdate" 2>nul

echo.
echo ==========================================
echo PRONTO PER TENTARE L'AGGIORNAMENTO
echo ==========================================
echo.
echo Ora puoi:
echo 1. Andare in Impostazioni > Aggiornamento e sicurezza
echo 2. Cliccare "Verifica disponibilita aggiornamenti"
echo 3. L'aggiornamento Windows 11 23H2 dovrebbe installarsi correttamente
echo.
echo Con 113 GB liberi, lo spazio non dovrebbe più essere un problema.
echo.

choice /C YN /M "Aprire automaticamente Windows Update"
if %errorlevel%==1 (
    echo Aprendo Windows Update...
    start ms-settings:windowsupdate
)

echo.
echo NOTA: Se l'aggiornamento fallisce ancora, usa gli script
echo per bloccarlo definitivamente.
echo.
pause