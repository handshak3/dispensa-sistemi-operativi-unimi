#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Dischi

Le memorie di massa si suddividono in due categorie:
- *Direct-access storage device (DASD)*: comprendono i dischi magnetici, come gli hard disk, che offrono alta capacità, basso costo e velocità relativamente elevate, e i floppy disk, che sono ormai obsoleti a causa della loro bassa capacità e lentezza.
- *Serial Devices*: dischi ottici come i CD-ROM, che hanno capacità limitate ma sono ancora utilizzati in alcuni ambiti. I dispositivi ad accesso seriale, come i nastri magnetici, offrono un accesso sequenziale molto veloce, ma risultano inefficienti per operazioni di accesso casuale ai dati.

Unità di misura spaziali:
- *byte*: 8 bits
- *kilobyte (KB)*: 1024 or $2^10$ bytes
- *megabyte (MB)*: 1024 kilobytes or $2^20$ bytes
- *gigabyte (GB)*: 1024 megabytes or $2^30$ bytes

Unità di misura temporali:
- *nanosecond (ns)*: one- billionth (10-9) of a second.
- *microsecond (s)*: one- millionth (10-6) of a second.
- *millisecond (ms)*: one- thousandth (10-3) of a second.

==== Dischi magnetici

I dati, rappresentati da bit (0 o 1), vengono scritti su piatti circolari ricoperti di materiale ferromagnetico, chiamati *dischi*. Questi ruotano continuamente ad alta velocità. Le *testine* di lettura/scrittura registrano o leggono i dati quando i *piatti* passano sotto di esse. Nei disk drive dei PC sono presenti più piatti per aumentare la capacità di archiviazione. Il disco contiene *tracce* concentriche che sono divise in *settori*. Il *blocco* è l'unità indirizzabile più piccola di un disco. Un *cilindro* è un set di tracce posizionate ad un determinato raggio del disco (inteso come insieme di piatti).

Il disco ha un controllare che ha una cache che viene utilizzata da buffer per le richieste di lettura/scrittura.

Quando un programma legge un byte dal disco l'OS localizza la sua posizione sulla superficie (traccia/settore) e legge l'intero blocco in una speciale area di memoria che funziona da buffer. Il collo di bottiglia nell'accesso al disco è il movimento dei bracci delle testine. Ha quindi senso immagazzinare il file in tracce che occupano la medesima posizione su diversi piatti e superfici piuttosto che su diverse tracce della superficie di un singolo piatto.

=== Calcolo dei blocchi

- $"blocchiPerSuperficie" = "cilindriPerDisco" times "settoriPerDisco"$

- $"blocchiPerDisco" = "blocchiPerSuperficie" times "TestinePerDisco"$

- $"blocchiPerDisco" = "cilindriPerDisco" times "settoriPerDisco" times "TestinePerDisco"$

- $"blocchi" = "cilindri" times "testine" times "settori"$

- $"Offset" = C times (H times S) + H times S + S$

=== Notazione
(C,H,S)

Esempio: (0, 0, 2)
- C = 0 $->$ Cilindro (traccia) 0
- H = 0 $->$ Testina (piatto) 0
- S = 2 $->$ Settore 2

=== Esercizio calcolo dei blocchi
Dati:
- 3 cilindri (C)
- 2 Testine (T)
- 8 Settori (S)

Calcoli:\
$"blocchi" = 3 times 2 times 8 = 48 "blocchi"$

=== Esercizio calcolo dell'Offset

Si considera la posizione iniziale (0,0,2) e la posizione finale (1,0,3).

#align(center)[#image("../../images/lab/ex sectors.png", width: 60%)]

+ Calcolo della posizione finale (1,0,3):
  $
    1 times (2 times 8) + 0 times 8 + 3 times 1\
    = 1 times 16 + 0 +3\
    = 16 + 3 = 19\
  $

+ Calcolo della posizione iniziale (0,0,2)
  $
    0 times (2 times 8)+0 times 8+2 times 1\
    =0 + 0 + 2 = 2
  $

