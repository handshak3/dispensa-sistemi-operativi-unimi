#import "template.typ": *

#show: project.with(
  title: "Sistemi Operativi",
  authors: (
    (name: "Nicola Iantomasi", email: "nicola.iantomasi2020@gmail.com"),
  ),
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

#include "chapters/virtualization/processes.typ"

#include "chapters/virtualization/process API.typ"

#include "chapters/virtualization/cpu mechanism.typ"

#include "chapters/virtualization/cpu scheduling.typ"

#include "chapters/virtualization/mlfq.typ"

#include "chapters/virtualization/address space.typ"

#include "chapters/virtualization/memory api.typ"

#include "chapters/virtualization/address translation.typ"

#include "chapters/virtualization/segmentation.typ"

#include "chapters/virtualization/paging.typ"

#include "chapters/virtualization/tlb.typ"

#include "chapters/virtualization/small tlbs.typ"


#include "chapters/virtualization/swapping mechanisms.typ"

#include "chapters/virtualization/swapping policies.typ"

= Concorrenza

#include "chapters/concurrency/concurrency.typ"

#include "chapters/concurrency/thread api.typ"

#include "chapters/concurrency/locks.typ"

#include "chapters/concurrency/lockbased.typ"

#include "chapters/concurrency/condition variables.typ"

#include "chapters/concurrency/semaphores.typ"

= Persistenza

#include "chapters/persistency/io devices.typ"

#include "chapters/persistency/hd drivers.typ"

#include "chapters/persistency/raid.typ"

#include "chapters/persistency/file e dir.typ"

#include "chapters/persistency/fs.typ"

#include "chapters/persistency/ffs.typ"

#include "chapters/persistency/journaling.typ"

= Esercizi
#include "chapters/exercises.typ"

= Laboratorio
#include "chapters/laboratory/assembly.typ"

#include "chapters/laboratory/shell.typ"

#include "chapters/laboratory/memorie di massa.typ"

#include "chapters/laboratory/simulation.typ"

#bibliography("citations.bib")