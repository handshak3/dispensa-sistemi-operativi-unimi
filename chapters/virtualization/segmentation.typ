#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Segmentation

*Binding*: durante il processo rilocazione vengono cambiati tutti gli indirizzi del programma (anche le jump) per evitare che vadano fuori dallo spazio di indirizzamento previsto. Il binding è l'operazione che viene fatta per modificare gli indirizzi. Può essere:

- *Early binding*: riallocazione degli indirizzi fatta a compile time. Il compilatore deve conoscere la posizione di partenza del programma in memoria (informazione che, generalmente, non possiamo conoscere a priori). Questo meccanismo funziona solamente nei sistemi embedded, dove il compilatore genera direttamente il codice assoluto, oppure nei sistemi monoprogrammati.

- *Delayed binding*: la riallocazione degli indirizzi viene fatta durante il trasferimento (loading) del programma da disco a memoria. Quest'operazione viene quindi svolta dal sistema operativo ed è quella che veniva adottata prima dell'introduzione dell'MMU.

- *Late binding*: la riallocazione degli indirizzi viene fatta immediatamente prima di eseguire l'istruzione corrente, quindi a runtime. Occorre il dovuto supporto hardware (MMU) per poter implementare questa tecnica. Durante la fase di decodifica del programma, gli indirizzi relativi vengono cambiati in indirizzi assoluti. Questo meccanismo è alla base della virtualizzazione della memoria.

*Problema*: lo spazio allocato per la crescita di stack e heap, se non utilizzato e se si adotta la tecnica del base-and-bounds, costituisce uno spreco di memoria.

Prima di proseguire è bene introdurre alcune assunzioni:
- Il programma viene caricato in locazioni di memoria contigue.
- L'address space è minore della memoria fisica.
- L'address space ha dimensione fissata (assunzione già superata con base e bound).

Nel meccanismo base e bound, quando un processo viene caricato in memoria, il sistema operativo mette il punto di partenza all'interno del registro base. Durante la fase di decodifica delle istruzioni viene fatto il binding:
$ "Indirizzo fisico (PA)" = "Indirizzo logico (VA)" + "Base" $


=== Segmantazione
*Segmantazione*: suddivisione della memoria in blocchi chiamati segmenti con il fine di ottimizzare la gestione degli spazi vuoti (tra stack e heap) di un processo nel suo address space. La segmentazione è un approccio *dinamico* di allocazione della memoria. Questo significa che i processi possono richiedere e rilasciare memoria durante l'esecuzione. Invece di una sola coppia base-and-bounds per MMU, si utilizza una coppia base-and-bounds per ogni singolo segmento. La segmentazione consente all'OS di posizionare i segmenti in parti diverse della memoria fisica, evitando di riempire la memoria fisica con l'address space virtuale inutilizzato. Solo la memoria utilizzata è allocata in memoria fisica.

Il meccanismo funziona come segue:

Input: indirizzo logico $B$.
+ Individua il segmento $s$ di appartenenza dell'indirizzo $B$.
+ Calcola l'offset $k$ sottraendo all'indirizzo virtuale l'indirizzo di partenza (logico) del segmento ($k = B - "indirizzo iniziale di" s$).
+ Viene calcolato l'indirizzo fisico sommando k e il base register ($"PA" = "Base(s)" + k$).

L'offset è la distanza l'inizio del segmento e l'indirizzo logico

==== Esempio di traduzione di un indirizzo

#figure(
  image("../../images/segmentation/segmentation ex.png", width: 60%),
  caption: [Esercizio: Segment table.],
)

*Esercizio 2*
Input:
- Indirizzo virtuale (offset): $100$

Calcoli:
- Indirizzo base: $32 "kb"$
- indirizzo fisico: $100 + 32 "kb" = 32*1024 + 100 = 32868$
- Verifica che rientri nei limiti: $100 < 2 "kb"$.

*Esercizio 2*
Input:
- Indirizzo virtuale: $4200$

Calcoli:
- Inizio heap (virtuale): $4"kb"$
- Estrazione offset: $4"kb"*1024-4200 = 104$
- Indirizzo fisico: $34"kb" *1024 + 104 = 34920$

*Steps per la conversione di Indirizzi Virtuali*

Input: VA, segment table e virtual start.

+ Identificazione del segmento: determinare in quale segmento si trova il VA (codice, heap, stack, ecc.) usando la segment table valutando in quale range di indirizzi si trova il VA.

+ Estrazione dell'offset:
  - Se il segmento parte da VA=0: non occorre calcolare l'offset.

  - Se il segmento cresce in positivo:\
    $"offset" = "VA" - "virtual_start"("segmento")$

  - Se il segmento cresce in negativo:\
    $"offset" = "size_of"("segmento") - ("virtual_start"("segmento") - "VA")$

+ Controllo validità dell'offset:\
  $"offset" < "size_of"("segmento")$

+ Calcolo dell'Indirizzo fisico\
  $"PA" = "base" + "offset"$

*Nota bene*: Lo stack cresce in negativo e l'heap in positivo.

*Code sharing*: Pratica comune nei moderni sistemi operativi che consente di condividere certi segmenti tra gli address spaces, risparmiando memoria.

L'hardware conoscere il segmento a cui si sta riferendo utilizzando:
- *Approccio esplicito*
- *Approccio implicito*

==== Approccio esplicito

Divide lo spazio degli indirizzi in segmenti basati sui primi bit dell'indirizzo virtuale.

#figure(
  image("../../images/segmentation/seg mem1.png", width: 70%),
  caption: [Blocco di memoria a 14 bit.],
)

