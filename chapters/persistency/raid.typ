== Redundant Array of Independent Disks (RAID)

*RAID (Redundant Array of Independent Disks)*: tecnica per utilizzare più dischi insieme per avere più velocità, più capienza e più affidabilità. Viene visto come un gruppo di blocchi che si possono leggere o scrivere. È un sistema complesso con più dischi, memoria volatile e persistente e anche un processore per gestire il sistema.

Vantaggi:
- *Prestazioni*: l'utilizzo di dischi in parallelo accelera i tempi di I/O.
- *Capacità*: è possibile storare grandi quantità di dati.
- *Affidabilità*: consente di avere forme di ridondanza.

Quando il file system invia una richiesta di I/O al RAID, il RAID deve calcolare a quale disco accedere.

Il RAID fornisce tutto ciò in maniera trasparente all'OS che lo vede come un unico grande disco. Quindi, non occorre fare alcuna modifica all'OS per renderlo compatibile al RAID. Quando il file system invia una richiesta di I/O al RAID, il RAID deve calcolare a quale disco accedere. Il RAID è spesso hardware separato formato da un microcontroller che esegue il software per il funzionamento e una memoria volatile DRAM per bufferizzare i blocchi che vengono letti/scritti.

Sono progettati per rilevare e ripristinare gli errori del disco.

*Modello fail-stop*: il disco o è funzionante o è guasto. Se funziona, tutti i blocchi possono essere scritti/letti. Se è guasto, i dati sono persi in modo permanente.

Il controller RAID (software o hardware) riconosce se il RAID è guasto.

*Obbiettivi del RAID*:
+ Distribuire l'informazione su più dischi in modo da parallelizzare una parte delle operazioni di accesso ai dati e guadagnare in prestazioni.
+ Duplicare su più dischi l'informazione memorizzata, in modo tale che, in caso di guasto di un disco, sia comunque possibile mantenere funzionante il sistema recuperando in qualche modo l'informazione perduta.

Come valutare un RAID:
- *Capacità*: dati $N$ dischi con $B$ blocchi, la capacità disponibile:
  - se non si ha ridondanza è $N dot B$.
  - se si hanno $2$ copie per ogni blocco è $(N dot B)/2$.
- *Affidabilità*: quanti errori del disco può tollerare
- *Prestazioni*: dipende dal workload dato al RAID.

=== RAID 0
*RAID 0 (striping)*: non è considerato un vero RAID. Consiste nel distribuire i blocchi disponibili in modo RR tra i dischi disponibili per aumentare il parallelismo in lettura/scrittura.

Alcune definizioni per valutare le performance del RAID:
- *$S$*: MB/s under a sequential workload.
- *$R$*: MB/s under a random workload.

Proprietà:
- *Capacità*: $N dot B$ blocchi di capacità utili.
- *Affidabilità*: qualsiasi guasto comporta la perdita di tutti i dati.
- *Performance*: eccellente perché vengono utilizzati tutti i dischi in parallelo.
  - Latenza di una singola richiesta: quasi identica a quella per singolo disco dato che il RAID deve inviare la richiesta a un suo disco.
  - Throughput sequenziale in stato stazionario: intera larghezza di banda ($N dot S$).
  - Throughput random in stato stazionario: $N dot R$.

#figure(
  image("../../images/raid/r0.png", width: 70%),
  caption: [Raid 0 o striping.],
) <raid0>

*Chunk size*: numero di blocchi in un chuck. Incide sulle performance del RAID.

In @raid0 abbiamo che:
- Chunk size = 1 block.
- Block size = 4 Kb.
- Stripe size = 16 Kb.

Abbiamo un problema di mapping dato che il RAID deve sapere in quale disco e l'offset a cui accedere. Soluzione:
- $"Disk"="Address_of_block" % "Number_of_disk"$
- $"Offset"="Address_of_block" / "Number_of_disk"$

Dimensione dei chunk:
- *Chunk troppo grande*: riduce il parallelismo intra-file, contando maggiormente su richieste multiple contemporanee per ottenere un'elevata capacità di trasferimento.
- *Chunk troppo piccolo*: più piccolo implica che molti file saranno distribuiti su molti dischi, aumentando così il parallelismo a discapito dei tempi di posizionamento.

Valutazione delle performance generali:
- *Latenza di una singola richiesta*: permette di capire quanto parallelismo puo esistere durante una singola richiesta I/O.
- *Throughput in stato stazionario di un RAID*: capacità totale di gestire molte richieste contemporanee. Consideriamo due tipi di carichi di lavoro:
  - *Workload Sequenziale*: le richieste coinvolgono blocchi contigui di dati.
  - *Workload Random*: richieste piccole e rivolte a una posizione casuale sul disco.

