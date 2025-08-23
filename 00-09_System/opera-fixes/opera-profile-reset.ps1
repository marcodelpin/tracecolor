#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Opera Browser Profile Reset Tool
    
.DESCRIPTION
    Resets corrupted Opera browser profile while preserving important data
    like bookmarks and passwords. Fixes common Opera stability issues.
    
.PARAMETER BackupFirst
    Create backup before resetting profile
    
.PARAMETER PreserveBookmarks
    Keep bookmarks during reset
    
.PARAMETER PreservePasswords
    Keep saved passwords during reset
    
.EXAMPLE
    .\opera-profile-reset.ps1 -BackupFirst -PreserveBookmarks
    Reset Opera profile with backup and bookmark preservation
#>

param(
    [switch]$BackupFirst,
    [switch]$PreserveBookmarks,
    [switch]$PreservePasswords
)

# Opera profile paths
$OperaProfilePath = "$env:APPDATA\Opera Software\Opera Stable"
$BackupPath = "$env:USERPROFILE\Desktop\Opera_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$Timestamp][$Level] $Message"
}

function Test-OperaRunning {
    """Check if Opera is currently running"""
    $OperaProcesses = Get-Process -Name "opera" -ErrorAction SilentlyContinue
    return ($OperaProcesses.Count -gt 0)
}

function Stop-OperaBrowser {
    """Stop all Opera processes"""
    Write-Log "Stopping Opera browser processes..."
    
    $OperaProcesses = Get-Process -Name "opera" -ErrorAction SilentlyContinue
    foreach ($Process in $OperaProcesses) {
        try {
            $Process.CloseMainWindow() | Out-Null
            Start-Sleep -Seconds 2
            
            if (!$Process.HasExited) {
                $Process.Kill()
            }
            Write-Log "Stopped Opera process: $($Process.Id)"
        } catch {
            Write-Log "Error stopping Opera process: $($_.Exception.Message)" "ERROR"
        }
    }
    
    # Wait for processes to fully exit
    Start-Sleep -Seconds 3
}

