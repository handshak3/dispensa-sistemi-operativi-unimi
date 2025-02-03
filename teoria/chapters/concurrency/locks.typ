#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Locks
#text(size: 9pt)[
  ```c
  lock_t mutex; // some globally-allocated lock 'mutex'
  ...
  lock(&mutex);
  balance = balance + 1;
  unlock(&mutex);
  ```
]

*Lock o mutex:* primitiva di sincronizzazione, un meccanismo che impone dei limiti all'accesso a una risorsa quando ci sono molti thread di esecuzione. Utilizzato per garantire la mutua esclusione. Nella pratica è una variabile che rappresenta lo stato del lock (locked/unlocked).

=== Funzionamento dei lock
#text(size: 9pt)[
  ```c
  pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
  Pthread_mutex_lock(&lock); // wrapper; exits on failure
  balance = balance + 1;
  Pthread_mutex_unlock(&lock);
  ```
]

I lock vanno inizializzati perché possono assumere solamente due valori:
- Disponibile
- Acquisito

Funzionamento:
+ Viene chiamata la routine `lock()` per acquisire il lock.
+ Se disponibile, il thread chiamante riceve il lock e può entrare in sezione critica. Se acquisito, il thread chiamante rimarrà “bloccato” nella routine `lock()` fino a quando il thread in sezione critica non termina e invoca la `unlock()`.
+ Una volta acquisito il lock un thread può operare in sezione critica, una volta terminato lo rilascia tramite `unlock()`.

`lock()`: routine chiamata dal thread che tenta di acquisire il lock in modo tale da permettere al thread (owner of the lock) di accedere alla sezione critica. Viene acquisito il lock se nessun altro thread lo detiene. Non è possibile acquisire il lock quando non è libero.

`unlock()`: routine chiamata dal proprietario del lock che libera il lock.

Obbiettivi dei lock:
- *Mutua esclusione*: impedimento ai thread di entrare nelle sezioni critiche.
- *Equità*: i thread che si contendono i lock hanno la stessa possibilità di acquisirlo una volta che il lock è libero.
- *Performance*: costo aggiuntivo in termini di tempo.

*Primitive di sincronizzazione*
- Disabilitare gli interrupt
- Load/Stores
- TestAndSet
- Load-linked and store conditional
- Fetch-And-AddFetch

==== Disabilitare gli interrupt

#figure(caption: [Lock che disabilitano l'interrupt.])[
  #text(size: 9pt)[
    ```c
    void lock() {
      DisableInterrupts();
    }

    void unlock() {
      EnableInterrupts();
    }
    ```
  ]
]

Disattivando gli interrupt prima di entrare in una sezione critica, ci assicuriamo che il codice all'interno della sezione non verrà interrotto e quindi verrà eseguito come se fosse atomico. Si ottiene l'esclusione reciproca (mutual execution).

Vantaggi: semplicità della politica.

Svantaggi:
- Richiede un'operazione privilegiata (ON/OFF interrupts): ci potrebbe essere un abuso tramite la routine `lock()`.
- Non funziona su sistemi a multi processore: se molti thread sono in esecuzione su più CPU, non importa se gli interrupt sono disabilitati, i thread potrebbero comunque accedere alla sezione critica tramite altre CPU.
- Gli interrupt potrebbero essere disabilitati per tanto tempo.
- L'approccio può essere inefficiente: il codice che attiva e disabilita gli interrupt è tendenzialmente più lento.

==== Loads/Stores

#figure(caption: [Lock con load/store.])[
  ```c
    typedef struct __lock_t { int flag; } lock_t;

    void init(lock_t *mutex) {
      // 0 -> lock is available, 1 -> held
      mutex->flag = 0;
    }

    void lock(lock_t *mutex) {
      while (mutex->flag === 1) // TEST the flag
      ; // spin-wait (do nothing)
      mutex->flag = 1; // now SET it!
    }

    void unlock(lock_t *mutex) {
      mutex->flag = 0;
    }
  ```
]

