#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Translation Lookaside Buffer
Siccome le informazioni di mappatura risiedono generalmente in memoria fisica, la paginazione richiede un accesso aggiuntivo per ogni indirizzo virtuale generato dal programma. È necessario consultare la page table (in memoria centrale), prima che un'istruzione sia effettivamente prelevata (fetch) o prima che avvenga un accesso esplicito (load-store), il che rende il meccanismo della paginazione poco performante.

L'obiettivo è snellire la tecnica introdotta, cercando di diminuire il numero di accessi a memoria fisica (alla page table).

*TLB (Translation Lookaside Buffer)*: cache hardware che risiede nell'MMU e contiene le traduzioni da virtuali a fisiche più popolari. Sono utilizzate per accelerare la traduzione da VA a PA e per ridurre gli accesi alla page table. Quando il processore deve accedere a un indirizzo virtuale, prima controlla la TLB per vedere se la traduzione è presente. Se la traduzione è presente, il processore può accedere direttamente alla memoria fisica senza dover consultare la tabella delle pagine.

=== Vantaggi e svantaggi TLB
*Vantaggi delle TLB*
- Le TLB possono accelerare la traduzione dell'indirizzo virtuale in indirizzo fisico.
- Le TLB possono ridurre il numero di accessi alla memoria.
- Le TLB possono migliorare le prestazioni dei sistemi che utilizzano la virtualizzazione della memoria.

*Svantaggi delle TLB*
- Le TLB sono cache e quindi possono contenere traduzioni non aggiornate.
- Le TLB possono essere di dimensioni limitate e quindi non possono memorizzare tutte le traduzioni.
- Le TLB possono essere inefficienti per le traduzioni che vengono utilizzate raramente.

=== Funzionamento del TLB
#figure(caption: [Implementazione del TLB.])[
  #text(size: 9pt)[
    ```c
    VPN = (VirtualAddress & VPN_MASK) >> SHIFT
    (Success, TlbEntry) = TLB_Lookup(VPN)
    if (Success === True) // TLB Hit
    		if (CanAccess(TlbEntry.ProtectBits) === True)
    			Offset = VirtualAddress & OFFSET_MASK
    			PhysAddr = (TlbEntry.PFN << SHIFT) | Offset
    			Register = AccessMemory(PhysAddr)
    		else
    			RaiseException(PROTECTION_FAULT)
    else // TLB Miss
    	PTEAddr = PTBR + (VPN * sizeof(PTE))
    	PTE = AccessMemory(PTEAddr)
    	if (PTE.Valid === False)
    		RaiseException(SEGMENTATION_FAULT)
    	else if (CanAccess(PTE.ProtectBits) === False)
    		RaiseException(PROTECTION_FAULT)
    	else
    		TLB_Insert(VPN, PTE.PFN, PTE.ProtectBits)
    		RetryInstruction()
    ```
  ]
]

Algoritmo TLB di base:
+ Estrai il numero di pagina virtuale (VPN) dall'indirizzo virtuale.
+ Controlla se il TLB contiene la traduzione per questo VPN.
+ Se lo fa, abbiamo una *TLB hit*, che significa che il TLB contiene la traduzione.
  - Estraiamo il PFN della TLBE pertinente, concatenalo sull'offset dal VA originale e forma il PA, e accedi alla memoria.
+ Se la CPU non trova la traduzione nel TLB (*TLB miss*)
  - L'hardware accede alla page table per trovare la traduzione.
  - Supponendo che la referenza di memoria virtuale generata dal processo sia valida e accessibile, aggiorna il TLB con la traduzione (azioni costose).
+ Aggiornato il TLB, l'hardware riprova l'istruzione e la traduzione si trova nel TLB quindi la referenza di memoria viene elaborata rapidamente.

#figure(
  image("../images/tlb/tlb.png"),
  caption: [Schema di funzionamento delle TLB. @geeksforgeeks2],
)

=== Gestione dei TLB miss
Le TLB miss possono causare un rallentamento del programma se si verificano frequentemente (CPU deve accedere alla page table per trovare la traduzione).

La prima volta che il programma accede a un elemento dell'array di 10 elementi, si verifica un TLB miss, perché la traduzione non è ancora memorizzata nel TLB. Tuttavia, le successive accessi all'array causeranno dei TLB hit, perché le traduzioni degli elementi successivi si trovano sulla stessa pagina di memoria della prima traduzione. il TLB ha un hit rate del 70% (valore ragionevole). Se il programma accedesse nuovamente all'array, il TLB hit rate sarebbe probabilmente più alto, perché le traduzioni degli elementi dell'array sarebbero già memorizzate nel TLB.

*Spatial locality*: tendenza degli elementi di un array a essere contigui in memoria.

*Temporal locality*: tendenza di un programma a riutilizzare gli stessi indirizzi di memoria più volte. Es. ciclo for.

