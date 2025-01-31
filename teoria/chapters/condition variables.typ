#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Condition variables

Usare una variabile condivisa per un thread che controlla una condizione prima di continuare la sua esecuzione (es. wait(): padre che attende il figlio) è inefficiente perché la CPU per controllare la variabile condivisa perderebbe tempo. vorremmo è mettere il genitore in sleep fino a quando la condizione
che stiamo aspettando (cioè che il figlio termini la sua esecuzione) diventi vera.

=== Condition variable
*Condition variable*: meccanismo di sincronizzazione che consente a un thread di attendere che si verifichi una condizione specifica. È una coda esplicita in cui i thread possono mettersi in attesa quando una condizione non è soddisfatta; un altro thread, quando cambia la condizione, può quindi svegliare uno (o più) di quei thread in attesa e quindi consentire loro di continuare (segnalando sulla condizione).

#figure(caption: [Come creare una condition variable.])[
  #text(size: 9pt)[
    ```c
    pthread_cond_t c;
    ```
  ]
]

Una condition variable ha due operazioni associate:
- `pthread_cond_wait()`: mette il thread corrente in attesa di una condizione specificata. La condizione è rappresentata da un oggetto di tipo `thread_cond_t`. Il thread corrente viene risvegliato quando la condizione è soddisfatta o quando viene interrotto da un segnale.
- `pthread_cond_signal()`: sveglia uno o più thread che sono in attesa della condizione specificata.

#text(size: 9pt)[
  ```c
  int pthread_cond_wait(
     pthread_cond_t cond, pthread_mutex_t mutex
  );
  int pthread_cond_signal(pthread_cond_t cond);
  ```
]

=== Problema del buffer limitato
Anche chiamato "The Producer/Consumer Problem".
Problema di sincronizzazione comune in cui uno o più thread produttori generano dati e li inseriscono in un buffer, mentre uno o più thread consumatori prelevano i dati dal buffer e li consumano.
Il buffer è una risorsa condivisa, quindi è necessario sincronizzare l'accesso ad essa per evitare race condition.
#figure(caption: [The Put And Get Routines (v1).])[
  #text(size: 9pt)[
    ```c
    int buffer;
    int count = 0; // initially, empty

    void put(int value) {
       assert(count === 0);
       count = 1;
       buffer = value(
    )

    int get() {
       assert(count === 1);
       count = 0;
       return buffer(
    )
    ```
  ]
]

Occorrono routine che sappiano quando è possibile accedere al buffer per inserire/estrarre dati. Così:

#figure(caption: [Producer/Consumer Threads (v1).])[
  #text(size: 9pt)[
    ```c
    void producer(void arg) {
       int i;
       int loops = (int) arg;
       for (i = 0; i < loops; i++) {
          put(i);
       }
    }

    void consumer(void arg) {
       while (1) {
          int tmp = get();
          printf("%d\n", tmp);
       }
    }
    ```
  ]
]


==== Soluzione v1 (broken, if statement)
#figure(caption: [Producer/Consumer: Single CV And If Statement.])[
  #text(size: 9pt)[
    ```c
    int loops; // must initialize somewhere...
    cond_t cond;
    mutex_t mutex;

    void producer(void arg) {
       int i;
       for (i = 0; i < loops; i++) {
          Pthread_mutex_lock(&mutex); // p1
          if (count === 1) // p2
             Pthread_cond_wait(&cond, &mutex); // p3
          put(i); // p4
          Pthread_cond_signal(&cond); // p5
          Pthread_mutex_unlock(&mutex); // p6
       }
    }

    void consumer(void arg) {
       int i;
       for (i = 0; i < loops; i++) {
          Pthread_mutex_lock(&mutex); // c1
          if (count === 0) // c2
             Pthread_cond_wait(&cond, &mutex); // c3
          int tmp = get(); // c4
          Pthread_cond_signal(&cond); // c5
          Pthread_mutex_unlock(&mutex); // c6
          printf("%d\n", tmp);
       }
    }
    ```
  ]
]

*Problema*: quando ci sono più consumatori è possibile che uno consumi il buffer prima dell'altro, quando il consumatore tenterà di consumare un buffer vuoto causerà un errore.

$T_("c1")$ viene eseguito:
+ Acquisisce il lock (c1)
+ Controlla se ci sono buffer pronti per il consumo (c2) ma non ce ne sono.
+ Attende (c3) (rilasciando il blocco).

$T_p$ viene eseguito:
+ Acquisisce il lock (p1)
+ Controlla se tutti i buffer sono pieni (p2) ma i buffer sono vuoti
+ Riempie il buffer (p4).
+ Segnala che un buffer è stato riempito (p5).

$T_("c1")$ ora è pronto per l'esecuzione fino a quando non si rende conto che il buffer è pieno. Rilascia il lock e si mette a dormire (p6, p1-p3).

