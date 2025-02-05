#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Lock-based concurrent data structure

=== Introduzione
Le strutture dati concorrenti utilizzano lock per garantire sicurezza nei thread e prevenire race conditions. Tuttavia, il modo in cui vengono applicati i lock influisce sia sulla correttezza che sulle prestazioni della struttura. L'obiettivo è trovare un equilibrio tra concorrenza e performance.

==== Problemi della concorrenza
- *Race Condition*: quando due o più thread accedono a una risorsa condivisa in modo non sincronizzato.
- *Deadlock*: situazione in cui due o più thread rimangono bloccati aspettando l'uno il lock dell'altro.
- *Starvation*: un thread non riesce mai ad ottenere il lock perché altri thread monopolizzano la risorsa.
- *Overhead dei lock*: un numero eccessivo di lock può rallentare l'esecuzione anziché migliorarla.

=== Contatori concorrenti
Un contatore è una struttura semplice, ma quando è condiviso tra più thread può causare problemi di concorrenza.

==== Contatore Senza Lock (non sicuro)

#text(size: 9pt)[
  ```c
  typedef struct __counter_t {
      int value;
  } counter_t;

  void increment(counter_t c) {
      c->value++; // NON ATOMICO
  }
  ```
]

Problema: Più thread possono modificare `value` contemporaneamente, generando risultati inaffidabili.

==== Contatore con Mutex (non scalabile)

#text(size: 9pt)[
  ```c
  typedef struct __counter_t {
      int value;
      pthread_mutex_t lock;
  } counter_t;

  void increment(counter_t c) {
      pthread_mutex_lock(&c->lock);
      c->value++;
      pthread_mutex_unlock(&c->lock);
  }
  ```
]

Vantaggio: Sicuro.

Svantaggio: Non scalabile su più CPU, poiché i thread devono aspettare il rilascio del lock.

==== Contatore Approssimato (scalabile)
- Divide il contatore in contatori locali per CPU.
- Ogni CPU aggiorna il proprio contatore locale, riducendo la contesa sul lock globale.
- Periodicamente, i valori locali vengono sommati in un contatore globale.

#text(size: 9pt)[
  ```c
  typedef struct __counter_t {
      int global;
      pthread_mutex_t glock;
      int local[NUMCPUS];
      pthread_mutex_t llock[NUMCPUS];
      int threshold;
  } counter_t;
  ```
]

Vantaggio: Scalabilità maggiore rispetto all'approccio con singolo lock.

Svantaggio: Il valore letto dal contatore potrebbe non essere sempre preciso.

=== Liste Concorrenti
Le liste concatenate devono gestire correttamente l'inserimento e la ricerca in modo sicuro.

==== Lista Concorrente con singolo Lock

#text(size: 9pt)[
  ```c
  typedef struct __list_t {
      node_t head;
      pthread_mutex_t lock;
  } list_t;

  int List_Insert(list_t L, int key) {
      pthread_mutex_lock(&L->lock);
      node_t new = malloc(sizeof(node_t));
      new->key = key;
      new->next = L->head;
      L->head = new;
      pthread_mutex_unlock(&L->lock);
      return 0;
  }
  ```
]
Vantaggio: Implementazione semplice.

Svantaggio: Scarsa scalabilità, poiché un solo thread può accedere alla lista alla volta.

==== Hand-over-Hand Locking
- Ogni nodo ha un lock separato.
- Durante l'attraversamento della lista, si acquisisce il lock del nodo successivo prima di rilasciare quello attuale.
Vantaggio: Maggiore concorrenza.
Svantaggio: Maggiore overhead per il numero elevato di lock/unlock.

=== Code Concorrenti
Le code sono strutture fondamentali nei sistemi concorrenti, utilizzate per buffer, scheduler, ecc.

==== Coda Concorrente con Doppio Lock
Anche chiamato (Michael-Scott Queue).
- Due lock separati: uno per la testa e uno per la coda.
- Permette di parallelizzare enqueue e dequeue.
#text(size: 9pt)[
  ```c
  typedef struct __queue_t {
      node_t head;
      node_t tail;
      pthread_mutex_t head_lock, tail_lock;
  } queue_t;
  ```
]
Vantaggio: Maggiore concorrenza rispetto alla coda con singolo lock.

Svantaggio: Più complessa da implementare.

=== Hash Table Concorrente
Una tabella hash concorrente consente accesso rapido agli elementi mantenendo la sicurezza nei thread.

==== Implementazione con Lock per Bucket
- Ogni bucket ha una sua lista concatenata con un lock separato.
- Questo permette accessi concorrenti a diversi bucket, migliorando le prestazioni.
#text(size: 9pt)[
  ```c
  typedef struct __hash_t {
      list_t lists[BUCKETS];
  } hash_t;
  ```
]
Vantaggio: Ottima scalabilità rispetto alla lista concatenata con singolo lock.

=== Two-Phase Locks
Strategia ibrida che combina:
1. Spin-wait breve se il lock sarà presto disponibile.
2. Passaggio in stato di sleep se il lock non viene acquisito rapidamente.

Utilizzato in Linux (futex) per evitare il consumo eccessivo di CPU nei lock lunghi.

=== Compare-and-Swap (CAS) vs. Test-and-Set
==== Test-and-Set
#text(size: 9pt)[
  ```c
  int TestAndSet(int ptr, int new) {
      int old = ptr;
      ptr = new;
      return old;
  }
  ```
]
Problema: Può causare attesa attiva prolungata (spin lock inefficiente).

==== Compare-and-Swap (CAS)
- Più potente di Test-and-Set.
- Cambia il valore solo se è ancora quello atteso, evitando race conditions.
#text(size: 9pt)[
  ```c
  bool CompareAndSwap(int ptr, int expected, int new_value) {
      if (ptr == expected) {
          ptr = new_value;
          return true;
      }
      return false;
  }
  ```
]
*Vantaggio*: Usato per lock-free synchronization.

#line()