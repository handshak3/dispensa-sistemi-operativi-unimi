#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Swapping: Mechanisms
Per supportare AS di grandi dimensioni, l'OS avrà bisogno di posizionare altrove quelle pagine che non sono largamente richieste. Quindi occorre molta memoria che comporta l'utilizzo di un disco rigido grande, dunque, molto lento. Avremmo prestazioni scarse per spostare le pagine dalla memoria centrale a quella di massa e viceversa.

=== Swapping
*Swap space*: spazio sulla memoria di massa per spostare le pagine avanti e dietro.

L'OS legge e scrive nello space swap usando la dimensione di una pagina come unità. L'OS deve ricordare l'indirizzo su disco di una determinata pagina. La dimensione dello space swap determina il numero massimo di pagine in memoria che possono essere usate da un sistema in un determinato momento.

+ *Generazione VA*: Il processo in esecuzione genera dei riferimenti virtuali a memoria (per prelevare istruzioni o accedere dati).
+ *Consultazione della TLB*:L'hardware prima di estrarre la VPN del VA controlla la TLB:
  - *TLB HIT*: produce il PA e lo recupera il contenuto in memoria.
  - *TLB MISS*: l'hardware individua la PT in memoria e cerca la PTE per la pagina utilizzando il VPN come indice.
    - Se la pagina è valida ed è presente nella memoria fisica, l'hardware estrae il PFN dal PTE, lo installa nel TLB e riprova l'istruzione e questa volta genererà un TLB HIT.
    - Se la pagina non è valida significa che non è presente nella memoria fisica. Avviene il *page fault*.

=== Page fault

Per gestire il TLB MISS ci sono 2 sistemi:
- *Sistema gestito dall'hardware*: l'hardware cerca nella PT la traduzione desiderata.
- *Sistema gestito dal software*: l'OS cerca nella PT la traduzione.

In entrambi i casi se una pagina non è presente, l'OS deve gestire il page fault (se una pagina non è presente in memoria centrale l'OS dovrà riportare la pagina dalla memoria di massa a quella centrale per risolvere il page fault). L'OS per trovare la pagina utilizzerà i bit della PTE relativi al PFN. L'OS quando si verifica un page fault cerca nella PTE per trovare l'indirizzo e inviare la richiesta della pagina al disco fisico. Al termine, l'OS aggiornerà la PT con il presence bit della relativa pagina impostato a 1, aggiornerà il campo PFN della PTE per registrare la posizione in memoria e infine riproverà l'istruzione fallita.

Mentre c'è I/O il processo è in block state e il processore sarà libero per eseguire altri processi (*overlap*).

La memoria potrebbe essere piena e l'OS potrebbe aver bisogno di una pagina o più, in questo caso occorre sostituire le pagine che non sarebbero utili. Questa politica si chiama *page-replacement policy*.

=== Control Flow del page fault

#figure(caption: [Page-Fault Control Flow Algorithm (Software).])[
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
      else
        if (CanAccess(PTE.ProtectBits) === False)
          RaiseException(PROTECTION_FAULT)
        else if (PTE.Present === True)
          // assuming hardware-managed TLB
          TLB_Insert(VPN, PTE.PFN, PTE.ProtectBits)
          RetryInstruction()
        else if (PTE.Present === False)
          RaiseException(PAGE_FAULT)
    ```
  ]
]

Quando si verifica un TLB MISS, ci sono tre casi:
+ La pagina è sia presente che valida (righe 18-20). In questo caso, il TLB miss handler prende semplicemente il PFN dalla PTE e riprova l'istruzione ottenendo un TLB hit.
+ Il page fault handler deve essere eseguito; sebbene la pagina sia valida, non è presente in memoria fisica (righe 22-23).
+ L'accesso potrebbe non essere valido (righe 13-14). In questo caso nessun altro bit della PTE viene preso in considerazione. L'hardware esegue una trap e l'opportuno trap handler dell'OS viene eseguito, terminando il processo.

#figure(caption: [Page-Fault Control Flow Algorithm (Software).])[
  #text(size: 9pt)[
    ```c
    PFN = FindFreePhysicalPage()
    if (PFN === -1) // no free page found
      PFN = EvictPage() // replacement algorithm
    DiskRead(PTE.DiskAddr, PFN) // sleep (wait for I/O)
    PTE.present = True // update page table:
    PTE.PFN = PFN // (present/translation)
    RetryInstruction() // retry instruction
    ```
  ]
]

L'OS per gestire il page fault deve:
+ Trovare il frame fisico per far risiedere la pagina “soon-to-be-faulted-in”.
+ Se tale frame non c'è, dobbiamo aspettare per che l'algoritmo di replacement venga eseguito e liberi alcune pagine per riutilizzarle.

*Parte hardware del controllo del flusso di pagina*
Quando il processore tenta di accedere a una pagina di memoria, prima interroga la tabella di traduzione della pagina (TLB) per vedere se la pagina è presente in memoria fisica. Se:
+ *$"present bit = 1"$*: la CPU ottiene il numero del frame fisico della pagina dalla TLB e procede ad accedere alla pagina.
+ *$"present bit = 0"$*: la CPU genera un errore di pagina e il controllo passa alla parte software del controllo del flusso di pagina.

*Parte software del controllo del flusso di pagina*
Quando l'OS riceve un errore di pagina:
+ Deve trovare un frame fisico libero per la pagina.
  - Se non è disponibile alcun frame fisico libero, l'OS deve eseguire un algoritmo di sostituzione di pagina per rimuovere una pagina dalla memoria fisica.
+ L'OS legge la pagina dalla memoria di swap nel frame fisico.
+ L'OS aggiorna la tabella di traduzione della pagina per indicare che la pagina è ora presente in memoria fisica.

=== Replacement delle pagine
I'OS attende fino a quando la memoria non è completamente piena e solo allora sostituisce una pagine per far spazio ad una nuova. Ma gli OS mantengono un po' di memoria libera per:
- Eseguire gli algoritmi di sostituzione di pagina.
- Evitare che il sistema operativo si blocchi a causa di un errore di pagina.
- Consentire ai processi di allocare nuove pagine di memoria.

Per mantenere una quantità minima di memoria libera l'OS utilizza *HW* (high watermark) e *LW* (low watermark) che aiutano a decidere quando iniziare a rimuovere le pagine dalla memoria. Quando il numero di pagine di memoria libere scende al di sotto del valore LW, l'OS avvia un thread in background (*swap daemon* o page daemon) che si occupa di liberare memoria. Il thread in background esegue l'algoritmo di sostituzione di pagina fino a quando il numero di pagine di memoria libere non supera il valore HW. Per supportare il thread in background, il controllo del flusso di pagina deve essere modificato.

L'OS controlla costantemente il numero di pagine libere in memoria. Quando le pagine libere scendono sotto la soglia LW:
+ *Attivazione del Swap Daemon*: lo swap daemon viene attivato per iniziare il processo di liberazione della memoria.
+ *Liberazione della Memoria*: lo swap daemon identifica le pagine meno utilizzate e le trasferisce su disco, liberando spazio in memoria fisica. Questo processo può includere la scrittura di gruppi di pagine sul disco in un'unica operazione, migliorando l'efficienza grazie all'accesso sequenziale al disco.
+ *Conclusione*: quando il numero di pagine libere raggiunge o supera la soglia HW, il swap daemon termina la sua attività e ritorna in stato di inattività, pronto a riattivarsi se necessario.

#line()