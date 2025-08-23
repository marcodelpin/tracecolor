# Proxmox VE Management Suite

Collection of scripts and tools for managing Proxmox Virtual Environment infrastructure.

## Target System
- **Proxmox Server**: 192.168.71.6 (MDP-HOME-OLD)
- **Specs**: 8 cores, 16GB RAM
- **OS**: Proxmox VE

## Tools Overview

### User Management
- `proxmox-setup-windows.bat` - Setup Proxmox admin user from Windows
- User creation with limited sudo privileges (`pvadmin`, `updater`)

### VM/Container Management  
- `proxmox-manage.ps1` - PowerShell VM management interface
- `proxmox-vm-management.sh` - Linux/WSL VM management script

### System Updates
- `proxmox-auto-update.sh` - Automated system updates with safety checks
- Update checking and maintenance routines

## Usage Examples

```bash
# Setup admin user (from Windows)
cd proxmox && proxmox-setup-windows.bat

# VM management (PowerShell)
.\proxmox-manage.ps1

# VM management (WSL/Linux)  
./proxmox-vm-management.sh

# System updates
./proxmox-auto-update.sh --check
```

## Security Model
- Dedicated users with limited sudo privileges
- SSH key-based authentication
- Backup recommendations before destructive operations