+ Differenza tra le due posizioni:
  $ 19 - 2 = 17 $

=== Tempo di lettura/scrittura
- $"TempoDiLettura" = "TempoDIRotazione" + "TempoDiRicerca" + "TempoDiAccesso"$
- $"RateDiLettura" = "DimensioneTrasferimento" / "TempoDiLettura"$

=== Algoritmi per ottimizzare il tempo di ricerca

- *First Come First Served (FCFS)*: Gli accessi ai blocchi del disco vengono serviti nell'ordine in cui arrivano, senza alcuna ottimizzazione. È semplice, ma può causare lunghi tempi di attesa se le richieste sono distribuite in modo casuale (effetto "starvation").
- *Shortest Seek First (SSTF)*: L'algoritmo sceglie sempre la richiesta più vicina alla posizione attuale della testina, riducendo il tempo di ricerca medio. Tuttavia, può causare starvation per richieste lontane se il disco è molto occupato.
- *Scan / Look (Elevator)*: La testina si muove in una direzione servendo tutte le richieste fino a raggiungere il limite (Scan) o l'ultima richiesta esistente (Look), poi inverte la direzione. Questo metodo assicura un tempo di risposta più equo rispetto a SSTF e riduce la frammentazione delle richieste.

=== Stima capacità del disco
- $"CapacitàTraccia" = "SettoriPerTraccia" times "BytePerSettore"$

- $"CapacitàCilindro" = "CapacitàTraccia" times "TraccePerCilindro"$

- $"TraccePerCilindro" = "TraccePerSuperficie" times "NumeroDiTestine"$

- $"CapacitàDisco" = "CapacitàCilindro" times "CilindriPerDisco"$

- $"CilindriPerDisco" = "TracciePerSuperficie"$

=== Esercizio capacità disco
Salvare un file di 20000 record su un disco con le seguenti caratteristiche:
- 512 bytes per sector
- 40 sector per track
- 11 tracks per cylinder
- 1331 cylinder

+ Quanti cilindri sono richiesti se ogni record occupa 256 bytes?
+ Qual è la capacità totale del disco?

Calcolo dei settori necessari:\
Ogni settore può contenere:\
$512 / 256 = 2 "record per settore"$\
Quindi, il numero totale di settori necessari per memorizzare 20.000 record è:
$20000 / 2 = 10.000 "settori"$

+ Calcolo dei cilindri richiesti:

  Ogni cilindro ha:
  $40 times 11 = 440 "settori per cilindro"$

  Quindi, il numero di cilindri necessari è:

  $10000 / 440 = tilde 22.73$

  Poiché un cilindro parziale non è possibile, servono 23 cilindri.

+ Capacità totale del disco

  Calcoliamo la capacità complessiva del disco considerando tutti i cilindri:

  $1331 times 440 times 512 = 299.499.520 "bytes"$

  Convertiamolo in Gigabyte (GB):

  $299.499.520 / (1024 times 1024 times 1024) = tilde 0.28 "GB"$
  Capacità totale del disco ≈ 0.28 GB (circa 280 MB).

Risultati Finali:
- Cilindri richiesti: 23
- Capacità totale del disco: $tilde$280 MB

==== Esercizio
- Supponiamo di voler leggere consecutivamente i settori di una traccia ordinati dal primo all'ultimo : sectors 1, 2,…11.
- Supponiamo che due settori consecutivi non possano essere letti in assenza di interlacciamento.

Quante rivoluzioni sono necessarie per leggere l'intero disco?
- Senza interlacciamento
- Con interlacciamento 3:1
Nota: Al giorno d'oggi molti controllori dei dischi sono veloci e quindi l'interlacciamento non è più così commune.

=== Tempo di ricerca (seek Time)
*Tempo di ricerca*: tempo richiesto per muovere il braccio della testina sul cilindro desiderato. È la componente che incide di più sul tempo di accesso. Tipicamente:
- 5 ms per muoversi da una traccia alla successive (track-to-track).
- 50 ms tempo di ricerca massimo (per spostarsi al di fuori di una traccia quando ci si trova la suo interno).
- 30 ms tempo di ricerca medio (da una qualsiasi traccia ad una qualsiasi altra traccia).

