#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Concurrency

*Thread*: è un sottoinsieme delle istruzioni di un processo, che può essere eseguito in maniera concorrente con altre parti di esso. Viene quindi suddiviso un processo in parti differenti, eseguite in maniera indipendente l'una dall'altra. L'obiettivo dei threads è quello di rendere più veloce l'esecuzione di un processo.

=== Programmi multi-thread

*Programma multi-thread*: ha più punti di esecuzione o PC. Per ogni thread ci sarà uno stack (memoria locale del thread).

I thread del programma condividono lo stesso address space e quindi i dati. Ognuno di essi ha il proprio stato che è privato (registri da ripristinare, quando si passa da un thread ad un altro avviene il context switching). Lo stato di questi è salvato nel TCB (Thread Control Blocks).

In un processo multithread, ogni thread viene eseguito in modo indipendente e ha il suo stack.

#figure(
  image("../images/concurrency/single thread and multi thread.png"),
  caption: [Single-Threaded And Multi-Threaded Address Spaces],
)
=== Strutture per i thread

*Thread-local storage (TLS)*: stack relativo a un thread. Consente di memorizzare dati in modo che siano accessibili solo a un thread specifico. Qualsiasi variabile allocata nello stack, parametri, valori di ritorno e altre cose che mettiamo sullo stack andranno nel TLS per separare i singoli stack.

Perché usare i thread:
- *Parallelismo:* i thread possono essere utilizzati per eseguire più attività contemporaneamente, il che può migliorare le prestazioni del programma se il sistema ha più di un processore.
- *Evitare il blocco del programma a causa di I/O lente:* i thread possono essere utilizzati per eseguire altre attività mentre un thread è bloccato in attesa di un'operazione di I/O lenta. (overlap)
- *Facile condivisione dei dati:* I thread condividono lo stesso spazio di memoria, il che rende facile la condivisione dei dati tra di loro.

=== Creazione dei thread

#figure(caption: [Creazione di thread.])[
  #text(size: 9pt)[
    ```c
    #include <stdio.h>
    #include <stdlib.h>
    #include <pthread.h>
    #include "common.h"
    #include "common_threads.h"

    void *mythread(void *arg) {
        printf("%s\n", (char *) arg);
        return NULL;
    }

    int main(int argc, char *argv[]) {
        if (argc != 1) {
                fprintf(stderr, "usage: main\n");
                exit(1);
        }

        pthread_t p1, p2;
        printf("main: begin\n");
            // Attesa completamento dei thread
            // Non è detto che "A" sia stampata prima di "B", dipende dallo scheduler
            // Pthread_create() chiama pthread_create() e si assicura che ritorni zero,
        // in caso contrario viene stampato un messaggio nello stderr.

        Pthread_create(&p1, NULL, mythread, "A");
        Pthread_create(&p2, NULL, mythread, "B");
        // join waits for the threads to finish
        Pthread_join(p1, NULL);
        Pthread_join(p2, NULL);
        printf("main: end\n");
        return 0;
    }
    ```
  ]
]

Il programma crea due thread, che eseguono la funzione `mythread()` con argomenti diversi (le stringhe A o B).

- Il thread può iniziare a essere eseguito immediatamente o essere messo in uno stato di "pronto" ma non "in esecuzione" e quindi non ancora eseguito.
- Su un multiprocessore, i thread potrebbero anche essere eseguiti contemporaneamente.
- Il thread principale chiama `Pthread_join()`, che attende il completamento di un particolare thread. Lo fa due volte, assicurando che T1 e T2 vengano eseguiti e completati prima di consentire al thread principale di eseguire di nuovo.

Ecco i possibili ordini di esecuzione del programma:
- Il thread principale viene eseguito prima, seguito da Thread 1 e Thread 2.
- Thread 1 viene eseguito prima, seguito dal thread principale e Thread 2.
- Thread 2 viene eseguito prima, seguito dal thread principale e Thread 1.

Non è possibile sapere in anticipo quale ordine di esecuzione si verificherà, poiché dipende dal programma di schedulazione dell?OS.

Questo esempio mostra che i thread possono rendere difficile prevedere il comportamento di un programma. È importante essere consapevoli di questo quando si scrive codice multithread.

