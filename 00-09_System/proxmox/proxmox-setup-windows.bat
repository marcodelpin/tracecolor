@echo off
REM Proxmox Admin User Setup - Windows Launcher
REM Target: 192.168.71.6 (MDP-HOME-OLD)

echo ======================================
echo Proxmox VE Admin User Setup
echo ======================================
echo.
echo Target Server: 192.168.71.6
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator - OK
) else (
    echo ERROR: Please run as Administrator
    pause
    exit /b 1
)

echo.
echo This script will:
echo 1. Setup SSH connection to Proxmox server
echo 2. Create admin user with limited privileges
echo 3. Configure SSH key authentication
echo.

set /p confirm="Continue? (y/n): "
if /i not "%confirm%"=="y" (
    echo Cancelled by user
    pause
    exit /b 0
)

echo.
echo Connecting to Proxmox server...
echo.

REM Use WSL if available, otherwise use built-in SSH
where wsl >nul 2>&1
if %errorLevel% == 0 (
    echo Using WSL for SSH connection...
    wsl ssh root@192.168.71.6 "bash -s" < proxmox-user-setup.sh
) else (
    echo Using Windows SSH...
    ssh root@192.168.71.6 "bash -s" < proxmox-user-setup.sh
)

if %errorLevel% == 0 (
    echo.
    echo ======================================
    echo Setup completed successfully!
    echo ======================================
) else (
    echo.
    echo ======================================
    echo Setup failed - check connection
    echo ======================================
)

pause