=== Tempo di ricerca medio (s)
Il tempo di ricerca dipende unicamente dalla velocità con cui si muovono i bracci delle testine e dal numero di tracce che devono essere attraversate per raggiungere l'obiettivo. Data la conoscenza delle seguenti informazioni (che sono costanti per ogni specifico modello di disco):
- $H_s$ = tempo richiesto perché la testina inizi a muoversi.
- $H_t$ = tempo richiesto perché la testina si muova da una traccia alla successiva.

Il tempo necessario perché la testina si muova di n tracce è:
$ "Seek"(n)= "Hs"+ "Ht" times "n" $

=== Latenza rotazionale (r)
Latenza è il tempo richiesto necessario perché il disco ruoti in modo che il settore che ci interessa sia sotto la testina di lettura/scrittura. Gli hard disk ruotano a circa 5000-7000 rpm (12-8 msec per rivoluzione).

Note:
- Latenza minima = 0.
- Latenza massima = tempo per una intera rivoluzione del disco.
- $"Latenza media"(r) = (min + max) / 2 = max / 2 = "tempo" 1 / 2 "rivoluzione del disco"$

Circa 5000 - 7000 RPM, 12/8 ms per rivoluzione RPM/60 = RPS
Latenza Massima = $1/"RPS" = "sec"/"rotazione"$
Latenza Media = $("Latenza Massima") / 2$

=== Tempo di trasferimento
Il tempo di trasferimento è il tempo richiesto perché una testina passi attraverso un blocco.

$"Tempo di trasferimento" = "settori da trasferire" / "settori in una traccia" times "tempo di rotazione"$

Il tempo di trasferimento dipende unicamente dalla velocità a cui ruotano i piatti e dal numero di settori che deve essere trasferito.

$"St"$ = numero totale settori per traccia.

È possibile calcolare il tempo di trasferimento per n settori contigui sulla stessa traccia come segue:

$"Tempo trasferimento" = (n / "St")times(1000/R)$

=== Esercizio latenza, capacità e tempo di lettura

Dati:
- 20 superfici
- 800 tracce/superficie
- 25 settori/traccia
- 512 bytes/settore
- 3600 rpm (revolutions per minute)
- 7 ms track-to-track seek time
- 28 ms avg seek time
- 50 ms max seek time

Calcolare:
- Latenza media
- Capacità del disco
- Tempo richiesto per leggere l'intero disco, un cilindro alla volta

Calcoli:
- Latenza Media = $("Latenza Massima") / 2 = (60 times 1000/3600)/2 = 8.33 "ms"$.
- Capacità disco = $20 times 800 times 25 times 512 = 193.31 "MB"$
- Tempo di lettura dell'intero disco = $20 times 800 times 7 = 112 "sec"$

== File System
Il file system è un'astrazione fornita dal sistema operativo per organizzare e gestire i dati memorizzati su dispositivi di archiviazione di massa. Fornisce:
- *File*: unità logiche di dati.
- *Directory*: strutture per organizzare i file.
- *Permessi* e *attributi*: per gestire accesso e proprietà.

=== Astrazione del Device Logico
- Il sistema operativo vede il disco come un device a blocchi.
- Ogni dispositivo è identificato da:
  - *Major number*: identifica la categoria del device (es. disco IDE, SSD, USB).
  - *Minor number*: numero specifico del device all'interno della categoria.
- File speciali si creano con `/usr/bin/mknod` e possono essere:
  - *b*: device a blocchi.
  - *c*: device a caratteri.
  - *p*: named pipe.

=== Partizionamento del Disco
- Un disco può essere diviso in partizioni, che possono contenere file system diversi.
- *Partition Table Sector (PTS)*: contiene informazioni sulle partizioni primarie agli offset 446, 462, 478, 494.
- Partizione estesa: può contenere altre partizioni logiche.
- Struttura `struct partition` in C:
  ```c
  struct partition {
      char active;
      char begin[3];
      char type;
      char end[3];
      int start;
      int length;
  };
  ```