Per costruire un lock efficace, dobbiamo sfruttare le istruzioni hardware della CPU. Un primo approccio consiste nell'usare una variabile flag per indicare se un thread possiede il lock.

*Funzionamento del lock semplice:*
+ Un thread chiama `lock()`, verifica che `flag === 0` e imposta `flag = 1`, ottenendo il lock.
+ Dopo aver terminato, chiama `unlock()` e ripristina `flag = 0`.
+ Se un altro thread chiama `lock()` mentre il primo è nella sezione critica, rimane bloccato in un ciclo di attesa (`spin-waiting`) finché il flag non viene liberato.

Problemi:
+ *Errore di correttezza (mancanza di mutua esclusione)*: Se due thread eseguono `lock()` quasi simultaneamente, entrambi possono vedere `flag = 0` e impostarlo a `1`, accedendo contemporaneamente alla sezione critica. Questo viola la mutua esclusione.
+ *Problema di prestazioni*: L'uso dello spin-waiting fa sì che un thread consumi inutilmente tempo CPU controllando continuamente il flag. Questo è particolarmente inefficiente su sistemi monoprocessore, dove il thread bloccante non può avanzare fino al prossimo context switch.

#figure(
  image("../../images/locks/no mutual exclusion.png"),
  caption: [Trace: No Mutual Exclusion.],
)

==== TestAndSet

Sistemi multiprocessore moderni, anche quelli con un singolo processore, supportano primitiva hardware per il locking, come il Test-and-Set.

#text(size: 9pt)[
  ```c
  typedef struct __lock_t {
    int flag;
  } lock_t;

  void init(lock_t *lock) {
    // 0: lock is available, 1: lock is held
    lock->flag = 0;
  }

  void lock(lock_t *lock) {
    while (TestAndSet(&lock->flag, 1) === 1)
      // spin-wait (do nothing)
  }

  void unlock(lock_t *lock) {
    lock->flag = 0;
  }
  ```
]

#figure(caption: [Lock con `TestAndSet()`.])[
  #text(size: 9pt)[
    ```c
    int TestAndSet(int *old_ptr, int new) {
      int old = *old_ptr; // fetch old value at old_ptr
      *old_ptr = new; // store 'new' into old_ptr
      return old; // return the old value
    }
    ```
  ]
]

Utilizziamo un flag per indicare se un thread possiede un lock.

L'operazione `TestAndSet()` esegue due operazioni atomiche in un'unica istruzione:
- Legge il valore attuale di una variabile condivisa (solitamente un flag di lock).
- Aggiorna la variabile con un nuovo valore.
- Restituisce il valore precedente della variabile.

Funzionamento:
+ Il thread chiamerà `lock()`;
+ Verifica se il flag vale “1” (se ha un lock).
  - Se il flag vale “0” il thread può holdare il lock. Al termine della sezione critica, il thread chiama `unlock()`.
  - Se il flag vale “1” il thread già holda un lock.

Se un thread B chiama `lock()` mentre thread A è nella sezione critica, thread B aspetterà (*spin-wait*) in un ciclo while finché thread A non avrà fatto `unlock()`. Dopo l'unlock di thread A, thread B esce dal ciclo while e imposta il suo flag a “1” ed entra nella sezione critica.

*Spinlock*: meccanismo che permette a un thread di attendere attivamente finché una risorsa condivisa non diventa disponibile.

Spinlock è più adatto con uno scheduler preemptive, in quanto un thread in attesa può essere interrotto periodicamente per dare opportunità ad altri thread di eseguire. Senza la prelazione, gli spinlock potrebbero essere inefficaci su un singolo processore, poiché un thread in attesa non rinuncerebbe mai al controllo del processore.

