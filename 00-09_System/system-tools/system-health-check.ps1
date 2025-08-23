#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Comprehensive Windows System Health Check
    
.DESCRIPTION
    Performs detailed system health diagnostics including hardware status,
    service health, disk space, memory usage, and critical system components.
    
.PARAMETER Detailed
    Generate detailed report with extended diagnostics
    
.PARAMETER OutputFile
    Path to save the health report
    
.PARAMETER CheckServices
    List of specific services to monitor
    
.EXAMPLE
    .\system-health-check.ps1 -Detailed
    Perform comprehensive system health check with detailed output
    
.EXAMPLE
    .\system-health-check.ps1 -OutputFile "C:\Reports\health.txt"
    Save health report to specified file
#>

param(
    [switch]$Detailed,
    [string]$OutputFile,
    [string[]]$CheckServices = @("Spooler", "BITS", "Themes", "AudioSrv", "Dhcp")
)

# Configure logging
$LogFile = "SystemHealthCheck.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$ReportContent = @()

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $LogEntry = "[$Timestamp][$Level] $Message"
    Write-Output $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}

function Add-ReportSection {
    param([string]$Title, [array]$Content)
    $global:ReportContent += ""
    $global:ReportContent += "=" * 60
    $global:ReportContent += $Title
    $global:ReportContent += "=" * 60
    $global:ReportContent += $Content
    $global:ReportContent += ""
}function Get-SystemInfo {
    """Get basic system information"""
    Write-Log "Gathering system information..."
    
    try {
        $OS = Get-CimInstance -ClassName Win32_OperatingSystem
        $Computer = Get-CimInstance -ClassName Win32_ComputerSystem
        $Processor = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
        
        $SystemInfo = [PSCustomObject]@{
            ComputerName = $Computer.Name
            Domain = $Computer.Domain
            OSVersion = $OS.Caption
            OSBuild = $OS.BuildNumber
            Architecture = $OS.OSArchitecture
            TotalRAM = [math]::Round($Computer.TotalPhysicalMemory / 1GB, 2)
            Processor = $Processor.Name
            ProcessorCores = $Processor.NumberOfCores
            ProcessorLogical = $Processor.NumberOfLogicalProcessors
            Uptime = (Get-Date) - $OS.LastBootUpTime
        }
        
        return $SystemInfo
        
    } catch {
        Write-Log "Error gathering system information: $($_.Exception.Message)" "ERROR"
        return $null
    }
}