Il processore può gestire le TLB miss in due modi:
- *Hardware-managed*: il processore è responsabile della gestione delle TLB miss. La CPU accede alla page table e trova la traduzione, aggiorna il TLB con la traduzione e rieseguire l'istruzione che ha causato la TLB miss.
- *Software-managed*: La CPU solleva un'eccezione quando si verifica la TLB miss. Il processore passa il controllo all'OS, che è responsabile della gestione della TLB miss. L'OS accede alla tabella delle pagine per trovare la traduzione, aggiorna il TLB con la traduzione e quindi restituisce il controllo al processore (flessibile ma più lento).

Le architetture moderne hanno il TLB software-managed. In caso di TLB miss, l'hardware solleva l'eccezione, mette in pausa il flusso di istruzioni, aumenta il privilegio e va al trap handler.

Il return-from-trap ha due scopi:
- Ripristinare il contesto del processore come prima dell'interruzione.
- Riprendere l'esecuzione del processo.

Il return-from-trap è diverso per le TLB miss e per le system call:
- Nelle TLB miss, deve riprendere l'esecuzione all'istruzione che ha causato la TLB miss perché dovrà eseguire di nuovo l'istruzione che ha bisogno della traduzione appena aggiornata.
- Nelle system call, deve riprendere l'esecuzione all'istruzione dopo l'interruzione perché la CPU ha già eseguito le istruzioni necessarie per la system call e non ha bisogno di ripeterle.

Se il codice di gestione delle TLB miss provoca una TLB miss, si può creare una catena infinita di TLB miss. Per evitare questo problema, l'OS può:
- Conservare il codice di gestione delle TLB miss in memoria fisica (dove non è soggetto a traduzione di indirizzi).
- Risolvere alcune TLBE per traduzioni sempre valide e utilizzare alcune di queste voci per il codice di gestione delle TLB miss.

Vantaggi dell'approccio software-managed:
- È più flessibile, perché l'OS può utilizzare qualsiasi struttura dati per implementare la tabella delle pagine.
- È più semplice, perché l'hardware non deve fare molto quando si verifica una TLB miss.

=== Struttura e implementazione
*Valid bit*: indica se una traduzione è memorizzata nel TLB. Quando un sistema viene avviato, i valid bit del TLB sono impostati su invalid, perché non ci sono traduzioni ancora memorizzate nel TLB. Una volta che i processi iniziano a funzionare e accedono ai loro spazi di VA, il TLB viene lentamente popolato e i valid bit vengono impostati su valid.

I valid bit sono utili anche durante i context switch. Quando si verifica un context switch, l'OS imposta tutti i valid bit del TLB su invalid. Ciò assicura che il processo che sta per essere eseguito non utilizzi accidentalmente una traduzione da virtuale a fisica da un processo precedente.

*TLB fully associative*: qualsiasi traduzione può trovarsi in qualsiasi posizione nella TLB.

Campi TLBE :
- *VPN (Virtual Page Number)*: il numero di pagina virtuale
- *PFN (Physical Page Number)*: il numero di pagina fisica
- *Altri bit*: es. bit di validità, i bit di protezione e l'identificatore dello spazio di indirizzi.

=== Context-switching e TLB
Il TLB contiene le traduzioni di indirizzi relative a un determinato processo. Quando avviene un context-switch bisogna assicurarsi che un processo usi le traduzioni corrette.

Occorre svuotare il TLB (*flush*) ad ogni cambio di contesto:
- *Approccio software*: ottenuto tramite un'istruzione hardware privilegiata.
- *Approccio hardware*: ottenuto quando si va a modificare il PTBS (Page Table Base Register)

In entrambi i casi per lo svuotamento si impostano i bit di validità a zero.
Ogni volta che viene eseguito un processo questo incorre in errori TLB quando tocca i suoi dati e le tabelle dei codici (costo elevato).

Quando si passa da un processo all'altro, le traduzioni nel TLB del processo precedente non sono più valide per il processo successivo. Ci sono due possibili soluzioni a questo problema:
1. Svuotare completamente il TLB su ogni cambio di contesto. Semplice ma costoso perché ogni processo deve ricaricare le sue traduzioni dal tabella delle pagine quando viene eseguito.
2. Aggiungere un campo di identificatore di spazio di indirizzi (*ASID*) al TLB. L'ASID è un numero che identifica univocamente un processo. Con l'ASID, il TLB può memorizzare traduzioni da diversi processi contemporaneamente, purché le traduzioni per un processo specifico abbiano lo stesso ASID.

Quando installiamo una nuova entry nel TLB si va a sostituire con una vecchia entry:
- *LRU* (least-recently-used): sostituisce la nuova entry con quella utilizzata meno recentemente.
- *Random Policy*: sostituisce una vecchia entry a caso con una nuova.

#colbreak()