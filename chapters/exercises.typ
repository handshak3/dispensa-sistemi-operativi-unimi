#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Scheduling

*Notazione adottata*
- *AT* = arrival time
- *RT* = response time
- *IST* = initial schedule time
- *TT* = tournaround time
- *CT* = completion time

=== Esercizio 1
*Dati*
- Scheduler FIFO
- ARG policy FIFO
- ARG jobs 4
- ARG maxlen 10

*Job*
- Job 0 (length = 8)
- Job 1 (length = 3)
- Job 2 (length = 8)
- Job 3 (length = 10)

Arrival time di tutti è 0

*Job 0 (length = 8)*
- AT = 0
- RT = IST - AT = 0CT = IST+JL = 0+8=8
- TT = CT - AT = 8 - 0 = 8

*Job 1 (length = 3)*
- AT = 0
- RT = IST - AT = 8
- CT = IST+JL = 8+3=11
- TT = CT - AT = 11 - 0 = 11

*Job 2 (length = 8)*
- AT = 0
- RT = IST - AT = 11
- CT = IST+JL = 11+8=19
- TT = CT - AT = 19 - 0 = 19

*Job 3 (length = 10)*
- AT = 0
- RT = IST - AT = 19
- CT = IST+JL = 19+10=29
- TT=CT-AT=29-0=29

*Grafico*
```
█████████████████████████████████████████████████
█    J0     █  J1 █    J2      █       J3       █
█████████████████████████████████████████████████
0           8     11           19               29
```

=== Esercizio 2
*Dati*
- Scheduler SJF
- ARG policy SJF
- ARG jobs 3
- ARG maxlen 10

*Job*
- Job 0 (length = 9)
- Job 1 (length = 8)
- Job 2 (length = 5)

*Job 2 (length = 5)*
- AT = 0
- RT = IST - AT = 0
- CT = IST+JL = 0+5=5
- TT = CT - AT = 5 - 0 = 5

*Job 1 (length = 8)*
- AT = 0
- RT = IST - AT = 5
- CT = IST+JL = 5+8=13
- TT = CT - AT = 13 - 0 = 13

*Job 0 (length = 9)*
- AT = 0
- RT = IST - AT = 13
- CT = IST+JL = 13+9=22
- TT = CT - AT = 22 - 0 = 22

*Grafico*
```
███████████████████████████████████████████████████████████████
█       J2      █         J1         █           J0           █
███████████████████████████████████████████████████████████████
0               5                    13                      22
```

=== Esercizio 3
*Dati*
- Scheduler RR
- ARG policy RR
- ARG jobs 3
- ARG maxlen 10
- Quantum slice = 1ms

*Job*
- Job 0 (length = 9)
- Job 1 (length = 8)
- Job 2 (length = 5)

*Job 0 (length = 9)*
- AT = 0
- RT = IST - AT = 0
- CT = 22
- TT = CT - AT = 22 - 0 = 22

*Job 1 (length = 8)*
- AT = 0
- RT = IST - AT = 1
- CT = 21
- TT = CT - AT = 21 - 0 = 21

*Job 2 (length = 5)*
- AT = 0
- RT = IST - AT = 2
- CT = 15
- TT = CT - AT = 15 - 0 = 15

```
███████████████████████████████████████████████████████████████████
█J0█J1█J2█J0█J1█J2█J0█J1█J2█J0█J1█J2█J0█J1█J2█J0█J1█J0█J1█J0█J1█J0█
███████████████████████████████████████████████████████████████████
0                                                                22
```

== Segmentation

=== Esercizio 1
*Dati*
- Seed: 0
- Address space size: 1k ($2^10$)
- Physical memory size: 16k

*Informazioni sui segmenti*\
Segmento 0 (cresce positivamente):
- Base: `0x00001aea` (decimale: 6890)
- Limit: 472

Segmento 1 (cresce negativamente):
- Base: `0x00001254` (decimale: 4692)
- Limit: 450

*Calcolo per VA 0: `0x0000020b` (523)*
+ Identificazione del segmento:
  Poiché l'address space size è $2^10 = 1024$, il MSB è in posizione 9.\
  $523_10 = 1000001011_2$\
  MSB = 1 $==> $ il VA appartiene al segmento 1.

+ Calcolo dell'offset: Offset = $523 - 1024 = -501$.

+ Validazione dell'offset: $|-501| > 450 ==>$ SEGMENTATION FAULT.

*Calcolo per VA 1: `0x0000019e` (414)*
+ Identificazione del segmento:\
  $414_10 = 0110011110_2$\
  Il MSB bit è 0 quindi il VA appartiene al segmento 0.

+ Calcolo dell'offset: Offset = $414$.

+ Validazione dell'offset: $414 < 472 ==>$ offset valido.

+ Calcolo dell'indirizzo fisico: PA = 6890 + 414 = 7304

*Calcolo per VA 2: `0x00000322` (802)*
+ Identificazione del segmento:\
  $802_10 = 1100100010_2$\
  Il MSB bit è 1 quindi il VA appartiene al segmento 1.

+ Calcolo dell'offset: Offset = $802 - 1024 = -222$.

+ Validazione dell'offset:$|-222| < 450 ==>$ offset valido.

+ Calcolo dell'indirizzo fisico: PA = $4692 - 222 = 4470$.

*Calcolo per VA 3: `0x00000136` (310)*
+ Identificazione del segmento:\
  $310_10 = 0100110110_2$\
  Il MSB bit è 0 quindi il VA appartiene al segmento 0.

+ Calcolo dell'offset: Offset = $310$.

+ Validazione dell'offset: $310 < 472 ==>$ offset valido.

+ Calcolo dell'indirizzo fisico: PA = $6890 + 310 = 7200$.

*Calcolo per VA 4: `0x000001e8` (488)*
+ Identificazione del segmento:\
  $488_10 = 0111101000_2$\
  Il MSB bit è 0 quindi il VA appartiene al segmento 0.

+ Calcolo dell'offset: Offset = $488$.

+ Validazione dell'offset: $488 > 472 ==>$ SEGMENTATION FAULT.

=== Esercizio 2
Si consideri un sistema con memoria virtuale e segmentazione, dove ogni parola ha dimensione di un byte. Gli indirizzi logici sono composti da 10 bit, dei quali i primi 4 bit più significativi indicano il numero di segmento.

1. Qual è la massima grandezza possibile per un segmento?
  - Gli ultimi $10 - 4 = 6$ bit rappresentano l'offset all'interno del segmento.
  - Massima grandezza di un segmento: $2^6 = 64$ byte.

2. Di quanti segmenti al più può essere composto un processo?
  - I primi 4 bit indicano il numero di segmento.
  - Numero massimo di segmenti: $2^4 = 16$.

*Dati della Tabella dei Segmenti*

Supponendo che il processo attualmente in esecuzione sia composto da 5 segmenti ($S_0$, $S_1$, $S_2$, $S_3$, $S_4$), la tabella dei segmenti è la seguente:

#table(
  columns: 3,
  [N. segmento], [Lunghezza (byte)], [Base (PA)],
  [0], [10], [200],
  [1], [20], [100],
  [2], [6], [252],
  [3], [32], [720],
  [4], [32], [683],
)

*Traduzione*

