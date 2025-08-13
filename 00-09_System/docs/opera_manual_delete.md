# Istruzioni per eliminare manualmente la cartella Opera

## Metodo 1: Safe Mode (Più semplice)

1. **Riavvia il PC** e durante l'avvio:
   - Windows 10/11: Tieni premuto SHIFT mentre clicchi su Riavvia
   - Oppure: Premi F8 ripetutamente durante il boot

2. **Scegli**: Risoluzione dei problemi → Opzioni avanzate → Impostazioni di avvio → Riavvia

3. **Premi 4** per avviare in Modalità provvisoria

4. **In Safe Mode**:
   - Apri Esplora file
   - Vai a: `C:\Users\marco\AppData\Roaming\`
   - Elimina la cartella "Opera Software"
   - Riavvia normalmente

## Metodo 2: Command Prompt dal Recovery

1. **Riavvia** tenendo premuto SHIFT
2. **Vai a**: Risoluzione problemi → Opzioni avanzate → Prompt dei comandi
3. **Esegui questi comandi**:
   ```
   C:
   cd Users\marco\AppData\Roaming
   rmdir /s /q "Opera Software"
   exit
   ```
4. Riavvia

## Metodo 3: Linux Live USB

1. Scarica Ubuntu o altra distro Linux
2. Crea USB bootable con Rufus
3. Avvia da USB
4. Monta il disco Windows
5. Naviga alla cartella ed elimina

## Metodo 4: Utility specializzate

- **IObit Unlocker**: https://www.iobit.com/en/iobit-unlocker.php
- **Unlocker**: http://www.emptyloop.com/unlocker/
- **LockHunter**: https://lockhunter.com/

Installa una di queste, click destro sulla cartella → Unlock & Delete