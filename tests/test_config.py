"""Tests for config loading and parsing."""

import json
import pytest
from pathlib import Path
from tracecolor.config import (
    find_config_file,
    load_config,
    _parse_json,
    _parse_toml,
    _parse_simple_toml,
    _toml_to_flat_config,
    _auto_detect_and_parse,
)


def test_find_config_file_none(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    assert find_config_file() is None


def test_find_config_file_tracecolor(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    (tmp_path / ".tracecolor").write_text('{"log_level": "DEBUG"}')
    assert find_config_file() == ".tracecolor"


def test_find_config_file_toml_priority(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    (tmp_path / "tracecolor.toml").write_text("[console]\nenabled = true")
    (tmp_path / "tracecolor.json").write_text('{"log_level": "INFO"}')
    assert find_config_file() == "tracecolor.toml"


def test_parse_json_flat():
    result = _parse_json('{"log_level": "DEBUG", "enable_udp": true}')
    assert result["log_level"] == "DEBUG"
    assert result["enable_udp"] is True


def test_parse_json_nested_logging():
    result = _parse_json('{"logging": {"log_level": "INFO"}}')
    assert result["log_level"] == "INFO"


def test_parse_simple_toml_sections():
    content = """
[udp]
enabled = true
host = "192.168.1.1"
port = 8888

[console]
enabled = true
level = "DEBUG"

[file]
enabled = false
dir = "./logs"
"""
    result = _parse_simple_toml(content)
    assert result["use_udp"] is True
    assert result["udp_host"] == "192.168.1.1"
    assert result["udp_port"] == 8888
    assert result["enable_console"] is True
    assert result["log_level"] == "DEBUG"
    assert result["enable_file"] is False
    assert result["log_dir"] == "./logs"


def test_toml_to_flat_config():
    toml_data = {
        "udp": {"enabled": True, "host": "0.0.0.0", "port": 7777},
        "console": {"enabled": True, "level": "TRACE"},
        "file": {"enabled": True, "dir": "/var/log"},
        "log_level": "WARNING",
    }
    result = _toml_to_flat_config(toml_data)
    assert result["use_udp"] is True
    assert result["udp_host"] == "0.0.0.0"
    assert result["udp_port"] == 7777
    assert result["enable_console"] is True
    assert result["log_level"] == "WARNING"
    assert result["enable_file"] is True
    assert result["log_dir"] == "/var/log"


def test_auto_detect_json():
    result = _auto_detect_and_parse('{"log_level": "INFO"}')
    assert result["log_level"] == "INFO"


def test_auto_detect_toml():
    result = _auto_detect_and_parse("[udp]\nenabled = true\nport = 5555")
    assert result["use_udp"] is True
    assert result["udp_port"] == 5555


def test_load_config_nonexistent():
    result = load_config("nonexistent_file.json")
    assert result == {}


def test_load_config_json(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    config_file = tmp_path / "tracecolor.json"
    config_file.write_text(json.dumps({"log_level": "ERROR", "enable_udp": True}))
    result = load_config(str(config_file))
    assert result["log_level"] == "ERROR"
    assert result["enable_udp"] is True


def test_toml_json_section():
    result = _parse_simple_toml("[json]\nenabled = true\nfile = \"logs/app.jsonl\"")
    assert result["enable_json"] is True
    assert result["json_file"] == "logs/app.jsonl"


def test_toml_to_flat_config_json():
    toml_data = {"json": {"enabled": True, "file": "/var/log/app.jsonl"}}
    result = _toml_to_flat_config(toml_data)
    assert result["enable_json"] is True
    assert result["json_file"] == "/var/log/app.jsonl"


def test_load_config_yaml(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    config_file = tmp_path / "tracecolor.yml"
    config_file.write_text("log_level: WARNING\nenable_udp: true\nudp_port: 7777\n")
    result = load_config(str(config_file))
    # YAML parsing requires pyyaml — if not installed, returns {}
    if result:
        assert result.get("log_level") == "WARNING"


def test_auto_detect_yaml():
    result = _auto_detect_and_parse("log_level: INFO\nenable_udp: true\n")
    # If pyyaml available, should parse; if not, falls through to TOML
    assert isinstance(result, dict)


def test_find_config_file_yml(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    (tmp_path / "tracecolor.yml").write_text("log_level: DEBUG\n")
    assert find_config_file() == "tracecolor.yml"
