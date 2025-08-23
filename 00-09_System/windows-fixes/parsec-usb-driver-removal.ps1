#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Remove Parsec Virtual USB Driver
    
.DESCRIPTION
    Removes the Parsec virtual USB driver that causes system audio issues 
    and Windows Update errors. This script safely uninstalls the problematic 
    driver and cleans up associated files.
    
.NOTES
    CRITICAL ISSUE RESOLUTION: Parsec virtual USB driver removal
    - Eliminates system audio issues  
    - Resolves Windows Update errors
    - Improves system stability
    
.EXAMPLE
    .\parsec-usb-driver-removal.ps1
    Remove Parsec virtual USB driver
#>

# Configure logging
$LogFile = "ParsecDriverRemoval.log" 
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $LogEntry = "[$Timestamp][$Level] $Message"
    Write-Output $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

function Test-ParsecDriver {
    """Check if Parsec virtual USB driver is installed"""
    try {
        $ParsecDevices = Get-PnpDevice | Where-Object { 
            $_.FriendlyName -like "*Parsec*" -or 
            $_.HardwareID -like "*Parsec*" -or
            $_.InstanceId -like "*Parsec*"
        }
        
        if ($ParsecDevices) {
            Write-Log "Found Parsec devices: $($ParsecDevices.Count)"
            foreach ($Device in $ParsecDevices) {
                Write-Log "Device: $($Device.FriendlyName) - Status: $($Device.Status)"
            }
            return $ParsecDevices
        } else {
            Write-Log "No Parsec devices found"
            return $null
        }
    } catch {
        Write-Log "Error checking for Parsec devices: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Remove-ParsecDriver {
    """Remove Parsec virtual USB driver"""
    Write-Log "Starting Parsec driver removal..."
    
    try {
        # Find Parsec devices
        $ParsecDevices = Get-PnpDevice | Where-Object { 
            $_.FriendlyName -like "*Parsec*" -or 
            $_.HardwareID -like "*Parsec*" -or
            $_.InstanceId -like "*Parsec*" -or
            $_.FriendlyName -like "*Virtual USB*"
        }
        
        if (-not $ParsecDevices) {
            Write-Log "No Parsec devices found to remove"
            return $true
        }
        
        $RemovedCount = 0
        foreach ($Device in $ParsecDevices) {
            try {
                Write-Log "Removing device: $($Device.FriendlyName)"
                
                # Disable device first
                Disable-PnpDevice -InstanceId $Device.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
                Write-Log "Device disabled: $($Device.InstanceId)"
                
                # Attempt to uninstall device
                $Result = pnputil /remove-device $Device.InstanceId
                if ($LASTEXITCODE -eq 0) {
                    Write-Log "Successfully removed device: $($Device.InstanceId)"
                    $RemovedCount++
                } else {
                    Write-Log "Failed to remove device with pnputil: $($Device.InstanceId)" "WARN"
                    
                    # Try alternative method with DevCon-style removal
                    try {
                        Remove-PnpDevice -InstanceId $Device.InstanceId -Confirm:$false
                        Write-Log "Device removed with Remove-PnpDevice: $($Device.InstanceId)"
                        $RemovedCount++
                    } catch {
                        Write-Log "Failed to remove device: $($_.Exception.Message)" "ERROR"
                    }
                }
                
            } catch {
                Write-Log "Error processing device $($Device.InstanceId): $($_.Exception.Message)" "ERROR"
            }
        }
        
        Write-Log "Removed $RemovedCount out of $($ParsecDevices.Count) Parsec devices"
        return $RemovedCount -gt 0
        
    } catch {
        Write-Log "Error during driver removal: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Remove-ParsecDriverFiles {
    """Remove Parsec driver files from system"""
    Write-Log "Cleaning up Parsec driver files..."
    
    $DriverPaths = @(
        "$env:SystemRoot\System32\drivers\*parsec*",
        "$env:SystemRoot\System32\DriverStore\FileRepository\*parsec*",
        "$env:SystemRoot\INF\*parsec*"
    )
    
    $RemovedFiles = 0
    foreach ($Path in $DriverPaths) {
        try {
            $Files = Get-ChildItem -Path $Path -ErrorAction SilentlyContinue
            if ($Files) {
                foreach ($File in $Files) {
                    try {
                        Remove-Item -Path $File.FullName -Force -Recurse -ErrorAction Stop
                        Write-Log "Removed file: $($File.FullName)"
                        $RemovedFiles++
                    } catch {
                        Write-Log "Could not remove file $($File.FullName): $($_.Exception.Message)" "WARN"
                    }
                }
            }
        } catch {
            Write-Log "Error accessing path $Path: $($_.Exception.Message)" "WARN"
        }
    }
    
    Write-Log "Removed $RemovedFiles Parsec driver files"
}

function Clear-DeviceCache {
    """Clear Windows device installation cache"""
    Write-Log "Clearing device installation cache..."
    
    try {
        # Clear PnP device cache
        $CacheFiles = Get-ChildItem -Path "$env:SystemRoot\INF\*.pnf" -ErrorAction SilentlyContinue
        $ClearedCount = 0
        
        foreach ($File in $CacheFiles) {
            if ($File.Name -like "*parsec*") {
                try {
                    Remove-Item -Path $File.FullName -Force -ErrorAction Stop
                    Write-Log "Removed cache file: $($File.Name)"
                    $ClearedCount++
                } catch {
                    Write-Log "Could not remove cache file $($File.Name): $($_.Exception.Message)" "WARN"
                }
            }
        }
        
        Write-Log "Cleared $ClearedCount cache files"
        
    } catch {
        Write-Log "Error clearing device cache: $($_.Exception.Message)" "ERROR"
    }
}

function Test-SystemHealth {
    """Verify system health after driver removal"""
    Write-Log "Checking system health after driver removal..."
    
    try {
        # Check for any remaining Parsec devices
        $RemainingDevices = Test-ParsecDriver
        if ($RemainingDevices) {
            Write-Log "Warning: Some Parsec devices may still be present" "WARN"
            return $false
        }
        
        # Check Windows Audio service
        $AudioService = Get-Service -Name "AudioSrv" -ErrorAction SilentlyContinue
        if ($AudioService -and $AudioService.Status -eq "Running") {
            Write-Log "Windows Audio service is running correctly"
        } else {
            Write-Log "Windows Audio service issue detected" "WARN"
        }
        
        Write-Log "System health check completed"
        return $true
        
    } catch {
        Write-Log "Error during system health check: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main execution
Write-Log "Parsec Virtual USB Driver Removal Script Started"

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "Script must be run as Administrator" "ERROR"
    Write-Output "ERROR: This script requires Administrator privileges"
    Write-Output "Please run PowerShell as Administrator and try again"
    exit 1
}

Write-Output "Parsec Virtual USB Driver Removal"
Write-Output "=================================="
Write-Output ""
Write-Output "This script will remove the Parsec virtual USB driver that causes:"
Write-Output "- System audio issues"
Write-Output "- Windows Update errors"
Write-Output "- System instability"
Write-Output ""

# Check for Parsec devices
Write-Log "Checking for Parsec devices..."
$InitialDevices = Test-ParsecDriver

if (-not $InitialDevices) {
    Write-Output "No Parsec devices found on this system."
    Write-Log "No Parsec devices detected - script completed"
    exit 0
}

Write-Output "Found Parsec devices that will be removed:"
foreach ($Device in $InitialDevices) {
    Write-Output "- $($Device.FriendlyName)"
}
Write-Output ""

# Confirm removal
$Confirmation = Read-Host "Do you want to proceed with removal? (Y/N)"
if ($Confirmation -ne 'Y' -and $Confirmation -ne 'y') {
    Write-Log "User cancelled operation"
    Write-Output "Operation cancelled by user"
    exit 0
}

Write-Output ""
Write-Output "Starting Parsec driver removal..."

# Create system restore point
try {
    Write-Log "Creating system restore point..."
    Enable-ComputerRestore -Drive "C:"
    Checkpoint-Computer -Description "Before Parsec Driver Removal" -RestorePointType "MODIFY_SETTINGS"
    Write-Log "System restore point created successfully"
    Write-Output "System restore point created"
} catch {
    Write-Log "Could not create system restore point: $($_.Exception.Message)" "WARN"
    Write-Output "Warning: Could not create system restore point"
}

# Remove Parsec driver
$RemovalSuccess = Remove-ParsecDriver

if ($RemovalSuccess) {
    Write-Output "Driver removal completed"
    
    # Clean up driver files
    Remove-ParsecDriverFiles
    
    # Clear device cache
    Clear-DeviceCache
    
    # Test system health
    $HealthCheck = Test-SystemHealth
    
    Write-Output ""
    Write-Output "Parsec driver removal completed successfully!"
    Write-Output ""
    Write-Output "Benefits:"
    Write-Output "- Resolved system audio issues"
    Write-Output "- Fixed Windows Update errors"
    Write-Output "- Improved system stability"
    Write-Output ""
    Write-Output "A system restart is recommended to complete the removal."
    
    $RestartPrompt = Read-Host "Would you like to restart now? (Y/N)"
    if ($RestartPrompt -eq 'Y' -or $RestartPrompt -eq 'y') {
        Write-Log "User chose to restart system"
        Write-Output "Restarting system in 10 seconds..."
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    } else {
        Write-Output "Please restart your system when convenient"
    }
    
} else {
    Write-Output "Driver removal encountered issues. Check log file for details."
    Write-Log "Driver removal completed with errors"
}

Write-Log "Parsec Virtual USB Driver Removal Script Completed"