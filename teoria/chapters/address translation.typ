#import "@preview/codly:1.0.0": *
#show: codly-init.with()

== Address Translation
L'indirizzo logico 0, ad esempio, non corrisponderà all'indirizzo fisico 0 (generalmente occupato dal sistema operativo) ma dovrà essere mappato in un'altra locazione di memoria fisica.

*Mapping*: trovare una corrispondenza fra indirizzo logico e indirizzo fisico (PA).

Tecniche di mapping
+ *Mapping Diretto*: ogni pagina virtuale è mappata a un frame fisico fisso, senza flessibilità. È una tecnica semplice, ma non adatta per gestire efficientemente sistemi complessi o grandi.
+ *Base e Bound*: tecnica semplice per la protezione della memoria, ma limitata in termini di flessibilità e scalabilità. Utilizza due registri
  - *Base*: per l'indirizzo base della memoria allocata al processo.
  - *Bound*: per il limite che definisce la dimensione della memoria.
+ *Segmentazione*: divide la memoria in segmenti logici di dimensioni variabili (ad esempio, codice, dati, stack). Ogni segmento ha un indirizzo base e una lunghezza, ma può causare frammentazione esterna, che la rende più complessa da gestire rispetto al mapping diretto.
+ *Paginazione*: memoria viene suddivisa in blocchi fissi chiamati "pagine". Ogni pagina è mappata a un frame fisico attraverso una tabella delle pagine. Riduce la frammentazione esterna ma introduce la possibilità di frammentazione interna e overhead di gestione.
+ *Paginazione con TLB (Translation Lookaside Buffer)*: l'uso di una cache ad alta velocità (TLB) per memorizzare le traduzioni più recenti degli indirizzi virtuali migliora le performance della paginazione. Sebbene il TLB ottimizzi la velocità, introduce la complessità della gestione della cache.
+ *Paginazione Multilivello*: la tabella delle pagine è suddivisa in più livelli, riducendo il consumo di memoria per la gestione delle tabelle. Ogni livello di tabella punta a un altro livello fino ad arrivare alla traduzione finale dell'indirizzo. Aumenta la complessità di gestione, ma è più efficiente in termini di memoria.

=== Tipi di Address Translation

Assunzioni:
1. Address space contiguo.
2. Address space non troppo grande e inferiore alla memoria fisica.
3. Tutti gli address space hanno la stessa dimensione.

*Hardware-based address translation*: l'hardware trasforma ogni accesso in memoria modificando l'indirizzo virtuale (VA) fornito dall'istruzione in un indirizzo fisico (dove è effettivamente memorizzata l'informazione). L'hardware da solo non può virtualizzare la memoria perché fornisce soltanto i meccanismi a basso livello per farlo in modo efficiente. L'OS deve gestire la memoria tenendo traccia delle posizioni libere e utilizzate controllando come viene utilizzata la memoria.

*Dynamic (Hardware-based) Relocation*: permette di spostare un processo in diverse posizioni della memoria fisica durante l'esecuzione senza che il processo stesso debba essere modificato. Il processore mantiene due registri hardware, il *base register* e il *bounds register*, che vengono utilizzati per la traduzione dell'indirizzo.

=== Registri per l'address translation

*Registri base-and-bounds*: ci permettono di posizionare l'address space ovunque nella memoria fisica assicurando che il processo possa accedere solamente al suo address space.

*base register*: contiene l'indirizzo fisico di base dell'area di memoria del processo.

*bounds register*: contiene la dimensione dell'area di memoria del processo.

Quando un processo genera un riferimento alla memoria, il processore aggiunge il valore del base register all'indirizzo virtuale fornito dal processo e ottiene un indirizzo fisico.

$ "indirizzo fisico" = "indirizzo virtuale" + "base" $

#figure(
  image("../images/translation/base and bound.png", width: 60%),
  caption: [Base and bound register. Schema creato dall'autore.],
)

*Traduzione di indirizzi*: trasformare un indirizzo virtuale in uno fisico. L'hardware che trasforma un indirizzo virtuale, a cui il processo pensa faccia riferimento, in uno fisico.

Se un processo genera un indirizzo virtuale esternamente ai limiti, la CPU solleverà un'eccezione e il processo verrà killato. I registri base-and-bounds sono strutture hardware mantenute dai chip (due per CPU).