=== Accesso ai File
- *Accesso sequenziale*: lettura/scrittura dall'inizio alla fine.
- *Accesso random*: lettura/scrittura in punti specifici del file.

*Directory*
- Struttura utilizzata per organizzare i file.
- Possibili strutture:
  - *Sistema a singola directory*: tutti i file in un unico spazio.
  - *Sistema a due livelli*: ogni utente ha una directory personale.
  - *Gerarchico*: simile agli alberi delle directory UNIX.

=== Struttura del File System ext2
- *Super Block*: contiene informazioni su dimensioni e stato del filesystem.
- *Cylinder Groups*: suddivisione logica per migliorare efficienza e affidabilità.
- *I-node*:
  - Contiene metadati su file (tipo, permessi, proprietario, dimensioni, timestamp, puntatori ai blocchi di dati).
  - Struttura con puntatori diretti, indiretti, doppi e tripli indiretti per la gestione efficiente dello spazio.
  - Indirizzamento dei blocchi:
    - *Diretto*: puntatori diretti ai blocchi dati.
    - *Indiretto singolo*: puntatore a un blocco che contiene altri puntatori a blocchi dati.
    - *Indiretto doppio*: puntatore a un blocco che contiene puntatori ad altri blocchi di puntatori.
    - *Indiretto triplo*: struttura simile al doppio, con un livello aggiuntivo.

=== Creazione e gestione delle partizioni
```bash
fdisk /dev/sda
mkfs /dev/sda1
mount /dev/sda1 /mnt/disksda1
```
=== Backup e verifica consistenza
- *Backup*: utilizzo di mappe di bit per identificare blocchi modificati.
- *Check di consistenza*: verifica blocchi persi o duplicati.
- *Esercizi sugli i-node*:
  - Calcolare il numero massimo di blocchi indirizzabili con puntatori diretti.
  - Determinare il numero massimo di blocchi indirizzabili con un blocco indiretto singolo.
  - Stimare la massima dimensione di un file considerando i puntatori diretti, indiretti, doppi e tripli.
  - Simulare la scrittura di un file grande e verificare quali blocchi vengono utilizzati.

*Comandi Utili*
- `ls` - Lista file e directory.
- `mkdir` - Creazione directory.
- `rm` - Rimozione file.
- `mount` - Montaggio filesystem.
- `umount` - Smontaggio filesystem.
- `fsck` - Controllo integrità filesystem.
- `df` - Visualizzazione spazio utilizzato.
- `du` - Dimensione directory/file.

=== Metodo per risolvere esercizi sugli inode
Per risolvere problemi sugli inode e l'allocazione della memoria nei filesystem, segui questi passi:

1. Calcola il numero di puntatori per blocco
  $
    "Puntatori per blocco" = "Dimensione del blocco" / "Dimensione del puntatore"
  $

2. Determina il range di blocchi indirizzati da ciascun metodo di indirizzamento
  - *Blocchi diretti*: Sono i primi ad essere usati. Il numero è dato dai puntatori diretti nell'inode.
  - *Indiretto semplice*: Indirizza un blocco contenente puntatori a blocchi dati.
  - *Indiretto doppio*: Contiene puntatori a blocchi che a loro volta contengono puntatori a blocchi dati.

3. Trova la posizione del blocco richiesto
  - Se il blocco è nei diretti, usa direttamente l'indice.
  - Se è nell'indiretto semplice, sottrai il numero di blocchi diretti e usa il puntatore nel blocco indiretto.
  - Se è nell'indiretto doppio, calcola la posizione nei due livelli di indirizzamento.

4. Converti un byte in un blocco
  - Dividi la posizione del byte per la dimensione del blocco per ottenere l'indice del blocco.
  - Trova il blocco fisico seguendo la tabella dei puntatori.

=== Esercizi sugli inode
==== Esercizio: Esempio esame completo

