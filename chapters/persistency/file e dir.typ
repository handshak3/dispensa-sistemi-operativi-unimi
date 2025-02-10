#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== File e Directory

*Dispositivo di archiviazione permanente*: disco rigido o solido che memorizza informazioni in modo permanente.

*File*: array lineare di byte scrivibili e leggibili. Ogni file ha un nome a basso livello o *inode number* (numeri di qualche tipo).

*File system (FS)*: archivia i dati in modo persistente su disco.

*Directory*: file che contiene un elenco di coppie (nome leggibile, inode number), anche le directory hanno un inode number e quindi ogni entry dell'elenco si riferisce a un file o a una directory.

*Albero delle directory*: creato quando si inseriscono directory in altre directory. La gerarchia inizia dalla root directory (`/`).

Indicare *l'estensione* del file nel nome arbitrario dopo il punto “`.`” è una convenzione.

#figure(
  image("../../images/file/dir tree.png", width: 60%),
  caption: [Albero delle directory.],
)

=== `unlink` e `open()`
`unlink()`: system call per rimuovere i file.

#text(9pt)[
  ```c
  int fd = open("foo", O_CREAT|O_WRONLY|O_TRUNC, S_IRUSR|S_IWUSR);
  ```
]

- `foo`: path/nome del file.
- `O_CREAT`: crea il file se non esiste.
- `O_WRONLY`: apre il file in sola scrittura.
- `O_TRUNC`: rade a zero il contenuto del file.
- `S_IRUSR`: l'utente ha il permesso di leggere il file.
- `S_IWUSR`: l'utente ha il permesso di scrivere sul file.

`open()` restituisce un *file descriptor* (numero intero privato per processo) utilizzato per accedere al file. I descrittori sono gestiti dall'OS in base al processo. Uno *struct proc* mantiene un array che tiene traccia dei file (c'è un limite massimo NOFILE) aperti in base al processo. Ogni entry dell'array è un puntatore a *struct file* che traccia le informazioni sul file letto/scritto.

Definizione semplificata di struct file:
#text(9pt)[
  ```c
  struct file {
  	int ref;
  	char readable;
  	char writable;
  	struct inode *ip;
  	uint off;
  };
  ```
]

Ogni processo mantiene un array di descrittori di file, ognuno dei quali si riferisce a una voce nella *tabella di file aperti* (struct file) a livello di sistema. Ogni voce tiene traccia di quale file corrisponde al descrittore, dell'offset corrente, se il file è leggibile o scrivibile ecc.

=== Lettura e scrittura
`strace`: traccia ogni sys call effettuata da un programma in esecuzione e la stampa a schermo.

Ogni processo in esecuzione ha tre file aperti:
- STDIN (0): letto dal processo per ricevere input.
- STDOUT (1): scritto dal processo per stampare a schermo.
- STDERR (2): scritto dal processo per comunicare errori.

`read()`: legge ripetutamente byte da un file e restituisce il numero di byte letti.

#text(9pt)[
  ```c
  ssize_t read(int fd, void *buf, size_t count);
  ```
]
- `fd`: file descriptor del file che si vuole leggere.
- `*buf`: puntatore a un buffer in cui posizionare il risultato di read.
- `count`: dimensione del buffer.

`read()`: legge ripetutamente byte da un file e restituisce il numero di byte scritti.

#text(9pt)[
  ```c
  ssize_t write(int fd, void *buf, size_t count);
  ```
]
- `fd`: file descriptor del file che si vuole scrivere.
- `*buf`: puntatore a un buffer in cui posizionare il risultato di read.
- `count`: dimensione del buffer.

Funzionamento di `cat`:
1. `cat` chiama `printf()` e non `write()` sul fd di stdout standard. `printf()` gestisce tutti i dettagli di formattazione e scrive sull'stdout.
2. `cat` cerca di leggere altri dati dal file, ma siccome non ci sono più byte nel file, la chiamata `read()` restituisce 0 e il programma sa che ha letto tutto il file.
3. `cat` chiama `close()` per terminare l'utilizzo del file.

Scrittura di un file:
+ Il file viene aperto.
+ Viene chiamata la funzione `write()` (ripetutamente per file più grandi).
+ Viene chiamata la funzione `close()`.

*Accesso sequenziale*: lettura o scrittura dall'inizio alla fine del file.

=== lettura/scrittura non sequenziale

`lseek()`: sposta il puntatore di lettura/scrittura di un file. Restituisce il nuovo offset del puntatore di lettura/scrittura.

