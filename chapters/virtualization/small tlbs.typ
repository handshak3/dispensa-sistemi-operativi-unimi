#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Small TLBS

=== Problemi delle Page Table
Le page table occupano tanta memoria, la soluzione è quella di creare pagine più grandi.

La soluzione più semplice per ridurre le dimensioni della page table consiste nell'utilizzare pagine di dimensioni maggiori. Considerando un AS a 32 bit e pagine da 16 KB, si otterrebbe una riduzione del fattore quattro delle dimensioni della tabella delle pagine. Otteniamo:
- VPN a 18 bit
- Offset a 14 bit ($16k dot 1024=2^14$)

Questa soluzione soffre di *frammentazione interna* all'interno di ciascuna pagina, poiché le applicazioni potrebbero utilizzare solo parti delle pagine e riempire la memoria con pagine grandi.

Alcune architetture supportano dimensioni multiple delle pagine. Questo approccio è utile per ottimizzare l'accesso a strutture dati grandi e frequentemente utilizzate, riducendo la pressione sulla TLB. L'implementazione di dimensioni multiple delle pagine rende il gestore di memoria virtuale dell'OS complesso.

=== Combinazione di segmentation e paging
Utilizzando un approccio ibrido, si combina il paging e la segmentation. Viene creata una page table per ogni segmento logico (es. heap, stack, code).

Composizione della segment table:
- *Registro base*: non contiene più l'indirizzo entry del segmento logico, qui contiene il PA della page table del segmento.
- *Registro bound*: non è più la dimensione della pagina ma il valore della massima pagina valida nel segmento.

Durante l'esecuzione di un processo, il registro base per ciascun segmento contiene l'indirizzo fisico di una tabella delle pagine lineare per quel segmento. Quando avviene un cambio di contesto, questi registri devono essere aggiornati per riflettere la posizione delle tabelle delle pagine del nuovo processo in esecuzione.

L'approccio ibrido può ridurre l'overhead di memoria delle page table in due modi:
- Il numero di voci nella tabella delle pagine può essere ridotto, perché le pagine che appartengono allo stesso segmento possono essere mappate nello stesso frame di memoria.
- Le voci nella tabella delle pagine possono essere più piccole, perché non è necessario memorizzare il numero di segmento per ogni pagina.

In caso di TLB MISS, l'hardware utilizza i bit di segmento SN per determinare quale coppia base and bounds utilizzare. L'hardware prende il PA in base e lo combina con il VPN per formare l'indirizzo della PTE

#text(9.7pt)[
  ```txt
  AddressOfPTE = Base[SN] + (VPN * sizeof(PTE))
  SN = (VirtualAddress & SEG_MASK) >> SN_SHIFT
  VPN = (VirtualAddress & VPN_MASK) >> VPN_SHIFT
  ```
]

In questo modo le pagine non allocate tra stack e heap non occupano più spazio in una PT.

*Criticità dell'approccio ibrido*: La segmentazione può causare *frammentazione esterna*, poiché i segmenti hanno dimensioni variabili. Questo porta a spazi di memoria liberi ma non contigui, che potrebbero essere insufficienti per soddisfare le richieste di nuovi processi, rendendo tali spazi inutilizzabili e aumentando l'inefficienza complessiva del sistema

=== Multi-Level Page Table
Per risolvere il problema delle regioni di memoria non valide nella page table si utilizzano le tabelle delle pagine multilivello.

Questo approccio trasforma la page table lineare in una struttura simile a un albero, migliorando l'efficienza e riducendo gli sprechi di memoria.

- La page table viene suddivisa in unità page-sized.
- Se una pagina di una PTE è invalida, non viene allocata.

*Page directory*: indica quali pagine della page table sono valide. Contiene un'entry PDE (Page Directory Entry) per ogni page della PT. Ogni PDE ha:
- *Bit di validita*: se PDE è valida significa che almeno una delle PTE nelle pagine della PT a cui punta la PDE tramite il PFN, è valida.
- *PFN* (Page Frame Number): indirizzo di memoria dove è situata una page table.