*VA: $9$*
- Decomposizione: 9 = 0000, 001001 → Segmento $0$, Offset $9$.
- Validazione: Offset $9 < 10$ (limite del segmento $0$).
- Indirizzo Fisico: PA = 200 + 9 = 209.

*VA: $132$*
- Decomposizione: 132 = 0100 , 00100 → Segmento $4$, Offset $4$.
- Validazione: Offset $4 < 32$ (limite del segmento $4$).
- Indirizzo Fisico: PA = 683 + 4 = 687.

*VA: $79$*
- Decomposizione: 79 = 0001 , 001111 → Segmento $1$, Offset $15$.
- Validazione: Offset $15 < 20$ (limite del segmento $1$).
- Indirizzo Fisico: PA = 100 + 15 = 115.

*VA: $64$*
- Decomposizione: 64 = 0001 , 000000 → Segmento $1$, Offset $0$.
- Validazione: Offset $0 < 20$ (limite del segmento $1$).
- Indirizzo Fisico: PA = 100 + 0 = 100.

*VA: $259$*
- Decomposizione: 259 = 1000 , 000011 → Segmento $8$, Offset $3$.
- Validazione: Il segmento $8$ non esiste (solo $S_0$-$S_4$).
- Risultato: INVALID SEGMENT.

*VA: $135$*
- Decomposizione: 135 = 0100 , 000111 → Segmento $4$, Offset $7$.
- Validazione: Offset $7 < 32$ (limite del segmento $4$).
- Indirizzo Fisico: PA = 683 + 7 = 690.

*VA: $320$*
- Decomposizione: 320 = 1010 , 000000 → Segmento $10$, Offset $0$.
- Validazione: Il segmento $10$ non esiste (solo $S_0$-$S_4$).
- Risultato: INVALID SEGMENT.

*Risultati Finali*
#table(
  columns: 5,
  [VA (decimale)], [Segmento], [Offset], [Validità], [PA (decimale)],
  [9], [0], [9], [Valid], [209],
  [132], [1], [12], [Valid], [115],
  [64], [1], [0], [Valid], [100],
  [259], [8], [3], [Invalid Segment], [-],
  [135], [4], [7], [Valid], [690],
  [320], [10], [0], [Invalid Segment], [-],
)

=== Esercizio 3

In questo esercizio sulla segmentazione, si richiede di determinare i valori di base e bound dei due segmenti a partire dalla traccia delle traduzioni di memoria.

- Dimensione dello spazio di indirizzamento virtuale (AS): 128 byte = $2^7$
  - Indirizzi virtuali da $0$ a $127$.
  - 1 bit per il numero di segmento ($2$ segmenti), 6 bit per l'offset.

- Segmento 0: Cresce positivamente (code + heap).
- Segmento 1: Cresce negativamente.

*Dati della Traccia*

#table(
  columns: 5,
  [VA (hex)], [VA (dec)], [Risultato], [PA (hex)], [PA (dec)],
  [`0x0000006c`], [108], [VALID in SEG1], [`0x000003ec`], [1004],
  [`0x0000001d`], [29], [VALID in SEG0], [`0x0000021d`], [541],
  [`0x00000050`], [80], [VIOLATION (SEG1)], [-], [-],
  [`0x0000001e`], [30], [VIOLATION (SEG0)], [-], [-],
  [`0x00000058`], [88], [VALID in SEG1], [`0x000003d8`], [984],
  [`0x00000061`], [97], [VALID in SEG1], [`0x000003e1`], [993],
  [`0x00000035`], [53], [VIOLATION (SEG0)], [-], [-],
  [`0x00000021`], [33], [VIOLATION (SEG0)], [-], [-],
  [`0x00000064`], [100], [VALID in SEG1], [`0x000003e4`], [996],
  [`0x0000003d`], [61], [VIOLATION (SEG0)], [-], [-],
  [`0x0000000c`], [12], [VALID in SEG0], [`0x0000020c`], [524],
  [`0x00000005`], [5], [VALID in SEG0], [`0x00000205`], [517],
  [`0x0000002f`], [47], [VIOLATION (SEG0)], [-], [-],
)

*Calcolo dei valori di base e bound*
1. Base del Segmento 1 (cresce negativamente):
  - Indirizzo fisico finale: $1004$.
  - Offset: $108 - 128 = -20$.
  - Base: $1004 + 20 = 1024$.

2. Base del Segmento 0 (cresce positivamente):
  - Indirizzo fisico finale: $541$.
  - Offset: $29$.
  - Base: $541 - 29 = 512$.

3. Bound del Segmento 1:
  - Offset massimo valido: tra $41$ e $48$.
  - Scelta: $41$ (più sicuro).

4. Bound del Segmento 0:
  - Offset massimo valido: $< 30$.
  - Scelta: $29$ (più sicuro).

*Risultati Finali*

#table(
  columns: 3,
  [Segmento], [Base (decimale)], [Bound (decimale)],
  [SEG 0], [512], [29],
  [SEG 1], [1024], [41],
)
=== Esercizio 4

*Dati*
- ARG address space size 32 byte
- ARG phys mem size 128 byte

*Segment register information*\
Segmento 0 (cresce positivamente):
- Base: 98
- Limit: 9

Segmento 1 (cresce negativamente):
- Base: 66
- Limit: 1

*VA = 25*
+ Identificazione del segmento:\
  $25_10 = 11001_2$\
  MSB = 1 $==>$ Il VA è nel Segmento 1.
+ Calcolo dell'offset:\
  Offset = 32 - 25 = 7 $<=$ 9 $==>$ Offset valido.
+ Traduzione: PA = 66 - 7 = 59

*VA = 17*
+ Identificazione del segmento:\
  $17_10 = 10001_2$\
  MSB = 1 $==>$ Il VA è nel Segmento 1.
+ Calcolo dell'offset: Offset = 32 - 17 = 15 > 9 $==>$ Offset NON valido.

*VA = 2*
+ Identificazione del segmento:\
  $2_10 = 00010_2$\
  MSB = 0 $==>$ Il VA è nel Segmento 0.
+ Calcolo dell'offset:\
  Offset = 2 $<=$ 9 $==>$ Offset valido.
+ Traduzione: PA = 98 + 2 = 100

*VA = 14*
+ Identificazione del segmento:\
  $14_10 = 01110_2$\
  MSB = 0 $==>$ Il VA è nel Segmento 0.
+ Calcolo dell'offset:\
  Offset = 14 $>$ 9 $==>$ Offset NON valido.

*VA = 1*
+ Identificazione del segmento:\
  $1_10 = 00001_2$\
  MSB = 0 $==>$ Il VA è nel Segmento 0.
+ Calcolo dell'offset:\
  Offset = 1 $<=$ 9 $==>$ Offset valido.
+ Traduzione: PA = 98 + 2 = 100

=== Esercizio 5
*Dati*
- ARG seed 1
- ARG address space size 1k
- ARG phys mem size 16k

*Segment register information*\
Segmento 0 (cresce positivamente):
- Base: 12513
- Limit: 290

Segmento 1 (cresce negativamente):
- Base: 4651
- Limit: 472

#figure(
  image("../images/segmentation/segmentation seed 1.png"),
  caption: [Struttura AS e physical memory dell'esercizio. Schema creato dall'autore.],
)

