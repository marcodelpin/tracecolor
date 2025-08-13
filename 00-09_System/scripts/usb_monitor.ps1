# Script per monitorare eventi USB
Write-Host "[INFO] Analisi eventi USB negli ultimi 60 minuti..."

# Ottieni gli ultimi eventi dal log di sistema
$StartTime = (Get-Date).AddMinutes(-60)
$FilterHashtable = @{LogName='System'; StartTime=$StartTime}
$Events = Get-WinEvent -FilterHashtable $FilterHashtable -MaxEvents 500 -ErrorAction SilentlyContinue

if ($Events) {
    # Filtra eventi USB/Device
    $USBEvents = $Events | Where-Object {
        $_.Message -match "USB|device.*connect|device.*disconnect|device.*install|device.*remov|PnP|Plug and Play" -or
        $_.Id -eq 20001 -or $_.Id -eq 20003 -or $_.Id -eq 400 -or $_.Id -eq 410
    }
    
    if ($USBEvents) {
        Write-Host "[FOUND] $($USBEvents.Count) eventi USB/dispositivi trovati:"
        Write-Host ""
        
        $USBEvents | Select-Object TimeCreated, Id, LevelDisplayName, Message | 
        Sort-Object TimeCreated -Descending | 
        Format-Table -Wrap
    } else {
        Write-Host "[INFO] Nessun evento USB specifico trovato negli ultimi 60 minuti"
    }
} else {
    Write-Host "[WARNING] Impossibile leggere il log eventi"
}

# Controlla anche eventi di connessione/disconnessione generici
Write-Host ""
Write-Host "[INFO] Controllo eventi generali di connessione dispositivi..."

$GenericFilterHashtable = @{LogName='System'; StartTime=$StartTime}
$GenericEvents = Get-WinEvent -FilterHashtable $GenericFilterHashtable -MaxEvents 200 -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -match "connect|disconnect|install|remove" }

if ($GenericEvents) {
    Write-Host "[FOUND] $($GenericEvents.Count) eventi di connessione trovati:"
    $GenericEvents | Select-Object TimeCreated, Id, ProviderName, Message |
    Sort-Object TimeCreated -Descending |
    Format-Table -Wrap
}