*Valutazioni del RAID 0*:
- *Capacità*: dati $N$ dischi, ognuno composto da $B$ blocchi, il RAID di livello zero fornisce $N dot B$ blocchi di capacità utile.
- *Affidabilità*: il RAID di livello 0 è terribile: ogni disk failure porterà a una perdita di dati.
- *Performance*: eccellente. tutti i dischi sono utilizzati, spesso in parallelo, per servire le richieste di I/O.
- *Single-block-latency*: dovrebbe essere identica a quella di un singolo disco; dopotutto, RAID-0 semplicemente reindirizza la richiesta a uno dei dischi.
- *Steady-state throughput*: ci aspettiamo di avere tutta la larghezza di banda del sistema. Il throughput sarà uguale a $N$ (il numero di dischi) moltiplicato per $S$ (la banda sequenziale di un singolo disco). Per un elevato numero di I/O random (workload introdotto la lezione scorsa), possiamo ancora una volta usare tutti i dischi, ottenendo quindi $N dot R$ MB/s.

*Nota bene*: $S = "Size"_"transfer"/"Time"_"I/O"$ rappresenta l'I/O rate di un workload sequenziale, $R = "Size"_"transfer"/"Time"_"I/O"$ quello di un workload random.

=== RAID 1
*RAID 1 (Mirroring)*: consiste nel creare più di una copia di ogni blocco su un disco separato. Ad ogni richiesta di lettura, è possibile leggere una copia del blocco richiesto da qualsiasi disco. In caso di una richiesta di scrittura, il RAID deve aggiornare tutte le copie su tutti i dischi per preservare l'affidabilità.

Proprietà (mirroring = 2):
- *Capacità*: $(N dot B)/2$ blocchi di capacità utili (la metà della capacità disponibile).
- *Affidabilità*: tollera il guasto di uno dei due dischi.
- *Performance*: normali.
  - *Latenza di una singola richiesta di lettura*: identica a quella per singolo disco.
  - *Latenza di una singola richiesta di scritture*: occorrono due scritture per il completamento della richiesta (tempo identico circa).
  - *Throughput sequenziale in stato stazionario*: ogni scrittura logica deve corrispondere a due scritture fisiche ($N/2 dot S$).
  - *Throughput random in stato stazionario*: miglior soluzione, distribuzione delle letture su tutti i dischi $N dot R$.

#figure(
  image("../../images/raid/r1.png", width: 70%),
  caption: [Raid 1 o mirroring.],
)

Combinazioni di RAID 1 e di RAID 0:

#table(
  columns: 2,
  stroke: 0pt,
  [
    #figure(
      image("../../images/raid/r10.png"),
      caption: [Raid 1 + 0.@a2023_confronto],
    )

  ],
  [
    #figure(
      image("../../images/raid/r01.png"),
      caption: [Raid 0 + 1 mirroring.@a2025_fileraid],
    )
  ],
)


=== RAID 4
*RAID 4*: i dati vengono distribuiti su più dischi e un disco è dedicato per la parità.

#figure(
  image("../../images/raid/r4.png", width: 70%),
  caption: [RAID 4 con parità.],
)

*Calcolo della parità*: si utilizza la funzione XOR. L'XOR di un insieme di bit restituisce:
- 0 se il numero di bit pari a 1 è pari.
- 1 se il numero di bit pari a 1 è dispari.

#figure(
  image("../../images/raid/parity.png", width: 80%),
  caption: [Calcolo della parità.],
)

#figure(
  image("../../images/raid/parity2.png", width: 90%),
  caption: [Calcolo della parità con blocchi.],
)

Il RAID livello 4 risparmia dischi rispetto al RAID di livello 1 e garantisce lo stesso il mantenimento dei dati in caso di guasto di un disco, ma al costo di una maggiore inefficienza. Infatti, ogni qualvolta una strip di un disco viene modificata, occorre leggere anche ricalcolarne la parità. Inoltre, il disco che ospita le strip di parità è pesantemente coinvolto in ogni operazione di scrittura sul RAID e può facilmente diventare un collo di bottiglia.