Vantaggi:
- Facili da implementare con supporto hardware.
- Garantisce esclusione mutua con operazioni atomiche.
- Utile su sistemi multiprocessore.

Svantaggi:
- Consumo di CPU: Se il lock è occupato, il thread continua a cicli di attesa (inefficiente su singola CPU senza preemption).
- Busy-Waiting: Blocca risorse inutilmente se il lock rimane occupato a lungo.

====== Valutazione di uno spinlock
- *Correttezza*: lo spin lock effettua l'esclusione reciproca.
- *Equità*: non forniscono garanzia di equità. Non garantisce che un thread in attesa entri mai nella sezione critica, potenzialmente portando a situazioni di stallo e fame dei thread.
- *Performance*: su sistemi a singola CPU i costi sono molto alti. Per sistemi multi processore i costi sono sostenibili finché il numero dei thread non supera quello delle CPU.

==== Compare-and-swap
Primitiva hardware alternativa al Test-And-Compare. Viene confrontato il valore del puntatore (`*ptr`) con quello aspettato (expected), se questi risultano uguali il valore del puntatore viene aggiornato con uno nuovo.

Compare-and-Swap è una primitiva più potente rispetto a test-and-set poiché consente di confrontare il valore e aggiornarlo solo se corrisponde a un valore atteso. Entrambi i metodi usano un ciclo di spin, ma CAS offre maggiore flessibilità per altre applicazioni come la sincronizzazione lock-free.

#text(size: 9pt)[
  ```c
  void lock(lock_t *lock) {
    while (CompareAndSwap(&lock->flag, 0, 1) === 1)
    ; // spin
  }
  ```
]

#figure(caption: [Lock con `CompareAndSwap()`.])[
  #text(size: 9pt)[
    ```c
    int CompareAndSwap(int *ptr, int expected, int new) {
      int original = *ptr;
      if (original === expected)
        *ptr = new;
      return original;
    }
    ```
  ]
]

==== Load-linked and store conditional

load-linked" e store-conditional lavorano insieme per costruire sezioni critiche.

La Load-Linked legge un valore dalla memoria e lo immagazzina in un registro, mentre Store-Conditional aggiorna il valore solo se nessuna modifica è avvenuta nel frattempo all'indirizzo di memoria.

- *load-linked*: preleva un valore dalla memoria e lo inserisce in un registro.

- *store-conditional*: controlla che il load abbia aggiornato il puntatore, se lo ha fatto aggiorna il puntatore e restituisce “1” altrimenti ritorna “0”.

Funzionamento:
+ Load-Linked: Carica un valore dalla memoria in un registro.
+ Store-Conditional:
  - Aggiorna il valore solo se non è stato modificato da un'altra operazione tra il Load-Linked e il Store-Conditional.
  - Se l'aggiornamento ha successo, restituisce 1; altrimenti, restituisce 0.

#text(size: 9pt)[
  ```c
  void lock(lock_t *lock) {
    while (1) {
      while (LoadLinked(&lock->flag) === 1)
        // spin until it's zero
      if (StoreConditional(&lock->flag, 1) === 1)
        return; // if set-to-1 was success: done
                // otherwise: try again
      }
  }

  void unlock(lock_t *lock) {
    lock->flag = 0;
  }
  ```
]

#figure(caption: [Lock con `LoadLinked()` e `StoreConditional()`])[
  #text(size: 9pt)[
    ```c
    int LoadLinked(int *ptr) {
      return *ptr;
    }

    int StoreConditional(int *ptr, int value) {
      if (no update to *ptr since LL to this addr) {
        *ptr = value;
        return 1; // success!
      } else {
          return 0; // failed to update
      }
    }
    ```
  ]
]

Nel codice di `lock()`, un thread attende che il flag sia impostato a 0, indicando che il blocco non è detenuto. Poi, tenta di acquisire il blocco usando la `StoreConditional()`. Se questa operazione ha successo, il thread ha cambiato atomicamente il valore del flag a 1 e può procedere nella sezione critica.

