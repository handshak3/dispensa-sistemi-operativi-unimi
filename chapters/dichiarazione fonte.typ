#heading(numbering: none)[Dichiarazione sulla fonte]

Questa dispensa si basa principalmente sul libro *Operating Systems: Three Easy Pieces*, scritto da Remzi H. Arpaci-Dusseau e Andrea C. Arpaci-Dusseau, pubblicato da Arpaci-Dusseau Books, LLC nel 2018 @ArpaciDusseau23-Book. Il materiale presentato in questa dispensa, inclusi frammenti di testo, diagrammi, grafici e tabelle, è tratto dal suddetto libro, salvo diversa indicazione.

Tutti i diritti sul contenuto originale di questa dispensa sono riservati agli autori. L'utilizzo del materiale in questa dispensa è esclusivamente a scopo educativo, per gli studenti del corso _Sicurezza dei sistemi e delle reti informatiche_ presso l'Università degli Studi di Milano. La dispensa non è destinata a scopi commerciali e non può essere riprodotta o distribuita senza il permesso esplicito degli autori.

Per maggiori informazioni sul libro, si consiglia di consultare la versione ufficiale del testo:

#quote[
  _Arpaci-Dusseau, Remzi H., and Andrea C. Arpaci-Dusseau._ *Operating Systems: Three Easy Pieces*. Arpaci-Dusseau Books, LLC, 2018.
]

Il materiale, inclusi frammenti di codice, grafici e tabelle, è tratto dal libro sopra citato e viene utilizzato esclusivamente a scopo educativo, per fini di apprendimento e studio. Si ritiene che l'uso di questo materiale rientri nell'ambito delle normative sul Fair Use, in quanto non ha scopi commerciali e viene utilizzato in quantità limitata per fini didattici. Si invita comunque a consultare il libro per una comprensione completa e dettagliata degli argomenti trattati.

Gli argomenti trattati in questa dispensa comprendono tutti quelli affrontati a lezione, con l'aggiunta di esercizi basati su temi d'esame ufficiali. In particolare i capitoli del libro trattati sono:

#grid(
  columns: (1fr, 1fr),
  [
    - Intro
    - Processes
    - Processes API
    - CPU-Mechanism
    - CPU scheduling
    - CPU Scheduling MLFQ
    - Address Space
    - Memory API
    - Address translation
    - Segmentation
    - Paging
    - TLB
    - Smalltables TLBS
    - Swapping: Mechanisms
  ],
  [
    - Swapping: Policies
    - Concurrency
    - Thread API
    - Locks
    - #text(size: 7.9pt)[Lock-based concurrent data structure]
    - Condition variables
    - Semaphores
    - I/O devices
    - HD drives
    - RAID
    - Files and directories
    - File system
    - FFS
    - Journaling
  ],
)

Per ottenere una copia completa del libro o maggiori dettagli, si invita a visitare il sito ufficiale: #link("http://pages.cs.wisc.edu/~remzi/OSTEP/").

Questo documento approfondisce anche gli argomenti trattati negli esami del Prof. Matteo Re' per la parte di laboratorio, offrendo un supporto pratico per la preparazione al parziale. Il contenuto è organizzato in diverse sezioni, tra cui:
- *Memorie di massa*: analisi del funzionamento dei dischi magnetici, calcolo dei blocchi, latenza rotazionale e ottimizzazione dei tempi di accesso ai dati.
- *Assembly*: esempi pratici di system call in Assembly.
- *Shell e Pipeline*: approfondimento su comandi della shell, permessi, processi e strumenti di manipolazione di file come `grep`, `awk`, `cut`, `sort` e `sed`.
- *Esercizi pratici e simulazioni d'esame*.

Le domande degli esami si ispirano in parte a quelle presenti in questo documento:
#link("http://twiki.di.uniroma1.it/pub/Sistemioperativi1/WebHome/dispensa_so.pdf")[Sistemi Operativi 1 - Twiki UniRoma1] all'indirizzo: "http://twiki.di.uniroma1.it/twiki/view/Sistemioperativi1".

Il materiale è destinato esclusivamente agli studenti dell'Università degli Studi di Milano iscritti al corso di *Sicurezza dei Sistemi e delle Reti Informatiche*.

Se riscontrate errori o avete suggerimenti per migliorare il contenuto, vi invitiamo ad aprire una *Issue* o una *Pull Request* nel #link("https://github.com/handshak3/dispensa-sistemi-operativi-unimi")[repository GitHub] all'indirizzo: "https://github.com/handshak3/dispensa-sistemi-operativi-unimi". Questo ci aiuterà a mantenere il materiale aggiornato e di qualità.

#colbreak()