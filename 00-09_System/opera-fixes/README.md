# Opera Browser Fixes & Tools

Browser-specific problem resolution tools focusing on Opera browser issues and optimizations.

## Common Issues Resolved
- Profile corruption and reset procedures
- Extension conflicts and management
- Cache and data cleanup
- Performance optimization
- Update and installation problems

## Scripts

### Profile Management
- `opera-profile-reset.ps1` - Reset corrupted Opera profile
- `opera-profile-backup.ps1` - Backup Opera user data and settings
- `opera-clean-install.ps1` - Clean Opera installation procedure

### Cache & Data Management
- `opera-cache-cleanup.ps1` - Clear browser cache and temporary data
- `opera-data-reset.ps1` - Reset Opera user data selectively

### Extension Management  
- `opera-extension-cleanup.ps1` - Remove problematic extensions
- `opera-extension-backup.ps1` - Backup extension settings

## Usage Examples

```powershell
# Profile issues
.\opera-profile-reset.ps1 -BackupFirst
.\opera-profile-backup.ps1 -Destination "D:\Backups"

# Performance issues
.\opera-cache-cleanup.ps1 -DeepClean
.\opera-clean-install.ps1 -PreserveBookmarks
```

## Browser Data Locations
- **Profile**: `%APPDATA%\Opera Software\Opera Stable`
- **Cache**: `%APPDATA%\Opera Software\Opera Stable\Cache`
- **Extensions**: `%APPDATA%\Opera Software\Opera Stable\Extensions`
- **Bookmarks**: `%APPDATA%\Opera Software\Opera Stable\Bookmarks`

## Safety Notes
- Always backup important data before running fixes
- Close Opera completely before running scripts
- Test fixes on non-critical profiles first
- Keep bookmarks and passwords backed up separately