*$"VA" = 507$*
+ Identificazione del segmento:\
  $507_10 = 0111111011_2$\
  Il MSB è 0, quindi, il VA appartiene a Seg 0.\
  Siccome $507 > 290 ==>$ l'indirizzo non è valido.

*$"VA" = 460$*
+ Identificazione del segmento:\
  $460_10 = 0111001100_2$\
  Il MSB è 0, quindi, il VA appartiene a Seg 0.\
  Siccome $507 > 290 ==>$ l'indirizzo non è valido.

*$"VA" = 667$*
+ Identificazione del segmento:\
  $667_10 = 1010011011_2$\
  Il MSB è 1, quindi, il VA appartiene a Seg 1.
+ Calcolo dell'offset: $"offset" = 472 - (1024 - 667) = 115$
+ Controllo della validità dell'offset: $115 < 472 ==>$ l'offset è valido.
+ Calcolo del PA: $"PA" = 4179 + 115 = 4294$

*$"VA" = 807$*
+ Identificazione del segmento:\
  $807_10 = 1100100111_2$\
  Il MSB è 1, quindi, il VA appartiene a Seg 1.

+ Calcolo dell'offset: $"offset" = 472 - (1024 - 807)=255$
+ Controllo della validità dell'offset: $255 < 472 ==>$ l'offset è valido.
+ Calcolo del PA: $"PA" = 4179 + 255 = 4434$

*$"VA" = 96$*
+ Identificazione del segmento:\
  $96_10 = 0001100000_2$\
  Il MSB è 0, quindi, il VA appartiene a Seg 0.
+ Controllo della validità dell'offset: $96 < 290 ==>$ l'offset è valido.
+ Calcolo del PA: $"PA" = 12513 + 96 = 12609$

== Paging
=== Esercizio 1
*Dati*
- Address space size: 16 KB = $2^(14)$.
- Physical memory size: 64 KB.
- Page size: 4 KB = $2^(12)$.

*Tabella delle pagine*
#table(
  columns: (1fr, 2fr),
  [Entry], [Valore],
  [`[0]`], [`0x8000000c`],
  [`[1]`], [`0x00000000`],
  [`[2]`], [`0x00000000`],
  [`[3]`], [`0x80000006`],
)

Se il bit più significativo è $1$, la pagina è valida e il resto dell'entry contiene il PFN. Se il bit è $0$, la pagina non è valida.

*Traduzione degli Indirizzi Virtuali*
#table(
  columns: (1.5fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  [VA (hex)],
  [VA (dec)],
  [VPN],
  [Offset (hex)],
  [PTE],
  [PFN],
  [Indirizzo Fisico (hex)],

  [`0x00003229`], [12841], [3], [`0x229`], [VALID], [6], [`0x6229`],
  [`0x00001369`], [4969], [1], [`0x369`], [NON VALIDA], [-], [-],
  [`0x00001e80`], [7808], [1], [`0xe80`], [NON VALIDA], [-], [-],
  [`0x00002556`], [9558], [2], [`0x556`], [NON VALIDA], [-], [-],
  [`0x00003a1e`], [14878], [3], [`0xa1e`], [VALID], [6], [`0x6a1e`],
)

+ *Calcolo della VPN e dell'Offset*:
  - Dimensione della pagina: 4 KB = $2^12$.
  - Offset: 12 bit.
  - VPN: Restanti bit (14 - 12 = 2 bit).

+ *Primo Indirizzo (VA = `0x00003229`)*:
  - Binario: 11 0010 0010 1001.
  - VPN: $3$.
  - Offset: `0x229`.
  - PTE: `0x80000006` → Valid ($1$), PFN = `0x6`.
  - PA = (PFN $times$ sizeOf(AS)) + Offset = (`0x6` $times$ `0x1000`) + `0x229` = `0x6229`.

+ *Secondo Indirizzo (VA = `0x00001369`)*:
  - Binario: 01 0011 0110 1001.
  - VPN: $1$.
  - Offset: `0x369`.
  - PTE: `0x00000000` → Non valida.

- *Terzo Indirizzo (VA = `0x00001e80`)*:
  - Binario: 01 1110 1000 0000.
  - VPN: $1$.
  - Offset: `0xe80`.
  - PTE: `0x00000000` → Non valida.

+ *Quarto Indirizzo (VA = `0x00002556`)*:
  - Binario: $10 0101 0101 0110$.
  - VPN: $2$.
  - Offset: `0x556`.
  - PTE: `0x00000000` → Non valida.

+ *Quinto Indirizzo (VA = `0x00003a1e`)*:
  - Binario: 11 1010 0001 1110.
  - VPN: $3$.
  - Offset: `0xa1e`.
  - PTE: `0x80000006` → Valid ($1$), PFN = `0x6`.
  - Indirizzo fisico: `0x6a1e`.

=== Esercizio 2
*Dati*
- Seed: 897832
- Address Space Size: 32 KB = $2^15$
- Physical Memory Size: 64 KB.
- Page Size: 4 KB = $2^12$.

*Struttura degli Indirizzi Virtuali*
- Offset: 12 bit ($2^12 = 4096$).
- VPN (Virtual Page Number): 15 - 12 = 3 bit.

*Tabella delle Pagine*
#table(
  columns: (1fr, 2fr),
  [VPN], [PTE],
  [`[0]`], [`0x8000000f`],
  [`[1]`], [`0x8000000b`],
  [`[2]`], [`0x00000000`],
  [`[3]`], [`0x00000000`],
  [`[4]`], [`0x80000003`],
  [`[5]`], [`0x8000000c`],
  [`[6]`], [`0x00000000`],
  [`[7]`], [`0x00000000`],
)

- Se il bit più significativo è $1$, la pagina è valida e il resto dell'entry contiene il PFN (Page Frame Number).
- Se il bit è $0$, la pagina non è valida.

Trace degli Indirizzi Virtuali
#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  [VA (hex)], [VA (dec)], [Risultato], [PA (hex)],
  [`0x00001760`], [5984], [VALID], [`0xb760`],
  [`0x000001cd`], [461], [VALID], [`0xf1cd`],
  [`0x00000121`], [289], [VALID], [`0xf121`],
  [`0x00006211`], [25105], [VIOLATION], [-],
  [`0x00002821`], [10273], [VIOLATION], [-],
)

*VA 0x00001760 (decimal: 5984)*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: `001 0111 0110 0000`.
  - VPN: `001` (decimal: 1).
  - Offset: `0111 0110 0000` (hex: `0x760`, decimal: 1888).
+ Consultazione della Tabella delle Pagine:
  - Entry $1$: `0x8000000b` → Valid ($1$), PFN = `0xb`.
+ PA = (PFN $times$ sizeOf(AS)) + Offset = `0xb760`.

*VA 0x000001cd (decimal: 461)*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: `000 0001 1100 1101`.
  - VPN: `000` (decimal: 0).
  - Offset: `0001 1100 1101` (hex: `0x1cd`, decimal: 461).

+ Consultazione della Tabella delle Pagine:
  - Entry $0$: `0x8000000f` → Valid ($1$), PFN = `0xf`.

+ PA = `0xf1cd`.