*Proprietà*:
- *Capacità*: $(N - 1)  B$, poiché un disco viene usato per la parità.
- *Affidabilità*: RAID 4 tollera il fallimento su un solo disco, non di più.
- *Performance*: Le performance di questi sistemi RAID non sono il massimo, anzi. Sono abbastanza sicuri ma, avendo un unico disco con le parità, siamo costantemente in attesa e di conseguenza tutte le operazioni a quel disco sono sequenziali.
- *Single-block-latency*: la latenza di una singola write richiede 2 read e 2 write (due per il dato e due per la parità). Le read possono essere fatte in parallelo, così come le write, la latenza totale è quindi doppia rispetto al singolo disco (con qualche differenza visto che dobbiamo aspettare che entrambe le reads vengano portate a termine).
- *Steady-state throughput*: consideriamo i nostri due workload, sequenziale e random. Nel caso di:
  - Scrittura sequenziale in tutta una striscia: la banda equivale a (N - 1) S MB/s (immaginandoci di ricevere una write per i blocchi 0, 1, 2 e 3, nonostante utilizziamo anche il blocco di parità in parallelo non ne traiamo un reale beneficio, per questo la banda è N-1 e non N).
  - Una random read: anche in questo caso le performance saranno pari a (N - 1) R MB/s perché non abbiamo bisogno di leggere il disco di parità.
  - Random writes invece: immaginiamo di voler scrivere il blocco 1 ad esempio. Potremmo semplicemente sovrascriverne il contenuto ma sorge un problema: il valore di parità va aggiornato perché potrebbe non essere più corretto.
Ci sono due metodi per andare a risolvere questo problema:
- *Additive parity*: per sapere il valore di parità si legge in parallelo il valore dei blocchi nella striscia e si esegue una XOR con il valore del nuovo blocco. Il problema di questa tecnica è che maggiore sono i dischi e più costosa diventa.
- *Subtractive parity*.

==== Small Write Problem
Il small write problem è una limitazione delle prestazioni nei sistemi RAID con parità (come RAID 4, 5 e 6) causata dalla gestione delle scritture su piccoli blocchi di dati.

Quando viene modificato un singolo bit (es. $"C2" -> "C2"_"new"$), il disco di parità deve essere aggiornato per mantenere la consistenza. Questo aggiornamento segue il metodo subtractive, che prevede:
+ Lettura del dato originale ($"C2"_"old"$) e della parità corrente ($P_"old"$).
+ Calcolo della nuova parità confrontando il vecchio e il nuovo valore del dato:
+ $P_"new" = (C_"old" xor C_"new") xor P_"old"$
+ Scrittura del nuovo dato e della nuova parità.

Soluzioni al Small Write Problem:
- *RAID con parità distribuita (es. RAID 5 e RAID 6)*: distribuiscono il carico della parità su più dischi, riducendo il problema.
- *Cache di scrittura (NVRAM o SSD)*: accumula piccole scritture e le applica in batch per ridurre l'overhead sul disco di parità.
- *RAID 10 (Striping + Mirroring)*: evita il problema eliminando la necessità di calcolare la parità.

=== RAID 5

*RAID 5*: simile al RAID 4 ma il blocco di parità ruota sui dischi per risolvere il problema della scrittura ridotta.

#figure(
  image("../../images/raid/r5.png", width: 70%),
  caption: [RAID 5 con rotated parity.],
)

Proprietà:
- *Capacità*: la capacità è uguale a quella del RAID-4, $(N-1)B$.
- *Affidabilità*: il RAID-5 e il RAID-4 offrono lo stesso livello di affidabilità.
- *Performance*: il RAID-5 rispetto al livello 4 ha performance notevolmente migliorate grazie alla disposizione dei blocchi di parità all'interno dei dischi. Con questa disposizione siamo in grado di eliminare l'effetto “collo di bottiglia” delle small write.
- *Single-write-latency*: è invariata rispetto al RAID-4, una write richiede 2 read e 2 write, la latenza è doppia rispetto a quella di un singolo disco.
- *Steady-state throughput*: nel workload random, il RAID-5 funziona leggermente meglio rispetto al RAID-4 perché ora possiamo utilizzare tutti i dischi. Infine, le performance di una write random è notevolmente migliorata rispetto al RAID-4 visto che ora siamo in grado di parallelizzare le richieste e non dobbiamo più accedere sequenzialmente al disco di parità.
Immaginiamo una write al blocco 1 e una write al blocco 10; verrà tradotta in una richiesta al disco 1 e una al disco 4 (per il blocco 1 e la sua parità) e una richiesta per il disco 0 e 2 (per il blocco 10 e la sua parità). In questo modo possono procedere in parallelo. Possiamo assumere che, dato un elevato numero di richieste random, saremo in grado di tenere occupati praticamente tutti i dischi. Se è questo il caso, allora la nostra larghezza di banda (bandwidth) per piccole writes sarà di (N/4)R MB/s. Il fattore di perdita 4 è dovuto al fatto che ogni write in un sistema RAID-5 genera 4 operazioni di I/O, che è semplicemente il costo dovuto all'impiego della parità (read data, read parity, write data, write parity)

#figure(
  image("../../images/raid/raid recap.png"),
  caption: [Capacità, affidabilità e performance dei RAID.],
)

#colbreak()