`StoreConditional()` può fallire se un altro thread ha modificato il valore del flag tra la `LoadLinked()` e la `StoreConditional()`. In caso di fallimento, il thread deve ritentare l'acquisizione del blocco.

#text(size: 9pt)[
  ```c
  void lock(lock_t *lock) {
    while (LoadLinked(&lock->flag) || !StoreConditional(&lock->flag, 1))
      ; // spin
  }
  ```
]

==== FetchAndAdd

La primitiva fetch-and-add è un'operazione atomica che incrementa un valore in memoria e restituisce il valore precedente. Questa primitiva è utilizzata per creare un ticket block. Per creare un lock si utilizzano in modo combinato un `ticket` e una variabile `turn`. Quando un thread ha `myturn === turn`, può entrare nella sezione critica.

#figure(caption: [Lock con `FetchAndAdd()` (ticket lock)])[
  #text(size: 9pt)[
    ```c
    int FetchAndAdd(int *ptr) {
      int old = *ptr;
      *ptr = old + 1;
      return old;
    }
    ```
  ]
]

#text(size: 9pt)[
  ```c
  typedef struct __lock_t {
      int ticket;
      int turn;
  } lock_t;

  void lock_init(lock_t *lock) {
      lock->ticket = 0;
      lock->turn = 0;
  }

  void lock(lock_t *lock) {
      int myturn = FetchAndAdd(&lock->ticket);
      while (lock->turn != myturn)
          ; // spin
  }

  void unlock(lock_t *lock) {
      lock->turn = lock->turn + 1;
  }
  ```
]

Quando un thread desidera acquisire il lock, esegue un'operazione `FetchAndAdd()` atomica sul valore del `ticket`; questo valore diventa `turn` di quel thread `myturn`. La variabile `lock->turn` viene utilizzata per determinare quale thread ha il proprio turno. Quando `(myturn === turn)` per un determinato thread, è il turno di quel thread di entrare nella sezione critica. Il rilascio del lock viene eseguito incrementando la variabile `turn`, consentendo al thread successivo in attesa (se presente) di entrare nella sezione critica.

Questa implementazione assicura il progresso per tutti i thread. Una volta assegnato un valore di `ticket` a un thread, sarà pianificato in qualche momento futuro.

Funzionamento:
Quando un thread desidera acquisire un lock, esegue atomicamente Fetch-And-Add sul valore del ticket (turn). lock → turn determina quale thread ha il turno. Quando il turno del thread è uguale al turno. Quando il turn del thread e il turn globale coincidono, il thread entra nella sezione critica. L'`unlock()` viene fatto all'incremento del turno. Garantisce l'equità perché al momento che il thread riceve il valore del ticket riceverà un ordine di scheduling.

Vantaggi del Ticket Lock
- Il ticket lock offre un'importante progresso garantito rispetto ad altri lock come il test-and-set. Una volta che un thread riceve il suo biglietto, entrerà nella sezione critica dopo che tutti i thread davanti a lui avranno completato il loro turno.
- Garantisce fairness: ogni thread otterrà il proprio turno in ordine, senza rischiare di essere bloccato indefinitamente.

A differenza di test-and-set, che non garantisce alcun progresso (un thread può rimanere in attesa indefinitamente), il ticket lock garantisce che ogni thread acquisisca il lock in ordine, migliorando la fairness. Il ticket lock è particolarmente utile in ambienti multi-threading ad alta concorrenza, dove si vuole evitare la starvation.

=== Problema dei lock con il context switch

#text(size: 9pt)[
  ```c
  void init() {
    flag = 0;
  }

  void lock() {
    while (TestAndSet(&flag, 1) === 1)
      yield(); // give up the CPU
  }

  void unlock() {
    flag = 0;
  }
  ```
]

