#pagebreak()

= Introduzione ai sistemi operativi

*Operative System (OS)*:
- Responsabile dell'esecuzione dei programmi.
- Consente ai programmi di condividere memoria.
- Garantisce il corretto e efficiente funzionamento del sistema, rendendo l'uso facile per l'utente.

=== Processi
Un processo, informalmente, altro non è che un programma in esecuzione. Un programma, a sua volta, è una sequenza finita di istruzioni scritte in un linguaggio comprensibile all'esecutore (nel nostro caso la CPU). L'esecuzione di un programma da parte del processore è concettualmente semplice:

+ *Fetch*: viene prelevata l'istruzione dalla memoria.
+ *Decode*: viene decodificata l'istruzione per renderla comprensibile alla cpu.
+ *Execute*: viene eseguita l'istruzione, ora in linguaggio macchina.

=== Virtualizzazione
Per svolgere i suoi compiti, l'OS utilizza la *virtualizzazione*, che astrae le risorse fisiche in risorse più generali. L'OS è anche chiamato macchina virtuale, e l'utente può interagire con esso tramite API o *System Calls* disponibili alle applicazioni. Fornisce librerie standard per gestire le risorse. La virtualizzazione permette l'esecuzione di molti programmi, e l'OS si occupa di gestire le risorse condivise tra tutti i programmi.

Tipi di Virtualizzazione:
- *Virtualizzazione della CPU*: Consiste nel trasformare una CPU fisica in un numero apparentemente infinito di CPU virtuali, consentendo ai programmi di funzionare in parallelo, apparentemente in contemporanea.

- *Virtualizzazione della memoria*: La memoria nelle macchine moderne è vista come un array di byte. Per accedere alla memoria, è necessario specificare un indirizzo. Inoltre, per scrivere in memoria, oltre all'indirizzo, è necessario specificare anche i dati. Ogni processo ha il proprio spazio privato di indirizzi virtuali che l'OS mappa sulla memoria fisica.

*Policies*: Un insieme di regole che governano il comportamento dell'OS e delle applicazioni che lo eseguono.

*Mechanisms*:
Procedure o strumenti specifici tramite i quali le politiche vengono attuate o implementate.

=== Concurrency
La concorrenza è la capacità di eseguire più programmi contemporaneamente, utile per migliorare le prestazioni eseguendo più processi o thread in parallelo.

*Thread*:
Una funzione in esecuzione all'interno dello stesso spazio di memoria di altre funzioni, che permette più attività contemporaneamente.

=== Persistence
La persistenza è la capacità di mantenere le informazioni anche dopo che il computer è stato spento. Questo viene fatto salvando le informazioni su dispositivi di archiviazione persistenti, come un disco rigido o un'unità flash.

=== Sicurezza

Un modello di protezione implementato dal sistema operativo è quello ad anelli. Vengono creati 5 livelli differenti e tre anelli differenti. A ciascun anello corrisponde un relativo livello di sicurezza. Solo chi ha i permessi per operare in un certo anello può eseguire codice in esso.

- *Level 1, hardware level*: qui vengono eseguiti, ad esempio, i device drivers visto che essi richiedono accesso diretto all'hardware dei dispositivi. Questo dispositivo è quindi il microcontroller (es: motherboard chipset, disk drivers, SATA, IDE, ard drives, processor, ecc... tutti questi hanno controller che risiedono quindi al livello 1) che controlla fisicamente un device.
- *Level 2, firmware level*: il firmware sta in cima al livello elettronico. Contiene il software necessario dal dispositivo hardware e dal micocontroller. Questo livello contiene quindi firmware sviluppato in microcode. Il microcode viene generalmente memorizzato in una memoria ROM.
- *Level 3, ring 0 o kernel level*: è il livello dove opera il kernel, dopo quindi la fase di bootload siamo qui.
- *Level 4, ring 1 e 2 o device drivers*: i device drivers passano attraverso il kernel per accedere all'hardware. Queste porzioni di codice per funzionare bene hanno bisogno di molta libertà senza però che essi possano andare a modificare componenti che causerebbero un crash (come ad esempio la GDT), questo è il motivo per cui sono eseguiti al ring 1 e 2 e non al ring 0.
- *Level 5, ring 3 o application level*. Qui è dove viene eseguito normalmente il codice utente, attraverso l'uso delle API del sistema o le interfacce driver.

#figure(
  image("../images/introduction/security.png"),
  caption: [Livelli di sicurezza.],
)

#colbreak()