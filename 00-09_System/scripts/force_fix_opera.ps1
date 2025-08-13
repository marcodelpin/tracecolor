# Script per disabilitare dispositivi Parsec
Write-Host "[INFO] Disabilitazione dispositivi Parsec..."

# Ottieni i dispositivi Parsec
$ParsecDevices = Get-PnpDevice | Where-Object { $_.Name -match "Parsec" }

if ($ParsecDevices) {
    Write-Host "[FOUND] Trovati $($ParsecDevices.Count) dispositivi Parsec:"
    $ParsecDevices | Select-Object Name, Status, InstanceId | Format-Table
    
    foreach ($device in $ParsecDevices) {
        Write-Host "[ACTION] Disabilitazione dispositivo: $($device.Name)"
        try {
            Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
            Write-Host "  [OK] Dispositivo $($device.Name) disabilitato"
        } catch {
            Write-Host "  [ERROR] Impossibile disabilitare: $($_.Exception.Message)"
        }
    }
} else {
    Write-Host "[INFO] Nessun dispositivo Parsec trovato"
}

# Verifica stato dopo disabilitazione
Write-Host "`n[CHECK] Stato dispositivi Parsec dopo disabilitazione:"
$UpdatedDevices = Get-PnpDevice | Where-Object { $_.Name -match "Parsec" }
if ($UpdatedDevices) {
    $UpdatedDevices | Select-Object Name, Status, InstanceId | Format-Table
} else {
    Write-Host "[INFO] Nessun dispositivo Parsec attivo trovato"
}

Write-Host "`n[INFO] Per completare la rimozione:"
Write-Host "1. Disinstallare Parsec dal Pannello di Controllo"  
Write-Host "2. Riavviare il sistema"
Write-Host "3. I suoni USB dovrebbero cessare"