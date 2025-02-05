#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Fast FIle System (FFS)

Il primo file system di UNIX, era molto semplice e organizzava i dati su disco in tre sezioni principali:
- Super block, inode region e data blocks. Tuttavia, nonostante la sua semplicità e facilità d'uso, soffriva di gravi problemi di prestazioni.

=== Problema: Scarse Prestazioni
- Il file system trattava il disco come una memoria ad accesso casuale, ignorando i costi di posizionamento fisico.
- I blocchi di dati di un file erano spesso lontani dal suo inode, causando costosi spostamenti della testina del disco.
- La gestione della lista dei blocchi liberi portava a frammentazione, con file distribuiti in diverse aree del disco invece che in blocchi contigui.
- Il blocco di dimensioni ridotte (512 byte) aumentava i costi di trasferimento dei dati.

=== Soluzione: disk aware

Il Fast File System (FFS) è stato progettato per essere *disk aware* (consapevole della struttura fisica sottostante del disco su cui opera e ottimizza le sue operazioni di conseguenza), migliorando così le prestazioni rispetto al precedente file system UNIX. Pur mantenendo la stessa interfaccia e API (`open()`, `read()`, `write()`, `close()`), FFS ha introdotto nuove strutture e politiche di allocazione più efficienti. Questo approccio ha aperto la strada alla ricerca sui file system moderni, che continuano a ottimizzare gli interni per migliorare prestazioni, affidabilità e compatibilità con le applicazioni esistenti.

=== Struttura con i cylinder group
FFS migliora l'organizzazione dei dati su disco suddividendolo in *cylinder groups*, ciascuno composto da N cilindri consecutivi.

*Cilindro*: insieme di tracce alla stessa distanza dal centro del disco su più superfici, e raggruppare più cilindri riduce la frammentazione e migliora le prestazioni minimizzando gli spostamenti della testina.

#figure(
  image("../../images/ffs/cilindro.png"),
  caption: [Struttura del cilindro.],
)

Nei file system moderni, come ext2, ext3 ed ext4, questa struttura è implementata come *block groups*, poiché i dischi moderni astraggono la geometria fisica esponendo solo uno spazio logico di blocchi. Tuttavia, il principio rimane lo stesso: collocare file correlati nello stesso gruppo per ridurre i tempi di seek.

#figure(
  image("../../images/ffs/gruppi.png"),
  caption: [Struttura di block groups.],
)

Ogni cylinder group contiene:
- *Superblock (S)*: una copia del superblocco per ridondanza, utile in caso di corruzione.
- *Bitmap degli inode (ib)* e dei *dati (db)*: utilizzate per tracciare quali inode e blocchi dati sono allocati o liberi. L'uso delle bitmap facilita l'allocazione di blocchi contigui, riducendo la frammentazione.
- *Regione degli inode* e *blocchi dati*: simile alla struttura del vecchio file system UNIX, ma organizzata per ottimizzare l'accesso ai file.

Grazie a questa organizzazione, FFS migliora significativamente le prestazioni rispetto al vecchio sistema, ottimizzando sia l'allocazione che l'accesso ai dati.

=== Creazione di un file con FFS

Quando un nuovo file viene creato (es. `/foo/bar.txt` di 4KB), diverse strutture dati devono essere aggiornate su disco:

1. Allocazione dell'inode:
  - Viene assegnato un nuovo inode, che deve essere scritto su disco.
  - La bitmap degli inode viene aggiornata per segnare l'inode come allocato.

2. Allocazione del blocco dati:
  - Il file ha contenuto, quindi è necessario un blocco dati.
  - La bitmap dei dati viene aggiornata per indicare l'allocazione.

3. Aggiornamento della directory:
  - La directory `foo` deve essere aggiornata per includere bar.txt.
  - Questo aggiornamento può avvenire in un blocco dati esistente o richiederne uno nuovo.
  - L'inode della directory viene modificato per aggiornare la dimensione e i metadati (es. last-modified-time).

=== Politiche di allocazione in FFS

FFS segue il principio "mantieni vicine le cose correlate e distanti quelle non correlate" per migliorare le prestazioni, riducendo i seek del disco. Per farlo, utilizza alcune euristiche di posizionamento per file e directory.

