# System Tools & Monitoring Utilities

General-purpose system administration and monitoring tools for Windows environments.

## Overview
- System health monitoring and diagnostics
- Disk usage analysis and cleanup utilities  
- Performance monitoring and optimization
- Service management and automation
- Log analysis and system reporting

## Scripts

### Monitoring & Diagnostics
- `system-health-check.ps1` - Comprehensive system diagnostics and health reporting
- `service-monitor.ps1` - Monitor critical Windows services and restart if needed
- `performance-monitor.ps1` - Track system performance metrics and generate reports

### Disk Management
- `disk-analysis.ps1` - Comprehensive disk usage analysis and reporting
- `disk-cleanup.ps1` - Automated disk cleanup and optimization
- `storage-monitor.ps1` - Monitor disk space and alert on low storage

### Log Analysis
- `log-analyzer.ps1` - Parse and analyze Windows event logs
- `error-scanner.ps1` - Scan system logs for critical errors and patterns
- `log-cleanup.ps1` - Automated log rotation and cleanup

### Service Management
- `service-manager.ps1` - Comprehensive Windows service management
- `startup-manager.ps1` - Manage Windows startup programs and services

## Usage Examples

```powershell
# System diagnostics
.\system-health-check.ps1 -Detailed
.\performance-monitor.ps1 -Duration 24

# Disk management
.\disk-analysis.ps1 -Path "C:\" -GenerateReport
.\disk-cleanup.ps1 -DeepClean

# Service monitoring
.\service-monitor.ps1 -Services @("Spooler", "BITS", "Themes")
```

## Monitoring Schedules
- System health checks: Daily at 2 AM
- Disk space monitoring: Every 4 hours
- Service monitoring: Continuous with 5-minute intervals
- Performance monitoring: Weekly reports

## Safety Notes
- Run with Administrator privileges for full system access
- Review cleanup operations before executing
- Monitor system resources during intensive operations
- Keep monitoring logs for historical analysis