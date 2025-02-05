== Journaling

*Crash-consistency problem (problema di consistenza in caso di crash)*: si riferisce alla sfida di garantire che un sistema rimanga in uno stato coerente e valido dopo un guasto improvviso del sistema, come una perdita di energia o un crash del software.
Supponiamo di voler scrivere in un file. Per farlo, dobbiamo sostanzialmente eseguire tre writes:
+ Aggiornare l'inode del file.
+ Aggiungere un nuovo blocco nella regione dati.
+ Aggiornare la data bitmap.
Se una di queste writes non viene completata per via di un crash, il file system viene lasciato in uno stato "inconsistente".

=== The Crash Consistency Problem

Immaginiamo che una sola write precedenti abbia successo. I possibili scenari sono i seguenti:
- *Solo il data-block scritto su disco*: il blocco esiste fisicamente, ma non è riferito da alcun inode né segnato come occupato nella bitmap. Non c'è problema di crash-consistency, ma l'utente potrebbe perdere dati.

- *Solo l'inode scritto su disco*: l'inode punta a blocchi non scritti, che contengono dati spazzatura. Questo causa inconsistenza del file system poiché l'inode indica dati validi mentre la bitmap li segna come liberi.

- *Solo la bitmap scritta su disco*: la bitmap segnala un blocco come occupato, ma non esiste alcun inode che lo punti. Questo causa inconsistenza e può portare a un space leak, dove il blocco non sarà mai utilizzato correttamente.

Supponiamo ora che due writes su tre abbiano avuto successo. Scenari:

Nel caso in cui due scritture su tre abbiano avuto successo, si verificano i seguenti scenari:

- *Inode e bitmap scritti su disco*: il blocco è marcato come "allocato" nella bitmap e l'inode contiene i puntatori al blocco, che però contiene "garbage data" perché i dati corretti non sono scritti. Non si crea un'inconsistenza del file system, ma l'utente perde dati, possibilmente sensibili.

- *Inode e blocco scritti su disco*: i data-blocks contengono i dati desiderati e l'inode punta correttamente a questi blocchi. Tuttavia, il blocco potrebbe essere sovrascritto, poiché è marcato come libero nella bitmap e quindi non sarà accessibile.

- *Bitmap e blocco scritti su disco*: il blocco è fisicamente presente e marcato come occupato nella bitmap, ma nessun inode lo punta. Di conseguenza, il blocco non sarà accessibile e non è chiaro a quale file appartenga.

==== Soluzione 1: FS check
Un approccio iniziale per risolvere il problema di crash consistency consisteva nel permettere che il sistema continui a funzionare durante l'errore, per poi correggere le incongruenze all'avvio. Questa operazione veniva generalmente affidata a uno strumento chiamato fsck.

fsck ha lo scopo di individuare e riparare le "inconsistenze" del file system, anche se non può risolvere tutte le problematiche (ad esempio, se un inode punta a "garbage data", non è possibile recuperare i dati corretti). Il tool viene eseguito prima che il file system venga montato e reso disponibile, assumendo che non ci siano operazioni in corso sul file system durante la sua esecuzione. Al termine, fsck restituisce un file system consistente e accessibile all'utente. Le fasi di esecuzione di fsck sono le seguenti:

+ *Superblock*: Verifica la correttezza del superblock, che contiene metadati cruciali sul file system. Durante questa fase viene eseguito un sanity check, che verifica, ad esempio, che la dimensione del file system sia maggiore del numero di blocchi allocati. Se il superblock è corrotto, viene sostituito con una copia funzionante.

+ *Free blocks*: Scansiona gli inodes, i blocchi indiretti, e così via, per generare una versione corretta della data bitmap basata sulle informazioni contenute negli inodes. Viene eseguita una scansione analoga per gli inodes e la loro bitmap.

+ *Inode state*: Ogni inode viene verificato per eventuali danni o anomalie. Se un inode è compromesso e non può essere facilmente riparato, viene "pulito" (clear) e la relativa bitmap aggiornata.

+ *Inode links*: fsck controlla il link count di ogni inode allocato, cioè il numero di directory che contengono un riferimento a quel file. Scansionando l'intero albero delle directory a partire dalla root, fsck confronta il proprio link count con quello presente nel file system e aggiorna quest'ultimo se necessario.

+ *Duplicates*: fsck verifica l'eventuale presenza di puntatori duplicati, come nel caso in cui due inode diversi puntano allo stesso blocco. Se un inode è corrotto, può essere "pulito" oppure, se necessario, il blocco viene duplicato, garantendo che ogni inode abbia la propria copia del blocco.

