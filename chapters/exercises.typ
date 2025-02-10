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

=== Esercizio 4

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
  [7], [`0x00000000`],
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

=== Esercizio 3
*Dati*
- Seed: $0$.
- Dimensione della pagina: 32 byte cioè $2^5$
- Spazio degli indirizzi virtuali: 1024 pagine
- Memoria fisica: 128 pagine
- Bit per indirizzo virtuale: 15
  - 5 bit per l'offset
  - 10 bit per il VPN
    - 5 bit per il PDIndex
    - 5 bit per il PTIndex
- Bit per indirizzo fisico: 12
  - 5 bit per l'offset
  - 7 bit per il PFN.
- Page Directory Base Register (PDBR): 108 decimale.
  #table(
    columns: 2,
    [n° byte],
    [`0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15`\ `16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31`],

    [page 108],
    [`83 fe e0 da 7f d4 7f eb be 9e d5 ad e4 ac 90 d6`\ `92 d8 c1 f8 9f e1 ed e9 a1 e8 c7 c2 a9 d1 db ff`],
  )

*Trace degli indirizzi virtuali*

#table(
  columns: 7,
  [VA (hex)], [VA (bin)], [PDE Index], [VPN], [Offset], [Risultato], [PA (hex)],
  [`0x611c`],
  [`11000 01000 11100`],
  [24],
  [8],
  [28],
  [#text(size: 6pt)[VALID]],
  [`0x08`],

  [`0x3da8`],
  [`01111 01101 01000`],
  [15],
  [13],
  [8],
  [#text(size: 6pt)[INVALID PTE]],
  [-],

  [`0x17f5`],
  [`00101 11111 10101`],
  [5],
  [31],
  [21],
  [#text(size: 6pt)[VALID]],
  [`0x1c`],

  [`0x7f6c`],
  [`11111 11011 01100`],
  [31],
  [27],
  [12],
  [#text(size: 6pt)[INVALID PTE]],
  [-],

  [`0x0bad`],
  [`00010 11101 01101`],
  [2],
  [29],
  [13],
  [#text(size: 6pt)[INVALID PTE]],
  [-],
)

*VA: `0x611c`*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: $11000 \, 01000 \, 11100$.
    - PDIndex: $11000$ (decimale: 24).
    - PTIndex: $01000$ (decimale: 8).
    - Offset: $11100$ (decimale: 28).

+ Consultazione della Page Directory:
  - 24° byte del PDBR = `0xa1`.
  - `0xa1` = $1 \, 0100001$: Valid bit = $1$, PFN = $33$.

+ Consultazione della Page Table:
  #table(
    columns: 2,
    [n° byte],
    [`0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15`\ `16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31`],

    [page 33],
    [`7f 7f 7f 7f 7f 7f 7f 7f b5 7f 9d 7f 7f 7f 7f 7f`\ `7f 7f 7f 7f 7f 7f 7f 7f 7f 7f f6 b1 7f 7f 7f 7f`],
  )
  - Page $33$: Entry n°$8$: `0xb5`.
  - `0xb5` = $1 \, 0110101$: Valid bit = $1$, PFN = $53$.

+ PA = 53 + 28 = 81 = `0x08`.

*VA: `0x3da8`*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: $01111 \, 01101 \, 01000$.
  - PDE Index: $01111$ (decimale: 15).
  - VPN: $01101$ (decimale: 13).
  - Offset: $01000$ (decimale: 8).

+ Consultazione della Page Directory:
  - 15° byte del PDBR: `0xd6`.
  - `0xd6` $= 1 \, 1010110$: Valid bit = $1$, PFN = $86$.

+ Consultazione della Page Table:
  #table(
    columns: 2,
    [n° byte],
    [`0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15`\ `16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31`],

    [page 86],
    [`7f 7f 7f 7f 7f 7f 7f c5 7f 7f 7f 7f 7f 7f 7f 7f`\ `7f 7f 7f 7f ca 7f 7f ee 7f 7f 7f 7f 7f 7f 7f 7f`],
  )
  - Page $86$: Entry n°$13$: `0x7f`.
  - `0x7f` $= 0 \, 1111111$: Valid bit = $0$.

+ Risultato: Invalid PTE.

*VA: `0x17f5`*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: $00101 \, 11111 \, 10101$.
  - PDE Index: $00101$ (decimale: 5).
  - VPN: $11111$ (decimale: 3).
  - Offset: $10101$ (decimale: 2).

+ Consultazione della Page Directory:
  - 5° byte del PDBR: `0xd4`.
  - `0xd4` $= 1 \, 1010100$: Valid bit = $1$, PFN = $84$.

+ Consultazione della Page Table:
  #table(
    columns: 2,
    [n° byte],
    [`0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15`\ `16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31`],

    [page 84],
    [`7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f`\ `7f 7f 7f 7f 7f 7f 7f 7f 7f 94 7f 7f 7f 7f 7f ce`],
  )
  - Page $84$: Entry n°$31$: `0xce`.
  - `0xce` $= 1 \, 1001110$: Valid bit = $1$, PFN = $78$.

+ PA = 78 + 21 = 99

*VA: `0x7f6c`*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: $11111 \, 11011 \, 01100$.
  - PDE Index: $11111$ (decimale: 3).
  - VPN: $11011$ (decimale: 2).
  - Offset: $01100$ (decimale: 1).

+ Consultazione della Page Directory:
  - 31° byte del PDBR: `0xff`.
  - `0xff` = 1 , D: Valid bit = $1$, PFN = $127$.

+ Consultazione della Page Table:
  #table(
    columns: 2,
    [n° byte],
    [`0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15`\ `16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31`],

    [page 127],
    [`7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f`\ `df 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 95 7f 7f`],
  )
  - Page $127$: Entry n°$27$: `0x7f`.
  - `0x7f` $= 0 \, 1111111$: Valid bit = $0$.

