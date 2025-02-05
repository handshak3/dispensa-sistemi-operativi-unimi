== Memorie di massa

Ci sono due tipi principali di memoria secondaria:
- *Direct Access Storage Devices (DASDs)*
  - Dischi magnetici:
    - Hard Disks
    - Floppy Disks
  - Dischi ottici: CD-ROM
- Serial Devices: nastri magnetici.

Unità di misura spaziali:
- *byte*: 8 bits
- *kilobyte (KB)*: 1024 or $2^10$ bytes
- *megabyte (MB)*: 1024 kilobytes or $2^20$ bytes
- *gigabyte (GB)*: 1024 megabytes or $2^30$ bytes

Unità di misura temporali:
- *nanosecond (ns)*: one- billionth (10-9) of a second.
- *microsecond (s)*: one- millionth (10-6) of a second.
- *millisecond (ms)*: one- thousandth (10-3) of a second.

=== Dischi magnetici

I dati, rappresentati da bit (0 o 1), vengono scritti su piatti circolari ricoperti di materiale ferromagnetico, chiamati *dischi*. Questi ruotano continuamente ad alta velocità. Le *testine* di lettura/scrittura registrano o leggono i dati quando i *piatti* passano sotto di esse. Nei disk drive dei PC sono presenti più piatti per aumentare la capacità di archiviazione. Il disco contiene *tracce* concentriche che sono divise in *settori*. Il *blocco* è l'unità indirizzabile più piccola di un disco. Un *cilindro* è un set di tracce posizionate ad un determinato raggio del disco (inteso come insieme di piatti).

Il disco ha un controllare che ha una cache che viene utilizzata da buffer per le richieste di lettura/scrittura.

Quando un programma legge un byte dal disco l'OS localizza la sua posizione sulla superficie (traccia/settore) e legge l'intero blocco in una speciale area di memoria che funziona da buffer. Il collo di bottiglia nell'accesso al disco è il movimento dei bracci delle testine. Ha quindi senso immagazzinare il file in tracce che occupano la medesima posizione su diversi piatti e superfici piuttosto che su diverse tracce della superficie di un singolo piatto.

=== Calcolo dei blocchi

- $"blocchiPerSuperficie" = "cilindriPerDisco" times "settoriPerDisco"$

- $"blocchiPerDisco" = "blocchiPerSuperficie" times "TestinePerDisco"$

- $"blocchiPerDisco" = "cilindriPerDisco" times "settoriPerDisco" times "TestinePerDisco"$

- $"blocchi" = "cilindri" times "testine" times "settori"$

- $"Offset" = C times (H times S) + H times S + S$

==== Notazione
(C,H,S)

Esempio: (0, 0, 2)
- C = 0 $->$ Cilindro (traccia) 0
- H = 0 $->$ Testina (piatto) 0
- S = 2 $->$ Settore 2

==== Esercizio calcolo dei blocchi
Dati:
- 3 cilindri (C)
- 2 Testine (T)
- 8 Settori (S)

Calcoli:\
$"blocchi" = 3 times 2 times 8 = 48 "blocchi"$

==== Esercizio calcolo dell'Offset

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

==== Esercizio capacità disco
Salvare un file di 20000 record su un disco con le seguenti caratteristiche:
- 512 bytes per sector
- 40 sector per track
- 11 tracks per cylinder
- 1331 cylinder

+ Quanti cilindri sono richiesti se ogni record occupa 256 bytes?
+ Qual è la capacità totale del disco?

Calcolo dei settori necessari:
Ogni settore può contenere:
$512 / 256 = 2 "record per settore"$
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

  $299.499.520 / (1024 times 1024 times 1024)} = tilde 0.28 "GB"$
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
Il tempo di ricerca dipende unicamente dalla velocità con cui si muovono i bracci delle testine e dal numero di tracce che devono essere attraversate per raggiungere l'obiettivo. Data la conoscenza delle seguenti informazioni (che sono costanti per
ogni specifico modello di disco):
- Hs = tempo richiesto perché la testina inizi a muoversi.
- Ht = tempo richiesto perché la testina si muova da una traccia alla successiva.

