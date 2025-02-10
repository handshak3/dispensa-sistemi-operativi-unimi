== Processi e gestione dei processi
*Multiprogrammazione*: migliora l'utilizzo della CPU e delle risorse del sistema, consentendo l'esecuzione simultanea di più processi. In un ambiente multiprogrammato, quando un processo è in attesa di risorse (ad esempio, I/O), la CPU viene assegnata ad un altro processo pronto per l'esecuzione. Questo approccio massimizza l'efficienza, riduce i tempi di inattività e aumenta la produttività complessiva del sistema.

Introduciamo alcuni concetti fondamentali della multiprogrammazione:
- *Time sharing*: prevede che il tempo di CPU sia “equamente” diviso fra i programmi in memoria. In questo modo sono in grado di risolvere i lunghi tempi di risposta del modello batch.
- *Real time sharing*: nei sistemi che adottano questa soluzione, la politica di scheduling (scelta del processo da eseguire) è differente. Alcuni processi vanno serviti prima di altri, basti pensare al programma che consente di controllare il volo di un aereo il quale avrà priorità massima (hard real time sharing). Il programma che regola il ritiro al bancomat ha priorità più bassa (soft real time sharing).

*Processo*: Un'istanza in esecuzione di un programma. Ogni processo ha il proprio spazio di indirizzo virtuale, il proprio set di registri e le proprie risorse di sistema. I processi sono gestiti dall'OS, che assegna loro le risorse di sistema e ne aggiorna lo stato.

*Process state*: Indica la fase corrente in cui si trova il processo in esecuzione. Comprende tutto ciò che può leggere e aggiornare un programma, inclusa la memoria del processo, lo spazio di indirizzamento, i registri, l'heap, lo stack e il codice.

=== Virtualizzazione CPU
L'OS virtualizza la CPU, in modo che il processo creda di avere più CPU a sua disposizione. Questo consente di dare l'impressione che più programmi vengano eseguiti contemporaneamente, mentre in realtà l'OS sta eseguendo e interrompendo i processi in sequenza.

*Policies*: Regole definite per prendere decisioni. Definiscono \"cosa è necessario fare\".

*Mechanisms*: Metodi o protocolli di basso livello che implementano una funzionalità. Determinano \"come fare qualcosa\".

Esempi:
- *Context switch* (meccanismo di time-sharing): Offre all'OS la possibilità di interrompere l'esecuzione di un programma e iniziare a eseguirne un altro sulla stessa CPU.
- *Scheduling policy*: dato un numero $n$ di programmi, definisce quale verrà eseguito per primo, determinando l'ordine di esecuzione.

*Meccanismi vs Policies:*
La differenza principale è che i meccanismi sono i mezzi per implementare una politica, mentre le politiche sono le regole che determinano come i meccanismi vengono utilizzati.

*Process Control Block (PCB)*: Una struttura dati che memorizza informazioni dettagliate per singolo processo. Include:
- Process ID (PID)
- Stato del processo (running, ready, waiting, etc.)
- Program Counter
- Registri della CPU
- Puntatore allo stack kernel
- Informazioni di scheduling
- Priorità del processo
- Puntatori alla memoria
- Informazioni sui file aperti
- Statistiche di utilizzo delle risorse

#figure(
  image("../../images/processes/pcb2.png"),
  caption: [Contenuto della PCB. @a2025_process],
)

=== API di processo comuni
- *`Create`*: Crea nuovi processi.
- *`Destroy`*: Distrugge forzatamente i processi.
- *`Wait`*: Attende la fine del processo.
- *`Miscellaneous Control`*: Metodi per sospendere un processo e poi riprenderlo.
- *`Status`*: Restituisce informazioni sullo stato (tempo di esecuzione, ecc.).

#figure(caption: [Loading from program to process.])[
  #image(
    "../../images/processes/loading from program to process.png",
    width: 70%,
  )
]

=== Creazione dei processi
Quando viene creato un processo, l'OS esegue le seguenti fasi:
1. Carica i dati statici nell'AS del processo.
2. Alloca memoria nello stack per i dati statici (ad esempio, parametri del `main()` e le variabili da inizializzare) e la fornisce al processo.
3. Inizializza gli I/O con tre descrittori di file aperti (input, output, errore).
4. Avvia il programma dal `main()`.
5. Trasferisce il controllo dalla CPU al processo creato.
6. Il processo inizia l'esecuzione.

=== Stati di esecuzione dei processi

- *Running*: Il processo è in esecuzione su un processore.
- *Ready*: Il processo è pronto per l'esecuzione, ma non è ancora in esecuzione.
- *Blocked*: Il processo è sospeso in attesa di un evento, come l'input utente o l'accesso a un file.
- *Zombie*: Il processo padre termina prima del processo figlio (il processo ha ancora un PID e un PCB). Per evitare ciò, il processo padre deve chiamare `wait()` per terminare insieme al figlio e pulire le strutture dati.

#figure(caption: [Process state transaction.])[
  #image("../../images/processes/process state transaction.png", width: 70%)
]

=== Task List o Process Table
La *task list* (o *process table*) è una struttura dati che tiene traccia di tutti i processi in esecuzione nel sistema.

#figure(
  image("../../images/processes/pcb.png"),
  caption: [Relazione tra PCB e process table. @a2025_process],
)

=== Kernel Stack
Il *kernel stack* è un buffer di memoria allocato dal kernel. Viene utilizzato per memorizzare le informazioni di stato del processo corrente. Spazio di memoria dedicato a ciascun processo quando si trova in modalità kernel, ovvero quando esegue chiamate di sistema o viene gestito direttamente dal sistema operativo.