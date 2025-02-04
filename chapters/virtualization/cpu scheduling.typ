== CPU scheduling

*Burst*: intervallo di tempo in cui viene usata intensamente una risorsa. Il CPU Burst, ad esempio, è un'intervallo di tempo $t$ in cui si ha un elevato utilizzo del processore. Per l'I/O Burst vale la stessa definizione in termini di dispositivi di input/output. Da ciò possiamo estrapolare altre due definizioni di classi funzionali di processi, che sono:
- *CPU Bound*: processi con CPU Burst lunghi, ad esempio compilatori, simulatori, calcolo del tempo, ecc...
- *I/O Bound*: con l'avvento dei microcomputer si introduce anche questa necessità. Sono processi con I/O Burst lunghi, ciò comporta maggiore interattività con l'utente.

Un processo in esecuzione si trova o in CPU Burst o in I/O Burst. Mentre un processo viene eseguito sulla CPU, non fa I/O e mentre fa I/O non può essere eseguito dal processore. Lo scheduler deve fare in modo che CPU e dispositivi I/O siano sempre impegnati. Vogliamo evitare che una risorsa entri in uno stato chiamato di IDLE, in cui è accesa e funzionante ma non utilizzata. In questo modo siamo in grado di aumentare l'efficienza, riducendo gli sprechi di tempo.

*Workload:* processi in esecuzione nel sistema.

Metriche di pianificazione usata per misurare l'efficienza:
- *Tempi di consegna (prestazioni)*: il momento in cui il lavoro viene completato meno il momento in cui il lavoro è arrivato nel sistema. $ T_"turn around"=T_"completion"-T_"arrival" $
- *Equità*: il principio di trattare in modo giusto e bilanciato i processi in esecuzione sulla CPU. Uno scheduler può ottimizzare le prestazioni a costo di impedire l'esecuzione di alcuni jobs (diminuzione dell'equità).

Supponiamo che (assunzioni):
1. Ogni lavoro viene eseguito per la stessa quantità di tempo.
2. Tutti i lavori arrivano contemporaneamente ($T_"arrival" = 0$).
3. Una volta avviato, ogni lavoro viene eseguito fino al completamento.
4. Tutti i lavori utilizzeranno solo la CPU (non eseguono I/O).
5. Il tempo di esecuzione di ogni lavoro è noto.

=== First In, First Out (FIFO)

Politica anche chiamata First Come, First Served (FCFS).

Esegue i job seguendo l'ordine di arrivo.

Ordine di arrivo: 1° $A$(10s) , 2° $B$(10s), 3° $C$(10s).

Tempi di consegna:
- $T_("turn around")(A) = 10 - 0 = 10$
- $T_("turn around")(B) = 20 - 0 = 20$
- $T_("turn around")(C) = 30 - 0 = 30$
- Tempo medio di consegna: $(10+20+30)/3=20$

#figure(
  caption: [FIFO simple example],
  image("../../images/scheduling/fifo.png", width: 70%),
)
*Vantaggi*: semplice e facile da implementare.

*Problema*: supponiamo che il job $A$ abbia un tempo di esecuzione maggiore di quello di $B$ e $C$ (negazione assunzione 1).

Ordine di arrivo: 1° $A$(100s) , 2° $B$(10s), 3° $C$(10s).

Tempo medio di consegna: $(100+110+120)/3=110$

*Convoy effect* (effetto convoglio): un numero di processi relativamente brevi capitano in coda dietro un processo più lungo.

#figure(
  caption: [Convoy Effect example.],
  image("../../images/scheduling/convoy effect.png", width: 70%),
)

=== Shortest Job First (SJF)

Ottimizza i tempi di risposta ed evita il convoy effect. Esegue il workload con CPU burst minore, poi il successivo più breve e così via.

Ordine di arrivo: 1° $A$ (100s) , 2° $B$ (10s), 3° $C$ (10s).

Tempi di consegna:
- $T_("turn around")(A) = 10 - 0 = 10$
- $T_("turn around")(B) = 20 - 0 = 20$
- $T_("turn around")(C) = 120 - 0 = 30$
- Tempo medio di consegna: $(10+20+120)/3=50$

