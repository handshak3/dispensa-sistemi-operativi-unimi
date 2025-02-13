#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Semaphores
*Semaforo*: meccanismo per gestire la concorrenza che può essere usato come una condition variable o come lock. È un oggetto con un valore intero che può essere manipolato con due routine: `sem_wait()` e `sem_post()`. Siccome valore iniziale del semaforo determina il suo comportamento, per usare un semaforo, occorre prima inizializzarlo a un valore.

#text(size: 9pt)[
  ```c
  #include <semaphore.h>
  sem_t s;
  sem_init(&s, 0, 1); // Semafori inizializzato a 1.
  ```
]

- *`sem_init()`*: inizializza un semaforo.
  #text(size: 9pt)[
    ```c
    int sem_init(sem_t *sem, int pshared, unsigned int value);
    ```
  ]
  - `sem`: Puntatore alla variabile del semaforo.
  - `pshared`: Se `0`, il semaforo è usato solo tra thread dello stesso processo. Se diverso da `0`, può essere condiviso tra processi diversi (ma deve risiedere in memoria condivisa).
  - `value`: Valore iniziale del semaforo.

  Ritorna `0` se ha successo, altrimenti `-1` con `errno` settato.

- *`sem_wait()`*: decrementa il semaforo.
  #text(size: 9pt)[
    ```c
    int sem_wait(sem_t *sem);
    ```
  ]
  - Se il valore del semaforo è maggiore di `0`, lo decrementa e continua.
  - Se è `0`, il thread si blocca finché il semaforo non diventa positivo.

  Ritorna `0` se ha successo, `-1` in caso di errore.

- *`sem_post()`*: incrementa il semaforo.
  #text(size: 9pt)[
    ```c
    int sem_post(sem_t *sem);
    ```
  ]
  - Aumenta il valore del semaforo di `1`.
  - Se altri thread sono in attesa (`sem_wait()`), ne sblocca uno.

  Ritorna `0` se ha successo, `-1` in caso di errore.

=== Semafori binari
È un semaforo che può assumere solo due valori:
- 0 (occupato)
- 1 (libero)

Possono essere utilizzati come lock, è necessario circondare la sezione critica di interesse con una coppia `sem_wait()`/`sem_post()`.

Utilizzo:
- Il thread 0 chiama `sem_wait()` per decrementare il valore del semaforo a 0 (thread 0 ha acquisito il lock).
- Il thread 0 quindi esegue l'operazione critica.
- Quando thread 0 ha terminato l'operazione, chiama `sem_post()` per incrementare il valore del semaforo a 1 (lock rilasciato).

#figure(
  image("../../images/semaphores/single.png"),
  caption: [Singolo thread che utilizza il semaforo.],
)

Un caso più interessante si verifica quando il Thread 0 ha il lock (ovvero ha chiamato `sem_wait()` ma non ha ancora chiamato `sem_post()`) e un altro thread (Thread 1) tenta di accedere alla sezione critica chiamando `sem_wait()`.

- Thread 1 decrementerà il valore del semaforo a -1 e quindi attenderà (metterà se stesso a dormire e rilascerà il processore).
- Quando Thread 0 viene eseguito di nuovo, alla fine chiamerà `sem_post()`, incrementando il valore del semaforo a zero e quindi risvegliando il thread in attesa (Thread 1), che potrà quindi acquisire il blocco per sé.
- Quando Thread 1 termina, incrementerà nuovamente il valore del semaforo, ripristinandolo a 1.

#figure(
  image("../../images/semaphores/double.png"),
  caption: [Due thread che usano lo stesso semaforo.],
)

=== Semafori per ordinamento
I semafori possono essere utilizzati per ordinare gli eventi in un programma concorrente.

Un thread può desiderare di attendere che una lista diventi non vuota, in modo da poter eliminare un elemento.

In questo modello di utilizzo, si trova spesso un thread che attende che qualcosa accada, e un altro thread che fa accadere quella cosa e poi segnala che è successo, risvegliando così al thread in attesa.

Stiamo utilizzando il semaforo come una primitiva d'ordinamento.

Immagina che un thread crei un altro thread e poi voglia aspettare che completi la sua esecuzione. Vogliamo ottenere:
+ parent: begin
+ child
+ parent: end

