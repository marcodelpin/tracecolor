# Script per rimuovere driver Parsec problematici
Write-Host "[INFO] Rimozione driver Parsec problematici..."

# 1. Lista dispositivi Parsec
Write-Host "`n[STEP 1] Identificazione dispositivi Parsec:"
$ParsecDevices = Get-PnpDevice | Where-Object { $_.Name -match "Parsec|parsec" -or $_.HardwareID -match "parsec" }
if ($ParsecDevices) {
    Write-Host "[FOUND] Dispositivi Parsec trovati:"
    $ParsecDevices | Select-Object Name, Status, InstanceId | Format-Table
} else {
    Write-Host "[INFO] Nessun dispositivo Parsec PnP trovato"
}

# 2. Lista driver Parsec nel Device Manager
Write-Host "`n[STEP 2] Ricerca driver Parsec nel sistema:"
$ParsecDrivers = Get-WmiObject Win32_PnPEntity | Where-Object { 
    $_.Name -match "Parsec|parsec" -or 
    $_.DeviceID -match "parsec" -or
    $_.HardwareID -match "parsec"
}

if ($ParsecDrivers) {
    Write-Host "[FOUND] Driver Parsec trovati:"
    $ParsecDrivers | Select-Object Name, DeviceID, Status | Format-Table
} else {
    Write-Host "[INFO] Nessun driver Parsec WMI trovato"
}

# 3. Controllo servizi Parsec
Write-Host "`n[STEP 3] Controllo servizi Parsec:"
$ParsecServices = Get-Service | Where-Object { $_.Name -match "Parsec|parsec" }
if ($ParsecServices) {
    Write-Host "[FOUND] Servizi Parsec:"
    $ParsecServices | Select-Object Name, Status, StartType | Format-Table
    
    Write-Host "[ACTION] Arresto servizi Parsec..."
    foreach ($service in $ParsecServices) {
        if ($service.Status -eq "Running") {
            try {
                Stop-Service -Name $service.Name -Force
                Write-Host "  [OK] Servizio $($service.Name) arrestato"
            } catch {
                Write-Host "  [WARNING] Impossibile arrestare $($service.Name): $($_.Exception.Message)"
            }
        }
    }
} else {
    Write-Host "[INFO] Nessun servizio Parsec trovato"
}

# 4. Rimozione driver specifici tramite PnPUtil
Write-Host "`n[STEP 4] Ricerca driver Parsec con PnPUtil:"
try {
    $DriverList = pnputil /enum-drivers
    $ParsecDriverFiles = $DriverList | Where-Object { $_ -match "parsec|Parsec" }
    
    if ($ParsecDriverFiles) {
        Write-Host "[FOUND] File driver Parsec trovati nel store:"
        $ParsecDriverFiles
        
        # Estrai gli OEM driver IDs
        $OemIds = $DriverList | Select-String "oem\d+\.inf" | Where-Object { 
            $Context = ($DriverList | Select-String -Pattern "oem\d+\.inf" -Context 5,5)
            $Context | Where-Object { $_.Context -match "parsec|Parsec" }
        }
        
        Write-Host "`n[ACTION] Tentativo rimozione driver OEM Parsec..."
        # Nota: questo richiede privilegi amministratore
        # pnputil /delete-driver oem##.inf /uninstall
    } else {
        Write-Host "[INFO] Nessun driver Parsec trovato nel driver store"
    }
} catch {
    Write-Host "[WARNING] Errore durante la ricerca driver: $($_.Exception.Message)"
}

# 5. Controllo processi Parsec
Write-Host "`n[STEP 5] Controllo processi Parsec attivi:"
$ParsecProcesses = Get-Process | Where-Object { $_.ProcessName -match "Parsec|parsec" }
if ($ParsecProcesses) {
    Write-Host "[FOUND] Processi Parsec attivi:"
    $ParsecProcesses | Select-Object ProcessName, Id, WorkingSet | Format-Table
    
    Write-Host "[ACTION] Terminazione processi Parsec..."
    foreach ($process in $ParsecProcesses) {
        try {
            Stop-Process -Id $process.Id -Force
            Write-Host "  [OK] Processo $($process.ProcessName) terminato"
        } catch {
            Write-Host "  [WARNING] Impossibile terminare $($process.ProcessName): $($_.Exception.Message)"
        }
    }
} else {
    Write-Host "[INFO] Nessun processo Parsec attivo"
}

Write-Host "`n[INFO] Scansione completata. Per rimuovere completamente Parsec:"
Write-Host "1. Disinstallare Parsec dal Pannello di Controllo"
Write-Host "2. Riavviare il sistema"
Write-Host "3. Controllare che i suoni USB siano cessati"