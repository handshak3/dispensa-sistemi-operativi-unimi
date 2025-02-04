== Multi-Level Feedback Queue

Obbiettivi:
- Ottimizzare i tempi di consegna.
- Ridurre al minimo il tempo di risposta (rendere un sistema responsive).

MLFQ ha un numero di code distinte e ciascuna di queste ha un livello di priorità (priorità usata per stabilire il job da eseguire in un determinato momento). Quando più lavori si trovano nella stessa coda viene applicato il RR.

#figure(
  image("../../images/mlfq/mlfq.png", width: 60%),
  caption: [Esempio MLFQ.],
)

MLFQ assegna una priorità variabile (in base al comportamento del processo).
- Se un job effettua ripetutamente I/O manterrà la sua priorità (per renderlo interattivo).
- Se un job utilizza in modo intensivo la CPU verrà ridotto di priorità.

*Starvation*: se ci sono troppi lavori interattivi questi monopolizzano la CPU e quindi i processi più lunghi non riceveranno più tempo dalla CPU (non vengono eseguiti quindi "moriranno di fame”).

Come va impostato $s$ (indica la frequenza di cambiamento delle priorità):
- Se troppo alto: i job più lunghi soffrirebbero di starvation.
- Se troppo basso: i job interattivi potrebbero non ottenere una quota adeguata della CPU.

*Gaming*: prima che un quanto di pianificazione sia trascorso il programma va a fare I/O e quindi non viene abbassato di priorità.

Siccome un programma può cambiare il suo comportamento nel tempo, un programma che era precedentemente vincolato dalla CPU e attualmente diventa interattivo sarà penalizzato perché si troverà nella fascia di priorità più bassa.

Per impedire il gaming, lo scheduler tiene traccia del tempo utilizzato da un processo (*accounting*), una volta che il suo quanto verrà esaurito seguirà il suo abbassamento di priorità.

Con il comando `nice` è possibile aumentare e diminuire la priorità di lavoro.

=== Funzionamento

1. Se `Priorità(A) > Priorità(B)`: va in esecuzione prima `A` e poi `B`.
2. Se `Priorità(A) = Priorità(B)`: viene applicato RR.
3. Quando job entra nel sistema gli viene assegnata la priorità più alta.
4. Decisione:
  - Se il processo completa la sua esecuzione entro il quanto di tempo, esso termina o viene messo in attesa.
  - Se il processo non completa l'esecuzione entro il quanto di tempo, viene spostato nella coda a priorità inferiore (*accounting* del tempo impiegato dal processo: soluzione al gaming).
5. Dopo un tempo $s$, sposta tutti i job nel sistema nella coda con massima priorità (risolve la starvation e la dinamicità dei programmi).

#colbreak()