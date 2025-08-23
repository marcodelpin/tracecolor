#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Comprehensive Disk Usage Analysis Tool
    
.DESCRIPTION
    Analyzes disk usage, identifies large files and directories,
    and provides detailed storage utilization reports.
    
.PARAMETER Path
    Root path to analyze (default: C:\)
    
.PARAMETER GenerateReport
    Generate detailed report file
    
.PARAMETER TopDirectories
    Number of top directories to analyze (default: 20)
    
.PARAMETER MinFileSize
    Minimum file size in MB for large file analysis (default: 100)
    
.EXAMPLE
    .\disk-analysis.ps1 -Path "C:\" -GenerateReport
    Analyze C: drive and generate detailed report
    
.EXAMPLE
    .\disk-analysis.ps1 -Path "D:\Projects" -TopDirectories 50
    Analyze specific directory with extended top directories list
#>

param(
    [string]$Path = "C:\",
    [switch]$GenerateReport,
    [int]$TopDirectories = 20,
    [int]$MinFileSize = 100
)

# Configure logging
$LogFile = "DiskAnalysis.log"
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
    $global:ReportContent += "=" * 80
    $global:ReportContent += $Title
    $global:ReportContent += "=" * 80
    $global:ReportContent += $Content
    $global:ReportContent += ""
}function Get-DirectorySize {
    """Calculate directory size including subdirectories"""
    param([string]$DirectoryPath)
    
    try {
        $Size = (Get-ChildItem -Path $DirectoryPath -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        return [math]::Max($Size, 0)
    } catch {
        return 0
    }
}

function Get-TopDirectories {
    """Get top directories by size"""
    Write-Log "Analyzing directory sizes in: $Path"
    
    try {
        $Directories = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue
        $DirectoryInfo = @()
        
        $Counter = 0
        foreach ($Dir in $Directories) {
            $Counter++
            Write-Progress -Activity "Analyzing Directories" -Status "Processing: $($Dir.Name)" -PercentComplete (($Counter / $Directories.Count) * 100)
            
            $Size = Get-DirectorySize -DirectoryPath $Dir.FullName
            $SizeGB = [math]::Round($Size / 1GB, 2)
            $SizeMB = [math]::Round($Size / 1MB, 1)
            
            $DirectoryInfo += [PSCustomObject]@{
                Name = $Dir.Name
                FullPath = $Dir.FullName
                SizeBytes = $Size
                SizeGB = $SizeGB
                SizeMB = $SizeMB
                LastModified = $Dir.LastWriteTime
            }
        }
        
        Write-Progress -Completed
        return $DirectoryInfo | Sort-Object SizeBytes -Descending | Select-Object -First $TopDirectories
        
    } catch {
        Write-Log "Error analyzing directories: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Get-LargeFiles {
    """Find large files in the analyzed path"""
    Write-Log "Finding large files (>$MinFileSize MB)..."
    
    try {
        $MinSizeBytes = $MinFileSize * 1MB
        $LargeFiles = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | 
                      Where-Object { $_.Length -gt $MinSizeBytes } |
                      Sort-Object Length -Descending |
                      Select-Object -First 50
        
        $FileInfo = @()
        foreach ($File in $LargeFiles) {
            $SizeGB = [math]::Round($File.Length / 1GB, 2)
            $SizeMB = [math]::Round($File.Length / 1MB, 1)
            
            $FileInfo += [PSCustomObject]@{
                Name = $File.Name
                FullPath = $File.FullName
                SizeGB = $SizeGB
                SizeMB = $SizeMB
                Extension = $File.Extension
                LastModified = $File.LastWriteTime
                Directory = $File.DirectoryName
            }
        }
        
        return $FileInfo
        
    } catch {
        Write-Log "Error finding large files: $($_.Exception.Message)" "ERROR"
        return @()
    }
}function Get-FileTypeAnalysis {
    """Analyze file types and their disk usage"""
    Write-Log "Analyzing file types..."
    
    try {
        $Files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
        $FileTypes = $Files | Group-Object Extension | Sort-Object Count -Descending
        
        $FileTypeInfo = @()
        foreach ($Type in $FileTypes | Select-Object -First 20) {
            $TotalSize = ($Files | Where-Object Extension -eq $Type.Name | Measure-Object Length -Sum).Sum
            $SizeGB = [math]::Round($TotalSize / 1GB, 2)
            $SizeMB = [math]::Round($TotalSize / 1MB, 1)
            
            $FileTypeInfo += [PSCustomObject]@{
                Extension = if ($Type.Name) { $Type.Name } else { "(no extension)" }
                FileCount = $Type.Count
                TotalSizeGB = $SizeGB
                TotalSizeMB = $SizeMB
                AvgSizeMB = [math]::Round($SizeMB / $Type.Count, 2)
            }
        }
        
        return $FileTypeInfo
        
    } catch {
        Write-Log "Error analyzing file types: $($_.Exception.Message)" "ERROR"
        return @()
    }
}

function Get-DiskSummary {
    """Get overall disk space summary"""
    Write-Log "Getting disk space summary..."
    
    try {
        $DiskInfo = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq ($Path.Substring(0,2)) }
        
        if ($DiskInfo) {
            $TotalSizeGB = [math]::Round($DiskInfo.Size / 1GB, 2)
            $FreeSpaceGB = [math]::Round($DiskInfo.FreeSpace / 1GB, 2)
            $UsedSpaceGB = $TotalSizeGB - $FreeSpaceGB
            $UsedPercent = [math]::Round(($UsedSpaceGB / $TotalSizeGB) * 100, 1)
            $FreePercent = [math]::Round(($FreeSpaceGB / $TotalSizeGB) * 100, 1)
            
            return [PSCustomObject]@{
                Drive = $DiskInfo.DeviceID
                TotalSize = "$TotalSizeGB GB"
                UsedSpace = "$UsedSpaceGB GB ($UsedPercent%)"
                FreeSpace = "$FreeSpaceGB GB ($FreePercent%)"
                FileSystem = $DiskInfo.FileSystem
                DriveType = switch ($DiskInfo.DriveType) {
                    3 { "Local Disk" }
                    4 { "Network Drive" }
                    5 { "CD-ROM" }
                    default { "Unknown" }
                }
            }
        }
        
        return $null
        
    } catch {
        Write-Log "Error getting disk summary: $($_.Exception.Message)" "ERROR"
        return $null
    }
}# Main execution
Write-Log "Disk Analysis Started for: $Path"

# Validate path
if (-not (Test-Path $Path)) {
    Write-Log "Path not found: $Path" "ERROR"
    Write-Output "ERROR: Path not found: $Path"
    exit 1
}

Write-Output "Disk Usage Analysis"
Write-Output "=================="
Write-Output "Analyzing: $Path"
Write-Output "Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output ""

# Get disk summary
$DiskSummary = Get-DiskSummary
if ($DiskSummary) {
    Add-ReportSection "DISK SUMMARY" @(
        "Drive: $($DiskSummary.Drive)",
        "File System: $($DiskSummary.FileSystem)",
        "Drive Type: $($DiskSummary.DriveType)",
        "Total Size: $($DiskSummary.TotalSize)",
        "Used Space: $($DiskSummary.UsedSpace)",
        "Free Space: $($DiskSummary.FreeSpace)"
    )
}

# Analyze top directories
Write-Output "Analyzing directory sizes..."
$TopDirs = Get-TopDirectories

if ($TopDirs.Count -gt 0) {
    $DirAnalysis = @()
    $DirAnalysis += "Rank | Directory Name | Size (GB) | Size (MB) | Last Modified"
    $DirAnalysis += "-" * 80
    
    $Rank = 1
    foreach ($Dir in $TopDirs) {
        $DirAnalysis += "$($Rank.ToString().PadLeft(4)) | $($Dir.Name.PadRight(30).Substring(0,[Math]::Min(30,$Dir.Name.Length))) | $($Dir.SizeGB.ToString().PadLeft(8)) | $($Dir.SizeMB.ToString().PadLeft(9)) | $($Dir.LastModified.ToString('yyyy-MM-dd'))"
        $Rank++
    }
    
    Add-ReportSection "TOP DIRECTORIES BY SIZE" $DirAnalysis
}

# Find large files
Write-Output "Finding large files..."
$LargeFiles = Get-LargeFiles

if ($LargeFiles.Count -gt 0) {
    $FileAnalysis = @()
    $FileAnalysis += "File Name | Size (GB) | Size (MB) | Extension | Directory"
    $FileAnalysis += "-" * 100
    
    foreach ($File in $LargeFiles | Select-Object -First 20) {
        $FileName = if ($File.Name.Length -gt 25) { $File.Name.Substring(0,22) + "..." } else { $File.Name }
        $DirName = if ($File.Directory.Length -gt 30) { "..." + $File.Directory.Substring($File.Directory.Length-27) } else { $File.Directory }
        $FileAnalysis += "$($FileName.PadRight(25)) | $($File.SizeGB.ToString().PadLeft(8)) | $($File.SizeMB.ToString().PadLeft(9)) | $($File.Extension.PadRight(10)) | $DirName"
    }
    
    Add-ReportSection "LARGE FILES (>$MinFileSize MB)" $FileAnalysis
}# Analyze file types
Write-Output "Analyzing file types..."
$FileTypes = Get-FileTypeAnalysis

if ($FileTypes.Count -gt 0) {
    $TypeAnalysis = @()
    $TypeAnalysis += "Extension | File Count | Total Size (GB) | Total Size (MB) | Avg Size (MB)"
    $TypeAnalysis += "-" * 80
    
    foreach ($Type in $FileTypes | Select-Object -First 15) {
        $TypeAnalysis += "$($Type.Extension.PadRight(10)) | $($Type.FileCount.ToString().PadLeft(10)) | $($Type.TotalSizeGB.ToString().PadLeft(14)) | $($Type.TotalSizeMB.ToString().PadLeft(14)) | $($Type.AvgSizeMB.ToString().PadLeft(12))"
    }
    
    Add-ReportSection "FILE TYPE ANALYSIS" $TypeAnalysis
}

# Generate summary statistics
$TotalDirectories = $TopDirs.Count
$TotalLargeFiles = $LargeFiles.Count
$TotalAnalyzedSize = ($TopDirs | Measure-Object SizeBytes -Sum).Sum
$TotalAnalyzedGB = [math]::Round($TotalAnalyzedSize / 1GB, 2)

Add-ReportSection "ANALYSIS SUMMARY" @(
    "Analysis Path: $Path",
    "Directories Analyzed: $TotalDirectories",
    "Large Files Found: $TotalLargeFiles (>$MinFileSize MB)",
    "Top Directories Total Size: $TotalAnalyzedGB GB",
    "File Types Identified: $($FileTypes.Count)",
    "Analysis Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

# Output results
Write-Output ""
Write-Output "ANALYSIS RESULTS"
Write-Output "================"
foreach ($Line in $ReportContent) {
    Write-Output $Line
}

# Generate report file if requested
if ($GenerateReport) {
    $ReportFile = "DiskAnalysis_$((Get-Date -Format 'yyyyMMdd_HHmmss')).txt"
    try {
        $ReportHeader = @(
            "DISK USAGE ANALYSIS REPORT",
            "=" * 50,
            "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
            "Analysis Path: $Path",
            "Parameters: TopDirectories=$TopDirectories, MinFileSize=$MinFileSize MB",
            ""
        )
        
        ($ReportHeader + $ReportContent) | Out-File -FilePath $ReportFile -Encoding UTF8
        Write-Output ""
        Write-Output "Detailed report saved to: $ReportFile"
        Write-Log "Report saved to: $ReportFile"
        
    } catch {
        Write-Log "Error saving report: $($_.Exception.Message)" "ERROR"
    }
}

Write-Output ""
Write-Output "Analysis completed. Large directories and files identified."
Write-Output "Consider cleaning up unnecessary files to free disk space."

Write-Log "Disk Analysis Completed for: $Path"