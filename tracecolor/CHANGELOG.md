# Changelog

All notable changes to tracecolor will be documented in this file.

## [0.7.0] - 2025-08-24

### BREAKING CHANGES
- Loguru is now a required dependency (no longer optional)
- Removed fallback to standard logging library
- colorlog dependency completely removed

### Added
- Git hooks for automatic NAS backup and Windows reserved names protection
- Monitor tools reorganized into tracecolor directory
- Quick launcher scripts (start_monitor.sh/bat) in root directory
- Comprehensive monitor documentation (MONITOR_USAGE.md)

### Changed
- Simplified codebase by removing dual backend support (341 lines vs 462)
- Monitor now colors only the log level character instead of entire line
- All monitor scripts updated for better cross-platform support
- setup.py entry point fixed for tracecolor-monitor command

### Fixed
- UDP socket now non-blocking to prevent hangs
- Monitor color output improved for better readability
- Windows batch scripts paths corrected

### Removed
- colorlog dependency (Loguru handles colors natively)
- Standard logging fallback code
- tracecolor_enhanced_backup.py (obsolete)

## [0.6.1] - 2025-08-23

### Fixed
- UDP logging implementation with non-blocking sockets
- Monitor plain text format handling

### Added
- Test files for UDP functionality
- Environment Guard System for conda environments

## [0.6.0] - 2025-08-22

### Added
- UDP remote monitoring support
- File logging with rotation and compression
- External configuration support (JSON/YAML)
- Loguru backend for enhanced performance

### Changed
- Dual backend support (Loguru preferred, logging fallback)

## [0.5.0] - Previous versions

### Features
- Custom TRACE and PROGRESS log levels
- Colorized console output
- Rate-limited progress messages
- Basic logging functionality