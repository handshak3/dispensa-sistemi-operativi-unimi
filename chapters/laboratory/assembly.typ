#import "@preview/codly:1.0.0": *

#show: codly-init.with()

= Cheat Sheet Assembly x86

== Registri Principali

#table(
  columns: 2,
  [*Registro*], [*Descrizione*],
  `EAX`, [Accumulatore per operazioni aritmetiche e logiche],
  `EBX`, [Registro base],
  `ECX`, [Contatore per loop],
  `EDX`, [Registro dati],
  `ESI`, [Indice sorgente per operazioni su stringhe],
  `EDI`, [Indice destinazione per operazioni su stringhe],
  `EBP`, [Puntatore di base per lo stack frame],
  `ESP`, [Puntatore dello stack],
  `EIP`, [Puntatore dell'istruzione]
)

== Istruzioni di Movimento Dati

#table(
  columns: 3,
  [*Istruzione*], [*Descrizione*], [*Esempio*],
  `MOV`, [Copia dati da sorgente a destinazione], `MOV EAX, EBX`,
  `PUSH`, [Inserisce un valore nello stack], `PUSH EAX`,
  `POP`, [Estrae un valore dallo stack], `POP EAX`,
  `XCHG`, [Scambia i valori tra due operandi], `XCHG EAX, EBX`
)

== Istruzioni Aritmetiche

#table(
  columns: 3,
  [*Istruzione*], [*Descrizione*], [*Esempio*],
  `ADD`, [Aggiunge sorgente a destinazione], `ADD EAX, 1`,
  `SUB`, [Sottrae sorgente da destinazione], `SUB EAX, EBX`,
  `MUL`, [Moltiplica senza segno], `MUL EBX`,
  `IMUL`, [Moltiplica con segno], `IMUL EBX`,
  `DIV`, [Divide senza segno], `DIV EBX`,
  `IDIV`, [Divide con segno], `IDIV EBX`,
  `INC`, [Incrementa di 1], `INC EAX`,
  `DEC`, [Decrementa di 1], `DEC EAX`
)

== Istruzioni Logiche

#table(
  columns: 3,
  [*Istruzione*], [*Descrizione*], [*Esempio*],
  `AND`, [AND logico bit a bit], `AND EAX, EBX`,
  `OR`, [OR logico bit a bit], `OR EAX, EBX`,
  `XOR`, [XOR logico bit a bit], `XOR EAX, EBX`,
  `NOT`, [Complemento a uno], `NOT EAX`,
  `SHL`, [Shift a sinistra], `SHL EAX, 1`,
  `SHR`, [Shift a destra], `SHR EAX, 1`,
  `CMP`, [Confronta due operandi], `CMP EAX, EBX`
)

== Istruzioni di Controllo di Flusso

#table(
  columns: 3,
  [*Istruzione*], [*Descrizione*], [*Esempio*],
  `JMP`, [Salta a un'etichetta], `JMP label`,
  `JE`, [Salta se uguale (ZF=1)], `JE label`,
  `JNE`, [Salta se diverso (ZF=0)], `JNE label`,
  `JG`, [Salta se maggiore (SF=OF) e (ZF=0)], `JG label`,
  `JL`, [Salta se minore (SF≠OF)], `JL label`,
  `JGE`, [Salta se maggiore o uguale (SF=OF)], `JGE label`,
  `JLE`, [Salta se minore o uguale (ZF=1 o SF≠OF)], `JLE label`,
  `CALL`, [Chiama una subroutine], `CALL subroutine`,
  `RET`, [Ritorna da una subroutine], `RET`
)

== Direttive comuni

#table(
  columns: 3,
  [*Direttiva*], [*Descrizione*], [*Esempio*],
  `.data`, [Sezione dati], [],
  `.bss`, [Sezione dati non inizializzati], [],
  `.text`, [Sezione codice], [],
  `.global`, [Definisce simboli globali], `.global _start`
)

