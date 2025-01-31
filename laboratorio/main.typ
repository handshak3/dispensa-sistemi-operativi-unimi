#import "template.typ": *

#show: project.with(
  authors: (
    (name: "Nicola Iantomasi", email: "nicola.iantomasi2020@gmail.com"),
  ),
  date: "Anno Accademico 2024/2025",
  subtitle: "Sicurezza dei Sistemi e delle Reti Informatiche",
  abstract: include "chapters/abstract.typ",
  title: "Sistemi Operativi Laboratorio"
)

#set page(numbering: "1")
#counter(page).update(1)

= Laboratorio

#include "chapters/memorie di massa.typ"

#include "chapters/assembly.typ"

#set page(flipped: true)

#include "chapters/shell.typ"

#include "chapters/simulation.typ"