*VA 0x00000121 (decimal: 289)*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: `000000000000000100100001`.
  - VPN: `000` (decimal: 0).
  - Offset: $00000100100001$ (hex: `0x121`, decimal: `289`).
+ Consultazione della Tabella delle Pagine:
  - Entry $0$: `0x8000000f` → Valid ($1$), PFN = `0xf`.
+ PA = `0xf121`.

*VA 0x00006211 (decimal: 25105)*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: `000000000110001000010001`.
  - VPN: `110` (decimal: 6).
  - Offset: `000100100001` (hex: `0x211`, decimal: 529).
+ Consultazione della Tabella delle Pagine:
  - Entry $6$: `0x00000000` → Non valida ($0$).

+ Risultato: violation.

*VA 0x00002821 (decimal: 10273)*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: `000000000010100000100001`.
  - VPN: `010` (decimal: 2).
  - Offset: `0000100000100001` (hex: `0x821`, decimal: 2081).

+ Consultazione della Tabella delle Pagine:
  - Entry $2$: `0x00000000` → Non valida ($0$).
+ Risultato: violation.

*Risultati Finali*
#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  [VA (hex)], [VA (dec)], [Risultato], [PA (hex)],
  [`0x00001760`], [5984], [VALID], [`0xb760`],
  [`0x000001cd`], [461], [VALID], [`0xf1cd`],
  [`0x00000121`], [289], [VALID], [`0xf121`],
  [`0x00006211`], [25105], [VIOLATION], [-],
  [`0x00002821`], [10273], [VIOLATION], [-],
)

=== Esercizio 3
*Dati*
- Spazio logico del programma: 64 byte $2^6$.
- Dimensione delle pagine: 4 byte $2^2$.
- Memoria fisica: 256 byte $2^8$.

*Domande e Risposte*
+ Da quanti bit sono costituiti gli indirizzi logici e gli indirizzi fisici?

  *Indirizzi logici*
    - Numero di pagine: $64/4 = 16$ → Richiede 4 bit per il numero di pagina (VPN).
    - Offset all'interno della pagina: 2 bit ($log_2(4) = 2$).
    - Totale: 4 + 2 = 6 bit.

  *Indirizzi fisici*
    - Numero di frame: $256/4 = 64$ → Richiede 6 bit per il numero di frame (PFN).
    - Offset all'interno del frame: 2 bit} ($log_2(4) = 2$).
    - Totale: 6 + 2 = 8 bit.

+ Da quanti bit sono costituiti i numeri di pagina (VPN)?

  Il numero di pagine è $16$ ($64/4$), quindi richiede $log_2(16) = 4$ bit.

+ Da quanti bit sono costituiti i numeri di frame (PFN)?

  Il numero di frame è $64$ ($256/4$), quindi richiede $log_2(64) = 6$ bit.

*Tabella delle Pagine*

#table(
  columns: (1fr, 1fr),
  [Num Pagina Logica], [PFN (Frame Fisico)],
  [0], [12],
  [1], [1],
  [2], [17],
  [3], [62],
  [4], [11],
  [5], [16],
  [6], [61],
  [7], [12],
)

*Traduzione*
Si traducono i seguenti indirizzi logici: 0, 2, 4, 9, 19, 11, 22, 32, 30, 26, 23, 36.

#table(
  columns: 8,
  [VA (dec)],
  [VA (bin)],
  [VPN],
  [Offset],
  [PFN (Tabella)],
  [PA (dec)],
  [PA (bin)],
  [Note],

  [0], [`0000 00`], [0], [0], [12], [48], [`001100 00`], [Valid],
  [2], [`0000 10`], [0], [2], [12], [50], [`001100 10`], [Valid],
  [4], [`0001 00`], [1], [0], [1], [4], [`000001 00`], [Valid],
  [9], [`0010 01`], [2], [1], [17], [69], [`010001 01`], [Valid],
  [19], [`0100 11`], [4], [3], [11], [47], [`001011 11`], [Valid],
  [11], [`0010 11`], [2], [3], [17], [71], [`010001 11`], [Valid],
  [22], [`0101 10`], [5], [2], [16], [66], [`010000 10`], [Valid],
  [32], [`1000 00`], [8], [0], [-], [-], [-], [Invalid Page],
  [30], [`0111 10`], [7], [2], [12], [42], [`001100 10`], [Valid],
  [26], [`0110 10`], [6], [2], [61], [246], [`$111101 10`], [Valid],
  [23], [`0101 11`], [5], [3], [16], [67], [`010000 11`], [Valid],
  [36], [`1001 00`], [9], [0], [-], [-], [-], [Invalid Page],
)

*VA: $0$*
- Binario: `0000 00`.
- VPN: $0$, Offset: $0$.
- PFN: $12$.
- PA: PFN $times$ sizeOf(page) + Offset = 12 $times$ 4 + 0 = 48.

*VA: $2$*
- Binario: `0000 10`.
- VPN: $0$, Offset: $2$.
- PFN: $12$.
- PA: $12 times 4 + 2 = 50$.

*VA: $4$*
- Binario: `0001 00`.
- VPN: $1$, Offset: $0$.
- PFN: $1$.
- PA: $1 times 4 + 0 = 4$

*VA: $9$*
- Binario: `0010 01`.
- VPN: $2$, Offset: $1$.
- PFN: $17$.
- PA: $17 times 4 + 1 = 69$.

*VA: $19$*
- Binario: `0100 11`.
- VPN: $4$, Offset: $3$.
- PFN: $11$.
- PA: $11 times 4 + 3 = 47$.

*VA: $11$*
- Binario: `0010 11`.
- VPN: $2$, Offset: $3$.
- PFN: $17$.
- PA: $17 times 4 + 3 = 71$.

*VA: $22$*
- Binario: `0101 10`.
- VPN: $5$, Offset: $2$.
- PFN: $16$.
- PA: $16 times 4 + 2 = 66$.

*VA: $32$*
- Binario: `1000 00`.
- VPN: $8$.
- Invalid Page: La tabella non contiene una voce per la pagina $8$.

*VA: $30$*
- Binario: `0111 10`.
- VPN: $7$, Offset: $2$.
- PFN: $12$.
- PA: $12 times 4 + 2 = 42$.

*VA: $26$*
- Binario: `0110 10`.
- VPN: $6$, Offset: $2$.
- PFN: $61$.
- PA: $61 times 4 + 2 = 246$.

*VA: $23$*
- Binario: `0101 11`.
- VPN: $5$, Offset: $3$.
- PFN: $16$.
- PA: $16 times 4 + 3 = 67$.

*VA: $36$*
- Binario: `1001 00`.
- VPN: $9$.
- Invalid Page: La tabella non contiene una voce per la pagina 9.

=== Esercizio 4 (DA RIVEDERE)

*Dati*
- sizeOf(Virtual AS) = 32K ($2^15$)
- sizeOf(Physical AS) = 64K
- sizeOf(page) = 4 K

*Calcoli preliminari*

Il Valid bit si trova in posizione 14.

- Numero pagine virtuali: $(32 K)/(4 K) = 8$ 
- Numero frame fisici: $(64 K)/(4K) = 16$
- Suddivisione del VA:
  - sizeOf(VPN) = $log_2(8) = 3$ bit.
  - sizeOf(Offset) = 15 - 3 = 12 bit.

