"""Configuration loading and parsing for tracecolor."""

import json
from pathlib import Path
from typing import Dict, Any, Optional

try:
    import yaml
    YAML_AVAILABLE = True
except ImportError:
    YAML_AVAILABLE = False


def find_config_file() -> Optional[str]:
    """Auto-detect standard config files in current directory"""
    standard_names = [
        ".tracecolor",
        "tracecolor.toml",
        "tracecolor.yml",
        "tracecolor.yaml",
        "tracecolor.json"
    ]

    for name in standard_names:
        if Path(name).exists():
            return name

    return None


def load_config(config_file: str) -> Dict[str, Any]:
    """Load configuration from TOML, YAML or JSON file with auto-detection"""
    config_path = Path(config_file)
    if not config_path.exists():
        return {}

    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            content = f.read()

            if config_file == '.tracecolor':
                return _auto_detect_and_parse(content)
            elif config_file.endswith('.toml'):
                return _parse_toml(content)
            elif config_file.endswith(('.yaml', '.yml')):
                return _parse_yaml(content)
            else:
                return _parse_json(content)
    except Exception:
        return {}


def _auto_detect_and_parse(content: str) -> Dict[str, Any]:
    """Auto-detect format and parse configuration"""
    content_stripped = content.strip()

    if content_stripped.startswith(('{', '[')):
        try:
            return _parse_json(content)
        except Exception:
            pass

    if ':' in content and not content_stripped.startswith('['):
        try:
            return _parse_yaml(content)
        except Exception:
            pass

    if '[' in content or '=' in content:
        try:
            return _parse_toml(content)
        except Exception:
            pass

    return _parse_toml(content)


def _parse_toml(content: str) -> Dict[str, Any]:
    """Parse TOML configuration"""
    try:
        import tomllib
    except ImportError:
        try:
            import tomli as tomllib
        except ImportError:
            return _parse_simple_toml(content)

    config_data = tomllib.loads(content)
    return _toml_to_flat_config(config_data)


def _parse_yaml(content: str) -> Dict[str, Any]:
    """Parse YAML configuration"""
    if not YAML_AVAILABLE:
        raise ImportError("PyYAML required for YAML config files")
    config_data = yaml.safe_load(content)
    return config_data.get('logging', config_data) if isinstance(config_data, dict) else {}


def _parse_json(content: str) -> Dict[str, Any]:
    """Parse JSON configuration"""
    config_data = json.loads(content)
    return config_data.get('logging', config_data) if isinstance(config_data, dict) else {}


def _toml_to_flat_config(toml_data: Dict[str, Any]) -> Dict[str, Any]:
    """Convert TOML structure to flat config format"""
    config = {}

    if 'udp' in toml_data:
        config['use_udp'] = toml_data['udp'].get('enabled', False)
        config['udp_host'] = toml_data['udp'].get('host', '127.0.0.1')
        config['udp_port'] = toml_data['udp'].get('port', 9999)

    if 'console' in toml_data:
        config['enable_console'] = toml_data['console'].get('enabled', True)
        if 'level' in toml_data['console']:
            config['log_level'] = toml_data['console']['level']

    if 'file' in toml_data:
        config['enable_file'] = toml_data['file'].get('enabled', False)
        if 'dir' in toml_data['file']:
            config['log_dir'] = toml_data['file']['dir']

    if 'json' in toml_data:
        config['enable_json'] = toml_data['json'].get('enabled', False)
        if 'file' in toml_data['json']:
            config['json_file'] = toml_data['json']['file']

    if 'log_level' in toml_data:
        config['log_level'] = toml_data['log_level']

    return config


def _parse_simple_toml(content: str) -> Dict[str, Any]:
    """Simple TOML parser for basic config (fallback when tomllib not available)"""
    config = {}
    current_section = None

    for line in content.splitlines():
        line = line.strip()
        if not line or line.startswith('#'):
            continue

        if line.startswith('[') and line.endswith(']'):
            current_section = line[1:-1]
            continue

        if '=' in line:
            key, value = line.split('=', 1)
            key = key.strip()
            value = value.strip()

            if value.lower() in ('true', 'false'):
                value = value.lower() == 'true'
            elif value.isdigit():
                value = int(value)
            elif value.startswith('"') and value.endswith('"'):
                value = value[1:-1]

            if current_section:
                if current_section == 'udp':
                    if key == 'enabled':
                        config['use_udp'] = value
                    elif key == 'host':
                        config['udp_host'] = value
                    elif key == 'port':
                        config['udp_port'] = value
                elif current_section == 'console':
                    if key == 'enabled':
                        config['enable_console'] = value
                    elif key == 'level':
                        config['log_level'] = value
                elif current_section == 'file':
                    if key == 'enabled':
                        config['enable_file'] = value
                    elif key == 'dir':
                        config['log_dir'] = value
                elif current_section == 'json':
                    if key == 'enabled':
                        config['enable_json'] = value
                    elif key == 'file':
                        config['json_file'] = value

    return config
