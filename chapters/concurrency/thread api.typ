#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Thread API

=== `pthread_create()`
In POSIX, la funzione `pthread_create()` viene utilizzata per creare un nuovo thread.

La funzione `pthread_create()` ha quattro argomenti:
- `thread`: puntatore a una struttura che verrà utilizzata per interagire con il nuovo thread.
- `attr`: puntatore a una struttura che può essere utilizzata per specificare attributi del thread, come la dimensione dello stack o la priorità di scheduling.
- `start_routine`: puntatore alla funzione che il nuovo thread eseguirà quando verrà creato.
- `arg`: argomento che verrà passato alla funzione start_routine.

La funzione `pthread_create()` restituisce un intero che indica se la creazione del thread è stata completata con successo.

=== `pthread_join()`

La funzione `pthread_join()` viene utilizzata per attendere il completamento di un thread.

La funzione `pthread_join()` prende due argomenti:
- `thread`: un puntatore alla struttura che identifica il thread da attendere.
- `value_ptr`: un puntatore a una variabile in cui verrà memorizzato il valore di ritorno del thread.

La funzione `pthread_join()` blocca il thread chiamante fino a quando il thread specificato non è terminato.

Funzionamento:
- Se il thread specificato non è ancora terminato, attenderà fino al suo termine.
- Se il thread specificato è già terminato, restituirà immediatamente.
- Se si passa NULL come valore di `value_ptr`, non memorizzerà il valore di ritorno del thread.

=== Locks o mutex

I lock sono un meccanismo di mutua esclusione che consente a un solo thread alla volta di accedere a una sezione critica.

La libreria POSIX fornisce due routine di base per l'utilizzo dei lock:

#text(9pt)[
  ```c
  int pthread_mutex_lock(pthread_mutex_t *mutex);
  int pthread_mutex_unlock(pthread_mutex_t *mutex);
  ```
]

La routine `pthread_mutex_lock()` acquisisce il lock e la routine `pthread_mutex_unlock()` lo rilascia.
#text(9pt)[
  ```c
  pthread_mutex_t lock;
  pthread_mutex_lock(&lock);
  x = x + 1;
  pthread_mutex_unlock(&lock);
  ```
]

- *Problema 1:* Il lock non è stato inizializzato correttamente. I lock devono essere inizializzati prima di essere utilizzati.
- *Problema 2:* Il codice non controlla gli errori quando chiama le routine di lock. Le routine di lock possono fallire, quindi è importante controllare gli errori per assicurarsi che il lock sia stato acquisito correttamente.

Per inizializzare il lock ci sono 2 modi:
- Modo 1:
  #text(9pt)[
    ```c
    pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
    ```
  ]
- Modo 2:
  #text(9pt)[
    ```c
    int rc = pthread_mutex_init(&lock, NULL);
    assert(rc == 0); // always check success!
    ```
  ]

Per risolvere il problema 2, è necessario controllare gli errori quando si chiamano le routine di lock. Questo può essere fatto utilizzando l'istruzione `assert()` o controllando il valore restituito dalla routine.

Esistono due altre routine di lock:
- `pthread_mutex_trylock()`: tenta di acquisire il lock e restituisce un errore se il lock è già acquisito da un altro thread.
- `pthread_mutex_timedlock()`: tenta di acquisire il lock entro un timeout specificato e restituisce un errore se il lock non è stato acquisito entro il timeout.

=== Condition variables

*Condition variables*: meccanismo di sincronizzazione tra thread che consentono a un thread di attendere che si verifichi una condizione specifica. Utilizzate quando un thread deve aspettare che un altro thread modifichi un dato valore o stato. Implementate utilizzando un lock necessario per garantire che la condizione non venga modificata da un altro thread mentre il primo thread è in attesa.
#text(9pt)[
  ```c
  pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);
  pthread_cond_signal(pthread_cond_t *cond);
  ```
]
- `pthread_cond_wait()`, mette il thread chiamante in attesa. Il thread rimane in attesa fino a quando un altro thread chiama la routine `pthread_cond_signal()` per indicare che la condizione è stata modificata.
- `pthread_cond_signal()`, sveglia uno o più thread che sono in attesa sulla condizione specificata.

È importante utilizzare le condition variable in modo appropriato per evitare problemi di sincronizzazione. Ad esempio, è importante assicurarsi che il lock sia acquisito prima di chiamare la routine `pthread_cond_wait()` e rilasciato dopo aver chiamato la routine `pthread_cond_signal()`.