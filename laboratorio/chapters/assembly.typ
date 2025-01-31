== Assambly

#figure(
  table(
    columns: 5,
    [*%eax*], [*Nome*], [*%ebx*], [*%ecx*], [*%edx*],
    [1], [sys_exit], [int], [-], [-],
    [2], [sys_fork], [struct pt_regs], [-], [-],
    [3], [sys_read], [unsigned int], [char \*], [size_t],
    [4], [sys_write], [unsigned int], [const char \*], [size_t],
    [5], [sys_open], [const char \*], [int], [int],
    [6], [sys_close], [unsigned int], [-], [-],
  ),
  caption: [Tabella delle principali syscall.],
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
        [%ebx], [Struttura dei registri del processo],
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

#align(center)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 10pt,
    [
      === sys_open
      #table(
        columns: (1fr, 2fr),
        [*Registro*], [*Descrizione*],
        [%ebx], [Nome del file],
        [%ecx], [Modalità di apertura (flag)],
        [%edx], [Permessi (se necessario)],
      )
    ],
    [
      === sys_close
      #table(
        columns: (1fr, 2fr),
        [*Registro*], [*Descrizione*],
        [%ebx], [File descriptor da chiudere],
      )
    ],
  )
]

#colbreak()