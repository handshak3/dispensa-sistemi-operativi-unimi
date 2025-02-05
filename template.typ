#let project(
  title: none,
  abstract: [],
  authors: (),
  date: none,
  subtitle: none,
  cfu: none,
  body,
) = {
  set document(author: authors.map(a => a.name), title: title)
  set page(
    numbering: "I",
    number-align: center,
    margin: 1.2cm,
    columns: 2
  )
  set text(font: "Libertinus Serif", lang: "it", size: 10pt)
  set par(justify: true, leading: 1.1mm)
  show raw: set text(size: 6pt)
  show table.cell.where(y: 0): strong
  set table(
    stroke: .05em,
    fill: (..args) => {
      let (col, row) = args.pos()
      if calc.even(row) { rgb("#ddd") } else { white }
    },
  )

  // Outline
  show outline.entry.where(level: 1): it => {
    v(20pt, weak: true)
    show repeat: none
    text(size: 1.2em, weight: 700, it.body)
    h(1fr)
    it.page
  }

  show outline.entry.where(level: 2): it => {
    strong(it)
  }

  // Title
  align(left)[
    #block(text(weight: 700, 1.75em, title))
    #v(1em, weak: true)
    #subtitle\
    #date\
    #cfu
  ]

  // Info
  grid(
    columns: (1fr,) * calc.min(3, authors.len()),
    ..authors.map(author => align(left)[
      *#author.name*\
      #author.email
    ]),
  )

  // Abstract
  heading(outlined: false, numbering: none, text(0.85em, smallcaps[Abstract]))
  abstract

  include "chapters/dichiarazione fonte.typ"

  // Indice
  outline(
    indent: 1.2em,
    fill: box(repeat[$. space$]),
    title: box(width: 1fr)[#align(right)[#text(size: 1.1em)[Contents]]],
  )

  body

  // Bibliography
  set page(numbering: "1")
  set page(columns: 1)

  bibliography("citations.bib")
}