==== Primo caso
Come dovrebbe essere con i semafori:
+ Il thread genitore esegue, decrementa il semaforo (a -1), quindi attende (dormendo).
- Quando il thread figlio finalmente esegue, chiamerà `sem_post()`, incrementerà il valore del semaforo da 0 a 1.
- Quando il genitore ottiene quindi la possibilità di eseguire, chiamerà `sem_wait()` e troverà il valore del semaforo a 1; il genitore decrementerà quindi il valore (a 0) e tornerà da `sem_wait()` senza aspettare, ottenendo anche l'effetto desiderato.

#figure(
  image("../../images/semaphores/tracev1.png"),
  caption: [Trace dei thread nel primo caso.],
)

==== Secondo caso
Si verifica quando il figlio esegue fino al completamento prima che il genitore possa chiamare `sem_wait()`. In questo caso, il figlio chiamerà prima `sem_post()`, aumentando così il valore del semaforo da 0 a 1. Quando il genitore ottiene quindi la possibilità di eseguire, chiamerà `sem_wait()` e troverà il valore del semaforo a 1; il genitore decrementerà quindi il valore (a 0) e tornerà da `sem_wait()` senza aspettare, ottenendo anche l'effetto desiderato.

#figure(
  image("../../images/semaphores/tracev2.png"),
  caption: [Trace dei thread nel secondo caso.],
)


=== Problema del buffer limitato

Il problema del produttore e consumatore è problema di sincronizzazione negli OS e nella programmazione concorrente. Si verifica quando uno o più produttori generano dati e li inseriscono in un buffer condiviso, mentre uno o più consumatori prelevano questi dati dal buffer per elaborarli.

==== Primo tentativo
Utilizziamo due semafori, `empty` e `full`, che i thread useranno per indicare quando una voce del buffer è stata svuotata o riempita, rispettivamente.

#figure(caption: [Codice di `put()` e `get()`])[
  #text(size: 9pt)[
    ```c
    int buffer[MAX];
    int fill = 0;
    int use = 0;

    void put(int value) {
      buffer[fill] = value; // Line F1
      fill = (fill + 1) % MAX; // Line F2
    }

    int get() {
        int tmp = buffer[use]; // Line G1
        use = (use + 1) % MAX; // Line G2
        return tmp;
    }
    ```
  ]
]

#figure(caption: [Codice del produttore e del consumatore.])[
  #text(size: 9pt)[
    ```c
    sem_t empty;
    sem_t full;

    void producer(void arg) {
      int i;
      for (i = 0; i < loops; i++) {
          sem_wait(&empty); // Line P1
          put(i); // Line P2
          sem_post(&full); // Line P3
        }
    }

    void consumer(void arg) {
        int tmp = 0;
        while (tmp != -1) {
          sem_wait(&full); // Line C1
          tmp = get(); // Line C2
          sem_post(&empty); // Line C3
          printf("%d\n", tmp);
        }
    }

    int main(int argc, char argv[]) {
        // ...
        sem_init(&empty, 0, MAX); // MAX are empty
        sem_init(&full, 0, 0); // 0 are full
        // ...
    }
    ```
  ]
]

Il produttore attende che un buffer diventi vuoto per potervi inserire dati, e il
consumatore attende in modo simile che un buffer diventi pieno prima di utilizzarlo.