*Tabella delle pagine*
#table(
  columns: (1fr, 2fr),
  [VPN], [PTE],
  [0], [`0x80000003`],
  [1], [`0x8000000a`],
  [2], [`0x8000000f`],
  [3], [`0x00000000`],
  [4], [`0x00000000`],
  [5], [`0x00000000`],
  [6], [`0x80000005`],
  [7], [`0x00000000`]
)

*VA: 9385*
- Binario: `010 0100 1010 1001`
- VPN: 2, Offset: 1193
- PFN: `0xf` = 15
- PA = 15 $times$ 4096 + 1193 = 62633

*VA: 7128*
- Binario: `001 1011 1101 1000`
- VPN: 1, Offset: 3032
- PFN: `0xa` = 10
- PA = 10 $times$ 4096 + 3032 = 43992

*VA: 16457*
- Binario: `100 0000 0100 1001`
- VPN: 4 $==>$ PTE non valida $==>$ Segmentation Fault!

*VA: 16672*
- Binario: `100 0001 0010 0000`
- VPN: 4 $==>$ PTE non valida $==>$ Segmentation Fault!

*VA: 3788*
- Binario: `000 1110 1100 1100`
- VPN: 0, Offset: 3788
- PFN: `0x3` = 3
- PA = 3 $times$ 4096 + 3788 = 16076

== Multi-Level Page Table

=== Esercizio 1
*Dati*
- Address space: 16KB
- Dimensione pagina: 64 bytes
- Numero totale di pagine: 256 ($2^8$)
- Indirizzo virtuale: 14 bit (8 bit per VPN, 6 bit per offset)
- PTE size = 4 byte

1. *Struttura della Page Table Lineare*
  - Ogni PTE è di 4 bytes, quindi, Page Table = $256 dot 4$ bytes = 1KB
  - Con pagine da 64 bytes, quindi, la Page Table è divisa in 16 pagine (ciascuna contiene 16 PTE)

2. *Costruzione della Multi-Level Page Table*
  - Page Directory con 16 entry (una per ogni pagina della Page Table)
  - Page Table divisa in 16 pagine da 64 bytes
  - Indice VPN suddiviso:
    - PDIndex: 4 bit
    - PTIndex 4 bit
    - Offset: 8 bit

3. *Traduzione*
  - Estrarre PDIndex (primi 4 bit di VPN) per trovare la PDE:
      ```
      PDEAddr = PageDirBase + (PDIndex * sizeof(PDE))
      ```
  - Se PDE è valida, ottenere il PFN della Page Table e trovare la PTE:
      ```
      PTEAddr = (PDE.PFN << SHIFT) + (PTIndex * sizeof(PTE))
      ```
  - Se PTE è valida, estrarre il PFN della pagina fisica e calcolare l'indirizzo fisico:
      ```
      PhysAddr = (PTE.PFN << SHIFT) + offset
      ```
*Esempio di Traduzione*
- Indirizzo virtuale: `0x3F80`\ In binario: `11 1111 1000 0000`
- PDIndex = `1111` che corrisponde alla Page Table con PFN `101`
- PTIndex = `1110`
  14-esima entry della Page Table con PFN `55`
- Offset = `000000`
  Indirizzo fisico finale: `0x0DC0`

=== Esercizio 2
Richiesta: calcolare il valore dei 3 offset:
- VPNPageDir
- VPNChunkIndex
- Offset della pagina fisica dove risiede il dato

*Dati*
- VirtualAddressSize = 48 bit
- PageSize = 16 Kb = $2^14$
- VA = `0x12A7FEDB`

Inoltre, avendo 48 bit per l'indirizzamento capiamo che siamo su un sistema a 64 bit.

*Implicazioni*:
- Con PageSize = $2^14$, abbiamo 14 bit per l'offset.
- Dato che abbiamo 14 bit per l'offset, i bit per la VPN sono 48 - 14 = 34 bit.
- Siccome siamo su architettura x86-64 quindi a 64 bit, le PTE sono grandi 8 byte (64 bit = 8 byte).

*Calcoli*
+ Calcolo il numero di PTE per pagina e PTIndex:
  $(16 "Kb") / (8 "byte") = (16 dot 1024)/8$ = 2048 = $2^11$ PTE per pagina. Questo implica che occorrono 11 bit per il PTIndex.

+ Calcolo il numero di bit per il PDIndex:
  Siccome abbiamo 11 bit per PTIndex, il PDIndex avrà bisogno di 48 - 14 - 11 = 23 bit.

Ricapitolando:
- VPN = 34 bit
  - PDIndex = 23 bit
  - PTIndex = 11 bit
- offset = 14 bit

*Traduzione*:\
  `0x12A7FEDB` #sub[16] =\ `0001 0010 1010 0111 1111 1110 1101 1011`#sub[2]

  Ottengo che:
  - PDIndex = `1001`
  - PTIndex = `010 1001 1111`
  - offset = `11 1110 1101 1011`

  Tradotti in esadecimale:
  - PDIndex = `0x09`
  - PTIndex = `0x029F`
  - offset = `0x3EDB`

#figure(
  image("../images/tlb/multi TLB.png"),
  caption: [Schema di memoria di un Multi-Level TLB a due livelli su architettura x86-64 con page size = 16 Kb. Schema creato dall'autore.],
)

=== Esercizio 3

*Dati*
- Seed: $0$.
- Dimensione della Pagina: 32 byte.
- Spazio di Indirizzamento Virtuale (VAS): 1024 byte = $2^10$.
- Memoria Fisica: 128 pagine.
- Pagine Allocate: $64$.
- Page Directory Base Register (PDBR): 108 decimale.

*Struttura degli Indirizzi*
1. Indirizzo Virtuale: 15 bit:
  - 5 bit per l'offset all'interno della pagina.
  - 10 bit per il Virtual Page Number (VPN).

2. Indirizzo Fisico: 12 bit:
  - 5 bit per l'offset all'interno del frame.
  - 7 bit per il Physical Frame Number (PFN).

*Sistema di Paginazione*
- Page Directory:
  - I primi 5 bit dell'indirizzo virtuale indicizzano una voce nella page directory.
  - Ogni entry della page directory (PDE), se valida, punta a una pagina della page table.

- Page Table:
  - Ogni pagina della page table contiene 32 PTE.
  - Ogni PTE, se valida, contiene il PFN corrispondente alla pagina virtuale specificata.

*Trace degli indirizzi virtuali*

#table(
  columns: 7,
  [VA (hex)], [VA (bin)], [PDE Index], [VPN], [Offset], [Risultato], [PA (hex)],
  [`0x611c`],
  [`11000 01000 11100`],
  [24],
  [8],
  [28],
  [VALID],
  [`0x08`],

  [`0x3da8`],
  [`01111 01101 01000`],
  [15],
  [13],
  [8],
  [SEGMENTATION VIOLATION],
  [-],

  [`0x17f5`],
  [`00101 11111 10101`],
  [5],
  [31],
  [21],
  [VALID],
  [`0x1c`],

  [`0x7f6c`],
  [`11111 11011 01100`],
  [31],
  [27],
  [12],
  [INVALID PTE],
  [-],

  [`0x0bad`],
  [`00010 11101 01101`],
  [2],
  [29],
  [13],
  [INVALID PTE],
  [-],
)

