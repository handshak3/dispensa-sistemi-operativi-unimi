#import "@preview/codly:1.0.0": *

#show: codly-init.with()

== Memory API

In un programma C, ci sono due tipi di memoria che vengono allocati:
- *Stack*: le cui allocazioni e deallocazioni vengono gestite implicitamente dal compilatore per il programmatore.
- *Heap*: dove tutte le allocazioni e le deallocazioni sono gestite esplicitamente dal programmatore.

=== `malloc()`

L'heap è necessaria per memorizzare informazioni che devono vivere oltre l'invocazione di una funzione. Per allocare memoria nello heap si usa `malloc()`. `malloc()` richiede come parametro un blocco di memoria di una determinata dimensione e restituisce un puntatore a tale blocco. Il programmatore è responsabile della deallocazione della memoria allocata con `malloc()` utilizzando la funzione `free()`.

Funzionamento di `malloc()`: si passa un valore di dimensione che indica la quantità di memoria richiesta e viene restituito un puntatore alla memoria appena allocata, oppure `NULL` se l'allocazione non è riuscita.

La sintassi di `malloc()` è la seguente:

#text(9pt)[
  ```c
  void *malloc(size_t size);
  ```
]

La funzione `malloc()` alloca un blocco di memoria di dimensioni `size` e restituisce un puntatore al blocco di memoria allocato. Il tipo del puntatore restituito è `void *` quindi è necessario castare il puntatore restituito a un tipo specifico prima di utilizzarlo.

Il tipo `size_t`, rappresenta il numero di byte da allocare. In genere si utilizza l'operatore `sizeof()` per ottenere il valore corretto. Ad esempio, per allocare spazio per un valore di tipo `double`, si può scrivere:
#text(9pt)[
  ```c
  double *d = (double *) malloc(sizeof(double));
  ```
]

In questo caso, l'operatore `sizeof()` viene utilizzato per ottenere il valore di 8, che è la dimensione di un valore di tipo `double`.

La chiamata `malloc()` può anche essere utilizzata per allocare memoria per un array di elementi. Ad esempio, per allocare memoria per un array di 10 elementi di tipo `int`, si può scrivere:

#text(9pt)[
  ```c
  int *x = malloc(10 * sizeof(int));
  ```
]

In questo caso, la chiamata `malloc()` richiede $10 * 8 = 80$ byte di memoria.

=== `free()`

Utile liberare la memoria heap che non è più in uso, i programmatori chiamano semplicemente `free()` .

La funzione `free()` prende un puntatore alla memoria allocata da `malloc()` e la dealloca.

#text(9pt)[
  ```c
  void free(void *ptr);
  ```
]

#line()