Supponiamo `MAX = 1` (cioè ci sia solo un buffer nell'array) e vediamo se funziona.

Supponiamo di nuovo che ci siano due thread, un produttore e un consumatore.

Si assume che il consumatore venga eseguito per primo:
+ Esegue C1, chiamando `sem_wait(&full)`. `full` è stato inizializzato al valore 0, la chiamata decrementerà `full` (a -1).
+ Va in sleep e attenderà che un altro thread chiami `sem_post()` su `full`.

Il produttore va in esecuzione:
+ Fa P1 chiamando `sem_wait(&empty)`. A differenza del consumatore, il produttore continuerà attraverso questa linea, perché `empty` è stato inizializzato al valore `MAX` (in questo caso, 1).
+ `empty` verrà decrementato a 0 e il produttore inserirà un valore di dati nella prima voce di buffer (riga P2).
+ Fa P3 e chiamerà `sem_post(&full)`, cambiando il valore del semaforo full da -1 a 0 e risvegliando il consumatore.

Ora possono accadere due cose:
- Se il produttore continua a funzionare, spinnerà di nuovo e colpirà la linea P1 di nuovo. Questa volta si bloccherà, poiché il valore del semaforo `empty` è 0.
- Se invece il produttore veniva interrotto e il consumatore iniziava a funzionare, sarebbe tornato da `sem_wait(&full)` (riga C1), avrebbe trovato che il buffer era pieno e lo avrebbe consumato. In entrambi i casi, otteniamo il comportamento
desiderato.

Lo stesso esempio con più thread:
- Supponiamo ora `MAX` > 1 (diciamo MAX = 10).
- Supponiamo che ci siano più produttori e più consumatori, quindi, abbiamo una race condition.

*Problema*: due produttori ($P_a$ e $P_b$) chiamano `put()` nello stesso momento. Si assume che il produttore $P_a$ venga eseguito per primo e stia riempiendo la prima voce del buffer (`fill = 0` alla riga F1). Prima che $P_a$ possa avere la possibilità di incrementare il contatore di riempimento a 1, viene interrotto.
$P_b$ inizia a funzionare e alla riga F1 inserisce anche i suoi dati nell'elemento 0 di buffer, il che significa che i dati vecchi vengono sovrascritti!

==== Aggiungere la mutua esclusione

Per evitare race condition è necessario utilizzare la mutua esclusione.

*Problema*: è possibile che due processi accedano contemporaneamente al buffer e all'indice del buffer portando a un deadlock.

*Deadlock (stallo)*: una situazione in cui due o più processi sono bloccati e non possono continuare a eseguire.

Esempio di deadlock:
+ Il consumatore viene eseguito prima e acquisisce mutex (c0).
+ Chiama quindi la `sem_wait(&full)` (c1). Tuttavia il consumatore possiede ancora il lock.
+ Viene eseguito un produttore che, se fosse possibile, riempirebbe il buffer di dati e sveglierebbe il consumatore. Sfortunatamente, la prima cosa che fa è chiamare la sem_wait(&mutex) (p0). Il lock, tuttavia, è già in possesso del consumatore e il produttore è bloccato ad aspettare.

Quindi:
- Il consumatore è bloccato su `sem_wait(&full)`, aspettando un elemento che il produttore deve inserire.
- Il produttore è bloccato su `sem_wait(&mutex)`, aspettando che il consumatore rilasci il lock.

#figure(caption: [Nuovo codice del produttore e del consumatore.])[
  #text(size: 9pt)[
    ```c
    void  producer(void  arg) {
      int i;
      for (i = 0; i < loops; i++) {
        sem_wait( & mutex); // Line P0 (NEW LINE)
        sem_wait( & empty); // Line P1
        put(i); // Line P2
        sem_post( & full); // Line P3
        sem_post( & mutex); // Line P4 (NEW LINE)
      }
    }

    void  consumer(void  arg) {
      int i;
      for (i = 0; i < loops; i++) {
        sem_wait( & mutex); // Line C0 (NEW LINE)
        sem_wait( & full); // Line C1
        int tmp = get(); // Line C2
        sem_post( & empty); // Line C3
        sem_post( & mutex); // Line C4 (NEW LINE)
        printf("%d\n", tmp);
      }
    }
    ```
  ]
]

==== Soluzione definitiva

Occorre ridurre la portata del lock spostando l'acquisizione e il rilascio appena intorno alla sezione critica.

#figure(caption: [Nuovo codice del produttore e del consumatore (soluzione al problema).])[
  #text(size: 9pt)[
    ```c
    void  producer(void  arg) {
      int i;
      for (i = 0; i < loops; i++) {
        sem_wait( & empty); // Line P1
        sem_wait( & mutex); // Line P1.5 (MUTEX HERE)
        put(i); // Line P2
        sem_post( & mutex); // Line P2.5 (AND HERE)
        sem_post( & full); // Line P3
      }
    }

    void  consumer(void  arg) {
      int i;
      for (i = 0; i < loops; i++) {
        sem_wait( & full); // Line C1
        sem_wait( & mutex); // Line C1.5 (MUTEX HERE)
        int tmp = get(); // Line C2
        sem_post( & mutex); // Line C2.5 (AND HERE)
        sem_post( & empty); // Line C3
        printf("%d\n", tmp);
      }
    }
    ```
  ]
]
=== Reader-Writer Locks

