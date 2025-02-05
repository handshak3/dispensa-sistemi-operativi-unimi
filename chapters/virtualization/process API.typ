#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Process API
*Process IDentification (PID)*: Identificatore del processo.

*Scheduler*: determina quale processo verrà eseguito in un determinato momento. Di solito non è deterministico il figlio potrebbe essere eseguito prima del padre (porta problematiche per i programmi multi thread).

=== System call `fork()`
*`fork()`*: una system call che l'OS fornisce come metodo per creare un nuovo processo. Il processo figlio è quasi identico al padre, cambia solamente l'ID. La `fork` al processo padre restituisce l'ID del processo figlio. Al processo figlio restituisce 0.

Rimangono gli stessi:
- L'indirizzo di memoria del processo padre.
- I registri del processo padre.
- I file aperti dal processo padre.
- I segnali inviati al processo padre.
- Il codice e i dati del processo padre.

Il processo figlio non ha il main come entry point ma la stringa successiva alla sua creazione.

#figure(
  text(9pt)[
    ```c
    process = fork();
    if (process === 0) {
    	// Processo creato (codice eseguito solamente dal figlio)
    } else if (process < 0) {
    	// Errore (processo non creato)
    } else {
    	// Processo padre (codice eseguito solamente dal padre)
    }
    // Codice eseguito da padre e figlio
    ```
  ],
  caption: [Utilizzo della `fork()`. ],
)

=== System call `exec()`
*`exec()`*: sostituisce il processo corrente con uno che eseguirà un altro programma. Carica il codice (e i dati statici) del programma che si vuole eseguire e li sovrascrive al segmento di codice corrente. Non viene creato un nuovo processo ma viene trasformato quello preesistente.

#text(9pt)[
  ```c
  int exec(const char *filename, char *const argv[], char *const envp[]);
  ```
]

L'istruzione `exec()` sostituisce il processo corrente con un nuovo processo che esegue il programma specificato in `filename`. Gli argomenti del programma sono specificati in `argv`. L'array di ambiente (contiene le variabili di ambiente) è specificato in `envp`.

=== System call `wait()`
*`wait()`*: la chiamata ritarda l'esecuzione del padre fino al termine dell'esecuzione del figlio. Quando il figlio ha finito, `wait()` ritorna al genitore. Rende l'output deterministico.

*Processo zombie*: processo che ha completato la sua esecuzione e ha chiamato `exit()`, ma il suo processo padre non ha ancora eseguito la chiamata di sistema `wait()` per leggere il suo stato di uscita.

Dettagli chiave:
- Il processo zombie non consuma risorse CPU.
- Mantiene una voce minima nella process table.
- Esiste solo per permettere al padre di recuperare il suo codice di uscita (exit status).
- Se il padre non chiama mai `wait()`, il processo zombie rimarrà nella process table.
- In casi estremi, troppi processi zombie possono esaurire le risorse della process table.

Motivi per cui si verificano i processi zombie:
- Il processo padre non si aspetta la terminazione del processo figlio.
- Il processo padre non è in grado di chiamare la funzione `wait()` a causa di un errore.
- Il processo padre è stato terminato.

#line()