*Dati*
- Dimensione dei blocchi: 512 byte
- Dimensione dei puntatori: 24 bit (3 byte)
- Struttura dell'inode:
  - 5 blocchi diretti
  - 1 blocco indiretto semplice
  - 1 blocco indiretto doppio
Il primo blocco ha indice logico 0.

*Richieste*
+ Calcolare il numero di puntatori contenuti in un blocco indiretto.
+ Determinare l'indice logico del primo e dell'ultimo blocco indirizzato dall'indiretto semplice.
+ Determinare l'indice logico del primo e dell'ultimo blocco indirizzato dall'indiretto doppio.
+ Calcolare il numero di blocchi necessari per memorizzare un file di 130500 byte.
+ Determinare in quale blocco fisico si trova un byte specifico, per i seguenti valori:
  - Byte 1980
  - Byte 3023
  - Byte 92151

*Calcoli*
+ Calcolo numero di puntatori in un blocco indiretto
  Dati:
  $512/3 = 170$ blocchi
  - Dimensione blocco: 512 byte
  - Dimensione puntatore: 3 byte
  Un blocco indiretto può quindi contenere 170 puntatori.
  #table(
    columns: (1fr,) * 8,
    [Puntatore], [0 (D)], [1 (D)], [2 (D)], [3 (D)], [4 (D)], [5 (IS)], [6 (ID)], [Valore], [100], [101], [102], [120], [121], [300], [301]
  )

+ Indirizzamento indiretto semplice
  - I blocchi diretti vanno da 0 a 4.
  - Il primo blocco indiretto semplice inizia a indice 5.
  - Può contenere 170 blocchi, quindi:
    - Ultimo blocco:
      $5 + 170 - 1 = 174$

+ Indirizzamento indiretto doppio:
  - Il primo blocco indiretto doppio inizia a indice 175.
  - Ogni puntatore di un blocco indiretto doppio punta a 170 blocchi indiretti semplici, ognuno dei quali punta a 170 blocchi dati:
    $170 times 170 = 28900$
  - Ultimo blocco:
    $175 + 28900 - 1 = 29074$

+ Numero di blocchi per un file di 130500 byte
  - Ogni blocco è 512 byte.
    $ceil(130500/512) = 255$
  Il file occupa 255 blocchi.

+ Posizione di un byte nel file system\
  Per determinare in quale blocco si trova un byte:

  $"posizione del byte" / "dimensione del blocco" = "indice del blocco"$

  - Byte 1980\
    $floor(1980/512) = 3$
    - Indice blocco: 3 (blocco diretto)

  - Byte 3023\
    $floor(3023/512) = 5$
    - Indice blocco: 5 $->$ 304 (indiretto semplice)

    #table(
      columns: (1fr,) * 7,
      [Indice], [0], [1], [2], [3], [4], [5], [Valore], [304], [305], [306], [307], [308], [309]
    )

  - Byte 92151\
    $floor(92151/512) = 179$
    - Indice blocco: 179 (indiretto doppio)
    - Sottraendo i 175 blocchi precedenti, otteniamo indice 4 nel primo blocco indiretto doppio.
    - Dal valore della tabella, il puntatore ci porta a blocchi 301 $->$ 800 $->$ 1024.
    #table(
      columns: (1fr,) * 7,
      [Indice], [0], [1], [2], [3], [4], [5], [Valore], [800], [801], [802], [850], [851], [852]
    )
    #table(
      columns: (1fr,) * 7,
      [Indice], [0], [1], [2], [3], [4], [5], [Valore], [1200], [1201], [1202], [1203], [1204], [1205]
    )
*Conclusione*
#table(
  columns: 4,
  [Byte], [Indice Blocco Logico], [Tipo di Indirizzamento], [Blocco Fisico],
  [1980], [3], [Diretto], [120],
  [3023], [5], [Indiretto Semplice], [304],
  [92151], [179], [Indiretto Doppio], [1024],
)

==== Esercizio: Calcolo dei blocchi indirizzabili
Un i-node contiene:
- 10 puntatori diretti
- 1 puntatore indiretto singolo
- 1 puntatore indiretto doppio
- 1 puntatore indiretto triplo