+ Risultato: Invalid PTE.

*VA: `0x0bad`*
+ Decomposizione dell'Indirizzo Virtuale:
  - Binario: $00010 \, 11101 \, 01101$.
  - PDE Index: $00010$ (decimale: 2).
  - VPN: $11101$ (decimale: 29).
  - Offset: $01101$ (decimale: 1).

+ Consultazione della Page Directory:
  - 2° byte del PDBR: `0xe0`.
  - `0xe0` $= 1 \, 1100000$: Valid bit = $1$, PFN = $96$.

+ Consultazione della Page Table:
  #table(
    columns: 2,
    [n° byte],
    [`0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15`\ `16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31`],

    [page 96],
    [`7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f b6 7f`\ `7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f 7f`],
  )
  - Page $96$: Entry n°$29$: `0x7f`.
  - `0x7f` $= 0 \, 1111111$: Valid bit = 0.

+ Risultato: Invalid PTE.

Se la PDE o la PTE non è valida, si verifica un errore di traduzione (invalid PTE o segmentation violation).

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

$(4096 "byte") / (512 "byte/settore") = 8 "settori"$

Tempo per leggere un settore ($T_"sector"$):

$T_"sector" = (T_"rotation" ("ms")) / ("Numeri settori per traccia") = (6 "ms") / 500 = 0.12 "ms"$

Tempo totale medio ($T_("I/O")=T_S+T_L+T_T$)
- $T_"seek" = 4$ ms
- $T_"rotation" = 1/2 T_"rotation" = 3$ ms
- $T_"transfer" = 8 times 0,012 "ms" = 0,096 "ms"$

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

$10000 / 60 approx 166,67 "rotazioni/s"$

Throughput (byte/s):

$256000 "byte/rotazione" times 166.67 "rotazioni/s" approx 42666667 "byte/s"$
Throughput (MB/s):

$(42666667 "byte/s") / 1000000 approx 42,67 "MB/s"$

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

