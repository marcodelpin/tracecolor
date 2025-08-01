Istruzioni per la Creazione di un'App di "Question Storming"
1. Obiettivo Principale
Sviluppare un'applicazione web single-page (SPA) chiamata "Question Storming". L'app consente agli utenti di inserire un problema o un argomento e di generare, tramite un'API di intelligenza artificiale, una lista di 10 domande creative e stimolanti per facilitare il brainstorming. Gli utenti devono poter salvare le loro domande preferite.

2. Stack Tecnologico
Frontend: React (con Hooks)

Styling: TailwindCSS

Icone: lucide-react

Database (per i preferiti): Google Firebase Firestore

Autenticazione (per utente): Google Firebase Authentication (con login anonimo)

Generazione AI: API Google Gemini (specificamente gemini-2.0-flash)

3. Design e Interfaccia Utente (UI/UX)
Stile Generale: Moderno, pulito, minimalista, con un'estetica ispirata a macOS.

Tema: Scuro (Dark Mode). Sfondi slate-900, elementi su slate-800, testo slate-100/slate-300, accenti blue-600.

Layout: Centrato, con una larghezza massima (max-w-3xl) per una leggibilità ottimale.

Font: Inter.

Animazioni: Transizioni fluide e animazioni discrete (fade-in) per l'apparizione di nuovi elementi.

4. Struttura dei Componenti React
L'applicazione deve essere suddivisa in componenti logici:

App (Componente Principale):

Gestisce lo stato principale: problem, questions, favorites, isLoading, error, currentView, userId.

Contiene la logica per l'autenticazione, le chiamate all'API e l'interazione con Firestore.

Renderizza i componenti figli e la navigazione.

QuestionItem:

Visualizza una singola domanda generata.

Contiene un pulsante a forma di stella (Star) per aggiungere/rimuovere la domanda dai preferiti. Lo stato della stella (piena/vuota) deve riflettere se la domanda è già tra i preferiti.

FavoriteItem:

Visualizza una singola domanda salvata nella lista dei preferiti.

Contiene un pulsante (Trash2) per rimuovere permanentemente la domanda dai preferiti.

5. Flusso Funzionale
Avvio dell'App:

Inizializza Firebase.

Autentica l'utente in modo anonimo o con il token fornito per ottenere un userId.

Stabilisce un listener onSnapshot sulla collezione dei preferiti dell'utente in Firestore per mantenere la lista dei preferiti (favorites) sempre sincronizzata in tempo reale.

Navigazione:

Un menu con due pulsanti ("Home", "Preferiti") controlla lo stato currentView.

Se currentView === 'home', mostra l'interfaccia principale per generare domande.

Se currentView === 'favorites', mostra la lista delle domande salvate.

Generazione Domande (Vista 'Home'):

L'utente inserisce un testo in una <textarea>.

Cliccando il pulsante "Genera 10 domande", viene attivata la funzione handleGenerateQuestions.

Mostra uno stato di caricamento (isLoading = true) e disabilita il pulsante.

Effettua una chiamata fetch all'API di Gemini.

Prompt per l'AI: Sei un esperto di pensiero creativo e problem-solving. Il tuo compito è generare 10 domande potenti e aperte basate sul seguente problema. Le domande devono sfidare le supposizioni, esplorare nuove prospettive e stimolare una riflessione profonda. Non fornire alcun preambolo o spiegazione, solo l'elenco di domande in formato JSON. Problema: "[TESTO_UTENTE]"

Schema di Risposta (JSON): L'API deve essere configurata per restituire un array di stringhe JSON. Esempio: ["Domanda 1?", "Domanda 2?", ...]

Al ricevimento della risposta, popola lo stato questions con gli oggetti { text: "...", id: ... }.

Gestisce eventuali errori di rete o dell'API, mostrandoli all'utente.

Se l'utente clicca di nuovo il pulsante, il processo si ripete, generando una nuova lista di domande.

Gestione Preferiti:

Aggiunta: Cliccando la stella su un QuestionItem, la funzione handleToggleFavorite controlla se la domanda esiste già nei preferiti (basandosi sul testo). Se non esiste, la aggiunge alla collezione Firestore dell'utente. Il percorso deve essere: artifacts/{appId}/users/{userId}/favorites.

Rimozione (dalla Home): Se la domanda è già nei preferiti, handleToggleFavorite la rimuove dal documento corrispondente in Firestore.

Rimozione (dalla Vista Preferiti): Cliccando l'icona del cestino su un FavoriteItem, la funzione handleRemoveFavorite elimina il documento corrispondente da Firestore usando il suo ID.

L'aggiornamento della UI è automatico grazie al listener onSnapshot.