Problema: $T_("c2")$ si intrufola e consuma il buffer (c1, c2, c4, c5, c6, saltando l'attesa in c3 perché il buffer è pieno).

$T_("c1")$ va in esecuzione:
+ Poco prima di tornare dall'attesa, riacquisisce il blocco e poi torna.
+ Chiama `get()` (c4) e non ci sono buffer da consumare!
+ Si attiva un'asserzione e il codice non ha funzionato come desiderato.

Avremmo dovuto impedire a $T_("c1")$ di provare a consumare perché $T_("c2")$ si è intrufolato consumando il buffer che era stato prodotto.

Il problema si verifica perché il consumatore $T_("c1")$ non è stato in grado di verificare che il buffer fosse effettivamente pronto prima di chiamare `get()`.

#figure(
  image("../images/cv/trace 1.png"),
  caption: [Trace dei thread con l'if.],
)
*Semantica Mesa*: un segnale a un thread è solo un suggerimento che lo stato del mondo è cambiato. Il thread svegliato non ha alcuna garanzia che lo stato del mondo sarà ancora come lo desiderava.

*Semantica di Hoare*: un segnale a un thread garantisce che il thread verrà eseguito immediatamente dopo essere stato svegliato. Questo significa che il thread svegliato avrà la possibilità di verificare che lo stato del mondo sia ancora come lo desiderava.

==== Soluzione v2 (broken, while statement)

#figure(caption: [Producer/Consumer: Single CV And While.])[
  #text(size: 9pt)[
    ```c
    int loops;
    cond_t cond;
    mutex_t mutex;

    void *producer(void *arg) {
       int i;
       for (i = 0; i < loops; i++) {
          Pthread_mutex_lock(&mutex); // p1
          while (count === 1) // p2
             Pthread_cond_wait(&cond, &mutex); // p3
          put(i); // p4
          Pthread_cond_signal(&cond); // p5
          Pthread_mutex_unlock(&mutex); // p6
       }
    }

    void *consumer(void *arg) {
       int i;
       for (i = 0; i < loops; i++) {
          Pthread_mutex_lock(&mutex); // c1
          while (count === 0) // c2
             Pthread_cond_wait(&cond, &mutex); // c3
          int tmp = get(); // c4
          Pthread_cond_signal(&cond); // c5
          Pthread_mutex_unlock(&mutex); // c6
          printf("%d\n", tmp);
       }
    }
    ```
  ]
]

Cambiando l'`if` con il `while`:

Il thread $T_("c1")$:
+ Si sveglia e (con il lock acquisito).
+ Controlla lo stato della cv (c2).
+ Se il buffer è vuoto, il consumatore torna semplicemente a dormire (c3).

L'`if` e cambiato in `while` anche nel produttore (p2).

Problema 2: tutti e tre i thread rimangono inattivi.

Il problema si verifica quando due consumatori vengono eseguiti per primi ($T_("c1")$ e $T_("c2")$) e si addormentano entrambi (c3).

Il thread $T_p$:
+ Inserisce un valore nel buffer e sveglia uno dei consumatori (diciamo $T_("c1")$).
+ Torna indietro (rilasciando e riacquistando il blocco lungo il percorso) e tenta di inserire più dati nel buffer e vede il buffer pieno, il produttore invece attende sulla condizione (così dormendo).

il thread $T_("c1")$:
+ Due thread sono in attesa su una condizione ($T_("c2")$ e $T_p$).
+ Si sveglia quindi tornando da wait() (c3)
+ Ricontrolla la condizione (c2) e il buffer pieno
+ Consuma il valore (c4).
+ Invia un segnale sulla condizione (c5), svegliando solo un thread che è in attesa.

Quale thread dovrebbe svegliare?

Poiché il consumatore ha svuotato il buffer, dovrebbe chiaramente svegliare il produttore. Ma se sveglia il consumatore $T_("c2")$ (che è sicuramente possibile, a seconda di come viene gestita la coda di attesa), abbiamo un problema:

- $T_("c2")$ si sveglierà e troverà il buffer vuoto (c2) e tornerà a dormire (c3).
- $T_p$, che ha un valore da inserire nel buffer, rimane addormentato.
- $T_("c1")$, torna anche a dormire.

Tutti e tre i thread rimangono inattivi.

È evidente che è necessario inviare un segnale, ma deve essere più diretto. Un consumatore non dovrebbe svegliare altri consumatori, solo produttori, e viceversa.

#figure(
  image("../images/cv/trace 2.png"),
  caption: [Trace dei thread senza il while.],
)

==== Soluzione a singolo buffer
#figure(caption: [Producer/Consumer: Two CVs And While.])[
  #text(9pt)[
    ```c
    cond_t empty, fill;
    mutex_t mutex;

    void producer(void arg) {
       int i;
       for (i = 0; i < loops; i++) {
          Pthread_mutex_lock(&mutex);
          while (count === 1)
             Pthread_cond_wait(&empty, &mutex);
          put(i);
          Pthread_cond_signal(&fill);
          Pthread_mutex_unlock(&mutex);
          }
       }

    void consumer(void arg) {
       int i;
       for (i = 0; i < loops; i++) {
          Pthread_mutex_lock(&mutex);
          while (count === 0)
             Pthread_cond_wait(&fill, &mutex);
          int tmp = get();
          Pthread_cond_signal(&empty);
          Pthread_mutex_unlock(&mutex);
          printf("%d\n", tmp);
          }
       }
    ```
  ]
]