*VA: `0x611c`*

+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: $11000 \, 01000 \, 11100$.
  - PDE Index: $11000$ (decimale: 24).
  - VPN: $01000$ (decimale: 8).
  - Offset: $11100$ (decimale: 28).

+ Consultazione della Page Directory:
  - PDBR → Page $108$: Entry $24$: $a_1$.
  - $a_1 = 1 \, 0100001$: Valid bit = $1$, PFN = $33$.

+ Consultazione della Page Table:
  - Page $33$: Entry $8$: $b_5$.
  - $b_5 = 1 \, 0110101$: Valid bit = $1$, PFN = $53$.

+ Calcolo dell'Indirizzo Fisico:
  - PFN + Offset: $53 + 28 = 81$.
  - Indirizzo fisico: `0x08`.

*VA: `0x3da8`*

+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: $01111 \, 01101 \, 01000$.
  - PDE Index: $01111$ (decimale: 15).
  - VPN: $01101$ (decimale: 13).
  - Offset: $01000$ (decimale: 8).

+ Consultazione della Page Directory:
  - PDBR → Page $108$: Entry $15$: $d_6$.
  - $d_6 = 1 \, 1010110$: Valid bit = $1$, PFN = $86$.

+ Consultazione della Page Table:
  - Page $86$: Entry $13$: $7f$.
  - $7f = 0 \, 1111111$: Valid bit = $0$.

+ Risultato:
  - Invalid PTE → Segmentation Violation.

*VA: `0x17f5`*
1. Decomposizione dell'Indirizzo Virtuale:
  - Binario: $00101 \, 11111 \, 10101$.
  - PDE Index: $00101$ (decimale: 5).
  - VPN: $11111$ (decimale: 3).
  - Offset: $10101$ (decimale: 2).

2. Consultazione della Page Directory:
  - PDBR → Page $108$: Entry $5$: $d_4$.
  - $d_4 = 1 \, 1010100$: Valid bit = $1$, PFN = $84$.

3. Consultazione della Page Table:
  - Page $84$: Entry $31$: $c_e$.
  - $c_e = 1 \, 1001110$: Valid bit = $1$, PFN = $78$.

4. Calcolo dell'Indirizzo Fisico:
  - PFN + Offset: $78 + 21 = 99$.
  - Indirizzo fisico: `0x1c`.


*VA: `0x7f6c`*
1. Decomposizione dell'Indirizzo Virtuale:
  - Binario: $11111 \, 11011 \, 01100$.
  - PDE Index: $11111$ (decimale: 3).
  - VPN: $11011$ (decimale: 2).
  - Offset: $01100$ (decimale: 1).

2. Consultazione della Page Directory:
  - PDBR → Page $108$: Entry $31$: `ff`.
  - Df = 1 , D: Valid bit = $1$, PFN = $127$.

3. Consultazione della Page Table:
  - Page $127$: Entry $27$: $7f$.
  - $7f = 0 \, 1111111$: Valid bit = $0$.

4. Risultato: Invalid PTE.

*VA: `0x0bad`*
1. Decomposizione dell'Indirizzo Virtuale:
  - Binario: $00010 \, 11101 \, 01101$.
  - PDE Index: $00010$ (decimale: 2).
  - VPN: $11101$ (decimale: 29).
  - Offset: $01101$ (decimale: 1).

2. Consultazione della Page Directory:
  - PDBR → Page $108$: Entry $2$: $e_0$.
  - $e_0 = 1 \, 1100000$: Valid bit = $1$, PFN = $96$.

3. Consultazione della Page Table:
  - Page $96$: Entry $29$: $7f$.
  - $7f = 0 \, 1111111$: Valid bit = $0$.

4. Risultato: Invalid PTE.

- Se la PDE o la PTE non è valida, si verifica un errore di traduzione (invalid PTE o segmentation violation).
- L'indirizzo fisico viene calcolato concatenando il PFN con l'offset.

