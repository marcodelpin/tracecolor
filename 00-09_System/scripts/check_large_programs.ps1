# Check Large Programs for Uninstallation
Write-Host "PROGRAMMI INSTALLATI - ANALISI SPAZIO" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Cercando programmi di grandi dimensioni..." -ForegroundColor Yellow
Write-Host ""

# Method 1: Windows Features/Programs
$programs = @()

# Get from Registry (more reliable)
$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($key in $uninstallKeys) {
    Get-ItemProperty $key -ErrorAction SilentlyContinue | 
        Where-Object { $_.DisplayName -and $_.EstimatedSize -gt 100000 } |
        ForEach-Object {
            $programs += [PSCustomObject]@{
                Name = $_.DisplayName
                SizeMB = [math]::Round($_.EstimatedSize / 1024, 0)
                Publisher = $_.Publisher
                InstallLocation = $_.InstallLocation
                UninstallString = $_.UninstallString
            }
        }
}

# Sort by size and remove duplicates
$programs = $programs | Sort-Object Name -Unique | Sort-Object SizeMB -Descending

Write-Host "TOP 30 PROGRAMMI PIU GRANDI:" -ForegroundColor Green
$programs | Select-Object -First 30 | Format-Table Name, SizeMB, Publisher -AutoSizeWrite-Host ""
Write-Host "CATEGORIE DI PROGRAMMI DA CONSIDERARE PER RIMOZIONE:" -ForegroundColor Red

$categories = @{
    "Giochi" = @("Steam", "Epic", "Game", "Gaming", "Ubisoft", "EA ", "Rockstar")
    "Sviluppo" = @("Visual Studio", "IntelliJ", "Eclipse", "Android Studio", "Xcode", "Unity")
    "Design" = @("Adobe", "Photoshop", "Illustrator", "Premiere", "After Effects", "Blender")
    "Office" = @("Microsoft Office", "LibreOffice", "OpenOffice")
    "Multimedia" = @("VLC", "Media Player", "Spotify", "iTunes", "Audacity")
    "Utility" = @("WinRAR", "7-Zip", "CCleaner", "Malwarebytes")
}

foreach ($category in $categories.Keys) {
    Write-Host ""
    Write-Host "$category):" -ForegroundColor Yellow
    
    $categoryPrograms = $programs | Where-Object { 
        $programName = $_.Name
        $categories[$category] | Where-Object { $programName -like "*$_*" }
    } | Select-Object -First 10
    
    if ($categoryPrograms) {
        $categoryPrograms | Format-Table Name, SizeMB -AutoSize
        $totalSize = ($categoryPrograms | Measure-Object SizeMB -Sum).Sum
        Write-Host "  Totale categoria: $([math]::Round($totalSize/1024, 1)) GB" -ForegroundColor Cyan
    } else {
        Write-Host "  Nessun programma trovato in questa categoria" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "PROGRAMMI POTENZIALMENTE SICURI DA RIMUOVERE:" -ForegroundColor Green

$safeToRemove = $programs | Where-Object { 
    $_.Name -match "(?i)(game|gioco|steam|epic|adobe trial|demo|old version|outdated)" -or
    $_.SizeMB -gt 2000  # Programs larger than 2GB
} | Select-Object -First 15

if ($safeToRemove) {
    $safeToRemove | Format-Table Name, SizeMB, Publisher -AutoSize
    $totalPotential = ($safeToRemove | Measure-Object SizeMB -Sum).Sum
    Write-Host "Spazio potenzialmente recuperabile: $([math]::Round($totalPotential/1024, 1)) GB" -ForegroundColor Green
}

Write-Host ""
Write-Host "PROSSIMI PASSI:" -ForegroundColor Cyan
Write-Host "1. Esamina la lista sopra" -ForegroundColor White
Write-Host "2. Identifica programmi che non usi più" -ForegroundColor White
Write-Host "3. Vai in Impostazioni > App per disinstallare" -ForegroundColor White
Write-Host "4. Priorità: programmi > 1 GB che non usi" -ForegroundColor White

Write-Host ""
Read-Host "Premere Enter per continuare"