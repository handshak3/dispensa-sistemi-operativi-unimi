== CPU Mechanism

*Interrupt*: meccanismo che consiste in un tipo di segnale hardware o software che interrompe il normale flusso di esecuzione di un programma per gestire un evento o una richiesta prioritaria.

*Direct execution*: permette di eseguire il programma direttamente sulla CPU senza l'intervento di un interprete o di un layer intermedio.

Quando l'OS desidera avviare un programma in Direct Execution:
1. l'OS crea una voce di processo nella Process Table.
2. Alloca della memoria per il programma.
3. Carica il codice del programma in memoria.
4. Imposta lo stack con `argc` e `argv`.
5. Pulisce i registri.
6. Chiama `main()`.
7. il programma esegue `main()`.
8. Ritorna dal `main()`.
9. L'OS libera la memoria del processo terminato.
10. Rimuove l'entry dalla process table.

Per il controllare le azioni indesiderate si ricorre a LDE.

*Limited Direct Execution (LDE)*: tecnica utilizzata per eseguire programmi utente in modo efficiente, mantenendo al contempo il controllo sulla gestione delle risorse e la sicurezza del sistema. Consiste nel controllare e limitare l'accesso diretto dei processi all'hardware sottostante. L'obiettivo principale della LDE è combinare i vantaggi dell'esecuzione diretta del codice da parte dell'hardware (per massimizzare le prestazioni) con i meccanismi di controllo necessari per prevenire comportamenti errati o malevoli da parte dei programmi utente.

=== Problema 1 (operazioni limitate)
Quando un processo decide di eseguire un tipo di esecuzione limitata ci sono due modalità di esecuzione:

- *User mode*: il codice è limitato in ciò che può fare in quanto le applicazioni non hanno accesso completo alle risorse hardware.
- *Kernel mode*: il codice eseguito può fare ciò che vuole, l'OS ha accesso a tutte le risorse della macchina.

Quando un processo utente vuole eseguire un operazione privilegiata lo fa attraverso le system call che consentono al kernel di esporre alcune funzionalità fondamentali al processo utente a seguito di una istruzione *trap*.

Per eseguire una system call il programma utente dovrà chiamare un interrupt facendo saltare l'esecuzione nel kernel e quindi cambiare i privilegi in kernel mode. Al termine l'OS richiama una *return-from-trap* e l'esecuzione ritorna al programma utente abbassando i privilegi alla user mode.

Flusso di esecuzione dell'interrupt:
1. L'hardware genera un segnale di interrupt.
2. La CPU interrompe l'esecuzione del processo corrente e salva lo stato del processo corrente sullo stack kernel del processo.
3. La CPU passa il controllo al trap handler. La routine di interrupt handler è responsabile di gestire l'interrupt.
4. La trap handler legge i dati dall'hardware che ha generato l'interruzione e gestisce l'interruzione.
5. La trap handler ripristina lo stato del processo corrente dallo stack kernel del processo.
6. La CPU passa il controllo nuovamente al processo corrente.

*Funzionamento della trap*: il processo chiamante non può selezionare direttamente dove saltare altrimenti i programmi potrebbero accedere ovunque nel kernel. Quindi, il kernel gestisce quale codice viene eseguito quando si verifica una trap.

1. All'avvio della macchina (in kernel mode) viene creata una *trap table* nella quale l'OS informa l'hardware della posizione dei trap handlers. La trap table contiene il puntatore alla prima cella della *system call table*.
2. Viene assegnato un codice ad ogni system call per essere identificata e poi chiamata.
3. Il codice utente specifica quale chiamata occorre effettuare e l'OS verifica la validità del codice che in nel caso affermativo effettuera la determinata system call.

#figure(caption: [Limited Direct Execution protocol.])[#image("../../images/mechanism/limited direct execution.png")]