In un AS grande $1k$ abbiamo bisogno di $10$ bit per indirizzare tutti i byte. Il calcolo è $log_2 1024 = 10 "bit"$ e in generale:
$ceil(log_2 "<size_of_AS>")$

*Esempio*: per selezionare un segmento, supponendo di averne tre a disposizione (codice heap, stack), occorrono 2 bit.

- *00*: l'hardware sa che il virtual address si trova nel segmento *codice*.
- *01*: l'hardware sa che il virtual address si trova nel segmento *heap* ecc.

L'offset facilita il controllo dei limiti perché si controlla che l'offset (in valore assoluto) sia inferiore ai limiti.

*Problemi*

- Se abbiamo a disposizione solamente 3 segmenti una combinazione di bit non viene utilizzata ($2^2 = 4$ combinazioni di bit). Alcuni mettono codice e heap nello stesso segmento e accedono solamente con due combinazioni.
- Limita l'uso dello spazio degli indirizzi virtuali: ogni segmento ha una dimensione massima (un segmento non può crescere di dimensione).

==== Approccio implicito

L'hardware determina a quale segmento l'indirizzo fa riferimento in base a come è stato formato.

- Se è stato generato dalla fetch appartiene al segmento *codice*.
- Se l'indirizzo è basato sullo stack o sul base pointer, fa riferimento allo *stack*.
- Altrimenti tutti gli indirizzi rimanenti fanno parte dell'*heap*.

Oltre ad avere base-and-bounds all'hardware occorre sapere se il segmento cresce in positivo o in negativo.

Per risparmiare memoria è utile condividere determinati segmenti (specialmente il codice) tra gli address space. Il *bit di protezione* è stato introdotto per questo. Il registro base utilizza questo bit per ogni segmento e indica se un programma può leggere, scrivere o eseguire un segmento. Lo stesso segmento fisico di memoria poterebbe essere mappato in più address space virtuali. L'hardware deve verificare i bit di protezione quando un processo accede a un segmento.

#figure(
  image("../../images/segmentation/segment reg with growth support.png"),
  caption: [Segment registers with growth support.],
)

=== Problematiche della segmentazione

*Fine-grained-segmentation*: l'address space è suddiviso in un numero maggiore di segmenti. Questo consente all'OS di gestire la memoria in modo più granulare e di allocare e deallocare la memoria in modo più efficiente.

*Coarse-grained-segmentation*: address space suddiviso in un numero minore di segmenti. Questo è più semplice da implementare hardware e software, ma non è così efficiente come la segmentazione fine-grained.

*Segment table*: struttura dati che mantiene le informazioni sui segmenti di un processo. Ogni segmento è rappresentato da un record nella tabella dei segmenti, che include l'indirizzo base del segmento, la dimensione del segmento e le flag di protezione. Supporta la creazione di un numero molto elevato di segmenti.

#figure(
  image("../../images/segmentation/segmentation.png"),
  caption: [Schema di traduzione. @lavecchia_2020_differenza],
)

Problemi della segmentazione:
- *Salvataggio e ripristino dei registri di segmento*: I'OS deve salvare e ripristinare i registri di segmento quando avviene un cambio di contesto. Questo perché ogni processo ha il proprio spazio di indirizzi virtuali e l'OS deve assicurarsi che i registri siano impostati correttamente prima che il processo venga eseguito di nuovo.
- *Creazione e gestione dei segmenti*: l'OS deve creare e gestire i segmenti per ogni processo. Questo include la creazione di nuovi segmenti, la crescita e la contrazione dei segmenti, e la deallocazione dei segmenti non più necessari. La `malloc()` alloca spazio, la system call `sbrk()` (obsoleta ma ancora supportata) aumenta o riduce la dimensione del segmento heap. Ora si utilizza `mmap()`.
- *Gestione della memoria libera*: l'OS deve gestire la memoria libera in modo efficiente. Questo include la riallocazione della memoria libera quando i processi vengono creati, eliminati o quando i segmenti crescono o si contraggono.

*Frammentazione esterna*: problema che si verifica quando la memoria libera dell'AS è frammentata in piccoli parti che non sono abbastanza grandi per soddisfare una richiesta di allocazione di memoria.

*Deframmentazione*: operazione complessa e dispendiosa in cui l'OS compatta la memoria fisica riarrangiando i segmenti esistenti. Per eseguirla, il sistema deve fermare tutti i processi in esecuzione, copiare i loro dati in una regione contigua di memoria, e aggiornare i segment registers affinché puntino alle nuove locazioni. Questo processo consente di ottenere un ampio spazio libero contiguo, ma è bloccante, poiché durante l'operazione nessun programma può essere eseguito.

Ci sono due approcci principali per gestire la frammentazione esterna:
- *Compaction*: consiste nel riorganizzare i segmenti in memoria in modo che i frammenti di memoria libera siano contigui. Questo può essere fatto fermando i processi che sono in esecuzione, copiando i loro dati in una regione di memoria contigua, e quindi aggiornando i registri di segmento dei processi per puntare alle nuove posizioni fisiche. Approccio molto costoso.
- *Gestione della free list*: consiste nel mantenere una lista di tutti i frammenti di memoria libera. Quando viene fatta una richiesta di allocazione di memoria, l'OS cerca il frammento di memoria più grande che è abbastanza grande per soddisfare la richiesta. Meno costosa ma non efficiente.

#figure(
  image("../../images/segmentation/frammentazione.png", width: 80%),
  caption: [Esempio di come la memoria fisica viene trasformata con la compaction.],
)