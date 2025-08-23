#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Comprehensive Windows Update Management Script
    
.DESCRIPTION  
    Manages Windows Updates with options for checking, installing, and troubleshooting.
    Includes safety checks and detailed logging.
    
.PARAMETER CheckOnly
    Only check for available updates without installing
    
.PARAMETER InstallUpdates
    Install all available updates
    
.PARAMETER IncludeOptional
    Include optional updates in installation
    
.EXAMPLE
    .\manage_windows_updates.ps1 -CheckOnly
    Check for available updates
    
.EXAMPLE
    .\manage_windows_updates.ps1 -InstallUpdates
    Install all available updates
#>

param(
    [switch]$CheckOnly,
    [switch]$InstallUpdates, 
    [switch]$IncludeOptional
)

# Configure logging
$LogFile = "WindowsUpdateManagement.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $LogEntry = "[$Timestamp][$Level] $Message"
    Write-Output $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

function Test-UpdateService {
    """Test if Windows Update service is running"""
    $Service = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    if ($Service -and $Service.Status -eq "Running") {
        Write-Log "Windows Update service is running"
        return $true
    } else {
        Write-Log "Windows Update service is not running" "WARN"
        return $false
    }
}

function Start-UpdateService {
    """Start Windows Update service if stopped"""
    try {
        Start-Service -Name "wuauserv" -ErrorAction Stop
        Write-Log "Windows Update service started successfully"
        return $true
    } catch {
        Write-Log "Failed to start Windows Update service: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Get-AvailableUpdates {
    """Get list of available Windows updates"""
    Write-Log "Checking for available updates..."
    
    try {
        # Use Windows Update API
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        
        Write-Log "Searching for updates..."
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        if ($SearchResult.Updates.Count -eq 0) {
            Write-Log "No updates available"
            return @()
        }
        
        $Updates = @()
        foreach ($Update in $SearchResult.Updates) {
            $UpdateInfo = [PSCustomObject]@{
                Title = $Update.Title
                Size = [math]::Round($Update.MaxDownloadSize / 1MB, 2)
                IsOptional = $Update.IsHidden
                KBArticleIDs = $Update.KBArticleIDs -join ", "
                Description = $Update.Description
            }
            $Updates += $UpdateInfo
        }
        
        Write-Log "Found $($Updates.Count) available updates"
        return $Updates
        
    } catch {
        Write-Log "Error checking for updates: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Install-AvailableUpdates {
    """Install available Windows updates"""
    Write-Log "Starting update installation..."
    
    try {
        # Create update session
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        
        # Search for updates
        $SearchCriteria = if ($IncludeOptional) {
            "IsInstalled=0 and Type='Software'"
        } else {
            "IsInstalled=0 and Type='Software' and IsHidden=0"
        }
        
        $SearchResult = $UpdateSearcher.Search($SearchCriteria)
        
        if ($SearchResult.Updates.Count -eq 0) {
            Write-Log "No updates to install"
            return
        }
        
        # Create update collection
        $UpdatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
        foreach ($Update in $SearchResult.Updates) {
            if ($Update.EulaAccepted -eq $false) {
                $Update.AcceptEula()
            }
            $UpdatesToInstall.Add($Update) | Out-Null
        }
        
        # Download updates
        Write-Log "Downloading $($UpdatesToInstall.Count) updates..."
        $Downloader = $UpdateSession.CreateUpdateDownloader()
        $Downloader.Updates = $UpdatesToInstall
        $DownloadResult = $Downloader.Download()
        
        if ($DownloadResult.ResultCode -eq 2) {
            Write-Log "Updates downloaded successfully"
            
            # Install updates
            Write-Log "Installing updates..."
            $Installer = $UpdateSession.CreateUpdateInstaller()
            $Installer.Updates = $UpdatesToInstall
            $InstallationResult = $Installer.Install()
            
            if ($InstallationResult.ResultCode -eq 2) {
                Write-Log "Updates installed successfully"
                
                if ($InstallationResult.RebootRequired) {
                    Write-Log "Reboot required to complete installation" "WARN"
                    Write-Output "REBOOT REQUIRED"
                }
            } else {
                Write-Log "Update installation failed with code: $($InstallationResult.ResultCode)" "ERROR"
            }
        } else {
            Write-Log "Update download failed with code: $($DownloadResult.ResultCode)" "ERROR"
        }
        
    } catch {
        Write-Log "Error during update installation: $($_.Exception.Message)" "ERROR"
    }
}

# Main execution
Write-Log "Windows Update Management Script Started"

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "Script must be run as Administrator" "ERROR"
    exit 1
}

# Ensure Windows Update service is running
if (-not (Test-UpdateService)) {
    if (-not (Start-UpdateService)) {
        Write-Log "Cannot proceed without Windows Update service" "ERROR"
        exit 1
    }
}

# Execute requested action
if ($CheckOnly) {
    Write-Log "Checking for available updates only"
    $Updates = Get-AvailableUpdates
    
    if ($Updates.Count -gt 0) {
        Write-Output "`nAvailable Updates:"
        Write-Output "=================="
        $Updates | Format-Table -AutoSize
    }
    
} elseif ($InstallUpdates) {
    Write-Log "Installing available updates"
    $Updates = Get-AvailableUpdates
    
    if ($Updates.Count -gt 0) {
        Write-Output "`nInstalling $($Updates.Count) updates..."
        Install-AvailableUpdates
    } else {
        Write-Output "No updates available to install"
    }
    
} else {
    Write-Output "Windows Update Management Script"
    Write-Output "Usage:"
    Write-Output "  -CheckOnly        Check for updates only"
    Write-Output "  -InstallUpdates   Install all available updates"  
    Write-Output "  -IncludeOptional  Include optional updates"
}

Write-Log "Windows Update Management Script Completed"