*Rilocazione statica*: tecnica di rilocazione software-based eseguita dal loader. Il loader modifica gli indirizzi all'interno di un file eseguibile prima che il programma venga eseguito. Il processo di rilocazione consiste nel riscrivere gli indirizzi del programma, aggiungendo un offset che corrisponde alla posizione in memoria fisica in cui il programma verrà caricato. Ad esempio, se un programma è compilato per essere caricato a partire dall'indirizzo 0, ma viene caricato in memoria a partire dall'indirizzo 3000, tutti gli indirizzi del programma vengono aumentati di 3000. La rilocazione statica viene eseguita una sola volta, al momento del caricamento del programma in memoria. Una volta che un processo è stato caricato con rilocazione statica, è difficile spostarlo in un'altra posizione in memoria.Questa tecnica non offre protezione della memoria, poiché i processi possono generare indirizzi errati e accedere a memoria non autorizzata.

*Rilocazione dinamica*: tecnica di rilocazione hardware-based eseguita a runtime. Utilizza i registri base e bounds. Il base register contiene l'indirizzo fisico di partenza del processo in memoria. Ogni indirizzo virtuale generato dal programma viene sommato al valore del base register per ottenere l'indirizzo fisico corrispondente. Il bounds register definisce i limiti dell'area di memoria che il processo può utilizzare. L'hardware verifica che ogni indirizzo generato dal processo sia entro questi limiti. La traduzione degli indirizzi virtuali in indirizzi fisici viene eseguita dall'hardware ad ogni accesso alla memoria. La rilocazione dinamica permette di spostare un processo in una diversa posizione della memoria fisica anche dopo che è iniziato.Questa tecnica consente di implementare la virtualizzazione della memoria in modo efficiente e protetto, garantendo che ogni processo acceda solo alla propria area di memoria.

In sintesi, la *rilocazione statica* è un processo che modifica gli indirizzi di un programma prima della sua esecuzione, mentre la *rilocazione dinamica* avviene durante l'esecuzione del programma e utilizza registri hardware per la traduzione degli indirizzi e la protezione della memoria.

==== Esempio di traduzione
Supponiamo un processo con uno spazio di indirizzi di dimensioni 4 Kb che è stato caricato all'indirizzo fisico 16 KB.

#figure(
  image("../images/translation/translation.png"),
  caption: [Esempio di traduzione.],
)


=== Gestione dello spazio

*MMU (Memory Management Unit)*: gruppo di componenti hardware che gestisce gli accessi in memoria e si occupa di tradurre gli indirizzi virtuali in indirizzi fisici.
#figure(
  caption: [Come calcola il PA l'MMU. Schema creato dall'autore.],
  image("../images/translation/mmu.png"),
)

L'hardware dovrebbe fornire istruzioni speciali per modificare il base-and-bounds register accessibili solamente in modalità kernel.

*Free list*: elenco degli intervalli della memoria fisica non ancora utilizzati (l'OS deve tenere traccia della memoria per capire se è possibile allocare i processi).

#figure(
  image("../images/translation/dynamic rel.png"),
  caption: [Requisiti per la dynamic relocation.],
)

La CPU deve essere in grado di generare eccezioni in situazioni in cui un processo utente tenta di accedere alla memoria illegalmente. in caso di out of bounds, il processore deve interrompere l'esecuzione del processo utente e organizzare l'esecuzione dell'handler di eccezione out-of-bounds dell'OS. L'handler dell OS decidere come reagire. Allo stesso modo, se un processo utente tenta di modificare i valori dei registri base e limiti (privilegiati), il processore deve sollevare un'eccezione e eseguire l'handler "ha tentato di eseguire un'operazione privilegiata in modalità utente".

#figure(
  image("../images/translation/os responsibilities.png"),
  caption: [OS responsibilities.],
)

#figure(
  image("../images/translation/LDE Boot.png"),
  caption: [Limited Direct Execution (Dynamic Relocation) \@ Boot.],
)

Per supportare la dynamic relocation, l'OS:
+ Quando viene creato un nuovo processo l'OS deve reagire trovando spazio per l'address space dell'processo attraverso la *free list*.
+ Quando il processo viene terminato l'OS ripulisce le strutture dati allocate per il processo (liberando memoria).
+ Quando avviene un context-switch l'OS deve salvare le coppie di base-and-bounds.
+ Quando un processo viene interrotto, l'OS deve salvare in memoria i registri base-and-bounds nel PCB.
+ Quando un processo viene fermato, il S.O. può spostare il suo address space in un'altra locazione di memoria.
+ Quando il processo riprende l'esecuzione, deve ripristinare base e bound.
+ L'OS deve fornire gestori di eccezioni, o funzioni da chiamare, installa questi gestori all'avvio (tramite istruzioni privilegiate). Se un processo tenta di accedere a una memoria al di fuori dei suoi confini, il processore genererà un'eccezione.
#figure(
  image("../images/translation/lde runtime.png"),
  caption: [Limited Direct Execution (Dynamic Relocation) \@ Runtime.],
)

#colbreak()

