# Telegram Channel Analysis Scripts

Tools for extracting and analyzing ESET license information from Telegram channels.

## Purpose
- Extract ESET license keys from Telegram channel messages
- Analyze license validity and expiration dates  
- Generate reports on available licenses

## Scripts

### Main Tools
- `scan-eset-licenses.py` - Primary license extraction script
- `telegram-channel-analyzer.py` - Channel message analysis
- `license-validator.py` - Validate ESET license format and status

### Configuration  
- `config.json` - Telegram API credentials and channel settings
- `channels.txt` - List of channels to monitor

## Usage

```bash
# Basic license scanning
cd telegram
python scan-eset-licenses.py

# Analyze specific channel
python telegram-channel-analyzer.py --channel @channel_name

# Validate extracted licenses  
python license-validator.py --input licenses.txt
```

## Setup Requirements
1. Telegram API credentials (api_id, api_hash)
2. Python dependencies: `telethon`, `regex`, `datetime`
3. Channel access permissions

## Output Formats
- Text files with license keys
- JSON reports with metadata
- CSV exports for analysis

## Security Note
- License data is sensitive information
- Ensure proper access controls
- Follow ESET terms of service