#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Simulazione esame

=== Esercizio assembly

#text(size: 9pt)[
  ```nasm
  ; --------------------------------------------
  ; functions.asm ------------------------------
  ; --------------------------------------------

  ;---------------------------------------------
  ; int slen(String message)
  ; String length calculation function
  slen:
      push    ebx
      mov     ebx, eax

  nextchar:
      cmp     byte [eax], 0
      jz      finished
      inc     eax
      jmp     nextchar

  finished:
      sub     eax, ebx
      pop     ebx
      ret

  ;---------------------------------------------
  ; void sprint(String message)
  ; String printing function
  sprint:
      push    edx
      push    ecx
      push    ebx
      push    eax
      call    slen

      mov     edx, eax
      pop     eax

      mov     ecx, eax
      mov     ebx, 1
      mov     eax, 4
      int     80h

      pop     ebx
      pop     ecx
      pop     edx
      ret

  ;---------------------------------------------
  ; void exit()
  ; Exit program and restore resources
  quit:
      mov     ebx, 0
      mov     eax, 1
      int     80h
      ret
  ```
]

#text(size: 9pt)[
  ```nasm
  ; ----------------------------------------------------------
  ; test.asm -------------------------------------------------
  ; ----------------------------------------------------------

   %include        'functions.asm'

   SECTION .data
   aMsg        db      'This is message a', 0h
   bMsg        db      'This is message b', 0h

   SECTION .text
   global  _start

   _start:

   mov     eax, 2
   int     80h

   cmp     eax, 0
   jz      a

   b:
   mov     eax, bMsg
   call    sprint

   call    quit

   a:
   mov     eax, aMsg
   call    sprint

   call    quit
  ```
]

Rispondere alle seguenti domande riguardanti test.asm, commentando le righe corrispondenti ed iniziando il commento con un `;`.

1. Cosa stiamo caricando in `eax` a riga 16 di test.asm?
2. Commentate le righe 19 e 20 di test.asm
3. Commentate le righe da 29 a 32 (incluse) di test.asm

Risposte:
1. Nellara riga 16 in `eax` viene caricato il valore `2`. Su Linux, ogni chiamata di sistema ha un codice identificativo specifico; in questo caso, il codice `2` identifica la chiamata di sistema `fork()`. La funzione `fork()` è una chiamata di sistema che crea un nuovo processo come copia esatta di quello corrente. Dopo aver impostato `eax` a `2`, il programma utilizza l'istruzione `int 80h` per eseguire la chiamata di sistema: `int 80h` è un'interruzione software che avvisa il kernel di eseguire l'operazione richiesta, qui identificata da `eax = 2`.
2. Commento righe 19-20 di test.asm
  #text(size: 9pt)[
    ```nasm
    cmp eax, 0  ; Verifica se il processo è figlio (eax = 0) o genitore (eax > 0)
    jz  a ; Se eax è 0 (siamo nel processo figlio), salta all'etichetta "a"
    ```
  ]

3. Commento righe 29-232 di test.asm:

  #text(size: 9pt)[
    ```nasm
      a:  ; Etichetta "a", punto d'ingresso per il processo figlio
      mov eax, aMsg ; Carica l'indirizzo di "aMsg" (messaggio a) in eax
      call  sprint  ; Chiama la funzione sprint per stampare il messaggio "aMsg"
      call  quit  ; Chiama la funzione quit per terminare il processo
    ```
  ]

=== Esercizio pipeline

Utilizzare `strace` per listare tutte le chiamate di sistema effettuate durante l'esecuzione del comando `df -h` , il cui nome inizi con la lettera `s` ed il cui nome abbia, in terza posizione, una vocale. Ordinarle per frequenza di chiamata ed estrarre la chiamata di sistema effettuata più frequentemente. Stampare in output 'n syscallname' dove n è il numero di occorrenze della chiamata a syscallname. Risolvete l'esercizio utilizzando una pipeline.

#text(size: 9pt)[
  ```nasm
  strace -f df -h 2>&1 | grep '^s.[aeiou]' | cut -d '(' -f 1 | sort | uniq -c | sed 's/^ *//' | sort -nr | head -n 1
  ```
]

Oppure

#text(size: 9pt)[
  ```nasm
  strace -f df -h 2>&1 | grep '^s.[aeiou]' | cut -d '(' -f 1 | sort | uniq -c | sort -nr | head -n 1 | awk '{print $1, $2}'
  ```
]