Quando un thread è interrotto durante una sezione critica (ad esempio, a causa di un context switch), gli altri thread che stanno aspettando il lock potrebbero entrare in un ciclo di spin infinito, in attesa che il thread interrotto riprenda l'esecuzione.

Soluzione iniziale proposta: invece di far girare indefinitamente, il thread cede la CPU ad un altro thread. Questo è ciò che viene descritto con il concetto di yield.

Si utilizza un'operazione Test-and-Set per verificare se il lock è disponibile e acquisirlo se non lo è. Se il lock è già acquisito, il thread non spinna (non consuma cicli della CPU inutilmente), ma esegue `yield()`, che cede la CPU ad un altro thread.

Se ci sono solo due thread e un thread ottiene il lock, il secondo thread chiama `lock()`, rileva che il lock è occupato, e cede la CPU. Questo è un miglioramento rispetto al comportamento di spin, in quanto un thread non consuma cicli di CPU inutili, ma il contesto di switching è più efficiente.

*Problema di costo*: Se ci sono molti thread che contendono per il lock (es. 100), e uno di questi thread acquisisce il lock ma viene preempted prima di rilasciarlo, gli altri 99 thread entreranno nel ciclo di lock() e chiameranno yield(). Ogni thread in attesa cede la CPU, causando un gran numero di context switch. Un gran numero di switch di contesto può diventare costoso, con sprechi di tempo notevoli.

*Problema di starvation*: un thread potrebbe finire intrappolato in un ciclo di yield senza mai ottenere l'opportunità di entrare nella sezione critica, mentre altri thread entrano e escono dal blocco. Questo dimostra che l'approccio yield non risolve completamente il problema della fairness e della starvation.

=== Lock con le code
Utilizziamo le *code* per tracciare i thread in attesa del lock e l'OS per controllare i successivi thread detentori del lock.

L'approccio di yield può comportare un uso inefficiente della CPU con costosi context switch e non risolve completamente il problema della starvation, in cui alcuni thread potrebbero essere bloccati indefinitamente in attesa del lock.

La soluzione migliore è quella di mettere i thread in attesa (sleep) invece di farli "girare" in attesa del lock. Questo è ciò che viene fatto con l'uso di una coda di attesa (queue) che tiene traccia di quali thread sono in attesa di acquisire il lock. In questo modo, l'OS ha più controllo su quale thread acquisisce il lock successivamente, evitando starvation e migliorando l'efficienza.

- `park()`: per mettere il thread in attesa.
- `unpark()`: per svegliare il thread quando il lock è disponibile. La gestione del lock avviene con una coda che contiene i thread in attesa.

`park()` e `unpark()` sono due routine utilizzate per creare un lock che mette nello stato di stop il chiamante tenta di acquisire un blocco trattenuto e lo riattiva quando il lock è libero.

Non evita del tutto l'attesa di rotazione: potrebbe essere interrotto durante l'acquisizione o il rilascio del lock e fare in modo che altri thread ruotino in attesa che questo venga eseguito nuovamente (tempo trascorso a spinnare limitato).

Quando un thread non può acquisire il lock, il processo chiamante va in coda (chiamando gettid per ottenere l'ID del thread corrente), imposta guard a zero e rilascia la CPU.

`setpark()`: quando un thread chiama questa routine può indicare se sta per fare park(). Se capita di essere interrotto e un altro thread chiama unpark() prima che il park venga effettivamente chiamato, il park successivo ritorna immediatamente invece di dormire.

#text(size: 9pt)[
  ```c
  typedef struct __lock_t {
      int flag;
      int guard;
      queue_t *q;
  } lock_t;

  void lock_init(lock_t *m) {
      m->flag = 0;
      m->guard = 0;
      queue_init(m->q);
  }

  void lock(lock_t *m) {
      while (TestAndSet(&m->guard, 1) === 1)
          ; //acquire guard lock by spinning

      if (m->flag === 0) {
          m->flag = 1; // lock is acquired
          m->guard = 0;
      } else {
          queue_add(m->q, gettid());
          m->guard = 0;
          park();
      }
  }

  void unlock(lock_t *m) {
      while (TestAndSet(&m->guard, 1) === 1)
          ; //acquire guard lock by spinning

      if (queue_empty(m->q))
          m->flag = 0; // let go of lock; no one wants it
      else
          unpark(queue_remove(m->q)); // hold lock
      // (for next thread!)
      m->guard = 0;
  }
  ```
]