+ *Bad blocks*: Viene eseguito un controllo sui puntatori che potrebbero indirizzare a blocchi corrotti. Un puntatore è considerato corrotto se fa riferimento a un blocco al di fuori di un range valido (ad esempio, se punta a un blocco più grande della partizione). In tal caso, fsck rimuove semplicemente il puntatore, senza ulteriori operazioni.

+ *Directory checks*: fsck esegue una verifica sull'integrità delle directory. Si assicura che le voci "." e ".." siano le prime entries e che ogni inode riferito a una voce di directory sia allocato correttamente. Inoltre, verifica che le directory non contengano cicli, garantendo che siano collegate correttamente tra loro.

Il principale problema di questo approccio è la sua lentezza. Più grande è la partizione, più tempo è necessario per eseguire fsck. Con l'introduzione dei dischi RAID, il processo è diventato ancora più complesso e rallentato. Sebbene fsck funzioni correttamente, è una soluzione che comporta un significativo spreco di tempo.

==== Soluzione 2: Journaling

Una soluzione comune per affrontare la problematica di crash consistency è il write-ahead logging, noto nel contesto dei file system come *journaling o Write-Ahead Logging*. Consiste nell'anticipare l'aggiornamento delle strutture dati su disco, registrando prima un "log" (un registro) che descrive l'operazione imminente. Questo log viene scritto in una zona del disco di cui si conosce la posizione e viene chiamato appunto journal (da cui il termine write-ahead logging). In questo modo, se si verifica un crash durante l'aggiornamento delle strutture dati, il sistema può consultare il log per determinare esattamente cosa correggere e come farlo.

Con il journaling, dopo un crash, invece di eseguire una scansione completa del disco tramite fsck, è possibile andare direttamente alla sorgente del problema, riducendo significativamente il tempo necessario per il recupero. Sebbene l'introduzione di un log aggiunga un piccolo carico durante la fase di aggiornamento, essa riduce notevolmente i tempi di recupero dopo un crash.

Per comprendere come funziona, prendiamo ad esempio il file system Linux ext3. Il disco è suddiviso in groups-blocks, ciascuno dei quali contiene una bitmap per gli inodes, una bitmap per i dati e gli stessi inodes e blocchi di dati. Una struttura chiave in questo contesto è il blocco "journal", che occupa uno spazio ridotto all'interno della partizione (o su un altro dispositivo).

#image("../../images/journaling/journal block.png")

==== Esempio pratico:

Supponiamo di voler eseguire l'aggiornamento di un inode (I[v2]), una bitmap (B[v2]) e un data block (Db).

#image("../../images/journaling/data jou.png")

Prima di scrivere questi dati su disco, il sistema registra le informazioni necessarie nel log (journal), in particolare:
- *TxB*: "Transaction Begin", che contiene informazioni sull'aggiornamento imminente, come gli indirizzi finali di I[v2], B[v2] e Db, oltre a un identificatore della transazione (TID).
- *TxE*: "Transaction End", che segna la fine della transazione e include anch'esso l'TID.
- Tra *TxB* e *TxE*, i blocchi di dati contengono esattamente il contenuto degli inodes e della bitmap (questo è noto come physical logging). Esiste anche l'alternativa del logical logging, in cui vengono registrate rappresentazioni logiche dell'aggiornamento.

Una volta che il blocco journal è stato scritto su disco, si può procedere con l'aggiornamento delle strutture dati originali (questo processo è noto come checkpointing). Il file system scrive I[v2], B[v2] e Db nelle locazioni appropriate su disco.

La sequenza delle operazioni è quindi la seguente:
+ *Journal Write*: Il sistema scrive nel log le informazioni necessarie per la transazione.
+ *Checkpoint*: Il sistema applica gli aggiornamenti alle strutture dati sul disco.

==== Gestione dei crash durante la scrittura

Cosa succede se un crash avviene durante la scrittura del blocco journal?

#image("../../images/journaling/data jou 2.png")

Il sistema sta cercando di scrivere i blocchi della transazione su disco (TxB, I[v2], B[v2], Db, TxE). Una soluzione semplice potrebbe essere quella di eseguire una scrittura per volta, attendendo che ogni scrittura sia completata prima di passare alla successiva. Sebbene questo approccio funzioni, è inefficiente. D'altro canto, scrivere tutti i blocchi in una sola volta non è sicuro, poiché il disco potrebbe ottimizzare l'I/O e scrivere i blocchi nell'ordine sparso (ad esempio, prima TxB, poi I[v2], B[v2], TxE, e infine Db). Se il crash avviene dopo che TxE è stato scritto ma prima di Db, il file system troverà una transazione "completa" (con un inizio e una fine), ma in realtà il sistema non può sapere che la transazione è incompleta. Al riavvio, il sistema potrebbe erroneamente copiare il contenuto del "garbage-block" nel blocco Db, con il rischio di perdita di dati.

