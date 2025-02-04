== Hard Disk Driver (HDD)

Il disco rigido è composto da un gran numero di settori (blocchi da 512 byte), ognuno dei quali può essere letto o scritto. Sono possibili operazioni multi-settore. Molti FS leggeranno o scriveranno 4 KB alla volta (o più). L'unica garanzia che i produttori di drive offrono è che una singola scrittura da 512 byte è atomica. Accedere a due blocchi vicini l'uno all'altro all'interno dello spazio di indirizzi del drive sarà più veloce che accedere a due blocchi che sono distanti. Accedere ai blocchi in un blocco contiguo (cioè una lettura o una scrittura sequenziale) sia la modalità di accesso più veloce e di solito molto più veloce di qualsiasi altro modello di accesso casuale.

=== Struttura e funzionamento
#figure(
  image("../../images/hdd/single track.png", width: 60%),
  caption: [Singola traccia con testa.],
)

Un disco rigido è composto da un piatto (*platter*) rotante che contiene $n$ tracce (*track*) da tutti e due i lati (*surface*). Ogni traccia è composta da un numero di settori (*sector*), che sono le unità di base di memorizzazione dei dati. I settori sono numerati da $0$ a $n-1$. Il disco è dotato di una testina (*disk head*) che può leggere e scrivere i dati sui settori. La testina è montata su un braccio (*disk arm*) che può essere spostato per accedere a diverse tracce. Il disco è in continuo movimento, quindi la testina deve essere posizionata sulla traccia corretta al momento giusto per leggere o scrivere i dati.

#figure(
  image("../../images/hdd/hdd.png"),
  caption: [Nomenclatura delle componenti di un HDD. @markham_2020_disk],
)

La velocità di rotazione è costante ed è misurata in RPM (Rotazioni Per Minuto). Il piatto ruota in senso antiorario.

=== Tempi di accesso

*Ritardo di rotazione*: tempo che il disco impiega per far ruotare il settore desiderato sotto la testina di lettura/scrittura. Nel caso peggiore, il ritardo di rotazione è pari alla metà del tempo di rotazione del disco.

La ricerca di un blocco ha più fasi:
- *Acceleration*: il braccio si muove.
- *Coasting*: il braccio si muove a velocità piena per inerzia.
- *Deceleration*: il braccio rallenta.
- *Settling*: il braccio si stabilizza mentre la testina viene posizionata con attenzione.

*Seek time*: tempo necessario per spostare la testina da una traccia all'altra.

#figure(
  image("../../images/hdd/multiple tracks.png"),
  caption: [Tre track e una testa.],
)

I settori di un disco rigido sono spesso sfalsati perché quando il braccio si sposta da una traccia all'altra, ha bisogno di tempo per riposizionarsi (anche su tracce adiacenti). Se i settori non fossero sfalsati, il braccio si sposterebbe sulla traccia successiva ma il blocco successivo desiderato sarebbe già passato.

Le tracce esterne tendono ad avere più settori delle tracce interne. Queste tracce sono spesso chiamate *dischi multi-zoned*, dove il disco è organizzato in più zone e ogni zona è un insieme consecutivo di tracce su una superficie. Ogni zona ha lo stesso numero di settori per traccia e le zone esterne hanno più settori delle zone interne.

=== Politiche di scrittura
*Cache o track buffer*: piccola quantità di memoria che il disco può utilizzare per memorizzare i dati letti o scritti sul disco. Ad esempio, quando si legge un settore dal disco, il disco potrebbe decidere di leggere tutti i settori su quella traccia e memorizzarli nella sua memoria; questo consente al disco di rispondere rapidamente a qualsiasi richiesta successiva alla stessa traccia.

In scrittura il disco ha una scelta:
- *Caching write back*: riconoscere che la scrittura è stata completata quando ha messo i dati nella sua cache.
- *Write through*: riconoscere che la scrittura è stata completata dopo che la scrittura è stata effettivamente scritta sul disco.

=== Analisi delle performance
Tempo per una rotazione completa:
$ "Time (ms)" = ("1 minuto") / ("RPM") $

Esempio con 10000 RPM:
$ "Time (ms)" = (60000 "ms") / (10000 "rotazioni") = 6 "ms/rotazione" $

Tempo di trasferimento di un blocco:
Se dobbiamo trasferire 512 KB con una velocità di 100 MB/s, il tempo di trasferimento è:
$ T_("transfer") = (512 "Kb") / (100 "MB/s") $

Convertendo le unità:
$
  T_("transfer") = (512 times 10^3 "B") / (100 times 10^6 "B/s") = 512 / 100000 "s" = 5.12 "ms"
$

Tempo di I/O totale:
$ T_("I/O") = T_"seek" + T_"rotation" + T_"transfer" $

Velocità di I/O:
$ R_("I/O") = "Size"_"transfer" / T_("I/O") $

*Workload sequenziale*: legge molti settori contigui sul disco.

*Workload casuale*: emette piccole letture (es. 4KB) in posizioni randomiche del disco.

