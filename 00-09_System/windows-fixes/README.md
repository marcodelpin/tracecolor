# Windows System Troubleshooting & Maintenance

Collection of scripts and tools for Windows system maintenance, troubleshooting, and update management.

## Overview
- Windows Update management and troubleshooting  
- System health monitoring and diagnostics
- Common problem resolution scripts
- Performance optimization tools

## Scripts

### Windows Update Management
- `manage_windows_updates.ps1` - Comprehensive Windows Update management
- `windows-update-troubleshoot.ps1` - Fix common update issues
- `update-checker.bat` - Quick update status check

### System Maintenance
- `disk-cleanup.ps1` - Automated disk cleanup and optimization
- `system-health-check.ps1` - Comprehensive system diagnostics
- `registry-cleanup.ps1` - Safe registry maintenance

### Problem Resolution
- `parsec-usb-driver-removal.ps1` - Remove problematic Parsec virtual USB drivers
- `audio-fix.ps1` - Resolve Windows audio issues
- `network-reset.ps1` - Network troubleshooting and reset

## Recent Issues Resolved
- **Parsec Virtual USB Driver**: Removal to eliminate system audio issues and Windows Update errors
- **Windows Update Errors**: Automated troubleshooting for common update failures
- **System Performance**: Disk cleanup and registry optimization

## Usage Examples

```powershell
# Windows Update management
.\manage_windows_updates.ps1 -CheckOnly
.\manage_windows_updates.ps1 -InstallUpdates

# System maintenance
.\system-health-check.ps1 -Detailed
.\disk-cleanup.ps1 -DeepClean

# Problem resolution
.\parsec-usb-driver-removal.ps1
```

## Safety Notes
- Run scripts as Administrator
- Create system restore point before major changes
- Review script contents before execution
- Test on non-critical systems first