#import "@preview/codly:1.0.0": *

#show: codly-init.with()

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

1. Determina il range di blocchi indirizzati da ciascun metodo di indirizzamento
  - *Blocchi diretti*: Sono i primi ad essere usati. Il numero è dato dai puntatori diretti nell'inode.
  - *Indiretto semplice*: Indirizza un blocco contenente puntatori a blocchi dati.
  - *Indiretto doppio*: Contiene puntatori a blocchi che a loro volta contengono puntatori a blocchi dati.

2. Trova la posizione del blocco richiesto
  - Se il blocco è nei diretti, usa direttamente l'indice.
  - Se è nell'indiretto semplice, sottrai il numero di blocchi diretti e usa il puntatore nel blocco indiretto.
  - Se è nell'indiretto doppio, calcola la posizione nei due livelli di indirizzamento.

3. Converti un byte in un blocco
  - Dividi la posizione del byte per la dimensione del blocco per ottenere l'indice del blocco.
  - Trova il blocco fisico seguendo la tabella dei puntatori.

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