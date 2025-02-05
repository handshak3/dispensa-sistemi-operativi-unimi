#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== File System (FS)

Per la costruzione di un file system VSFS (Very Simple File System) bisogna comprendere due aspetti principali:
+ *Strutture dati del file system*: che tipo di strutture utilizza il file system su disco per mantenere e organizzare dati e metadati.
+ *Metodo di accesso*: come vengono mappate le chiamate fatte da un processo (es. `open()`, `write()`).

=== Struttura di VSFS
Organizzazione del File System sul disco:
1. Il disco viene diviso in *blocchi* (es. 4KB).
  #image("../../images/fs/block.png")
2. La maggior parte dello spazio del FS sarà destinato ai dati dell'utente (data region).
  #image("../../images/fs/data region.png")
3. Il FS traccia le informazioni di ciascun file (*metadati*) e le conserva in una struttura chiamata *inode*. Va riservato lo spazio per la inode table. Supponendo 256 byte per inode, un blocco da 4 KB può contenerne 16. Quindi il massimo numero di file che si può avere è $16 "inode" dot 5 "blocchi" = 80$ file.
  #image("../../images/fs/inode region.png")
4. Occorre una struttura per tracciare se gli inode o i blocchi dati sono allocati o liberi. possiamo utilizzare:
  - *Free List*: punta al primo blocco libero e così via.
  - *Bitmap*: si utilizza una data bitmap e un'inode bitmap che indicano se l'oggetto/blocco corrispondente è libero (0) oppure in uso (1).

  #image("../../images/fs/bitmap region.png")

5. Lo spazio rimanente sarà occupato dal *superblocco*: contiene informazioni sul file system (n. inode, n. blocchi, ecc.), include anche il magic number per identificare il tipo di FS. Il super blocco verrà letto dall'OS per montare il FS.

  #image("../../images/fs/super block.png")

=== Inode
*inode (index node)*: struttura che contiene i metadati di un file. Ogni inode è implicitamente identificato da un numero detto "i-number", che funge da nome di basso livello.

*inode number*: identificatore univoco assegnato a ogni file o directory.

Dato un i-number, calcolare la posizione dell'inode corrispondente su disco. Supponendo di avere:

#figure(image("../../images/fs/inode table.png"), caption: [Inode table.])

L'obbiettivo è leggere l'i-number 32.

Assunzioni:
- $"SizeOf(inode)" = 512 "byte"$.
- $"InodeStartAddr" = 12 "Kb"$
+ Calcolare l'offset della regione dell'inode:
  $ "InodeOffset" = 32 dot "SizeOf(inode)"} = 8192 "byte" $

+ Trova l'indirizzo assoluto del blocco dell'inode cercato:

  $"Indirizzo Assoluto" =\ "InodeOffset" + "InodeStartAddress" = 20 "Kb"$

+ Trasforma l'indirizzo assoluto in un numero di settore:

  $"SectorNumber" = "AbsoluteAddr" / "SectorSize" = (20 dot 1024) / 512 = 40$

Formula generale:

$ "Block" = ("iNumber" dot "SizeOf(iNode)") / "BlockSize" $

$ "Sector" = (21) / "SectorSize" $

#figure(
  image("../../images/fs/inode field.png"),
  caption: [Ext2 Inode Simplified.],
)

=== Indice a più livelli

È importante come un inode fa riferimento ai blocchi dei dati. Approcci:
- *Puntatori diretti*: all'interno dell'inode dove ciascun puntatore si riferisce a un blocco di disco appartenente al file. L'approccio è limitato perché in caso di file di grosse dimensioni servirebbero troppi puntatori che superano la dimensione del blocco.
- *Puntatore indiretto*: invece di puntare a un blocco che contiene dati, punta a un blocco che contiene puntatori a dati utente. Un inode contiene un numero fisso di puntatori diretti o un singolo puntatore indiretto. Se il file cresce, viene allocato un blocco indiretto (nel data region) e lo slot dell'inode per un puntatore indiretto è impostato per puntare ad esso. Così aumenta la dimensione massima del file.
- *Doppio puntatore indiretto*: puntatore a un blocco che contiene altri puntatori a blocchi indiretti, ciascuno dei quali contiene puntatori a blocchi dei dati. Così aumenta la dimensione massima del file.

#figure(image("../../images/fs/pointers.png"), caption: [Esempi dei puntatori.])

