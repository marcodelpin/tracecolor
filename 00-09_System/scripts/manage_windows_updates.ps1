# Windows Update Manager PowerShell Script
Write-Host "Windows Update Manager" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Run PowerShell as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

function Show-Menu {
    Write-Host "Choose an option:" -ForegroundColor Yellow
    Write-Host "1. View pending updates"
    Write-Host "2. View installed updates history"
    Write-Host "3. Block a specific update by KB number"
    Write-Host "4. Unblock a previously blocked update"
    Write-Host "5. Hide all driver updates"
    Write-Host "6. Download Microsoft's Show/Hide tool"
    Write-Host "7. Exit"
    Write-Host ""
}

function Get-PendingUpdates {
    Write-Host "Checking for pending updates..." -ForegroundColor Yellow
    $Session = New-Object -ComObject Microsoft.Update.Session
    $Searcher = $Session.CreateUpdateSearcher()
    $SearchResult = $Searcher.Search("IsInstalled=0")
    
    if ($SearchResult.Updates.Count -eq 0) {
        Write-Host "No pending updates found." -ForegroundColor Green
    } else {
        Write-Host "Pending updates:" -ForegroundColor Cyan
        foreach ($Update in $SearchResult.Updates) {
            Write-Host "  - $($Update.Title)" -ForegroundColor White
            Write-Host "    KB: $($Update.KBArticleIDs)" -ForegroundColor Gray
            Write-Host "    Size: $([Math]::Round($Update.MaxDownloadSize / 1MB, 2)) MB" -ForegroundColor Gray
            Write-Host ""
        }
    }
}

function Get-InstalledUpdates {
    Write-Host "Recent installed updates:" -ForegroundColor Cyan
    Get-HotFix | Select-Object -First 20 | Format-Table -Property Description, HotFixID, InstalledOn -AutoSize
}

function Block-Update {
    $kb = Read-Host "Enter KB number to block (e.g., KB5034441)"
    
    # Method 1: Using registry
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\HiddenUpdates"
    
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    New-ItemProperty -Path $regPath -Name $kb -Value 1 -PropertyType DWord -Force | Out-Null
    
    # Method 2: Using Group Policy registry keys
    $policyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    if (!(Test-Path $policyPath)) {
        New-Item -Path $policyPath -Force | Out-Null
    }
    
    $currentExcluded = (Get-ItemProperty -Path $policyPath -Name "ExcludedUpdates" -ErrorAction SilentlyContinue).ExcludedUpdates
    if ($currentExcluded) {
        $newExcluded = "$currentExcluded;$kb"
    } else {
        $newExcluded = $kb
    }
    
    Set-ItemProperty -Path $policyPath -Name "ExcludedUpdates" -Value $newExcluded
    
    Write-Host "Update $kb has been blocked." -ForegroundColor Green
    Write-Host "You may need to restart Windows Update service for changes to take effect." -ForegroundColor Yellow
}

function Unblock-Update {
    $kb = Read-Host "Enter KB number to unblock (e.g., KB5034441)"
    
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\HiddenUpdates"
    if (Test-Path "$regPath\$kb") {
        Remove-ItemProperty -Path $regPath -Name $kb -Force
        Write-Host "Update $kb has been unblocked." -ForegroundColor Green
    } else {
        Write-Host "Update $kb was not found in blocked list." -ForegroundColor Yellow
    }
}

function Hide-DriverUpdates {
    Write-Host "Hiding all driver updates..." -ForegroundColor Yellow
    
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    Set-ItemProperty -Path $regPath -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -Type DWord
    
    Write-Host "Driver updates have been hidden." -ForegroundColor Green
    Write-Host "To show them again, set ExcludeWUDriversInQualityUpdate to 0" -ForegroundColor Gray
}

function Download-ShowHideTool {
    Write-Host "Downloading Microsoft Show/Hide Updates tool..." -ForegroundColor Yellow
    
    $url = "http://download.microsoft.com/download/f/2/2/f22d5fdb-59cd-4275-8c95-1be17bf70b21/wushowhide.diagcab"
    $output = "$env:USERPROFILE\Desktop\wushowhide.diagcab"
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $output
        Write-Host "Tool downloaded to Desktop: wushowhide.diagcab" -ForegroundColor Green
        Write-Host "Double-click to run it." -ForegroundColor Yellow
        
        $run = Read-Host "Run it now? (Y/N)"
        if ($run -eq 'Y' -or $run -eq 'y') {
            Start-Process $output
        }
    } catch {
        Write-Host "Failed to download: $_" -ForegroundColor Red
    }
}

# Main loop
do {
    Clear-Host
    Write-Host "Windows Update Manager" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    Write-Host ""
    
    Show-Menu
    $choice = Read-Host "Select option (1-7)"
    
    switch ($choice) {
        '1' { Get-PendingUpdates; Read-Host "Press Enter to continue" }
        '2' { Get-InstalledUpdates; Read-Host "Press Enter to continue" }
        '3' { Block-Update; Read-Host "Press Enter to continue" }
        '4' { Unblock-Update; Read-Host "Press Enter to continue" }
        '5' { Hide-DriverUpdates; Read-Host "Press Enter to continue" }
        '6' { Download-ShowHideTool; Read-Host "Press Enter to continue" }
        '7' { Write-Host "Exiting..." -ForegroundColor Green; break }
        default { Write-Host "Invalid option!" -ForegroundColor Red; Start-Sleep -Seconds 2 }
    }
} while ($choice -ne '7')