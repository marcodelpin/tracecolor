#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows Service Monitoring and Management Tool
    
.DESCRIPTION
    Monitors critical Windows services, automatically restarts failed services,
    and provides detailed service health reporting with alerting capabilities.
    
.PARAMETER Services
    Array of service names to monitor
    
.PARAMETER RestartFailed
    Automatically restart failed services
    
.PARAMETER ContinuousMode
    Run in continuous monitoring mode
    
.PARAMETER CheckInterval
    Interval in seconds for continuous monitoring (default: 300)
    
.EXAMPLE
    .\service-monitor.ps1 -Services @("Spooler", "BITS", "Themes") -RestartFailed
    Monitor specific services and restart if failed
    
.EXAMPLE
    .\service-monitor.ps1 -ContinuousMode -CheckInterval 60
    Run continuous monitoring with 1-minute intervals
#>

param(
    [string[]]$Services = @("Spooler", "BITS", "Themes", "AudioSrv", "Dhcp", "EventLog", "PlugPlay", "RpcSs", "Winmgmt"),
    [switch]$RestartFailed,
    [switch]$ContinuousMode,
    [int]$CheckInterval = 300
)

# Configure logging
$LogFile = "ServiceMonitor.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp][$Level] $Message"
    Write-Output $LogEntry
    Add-Content -Path $LogFile -Value $LogEntry
}function Test-ServiceHealth {
    """Check health status of specified services"""
    Write-Log "Checking service health..."
    
    $ServiceStatus = @()
    $FailedServices = @()
    $RestartedServices = @()
    
    foreach ($ServiceName in $Services) {
        try {
            $Service = Get-Service -Name $ServiceName -ErrorAction Stop
            
            $Status = [PSCustomObject]@{
                Name = $Service.Name
                DisplayName = $Service.DisplayName
                Status = $Service.Status
                StartType = $Service.StartType
                CanStop = $Service.CanStop
                CanRestart = $Service.CanStop
                Health = "Unknown"
                Action = "None"
            }
            
            # Determine health status
            if ($Service.Status -eq "Running") {
                if ($Service.StartType -in @("Automatic", "AutomaticDelayedStart")) {
                    $Status.Health = "Healthy"
                } else {
                    $Status.Health = "Running (Manual)"
                }
            } elseif ($Service.Status -eq "Stopped") {
                if ($Service.StartType -in @("Automatic", "AutomaticDelayedStart")) {
                    $Status.Health = "Failed"
                    $FailedServices += $ServiceName
                    
                    # Attempt restart if enabled
                    if ($RestartFailed) {
                        try {
                            Write-Log "Attempting to restart service: $ServiceName" "WARN"
                            Start-Service -Name $ServiceName -ErrorAction Stop
                            
                            # Wait and verify restart
                            Start-Sleep -Seconds 5
                            $RestartedService = Get-Service -Name $ServiceName
                            if ($RestartedService.Status -eq "Running") {
                                Write-Log "Successfully restarted service: $ServiceName"
                                $Status.Status = "Running"
                                $Status.Health = "Healthy (Restarted)"
                                $Status.Action = "Restarted"
                                $RestartedServices += $ServiceName
                            } else {
                                Write-Log "Failed to restart service: $ServiceName" "ERROR"
                                $Status.Action = "Restart Failed"
                            }
                            
                        } catch {
                            Write-Log "Error restarting service $ServiceName: $($_.Exception.Message)" "ERROR"
                            $Status.Action = "Restart Error"
                        }
                    }
                } else {
                    $Status.Health = "Stopped (Manual)"
                }
            } else {
                $Status.Health = "Transitioning"
            }
            
            $ServiceStatus += $Status
            
        } catch {
            Write-Log "Error checking service $ServiceName: $($_.Exception.Message)" "ERROR"
            $ServiceStatus += [PSCustomObject]@{
                Name = $ServiceName
                DisplayName = "Service Not Found"
                Status = "NotFound"
                StartType = "Unknown"
                CanStop = $false
                CanRestart = $false
                Health = "Missing"
                Action = "None"
            }
            $FailedServices += $ServiceName
        }
    }
    
    return @{
        ServiceStatus = $ServiceStatus
        FailedServices = $FailedServices
        RestartedServices = $RestartedServices
    }
}function Get-ServiceDependencies {
    """Get service dependencies for critical services"""
    Write-Log "Checking service dependencies..."
    
    try {
        $DependencyInfo = @()
        
        foreach ($ServiceName in $Services) {
            $Service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($Service) {
                $Dependencies = $Service.ServicesDependedOn
                $Dependents = $Service.DependentServices
                
                $DependencyInfo += [PSCustomObject]@{
                    ServiceName = $Service.Name
                    DependsOn = if ($Dependencies.Count -gt 0) { $Dependencies.Name -join ", " } else { "None" }
                    DependentServices = if ($Dependents.Count -gt 0) { $Dependents.Name -join ", " } else { "None" }
                    DependencyCount = $Dependencies.Count
                    DependentCount = $Dependents.Count
                }
            }
        }
        
        return $DependencyInfo
        
    } catch {
        Write-Log "Error getting service dependencies: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Show-ServiceReport {
    """Display formatted service monitoring report"""
    param($MonitoringResult)
    
    $ServiceStatus = $MonitoringResult.ServiceStatus
    $FailedServices = $MonitoringResult.FailedServices
    $RestartedServices = $MonitoringResult.RestartedServices
    
    Write-Output ""
    Write-Output "SERVICE MONITORING REPORT"
    Write-Output "=" * 60
    Write-Output "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Output "Services Monitored: $($Services.Count)"
    Write-Output "Failed Services: $($FailedServices.Count)"
    if ($RestartedServices.Count -gt 0) {
        Write-Output "Restarted Services: $($RestartedServices.Count)"
    }
    Write-Output ""
    
    # Service status table
    Write-Output "SERVICE STATUS DETAILS"
    Write-Output "-" * 60
    Write-Output "Service Name".PadRight(20) + "Status".PadRight(12) + "Health".PadRight(15) + "Action"
    Write-Output "-" * 60
    
    foreach ($Service in $ServiceStatus) {
        $StatusColor = switch ($Service.Health) {
            "Healthy" { "Green" }
            "Failed" { "Red" }
            "Missing" { "Red" }
            default { "Yellow" }
        }
        
        $StatusLine = $Service.Name.PadRight(20) + $Service.Status.ToString().PadRight(12) + $Service.Health.PadRight(15) + $Service.Action
        Write-Output $StatusLine
    }
    
    # Summary
    $HealthyCount = ($ServiceStatus | Where-Object { $_.Health -eq "Healthy" -or $_.Health -eq "Healthy (Restarted)" }).Count
    $FailedCount = ($ServiceStatus | Where-Object { $_.Health -in @("Failed", "Missing") }).Count
    $OtherCount = $ServiceStatus.Count - $HealthyCount - $FailedCount
    
    Write-Output ""
    Write-Output "SUMMARY"
    Write-Output "-" * 20
    Write-Output "Healthy Services: $HealthyCount"
    Write-Output "Failed Services: $FailedCount"
    Write-Output "Other Status: $OtherCount"
    
    if ($FailedServices.Count -gt 0) {
        Write-Output ""
        Write-Output "FAILED SERVICES: $($FailedServices -join ', ')"
    }
    
    if ($RestartedServices.Count -gt 0) {
        Write-Output ""
        Write-Output "RESTARTED SERVICES: $($RestartedServices -join ', ')"
    }
}# Main execution
Write-Log "Service Monitor Started"

# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Log "Script must be run as Administrator" "ERROR"
    Write-Output "ERROR: This script requires Administrator privileges"
    Write-Output "Please run PowerShell as Administrator and try again"
    exit 1
}