Il problema del produttore/consumatore con buffer singolo può essere risolto utilizzando due variabili di condizione.

I produttori aspettano sulla condizione empty e segnalano fill. I consumatori aspettano su fill e segnalano empty. In questo modo un consumatore non può mai svegliare accidentalmente un altro consumatore, e un produttore non può mai svegliare accidentalmente un altro produttore. La soluzione è corretta ma no in generale.

==== Soluzione corretta

Modifica che porta maggiore concorrenza e efficienza.

Aggiungiamo più slot del buffer, in modo che più valori possano essere prodotti prima di dormire, e allo stesso modo più valori possono essere consumati prima di dormire.

Con un solo produttore e consumatore, questo approccio è più efficiente in quanto riduce gli switch di contesto; con più produttori o consumatori (o entrambi), consente anche la produzione o il consumo concorrente, aumentando così la concorrenza.

#figure(caption: [The Correct Put And Get Routines.])[
  #text(size: 9pt)[
    ```c
    int buffer[MAX];
    int fill_ptr = 0;
    int use_ptr = 0;
    int count = 0;
    void put(int value) {
    buffer[fill_ptr] = value;
    fill_ptr = (fill_ptr + 1) % MAX;
    count++;
    }
    int get() {
    int tmp = buffer[use_ptr];
    use_ptr = (use_ptr + 1) % MAX;
    count--;
    return tmp;
    }
    ```
  ]
]

#figure(caption: [The Correct Put And Get Routines.])[
  #text(size: 9pt)[
    ```c
    cond_t empty, fill;
    mutex_t mutex;

    void * producer(void * arg) {
       int i;
       for (i = 0; i < loops; i++) {
          Pthread_mutex_lock( & mutex); // p1
          while (count === MAX) // p2
             Pthread_cond_wait( & empty, & mutex); // p3
          put(i); // p4
          Pthread_cond_signal( & fill); // p5
          Pthread_mutex_unlock( & mutex); // p6
       }
    }

    void * consumer(void * arg) {
       int i;
       for (i = 0; i < loops; i++) {
          Pthread_mutex_lock( & mutex); // c1
          while (count === 0) // c2
             Pthread_cond_wait( & fill, & mutex); // c3
          int tmp = get(); // c4
          Pthread_cond_signal( & empty); // c5
          Pthread_mutex_unlock( & mutex); // c6
          printf("%d\n", tmp);
       }
    }
    ```
  ]
]

=== Covering Conditions
Un produttore dorme solo se tutti i buffer sono attualmente pieni (p2). Un consumatore dorme solo se tutti i buffer sono attualmente vuoti (c2).
#figure(caption: [Covering Conditions example.])[
  #text(9pt)[
    ```c
    // how many bytes of the heap are free?
    int bytesLeft = MAX_HEAP_SIZE;

    // need lock and condition too
    cond_t c;
    mutex_t m;

    void allocate(int size) {
          Pthread_mutex_lock( & m);
          while (bytesLeft < size)
             Pthread_cond_wait( & c, & m);
          void  ptr = ...; // get mem from heap
          bytesLeft -= size;
          Pthread_mutex_unlock( & m);
          return (tr;
    )

    void free(void  ptr, int size) {
       Pthread_mutex_lock( & m);
       bytesLeft += size;
       Pthread_cond_signal( & c); // whom to signal??
       Pthread_mutex_unlock( &(m);
    )
    ```
  ]
]


Considera zero byte liberi.

+ $T_a$ chiama `allocate(100)`,
+ $T_b$ che richiede meno memoria chiamando `allocate(10)`.
+ Entrambi $T_a$ e $T_b$ quindi aspettano sulla condizione e si addormentano; non ci sono abbastanza byte liberi per soddisfare nessuno di questi requisiti.
+ $T_c$, chiama free(50)
+ $T_c$ chiama signal per svegliare un thread in attesa e potrebbe non svegliare il thread corretto
+ $T_b$, che sta aspettando solo 10 byte da liberare
+ $T_a$ dovrebbe rimanere in attesa, poiché non è ancora disponibile abbastanza memoria.

Il codice non funziona, il thread che sveglia altri thread non sa quale thread svegliare.

Soluzione suggerita da Lampson e Redell (condizione di copertura): \ Sostituire la chiamata `pthread_cond_signal()` con `pthread_cond_broadcast()`, che sveglia tutti i thread in attesa in modo da svegliare tutti thread che dovrebbero essere svegli. Può impattare sulle prestazioni ma i thread si svegliati inutilmente ricontrolleranno la condizione e poi torneranno a dormire.

#colbreak()