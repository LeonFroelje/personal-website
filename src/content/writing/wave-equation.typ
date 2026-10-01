#metadata((
  title: "Wave Equation Derivation",
  description: "Interactive intro to the 1D wave equation.",
  date: "2024-01-10",
  tags: ("pde",),
)) <frontmatter>

#set text(font: "New Computer Modern")
#show math.equation: set text(font: "New Computer Modern Math")

= Wave Equation Derivation

The one-dimensional wave equation is given by:

$ (partial^2 u)/(partial t^2) = c^2 (partial^2 u)/(partial x^2) $

Below is an interactive visual representation of the sine wave harmonic:
#figure(caption: "Test")[
  #html.elem("interactive-sine-plot", attrs: (frequency: "4", amplitude: "50"))
]
Notice how increasing the frequency changes the spatial wavelength.
