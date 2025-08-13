ISTRUZIONI RAPIDE PER RISOLVERE IL PROBLEMA OPERA
=================================================

Il problema: La cartella Opera in AppData è bloccata e non può essere eliminata/rinominata.

SOLUZIONI (in ordine di semplicità):

1. UTILITY UNLOCKER (5 minuti)
   - Scarica IObit Unlocker: https://www.iobit.com/en/iobit-unlocker.php
   - Installa e avvia
   - Trascina la cartella C:\Users\marco\AppData\Roaming\Opera Software
   - Clicca "Unlock & Delete"
   - Riavvia Opera

2. SAFE MODE (10 minuti)
   - Riavvia il PC
   - Mentre si riavvia, tieni premuto SHIFT e clicca su "Riavvia"
   - Scegli: Risoluzione problemi > Opzioni avanzate > Impostazioni di avvio > Riavvia
   - Premi 4 per Modalità provvisoria
   - Elimina la cartella manualmente
   - Riavvia normalmente

3. PROMPT COMANDI AL BOOT (15 minuti)
   - Riavvia con SHIFT+Riavvia
   - Risoluzione problemi > Opzioni avanzate > Prompt dei comandi
   - Digita:
     C:
     cd Users\marco\AppData\Roaming
     rmdir /s /q "Opera Software"
   - Riavvia

Dopo aver eliminato la cartella, Opera creerà automaticamente una nuova configurazione pulita al prossimo avvio.