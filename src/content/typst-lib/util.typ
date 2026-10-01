#let to = $->$
#let numberedBlock(content) = {
  set math.equation(numbering: "(1)")
  content
}
#let loc = math.op("loc")
#let closure = math.overline
#let supp = math.op("supp")
#let testto = math.attach(to, t: $cal(D)(Omega)$)

#let tb = math.op("TB")
#let mn = math.op("MN")


#let part = math.op("Part")

#let join = sym.or
#let given = math.mid(sym.bar)

#let ayto = quote[Are You The One?]