#image("../../images/journaling/data jou 3.png")

Per evitare questo problema, il file system adotta una scrittura in due fasi. Prima vengono scritti nel journal tutti i blocchi tranne TxE (questi blocchi vengono scritti in una sola operazione). A questo punto, il file system può scrivere anche TxE nel journal, garantendo così l'atomicità dell'operazione. Il disco garantisce che le scritture da 512 byte (dimensione di un settore) vengano eseguite in modo atomico, quindi TxE deve essere di 512 byte per garantire il corretto funzionamento.

==== Sequenza di Aggiornamento del FS

Il protocollo di aggiornamento del file system, quindi, sarà:
+ *Journal Write*: Scrittura del contenuto della transazione nel journal, inclusi TxB, metadati e dati. Il sistema attende che queste scritture siano completate.
+ *Journal Commit*: Scrittura del "commit-block" (TxE) nel journal e attesa del completamento di questa scrittura.
+ *Checkpoint*: Applicazione degli aggiornamenti nelle locazioni appropriate su disco.

Con questa strategia, il file system è in grado di gestire i crash in modo più sicuro e ridurre il tempo necessario per il recupero, pur mantenendo l'affidabilità e la consistenza delle operazioni.

=== Recovery

Abbiamo precedentemente visto che il blocco journal (la "nota") può essere utilizzato per il recupero (recovery) dopo un crash. Un crash, o una perdita di corrente, può verificarsi in qualsiasi momento. Se il crash accade prima che la transazione sia completata (ovvero prima del "journal commit"), il processo di recupero è relativamente semplice: l'operazione in sospeso viene semplicemente ignorata. Se, invece, il crash si verifica dopo che la transazione ha scritto nel commit block ma prima che il checkpoint sia completato, il file system è in grado di riprendere l'aggiornamento.

Durante l'avvio del sistema dopo un crash, il processo di recupero del file system esamina il log per identificare le transazioni che erano state "committed", ossia quelle che avevano tentato di scrivere su disco. Le transazioni vengono quindi eseguite nuovamente, nell'ordine in cui sono state registrate, per aggiornare le strutture dati appropriate. Questo processo, noto come *redo logging*, garantisce che il file system riporti le sue strutture su disco a uno stato consistente.

Nel caso in cui il crash avvenga durante il checkpoint, il contenuto del journal può essere letto durante il recovery e l'aggiornamento verrà ripetuto. Anche se il crash avviene all'ultima fase del processo, il sistema eseguirà tutte le scritture necessarie, considerando che i crash del file system sono eventi rari.

==== Performance del recovery

Il protocollo di journaling potrebbe generare un traffico I/O aggiuntivo. Ad esempio, supponiamo di creare due file, "file1" e "file2", nella stessa directory. Per creare ogni file è necessario aggiornare diverse strutture su disco: la inode bitmap (per allocare un nuovo inode), l'inode stesso, il blocco dati della directory contenente la nuova entry, e l'inode della directory (che ora ha un nuovo access time).