Write-Output "Windows Service Monitor"
Write-Output "======================"
Write-Output ""
Write-Output "Monitoring Services: $($Services -join ', ')"
if ($RestartFailed) { Write-Output "Auto-restart: Enabled" }
if ($ContinuousMode) { Write-Output "Continuous Mode: $CheckInterval seconds interval" }
Write-Output ""

# Continuous monitoring mode
if ($ContinuousMode) {
    Write-Output "Starting continuous monitoring mode..."
    Write-Output "Press Ctrl+C to stop monitoring"
    Write-Output ""
    
    $IterationCount = 0
    
    try {
        while ($true) {
            $IterationCount++
            Write-Log "Starting monitoring iteration #$IterationCount"
            
            # Perform service health check
            $MonitoringResult = Test-ServiceHealth
            
            # Show report
            Show-ServiceReport -MonitoringResult $MonitoringResult
            
            # Log results
            if ($MonitoringResult.FailedServices.Count -gt 0) {
                Write-Log "Iteration #$IterationCount: $($MonitoringResult.FailedServices.Count) services failed" "WARN"
            } else {
                Write-Log "Iteration #$IterationCount: All services healthy"
            }
            
            if ($MonitoringResult.RestartedServices.Count -gt 0) {
                Write-Log "Iteration #$IterationCount: Restarted services: $($MonitoringResult.RestartedServices -join ', ')"
            }
            
            # Wait for next check
            Write-Output ""
            Write-Output "Next check in $CheckInterval seconds... (Ctrl+C to stop)"
            Start-Sleep -Seconds $CheckInterval
            
            # Clear screen for next iteration
            Clear-Host
        }
        
    } catch [System.OperationCanceledException] {
        Write-Output ""
        Write-Output "Monitoring stopped by user"
        Write-Log "Continuous monitoring stopped by user"
    } catch {
        Write-Log "Error in continuous monitoring: $($_.Exception.Message)" "ERROR"
        Write-Output "ERROR: $($_.Exception.Message)"
    }
    
} else {
    # Single check mode
    Write-Log "Performing single service health check"
    
    $MonitoringResult = Test-ServiceHealth
    Show-ServiceReport -MonitoringResult $MonitoringResult
    
    # Show dependencies if requested (detailed mode)
    if ($Services.Count -le 10) {
        $Dependencies = Get-ServiceDependencies
        if ($Dependencies.Count -gt 0) {
            Write-Output ""
            Write-Output "SERVICE DEPENDENCIES"
            Write-Output "-" * 40
            foreach ($Dep in $Dependencies) {
                Write-Output "$($Dep.ServiceName):"
                Write-Output "  Depends On: $($Dep.DependsOn)"
                Write-Output "  Dependents: $($Dep.DependentServices)"
            }
        }
    }
}

Write-Output ""
Write-Log "Service Monitor Completed"