#text(size: 8pt)[
  #table(
    columns: 1fr,
    [Page directory],
    [*0*:`1b1d05051d0b19001e00121c1909190c0f0b0a1218151700100a061c06050514`],
    [*1*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*2*:`121b0c06001e04130f0b10021e0f000c17091717071e001a0f0408120819060b`],
    [*3*:`7f7f7f7fcd7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f887f7f7f7f7f7f7f7fb9`],
    [*4*:`0b041004051c13071b131d0e1b150107080507071b0e1b0411001c000c181e00`],
    [*5*:`17131d0a1202111906081507081d1e041b1101121301171902140e070e040a14`],
    [*6*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*7*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*8*:`11101a120f10180a11151e151d0c12170a081e0a1e1a06191e08141702190915`],
    [*9*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*10*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*11*:`0910141d04011a18170e150c050c18181d1b151016051c16120d13131b11060d`],
    [*12*:`060b16191c05141d01141a0a07120d050e0c110f090b19071100160a0108071d`],
    [*13*:`19100b0e000614140f1d0e091a08121519180b0101161d0a0d16140814090b10`],
    [*14*:`1218140b000d1c0a07040f10020c141d0d0d0e060c140c12191e1b0b00120e07`],
    [*15*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*16*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fea7f7f7f`],
    [*17*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*18*:`7f7f7f7f7f7fab7f7f7f8e7f7f7fdd7f7f7f7f7f7f7f8b7f7f7f7f7f7f7f7f7f`],
    [*19*:`00130001061402011e0d1b060d0b050a1e170b0c081016150e011c0c0c00041a`],
    [*20*:`1a190402020c1d110807030419041a190411001a11170f151c111b0a03000719`],
    [*21*:`0b081b0e1c151e121e050d111e111a130f0c0b09061d101a1b1d070a13090417`],
    [*22*:`1212150f081b0a0e130f1d1d1c1c120f150608010500140418151e0c1c0e0a03`],
    [*23*:`1d0f030b0c0f1e1e1113140f0f091502091b071d1e110102060a03180b07010b`],
    [*24*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*25*:`03031c031b0e0e0a0c0b110a1907070e1c0016000c170d0d070e070814121c1e`],
    [*26*:`090e1d18081115180d0c170d070e1d040e130e06001513000917131004150e15`],
    [*27*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*28*:`0f1d0f0a0211070b0b17071d170e1b0b0b04180c0f0e140b1c0d0b0c171e1a0e`],
    [*29*:`17081e031b010710120c030708171c120118090a10071c050c08101113100c13`],
    [*30*:`7f7f7f7f7f847f7f7f7f977fbd7f7ff47f7f7f7f7f7f7f7f7f7f7f7f7f7f9c7f`],
    [*31*:`7f7f7f7f7f7fd07f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*32*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*33*:`7f7f7f7f7f7f7f7fb57f9d7f7f7f7f7f7f7f7f7f7f7f7f7f7f7ff6b17f7f7f7f`],
    [*34*:`0413050d0c02161518101105060710190b1b16160a031d1a0c1a1b0a0f0a151c`],
    [*35*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*36*:`1d1313160c0c1400050a07130b1b110c0c150c14010d0804100f11171b0f090e`],
    [*37*:`1e0f0a0d0c100c021e1e05070d15001913081a1409101e01151a150412180c12`],
    [*38*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*39*:`1b111e171108150e160c0f001601151218081506100a1e1e06110a1e1c121615`],
    [*40*:`0d030b1007190b0709191c1d0017100307080c0e1d01151a0b07060904110700`],
    [*41*:`7f7f7f7f7f7f7f7fe57f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f8d7f7f7f7f7f`],
    [*42*:`03041501111c1015001312110c0b1e01001d050306181d000d030806140a050f`],
    [*43*:`190802041311011e0e0916000d141d171b030d00080b0a0b180519100a11050f`],
    [*44*:`7f7f7f7f7f7fcc7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fa27f7f7f7f7f7f`],
    [*45*:`7fb27fef7f7f7f7fa4f57f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*46*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*47*:`070a0f1002090b0c0e0d020613190f0402040b111410110a14160c19171c0e0a`],
    [*48*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*49*:`1e0a0f0702030d13101003010b1d05080e1c1d00140714171b151a1804011610`],
    [*50*:`161b040706011a0f020d0d181704130f0004140b1d0f15040e1619060c0e0d0e`],
    [*51*:`14000f1a070a1a0511071d180d02090f1c0311151019101d12120d120b110905`],
    [*52*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*53*:`0f0c18090e121c0f081713071c1e191b09161b150e030d121c1d0e1a08181100`],
    [*54*:`1901050f031b1c090d11081006090d121008070318031607081614160f1a0314`],
    [*55*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*56*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*57*:`1c1d1602020b000a001e19021b0606141d03000b00121a05030a1d041d0b0e09`],
    [*58*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*59*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*60*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*61*:`010510020c0a0c031c0e1a1e0a0e150d09161b1c130b1e1302021701000c100d`],
    [*62*:`7f7f7fa87f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*63*:`0612060a1d1b19010407181a12161902021a010601001a0a0404141e0f1b0f11`],
    [*64*:`18121708080d1e161d10111e0518181a1704141c110b1d110c13180700101d15`],
    [*65*:`7f7f7f7f7f7f7f7f7f7f997f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*66*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fd77f7f`],
    [*67*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*68*:`121216020f060c0f0a0c16011d120511020f150d09141c1b0b1a03011e171311`],
    [*69*:`190a19020d0a0d190f1e1a03090016001b050c01090c0117160b1902010b1b17`],
    [*70*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*71*:`7f7f7f7f7f7f7f7f7f7f7f857f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*72*:`180c0018050c0b030a051314000e111b0f02011a181a081402190a1d0e011c13`],
    [*73*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*74*:`0d0b1e08180d0b011a151b0d14030c06011d0604060b10041e1e040c151b0f1c`],
    [*75*:`1a1c011b00141c0f0c0a1c1c13160a041e14081e120a1b021804030816120d04`],
    [*76*:`0c11150c1b1d1e01191b041d03061d191108070c0013011702000817190f1d03`],
    [*77*:`1c061606001b1a0205071c0b190d0b171308121519141312021d16081513140b`],
    [*78*:`0e02171b1c1a1b1c100c1508191a1b121d110d141e1c1802120f131a07160306`],
    [*79*:`1e1b1516071708030e0a050d1b0d0d1510041c0d180c190c06061d12010c0702`],
    [*80*:`1b081d1c020d170d0f19151d051c1c131d071b171202000007170b18130c1b01`],
    [*81*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fe27f7f7f7f7f7f7f7f7f7f7f7f7ffa`],
    [*82*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*83*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*84*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f947f7f7f7f7fce`],
    [*85*:`7f7f7f7f7f7f7f7f9a7fbf7f7f7f7f7f7f7f7f7faf7f7f7f7f7f7f7f7f7f7f7f`],
    [*86*:`7f7f7f7f7f7f7fc57f7f7f7f7f7f7f7f7f7f7f7fca7f7fee7f7f7f7f7f7f7f7f`],
    [*87*:`1805180d170e1802011c0f1b1d14110602191b18150d09030d111c1d0c031716`],
    [*88*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fc47f7f7f7f7f7f7f7f7f7f7f7f`],
    [*89*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*90*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fc07f7f7f7f7f7f7f7fde7f7f7f7f7f7f`],
    [*91*:`7f7f7f7f7f7f7f7f7f7f7f7fa57f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*92*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*93*:`0a1a1907001905181505021c12130e0412071816001c01020904070b160c080f`],
    [*94*:`1406190710140713080519110a1200040c1e0f021718181115061619170a1213`],
    [*95*:`0a1d0f1d1e1915040012151d10151406131e0315130b18001b190e030e12070f`],
    [*96*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7fb67f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*97*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fc87f7f7f7f7fe77f7f7f7f7f7f7f7f7f`],
    [*98*:`15191803171a170e1503170818130f100201001804030b1e1b0919020c111e01`],
    [*99*:`090b1304150b1204140a0e0c0e1509140109170113000e1b0010021a15171400`],
    [*100*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fa77f7f7f7f7f7f7f7f7f7fe37f7f`],
    [*101*:`0e0a00010b061005061416091a070a16011c020e1601191e0e030203170c1c0d`],
    [*102*:`1d031b0116000d1a0c1c1612050a0c121e080f1c0a13171317061d0512091309`],
    [*103*:`1e171c061012190e180c121a181400050f07021a1d090c19011303081901010c`],
    [*104*:`7f7f7f7f7f7f7f7f7f7f7f7f80aa7f7f7f7f7f7f7f7f7f7f7f7f7f7ff07f7f7f`],
    [*105*:`b37f7f7f7f7f7f7f7f7f7f7f7f937f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*106*:`160a000e1001110a00050310011c1a1d091c1e170814120c090103040e131701`],
    [*107*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7ff17f7f7f7f7f7f7f7f7ff37f7f7f7f7f7f7f`],
    [*108*:`83fee0da7fd47febbe9ed5ade4ac90d692d8c1f89fe1ede9a1e8c7c2a9d1dbff`],
    [*109*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f827f7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*110*:`1614041e0c120b010e0401131303110a0b180f1b120e130a03151318031c181c`],
    [*111*:`08000115111d1d1c01171514161b130b10061200040a18160a1301051e080c11`],
    [*112*:`19051e1302161e0c150906160019100303141b081e031a0c02080e181a041014`],
    [*113*:`1d07111b1205071e091a181716181a01050f06100f03020019021d1e170d080c`],
    [*114*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*115*:`110601040d1406151a170d141e1b0a1505110b0d0d141a0e0417171d0c0e101b`],
    [*116*:`0a130b11150f14171a05060f0f19101b180f190e0a0d0e1401161e0e02060307`],
    [*117*:`1b0a170019111d0b130a18121e000401031c1d0e1d19181705110d1d05051404`],
    [*118*:`1119021a1c05191a1b101206150c00040c1b111c1c02120a0f0e0e03190f130e`],
    [*119*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*120*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fcb7f7f7f7f7f7f7f7f7f7f7f7f7f`],
    [*121*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*122*:`051e0312041b1d18090717090d01040002020d1116040d13020d0b1d010c0c16`],
    [*123*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*124*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*125*:`0000000000000000000000000000000000000000000000000000000000000000`],
    [*126*:`7f7f7f7f7f7f7f7f8ce6cf7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f967f7f7f7f7f`],
    [*127*:`7f7f7f7f7f7f7f7f7f7f7f7f7f7f7f7fdf7f7f7f7f7f7f7f7f7f7f7f7f957f7f`]
  )
]

== Algoritmi di sostituzione

=== LRU (Least Recently Used)

Sequenza di accessi:
- Accesso $0$: Cache = $[0]$
- Accesso $1$: Cache = $[0, 1]$
- Accesso $2$: Cache = $[0, 1, 2]$
- Accesso $0$: Cache = $[1, 2, 0]$
- Accesso $1$: Cache = $[2, 0, 1]$
- Accesso $3$: Cache = $[0, 1, 3]$ → Sostituisce $2$ con $3$.
- Accesso $0$: Cache = $[1, 3, 0]$
- Accesso $3$: Cache = $[1, 0, 3]$
- Accesso $1$: Cache = $[0, 3, 1]$
- Accesso $2$: Cache = $[3, 1, 2]$
- Accesso $1$: Cache = $[3, 2, 1]$

=== Clock

Sequenza di accessi:
- Accesso $8$: Miss → Cache = $[8^*]$
- Accesso $7$: Miss → Cache = $[8^*, 7^*]$
- Accesso $4$: Miss → Cache = $[8^*, 7^*, 4^*]$
- Accesso $2$: Miss → Cache = $[2^*, 7, 4]$ → Scansiona fino a $8$, sostituisce $8$ con $2$.
- Accesso $5$: Miss → Cache = $[2^*, 5^*, 4]$ → Scansiona fino a $7$, sostituisce $7$ con $5$.
- Accesso $4$: Hit → Cache = $[2^*, 5^*, 4^*]$ → Imposta bit di riferimento di $4$.
- Accesso $7$: Miss → Cache = $[7^*, 5, 4]$ → Scansiona fino a $2$, sostituisce $2$ con $7$.
- Accesso $3$: Miss → Cache = $[7^*, 3^*, 4]$ → Scansiona fino a $5$, sostituisce $5$ con $3$.
- Accesso $4$: Hit → Cache = $[7^*, 3^*, 4^*]$ → Imposta bit di riferimento di $4$.
- Accesso $5$: Hit → Cache = $[7, 3, 5^*]$ → Imposta bit di riferimento di $5$.

== Calcolo delle Prestazioni I/O

=== Cheetah Random Access

*Dati*
- Capacità: 300GB.
- RPM: $15000$.
- Seek Time: 4 ms.
- Max Transfer Rate: 125 MB/s.

*Calcoli*
- $T_"rotation" = 60 / 15000 = 4 "ms"$
- $T_"transfer" = (4 "KB")/(125 "MB/s") = 32 mu s$.
- $T_"I/O" = 4 "ms" + 4 "ms" + 32 mu s = 8 "ms"$.
- $R_"I/O" = (4 "KB")*(8 "ms" = 0.5 "MB/s"$.

=== Barracuda Random Access

*Dati*
- Capacità: 1 tB.
- RPM: $7200$.
- Seek Time: 9 ms.
- Max Transfer Rate: 105 MB/s.

*Calcoli*
- $"T_rotation" = 60/7200 = 8 "ms"$.
- $T_"transfer" = (4 "KB")/(105 "MB/s") = 37 mu s$.
- $T_"I/O" = 9 "ms" + 8 "ms" + 37 mu s = 17 "ms"$.
- $R_"I/O" = (4 "KB")/(17 "ms") = 0.23 "MB/s"$.

=== Cheetah Sequential Access

*Dati*
- Capacità: 300 GB.
- RPM: $15000$.
- Seek Time: $4 "ms"$.
- Max Transfer Rate: $125 "MB/s"$.

*Calcoli*
- $T_"rotation" = 60/15000 = 4 "ms"$.
- $T_"transfer" = (100 "MB")/(125 "MB/s") = 800 "ms"$.
- $T_"I/O" = 4 "ms" + 4 "ms" + 800 "ms" = 808 "ms"$.
- $R_"I/O" = (100 "MB")/(808 "ms") = 123.76 "MB/s"$.

=== Barracuda Sequential Access

*Dati*
- Capacità: 1 TB.
- RPM: $7200$.
- Seek Time: 9 ms.
- Max Transfer Rate: 105 MB/s.

*Calcoli*
- $T_"rotation" = 60/7200 = 8 "ms"$.
- $T_"transfer" = (100 "MB")(105 "MB/s") = 950 "ms"$.
- $T_"I/O" = 9 "ms" + 8 "ms" + 950 "ms" = 967 "ms"$.
- $R_"I/O" = (100 "MB")(967 "ms") = 103.41 "MB/s"$.

== Dischi
=== Esercizio 1
*Caratteristiche del disco*
- Velocità di rotazione: 10.000 RPM $==>$ $T_"rotation" = 60000/10000 = 6$ ms 
- Tempo medio di seek ($T_S$): 4 ms
- Numeri settori per traccia: 500
- Dimensione del settore: 512 byte
  
*Domanda*:
Calcola il tempo totale medio ($T_"I/O"$) necessario per leggere un blocco di 4 KB (settori contigui e nella stessa traccia)

Settori da leggere:

$(4096 "byte")/ (512 "byte/settore") = 8 "settori"$

Tempo per leggere un settore ($T_"sector"$):

$T_"sector" = (T_"rotation" ("ms"))/("Numeri settori per traccia") = (6 "ms")/500 = 0.12 "ms"$

Tempo totale medio ($T_("I/O")=T_S+T_L+T_T$)
- $T_S = 4$ ms
- $T_L = 1/2 T_"rotation" = 3$ ms
- $T_T = 8 times 0,012 "ms" = 0,096 "ms"$

$T_("I/O")= 4 "ms" + 3 "ms" + 0,096 "ms" = 7,096 "ms"$

=== Esercizio 2
*Caratteristiche del disco*
- Velocità di rotazione: 10.000 RPM
- Numeri settori per traccia: 500
- Dimensione del settore: 512 byte

*Domanda*:
Calcola il throughput massimo teorico del disco in megabyte al secondo (MB/s) (assumi: seek time = 0 e tempo di accesso = 0).

Byte letti con una rotazione:

$500 times 512 = 256 000 "byte/rotation"$

Rotazioni al secondo:

$10000/60 approx 166,67 "rotazioni/s"$

Throughput (byte/s):

$256000 "byte/rotazione" times 166.67 "rotazioni/s" approx 42666667 "byte/s"$
Throughput (MB/s):

$(42666667 "byte/s")/1000000 approx 42,67 "MB/s"$

== Filesystem Implementation
=== Esercizio 1
*Dati*
- inodeStartAddr: 12 KB.
- blockSize: 4 KB.
- sectorSize: 512 Byte.
- sizeof(inode_t): 256 Byte.
- inumber: 6.

Indirizzo dell'inode corrispondente all'inumber $16$:
$"Indirizzo" =\ "inodeStartAddr" + ("inumber" times "sizeof(inode_t)" = \ 12 "KB" + (16 times 256 "Byte") = 16 "KB"$
