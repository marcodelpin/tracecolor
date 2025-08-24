# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.5] - 2025-08-24

### Fixed
- Updated README.md to show correct version number

### Changed
- Documentation now reflects current version

## [0.7.4] - 2025-08-24

### Fixed
- pyproject.toml now uses dynamic version from __init__.py
- Complete fix for Upload Python Package workflow version mismatch

### Changed
- pyproject.toml version is now dynamic using setuptools>=61.0
- Single source of truth for version in __init__.py

## [0.7.3] - 2025-08-24

### Fixed
- setup.py now dynamically reads version from __init__.py to prevent version mismatch
- GitHub Actions Upload Python Package workflow now builds correct version

### Changed
- Eliminated hardcoded version in setup.py for single source of truth

## [0.7.2] - 2025-08-24

### Fixed
- Updated test suite to work with Loguru backend
- Fixed all test failures in GitHub Actions CI

### Changed
- Tests now properly validate Loguru-based implementation

## [0.7.1] - 2025-08-24

### Fixed
- PROGRESS rate limiting now correctly applied to all output sinks (console, UDP, file)
- Rate limiting logic moved upstream to prevent duplication and ensure consistency
- Rate limiting properly enforces 1 message per second per call site

### Changed
- Rate limiting implementation moved from filter level to method level for better control

## [0.7.0] - 2025-08-24

### Added
- Console script `tracecolor-monitor` for easy UDP monitoring
- Automatic installation of Loguru as required dependency
- Monitor script improvements with colored level indicators
- Comprehensive test suite and installation scripts
- Documentation for monitor usage and troubleshooting

### Changed
- Loguru is now a required dependency (not optional)
- Pure Loguru implementation (removed fallback to standard logging)
- Monitor now colors only the first letter of log level
- Improved package metadata and descriptions

### Fixed
- UDP monitor coloring now properly shows only level character in color
- Console script entry points properly configured
- Dependencies automatically installed with pip install

## [Unreleased]

### Added
- GitHub Actions CI/CD pipeline for automated testing
- Contributing guidelines
- Issue templates for bug reports and feature requests

## [0.6.1] - 2024-08-24

### Added
- Enhanced Loguru integration for better performance
- Structured logging support with context binding
- Improved UDP monitoring reliability with non-blocking sockets
- Better fallback handling when Loguru is not available

### Changed
- UDP socket now non-blocking to prevent application hangs
- Improved error handling for network operations

### Fixed
- Rate limiting now properly applies per call site
- Logger instance isolation prevents cross-contamination

## [0.6.0] - 2024-08-23

### Added
- Migrated to Loguru backend for superior performance
- YAML configuration file support
- File logging with automatic rotation and compression
- UDP remote monitoring for centralized logging
- External configuration via JSON/YAML files
- Multiple simultaneous output sinks

### Changed
- Complete backend rewrite using Loguru
- Maintained 100% backward compatibility with v0.5.0 API
- Enhanced thread safety with enterprise-grade implementation

## [0.5.0] - 2024

### Added
- Initial release with custom TRACE and PROGRESS log levels
- Colorized console output using colorlog
- Rate-limited PROGRESS messages (1 per second per call site)
- Support for Python 3.8+

[Unreleased]: https://github.com/marcodelpin/tracecolor/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/marcodelpin/tracecolor/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/marcodelpin/tracecolor/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/marcodelpin/tracecolor/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/marcodelpin/tracecolor/releases/tag/v0.5.0