Allocazione delle Directory:
- FFS cerca un cylinder group con poche directory allocate e molti inode liberi per posizionare una nuova directory.
- Questo bilancia la distribuzione delle directory e garantisce spazio per i file futuri.

Allocazione dei File:
1. I blocchi dati di un file vengono posizionati nello stesso gruppo del suo inode, evitando seek lunghi.
2. I file nella stessa directory vengono collocati nello stesso cylinder group per preservare la località dei nomi.

Per esempio, se l'utente crea i file /a/c, /a/d, /a/e e /b/f, FFS organizza i file così:
- Gruppo 1 $->$ Contiene /a, /a/c, /a/d, /a/e (vicini tra loro).
- Gruppo 2 $->$ Contiene /b e /b/f (vicini tra loro).

#text(9pt)[
  ```txt
  group inodes      data
  0     /---------  /---------
  1     acde------  accddee---
  2     bf--------  bff-------
  3     ----------  ----------
  4     ----------  ----------
  5     ----------  ----------
  6     ----------  ----------
  7     ----------  ----------
  ```
]

Un'allocazione che distribuisce uniformemente gli inode tra i gruppi, senza considerare la località, porta a file della stessa directory sparsi su più gruppi. Questo peggiora le prestazioni, poiché i file correlati sono lontani e richiedono più seek per essere letti insieme.

#text(9pt)[
  ```txt
  group inodes      data
  0     /---------  /---------
  1     a---------  a---------
  2     b---------  b---------
  3     c---------  cc--------
  4     d---------  dd--------
  5     e---------  ee--------
  6     f---------  ff--------
  7     ----------  ----------
  ```
]

Le euristiche di FFS non derivano da studi complessi ma da buon senso: i file nella stessa directory sono spesso usati insieme (es. compilazione di codice), quindi tenerli vicini riduce i tempi di accesso e migliora le prestazioni del file system.

=== Misurare la Località dei File

Per valutare se le euristiche di FFS abbiano senso, è stato analizzato l'accesso ai file utilizzando i tracciamenti SEER [K94], misurando la distanza tra accessi consecutivi nella gerarchia delle directory.

Metodo di misurazione:
- Se un file f viene aperto e poi riaperto subito dopo, la distanza è 0.
- Se si accede a due file nella stessa directory (es. dir/f → dir/g), la distanza è 1.
- Se si accede a file in sottodirectory diverse, la distanza è misurata in base al primo antenato comune.

L'analisi ha mostrato che:
- 7% degli accessi erano allo stesso file aperto in precedenza (distanza 0).
- 40% degli accessi erano a file nello stesso file o nella stessa directory (distanza 0 o 1).
- 25% degli accessi erano a file con distanza 2, tipico di strutture organizzate gerarchicamente (es. proj/src/foo.c seguito da proj/obj/foo.o).

Limiti di FFS:
FFS ottimizza l'accesso ai file con distanza 0 o 1, ma non cattura bene la località a distanza 2, causando più seek. Questo accade quando gli utenti organizzano file in più livelli (es. sorgenti e oggetti separati in directory diverse).

Confronto con un accesso casuale:
- Un accesso casuale ai file mostra meno località, come previsto.
- Tuttavia, anche nel caso casuale c'è una certa località, poiché tutti i file condividono un antenato comune (es. la root del filesystem).

L'analisi dei tracciamenti conferma l'efficacia delle strategie di località di FFS, anche se potrebbe essere migliorata per strutture più profonde.

=== L'eccezione per i file grandi
La politica standard di FFS assegna file e metadati nello stesso gruppo per ridurre i seek. Tuttavia, per file molto grandi, questa strategia presenta un problema:
- Il file potrebbe riempire interamente un gruppo, impedendo ad altri file “correlati” di essere collocati lì.
- Questo riduce la località di accesso ai file futuri.