#text(9pt)[
  ```c
  off_t lseek(int fd, off_t offset, int whence);
  ```
]
- `fd`: file descriptor del file.
- `offset`: nuovo offset del puntatore di lettura/scrittura.
- `whence`: specifica il punto di riferimento per l'offset.
  - `SEEK_SET`: offset è relativo all'inizio del file.
  - `SEEK_CUR`: offset è relativo alla posizione corrente del puntatore di lettura/scrittura.
  - `SEEK_END`: offset è relativo alla fine del file.

Metodi di aggiornamento per offset corrente:
1. Quando avviene una lettura o scrittura di $N$ byte, $N$ va aggiunto all'offset corrente.
2. Usare `lseek()`.

Il mapping tra fd e entry nella tabella dei file aperti è in genere un'associazione uno a uno. Quindi due processi che scrivono sullo stesso file avranno entry diverse. Ogni processo ha il proprio accesso al file e non può modificare il contenuto che è stato modificato da un altro processo.

Quando un processo padre crea un processo figlio con `fork()`, un'entry nella tabella dei file aperti è condivisa. Il processo figlio può accedere ai file aperti dal processo padre e modificarne il contenuto.

`dup()`: crea un nuovo descrittore che fa riferimento a un file già aperto.
`dup2()`: sostituisce il descrittore con uno nuovo.

#figure(
  image("../../images/file/pt.png", width: 80%),
  caption: [Processi che condividono una voce della tabella dei file aperti.],
)

Quando l'OS chiama `write()`, il FS bufferizza i dati per poi scriverli effettivamente su disco in un secondo momento. Il problema e che questi dati, in caso di arresto anomalo, potrebbero andare persi. Per forzare la scrittura si utilizza `fsync(int fd)` che scrive immediatamente sul disco.

=== `remane()`
Per eseguire il comando (Rinominare un file da 'foo' a 'bar'):

#text(9pt)[
  ```bash
  mv foo bar
  ```
]

mv utilizza la syscall `rename(char *old, char *new)`:
- `char *old`: nome originale.
- `char *new`: nuovo nome.

Spesso, `rename()` è implementata in modo atomico.

#text(9pt)[
  ```c
  int fd = open("foo.txt.tmp", O_WRONLY|O_CREAT|O_TRUNC,S_IRUSR|S_IWUSR);
  write(fd, buffer, size); // write out new version of file
  fsync(fd);
  close(fd);
  rename("foo.txt.tmp", "foo.txt");
  ```
]

Modifica atomica di un file foo.txt:
1. Viene creato un file temporaneo
2. Viene aggiunta una riga al file temporaneo.
3. Viene forzata la scrittura sul file temporaneo.
4. Chiusura file temporaneo.
5. Sostituzione del file temporaneo con quello effettivo (ridenominandolo).

Il FS mantiene informazioni sui file utilizzando i metadati (visibili tramite `stat()` e `fstat()`). Le chiamate riempiono una struttura stat del tipo:

#text(9pt)[
  ```c
  struct stat {
  	dev_t st_dev; // ID of device containing file
  	ino_t st_ino; // inode number
  	mode_t st_mode; // protection
  	nlink_t st_nlink; // number of hard links
  	uid_t st_uid; // user ID of owner
  	gid_t st_gid; // group ID of owner
  	dev_t st_rdev; // device ID (if special file)
  	off_t st_size; // total size, in bytes
  	blksize_t st_blksize; // block size for filesystem I/O
  	blkcnt_t st_blocks; // number of blocks allocated
  	time_t st_atime; // time of last access
  	time_t st_mtime; // time of last modification
  	time_t st_ctime; // time of last status change
  };
  ```
]

Ogni FS conserva queste informazioni in un inode.

Per rimuovere un file, l'OS chiama `unlink()`.

Il formato di una directory è considerato metadati del FS, quindi, non è possibile aggiornare una directory direttamente.

=== Creazione di directory
`mkdir()`: syscall che crea una cartella.

Una nuova directory è considerata vuota ma ha due voci:
- Entry che fa riferimento a se stessa `.`.
- Entry che fa riferimento al parent `..`.

