# Scripts per Telegram MCP

## update-telegram-credentials.py

Script Python interattivo per aggiornare le credenziali Telegram API.

### Funzionalità:
- ✅ Input interattivo delle credenziali
- ✅ Validazione formato API ID e API Hash
- ✅ Aggiornamento automatico di `.env.development` e `mcp.json`
- ✅ Test connessione Telegram opzionale
- ✅ Gestione errori completa

### Utilizzo:

**Da Python:**
```cmd
python scripts\update-telegram-credentials.py
```

**Da batch:**
```cmd
scripts\update-telegram-credentials.cmd
```

### Cosa fa lo script:

1. **Richiede credenziali**:
   - API ID (numerico)
   - API Hash (32 caratteri hex)
   - Numero di telefono

2. **Aggiorna file**:
   - `C:\Users\marco\.secrets\telegram-mcp\.env.development`
   - `S:\Commesse\00-09_System\mcp.json`

3. **Valida credenziali**:
   - API ID deve essere numerico positivo
   - API Hash deve essere 32 caratteri esadecimali
   - Numero telefono formato internazionale

4. **Test connessione** (opzionale):
   - Esegue `mcp-telegram sign-in`
   - Richiede codice di verifica da Telegram

### Prerequisiti:

- Python 3.7+
- `mcp-telegram` installato via uv
- Account Telegram con API credentials da https://my.telegram.org/apps

### Output:

Lo script crea/aggiorna:
- File `.env.development` nella directory sicura
- File `mcp.json` nel progetto
- Timestamp dell'ultimo aggiornamento

### Sicurezza:

- ✅ Credenziali memorizzate in `~/.secrets/` (fuori dal repository)
- ✅ File `mcp.json` ignorato da git (vedi `.claudeignore`)
- ✅ Validazione input per evitare errori

---
Creato: 2025-01-20