- *Direct indexing*: il file può essere grande massimo 12 blocchi, ciascuno di dimensione 4 K.
- *Single indirect indexing*: il puntatore non punta a un blocco che contiene dati ma a un blocco che contiene altri puntatori. Ciascuno di questi puntatori punta a un blocco che contiene i dati utente. Avendo puntatori da 4-bytes (perché ogni indirizzo è grande 4-bytes), si ha un blocco di puntatori suddiviso in fette da 4 byte (1024 indirizzi da 4 bytes ciascuno).
Un file può essere grande $(12 + 1024)*4 "Kb" = 4144 "Kb"$.
3. *Double indirect indexing*: il puntatore punta a un blocco di puntatori, ciascuno dei quali punta a un altro blocco di puntatori, ciascuno dei quali, infine, punta a un blocco che contiene i dati utente. In questo caso un file può essere grande massimo $(12 + 1024 + 10242) dot 4 "Kb" = 4 "Gb"$.
- Triple indirect indexing: in questo caso riesco a indicizzare un numero enorme di blocchi,
riuscendo a supportare file di dimensioni notevoli. Nello specifico si ha $(12 + 1024 + 10242 + 10243)*4 "Kb" = 4 "Tb"$.
+ *Lista concatenata*: l'inode contiene un solo puntatore che indica il primo blocco del file, e per gestire file più grandi, vengono aggiunti ulteriori puntatori ai blocchi successivi. Ma questo può avere prestazioni inferiori. Per migliorare ciò, alcuni sistemi mantengono una tabella in memoria dei puntatori successivi per consentire accessi casuali. Un esempio di tale approccio è il sistema di file FAT utilizzato nei sistemi Windows precedenti a NTFS.

=== Gestione dello spazio libero
Un file system deve tracciare quali inode e blocchi dati sono liberi o occupati per allocare spazio ai nuovi file e directory.
- In vsfs, questo compito è svolto da due bitmap, una per gli inode e una per i blocchi dati.
- Quando si crea un file, il file system cerca un inode libero, lo assegna e lo segna come usato aggiornando la bitmap su disco.
- Lo stesso processo avviene per l'allocazione dei blocchi dati.

Alcuni file system, come ext2 ed ext3, adottano strategie per ottimizzare le prestazioni, ad esempio cercando blocchi contigui (es. gruppi di 8 blocchi liberi) per migliorare l'accesso sequenziale ai file. Questo metodo, detto pre-allocazione, aiuta a mantenere le porzioni dei file più compatte sul disco, aumentando l'efficienza.

In VSFS (Very Simple File System) una directory contiene coppie voce-inode number per ogni file o directory.

I FS vedono le directory come file speciali. La directory ha un inode nella tabella degli inode. I blocchi di dati della directory sono puntati dall'inode e risiedono nella regione dei blocchi di dati del sistema di file.

=== Directory Organization

Nei file system come VSFS, una directory è semplicemente una lista di coppie (nome file, numero inode) memorizzate nei blocchi dati della directory.

Struttura di una directory:
- Numero inode del file o directory.
- Lunghezza del record (dimensione del nome più eventuale spazio extra).
- Lunghezza del nome.
- Nome del file o directory.
- Ogni directory include sempre due voci speciali:
  - `.` (dot): riferimento alla directory stessa.
  - `..` (dot-dot): riferimento alla directory padre.

#image("../../images/fs/dir org.png")

Quando un file viene eliminato (`unlink()`), si crea uno spazio vuoto nella directory. Questo spazio può essere riutilizzato per nuove entry di dimensioni maggiori.

Le directory sono gestite come file speciali, con un proprio inode. Gli inode contengono puntatori ai blocchi dati della directory, memorizzati nella regione dei dati del file system.

File system avanzati come XFS usano strutture più efficienti come B-tree, migliorando le prestazioni delle operazioni di creazione ed eliminazione di file rispetto alle liste lineari.

=== Lettura su disco
Per leggere un file, il file system deve individuare il suo inode partendo dal suo percorso completo. Supponiamo di aprire `/foo/bar`, un file da 12KB (3 blocchi).

#text(9pt)[
  ```c
      open("/foo/bar", O_RDONLY);
  ```
]

+ Apertura del File (`open()`)
  + Il file system inizia dalla root (`/`), leggendo il suo inode. L'inode della root è un valore fisso (tipicamente 2 nei sistemi UNIX).
  + Legge i blocchi dati della root per trovare l'inode di `foo`.
  + Ripete il processo per `foo`, leggendo il suo inode e i suoi blocchi dati per individuare `bar`.
  + Una volta trovato, legge l'inode di `bar`, verifica i permessi e assegna un file descriptor al processo.