Se la dimensione del blocco è 1024 byte e ogni puntatore occupa 4 byte:
1. Quanti blocchi dati possono essere indirizzati direttamente?
  - Ogni puntatore diretto indirizza un blocco dati.
  - Totale: 10 blocchi.

2. Quanti blocchi possono essere indirizzati attraverso il puntatore indiretto singolo?
  - Il blocco indiretto contiene solo puntatori.
  - Ogni blocco ha 1024/4 = 256 puntatori.
  - Totale: 256 blocchi.

3. Quanti blocchi possono essere indirizzati attraverso il puntatore indiretto doppio?
  - Ogni puntatore nel blocco di primo livello punta a un blocco con 256 puntatori.
  - Totale: 256 $times$ 256 = 65.536 blocchi.

4. Quanti blocchi possono essere indirizzati attraverso il puntatore indiretto triplo?
  - Ogni puntatore di primo livello punta a un blocco con 256 puntatori di secondo livello.
  - Totale: 256 $times$ 256 $times$ 256 = 16.777.216 blocchi.

5. Qual è la dimensione massima di un file?
  - (10 + 256 + 65.536 + 16.777.216) $times$ 1024 byte = ~17 GB.


==== Esercizio: Allocazione e utilizzo dei blocchi
1. Se un file di 15 KB viene scritto, quanti blocchi vengono utilizzati e quali tipi di indirizzamento vengono impiegati?
  - 15 KB = 15 blocchi (1 KB per blocco).
  - I primi 10 blocchi sono indirizzati direttamente.
  - Gli altri 5 blocchi usano un blocco indiretto singolo.
  - Totale: 16 blocchi (15 dati + 1 indiretto singolo).

2. Se un file di 500 KB viene scritto, quali puntatori vengono utilizzati?
  - 500 KB = 500 blocchi.
  - 10 diretti, 256 indiretti singoli.
  - Rimangono 234 blocchi, quindi viene usato un blocco indiretto doppio.
  - Totale: 10 + 256 + 234 + 1 (doppio indiretto) = 502 blocchi.

3. Determinare quanti blocchi servono per archiviare un file di 5 GB.
  - 5 GB = 5 $times$ 1024 $times$ 1024 KB / 1 KB = 5.242.880 blocchi.
  - Necessari blocchi tripli indiretti.
  - Struttura usata: 10 diretti, 256 singoli, 65.536 doppi, e il resto tripli.

==== Esercizio: Simulazione di lettura e scrittura
Dati i seguenti comandi:
```bash
mkdir /mnt/test
mount /dev/sda1 /mnt/test
cd /mnt/test
touch file1
echo "testo" > file1
sync
ls -i file1
```
1. Quali informazioni vengono salvate nell'i-node del file `file1`?
  - ID dell'i-node.
  - Permessi, proprietario, dimensioni.
  - Timestamp di creazione e modifica.
  - Puntatori ai blocchi.

2. Come verificare quali blocchi sono stati allocati per il file?
  - Usare `ls -l file1` e `stat file1`.
  - Usare `debugfs` e `dumpe2fs`.

3. Dopo la rimozione di `file1`, lo spazio su disco viene immediatamente liberato?
  - No, i blocchi sono marcati come liberi ma non vengono sovrascritti immediatamente.
  - Il recupero può avvenire finché non vengono riutilizzati.

==== Esercizio: Recupero dati e check di consistenza
1. Simulare la cancellazione di un file e provare a recuperarlo leggendo la tabella degli i-node.
  - Cancellare con `rm file1`.
  - Usare `debugfs` per esplorare i blocchi dell'i-node.

2. Usare `fsck` per verificare la consistenza del file system e interpretare il risultato.
  - Eseguire `fsck /dev/sda1`.
  - Controllare errori come blocchi persi o riferimenti inconsistenti.

3. Quali problemi possono emergere se un i-node viene danneggiato?
  - Perdita di metadati del file.
  - Corruzione dei puntatori ai blocchi dati.
  - File che appaiono come "fantasma" nel file system.