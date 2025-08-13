# Disk Space Analysis for C: drive
Write-Host "ANALISI SPAZIO DISCO C:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Check current space
$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeGB = [math]::Round($disk.FreeSpace / 1GB, 1)
$totalGB = [math]::Round($disk.Size / 1GB, 1)
$usedGB = $totalGB - $freeGB

Write-Host "Stato attuale:" -ForegroundColor Yellow
Write-Host "  Totale: $totalGB GB"
Write-Host "  Usato:  $usedGB GB"
Write-Host "  Libero: $freeGB GB"
Write-Host "  Necessario per Windows 11: 64 GB"
Write-Host "  Da liberare: $([math]::Max(64 - $freeGB, 0)) GB" -ForegroundColor Red
Write-Host ""

# Quick analysis of major folders
Write-Host "CARTELLE PRINCIPALI (stima rapida):" -ForegroundColor Yellow

$folders = @(
    @{Name="Program Files"; Path="C:\Program Files"},
    @{Name="Program Files (x86)"; Path="C:\Program Files (x86)"},
    @{Name="Windows"; Path="C:\Windows"},
    @{Name="Users"; Path="C:\Users"},
    @{Name="ProgramData"; Path="C:\ProgramData"},
    @{Name="Temp Files"; Path="C:\Windows\Temp"}
)

foreach ($folder in $folders) {
    if (Test-Path $folder.Path) {
        try {
            $size = (Get-ChildItem $folder.Path -Recurse -File -ErrorAction SilentlyContinue | 
                    Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $sizeGB = [math]::Round($size / 1GB, 1)
            Write-Host "  $($folder.Name): $sizeGB GB"
        } catch {
            Write-Host "  $($folder.Name): [Accesso negato]" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "PROGRAMMI INSTALLATI (Top 20 per dimensione):" -ForegroundColor Yellow

# Get installed programs with size
$programs = Get-WmiObject -Class Win32_Product | 
    Where-Object { $_.InstallLocation -like "C:\*" -and $_.EstimatedSize -gt 0 } |
    Sort-Object EstimatedSize -Descending |
    Select-Object -First 20 Name, @{Name="SizeMB";Expression={[math]::Round($_.EstimatedSize/1024,0)}}, InstallLocation

$programs | Format-Table -AutoSize

Write-Host ""
Write-Host "FILE TEMPORANEI DA PULIRE:" -ForegroundColor Yellow

$tempFolders = @(
    "C:\Windows\Temp",
    "C:\Users\$env:USERNAME\AppData\Local\Temp",
    "C:\Windows\SoftwareDistribution\Download",
    "C:\Windows\Logs",
    "C:\`$Recycle.Bin"
)

foreach ($tempPath in $tempFolders) {
    if (Test-Path $tempPath) {
        try {
            $size = (Get-ChildItem $tempPath -Recurse -File -ErrorAction SilentlyContinue | 
                    Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $sizeGB = [math]::Round($size / 1GB, 2)
            if ($sizeGB -gt 0.1) {
                Write-Host "  $tempPath`: $sizeGB GB" -ForegroundColor Red
            }
        } catch {
            Write-Host "  $tempPath`: [Accesso limitato]" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "CARTELLE CANDIDATR PER JUNCTION:" -ForegroundColor Green

$junctionCandidates = @(
    @{Path="C:\Users\$env:USERNAME\Documents"; Description="Documenti utente"},
    @{Path="C:\Users\$env:USERNAME\Downloads"; Description="Download"},
    @{Path="C:\Users\$env:USERNAME\Pictures"; Description="Immagini"},
    @{Path="C:\Users\$env:USERNAME\Videos"; Description="Video"},
    @{Path="C:\Users\$env:USERNAME\Music"; Description="Musica"},
    @{Path="C:\ProgramData"; Description="Dati applicazioni (ATTENZIONE)"}
)

foreach ($candidate in $junctionCandidates) {
    if (Test-Path $candidate.Path) {
        try {
            $size = (Get-ChildItem $candidate.Path -Recurse -File -ErrorAction SilentlyContinue | 
                    Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $sizeGB = [math]::Round($size / 1GB, 2)
            if ($sizeGB -gt 0.5) {
                Write-Host "  $($candidate.Path): $sizeGB GB - $($candidate.Description)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "  $($candidate.Path): [Calcolo non riuscito] - $($candidate.Description)" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "RACCOMANDAZIONI:" -ForegroundColor Green
Write-Host "1. Eseguire Pulizia Disco (cleanmgr)" -ForegroundColor White
Write-Host "2. Disinstallare programmi inutili" -ForegroundColor White
Write-Host "3. Spostare cartelle utente su S: con junction" -ForegroundColor White
Write-Host "4. Pulire file temporanei" -ForegroundColor White
Write-Host ""

Read-Host "Premere Enter per continuare"