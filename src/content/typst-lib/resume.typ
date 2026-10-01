// src/content/typst-lib/resume.typ
//
// Shared CV source. Compiled twice by the build:
//   typst compile cv.typ cv.pdf                       -> print layout (native grid/stack/line)
//   typst compile --features html --format html ...   -> semantic HTML, styled by site CSS
//
// Layout primitives have no direct HTML-export equivalent (HTML export is
// flow-based DOM, not paginated layout), so every layout-bearing helper
// branches on target(). Content (text, structure) stays identical either way.

#let is-html() = target() == "html"

#let contact-line(body) = if body != none { html.elem("div", body) }

#let cv-entry(org, role, location, timespan, tasks) = context {
  if is-html() {
    html.elem("article", attrs: (class: "cv-entry"))[
      #html.elem("div", attrs: (class: "cv-entry-head"))[
        #html.elem("span", attrs: (class: "cv-entry-org"))[
          #org#if location != none [, #location]
        ]
        #html.elem("span", attrs: (class: "cv-entry-role"))[#role]
      ]
      #html.elem("div", attrs: (class: "cv-entry-time"))[#timespan]
      #html.elem("ul", attrs: (class: "cv-entry-tasks"))[
        #for t in tasks [ #html.elem("li", t) ]
      ]
    ]
  } else {
    grid(columns: (2fr, 3fr), column-gutter: 2em, row-gutter: 1em)[
      #text(weight: "bold")[#org#if location != none { [, #location] }]
    ][
      #text(weight: "bold")[#role]
    ][
      #text(fill: rgb("#555"), size: 10pt)[#timespan]
    ][
      #set text(fill: rgb("#555"), size: 10pt)
      #list(..tasks)
    ]
  }
}

#let workExperience(timespan, jobTitle, company, location, tasks) = cv-entry(
  company,
  jobTitle,
  location,
  timespan,
  tasks,
)

#let education(timespan, school, location, title, tasks) = cv-entry(school, title, location, timespan, tasks)

#let two-col(left, right) = context {
  if is-html() {
    html.elem("div", attrs: (class: "cv-columns"))[
      #html.elem("div", left)
      #html.elem("div", right)
    ]
  } else {
    grid(
      columns: (1fr, 1fr),
      column-gutter: 2em,
      left, right,
    )
  }
}

#let resume(
  picture: none,
  name: none,
  address: none,
  email: none,
  phone: none,
  birth: none,
  github: none,
  workExperiences: (),
  education: (),
  doc,
) = context {
  if is-html() {
    html.elem("div", attrs: (class: "cv"))[
      #html.elem("header", attrs: (class: "cv-header"))[
        #if picture != none { html.elem("div", attrs: (class: "cv-photo"), picture) }
        #html.elem("h1", name)
        #html.elem("div", attrs: (class: "cv-contact"))[
          #contact-line(address)
          #contact-line(email)
          #contact-line(phone)
          #contact-line(birth)
          #contact-line(github)
        ]
      ]
      #html.elem("h2", "Working Experience")
      #html.elem("div", attrs: (class: "cv-entries"))[#workExperiences.join()]
      #html.elem("h2", "Education")
      #html.elem("div", attrs: (class: "cv-entries"))[#education.join()]
      #doc
    ]
  } else {
    set page(margin: 2.5cm)
    set text(size: 10pt, font: "Helvetica Neue LT Std")
    set grid.cell(align: left + top)
    grid(columns: (1fr, 1fr, 1fr), column-gutter: 2em)[
      #if picture != none { picture }
    ][
      #text(size: 25pt)[*#name*]
    ][
      #set text(fill: rgb("#555"))
      #stack(dir: ttb, spacing: .8em, ..(address, email, phone, birth, github).filter(x => x != none))
    ]
    [= Working experience]
    line(length: 100%, stroke: .5pt + rgb("#CCC"))
    stack(dir: ttb, spacing: 2em, ..workExperiences)
    [= Education]
    line(length: 100%, stroke: .5pt + rgb("#CCC"))
    stack(dir: ttb, spacing: 2em, ..education)
    doc
  }
}