function Get-DiskHealthStatus {
    """Check disk health and space usage"""
    Write-Log "Checking disk health status..."
    
    try {
        $Disks = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
        $DiskInfo = @()
        
        foreach ($Disk in $Disks) {
            $FreeSpaceGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
            $TotalSizeGB = [math]::Round($Disk.Size / 1GB, 2)
            $UsedSpaceGB = $TotalSizeGB - $FreeSpaceGB
            $FreePercent = [math]::Round(($FreeSpaceGB / $TotalSizeGB) * 100, 1)
            
            $Status = if ($FreePercent -lt 10) { "CRITICAL" }
                     elseif ($FreePercent -lt 20) { "WARNING" }
                     else { "OK" }
            
            $DiskInfo += [PSCustomObject]@{
                Drive = $Disk.DeviceID
                TotalSize = "$TotalSizeGB GB"
                FreeSpace = "$FreeSpaceGB GB"
                UsedSpace = "$UsedSpaceGB GB"
                FreePercent = "$FreePercent%"
                Status = $Status
            }
        }
        
        return $DiskInfo
        
    } catch {
        Write-Log "Error checking disk health: $($_.Exception.Message)" "ERROR"
        return @()
    }
}function Get-ServiceStatus {
    """Check status of critical Windows services"""
    Write-Log "Checking service status..."
    
    try {
        $ServiceInfo = @()
        
        foreach ($ServiceName in $CheckServices) {
            $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($Service) {
                $ServiceInfo += [PSCustomObject]@{
                    Name = $Service.Name
                    DisplayName = $Service.DisplayName
                    Status = $Service.Status
                    StartType = $Service.StartType
                    Health = if ($Service.Status -eq "Running") { "OK" } else { "ISSUE" }
                }
            } else {
                $ServiceInfo += [PSCustomObject]@{
                    Name = $ServiceName
                    DisplayName = "Service Not Found"
                    Status = "NotFound"
                    StartType = "Unknown"
                    Health = "MISSING"
                }
            }
        }
        
        return $ServiceInfo
        
    } catch {
        Write-Log "Error checking service status: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Get-MemoryStatus {
    """Get memory usage information"""
    Write-Log "Checking memory status..."
    
    try {
        $OS = Get-CimInstance -ClassName Win32_OperatingSystem
        $TotalMemory = $OS.TotalVisibleMemorySize * 1KB
        $FreeMemory = $OS.FreePhysicalMemory * 1KB
        $UsedMemory = $TotalMemory - $FreeMemory
        
        $MemoryPercent = [math]::Round(($UsedMemory / $TotalMemory) * 100, 1)
        $Status = if ($MemoryPercent -gt 90) { "CRITICAL" }
                  elseif ($MemoryPercent -gt 80) { "WARNING" }
                  else { "OK" }
        
        return [PSCustomObject]@{
            TotalMemory = [math]::Round($TotalMemory / 1GB, 2)
            UsedMemory = [math]::Round($UsedMemory / 1GB, 2)
            FreeMemory = [math]::Round($FreeMemory / 1GB, 2)
            UsedPercent = "$MemoryPercent%"
            Status = $Status
        }
        
    } catch {
        Write-Log "Error checking memory status: $($_.Exception.Message)" "ERROR"
        return $null
    }
}function Get-EventLogErrors {
    """Check for recent critical errors in event logs"""
    Write-Log "Checking event log errors..."
    
    try {
        $StartTime = (Get-Date).AddHours(-24)
        $ErrorEvents = @()
        
        # Check System log
        $SystemErrors = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            Level = 1,2  # Critical and Error
            StartTime = $StartTime
        } -MaxEvents 50 -ErrorAction SilentlyContinue
        
        if ($SystemErrors) {
            foreach ($Event in $SystemErrors) {
                $ErrorEvents += [PSCustomObject]@{
                    LogName = "System"
                    Level = switch ($Event.Level) { 1 {"Critical"} 2 {"Error"} default {"Other"} }
                    TimeCreated = $Event.TimeCreated
                    Id = $Event.Id
                    Source = $Event.ProviderName
                    Message = $Event.Message.Split("`n")[0].Substring(0, [Math]::Min(100, $Event.Message.Length))
                }
            }
        }
        
        return $ErrorEvents | Select-Object -First 10
        
    } catch {
        Write-Log "Error checking event logs: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Get-NetworkStatus {
    """Check network connectivity status"""
    Write-Log "Checking network status..."
    
    try {
        $NetworkTests = @(
            @{Name = "Internet (Google DNS)"; Target = "8.8.8.8"},
            @{Name = "Local Gateway"; Target = (Get-NetRoute | Where-Object DestinationPrefix -eq '0.0.0.0/0' | Select-Object -First 1).NextHop}
        )
        
        $NetworkResults = @()
        foreach ($Test in $NetworkTests) {
            if ($Test.Target) {
                $PingResult = Test-Connection -ComputerName $Test.Target -Count 2 -Quiet
                $NetworkResults += [PSCustomObject]@{
                    Target = $Test.Name
                    Address = $Test.Target
                    Status = if ($PingResult) { "OK" } else { "FAILED" }
                }
            }
        }
        
        return $NetworkResults
        
    } catch {
        Write-Log "Error checking network status: $($_.Exception.Message)" "ERROR"
        return @()
    }
}# Main execution
Write-Log "System Health Check Started"

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "Script must be run as Administrator" "ERROR"
    Write-Output "ERROR: This script requires Administrator privileges"
    Write-Output "Please run PowerShell as Administrator and try again"
    exit 1
}

Write-Output "Windows System Health Check"
Write-Output "=========================="
Write-Output ""

# Gather system information
$SystemInfo = Get-SystemInfo
if ($SystemInfo) {
    Add-ReportSection "SYSTEM INFORMATION" @(
        "Computer Name: $($SystemInfo.ComputerName)",
        "Domain: $($SystemInfo.Domain)",
        "Operating System: $($SystemInfo.OSVersion)",
        "Build Number: $($SystemInfo.OSBuild)",
        "Architecture: $($SystemInfo.Architecture)",
        "Total RAM: $($SystemInfo.TotalRAM) GB",
        "Processor: $($SystemInfo.Processor)",
        "Cores: $($SystemInfo.ProcessorCores) physical, $($SystemInfo.ProcessorLogical) logical",
        "System Uptime: $($SystemInfo.Uptime.Days) days, $($SystemInfo.Uptime.Hours) hours, $($SystemInfo.Uptime.Minutes) minutes"
    )
}