Date un insieme di richieste di I/O, lo scheduler del disco le esamina e decide quale programmare successivamente. La durata effettiva di un I/O è sconosciuta ma è possibile stimarla ipotizzando un ritardo della ricerca e il ritardo di rotazione di una richiesta. In questo modo lo scheduler del disco, se è SJF (Shortest Job First), potrà scegliere quale richiesta gestire per prima.

=== Disk scheduling

*SSTF (Shortest Seek Time First)* o *SSF (Shortest Seek First)*: ordina la coda delle richieste I/O in base alla traccia. Completerà prima le richieste vicine alla traccia corrente. Problemi:
1. *Geometria non disponibile*: l'OS lavora con i blocchi senza conoscere la geometria dell'unità. Siccome l'OS vedi il disco come un insieme di blocchi, il problema viene risolto con NBF (Nearest Block First), un algoritmo che pianifica la richiesta che ha l'indirizzo più vicino a quello corrente.
2. *Starvation*: se ci fosse un flusso importante di richieste tutte a blocchi vicini, i blocchi lontani soffrirebbero di starvation.

*Sweep*: passaggio della testina da una traccia interna su una esterna o viceversa.

*Algoritmo dell'ascensore o SCAN*: muove la testina in modo sequenziale avanti e indietro. Inizialmente, si muove in una direzione soddisfacendo le richieste lungo il percorso. Quando raggiunge l'estremità, inverte la direzione e continua a soddisfare le richieste nella direzione opposta. Il problema è che le richieste alle estremità, essendo in fondo alla coda, soffriranno di fame. Ha due varianti:

- *F-SCAN*: durante una scansione (sweep), F-SCAN "freeza" la coda in modo che le richieste arrivate durante la scansione vengano messe in una coda temporanea per essere elaborate successivamente. Questo evita la possibilità di fame delle richieste più lontane, ritardando il servizio delle richieste arrivate tardi ma più vicine.
- *C-SCAN o Circular SCAN*: dopo aver raggiunto l'estremità in una direzione, torna rapidamente all'inizio. Questo significa che le richieste agli estremi della coda non subiscono ritardi significativi dovuti all'inversione della direzione.

Questi algoritmi non aderiscono al principio SJF. Soluzione: SPTF (Shortest Positioning Time First).

*SPTF (Shortest Positioning Time First*): seleziona la richiesta successiva da servire in base al tempo di posizionamento più breve, cercando di ridurre al minimo il tempo di ricerca della testina. SPTF è vantaggioso quando ricerca e rotazione sono approssimativamente equivalenti, ma la sua implementazione è complessa.

La scelta tra richieste più vicine o più lontane dipende dal rapporto tra il tempo di ricerca e il ritardo di rotazione. Se il tempo di ricerca è molto più alto del ritardo di rotazione, algoritmi come SSTF sono adatti, ma se la ricerca è notevolmente più veloce della rotazione, può essere preferibile servire richieste più lontane.

=== Formulario per i dischi rigidi

*Tempo di I/O totale*

$ T_("I/O") = T_"seek" + T_"rotation" + T_"transfer" $

Dove:
- $T_"seek"$ è il tempo di seek (posizionamento della testina sulla traccia corretta).
- $T_"rotation"$ è il tempo di rotazione (attesa che il settore passi sotto la testina).
- $T_"transfer"$ è il tempo di trasferimento (lettura/scrittura dei dati).

*Throughput*

$ "Throughput" = "Size"_"Transfer" / T_"I/O" $

Misura la quantità di dati trasferiti per unità di tempo.

*Tempo Medio di Seek*

$ T_"seek" = 1 / 3 T_"seek"^"max" $

Dove $T_"seek"^"max"$ è il tempo massimo per muoversi tra le tracce più distanti.

*Tempo di Rotazione Medio*

$ T_"rotation" = 1 / 2 T_"rotation"^"max" $

Dove il tempo di rotazione massimo è dato da:

$ T_"rotation"^"max" = 60000 / "RPM" "(in ms)" $

*Tempo di Trasferimento*

$ T_"transfer" = "Size"_"Transfer" / "Transfer Rate" $

Dove:
- $"Size"_"Transfer"$ è la dimensione del trasferimento dei dati.
- $"Transfer Rate"$ è la velocità di trasferimento del disco.

Velocità di Trasferimento Massima

$
  "Max Transfer Rate" =\ ("Settori per traccia" times "Dimensione settore" times "RPM") / 60
$

Dove:
- "Settori per traccia" è il numero di settori per traccia.
- "Dimensione settore" è tipicamente 512B o 4KB.
- "RPM" indica le rotazioni per minuto.

*Distanza Media di Seek*

$ 1 / (N^2) sum_(x=0)^N sum_(y=0)^N |x - y| = N / 3 $

Dove $N$ è il numero totale di tracce.

*Rateo di I/O*

$ R_"I/O" = "Size"_"Transfer" / T_"I/O" $

Indica la velocità con cui le operazioni di I/O vengono eseguite.

*Utilizzo del Disco*

$ U = T_"I/O" / T_"cycle" $

Dove $T_"cycle"$ è il tempo totale tra due richieste consecutive.

#colbreak()