=== Dati in condivisione
#figure(caption: [Esempio di codice con dato condiviso.])[
  #text(size: 9pt)[
    ```c
    #include <stdio.h>
    #include <stdlib.h>
    #include <pthread.h>

    #include "common.h"
    #include "common_threads.h"

    int max;
    static volatile int counter = 0; // shared global variable

    void *mythread(void *arg) {
        char *letter = arg;
        int i; // stack (private per thread)
        printf("%s: begin [addr of i: %p]\n", letter, &i);
        for (i = 0; i < max; i++) {
            counter = counter + 1; // shared: only one
        }
        printf("%s: done\n", letter);
        return NULL;
    }

    int main(int argc, char *argv[]) {
        if (argc != 2) {
            fprintf(stderr, "
                usage: main-first <loopcount>\n
            ");
            exit(1);
        }
        max = atoi(argv[1]);

        pthread_t p1, p2;
        printf("main: begin [counter = %d] [%x]\n", counter,
        (unsigned int) &counter);
        Pthread_create(&p1, NULL, mythread, "A");
        Pthread_create(&p2, NULL, mythread, "B");
        // join waits for the threads to finish
        Pthread_join(p1, NULL);
        Pthread_join(p2, NULL);
        printf("main: done\n [counter: %d]\n [should: %d]\n",
        counter, max*2);
        return 0;
    }
    ```
  ]
]

Il programma crea due thread che tentano di aggiornare una variabile condivisa, counter. La variabile counter è inizialmente impostata a 0.

I thread eseguono un loop in cui incrementano counter di 1. Il numero di volte che il loop viene eseguito è 10 milioni (1e7). Il risultato desiderato è che counter sia impostata a 20 milioni (20000000) alla fine del programma. Tuttavia, il programma non sempre produce il risultato desiderato. A volte, il valore finale di counter è diverso da 20 milioni. Ad esempio, il valore finale può essere 19345221 o 19221041. Il motivo di questo comportamento è che i thread accedono alla variabile counter contemporaneamente. Quando due o più thread accedono alla stessa variabile condivisa, si verifica una condizione nota come *race condition*. In una race condition, il risultato dell'esecuzione del programma dipende dall'ordine in cui i thread accedono alla variabile condivisa.

In questo caso, il risultato dell'esecuzione del programma dipende dall'ordine in cui i thread incrementano counter nel loop. Se il thread A incrementa counter prima del thread B, il valore finale di counter sarà maggiore di 20 milioni. Se il thread B incrementa counter prima del thread A, il valore finale di counter sarà minore di 20 milioni. Per evitare le race condition, è necessario utilizzare meccanismi di sincronizzazione. I meccanismi di sincronizzazione consentono di coordinare l'accesso dei thread alle variabili condivise.

Se un thread dopo aver incrementato il contatore viene interrotto e l'OS fa context switching, parte il secondo thread ed esegue le tre istruzioni salvando l'incremento in memoria. T2 viene interrotto, T1 riprende il controllo ed esegue l'ultima istruzione rimanente ma nel suo stato il contatore vale uno in meno e salva quest'ultimo. In sostanza il codice viene eseguito due volte ma il contatore definitivamente è incrementato solamente di un'unità.

*Race condition*: condizione di errore che si verifica quando due o più thread accedono alla stessa variabile condivisa contemporaneamente e il risultato dell'esecuzione del programma dipende dall'ordine in cui i thread accedono alla variabile.

*Critical section*: pezzo di codice che accede ad una variabile condivisa tra i thread.

*Esclusione reciproca (mutual exclusion)*: garantisce che gli altri thread non possano eseguire una critical section se un thread è già in esecuzione in quell'area.

*Atomicità*: un'operazione o un insieme di operazioni di un programma eseguite interamente senza essere interrotte prima della fine del loro corso. Questo concetto si applica a una parte di un programma di cui il processo o il thread che lo gestisce non cederà il monopolio su determinati dati a un altro processo durante tutto il corso di questa parte.

*Transazione*: raggruppamento di molte azioni in un'unica azione atomica.

*Programma indeterminato:* consiste in una o più race condition; l'output del programma varia da esecuzione a esecuzione, a seconda di quali thread sono stati eseguiti quando. Il risultato non è quindi deterministico.

#colbreak()