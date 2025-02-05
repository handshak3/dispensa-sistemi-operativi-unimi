== Address Space (AS)

I primi OS non offrivano molte astrazioni dalla memoria. L'OS era una serie di routine (una libreria, in realtà) che si trovava in memoria (a partire dall'indirizzo fisico 0 in questo esempio). C'era un solo processo in esecuzione che occupava il resto della memoria.

*Nascita della multiprogrammazione*: le macchine erano costose, le persone iniziavano a condividerle. I processi erano pronti per essere eseguiti in un momento e l'OS passava da un programma all'altro.

I sistemi multiprogrammazione e time sharing sono stati sviluppati per migliorare l'utilizzo del processore e per consentire a più utenti di utilizzare una macchina contemporaneamente.

#figure(
  caption: [Sharing memory.],
  image("../../images/as/sharing mem.png", width: 45%),
)

=== Address space moderno

In un sistema *multiprogrammazione*, più processi sono pronti per l'esecuzione e l'OS passa da un processo all'altro, ad esempio quando uno decide di eseguire un'operazione di I/O.

*Interattività*: capacità di un sistema di rispondere alle azioni dell'utente.

In un sistema time sharing, i processi vengono eseguiti per un breve periodo di tempo, prima di essere sospesi e sostituiti da un altro processo. Questo consente a più utenti di utilizzare una macchina contemporaneamente e di ricevere un feedback tempestivo dalle loro attività.

La protezione della memoria è un problema importante nei sistemi multiprogrammazione e time sharing, poiché è necessario impedire che un processo acceda alla memoria di un altro processo.

L'interattività diventa importante. Un modo per implementare il time-sharing (molto lento):
1. Eseguire il processo $A$ per un breve periodo (dandogli accesso a tutta la memoria).
2. Interrompere il processo $A$.
3. Salvare lo stato del processo $A$ su un disco.
4. Caricare stato del processo $B$.
5. Eseguire il processo $B$ per il suo quanto di pianificazione ecc.

*Approccio ottimale*: si lasciano i processi in memoria facendo time-sharing (salvataggio e ripristino dello stato a livello di registro).

#figure(
  caption: [Address space example.],
  image("../../images/as/address space.png", width: 70%),
)

*Address space*: astrazione del programma in esecuzione fornita dall'OS (range di indirizzi di memoria sui quali il programma è in esecuzione).

Contiene:
- *Stato* della memoria del processo in esecuzione.
- *Codice* del programma.
- *Heap* utilizzato per la memoria allocata dinamicamente. Esso viene gestito dall'utente e cresce verso il basso.
- *Stack* che tiene traccia di dove si trova il processo nella catena di chiamate a funzione, utilizzato per allocare variabili locali, passare parametri, per restituire valori da/verso le routine. Cresce verso l'alto.

*Virtualizzazione della memoria*: il processo non dispone la conoscenza degli indirizzi fisici sui quali è in esecuzione e ha l'illusione di avere a disposizione una memoria potenzialmente molto grande.

Il programma non risiede realmente in memoria dall'indirizzo 0 a 16 KB, sarà invece caricato a indirizzi fisici arbitrari.

=== Obbiettivi dell'OS

- *Trasparenza:* l'OS deve virtualizzare la memoria in modo che il programma in esecuzione non sia consapevole del fatto che la memoria è virtualizzata.
- *Efficienza:* l'OS deve rendere la virtualizzazione efficiente, sia in termini di
  - Tempo: la virtualizzazione non deve rallentare il programma in esecuzione.
  - Spazio: l'OS non deve allocare più memoria di quella necessaria per virtualizzare la memoria.
- *Protezione:* l'OS deve proteggere i processi l'uno dall'altro e l'OS stesso dai processi. Ciò significa che un processo non deve essere in grado di accedere alla memoria o ai dati di un altro processo. l'OS deve proteggere l'OS stesso da processi che potrebbero essere malevoli.

#line()