*Altro problema*: non esiste una primitiva di locking abbastanza flessibile per soddisfare tutti i requisiti delle operazioni su strutture dati concorrenti. Le operazioni di lettura sono molto più veloci delle operazioni di scrittura e non richiedono di modificare lo stato della struttura dati. Le operazioni di scrittura sono più lente e richiedono di modificare lo stato della struttura dati.

*Soluzione*: il *lock reader-writer* che consente a più lettori di accedere contemporaneamente a una risorsa, ma solo a un singolo scrittore. Questo è utile per strutture dati in cui le letture sono più comuni delle scritture, come le liste.

*Implementazione*: se un thread vuole aggiornare la struttura dati in questione, deve chiamare la nuova coppia di operazioni di sincronizzazione:

- `rwlock_acquire_writelock()`: per acquisire un lock di scrittura.
- `rwlock_release_writelock()`: per rilasciare il lock di scrittura.

Internamente utilizzano il semaforo `writelock` per garantire che solo un singolo scrittore possa acquisire il lock.

#figure(caption: [Implementazione di un semplice lock reader-writer.])[
  #text(size: 9pt)[
    ```c
    typedef struct _rwlock_t {
      sem_t lock; // binary semaphore (basic lock)
      sem_t writelock; // allow ONE writer/MANY readers
      int readers; // #readers in critical section
    }
    rwlock_t;
    void rwlock_init(rwlock_t * rw) {
      rw -> readers = 0;
      sem_init( & rw -> lock, 0, 1);
      sem_init( & rw -> writelock, 0, 1);
    }

    void rwlock_acquire_readlock(rwlock_t * rw) {
      sem_wait( & rw -> lock);
      rw -> readers++;
      if (rw -> readers == 1) // first reader gets writelock
        sem_wait( & rw -> writelock);
      sem_post( & rw -> lock);
    }

    void rwlock_release_readlock(rwlock_t * rw) {
      sem_wait( & rw -> lock);
      rw -> readers--;
      if (rw -> readers == 0) // last reader lets it go
        sem_post( & rw -> writelock);
      sem_post( & rw -> lock);
    }

    void rwlock_acquire_writelock(rwlock_t * rw) {
      sem_wait( & rw -> writelock);
    }

    void rwlock_release_writelock(rwlock_t * rw) {
      sem_post( & rw -> writelock);
    }
    ```
  ]
]

Quando acquisisce un lock di lettura, il lettore acquisisce prima il lock e poi incrementa la variabile readers per tenere traccia di quanti lettori sono attualmente all'interno della struttura dati. Il passo importante quindi intrapreso all'interno di `rwlock_acquire_readlock()` si verifica quando il primo lettore acquisisce il lock; in tal caso, il lettore acquisisce anche il lock di scrittura chiamando `sem_wait()` sul semaforo `writelock` e quindi rilasciando il lock chiamando `sem_post()`.

Quando il lettore ha acquisito un lock di lettura, altri lettori saranno autorizzati ad acquisire il lock di lettura; tuttavia, qualsiasi thread che desidera acquisire il lock di scrittura dovrà aspettare che tutti i lettori siano terminati; l'ultimo a uscire dalla sezione critica chiama `sem_post()` su `writelock` e quindi abilita un writer in attesa ad acquisire il lock.

Approccio funzionante ma presenta alcuni lettori potrebbero soffrire di starvation.

=== Problema dei 5 filosofi

Si supponga che ci siano cinque "filosofi" seduti intorno a un tavolo. Tra ogni coppia di filosofi c'è una sola forchetta (e quindi, cinque in totale). I filosofi hanno periodi in cui pensano, e non hanno bisogno di forchette e periodi in cui mangiano. Per mangiare, un filosofo ha bisogno di due forchette, sia quella alla sua sinistra che quella alla sua destra.

#figure(
  image("../../images/semaphores/filosofi.png", width: 60%),
  caption: [Problema dei 5 filosofi.],
)

La sfida è scrivere le routine `get_forks()` e `put_forks()` in modo che non ci sia deadlock, nessun filosofo muoia di fame e non riesca mai a mangiare, e la concorrenza sia alta (cioè, il maggior numero possibile di filosofi può mangiare allo stesso tempo).

#text(9pt)[
  ```c
  while (1) {
    think();
    get_forks(p);
    eat();
    put_forks(p);
  }
  ```
]

Usiamo due funzioni ausiliarie:
- `int left(int p) { return p; }`
- `int right(int p) { return (p + 1) % 5; }`

