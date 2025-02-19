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
    margin: (left: 10mm, right: 12mm, top: 5mm, bottom: 8.4mm),
    columns: 2,
  )
  set text(font: "Libertinus Serif", lang: "it", size: 8pt)
  set par(justify: true, leading: 1.2mm)
  show raw: set text(size: 6pt)

  show table.cell.where(y: 0): strong
  set table(
    stroke: .05em,
    fill: (..args) => {
      let (col, row) = args.pos()
      if calc.even(row) { rgb("#ddd") } else { white }
    },
  )

  show heading.where(level: 2): it => [
    #rect(
      width: 100%,
      radius: 1pt,
      fill: rgb("#ddd"),
      [#it],
    )
  ]

  // Outline
  show outline.entry.where(level: 1): it => {
    v(10pt, weak: true)
    show repeat: none
    text(size: 1.2em, weight: 700, it.body)
    h(1fr)
    it.page
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

  include "chapters/dichiarazione fonte.typ"

  // Indice
  outline(
    indent: 1.2em,
    fill: box(repeat[$. space$]),
    title: box(width: 1fr)[#align(right)[#text(size: 1.1em)[Contents]]],
    depth: 3,
  )

  body
}