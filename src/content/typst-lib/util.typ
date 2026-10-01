#let to = $->$
#let numberedBlock(content) = {
  set math.equation(numbering: "(1)")
  content
}
#let loc = math.op("loc")
#let closure = math.overline
#let supp = math.op("supp")
#let testto = math.attach(to, t: $cal(D)(Omega)$)