=== Problema 2 (Context Switching)
Immaginiamo di avere un processo in esecuzione sulla CPU fisica che abbia appena esaurito il lasso di tempo a disposizione. A questo punto il sistema operativo dovrebbe eseguire il codice che consente di bloccare l'esecuzione del processo corrente e schedulare il prossimo da eseguire. Il problema è che ciò non può avvenire visto che il processore è attualmente occupato. Soluzioni:
- *Approccio cooperativo (via software)*: dato che quando il processo è in esecuzione, non lo è anche l'OS. Si presume che i processi lunghi rinuncino periodicamente alla CPU per far riprendere l'attività all'OS. La maggior parte dei processi trasferisce il controllo all'OS dopo una system call attraverso `yeld()`. I processi che fanno qualcosa di illegale generano una trap. L'OS riprende il controllo della CPU ogni volta che si effettua un system call o un operazione illegale.
- *Approccio non cooperativo (via hardware)*: per restituire il controllo all'OS è il *timer di interrupt* (timer che allo scadere di $x$ millisecondi, genera un interrupt). Quando l'interrupt viene generato, il processo in esecuzione viene interrotto e viene eseguito un *trap handler* (preconfigurato nell'OS). L'OS deve informare l'hardware di quale codice eseguire quando si verifica l'interruzione da parte del timer (impostato al momento del boot del sistema). Anche durante il boot l'OS deve avviare il timer. Il timer può essere anche disattivato. L'hardware, al momento dell'interruzione, deve salvare lo stato del programma in esecuzione per consentire, dopo la *return-from-trap*, di riprendere la sua corretta esecuzione.

=== Salvataggio/ripristino e context-switch
Dopo un interrupt è necessario stabilire come e se cambiare processo in esecuzione (decisione presa dallo *scheduler*). Se lo scheduler decide che occorre cambiare processo in esecuzione, l'OS esegue un pezzo di codice a basso livello chiamato *context-switch*. L'OS per salvare il contesto del processo in esecuzione:
1. Il processo $A$ è in esecuzione.
2. L'hardware:
  1. Genera l'interrupt allo scadere del timer interrupt.
  2. Salva i registri del processo $A$ nello stack kernel.
  3. Eleva i privilegi passando in kernel mode.
  4. Passa al trap handler.
3. Il trap handler:
  1. Chiama la routine `switch()`.
    1. Salva i registri del processo $A$ nella PCB di $A$.
    2. Ripristina i registri del processo $B$ dalla PCB di $B$.
    3. Passa allo stack kernel del processo B.
  2. L'OS fa return-from-trap.
4. L'hardware:
  1. Ripristina dei registri di $B$ dallo stack kernel.
  2. Cambia il livello di privilegio in user mode.
  3. Saltare all'indirizzo del PC del processo $B$.

Siccome no tutti gli interrupt portano a un context-switch, l'hardware salva i registri essenziali nel kernel per gestire lp'interrupt. Tipicamente salva il Program Counter (PC), Program Status Word (PSW) e lo Stack Pointer (SP). Successivamente, in caso di context-switch, l'OS salva tutti i registri per poi essere in grado di ripristinarli in seguito.

#figure(caption: [Limited Direct Execution with interrupt.])[#image("../../images/mechanism/limited direct execution protocol with interrupt.png")]

Per fare context-switching, l'OS salva alcuni valori dei registri per il processo in corso di esecuzione (generalmente li salva nel kernel stack) e ripristinarne altri per il processo scelto. Facendo ciò è in grado di assicurare che quando si esegue l'istruzione per ritornare dall'interrupt (*IRET*), anziché ritornare al processo che era in esecuzione, il sistema riprenderà l'esecuzione del processo schedulato. L'OS dovrà quindi salvare i registri di general purpose, program counter, kernel stack pointer del currently-running-process e successivamente ripristinare i rispettivi valori del chosen-process. Quando viene eseguita la return-from-trap il processo che andrà in esecuzione sarà quello scelto, completando così il context switch. Cambiando puntatori al kernel stack (di fatto cambiando stack), il kernel è in grado di cambiare “contesto”, passando dal processo in corso di esecuzione a quello schedulato.

=== Problemi di concorrenza e locking
Se un altro interrupt si verifica durante il processo di gestione di un interrupt, il kernel deve decidere come gestire la situazione. È possibile disabilitare gli interrupt durante la gestione dell'interrupt impedendo che altri interrupt vengano inviati alla CPU fino a quando l'interrupt corrente non è stato gestito. Disabilitare gli interrupt per un periodo di tempo prolungato può causare la perdita di interrupt. Gli OS hanno sviluppato schemi di *locking* per proteggere l'accesso concorrente alle strutture dati interne. Ciò consente a più attività di essere in esecuzione all'interno del kernel contemporaneamente.