#figure(
  caption: [SJF simple example.],
  image("../../images/scheduling/sjf.png", width: 70%),
)

*Problema*: i lavori non arrivano tutti inseme (negazione dell'assunzione 2). Se un workload con burst CPU corto arriva quando la CPU è occupata con un workload con CPU più lungo, il convoy effect è ancora presente.

Ordine di arrivo: 1° $A$ (t=0, 100s) , 2° $B$ (t=10, 10s), 3° $C$ (t=10, 10s).

$B$ e $C$ anche essendo arrivati leggermente dopo di $A$ sono comunque costretti ad aspettare $A$.

Tempo medio di consegna: $(100 + (110-10)+(120-10))/3=103,33$

#figure(
  caption: [SJF with late arrivals from B and C.],
  image("../../images/scheduling/sjf example.png", width: 75%),
)

Nuova metrica: *tempo di risposta* $ T_"response"=T_"first turn"-T_"arrival" $

Tempi di risposta:
- $T_("response")(A) = 0 - 0 = 0$
- $T_("response")(B) = 100 - 10 = 90$
- $T_("response")(C) = 110 - 10 = 100$
- $T_("response AVG") = (0 + 90 + 100) / 3 = 63,33$

È anche uno scheduler *non preventivo* e in quanto tale porta a termine i processi fino al completamento.

*Non-preemptive scheduler*: non interrompe un processo in esecuzione per pianificare un altro processo.

*Preemptive scheduler*: capace di interrompere un processo in esecuzione per assegnare la CPU a un altro processo con priorità maggiore o più urgente.

=== Shortest Time to Completation First (STCF)

Come SJF ma ottimizza i tempi di risposta. Ogni volta che un job entra nel sistema, lo scheduler determina quale job ha il minor tempo rimanente e lo schedula. Quindi anticipa l'esecuzione di B e C.

Ordine di arrivo: 1° A (t=0, 100s) , 2° B (t=10, 10s), 3° C (t=10, 10s).

Tempi di consegna:
- $T_("turn around")(A) = 120 - 0 = 120$
- $T_("turn around")(B) = 20 - 10 = 10$
- $T_("turn around")(C) = 30 - 10 = 20$
- Tempo medio di consegna: $(120+10+20)/3=50$

Tempi di risposta:
- $T_("response")(A) = 0 - 0 = 0$
- $T_("response")(B) = 10 - 10 = 0$
- $T_("response")(C) = 20 - 10 = 10$
- $T_("response AVG") = (0 + 0 + 10) / 3 = 3,33$

#figure(
  caption: [SJF simple example.],
  image("../../images/scheduling/stcf.png", width: 70%),
)

*Problema*: la policy non è efficace perché i job effettuano anche operazioni di I/O e con si conosce quanto sarà effettivamente il loro tempo di consegna.

=== Round Robin (RR)
Risolve il problema dell'equità, il convoy effect e il problema della responsività.

È uno scheduler *preventivo*: esegue i job per intervallo di tempo (*quanto di pianificazione*) grazie all'interrupt time. La durata di un quanto di pianificazione deve essere un multiplo del time di interrupt.

*Problema*: rendere $T_"response"$ troppo corto perché sarebbe troppo oneroso per le risorse dato il context switch.

Ordine di arrivo: 1° A (t=0, 5s) , 2° B (t=0, 5s), 3° C (t=0, 5s).

Tempi di consegna:
- $T_("turn around")(A) = 13 - 0 = 13$
- $T_("turn around")(B) = 14 - 0 = 14$
- $T_("turn around")(C) = 15 - 0 = 15$
- Tempo medio di consegna: $(13+14+15)/3=14$ (troppo)

Tempi di risposta:
- $T_("response")(A) = 0 - 0 = 0$
- $T_("response")(B) = 10 - 0 = 10$
- $T_("response")(C) = 20 - 0 = 20$
- $T_("response AVG") = (0 + 10 + 20) / 3 = 10$