# Check disk health
$DiskInfo = Get-DiskHealthStatus
if ($DiskInfo) {
    $DiskStatus = @()
    $CriticalDisks = @()
    
    foreach ($Disk in $DiskInfo) {
        $DiskStatus += "$($Disk.Drive) $($Disk.TotalSize) - Used: $($Disk.UsedSpace), Free: $($Disk.FreeSpace) ($($Disk.FreePercent)) - $($Disk.Status)"
        if ($Disk.Status -in @("CRITICAL", "WARNING")) {
            $CriticalDisks += $Disk.Drive
        }
    }
    
    Add-ReportSection "DISK HEALTH STATUS" $DiskStatus
    
    if ($CriticalDisks.Count -gt 0) {
        Write-Output "WARNING: Low disk space detected on drives: $($CriticalDisks -join ', ')"
    }
}# Check memory status
$MemoryInfo = Get-MemoryStatus
if ($MemoryInfo) {
    Add-ReportSection "MEMORY STATUS" @(
        "Total Memory: $($MemoryInfo.TotalMemory) GB",
        "Used Memory: $($MemoryInfo.UsedMemory) GB ($($MemoryInfo.UsedPercent))",
        "Free Memory: $($MemoryInfo.FreeMemory) GB",
        "Status: $($MemoryInfo.Status)"
    )
    
    if ($MemoryInfo.Status -in @("CRITICAL", "WARNING")) {
        Write-Output "WARNING: High memory usage detected ($($MemoryInfo.UsedPercent))"
    }
}

# Check service status
$ServiceInfo = Get-ServiceStatus
if ($ServiceInfo) {
    $ServiceStatus = @()
    $FailedServices = @()
    
    foreach ($Service in $ServiceInfo) {
        $ServiceStatus += "$($Service.Name) ($($Service.DisplayName)) - Status: $($Service.Status) - Health: $($Service.Health)"
        if ($Service.Health -in @("ISSUE", "MISSING")) {
            $FailedServices += $Service.Name
        }
    }
    
    Add-ReportSection "SERVICE STATUS" $ServiceStatus
    
    if ($FailedServices.Count -gt 0) {
        Write-Output "WARNING: Service issues detected: $($FailedServices -join ', ')"
    }
}

# Check network status
$NetworkInfo = Get-NetworkStatus
if ($NetworkInfo) {
    $NetworkStatus = @()
    $FailedConnections = @()
    
    foreach ($Network in $NetworkInfo) {
        $NetworkStatus += "$($Network.Target) ($($Network.Address)) - Status: $($Network.Status)"
        if ($Network.Status -eq "FAILED") {
            $FailedConnections += $Network.Target
        }
    }
    
    Add-ReportSection "NETWORK STATUS" $NetworkStatus
    
    if ($FailedConnections.Count -gt 0) {
        Write-Output "WARNING: Network connectivity issues: $($FailedConnections -join ', ')"
    }
}# Check event log errors (only if detailed)
if ($Detailed) {
    $EventLogErrors = Get-EventLogErrors
    if ($EventLogErrors.Count -gt 0) {
        $ErrorStatus = @()
        foreach ($Error in $EventLogErrors) {
            $ErrorStatus += "[$($Error.TimeCreated)] $($Error.Level) - $($Error.Source) (ID: $($Error.Id)) - $($Error.Message)"
        }
        Add-ReportSection "RECENT CRITICAL ERRORS (Last 24h)" $ErrorStatus
        
        Write-Output "INFO: $($EventLogErrors.Count) recent critical/error events found"
    } else {
        Add-ReportSection "RECENT CRITICAL ERRORS (Last 24h)" @("No critical errors found in the last 24 hours")
    }
}

# Generate overall health summary
$OverallStatus = "HEALTHY"
$Issues = @()

if ($DiskInfo | Where-Object { $_.Status -in @("CRITICAL", "WARNING") }) {
    $OverallStatus = "WARNING"
    $Issues += "Disk space issues"
}

if ($MemoryInfo -and $MemoryInfo.Status -in @("CRITICAL", "WARNING")) {
    $OverallStatus = "WARNING"
    $Issues += "Memory usage high"
}

if ($ServiceInfo | Where-Object { $_.Health -in @("ISSUE", "MISSING") }) {
    $OverallStatus = "WARNING"
    $Issues += "Service issues"
}

if ($NetworkInfo | Where-Object { $_.Status -eq "FAILED" }) {
    $OverallStatus = "WARNING"
    $Issues += "Network connectivity problems"
}

Add-ReportSection "OVERALL HEALTH SUMMARY" @(
    "System Status: $OverallStatus",
    "Issues Found: $(if ($Issues.Count -gt 0) { $Issues -join ', ' } else { 'None' })",
    "Report Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

# Output results
Write-Output ""
foreach ($Line in $ReportContent) {
    Write-Output $Line
}

# Save to file if requested
if ($OutputFile) {
    try {
        $ReportContent | Out-File -FilePath $OutputFile -Encoding UTF8
        Write-Output ""
        Write-Output "Report saved to: $OutputFile"
        Write-Log "Report saved to: $OutputFile"
    } catch {
        Write-Log "Error saving report: $($_.Exception.Message)" "ERROR"
    }
}

Write-Log "System Health Check Completed - Status: $OverallStatus"