==== Soluzione FFS: Divisione in Chunk
Per evitare questo problema, FFS spezza i file grandi in blocchi e li distribuisce su gruppi diversi:
1. I primi blocchi (es. 12 blocchi, che corrispondono ai puntatori diretti nell'inode) vengono memorizzati nel primo gruppo.
2. Successivamente, i blocchi indiretti vengono spostati in gruppi diversi (scelti in base alla loro disponibilità).

==== Esempio senza l'eccezione per file grandi
Un file di 30 blocchi in un FFS con 10 inode e 40 blocchi dati per gruppo finirebbe per occupare quasi tutto un gruppo:

#image("../../images/ffs/es1.png")

Se ora vengono creati altri file nella root `/`, non c'è più spazio nel gruppo 0 per i loro dati, riducendo la località.

==== Esempio con l'eccezione per file grandi
Con la politica di suddivisione in chunk di 5 blocchi, il file viene distribuito su più gruppi:

#image("../../images/ffs/es2.png")


Ora altri file nella root `/` possono essere salvati nel gruppo 0 senza problemi.

Distribuire un file grande su più gruppi aumenta i tempi di seek, specialmente negli accessi sequenziali. Tuttavia, questa scelta:
- Evita che un file riempia un gruppo intero.
- Permette di mantenere la località tra file correlati.

Per bilanciare seek vs. trasferimento, si usa il concetto di ammortizzazione:
- Se il chunk è troppo piccolo, si passa troppo tempo in seek.
- Se il chunk è grande, si massimizza il tempo di trasferimento riducendo il seek overhead.

Per esempio, con:
- Tempo medio di posizionamento: 10 ms
- Velocità di trasferimento: 40 MB/s

Se vogliamo spendere metà del tempo in seek e metà in trasferimento, dobbiamo trasferire almeno:
$40 "Mb" / s dot 10 "ms" = 409.6 "Kb"$
Maggiore è la percentuale di utilizzo della banda desiderata, più grande deve essere il chunk:
- 50% della banda $->$ 409.6 KB
- 90% della banda $->$ 3.6 MB
- 99% della banda $->$ 39.6 MB

==== Strategia di FFS
FFS non ha scelto chunk in base a questo calcolo, ma ha seguito una strategia più semplice:
- I primi 12 blocchi diretti rimangono nel gruppo dell'inode.
- Ogni blocco indiretto e i suoi puntatori vengono assegnati a gruppi diversi.
- Con blocchi di 4KB, ciò significa che ogni 4MB del file sono salvati in gruppi separati.

Evoluzione nel tempo:
- La velocità di trasferimento dei dischi migliora rapidamente.
- Il tempo di seek e la rotazione migliorano molto più lentamente.
- Ciò significa che nel tempo il costo del seek diventa relativamente più alto, rendendo necessaria l'ammortizzazione con chunk più grandi.

L'eccezione per i file grandi in FFS riduce il problema dell'allocazione di spazio nei gruppi, migliorando la località per altri file. Tuttavia, ha il costo di maggiori seek durante l'accesso sequenziale. La chiave per bilanciare queste due esigenze è scegliere la giusta dimensione del chunk, per minimizzare i tempi di seek e massimizzare l'efficienza del trasferimento dati.

=== Altri miglioramenti
FFS ha introdotto diverse innovazioni significative per migliorare l'efficienza e l'usabilità dei file system.

1. *Sub-blocchi per file piccoli*: FFS ha risolto il problema dell'inefficienza dei blocchi da 4KB per file di dimensioni ridotte (spesso intorno ai 2KB) utilizzando sub-blocchi da 512 byte. Questo ha ridotto la frammentazione interna. Quando un file piccolo cresceva, FFS consolidava i sub-blocchi in blocchi da 4KB.

2. *Layout ottimizzato per le prestazioni*: FFS ha risolto il problema del posizionamento consecutivo dei settori sul disco, "parametrizzando" il layout. Saltando blocchi tra loro, evitava i ritardi dovuti alla rotazione del disco, migliorando così le prestazioni di lettura sequenziale.

3. *Miglioramenti dell'usabilità*: FFS ha reso il sistema più facile da usare introducendo nomi di file lunghi, collegamenti simbolici (per riferimenti più flessibili a file e directory) e un'operazione di rinomina atomica per i file. Sebbene non siano innovazioni tecniche rivoluzionarie, queste migliorie hanno contribuito a una maggiore adozione e fruibilità di FFS.

Queste scelte progettuali hanno mostrato un equilibrio tra innovazione tecnica e miglioramenti pratici, rendendo FFS più efficiente e accessibile per gli utenti.

#line()