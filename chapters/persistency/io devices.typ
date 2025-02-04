== I/O devices

#figure(
  image("../../images/io/architettura.png", width: 70%),
  caption: [Prototipo dell'architettura di un sistema.],
)

Vantaggi struttura gerarchica:
- I componenti ad alta performance sono più vicini alla CPU, il che migliora le loro prestazioni (bus corto).
- I componenti a bassa performance sono più lontani dalla CPU, il che riduce il loro impatto sulle prestazioni della CPU.
- È possibile posizionare un gran numero di dispositivi su un bus periferico.
- È possibile utilizzare bus diversi per diversi tipi di dispositivi, a seconda delle loro esigenze di prestazioni.

#figure(
  image("../../images/io/architettura moderna.png", width: 60%),
  caption: [Architettura moderna di un sistema.],
)

Architettura di un sistema moderno:
- Utilizzano chipset specializzati e interconnessioni p2p.
- La CPU si collega direttamente alla memoria RAM e alla GPU per maggiori prestazioni.
- Tramite DMI (Direct Media Interface) si collega al chip I/O.
- Il chip I/O collega i dischi.
- Sotto il chip I/O ci sono le connessioni USB (Universal Serial Bus).
- Infine ci sono le connessioni PCIe (Peripheral Component Interconnect Express) per dispositivi più performanti.

=== Interfacce e registri
Un dispositivo canonico ha due componenti importanti:
- *Interfaccia hardware*: consente al software di sistema di controllare il funzionamento del device.
- *Struttura interna*: è specifica dell'implementazione e si occupa di implementare l'astrazione che il dispositivo presenta al sistema.

#figure(
  image("../../images/io/canonical drive.png"),
  caption: [Interfaccia e struttura interna.],
)
L'interfaccia di un dispositivo ha tre registri:
- *Registro di stato*: letto per vedere lo stato attuale del device.
- *Registro dei comandi*: indica al device di eseguire un determinato compito.
- *Registro dei dati*: utilizzato per passare/ottenere dati dal device.

=== Canonical protocol
Il protocollo canonico ha quattro fasi:
1. *Polling*: l'OS attende che il dispositivo sia pronto leggendo ripetutamente il suo registro di stato.
2. I'OS invia i dati al dispositivo attraverso il registro dati. Quando la CPU principale è coinvolta nel trasferimento dei dati, il metodo di trasferimento è chiamato I/O programmato (PIO).
3. L'OS scrive un comando nel registro comandi in modo da informare il device che i dati sono presenti e che deve iniziare a lavorare sul comando.
4. La CPU attende che il dispositivo finisca ripetendo il polling in un loop, aspettando di vedere se è terminato (potrebbe quindi ottenere un codice di errore per indicare il successo o il fallimento).

=== Ottimizzazioni dell'I/O

In questo approccio ci sono inefficienze (es. polling che spreca tempo della CPU). È possibile ridurre il sovraccarico della CPU utilizzando gli interrupt. Invece di interrogare ripetutamente il dispositivo, l'OS può:
+ Inviare una richiesta.
+ Mettere il processo chiamante in attesa.
+ Passare al contesto di un'altra attività.
+ Quando il dispositivo terminerà l'operazione, invierà un'interruzione hardware che causerà il salto della CPU nell'OS in una routine di servizio di interrupt (ISR) o a un gestore di interrupt.

Il gestore di interrupt:
+ Completerà la richiesta.
+ Risveglierà il processo in attesa dell'I/O che potrà procedere.

Le interruzioni consentono quindi di sovrapporre (overlay) computazione e I/O, migliorando l'efficienza del sistema. Le interruzioni possono essere inefficienti se il dispositivo è veloce, in tal caso, meglio utilizzare il polling. Se la velocità del dispositivo non è nota è possibile utilizzare un metodo ibrido: fare polling per un po' e se il device non ha ancora finito, utilizzare gli interrupt.

Gli interrupt non sono sempre la miglior soluzione quando si hanno molte richieste. In questi casi, è meglio utilizzare il polling per avere un controllo migliore sul sistema e consentire ai processi di livello utente di eseguire le richieste.

#figure(
  image("../../images/io/noint.png"),
  caption: [Performance senza l'utilizzo di interrupt.],
)
#figure(
  image("../../images/io/int.png"),
  caption: [Performance con l'utilizzo di interrupt.],
)

*Coalescenza (coalescing)*: altra ottimizzazione basata sulle interruzioni, che consente di ridurre il sovraccarico della gestione delle interruzioni. Riesce ad aggregare più interrupt perché non genera subito l'interruzione ma aspetta.

Quando si utilizza PIO per trasferire grande mole di dati, la CPU è sovraccarica e perde tempo.

=== DMA (Direct Memory Access)
#figure(
  image("../../images/io/nodma.png"),
  caption: [Performance senza l'utilizzo di DMA.],
)
#figure(
  image("../../images/io/dma.png"),
  caption: [Performance con l'utilizzo di DMA.],
)

*DMA (Direct Memory Access)*: device che consente di accedere direttamente alla memoria centrale del computer, bypassando il processore.

Si vuole trasferire dati a un device. Funzionamento:
1. L'OS programma il DMA specificando dove sono i dati, quanti ne sono e a chi inviarli.
2. L'OS torna a fare altro.
3. Il DMA genera un interrupt per avvisare l'OS che il trasferimento è stato completato.

Due metodi principali di comunicazione con i dispositivi:
- *Istruzioni I/O esplicite*: specificano un modo per l'OS di inviare dati a registri del dispositivo. Occorre che tali istruzioni siano privilegiate.
- *I/O mappato in memoria*: l'hardware rende i registri dei dispositivi disponibili come se fossero locazioni di memoria. Per accedere a un registro particolare, l'OS emette un caricamento (per leggere) o una memorizzazione (per scrivere) l'indirizzo. L'hardware instrada il caricamento/archiviazione al dispositivo invece alla memoria principale.

Le istruzioni I/O esplicite sono più semplici da implementare, ma richiedono istruzioni privilegiate. L'I/O mappato in memoria è più efficiente, ma richiede hardware più complesso.

I device hanno interfacce specifiche e l'OS deve essere in grado di interagire con i dispositivi indipendentemente dalla loro interfaccia specifica (per fare ciò, si utilizza l'astrazione tramite i driver).

*Driver*: un pezzo di software nell'OS che conosce come funziona un dispositivo.

#figure(
  image("../../images/io/file system stack.png"),
  caption: [File system stack.],
)
Rappresentazione approssimativa e approssimativa dell'organizzazione del software Linux.

Il FS (File System) non deve conoscere i dettagli specifici del dispositivo hardware a cui è collegato. Il FS emette richieste di lettura/scrittura di blocchi al livello di blocco generico. Il livello di blocco instrada le richieste al driver del dispositivo appropriato. Il driver del dispositivo gestisce i dettagli dell'emissione della richiesta specifica.

*Raw interface*: abilita applicazioni speciali a leggere e scrivere blocchi direttamente senza utilizzare l'astrazione del file.

L'interfaccia generica può avere lati negativi, poiché può impedire alle applicazioni di sfruttare le capacità speciali di alcuni dispositivi.

#colbreak()