Vantaggi di questo Approccio:
- *Evitare lo Spin*: Questo approccio evita l'effetto negativo dello spinning continuo e del context switch costoso. Invece di occupare cicli di CPU inutilmente, i thread dormono e sono risvegliati solo quando necessario.

- *Controllo del Scheduler*: Grazie all'uso delle primitive park e unpark, l'operazione di lock non dipende esclusivamente dalla scelta del sistema operativo su quale thread eseguire. I thread vengono messi in attesa e risvegliati nell'ordine in cui sono arrivati.

- *Evitare la Starvation*: Poiché i thread sono gestiti tramite una coda, l'ordine di acquisizione del lock è determinato in modo equo. Ogni thread attende il suo turno per entrare nella sezione critica, eliminando così il problema di starvation.

Problematiche e soluzioni:
- *Race Condition (Guard e Park)*: Potrebbe esserci un race condition tra il momento in cui un thread verifica che il lock è occupato (dando l'impressione di dover dormire) e il momento in cui un altro thread rilascia il lock. Se il thread che sta per dormire viene interrotto proprio in quel momento, potrebbe rischiare di dormire all'infinito. Per risolvere questo, viene introdotto un meccanismo chiamato setpark() che segnala al sistema operativo che il thread sta per essere messo a dormire. Se il lock viene rilasciato prima che il thread effettivamente si addormenti, questo viene immediatamente svegliato.
- *Guard Lock e Coda*: L'uso del guard lock è necessario per evitare che altri thread possano manipolare flag e la coda mentre un thread sta tentando di acquisirli. Se un thread viene interrotto mentre acquisisce o rilascia il lock, altri thread dovranno aspettare che il guard lock venga rilasciato.
-
=== Futex

*Futex (fast user space mutex)*: primitiva di sincronizzazione in Linux. È associato a un'area di memoria fisica specifica e ha una coda in-kernel dedicata. Ogni futex è associata a una locazione specifica nella coda del kernel.

`futex_wait(indirizzo, valore_atteso)`: mette il thread chiamante in attesa, assumendo che il valore all'indirizzo sia uguale a quello atteso. Se non è uguale, la chiamata restituisce immediatamente.

`futex_wake(indirizzo)`: sveglia un thread in attesa nella coda.

Un esempio pratico è dato dal codice in lowlevellock.h nella libreria nptl di glibc. Questo codice utilizza un singolo intero per tracciare lo stato del lock e il numero di attese. L'ottimizzazione è implementata per il caso in cui non ci sia competizione per il lock, riducendo al minimo il lavoro in situazioni di singolo thread.

=== Two-Phase Locks
I Two-Phase Locks sono un meccanismo di sincronizzazione ibrido che combina attesa attiva (spinning) e sospensione (sleeping) per migliorare le prestazioni nell'acquisizione di un lock.

Fasi del Two-Phase Lock:
- *1° fase (spin)*: Il thread tenta di acquisire il lock rimanendo in attesa attiva (spinning). Se il lock è rilasciato rapidamente, il thread lo acquisisce senza dover effettuare un costoso cambio di contesto.
- *2°fase (sleep)*: se il thread non riesce ad acquisire il lock entro un certo tempo, entra in stato di sospensione (sleep), riducendo il consumo di CPU. Il thread viene riattivato solo quando il lock diventa disponibile.

#colbreak()