Per aprire una directory non bisogna trattarla come un file, esistono le chiamate:
- `opendir()`: apre una directory specificata dal percorso e restituisce un puntatore a una struttura di tipo `DIR`.
- `readdir()`: utilizzata per leggere la prossima voce della directory aperta con `opendir()`. Restituisce un puntatore alla struttura `struct dirent` che contiene le informazioni sull'elemento della directory.
- `closedir()`: chiude la directory precedentemente aperta con `opendir()`. Rilascia le risorse associate alla gestione della directory.

#text(9pt)[
  ```c
  int main(int argc, char *argv[]) {
  	DIR *dp = opendir(".");
  	assert(dp != NULL);
  	struct dirent *d;
  	while ((d = readdir(dp)) != NULL) {
  	printf("%lu %s\n", (unsigned long) d->d_ino,
  	d->d_name);
  	}
  	closedir(dp);
  	return 0;
  }
  ```
]
Il ciclo legge una voce della dir alla volta e ne stampa il nome e il numero di inode di ogni file nella dir.

#text(9pt)[
  ```c
  struct dirent {
  	char d_name[256]; // filename
  	ino_t d_ino; // inode number
  	off_t d_off; // offset to the next dirent
  	unsigned short d_reclen; // length of this record
  	unsigned char d_type; // type of file
  };
  ```
]
Informazioni disponibili all'interno di ogni entry.

- `rmdir()`: utilizzata per rimuovere una dir vuota.
- `link()`: crea un'entry nell'albero del FS.

#text(9pt)[
  ```c
  int link(const char *oldpath, const char *newpath);
  ```
]

- oldpath: il percorso del file esistente al quale si desidera creare un collegamento.
- newpath: il percorso del nuovo nome (link) che si desidera associare al file esistente.

=== Hard Link
Quando un nome di un file viene linkato a un altro, si crea un modo per fare riferimento allo stesso file. Quindi `link()` crea un altro nome per fare riferimento allo stesso numero inode del file originale.

`unlink()` rimuove il collegamento tra nome leggibile e inode e decrementa il reference count. Se il reference count è 0, il file viene effettivamente cancellato.

*Hard Link*: collegamento fisico tra due nomi di file differenti che puntano allo stesso inode. Gli hard link condividono lo stesso spazio di archiviazione e le stesse informazioni di inode.

Limiti degli hard link:
- Non è possibile creare un hard link a una directory per evitare la creazione di cicli nella struttura delle directory.
- Non è possibile creare hard link a file su altre partizioni del disco perché i numeri di inode sono univoci solo all'interno di uno specifico FS.

=== Symbolic Link

*Soft Link (Link Simbolico)*: è un file separato che contiene un percorso che punta al file di destinazione. Il soft link è un riferimento indiretto al file di destinazione. Contiene il percorso del file di destinazione. Se il file di destinazione viene rimosso, si crea una "dangling reference", e il link simbolico punterà a un percorso inesistente.

Siccome i file sono condivisi tra i processi e gli utenti, all'interno del FS è presente un modo per abilitare vari tipi di permessi.

*Permission bits*: determinano chi può accedere a un file e come. Sono rappresentati da nove caratteri, suddivisi in tre gruppi:

- Owner.
- Gruppo di utenti.
- Altri utenti.

Le autorizzazioni includono la lettura, la scrittura e l'esecuzione. L'owner può modificare i permessi con `chmod`.

*Execute Bit*: esecuzione determina se un file può essere eseguito. Nelle directory, abilita la navigazione e la creazione di file.

*Access Control Lists (ACL)*: alcuni file system, come AFS, le utilizzano per controlli più sofisticati. Consentono di specificare dettagliatamente chi può accedere a una risorsa, superando le limitazioni dei permission bits.

=== Montaggio di un FS
Per creare un FS si utilizza `mkfs` (make fs). Si fornisce a `mkfs` un dispositivo (es. /dev/sda1) e un tipo di FS (es. ext3). Poi `mkfs` scrive un FS vuoto sulla partizione del disco specificata, iniziando con una directory radice.

Per rendere accessibile il FS si utilizza `mount`, che effettua la chiamata di sistema `mount()` che monta effettivamente il FS. `mount` prende un percorso di directory esistente come punto di montaggio e incolla il nuovo FS nell'albero delle directory in quel punto.

#text(9pt)[
  ```bash
  mount -t ext3 /dev/sda1 /home/users
  ```
]
=== TOCTTOU
*Problema del Time Of Check To Time Of Use (TOCTTOU)* : si verifica quando c'è un intervallo tra la verifica di validità di una condizione e l'operazione associata a tale verifica, aprendo la possibilità di manipolazioni da parte di un attaccante.