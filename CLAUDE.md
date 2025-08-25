# CLAUDE.md

This file provides project-specific development guidelines for this repository.

## GitHub Release Workflow (MANDATORY)

When releasing changes, ALWAYS follow this workflow:

1. **Update version** in `tracecolor/__init__.py`
2. **Update CHANGELOG.md** with version and changes
3. **Commit with message**: `type: description (vX.Y.Z)`
4. **Push to GitHub**: `git push origin main`
5. **VERIFY GitHub Actions**: Check workflow passes
6. **If fails**: Fix immediately, bump version, repeat

**NEVER leave a failing workflow. Continue fixing until all tests pass.**

Use `gh run list --repo marcodelpin/tracecolor` to check status.

## Development Commands

### Building and Installation
```bash
# Install in development mode with all dependencies
pip install -e ".[dev,yaml]"

# Install package from source
pip install .

# Build distribution packages
python -m build
```

### Testing
```bash
# Run all tests with coverage
pytest tests/ -v --cov=tracecolor --cov-report=html --cov-report=term-missing

# Run specific test file
pytest tests/test_specific.py -v

# Run tests matching pattern
pytest -k "test_udp" -v

# Manual UDP testing (requires two terminals)
# Terminal 1: Start monitor
python -m tracecolor.monitor --host 127.0.0.1 --port 9999
# Terminal 2: Run test script
python tracecolor/test_udp.py
```

### Code Quality
```bash
# Format code with Black
black tracecolor/ tests/ --line-length 100

# Run linting
flake8 tracecolor/ tests/

# Type checking with mypy
mypy tracecolor/ --python-version 3.8
```

### Package Distribution
```bash
# Build wheel and source distribution
python -m build

# Upload to PyPI (requires credentials)
python -m twine upload dist/*
```

## Architecture Overview

### Core Design Principles
1. **Dual Backend Support**: The library operates with either Loguru (preferred) or standard Python logging (fallback), determined at runtime based on availability.
2. **Rate Limiting**: PROGRESS level messages are rate-limited per call site using `ProgressRateLimiter` class to prevent log flooding.
3. **Custom Log Levels**: TRACE (5) and PROGRESS (15) are injected into both backend systems.

### Key Components

**tracecolor.py (Main Module)**
- `tracecolor` class: Main logger interface that wraps either Loguru or standard logging
- `ProgressRateLimiter`: Implements per-call-site rate limiting (1 msg/sec)
- `UDPSink`: Custom sink for UDP remote monitoring, non-blocking to prevent hangs
- Dual initialization paths: `_init_loguru_backend()` vs `_init_logging_backend()`

**monitor.py (UDP Monitor)**
- Standalone UDP server for receiving and displaying remote logs
- Color-coded output matching the main logger's console format
- Entry point for `tracecolor-monitor` console script

### Backend Selection Logic
The library checks for Loguru availability at import time:
1. If Loguru is available → Use Loguru backend with advanced features
2. If Loguru is missing → Fall back to standard logging + colorlog

Both backends maintain identical API surface for backward compatibility.

### Message Flow Architecture
```
User Code → tracecolor API → Backend Selection
                                ├── Loguru Path → Multiple Sinks (Console/File/UDP)
                                └── Logging Path → Console Handler with ColorLog
```

### UDP Monitoring System
- **Non-blocking**: UDP socket set to non-blocking mode to prevent application hangs
- **Silent failures**: Network errors are caught and ignored to maintain logging stability
- **Format consistency**: UDP messages use same format as console for monitoring consistency

### Configuration Loading
Supports external configuration from JSON/YAML files with fallback to constructor parameters:
1. Check for config_file parameter
2. Load JSON or YAML based on file extension
3. Merge with constructor parameters (constructor wins on conflicts)

## Important Implementation Details

### Rate Limiting Implementation
The `ProgressRateLimiter` maintains a dictionary of call sites (file:function:line) with last log timestamps. This ensures rate limiting is applied per unique code location, not globally.

### Logger Instance Isolation
Each `tracecolor` instance gets a unique `logger_id` UUID to prevent cross-contamination when multiple instances exist. All sinks filter by this ID.

### Backward Compatibility
The library maintains the exact same API as tracecolor 0.5.0. The `create_enhanced_logger()` function is an alias for explicit feature access but internally creates the same `tracecolor` instance.

### Error Handling Philosophy
- Network operations (UDP) fail silently to prevent disrupting the application
- Configuration loading errors fall back to defaults
- Missing optional dependencies (PyYAML) are handled gracefully

## Package Metadata
- Version tracked in `tracecolor/__init__.py` as `__version__`
- Both `setup.py` and `pyproject.toml` read version from `__init__.py`
- Package name: "tracecolor" (no suffix despite enhanced features)