Nel caso del journaling, tutte queste informazioni vengono scritte nello stesso blocco journal per entrambe le operazioni di "file creation". Poiché i file si trovano nella stessa directory e gli inodes sono probabilmente nello stesso blocco su disco, potrebbe succedere che lo stesso blocco venga scritto più volte (ad esempio, scriviamo prima l'inode di "file1", poi quello di "file2", sovrascrivendo quello di "file1", e così via). Una soluzione a questo problema consiste nell'utilizzare un buffer globale nel quale vengono raccolte le transazioni. Tuttavia, se il buffer continua ad accumulare transazioni, potrebbe riempirsi rapidamente.

#image("../../images/journaling/data jou 4.png")

I problemi derivanti dall'accumulo di transazioni sono i seguenti:
- Più grande è il log, più tempo sarà necessario per eseguire il recovery.
- Quando il log si riempie o è quasi pieno, non sarà possibile registrare nuove transazioni, rendendo di fatto il file system inutilizzabile.

Per affrontare questi problemi, i file system con journaling trattano il log come una struttura dati circolare, riutilizzandola continuamente. Questo è il motivo per cui il journaling è noto come *circular log*. Quando una transazione è completata, il file system libera lo spazio relativo ad essa. Una soluzione semplice consiste nel marcare le transazioni vecchie e "non-checkpointed" all'interno di un superblock del journal.

#image("../../images/journaling/data jou 5.png")

Nel superblock del journal ci sono informazioni sufficienti per determinare quale blocco non ha ancora raggiunto la fase di checkpoint. Questo approccio riduce notevolmente il tempo di recupero, poiché non è necessario ripetere tutte le transazioni, ma solo quelle incompletate.

==== Schema del protocollo di recovery

Il nostro protocollo di journaling si evolve nel seguente modo:
1. *Journal Write*: Scrittura di TxB e dei tre blocchi intermedi.
2. *Journal Commit*: Scrittura del blocco TxE.
3. *Checkpoint*: Applicazione degli aggiornamenti alle strutture dati nel file system.
4. *Free*: Se la transazione è completata, viene marcata come liberata nel superblock.

==== Ottimizzazione del traffico I/O

Le operazioni di scrittura su disco sono costose, e un aspetto problematico del journaling è che scriviamo due volte le stesse informazioni: una volta nel journal e una volta nella locazione finale su disco. Questo doppio processo aumenta il traffico di dati su disco, anche se il recovery è molto rapido. Una possibile soluzione per ridurre il traffico e ottimizzare il procedimento è il *data journaling* (come in ext3 di Linux), che registra tutti i dati utente nel journal, oltre ai metadati del file system.

Un'altra soluzione è il *ordered journaling* (o metadata journaling), in cui vengono registrati solo i metadati nel journal e non i dati utente (eliminando il blocco Db dal journal). Tuttavia, questo approccio introduce delle difficoltà: l'ordine in cui vengono scritte le informazioni su disco diventa cruciale. Se il blocco dei dati viene scritto dopo che la transazione è stata completata, i puntatori dell'inode potrebbero puntare a dati corrotti (ad esempio, le bitmap e gli inodes sono aggiornati, ma Db no). Inoltre, il recovery diventa più complesso, poiché Db non è più nel journal.

Un protocollo per risolvere queste problematiche potrebbe essere il seguente:
1. *Data Write*: I dati vengono scritti nella locazione finale.
2. *Journal Metadata Write*: Vengono scritti l'inizio del blocco e i metadati nel journal.
3. *Journal Commit*: Viene scritta la fine della transazione (TxE) nel journal.
4. *Checkpoint Metadata*: I metadati vengono scritti nella locazione finale nel file system.
5. *Free*: La transazione viene marcata come liberata nel superblock.

==== Block Reuse
Immaginiamo di usare una forma di metadata journaling. Supponiamo di avere una directory chiamata "foo" e che l'utente aggiunga una voce a questa directory (creando un nuovo file). Il contenuto della directory viene scritto nel log, poiché le directory sono considerate metadati. Immaginiamo ora che il blocco dati di "foo" abbia l'indirizzo "1000". In questo caso, il log conterrà informazioni come:

#image("../../images/journaling/data jou 6.png")


Supponiamo che l'utente elimini tutto dalla directory e successivamente la directory stessa, liberando il blocco "1000". Poi, l'utente crea un nuovo file chiamato "foolbar", che finisce per utilizzare lo stesso blocco "1000", che in precedenza apparteneva alla directory "foo". L'inode di "foolbar" viene scritto su disco, così come i suoi dati, ma solo l'inode viene scritto nel journal.

#image("../../images/journaling/data jou 7.png")


Se si verifica un crash e queste informazioni sono ancora nel log, si crea un grosso problema, poiché il blocco "1000" (contenente i dati di "foolbar") viene sovrascritto con i dati della directory "foo". Per evitare questo problema, il file system può utilizzare un tipo speciale di record nel journal chiamato revoke record. Quando una directory viene eliminata, come nell'esempio, viene scritto un revoke record nel journal. Durante il recovery, il sistema esaminerà prima il revoke record e non riscriverà i dati che sono stati "revocati".

#figure(
  image("../../images/journaling/dj timeline.png"),
  caption: [Data journaling timeline.],
)

#figure(
  image("../../images/journaling/dj timeline.png"),
  caption: [Metadata journaling timeline.],
)

==== Approcci Alternativi

Esistono anche altri approcci al di fuori del journaling. Uno di questi è *Soft Updates*, che si basa sull'ordinamento accurato delle scritture al file system per garantire che le strutture su disco non vengano mai lasciate in uno stato inconsistente (ad esempio, scrivendo un blocco dati prima che l'inode punti ad esso). Un altro approccio è *Copy-on-Write* (COW), che implica la scrittura di nuove copie di un blocco di dati invece di modificarlo direttamente. Questi sono solo alcuni degli approcci adottati dai file system per garantire la consistenza e l'affidabilità.

#line()