+ Lettura del File (`read()`)
  - Il primo read() legge il primo blocco del file, consultando l'inode per trovare la sua posizione su disco.
  - Aggiorna il tempo di ultimo accesso nell'inode.
  - Il puntatore del file viene aggiornato per consentire le letture successive.

+ Chiusura del File (`close()`)
- Il file descriptor viene deallocato, ma non sono necessarie operazioni su disco.

Considerazioni sulle prestazioni:
- Il numero di operazioni I/O dipende dalla lunghezza del percorso: più directory significa più inode e blocchi dati da leggere.
- Directory grandi peggiorano le prestazioni perché richiedono la lettura di più blocchi per trovare un file.

#figure(image("../../images/fs/read timeline.png"), caption: [Read timeline.])

=== Scrittura su file

Scrivere un file segue un processo simile alla lettura, con alcune differenze importanti: se il file non esiste, deve essere creato, e ogni scrittura può allocare nuovi blocchi su disco.

1. Apertura del File (`open()`)
- Se il file esiste, viene aperto come nella lettura.
- Se il file è nuovo, il file system:
  1. Trova e alloca un inode libero, aggiornando la bitmap degli inode.
  2. Inizializza il nuovo inode su disco.
  3. Aggiorna i dati della directory per collegare il nome del file al suo inode.
  4. Aggiorna l'inode della directory.

2. Scrittura del File (`write()`). Ogni scrittura può comportare:
  1. Lettura della bitmap dei blocchi per trovare un blocco libero.
  2. Scrittura della bitmap aggiornata.
  3. Lettura dell'inode per aggiornare i puntatori ai blocchi.
  4. Scrittura dell'inode aggiornato.
  5. Scrittura del blocco dati effettivo.


3. Chiusura del File (`close()`)
- Il file descriptor viene deallocato, senza operazioni su disco.

Efficienza della Scrittura:
- Creare un file comporta molte operazioni su disco, rendendolo un'operazione costosa.
- Allocare nuovi blocchi peggiora le prestazioni perché richiede aggiornamenti multipli alle bitmap e agli inode.
- Sistemi avanzati ottimizzano la scrittura con strategie come buffering e journaling per ridurre il numero di scritture effettive su disco.

#figure(
  image("../../images/fs/file creation timeline.png"),
  caption: [File creation timeline.],
)

=== Caching e buffering

Le operazioni di I/O su file sono costose in termini di tempo, poiché la lettura e la scrittura su disco richiedono numerosi accessi ai dati. Senza *caching*, ogni apertura di file comporterebbe molte operazioni di lettura, soprattutto con percorsi lunghi.

I file system hanno introdotto una cache di dimensione fissa (*fixed-size cache*) per memorizzare blocchi frequentemente utilizzati. Strategie come LRU (Least Recently Used) vengono impiegate per determinare quali blocchi mantenere in cache. Inizialmente, la cache veniva allocata staticamente al boot per circa il 10% della memoria totale. Questo metodo presentava però un problema, poiché l'allocazione fissa poteva risultare inefficiente se la memoria non veniva utilizzata appieno.

I sistemi moderni adottano un approccio più flessibile con la page cache unificata, che gestisce dinamicamente la memoria tra cache del file system e memoria virtuale (*partizionamento dinamico*). Questo sistema permette di assegnare la memoria in base alle necessità attuali, evitando sprechi. Quando un file viene aperto per la prima volta, si genera traffico I/O, ma le aperture successive possono sfruttare la cache e ridurre le operazioni di lettura.

La cache ha un impatto significativo anche sulle operazioni di scrittura. Mentre le letture possono essere evitate se i dati sono già in cache, le scritture devono comunque essere registrate su disco per garantire la persistenza. Il buffering delle scritture consente di raggruppare aggiornamenti, riducendo il numero di operazioni di I/O. Inoltre, permette di ottimizzare la pianificazione delle scritture e in alcuni casi di evitarle del tutto, come quando un file viene creato e poi eliminato prima di essere effettivamente scritto su disco.

I file system moderni ritardano le scritture tra cinque e trenta secondi per ottimizzare le prestazioni. Questo introduce un compromesso tra performance e sicurezza dei dati, poiché in caso di crash del sistema prima della scrittura definitiva su disco, i dati presenti in memoria vengono persi. Alcune applicazioni, come i database, non possono accettare questo rischio e adottano strategie alternative, come la chiamata a `fsync()` per forzare la scrittura su disco, l'uso di I/O diretto per bypassare la cache o l'accesso diretto al disco senza passare dal file system.

La gestione del caching e del buffering nei file system bilancia le prestazioni con l'affidabilità, offrendo opzioni per adattarsi alle esigenze specifiche delle applicazioni.

#line()