#figure(
  caption: [RR simple example.],
  image("../../images/scheduling/rr.png", width: 80%),
)

=== Integrazione dell'I/O

Un processo necessariamente ha bisogno di I/O (negazione assunzione 4).

#figure(
  image("../../images/scheduling/no overlap.png", width: 80%),
  caption: [RR senza overlap.],
)

- Job A = 50 ms (ogni 10 ms effettua una richiesta I/O con una durata di 10 ms).
- Job B = 50 ms (non effettua I/O).

Tempi di consegna
- $T_("turn around")(A)= 90 - 0 = 90$
- $T_("turn around")(B)= 140 - 0 = 140$
- $T_("turn around AVG")= (90 + 140) / 2 = 115$

Tempi di risposta
- $T_("response")(A)= 0 + 0 = 0$
- $T_("response")(B)= 90 + 0 = 90$
- $T_("response AVG")= (0 + 90) / 2=45$

Quando un job effettua operazioni di I/O non utilizzerà la CPU e quindi lo scheduler dovrebbe pianificare un altro job in attesa che quello precedente si sblocchi.

Quando l'operazione di I/O viene completata sarà generato un interrupt che metterà quel job nello stato “ready”.

Funzionamento delle *overlap*:

Uno scheduler STCF tratta ogni lavoro secondario (10 ms) di A come un lavoro indipendente (tiene conto delle operazioni I/O e viene suddiviso in più jobs).

Parte prima un sub-job di A (10 ms), quando A fa I/O può partire B (per un quanto di pianificazione) contemporaneamente alle operazioni I/O di A (che non utilizza la CPU per fare I/O).

#figure(
  caption: [Overlap allows better use of resources.],
  image("../../images/scheduling/overlap.png", width: 80%),
)

Tempi di consegna
- $T_("turn around")(B)= 100 - 0 = 100$
- $T_("turn around AVG")= (90 + 100) / 2 = 80$
- $T_("turn around")(A)= 90 - 0 = 90$

Tempi di risposta
- $T_("response")(A)= 0 + 0 = 0$
- $T_("response")(B)= 10 + 0 = 10$
- $T_("response AVG")= (0 + 10) / 2=5$

=== Formulario

*Turnaround Time*

$T_"turnaround" = T_"completion" - T_"arrival"$

*Turnaround Time Medio*

$T_"turnaround"_"avg" = (sum_(i=1)^n T_"turnaround"_i) / n$

*Response Time*

$T_"response" = T_"first turn" - T_"arrival"$

*Response Time Medio*

$T_"response"_"avg" = (sum_(i=1)^n T_"response"_i) / n$

*Waiting Time*

$T_"wait" = T_"turnaround" - T_"run time"$

*Wait Time Medio*

$T_"wait"_"avg" = (sum_(i=1)^n T_"wait"_i) / n$

=== Cheatsheet

*First In, First Out (FIFO) / First Come, First Served (FCFS)*
- Ordina i job in base all'ordine di arrivo.
- *Vantaggi*: Semplice da implementare.
- *Svantaggi*: Convoy effect, penalizza i processi brevi.

*Shortest Job First (SJF)*
- Esegue per primo il job con CPU Burst più corto.
- *Formula del Turnaround Time Medio*:
- *Vantaggi*: Minimizza il turnaround time medio.
- *Svantaggi*: Se i job non arrivano simultaneamente, può causare starvation.

*Shortest Time to Completion First (STCF)*
- Simile a SJF, ma preemptive: può interrompere un processo se arriva uno più corto.
- *Vantaggi*: Riduce il response time rispetto a SJF.
- *Svantaggi*: Difficile da implementare, richiede conoscenza del tempo rimanente.

*Round Robin (RR)*
- Assegna la CPU per un quantum di tempo fisso e poi passa al job successivo.
- *Vantaggi*: Equo, garantisce un buon response time per processi interattivi.
- *Svantaggi*: Se il quantum è troppo breve, aumenta il numero di context switch.

#colbreak()