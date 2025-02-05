#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Paging

Obbiettivi:
- Gestione ottimale dello spazio libero in memoria fisica.
- Gestione ottimale dell'address space di un programma (non vogliamo memorizzare più di quanto non sia necessario).

Per la gestione dello spazio esistono due approcci:
- *Segmentazione*: suddivide la memoria in parti di dimensioni variabili (problema: *frammentazione*).
- *Paging*: suddivide la memoria in parti di dimensioni fisse, chiamate pagine. La memoria fisica è vista come un array di slot con dimensioni fisse, chiamati *frame di pagina*; ogni frame può contenere una singola *pagina* di memoria virtuale.

#figure(
  caption: [(a) Simple 64 byte address space, (b) 64 byte address space in 128 byte of memory.],
  grid(
    columns: (1fr, 1fr),
    row-gutter: 1em,
    [$#image("../../images/paging/as w paging.png")$],
    [$#image("../../images/paging/full as w paging.png")$],

    [(a)], [(b)],
  ),
)

=== Vantaggi del paging
I problemi principali da risolvere quando si implementa il paging sono:
- La virtualizzazione della memoria.
- La scelta della dimensione delle pagine.
- La gestione dei conflitti di pagina.

Vantaggi paging:
- *Flessibilità*: il sistema sarà in grado di supportare l'astrazione di un'address space indipendentemente da come un processo utilizza lo spazio degli indirizzi.
- *Semplicità di gestione dello spazio libero*: quando l'OS vuole inserire l'AS di un processo, trova le pagine libere (prende le prime pagine della free list).

=== Page table
*Page table*: struttura dati presente nella PCB del processo, memorizza le traduzioni degli indirizzi per ogni pagina virtuale dell'AS. La page table è una struttura dati per-process. Se un altro processo dovesse essere mandato in esecuzione, l'OS dovrebbe gestire una page table differente per esso, siccome le sue VP ovviamente sono mappate in frame differenti. Non memorizziamo le page table su un chip dell'MMU per via della loro grandezza. La page table è una struttura dati che viene utilizzata per mappare gli VA (VPN) agli indirizzi fisici (PFN).

Quando un processo genera un indirizzo virtuale, l'OS e l'hardware, lo traducono in indirizzo fisico.

Il processo divide l'indirizzo virtuale in due componenti:
- *VPN* (Virtual Page Number): identifica la pagina virtuale.
- *Offset*: identifica il byte all'interno della pagina.

#figure(
  image("../../images/paging/translation w paging.png", width: 70%),
  caption: [The address translation process.],
)

=== Esempio Paging model
Abbiamo:
- Address Space: $32 "bit"$ quindi $ 2^32 = 4 "GigaByte"$
- Page Size = $4 "Kb"$

+ Calcolo le dimensioni dell'offset:\
  $"offset" = log_2 4096 = 12 "bit"$

+ Calcolo dimensione della VPN:\
  $"VPN" = 32 - 12 = 20 "bit"$

+ Verifico i calcoli:\
  $2^20 dot 4096 "KB" = 4 "GB di spazio indirizzabile"$
#figure(
  image("../../images/paging/paging.png"),
  caption: [Schema di traduzione. @lavecchia_2020_differenza],
)

Le page table possono diventare molto grandi delle segment table o delle coppie base/limiti. In un AS a 32 bit con pagine da 4Kb. Questo VA si divide in un VPN a 20 bit e un offset a 12 bit.

Un VPN a 20 bit implica che l'OS debba gestire $2^(20)$ traduzioni per ogni processo (circa un milione); assumendo che siano necessari 4 byte (32 bit) per PTE (Page Table Entry) per contenere la traduzione fisica, si ottiene 4MB ($2^20 dot 4 "byte"$) di memoria necessari per ogni page table. Se i processi in esecuzione sono 100: l'OS ha bisogno di 400MB di memoria solo per tutte quelle traduzioni di indirizzi.

=== Page Table Entry (PTE)

*Linear Page Table*: forma più semplice tra le tipologie di page table. È un array, l'OS indicizza l'array in base al VPN e cerca la PTE in corrispondenza di tale indice per trovare il PFN desiderato.

Bit in ogni PTE:
- *Present bit (P)*: indica se questa pagina è in memoria.
- *Reference bit* o *access bit (A)*: se il bit è impostato, significa che la pagina è stata acceduta di recente e deve essere mantenuta in memoria fisica. Se il bit non è impostato, significa che la pagina non è stata acceduta di recente e può essere spostata fuori dalla memoria fisica se necessario.
- *Dirty bit (D)*: indica se la pagina è stata modificata da quando è stata caricata in memoria. Se la page viene modificata deve essere scritta su disco quando il processo termina.
- *Read/Write (R/W)*: Indica se le letture e/o scritture sono consentite su quella pagina.
- *User/Supervisor bit (U/S)*: indica se i processi in user mode possono accedere alla pagina.
- *Valid bit*: indica se la particolare traduzione è valida (es. spazio tra stack e heap non valido). Supporta l'AS sparso marcando tutte le pagine non utilizzate nell'AS come non valide, e quindi rimuovendo la necessità di allocare frame fisici per tali pagine (risparmiamo memoria).
- *Protection bit*: indica se la pagina può essere letta, scritta o eseguita.
- *PWT, PCD, PAT e G*: determinano come funziona la memorizzazione in cache.

#figure(
  image("../../images/paging/x86 pte.png"),
  caption: [x86 PTE.],
)

=== Problemi del paging
Il paging può rallentare il sistema.

Esempio:

#text(9pt)[
  ```yasm
  movl 21, %eax
  ```
]

Per fare ciò, l'hardware deve sapere dove si trova la page table per il processo in esecuzione. Supponiamo che un singolo *registro di base della page table* contenga il PA della posizione iniziale della page table.

Una volta che il PA è noto, l'hardware recupera la PTE dalla memoria, estrae il PFN e lo concatena all'offset del VA formando il PA.
#figure(
  text(9pt)[
    ```c
    // Extract the VPN from the virtual address
    VPN = (VirtualAddress & VPN_MASK) >> SHIFT

    // Form the address of the page-table entry (PTE)
    PTEAddr = PTBR + (VPN * sizeof(PTE))

    // Fetch the PTE
    PTE = AccessMemory(PTEAddr)

    // Check if process can access the page
    if (PTE.Valid === False)
    RaiseException(SEGMENTATION_FAULT)
    else if (CanAccess(PTE.ProtectBits) === False)
    RaiseException(PROTECTION_FAULT)
    else
    // Access is OK: form physical address and fetch it
    offset = VirtualAddress & OFFSET_MASK
    PhysAddr = (PTE.PFN << PFN_SHIFT) | offset
    Register = AccessMemory(PhysAddr)
    ```
  ],
  caption: [Implementazione del paging.],
)

#figure(
  image("../../images/paging/paging schema.png"),
  caption: [Come funziona la paginazione. @geeksforgeeks1],
)

#colbreak()