== Semafori
=== Esercizio 1

Considera il seguente codice che usa due semafori per sincronizzare due thread:

```c
sem_t sem1, sem2;

void *thread1(void *arg) {
    sem_wait(&sem1);
    sem_wait(&sem2);
    printf("Thread 1 in sezione critica\n");
    sem_post(&sem2);
    sem_post(&sem1);
    return NULL;
}

void *thread2(void *arg) {
    sem_wait(&sem2);
    sem_wait(&sem1);
    printf("Thread 2 in sezione critica\n");
    sem_post(&sem1);
    sem_post(&sem2);
    return NULL;
}
```

*Domanda*: Cosa accade se entrambi i thread iniziano contemporaneamente?
#set enum(numbering: "A.")

+ Entrambi i thread accederanno alla sezione critica senza problemi.
+ Si verifica una condizione di deadlock.
+ Il programma eseguirà indefinitamente senza terminare.
+ Il thread 2 entrerà nella sezione critica prima del thread 1.
+ L'ordine di esecuzione dipende dalla schedulazione del sistema operativo.
#set enum(numbering: "1.")

Scegli la risposta corretta e nel caso il codice porti a problemi indicare una possibile soluzione.

*Soluzione*: Il codice definisce due semafori sem1 e sem2. Le funzioni thread1 e thread2 seguono la seguente sequenza:

1. Thread 1:
- Attende su sem1 (`sem_wait(&sem1);`)
- Attende su sem2 (`sem_wait(&sem2);`)
- Stampa un messaggio
- Rilascia sem2 (`sem_post(&sem2);`)
- Rilascia sem1 (`sem_post(&sem1);`)

2. Thread 2:
- Attende su sem2 (`sem_wait(&sem2);`)
- Attende su sem1 (`sem_wait(&sem1);`)
- Stampa un messaggio
- Rilascia sem1 (`sem_post(&sem1);`)
- Rilascia sem2 (`sem_post(&sem2);`)

Se partono contemporaneamente, Thread 1 attende prima su sem1 e poi su sem2, mentre Thread 2 fa il contrario. Quindi:
1. Thread 1 acquisisce sem1 e aspetta su sem2.
2. Thread 2 acquisisce sem2 e aspetta su sem1.
I thread sono bloccati in attesa che l'altro rilasci un semaforo, il che non accadrà mai. Questo è un deadlock.

*Risposta*: B. Si verifica una condizione di deadlock.

*Correzione del codice*
```c
void thread1(void *arg) {
    sem_wait(&sem1);
    sem_wait(&sem2);
    printf("Thread 1 in sezione critica\n");
    sem_post(&sem2);
    sem_post(&sem1);
    return NULL;
}

void thread2(void *arg) {
    sem_wait(&sem1);  // Modificato per rispettare lo stesso ordine di thread1
    sem_wait(&sem2);
    printf("Thread 2 in sezione critica\n");
    sem_post(&sem2);
    sem_post(&sem1);
    return NULL;
}```

Ora entrambi i thread acquisiscono prima sem1 e poi sem2, prevenendo il deadlock.

=== Esercizio 2
Considera il seguente codice C che implementa un semaforo per sincronizzare l'accesso a una sezione critica:

```c
#include <stdio.h>
#include <pthread.h>
#include <semaphore.h>

sem_t semaphore;

void *thread_function(void *arg) {
    sem_wait(&semaphore);
    printf("Thread %d in sezione critica\n", *(int *)arg);
    sem_post(&semaphore);
    return NULL;
}

int main() {
    pthread_t t1, t2;
    int id1 = 1, id2 = 2;
    sem_init(&semaphore, 0, 1);

    pthread_create(&t1, NULL, thread_function, &id1);
    pthread_create(&t2, NULL, thread_function, &id2);

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    sem_destroy(&semaphore);
    return 0;
}
```
*Domanda*: Quale sarà l'output di questo programma se entrambi i thread vengono eseguiti contemporaneamente?

