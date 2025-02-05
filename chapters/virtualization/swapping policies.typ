== Swapping: Policies

Quando l'OS ha poca memoria a disposizione per le pagine deve sostituire le pagine con quelle utilizzate attivamente. Per fare ciò occorre una replacement policy.

=== Access time

La memoria centrale contiene un sottoinsieme di pagine e può essere vista come una cache per le pagine di memoria virtuale. L'obiettivo è ridurre al minimo il numero di *cache misses* (volte in cui dobbiamo recuperare una pagina dal disco perché non è presente in memoria). Possiamo calcolare l'average memory access time (*AMAT*) per un programma:

$ "AMAT"=T_M+(P_"Miss" dot T_D) $

- $T_M$: è il costo di accesso alla memoria.
- $T_D$: è il costo di accesso al disco.
- $P_"Miss"$: è la probabilità di non trovare i dati nella cache (da 0 a 1).

=== Classificazione dei miss
Gli architetti di computer classificano i miss in base al tipo, in una delle tre categorie:

- *Compulsory miss*: si verifica perché la cache è vuota all'inizio e questa è la prima istanza di riferimento all'elemento.
- *Capacity miss*: si verifica perché la cache ha esaurito lo spazio e ha dovuto espellere un elemento per portare un nuovo elemento nella cache.
- *Conflict miss*: si verifica nell'hardware a causa dei limiti su dove un elemento può essere posizionato in una cache hardware, a causa di qualcosa noto come set-associative; non si verifica nella cache di pagina dell'OS perché tali cache sono sempre fully-associative, cioè non ci sono restrizioni su dove una pagina può essere posizionata in memoria.

=== Politiche di replacement

*Optimal Replacement Policy*: politica che porta al minor numero di errori di pagina e sostituisce la pagina che verrà acceduta più lontano nel futuro. È difficile da implementare, ma è un buon punto di riferimento per le altre politiche di sostituzione.

*FIFO (first-in, first-out) policy*: politica di sostituzione di pagina semplice che sostituisce la pagina che è stata caricata per prima in memoria. È facile da implementare, ma non è molto efficiente, poiché può espellere pagine che sono state recentemente accedute.

*Random policy*: politica che sceglie una pagina da sostituire in modo casuale. È semplice da implementare, ma non è molto efficiente, poiché può espellere pagine che sono state recentemente accedute. Può avere prestazioni migliori o peggiori del FIFO, a seconda della sequenza di accesso alle pagine.

Utilizzo della cronologia:\
Per migliorare la previsione del futuro, possiamo utilizzare la storia come guida. Se una pagina è stata acceduta di recente, è probabile che venga acceduta di nuovo a breve.

Una politica di paginazione può utilizzare due tipi di informazioni storiche:
- *Frequenza di accesso*
- *Attualità di accesso*

La famiglia di politiche basate sull'attualità di accesso è basata sul *principio di località*, che afferma che i programmi tendono ad accedere a determinate sequenze di codice e strutture dati in modo molto frequente. In dettaglio, sono:
- *LFU policy* (Least Frequently Used): sostituisce la pagina che è stata utilizzata meno frequentemente.
- *LRU policy* (Least Recently Used): sostituisce la pagina che è stata utilizzata meno di recente.

=== LRU approssimato

È possibile fare un approssimazione per trovare le pagine utilizzate meno recentemente. Approssimando LRU otteniamo un algoritmo più flessibile e meno
costoso ed è la tecnica che i moderni sistemi adottano. Per fare ciò occorre supporto hardware.

*Use bit o reference bit*: è contenuto in ogni pagina e ogni volta che una di esse viene riferita, lo use bit è settato dall'hardware a 1.

L'hardware non pulisce mai lo use bit, è l'OS che ha il compito di settarlo a 0.

Il *Clock algorithm* è utilizzato per approssimare l'LRU.
Funzionamento dell'Algoritmo Clock:
1. Struttura Circolare: Le pagine in memoria sono organizzate in una lista circolare, simile al quadrante di un orologio, con una "lancetta" che punta a una pagina specifica.

2. Processo di Sostituzione:
  - Quando è necessario sostituire una pagina, il sistema operativo controlla la pagina indicata dalla lancetta.
  - Se il bit di riferimento della pagina è 1, significa che la pagina è stata utilizzata di recente. In questo caso, il sistema operativo:
    - Resetta il bit di riferimento a 0.
    - Sposta la lancetta alla pagina successiva.
  - Questo processo continua finché non si trova una pagina con il bit di riferimento a 0, indicante che non è stata utilizzata di recente e può essere sostituita.

#figure(image("../../images/swapping/clock.png"), caption: [Clock algorithm.])

Per migliorare ulteriormente l'efficienza, l'algoritmo può considerare anche il bit di modifica (dirty bit), che indica se una pagina è stata modificata mentre risiedeva in memoria.

- Pagine non modificate (clean): Se una pagina non è stata modificata (dirty bit = 0), può essere rimossa senza necessità di scriverla su disco, riducendo il costo dell'operazione.

- Pagine modificate (dirty): Se una pagina è stata modificata (dirty bit = 1), deve essere scritta su disco prima di essere sostituita, comportando un overhead maggiore.

=== Trashing
Quando la richiesta di memoria dei processi in esecuzione supera la memoria fisica disponibile, il sistema entra in una condizione di *trashing*, caratterizzata da un eccessivo utilizzo della paginazione che degrada drasticamente le prestazioni.

Per gestire questa situazione, alcuni sistemi adottano meccanismi di controllo avanzati, come l'*admission control*, che limita il numero di processi in esecuzione per garantire un utilizzo più efficiente delle risorse. L'idea alla base è che eseguire meno processi in modo efficace sia preferibile rispetto a eseguirne troppi con prestazioni pessime.

Linux, invece, utilizza un approccio più diretto con l'*Out-Of-Memory (OOM) Killer*: quando la memoria è sovraccarica, questo demone identifica e termina il processo che sta consumando più memoria, liberando risorse e prevenendo il collasso del sistema.

#line()