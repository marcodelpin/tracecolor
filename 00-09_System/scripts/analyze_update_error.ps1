# Script per analizzare errori aggiornamento Windows
Write-Host "[INFO] Analisi errori Windows Update..."

# 1. Controlla lo stato del servizio Windows Update
Write-Host "`n[CHECK] Stato servizi Windows Update:"
$services = @('wuauserv', 'cryptsvc', 'bits', 'msiserver')
foreach ($service in $services) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($svc) {
        Write-Host "  $($svc.DisplayName): $($svc.Status)"
    }
}

# 2. Controlla eventi di errore Windows Update
Write-Host "`n[CHECK] Eventi errore Windows Update (ultimi 7 giorni):"
$StartTime = (Get-Date).AddDays(-7)
$FilterHashtable = @{LogName='System'; StartTime=$StartTime; Level=1,2,3}
$UpdateErrors = Get-WinEvent -FilterHashtable $FilterHashtable -MaxEvents 200 -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -match "Windows Update|wuauserv|update|BITS|Background Intelligence|cryptographic" }

if ($UpdateErrors) {
    Write-Host "[FOUND] $($UpdateErrors.Count) errori relativi agli aggiornamenti:"
    $UpdateErrors | Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message |
    Sort-Object TimeCreated -Descending | Select-Object -First 10 |
    Format-Table -Wrap
} else {
    Write-Host "[INFO] Nessun errore di aggiornamento trovato negli ultimi 7 giorni"
}

# 3. Controlla log specifici di Windows Update
Write-Host "`n[CHECK] Log eventi Windows Update:"
try {
    $WUEvents = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-WindowsUpdateClient/Operational'; StartTime=$StartTime} -MaxEvents 50 -ErrorAction SilentlyContinue
    if ($WUEvents) {
        Write-Host "[FOUND] $($WUEvents.Count) eventi Windows Update Client:"
        $WUEvents | Where-Object { $_.LevelDisplayName -match "Error|Warning" } |
        Select-Object TimeCreated, Id, LevelDisplayName, Message |
        Sort-Object TimeCreated -Descending | Select-Object -First 10 |
        Format-Table -Wrap
    }
} catch {
    Write-Host "[WARNING] Impossibile accedere al log Windows Update Client"
}

# 4. Controlla spazio disco
Write-Host "`n[CHECK] Spazio disco disponibile:"
Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } |
    Select-Object DeviceID, @{Name="Size(GB)";Expression={[math]::Round($_.Size/1GB,2)}}, 
                  @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
                  @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace/$_.Size)*100,2)}} |
    Format-Table

# 5. Controlla file di log WindowsUpdate.log se esiste
$LogPath = "$env:WINDIR\Logs\WindowsUpdate\WindowsUpdate.log"
if (Test-Path $LogPath) {
    Write-Host "`n[CHECK] Ultimi errori in WindowsUpdate.log:"
    Get-Content $LogPath -Tail 50 | Where-Object { $_ -match "ERROR|FAILED|WARN" } |
    Select-Object -Last 10
} else {
    Write-Host "`n[INFO] WindowsUpdate.log non trovato in $LogPath"
}

Write-Host "`n[INFO] Analisi completata."