#set enum(numbering: "A.")

+ Entrambi i thread accederanno simultaneamente alla sezione critica.
+ L'output sarà sempre nell'ordine "Thread 1 in sezione critica" seguito da "Thread 2 in sezione critica".
+ I thread accederanno alla sezione critica uno alla volta, ma l'ordine non è garantito.
+ Il programma andrà in deadlock a causa dell'uso improprio del semaforo.
+ I thread non accederanno mai alla sezione critica a causa di un errore di sincronizzazione.

Dare la risposta corretta e giustificarla.

*Soluzione*:

Analizziamo il comportamento del codice:
#set enum(numbering: "1.")
1. Inizializzazione del semaforo:\
  `sem_init(&semaphore, 0, 1);`
  Il semaforo è inizializzato a 1, il che significa che solo un thread alla volta può entrare nella sezione critica.

2. Esecuzione dei thread:\
  Entrambi i thread vengono creati con pthread_create. Ogni thread chiama `sem_wait(&semaphore)`, bloccandosi se il semaforo è già occupato. Quando un thread termina la sezione critica, chiama `sem_post(&semaphore)`, permettendo all'altro thread di procedere.

3. Conseguenze:\ Poiché il semaforo ha valore iniziale 1, solo un thread alla volta può accedere alla sezione critica. L'ordine di esecuzione dei thread non è garantito e dipende dalla schedulazione del sistema operativo. Non si verifica deadlock perché ogni thread rilascia il semaforo dopo l'uso.

*Risposta corretta*: C. I thread accederanno alla sezione critica uno alla volta, ma l'ordine non è garantito.

=== Esercizio 3
Riportare un esempio di codice di un semaforo usato per determinare l'ordine di esecuzione tra padre e figlio.

*Soluzione*: Per garantire che il processo padre esegua un'operazione solo dopo che il processo figlio ha completato una determinata azione, possiamo usare un semaforo inizializzato a 0. Il padre eseguirà una `sem_wait()` per attendere il figlio, mentre il figlio eseguirà `sem_post()` per segnalare al padre che può procedere.

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <semaphore.h>
#include <sys/types.h>
#include <sys/wait.h>

sem_t semaphore;

int main() {
    sem_init(&semaphore, 1, 0); // Semaforo inizializzato a 0 (bloccante)

    pid_t pid = fork(); // Creazione del processo figlio

    if (pid < 0) {
        perror("Errore nella fork");
        exit(1);
    }

    if (pid == 0) {
        // Processo FIGLIO
        printf("Figlio: sto eseguendo il mio compito\n");
        sleep(2); // Attività del figlio
        printf("Figlio: ho finito, segnalo al padre\n");
        sem_post(&semaphore); // Sblocca il padre
        exit(0);
    } else {
        // Processo PADRE
        sem_wait(&semaphore); // Attende che il figlio completi l'operazione
        printf("Padre: il figlio ha terminato, ora posso eseguire la mia parte\n");
        wait(NULL); // Aspetta la terminazione del figlio
        sem_destroy(&semaphore); // Distrugge il semaforo
    }

    return 0;
}
```
*Spiegazione:*
1. Inizializzazione del semaforo a 0: il padre parte in stato di attesa.
2. Creazione del processo figlio con fork().
3. Il figlio esegue il suo compito, poi chiama sem_post(&semaphore); per sbloccare il padre.
4. Il padre attende con sem_wait(&semaphore); finché il figlio non chiama sem_post().
5. Il padre prosegue l'esecuzione solo dopo il completamento del figlio.
6. Distruzione del semaforo alla fine del programma.

*Output atteso*

+ Figlio: sto eseguendo il mio compito
+ Figlio: ho finito, segnalo al padre
+ Padre: il figlio ha terminato, ora posso eseguire la mia parte

Questo assicura che il padre non esegua la sua parte prima che il figlio abbia completato la sua attività.