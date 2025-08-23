#!/usr/bin/env python3
"""
ESET License Scanner for Telegram Channels
Extracts ESET license keys from Telegram channel messages
"""

import re
import json
import asyncio
import logging
from datetime import datetime
from pathlib import Path
from telethon import TelegramClient
from telethon.errors import SessionPasswordNeededError

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('eset_scanner.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class ESETLicenseScanner:
    """Scanner for ESET license keys in Telegram channels"""
    
    def __init__(self, config_path='config.json'):
        self.config = self.load_config(config_path)
        self.client = None
        self.licenses_found = []
        
        # ESET license patterns
        self.license_patterns = [
            r'[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}',  # Standard format
            r'ESET[A-Z0-9\-]+',  # ESET prefixed keys
            r'EAV[A-Z0-9\-]+',   # EAV prefixed keys  
            r'EIS[A-Z0-9\-]+',   # EIS prefixed keys
        ]
    
    def load_config(self, config_path):
        """Load configuration from JSON file"""
        try:
            with open(config_path, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            logger.error(f"Config file {config_path} not found")
            return self.create_default_config(config_path)
    
    def create_default_config(self, config_path):
        """Create default configuration file"""
        config = {
            "api_id": "YOUR_API_ID",
            "api_hash": "YOUR_API_HASH", 
            "phone": "YOUR_PHONE_NUMBER",
            "channels": [
                "@eset_licenses",
                "@antivirus_keys"
            ],
            "output_file": "eset_licenses.txt",
            "max_messages": 1000
        }
        
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=4)
        
        logger.info(f"Created default config at {config_path}")
        logger.info("Please update with your Telegram API credentials")
        return config
    
    async def initialize_client(self):
        """Initialize Telegram client"""
        try:
            self.client = TelegramClient(
                'eset_scanner_session',
                self.config['api_id'],
                self.config['api_hash']
            )
            
            await self.client.start(phone=self.config['phone'])
            logger.info("Telegram client initialized successfully")
            
        except SessionPasswordNeededError:
            password = input("Two-factor authentication password: ")
            await self.client.start(password=password)
            logger.info("Authenticated with 2FA")
            
        except Exception as e:
            logger.error(f"Failed to initialize client: {e}")
            raise
    
    def extract_licenses(self, text):
        """Extract ESET license keys from text"""
        licenses = []
        
        for pattern in self.license_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            licenses.extend(matches)
        
        return list(set(licenses))  # Remove duplicates
    
    async def scan_channel(self, channel):
        """Scan a specific channel for licenses"""
        try:
            logger.info(f"Scanning channel: {channel}")
            
            entity = await self.client.get_entity(channel)
            messages_scanned = 0
            licenses_found = 0
            
            async for message in self.client.iter_messages(
                entity, 
                limit=self.config.get('max_messages', 1000)
            ):
                if message.text:
                    messages_scanned += 1
                    
                    # Extract licenses from message
                    found_licenses = self.extract_licenses(message.text)
                    
                    for license_key in found_licenses:
                        license_data = {
                            'license': license_key,
                            'channel': channel,
                            'message_id': message.id,
                            'date': message.date.isoformat(),
                            'text_preview': message.text[:100] + '...' if len(message.text) > 100 else message.text
                        }
                        
                        self.licenses_found.append(license_data)
                        licenses_found += 1
                        logger.info(f"Found license: {license_key}")
            
            logger.info(f"Channel {channel}: {messages_scanned} messages scanned, {licenses_found} licenses found")
            
        except Exception as e:
            logger.error(f"Error scanning channel {channel}: {e}")
    
    async def scan_all_channels(self):
        """Scan all configured channels"""
        if not self.client:
            await self.initialize_client()
        
        for channel in self.config['channels']:
            await self.scan_channel(channel)
    
    def save_results(self):
        """Save scan results to files"""
        output_file = self.config.get('output_file', 'eset_licenses.txt')
        
        # Save as text file
        with open(output_file, 'w') as f:
            f.write(f"ESET License Scan Results\n")
            f.write(f"Scan Date: {datetime.now().isoformat()}\n")
            f.write(f"Total Licenses Found: {len(self.licenses_found)}\n")
            f.write("=" * 50 + "\n\n")
            
            for license_data in self.licenses_found:
                f.write(f"License: {license_data['license']}\n")
                f.write(f"Channel: {license_data['channel']}\n")
                f.write(f"Date: {license_data['date']}\n")
                f.write(f"Preview: {license_data['text_preview']}\n")
                f.write("-" * 30 + "\n")
        
        # Save as JSON for programmatic access
        json_file = output_file.replace('.txt', '.json')
        with open(json_file, 'w') as f:
            json.dump({
                'scan_date': datetime.now().isoformat(),
                'total_licenses': len(self.licenses_found),
                'licenses': self.licenses_found
            }, f, indent=2)
        
        logger.info(f"Results saved to {output_file} and {json_file}")
        logger.info(f"Total licenses found: {len(self.licenses_found)}")
    
    async def run(self):
        """Main scanning routine"""
        try:
            logger.info("Starting ESET license scan...")
            await self.scan_all_channels()
            self.save_results()
            logger.info("Scan completed successfully")
            
        except Exception as e:
            logger.error(f"Scan failed: {e}")
            raise
        
        finally:
            if self.client:
                await self.client.disconnect()

async def main():
    """Main entry point"""
    scanner = ESETLicenseScanner()
    await scanner.run()

if __name__ == "__main__":
    asyncio.run(main())