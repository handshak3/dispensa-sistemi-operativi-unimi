#import "template.typ": *

#show: project.with(
  title: "Sistemi Operativi",
  authors: (
    (name: "Nicola Iantomasi", email: "nicola.iantomasi2020@gmail.com"),
  ),
  abstract: include "chapters/abstract.typ",
  date: "Anno Accademico 2024/2025",
  subtitle: "Sicurezza dei Sistemi e delle Reti Informatiche",
)

#set page(numbering: "1")
#counter(page).update(1)

#include "chapters/introduction.typ"

#set heading(numbering: (..numbers) => {
  let n = numbers.pos()
  if n.len() == 1 {
    numbering("I", ..n)
  } else if n.len() == 2 {
    numbering("1", ..n.slice(1))
  } else { numbering("1.1", ..n.slice(1)) }
})

= Virtualizzazione

#include "chapters/processes.typ"

#include "chapters/process API.typ"

#include "chapters/cpu mechanism.typ"

#include "chapters/cpu scheduling.typ"

#include "chapters/mlfq.typ"

#include "chapters/address space.typ"

#include "chapters/memory api.typ"

#include "chapters/address translation.typ"

#include "chapters/segmentation.typ"

#include "chapters/paging.typ"

#include "chapters/tlb.typ"

#include "chapters/small tlbs.typ"


#include "chapters/swapping mechanisms.typ"

#include "chapters/swapping policies.typ"

= Concorrenza

#include "chapters/concurrency.typ"

#include "chapters/thread api.typ"

#include "chapters/locks.typ"

#include "chapters/lockbased.typ"

#include "chapters/condition variables.typ"

#include "chapters/semaphores.typ"

= Persistenza

#include "chapters/io devices.typ"

#include "chapters/hd drivers.typ"

#include "chapters/raid.typ"

#include "chapters/file e dir.typ"

#include "chapters/file system.typ"

#include "chapters/ffs.typ"

#include "chapters/journaling.typ"