Il tempo necessario perché la testina si muova di n tracce è:
$ "Seek"(n)= H"s"+ "Ht" times n $

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

St = numero totale settori per traccia.

È possibile calcolare il tempo di trasferimento per n settori contigui sulla stessa traccia come segue:

$"Tempo trasferimento" = (n / "St")times(1000/R)$

==== Esercizio latenza, capacità e tempo di lettura

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

== Esercizi con le memorie di massa
- Dimensione blocchi: 512 byte
- Dimensione puntatori: 24 bit (equivalenti a 3 byte)
- Inode:
  - 5 blocchi diretti
  - 1 blocco indiretto semplice
  - 1 blocco indiretto doppio
- Primo blocco: Ha indice logico 0 1.

*Numero di puntatori in un blocco indiretto*\
Ogni puntatore occupa 3 byte. Un blocco è di 512 byte. Quindi, il numero di puntatori in un blocco indiretto è: $512 / 3 = 170$

*Indirizzo logico del primo e dell'ultimo blocco con indirizzamento indiretto semplice*\
- Blocchi diretti: I primi 5 blocchi (indici: 0, 1, 2, 3, 4).
- Primo blocco indiretto semplice: Inizia dal blocco successivo, quindi indice 5.
- Ultimo blocco indiretto semplice: Può indirizzare 170 blocchi.
  - Ultimo blocco = 5 + 170 - 1 = 174
*Indirizzo logico del primo e dell'ultimo blocco con indirizzamento indiretto doppio*\
- Primo blocco indiretto doppio: Inizia dopo l'ultimo blocco dell'indiretto semplice.
  Primo blocco = 174 + 1 = 175
- Ultimo blocco indiretto doppio: Ogni blocco di indirizzamento doppio contiene 170 puntatori e ciascun puntatore indirizza un blocco con 170 indirizzi.
  Numero massimo di blocchi = 170 x 170 = 28900
  Ultimo blocco = 175 + 28900 - 1 = 29074
*Numero di blocchi che compongono un file di 130500 byte*\
Ogni blocco è di 512 byte.
Numero di blocchi $130500 / 512 = 255$
=== In quale blocco fisico si trova un dato byte?
Tabella guida dei puntatori:

#table(
  columns: (1fr,) * 8,
  [Puntatore], [0 (D)], [1 (D)], [2 (D)], [3 (D)], [4 (D)], [5 (IS)], [6 (ID)], [Valore], [100], [101], [102], [120], [121], [300], [301]
)
Tabella guida dei contenuti dei puntatori parziali:\
Blocco 300:
#table(
  columns: (1fr,) * 7,
  [Indice], [0], [1], [2], [3], [4], [5], [Valore], [301], [305], [306], [307], [308], [309]
)

Blocco 301:
#table(
  columns: (1fr,) * 7,
  [Indice], [0], [1], [2], [3], [4], [5], [Valore], [800], [801], [802], [850], [851], [852]
)

Blocco 800:
#table(
  columns: (1fr,) * 7,
  [Indice], [0], [1], [2], [3], [4], [5], [Valore], [1200], [1201], [1202], [1203], [1204], [1205]
)

Byte 1980:\
$1980 / 512 = 3.87$\
Il byte si trova nel quarto blocco fisico (indice 3).

Byte 3023:\
$3023 / 512 = 5.9$\ Il byte si trova nel sesto blocco fisico, che è indirizzato dall'indirizzo indiretto semplice. Essendo 0 - 4 diretti, e 5 il nostro puntatore “Jumper” che sappiamo ci lancia al blocco, la sesta casella sarà l'indice 304.

Byte 92151:\
$92151 / 512 = 179.98$\
Il byte si trova nell'indirizzamento indiretto doppio. Andiamo sulla prima “Jumper”, che ci porta al blocco 301, ma è un ID (doppio), quindi saltiamo un altra volta il prima possibile finendo nella 800. Partendo dal primo blocco dell'indiretto doppio (indice 175, cosa che sappiamo da calcoli dell'es 2), avendo che 179 - 175 = 4, otteniamo 1024.

#line()