Quando il filosofo $p$ desidera fare riferimento alla forchetta alla sua sinistra, chiama semplicemente `left(p)`.

La forchetta alla destra di un filosofo $p$ è indicata chiamando `right(p)`; l'operatore modulo in questo caso gestisce il caso in cui l'ultimo filosofo (`p=4`) tenta di afferrare la forchetta alla sua destra, che è la forchetta 0. Sono inoltre necessari alcuni semafori per risolvere questo problema. Supponiamo di avere cinque, uno per ogni forchetta: `sem_t forks[5]`.

==== Soluzione broken
Inizializziamo ogni semaforo a 1 in `sem_t forks[5]`. Supponiamo che ogni filosofo conosca il proprio numero $p$.

#figure(caption: [Funzioni `get_forks()` e `put_forks()`.])[
  #text(size: 9pt)[
    ```c
    void get_forks(int p) {
        sem_wait(&forks[left(p)]);
        sem_wait(&forks[right(p)]);
    }

    void put_forks(int p) {
        sem_post(&forks[left(p)]);
        sem_post(&forks[right(p)]);
    }
    ```
  ]
]

Per ottenere le forchette acquisiamo il lock prima sulla forchetta di sinistra e poi su quella di destra. Finito di mangiare rilasceremo il lock.

*Problema*: deadlock! Se ogni filosofo afferra la forchetta alla sua sinistra prima che qualsiasi filosofo possa afferrare la forchetta alla sua destra, ognuno rimarrà bloccato con una forchetta e aspettandone un'altra, per sempre.

==== A Solution: Breaking The Dependency

Una possibile soluzione è cambiare il modo in cui le forchette vengono acquisite dai filosofi.

Il filosofo 4 può prendere forchette in un ordine diverso dagli altri. In questo modo, non si verifica una situazione in cui ogni filosofo afferra una forchetta e rimane bloccato in attesa di un altro.

#figure(caption: [Interruzione della dipendenza in `get_forks()`.])[
  #text(size: 9pt)[
    ```c
    void get_forks(int p) {
        if (p == 4) {
          sem_wait(&forks[right(p)]);
          sem_wait(&forks[left(p)]);
        } else {
          sem_wait(&forks[left(p)]);
          sem_wait(&forks[right(p)]);
        }
    }
    ```
  ]
]

=== Accodamento dei thread

*Throttling dei thread*: metodo per limitare il numero di thread che eseguono contemporaneamente un pezzo di codice.

Un modo semplice per implementare il throttling dei thread è usare un semaforo. Quando un thread desidera accedere alla regione critica, deve acquisire il semaforo. Se il semaforo è già acquisito da un altro thread, il thread deve attendere fino a quando il semaforo viene rilasciato.

Come il throttling dei thread può essere utilizzato:

Immaginiamo di creare centinaia di thread per lavorare in parallelo. In una parte del
codice, ogni thread acquisisce una grande quantità di memoria per eseguire una parte del calcolo.

Se tutti i thread entrano nella regione ad alta intensità di memoria allo stesso tempo, la somma di tutte le richieste di allocazione di memoria supererà la quantità di memoria fisica sulla macchina. La macchina inizierà a swappare e il calcolo rallenterà.

Un semaforo può risolvere questo problema. Inizializzando il valore del semaforo al numero massimo di thread che si desidera far entrare nella regione ad alta intensità di memoria contemporaneamente, solo un numero limitato di thread potrà accedere alla regione alla volta.

=== Come implementare i semafori
#figure(caption: [Implementazione dei semafori con i lock e le CV.])[
  #text(size: 9pt)[
    ```c
    typedef struct __Zem_t {
      int value;
      pthread_cond_t cond;
      pthread_mutex_t lock;
    }
    Zem_t;
    // only one thread can call this
    void Zem_init(Zem_t * s, int value) {
      s -> value = value;
      Cond_init( & s -> cond);
      Mutex_init( & s -> lock);
    }

    void Zem_wait(Zem_t * s) {
      Mutex_lock( & s -> lock);
      while (s -> value <= 0)
        Cond_wait( & s -> cond, & s -> lock);
      s -> value--;
      Mutex_unlock( & s -> lock);
    }

    void Zem_post(Zem_t * s) {
      Mutex_lock( & s -> lock);
      s -> value++;
      Cond_signal( & s -> cond);
      Mutex_unlock( & s -> lock);
    }
    ```
  ]
]