== System Call
#table(
  columns: 5,
  [*%eax*], [*Nome*], [*%ebx*], [*%ecx*], [*%edx*],
  [1], [sys_exit], [int], [-], [-],
  [2], [sys_fork], [-], [-], [-],
  [3], [sys_read], [unsigned int], [char \*], [size_t],
  [4], [sys_write], [unsigned int], [const char \*], [size_t],
  [5], [sys_open], [const char \*], [int], [int],
  [6], [sys_close], [unsigned int], [-], [-]
)

#align(center)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [
      === sys_exit
      #table(
        columns: (1fr, 2fr),
        [*Registro*], [*Descrizione*],
        [%ebx], [Codice di uscita del processo],
      )
    ],
    [
      === sys_fork
      #table(
        columns: (1fr, 2fr),
        [*Registro*], [*Descrizione*],
        [%ebx], [-],
      )
    ],
  )
]

#align(center)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [
      === sys_read
      #table(
        columns: (1fr, 2fr),
        [*Registro*], [*Descrizione*],
        [%ebx], [File descriptor],
        [%ecx], [Buffer di lettura],
        [%edx], [Numero di byte da leggere],
      )
    ],
    [
      === sys_write
      #table(
        columns: (1fr, 2fr),
        [*Registro*], [*Descrizione*],
        [%ebx], [File descriptor],
        [%ecx], [Buffer da scrivere],
        [%edx], [Numero di byte da scrivere],
      )
    ],
  )
]

== System call in assembly

=== sys_exit (1)
```asm
section .text
    global _start

_start:
    mov eax, 1      ; sys_exit
    xor ebx, ebx    ; Codice di uscita (0 = successo)
    int 0x80
```

=== sys_fork (2)
```asm
section .text
    global _start

_start:
    mov eax, 2      ; sys_fork
    int 0x80
    test eax, eax
    jz child_process
    mov eax, 1      ; sys_exit
    xor ebx, ebx
    int 0x80

child_process:
    mov eax, 1      ; sys_exit
    mov ebx, 42     ; Codice di uscita 42
    int 0x80
```

=== sys_read (3)
```asm
section .bss
    buffer resb 100

section .text
    global _start

_start:
    mov eax, 3      ; sys_read
    mov ebx, 0      ; File descriptor (0 = stdin)
    mov ecx, buffer ; Indirizzo del buffer
    mov edx, 100    ; Numero massimo di byte da leggere
    int 0x80
    mov eax, 1      ; sys_exit
    xor ebx, ebx
    int 0x80
```

=== sys_write (4)
```asm
section .data
    message db "Hello, World!", 0xA
    length equ $-message

section .text
    global _start

_start:
    mov eax, 4      ; sys_write
    mov ebx, 1      ; File descriptor (1 = stdout)
    mov ecx, message ; Indirizzo della stringa
    mov edx, length  ; Lunghezza della stringa
    int 0x80
    mov eax, 1      ; sys_exit
    xor ebx, ebx
    int 0x80
```

=== sys_open (5)
```asm
section .data
    filename db "test.txt", 0

section .text
    global _start

_start:
    mov eax, 5      ; sys_open
    mov ebx, filename ; Indirizzo del nome file
    mov ecx, 0      ; Flag (0 = sola lettura)
    mov edx, 0      ; Mode (ignorato se sola lettura)
    int 0x80
    mov ebx, eax    ; Salva il file descriptor
    mov eax, 1      ; sys_exit
    xor ebx, ebx
    int 0x80
```

=== sys_close (6)
```asm
section .data
    filename db "test.txt", 0

section .text
    global _start

_start:
    mov eax, 5      ; sys_open
    mov ebx, filename ; Indirizzo del nome file
    mov ecx, 0      ; Flag (0 = sola lettura)
    mov edx, 0      ; Mode (ignorato se sola lettura)
    int 0x80
    mov ebx, eax    ; File descriptor da chiudere
    mov eax, 6      ; sys_close
    int 0x80
    mov eax, 1      ; sys_exit
    xor ebx, ebx
    int 0x80
```

#colbreak()