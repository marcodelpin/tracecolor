# Tracecolor UDP Monitor Launcher for PowerShell
# Usage: .\monitor.ps1 [-Port 8888] [-Host 0.0.0.0]

param(
    [int]$Port = 9999,
    [string]$Host = "127.0.0.1",
    [switch]$Help
)

if ($Help) {
    Write-Host "Tracecolor UDP Monitor Launcher"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\monitor.ps1                  # Default: localhost:9999"
    Write-Host "  .\monitor.ps1 -Port 8888       # Custom port"
    Write-Host "  .\monitor.ps1 -Host 0.0.0.0   # All interfaces"
    Write-Host "  .\monitor.ps1 -Port 8888 -Host 192.168.1.100"
    Write-Host ""
    exit 0
}

Write-Host "Starting Tracecolor UDP Monitor" -ForegroundColor Green
Write-Host "Listening on ${Host}:${Port}" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Cyan
Write-Host ""

python monitor.py --port $Port --host $Host