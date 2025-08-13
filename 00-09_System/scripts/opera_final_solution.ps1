# Final Opera Fix Solution
Write-Host "Opera Final Fix Solution" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""

# Check if running as admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: Run PowerShell as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

$operaPath = "$env:APPDATA\Opera Software"

Write-Host "Attempting multiple methods to fix Opera..." -ForegroundColor Yellow
Write-Host ""

# Method 1: WMI
Write-Host "[1] Trying WMI method..." -ForegroundColor Cyan
try {
    $folder = Get-WmiObject -Query "SELECT * FROM Win32_Directory WHERE Name='$($operaPath.Replace('\','\\'))'"
    if ($folder) {
        $folder.Delete()
        Write-Host "Success with WMI!" -ForegroundColor Green
    }
} catch {
    Write-Host "WMI method failed" -ForegroundColor Red
}

# Method 2: .NET with special options
if (Test-Path $operaPath) {
    Write-Host "[2] Trying .NET method..." -ForegroundColor Cyan
    try {
        $dir = New-Object System.IO.DirectoryInfo($operaPath)
        $dir.Attributes = 'Normal'
        [System.IO.Directory]::Delete($operaPath, $true)
        Write-Host "Success with .NET!" -ForegroundColor Green
    } catch {
        Write-Host ".NET method failed" -ForegroundColor Red
    }
}

# Method 3: Create boot script
if (Test-Path $operaPath) {
    Write-Host "[3] Creating boot-time deletion script..." -ForegroundColor Cyan
    
    $bootScript = @"
Remove-Item -Path '$operaPath' -Recurse -Force -ErrorAction SilentlyContinue
Unregister-ScheduledTask -TaskName 'OperaFolderCleanup' -Confirm:`$false
"@
    
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"$bootScript`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    Register-ScheduledTask -TaskName "OperaFolderCleanup" -Action $action -Trigger $trigger -Principal $principal -Force | Out-Null
    
    Write-Host "Boot script created successfully!" -ForegroundColor Green
}

# Method 4: Immediate solution - Junction point
if (Test-Path $operaPath) {
    Write-Host "[4] Trying junction point trick..." -ForegroundColor Cyan
    try {
        # Create a temporary junction to an empty folder
        $tempEmpty = "$env:TEMP\EmptyOpera_$([guid]::NewGuid())"
        New-Item -ItemType Directory -Path $tempEmpty -Force | Out-Null
        
        # Remove the problematic folder and replace with junction
        cmd /c "rmdir /s /q `"$operaPath`" 2>nul & mklink /J `"$operaPath`" `"$tempEmpty`""
        
        # Now remove the junction
        cmd /c "rmdir `"$operaPath`""
        
        # Clean up
        Remove-Item $tempEmpty -Force
        
        if (-not (Test-Path $operaPath)) {
            Write-Host "Success with junction trick!" -ForegroundColor Green
        }
    } catch {
        Write-Host "Junction method failed" -ForegroundColor Red
    }
}

Write-Host ""
if (Test-Path $operaPath) {
    Write-Host "All automated methods failed." -ForegroundColor Red
    Write-Host ""
    Write-Host "FINAL RECOMMENDATION:" -ForegroundColor Yellow
    Write-Host "1. Download IObit Unlocker (free): https://www.iobit.com/en/iobit-unlocker.php" -ForegroundColor White
    Write-Host "2. Or restart in Safe Mode to delete manually" -ForegroundColor White
    Write-Host ""
    Write-Host "A scheduled task has been created to delete the folder on next boot." -ForegroundColor Cyan
} else {
    Write-Host "SUCCESS! Opera folder has been removed." -ForegroundColor Green
    Write-Host "You can now start Opera normally." -ForegroundColor Green
}

Write-Host ""
Read-Host "Press Enter to exit"