Mentre la page table lineare richiede spazio per regioni non valide, la multi-level page table può "far sparire" parti della tabella delle pagine, liberando quei frame per altri utilizzi e tracciando le pagine allocate con il page directory.

Vantaggi:
- Alloca spazio solamente per la page table in proporzione all'ammontare di AS in uso (supporta quindi address space sparsi).
- Se implementata correttamente, ogni porzione della PT entra ordinatamente in una pagina, rendendo più facile la gestione della memoria; il sistema operativo prende semplicemente la prossima pagina libera quando ha bisogno di allocare o far crescere una PT.

Svantaggi:
- In caso di TLB MISS sono necessari due accessi a memoria (uno per la PDE e l'altro per la PTE) mentre il caso di TLB HIT le prestazioni corrispondono a quelle di una tabella lineare.
- Struttura più complessa rispetto ad una tabella lineare.

Il multi-level page table rappresenta un compromesso tra tempo e spazio.

#figure(
  image("../../images/tlb/small tlbs.png"),
  caption: [Linear (Left) And Multi-Level (Right) Page Tables.],
)

=== Multi-level Page Table a più livelli

Quando lo spazio di indirizzamento aumenta, anche la dimensione della directory delle pagine cresce, rendendo inefficiente l'allocazione di memoria. Per ovviare a questo problema, si aggiungono ulteriori livelli alla tabella delle pagine, creando una struttura gerarchica più profonda. Questo approccio consente di suddividere l'indirizzo virtuale in più segmenti, ciascuno dei quali indirizza un livello specifico della tabella, garantendo che ogni segmento della tabella delle pagine occupi esattamente una pagina di memoria fisica.

Ad esempio, con uno spazio di indirizzamento di 30 bit e pagine di 512 byte, l'indirizzo virtuale può essere suddiviso in:
- 9 bit per l'offset all'interno della pagina.
- 7 bit per l'indice della tabella delle pagine.
- 14 bit per l'indice della directory delle pagine.

Se la directory delle pagine diventa troppo grande per essere contenuta in una singola pagina fisica, si introduce un ulteriore livello di directory, suddividendo la directory originale in più pagine e aggiungendo una directory di livello superiore. Questo processo può essere ripetuto, aggiungendo più livelli, fino a garantire che ogni segmento della tabella delle pagine possa essere contenuto in una singola pagina fisica, ottimizzando così l'utilizzo della memoria e migliorando l'efficienza del sistema.

#figure(caption: [Implementazione Multi-Level TLB.])[
  #text(9pt)[
    ```c
    VPN = (VirtualAddress & VPN_MASK) >> SHIFT
    (Success, TlbEntry) = TLB_Lookup(VPN)
    if (Success === True)
      // TLB Hit
      if (CanAccess(TlbEntry.ProtectBits) === True)
      Offset
      = VirtualAddress & OFFSET_MASK
      PhysAddr = (TlbEntry.PFN << SHIFT) | Offset
      Register = AccessMemory(PhysAddr)
      else
      RaiseException(PROTECTION_FAULT)
    else
      // TLB Miss
      // first, get page directory entry
      PDIndex = (VPN & PD_MASK) >> PD_SHIFT
      PDEAddr = PDBR + (PDIndex * sizeof(PDE))
      PDE = AccessMemory(PDEAddr)
      if (PDE.Valid === False)
        RaiseException(SEGMENTATION_FAULT)
      else
        // PDE is valid: now fetch PTE from page table
        PTIndex = (VPN & PT_MASK) >> PT_SHIFT
        PTEAddr = (PDE.PFN<<SHIFT) + (PTIndex*sizeof(PTE))
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

#figure(
  image("../../images/tlb/multi TLB.png"),
  caption: [Schema di memoria di un Multi-Level TLB a due livelli su architettura x86-64 con page size = 16 Kb. Schema creato dall'autore.],
)

#colbreak()