function Backup-OperaProfile {
    """Create backup of Opera profile"""
    Write-Log "Creating Opera profile backup..."
    
    try {
        if (-not (Test-Path $OperaProfilePath)) {
            Write-Log "Opera profile not found at: $OperaProfilePath" "ERROR"
            return $false
        }
        
        New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
        Copy-Item -Path "$OperaProfilePath\*" -Destination $BackupPath -Recurse -Force
        
        Write-Log "Backup created at: $BackupPath"
        return $true
        
    } catch {
        Write-Log "Error creating backup: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Save-ImportantData {
    """Save bookmarks and passwords before reset"""
    $SavedItems = @()
    
    if ($PreserveBookmarks) {
        $BookmarksFile = "$OperaProfilePath\Bookmarks"
        if (Test-Path $BookmarksFile) {
            Copy-Item -Path $BookmarksFile -Destination "$env:TEMP\Opera_Bookmarks_Backup.json" -Force
            $SavedItems += "Bookmarks"
            Write-Log "Bookmarks saved for restoration"
        }
    }
    
    if ($PreservePasswords) {
        $LoginDataFile = "$OperaProfilePath\Login Data"
        if (Test-Path $LoginDataFile) {
            Copy-Item -Path $LoginDataFile -Destination "$env:TEMP\Opera_LoginData_Backup.db" -Force
            $SavedItems += "Passwords"
            Write-Log "Password data saved for restoration"
        }
    }
    
    return $SavedItems
}

function Reset-OperaProfile {
    """Reset Opera profile by removing problematic files"""
    Write-Log "Resetting Opera profile..."
    
    try {
        if (-not (Test-Path $OperaProfilePath)) {
            Write-Log "Opera profile directory not found" "ERROR"
            return $false
        }
        
        # Files and folders to remove (keeping some important data)
        $ItemsToRemove = @(
            "Cache",
            "Code Cache", 
            "GPUCache",
            "Service Worker",
            "Session Storage",
            "Local Storage",
            "IndexedDB",
            "Web Data",
            "History",
            "Visited Links",
            "Top Sites",
            "Preferences",
            "Secure Preferences",
            "TransportSecurity"
        )
        
        foreach ($Item in $ItemsToRemove) {
            $ItemPath = Join-Path $OperaProfilePath $Item
            if (Test-Path $ItemPath) {
                try {
                    Remove-Item -Path $ItemPath -Recurse -Force -ErrorAction Stop
                    Write-Log "Removed: $Item"
                } catch {
                    Write-Log "Could not remove $Item: $($_.Exception.Message)" "WARN"
                }
            }
        }
        
        Write-Log "Opera profile reset completed"
        return $true
        
    } catch {
        Write-Log "Error resetting profile: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Restore-ImportantData {
    """Restore saved bookmarks and passwords"""
    param([array]$SavedItems)
    
    foreach ($Item in $SavedItems) {
        try {
            switch ($Item) {
                "Bookmarks" {
                    $BackupFile = "$env:TEMP\Opera_Bookmarks_Backup.json"
                    $TargetFile = "$OperaProfilePath\Bookmarks"
                    if (Test-Path $BackupFile) {
                        Copy-Item -Path $BackupFile -Destination $TargetFile -Force
                        Write-Log "Bookmarks restored"
                    }
                }
                "Passwords" {
                    $BackupFile = "$env:TEMP\Opera_LoginData_Backup.db"
                    $TargetFile = "$OperaProfilePath\Login Data"
                    if (Test-Path $BackupFile) {
                        Copy-Item -Path $BackupFile -Destination $TargetFile -Force
                        Write-Log "Password data restored"
                    }
                }
            }
        } catch {
            Write-Log "Error restoring $Item: $($_.Exception.Message)" "WARN"
        }
    }
}

# Main execution
Write-Log "Opera Profile Reset Tool Started"

Write-Output "Opera Browser Profile Reset"
Write-Output "============================"
Write-Output ""

# Check if Opera is running
if (Test-OperaRunning) {
    Write-Output "Opera is currently running and will be closed."
    $Confirmation = Read-Host "Continue? (Y/N)"
    if ($Confirmation -ne 'Y' -and $Confirmation -ne 'y') {
        Write-Log "User cancelled operation"
        exit 0
    }
    
    Stop-OperaBrowser
}

# Check if profile exists
if (-not (Test-Path $OperaProfilePath)) {
    Write-Output "Opera profile not found. Opera may not be installed or never run."
    Write-Log "Opera profile directory not found: $OperaProfilePath"
    exit 1
}

Write-Output "Profile location: $OperaProfilePath"
Write-Output ""

if ($PreserveBookmarks) { Write-Output "- Bookmarks will be preserved" }
if ($PreservePasswords) { Write-Output "- Passwords will be preserved" }
if ($BackupFirst) { Write-Output "- Full backup will be created" }
Write-Output ""

# Create backup if requested
if ($BackupFirst) {
    Write-Output "Creating backup..."
    if (-not (Backup-OperaProfile)) {
        Write-Output "Backup failed. Aborting reset for safety."
        exit 1
    }
    Write-Output "Backup completed: $BackupPath"
    Write-Output ""
}

# Save important data
Write-Output "Saving important data..."
$SavedItems = Save-ImportantData
if ($SavedItems.Count -gt 0) {
    Write-Output "Saved: $($SavedItems -join ', ')"
}
Write-Output ""

# Reset profile
Write-Output "Resetting Opera profile..."
$ResetSuccess = Reset-OperaProfile

if ($ResetSuccess) {
    # Restore important data
    if ($SavedItems.Count -gt 0) {
        Write-Output "Restoring preserved data..."
        Restore-ImportantData -SavedItems $SavedItems
    }
    
    Write-Output ""
    Write-Output "Opera profile reset completed successfully!"
    Write-Output ""
    Write-Output "Benefits:"
    Write-Output "- Resolved profile corruption issues"
    Write-Output "- Cleared problematic cache and data"
    Write-Output "- Reset preferences to defaults"
    Write-Output "- Improved browser performance"
    Write-Output ""
    Write-Output "You can now restart Opera with a fresh profile."
    
} else {
    Write-Output "Profile reset encountered issues. Check the log output above."
    if ($BackupFirst) {
        Write-Output "Your backup is available at: $BackupPath"
    }
}

Write-Log "Opera Profile Reset Tool Completed"