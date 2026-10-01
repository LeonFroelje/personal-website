#metadata((
  title: "Weak Derivatives and Sobolev Spaces",
  description: "From distributions to Sobolev spaces, motivated by the wave equation.",
  date: "2024-05-01",
  draft: false,
  tags: ("pde", "functional-analysis"),
)) <frontmatter>


#import "@preview/cetz:0.5.2"
#import "../typst-lib/util.typ": *
#import "../typst-lib/theorems.typ": *
#show math.equation: box
#show: show-theorion
#set heading(numbering: "1.")

#let initial_condition() = html.frame[#cetz.canvas({
    import cetz.draw: *

    // Set default line style
    set-style(stroke: 1pt)

    // Boundaries (Fixed walls at x = 0 and x = L)
    // line((0, -0.4), (0, 2.2), stroke: 3pt + gray.darken(40%))
    // line((6, -0.4), (6, 2.2), stroke: 3pt + gray.darken(40%))

    // Equilibrium baseline
    line((-0.5, 0), (6.5, 0), stroke: 0.5pt + gray)
    content((6.7, 0), [$x$])

    // The plucked string (triangle wave with a non-smooth kink at x = L/2)
    line((0, 0), (3, 1.8), (6, 0), stroke: 1.5pt + blue)

    // Dashed height indicator for the pluck magnitude h
    line((3, 0), (3, 1.8), stroke: (dash: "dashed", paint: red))
    content((3.4, 0.9), text(fill: red, [$h$]))

    // Points of interest
    circle((0, 0), radius: 0.07, fill: black)
    circle((6, 0), radius: 0.07, fill: black)
    circle((3, 1.8), radius: 0.09, fill: red, stroke: none)

    // Labels
    content((0, -0.35), [$0$])
    content((3, -0.35), [$L/2$])
    content((6, -0.35), [$L$])

    // Callout for the kink
    content((3, 2.3), text(size: 9pt)[
      Non-smooth kink ($u_(x x)$ undefined here)
    ])
  })
]
#import "@preview/cetz:0.3.3"

#import "@preview/irif:0.0.2"
#import "@preview/cetz-plot:0.1.1": plot
#import "@preview/plotsy-3d:0.2.1": plot-3d-surface

#let mollifier2d(x) = {
  if calc.abs(x) >= 1.0 {
    0.0
  } else {
    calc.exp(-1.0 / (1.0 - x * x))
  }
}

#let mollifierPlot2d() = html.frame[
  #cetz.canvas({
    plot.plot(
      size: (8, 5),
      // "school-book" draws axes intersecting at the origin (0,0) with arrows
      axis-style: "school-book",
      x-label: $x$,
      y-label: $f(x)$,

      // Enable grids to visually anchor the coordinates
      // x-grid: true,
      // y-grid: true,

      x-min: -1.5,
      x-max: 1.5,
      x-tick-step: 0.5,

      // Extending below 0.0 ensures the flat tails at y=0 are
      // clearly visible inside the plot, not cut off by the canvas edge.
      // y-min: -0.1,
      y-max: 0.45,
      y-tick-step: 0.1,

      plot.add(
        domain: (-1.5, 1.5),
        samples: 200,
        style: (stroke: (paint: blue.darken(20%), thickness: 1.5pt)),
        mollifier2d,
      ),
    )
  })
]

#let bump-norm = 0.443993816168079

// 1. Standard Mollifier Definition
#let mollifier(x, eps) = {
  let scaled-x = x / eps
  if calc.abs(scaled-x) >= 1.0 {
    0.0
  } else {
    (1.0 / (eps * bump-norm)) * calc.exp(-1.0 / (1.0 - scaled-x * scaled-x))
  }
}

// 2. Mollified Heaviside Definition
#let mollified_heaviside(x, epsilon) = {
  if x <= -epsilon {
    0.0
  } else if x >= epsilon {
    1.0
  } else {
    irif.nm-integrate-simpsons(
      f_x: t => mollifier(t, epsilon),
      x0: -epsilon,
      x1: x,
      n: 16,
    )
  }
}

// 3. Combined Plot
#let combinedMollifierPlots() = html.frame[
  #cetz.canvas({
    plot.plot(
      size: (6, 5), // Adjusted size to fit side-by-side
      axis-style: "scientific-auto",
      x-label: $x$,
      y-label: $eta_epsilon(x)$,
      legend: none, // Removed legend here

      x-min: -1.5,
      x-max: 1.5,
      x-tick-step: 0.5,
      y-max: 3.5,
      y-tick-step: 0.5,

      {
        // epsilon = 1
        plot.add(
          domain: (-1.5, 1.5),
          samples: 200,
          style: (stroke: (paint: blue.darken(20%), thickness: 1.5pt)),
          x => mollifier(x, 1.0),
        )
        // epsilon = 1/2
        plot.add(
          domain: (-1.5, 1.5),
          samples: 400,
          style: (
            stroke: (
              paint: green.darken(20%),
              thickness: 1.5pt,
              dash: "dashed",
            ),
          ),
          x => mollifier(x, 0.5),
        )
        // epsilon = 1/4
        plot.add(
          domain: (-1.5, 1.5),
          samples: 800,
          style: (
            stroke: (
              paint: red.darken(20%),
              thickness: 1.5pt,
              dash: "dotted",
            ),
          ),
          x => mollifier(x, 0.25),
        )
      },
    )
  })

  // RIGHT PLOT: Mollified Heaviside Sequence (Unified Legend)
  #cetz.canvas({
    plot.plot(
      size: (6, 5),
      axis-style: "scientific-auto",
      x-label: $x$,
      y-label: $(H ast eta_epsilon)(x)$,
      // legend: "north-west", // Unified legend in the empty top-left space

      x-min: -1.5,
      x-max: 1.5,
      x-tick-step: 0.5,
      y-min: -0.1,
      y-max: 1.2,
      y-tick-step: 0.25,

      {
        // Reference Heaviside Step Function
        plot.add(
          domain: (-1.5, 0),
          samples: 500,
          style: (stroke: (paint: black, thickness: 1pt)),
          label: box(inset: .2em)[$H(x)$],
          x => if x <= 0 { 0 } else { 1 },
        )
        plot.add(
          domain: (0, 1.5),
          samples: 500,
          style: (stroke: (paint: black, thickness: 1pt)),
          x => if x < 0 { 0 } else { 1 },
        )
        // epsilon = 1
        plot.add(
          domain: (-1.5, 1.5),
          samples: 200,
          style: (stroke: (paint: blue.darken(20%), thickness: 1.5pt)),
          label: box(inset: .2em)[$epsilon = 1$],
          x => mollified_heaviside(x, 1.0),
        )
        // epsilon = 1/2
        plot.add(
          domain: (-1.5, 1.5),
          samples: 400,
          style: (
            stroke: (
              paint: green.darken(20%),
              thickness: 1.5pt,
              dash: "dashed",
            ),
          ),
          label: box(inset: .2em)[$epsilon = 1/2$],
          x => mollified_heaviside(x, 0.5),
        )
        // epsilon = 1/4
        plot.add(
          domain: (-1.5, 1.5),
          samples: 800,
          style: (
            stroke: (
              paint: red.darken(20%),
              thickness: 1.5pt,
              dash: "dotted",
            ),
          ),
          label: box(inset: .2em)[$epsilon = 1/4$],
          x => mollified_heaviside(x, 0.25),
        )
      },
    )
  })
]




= Introduction and motivation <sec:motivation>
Classical calculus relies on a strict notion of pointwise differentiability.
For the classical derivative of a function at a point to exist, the function must be free of sharp corners, kinks,
or discontinuous jumps in some open neighborhood around that point.

When modeling physical systems, such non-smooth phenomena are often regularized at microscopic scales.
For example, a physical guitar pick or a musician's finger has a finite radius, so a physical string
can not be drawn into a perfectly sharp corner. Similarly, striking a billiard ball does not exert
a unit impulse at a single instant in time, the acceleration occurs continuously over a finite contact window.
However, for understanding the underlying principles governing these systems, considering such microscopic
properties is often either unnecessary or computationally intractable. In physics, one frequently
abstracts these localized details away to work in an idealized setting where universal laws
can be clearly formulated.

Yet, when transitioning to this idealized setting, we will see that classical calculus is no longer the appropriate tool.
To bridge the gap between mathematical rigor and the desire to work in simplified, idealized models,
we must generalize the classical notion of the derivative to the _weak derivative_.
This report introduces this generalization through the theory of distributions and weak derivatives,
culminating in the construction of Sobolev spaces.

To see specifically where classical calculus fails,
consider a vibrating guitar string of length $L in RR_(> 0)$ fixed at both ends.
Let $u(x,t)$ denote the vertical displacement of the string at position $x in [0, L]$ and time $t >= 0$.
Let $u_(t t) := (partial^2 u) / (partial t^2)$ and $u_(x x) := (partial^2 u) / (partial x^2)$ denote the
second partial derivatives with respect to time and space, respectively. That is, $u_(t t)$ represents the
vertical acceleration of a point $x in [0,L]$ at time $t >= 0$, and $u_(x x)$ represents the local curvature
of the string at $(x, t)$.

The dynamics of the idealized string are governed by the one-dimensional wave equation:
$
  u_(t t)(x,t) - c^2 u_(x x)(x,t) = 0 quad "for" (x,t) in (0, L) times (0, oo).
$
The parameter $c in RR_(>0)$ represents the horizontal propagation speed of the wave.
Physically, the PDE states that the acceleration $u_(t t)$ of the string is proportional
to its curvature $u_(x x)$. When the string curves, tension exerts a restoring force.
The string being fixed at both its ends corresponds to the boundary conditions
$
  u(0,t) = 0 = u(L, t), quad "for all" t >= 0.
$
We assume that at time $t = 0$ the string is plucked to a height $h > 0$ at its center $L/2$ by an
idealized point pick and released from rest.

#figure()[
  #initial_condition()
]<fig:initial_condition>

The initial conditions are given by:
$
  u(x,0) = cases(
    (2h)/L x & "for" 0 <= x <= L/2,
    (2h)/L (L-x) quad & "for" L/2 < x <= L,
  )", and" u_t(x,0) = 0"."
$
The initial state of the string is depicted in @fig:initial_condition.
By definition, a classical solution of this initial-boundary value problem requires $u in C^2((0,L) times (0,oo))$
in the interior and $u in C^0([0,L] times [0,oo))$ up to the boundary so that all derivatives in the differential
equation and initial/boundary values are well-defined at all points in space and time.

Our initial state $u(x,0)$, however, possesses a sharp kink at $x = L/2$.
Although the initial displacement is continuous, its first spatial derivative jumps discontinuously at $L/2$:
$
  lim_(x -> (L/2)^-) u_x (x,0) = (2h)/L != -(2h)/L = lim_(x -> (L/2)^+) u_x (x,0).
$
Consequently, the second spatial derivative $u_(x x)$ does not exist at $x = L/2$.
By d'Alembert's formula, the one-dimensional wave equation propagates initial features along the characteristic
lines $x plus.minus c t = "const"$. The initial kink, therefore, does not smooth out over time. Rather,
it splits into two kinks that propagate in opposite directions across the string and reflect off the boundaries indefinitely.
At these points, $u_(x x)$ and $u_(t t)$ fail to exist, meaning that no classical $C^2$ solution can exist.

This non-existence does not imply that the wave equation is physically invalid for this initial condition.
Rather, it reveals that differentiability at all points is too restrictive in the setting of partial
differential equations to ensure the existence of solutions. A solution to this problem is provided
by the _weak derivative_, formulated using _distributions_ and test functions, which we will
introduce in this report.

= Distributions and Weak Derivatives
In this chapter we provide a brief recap of the definitions and concepts required to introduce the
distributional derivative and the weak derivative. The theory of distributions was first formalized
and developed by Laurent Schwartz in 1945 in the context of PDE theory @lutzen_prehistory_1982.

First, we need to introduce _test functions_, which can be thought of as a way to locally measure
the value of a function instead of pointwise evaluation of the function.
#definition[Space of test functions][
  Let $Omega$ be a domain in $RR^n$. A sequence $(phi_j)_(j in NN)$
  of functions $phi_j in C_c^oo (Omega)$ is said to _converge in $cal(D)(Omega)$_
  to the function $phi in C_c^oo (Omega)$, if
  + There exists $K subset.double Omega$ such that $supp (phi_j - phi)
    subset.eq K$ for all $j in NN$, and #label("top_prop_1")

  + $lim_(j to oo) D^alpha phi_j (x) = D^alpha phi (x)$ uniformly on $K$ for each
    multi-index $alpha$. #label("top_prop_2")
  In this case, we denote the convergence in $cal(D)(Omega)$ by $phi_j testto phi$.
  There exists a unique locally convex topology on $C_c^oo (Omega)$ such that a linear
  functional $T: C_c^oo (Omega) to CC$ is continuous if and only if $phi_j testto phi$ implies
  $T(phi_j) to T(phi)$. Equipped with this topology, $C_c^oo (Omega)$ is a topological vector space.
  To distinguish between this topological vector space and the space $C_c^oo (Omega)$, we denote the
  space $C_c^oo (Omega)$ equipped with the topology described above by $cal(D) (Omega)$ and call it
  the _space of test functions_. Elements of $cal(D)(Omega)$ are called _test functions_.
]<def:test_functions>

Proving the existence and uniqueness of the topology on $cal(D)(Omega)$ would be out of scope for
this report. We include it in the definition of the space of test functions, however,
because it uniquely determines the topological dual $cal(D)' (Omega)$.

#definition[Space of distributions][
  Let $Omega$ be a domain and $cal(D)(Omega)$ be the space of test functions on $Omega$. Then,
  the topological dual $cal(D)'(Omega)$ is called the _space of distributions_ on $Omega$. Elements
  of $cal(D)' (Omega)$ are called _distributions_.
]
It is not immediately obvious that distributions are useful for defining a more general notion of
differentiation, or even that distributions are general enough to provide a way of generalizing
functions. To motivate this, for $L,h in RR_(> 0)$ consider the function
$
  u: [0, L] & to [0, h] \
          x & mapsto cases(
                (2h)/L x & "for" 0 <= x <= L/2",",
                (2h)/L (L-x) quad & "for" L/2 < x <= L","
              )
$
corresponding to the initial condition of the wave equation example in @sec:motivation.
We define the function
$
  T_u : cal(D) ((0,L)) & to CC#[,] \
                   phi & mapsto integral_0^L u(x) phi(x) dif x#[.]
$
The linearity of $T_u$ follows immediately from the linearity of the integral.
For continuity, let $(phi_j)_(j in NN)$ be a sequence in $cal(D)((0,L))$ that converges to $phi in
cal(D)((0,L))$, i.e. $phi_j testto phi$. Then, by #link(<top_prop_1>, "Property 1.") of the topology
on $cal(D)((0,L))$, there exists $K subset.double (0,L)$ such that
$supp(phi_j - phi) subset K$ for all $j in NN$. Therefore,
#numberedBlock[
  $
    abs(T_u (phi_j) - T_u (phi)) <= sup_(x in K) abs(phi_j (x) - phi(x)) integral_K abs(u(x)) dif x to 0 quad "as" j to oo","
  $<eq:1>]
since we know that $phi_j to phi$ uniformly on $K$ by #link(<top_prop_2>, "Property 2.") of the
topology on $cal(D)([0,L])$, implying continuity of $T_u$.
These two properties together show that $T_u$ defines a distribution.
This can be generalized to locally integrable functions.
#definition[Locally integrable][
  Let $Omega$ be a domain and $u: Omega without N to CC$, where $N$ has measure $0$ w.r.t. the
  Lebesgue measure $lambda$, i.e. $lambda(N) = 0$. The function $u$ is called _locally integrable_ on $Omega$,
  if $u in L^1(U)$ for every open $U subset.double Omega$. In this case we denote _$u in
  L^1_loc (Omega)$_.
]
#lemma[
  Let $Omega$ be a domain and $u in L^1_loc (Omega)$. Then, the functional
  $
    T_u: cal(D)(Omega) & to CC#[,] \
                   phi & mapsto integral_Omega u(x) phi(x) dif x","
  $
  defines a distribution on $Omega$, i.e. $T_u in cal(D)' (Omega)$.
]<lemma:l1_loc_distribution>
#proof[
  Linearity immediately follows from the linearity of the integral. The proof of continuity is analogous
  to before, i.e. for any sequence $(phi_j)_(j in NN)$ in $cal(D)(Omega)$ with $phi_j testto phi$ for
  $phi in cal(D)(Omega)$ there exists $K subset.double Omega$ with $supp(phi_j - phi) subset K$, implying
  $ abs(T_u (phi_j) - T_u (phi)) <= sup_(x in K) abs(phi_j (x) - phi(x)) integral_K
  abs(u(x)) dif x to 0 quad "as" j to oo"," $ since $phi_j to phi$ uniformly on $K$.
]
@lemma:l1_loc_distribution implies that any locally integrable function induces a distribution.
Later, we will see that the converse does not hold, showing that the space of distributions
$cal(D)'(Omega)$ is strictly larger than the space $L^1_loc (Omega)$ for any domain $Omega$.

Distributions induced by elements of $L^1_loc (Omega)$ are of special importance.
#definition[Regular distribution][
  Let $Omega$ be a domain and $u in L^1_loc (Omega)$. Then, the distribution
  $
    T_u: cal(D)(Omega) & to CC \
                   phi & mapsto integral_Omega u(x) phi(x) dif x
  $
  is called a _regular distribution_.
]

With these definitions and the generality of distributions established,
we now want to proceed to define a way of differentiating functions that are not classically differentiable.
In order to do so, we first restrict to the special case of a scalar valued continuously differentiable function $u in C^1(Omega)$.
Then, for any $phi in cal(D)(Omega)$ and $1<=j<=n$, integration by parts and the compactness of the support of $phi$ yields
$
  T_(D_j u) (phi) & = integral_Omega (D_j u(x)) phi(x) dif x = - integral_Omega u(x) (D_j phi(x)) dif
                    x = - T_u (D_j phi)"."
$
This shifts the differentiation entirely onto the smooth test function, motivating the following
definition of a derivative of distributions.
#let gray(content) = text(fill: color.gray)[#content]
#definition[Distributional Derivative][
  Let $T in cal(D)' (Omega)$ be a distribution and $alpha$ be a multi-index. The
  _distributional derivative_ $D^alpha T in cal(D)' (Omega)$ is defined by the continuous linear
  functional:
  $
    (D^alpha T) (phi) = (-1)^(abs(alpha)) T(D^alpha phi) quad "for all" phi in cal(D)(Omega)"."
  $
]<def:distributional_derivative>
#lemma[
  Let $Omega$ be a domain. For any distribution $T in cal(D)' (Omega)$ and any multi-index $alpha$,
  the distributional derivative $D^alpha T$ of $T$ is still a distribution, i.e. $D^alpha T in cal(D)' (Omega)$.
]

#proof[
  To show that the distributional derivative $D^alpha T$ is an actual distribution,
  we must prove it is a continuous linear functional on the space of test functions $cal(D)(Omega)$.
  By definition, the action of $D^alpha T$ on a test function $phi in cal(D)(Omega)$ is given by
  $ (D^alpha T)(phi) = (-1)^abs(alpha) T(D^alpha phi). $

  / Linearity: Let $phi, psi in cal(D)(Omega)$ and let $a,b in CC$. Because the classical derivative
    $D^alpha$ is a linear operator on smooth functions and $T$ is a linear functional, we have:
    $
      (D^alpha T)(a phi + b psi) & = (-1)^abs(alpha) T(D^alpha (a phi + b psi)) \
                                 & = (-1)^abs(alpha) T(a D^alpha phi + b D^alpha psi) \
                                 & = a (-1)^abs(alpha) T(D^alpha phi) + b (-1)^abs(alpha) T(D^alpha psi) \
                                 & = a (D^alpha T)(phi) + b (D^alpha T)(psi).
    $
    Thus, $D^alpha T$ is linear.

  / Continuity: We must show that if a sequence of test functions $phi_j testto phi$ in $cal(D)(Omega)$, then $(D^alpha T)(phi_j) -> (D^alpha T)(phi)$ in $CC$.

    First, we establish that $D^alpha phi_j -> D^alpha phi$ in $cal(D)(Omega)$. By the definition of
    convergence of the sequence $phi_j testto phi$ we know:
    + There exists a compact set $K subset.eq Omega$ such that $supp(phi_j - phi) subset.eq K$ for
      all $j$. Since taking the derivative of a function does not expand its support, it follows
      that $supp(D^alpha (phi_j - phi)) subset.eq supp(phi_j - phi) subset.eq K"."$
    + For any multi-index $beta$, the derivatives $D^beta (phi_j - phi)$ converge uniformly to $0$
      on $K$ as $j -> infinity$. Consequently, for our multi-index $alpha$, the derivative
      $ D^beta (D^alpha (phi_j - phi)) = D^(beta+alpha) (phi_j - phi) $ also converges uniformly to zero on $K$.

    Because both conditions are satisfied, $D^alpha phi_j -> D^alpha phi$ in $cal(D)(Omega)$.

    Finally, since $T$ is a continuous functional by definition of $cal(D)^' (Omega)$,
    it maps convergent sequences in $cal(D)(Omega)$ to convergent sequences in $CC$. Therefore:
    $
      (D^alpha T)(phi_j) = (-1)^abs(alpha) T(D^alpha phi_j) -> (-1)^abs(alpha) T(D^alpha phi) = (D^alpha T)(phi).
    $

  Because $D^alpha T$ is both linear and continuous on $cal(D)(Omega)$, we conclude that $D^alpha T in cal(D)'(Omega)$.
]
To illustrate the derivative of distributions, let us consider the following example.
#example[The Heaviside Function][
  Let $ H: RR & to RR, \
      x & mapsto cases(0 quad &"for" x < 0",", 1 quad &"for" x >= 0".") $
  While $H$ is not classically differentiable at $x=0$, since $H in L^1_loc (RR)$ we know that it
  induces a distribution $T_H in cal(D)'(RR)$.

  For any $phi in cal(D)(RR)$, by compactness of the support of $phi$, its distributional derivative acts as:
  $
    (D T_H) (phi) = - integral_0^oo phi' (x) dif x = - lim_(x to oo) phi(x) + phi(0) = phi(0)"."
  $
  The distribution $delta := D T_H$, is commonly known as the _Dirac distribution_, in reference to
  the Dirac measure at the origin.
  Note that $delta$ cannot be represented by a locally integrable function, showing that not every
  distribution is regular and that the derivative of a regular distribution is not necessarily regular.
  // TODO: Picture maybe? E.g. counterexample using the standard bump function centered at 0.
]
While @def:distributional_derivative guarantees that every distribution possesses derivatives of all
orders, since test functions are infinitely differentiable, the resulting derivative is often singular,
as was the case with the Dirac distribution $delta$.

In the study of partial differential equations, singular distributions induce a severe bottleneck.
Namely, Schwartz’s impossibility theorem @schwartz1954impossibilite proves that one cannot define an associative,
bilinear product on a space of distributions containing $C^0(RR)$ that preserves the Leibniz rule
and coincides with pointwise multiplication of continuous functions.

For an informal intuition as to why singular distributions cause issues, assume that we have such a
multiplication operator on the space of distributions, denoted by the symbol
$
  dot.o: cal(D)' (RR) times cal(D)' (RR) to
  cal(D)' (RR)"."
$
Now consider the continuous functions $u(x) = x$ and $f(x) = x ln abs(x) - x$ (with $f(0) = 0$),
and their corresponding distributions $T_u, T_f in cal(D)'(RR)$.
Since $D T_f = T_(ln abs(x))$, applying the Leibniz product rule to $T_u$ and $T_(ln abs(x) - 1)$
yields $T_u dot.o D(T_(ln abs(x))) = T_1 = 1$. Moreover, for the Dirac
distribution $delta$ we have $T_u dot.o delta = 0$. Therefore, by associativity of the
multiplication we obtain
$
  0 = D(T_(ln abs(x))) dot.o (T_u dot.o delta) = (D(T_(ln abs(x))) dot.o T_u) dot.o delta = delta !=
  0","
$
a contradiction.
This matters for PDEs since the non-existence of a multiplication that is
compatible with the usual multiplication of smooth functions prevents us from using distributions in
the analysis of non-linear PDEs.
This motivates restricting our attention to functions whose distributional derivatives remain regular
distributions. This subclass of distributional derivatives forms the basis of the _weak derivative_.

#definition[Weak Derivative][
  Let $Omega$ be a domain, $u in L^1_loc (Omega)$, and $alpha$ be a multi-index. If there exists
  $v_alpha in L^1_loc (Omega)$ such that the regular distribution
  $T_(v_alpha) = D^alpha T_u$ in $cal(D)'(Omega)$, then $v_alpha$ is called the _weak partial
  derivative_ of $u$, denoted by $D^alpha u$.

  Equivalently, for $v_alpha$
  $
    integral_Omega u(x) D^alpha phi(x) dif x = (-1)^(abs(alpha)) integral_Omega v_alpha (x) phi(x) dif x quad "for all" phi in cal(D)(Omega)"."
  $
]
In the definition of the weak derivative, notice how we used the word "_the_", implicitly assuming
the uniqueness of the weak derivative, provided it exists. This needs some justification.
To analyze in what sense the weak derivative is unique, we will need the following result.
#lemma[Fundamental Lemma of Calculus of Variations][
  Let $Omega$ be a domain and $w in L^1_loc (Omega)$. If $integral_Omega w(x) phi(x) dif x = 0$ for all $phi in cal(D)(Omega)$,
  then $w(x) = 0$ almost everywhere (a.e.) in $Omega$.
]<lemma:fundamental_lemma_cov>
Before being able to prove this, we will need some more machinery that will also be useful later in
the theory of Sobolev spaces. We need some way of "smoothing" a discontinuous function. The
operation on functions that will allow us to do so is the convolution.

#definition[Convolution][
  Let $u,v: RR^n -> RR$ be measurable. The convolution $u convolve v$ is defined by
  $
    (u convolve v)(x) = integral_(RR^n) u(x-y) v(y) dif y","
  $
  provided the integral exists almost everywhere.
]
#lemma[
  Let $v in L^1_loc (RR^n)$ and $u in C_c (RR^n)$. Then, the convolution $(u convolve v)(x)$ is well-defined and continuous
  for _every_ $x in RR^n$.
]
#proof[
  Let $x in RR^n$. To see that $(u convolve v)(x)$ is well-defined,
  note that $u$ is continuous with compact support, so it is bounded by some constant $M > 0$.
  The function $y mapsto u(x - y)$ has compact support given by $x - supp(u)$.
  Because $v in L^1_loc (RR^n)$, its integral over this compact support is finite. Thus,
  $
    integral_(RR^n) abs(u(x - y) v(y)) dif y <= M integral_(x - supp(u)) abs(v(y)) dif y < oo","
  $
  which implies $y mapsto u(x - y)v(y)$ is integrable.

  For continuity, let $(x_n)_(n in NN)$ be a sequence in $RR^n$ that converges to $x in RR^n$.
  The set containing the sequence and its limit, $S = {x_n}_(n in NN) union {x}$, is compact.
  We define $K$ as the Minkowski difference $K := S - supp(u)$.
  Because the difference of two compact sets is compact, $K subset RR^n$ is a compact set.
  By construction, $(x_n - supp(u)) subset.eq K$ and $(x - supp(u)) subset.eq K$.
  Therefore, $u(x_n - y) = 0$ and $u(x - y) = 0$ for all $y in.not K$.

  By assumption, $u$ is continuous and has compact support, which implies that $u$ is uniformly continuous on all of $RR^n$.
  This uniform continuity allows us to define
  $
    epsilon_n := sup_(y in RR^n) abs(u(x_n - y) - u(x - y))"."
  $
  Since $x_n to x$, we know that $epsilon_n to 0$ as $n to oo$.
  Furthermore, because the difference $u(x_n - y) - u(x - y)$ is strictly zero outside $K$, we have the bound
  $
    abs(u(x_n - y) - u(x - y)) <= epsilon_n bb(1)_K (y) quad "for all" n in NN "and" y in RR^n"."
  $
  Because $v in L^1_loc (RR^n)$, we can pull the maximum error out of the integral to conclude
  $
    abs((u convolve v)(x_n) - (u convolve v)(x)) & <= integral_(RR^n) abs(u(x_n - y) - u(x - y)) abs(v(y)) dif y \
                                                 & <= epsilon_n integral_K abs(v(y)) dif y"."
  $
  Taking the limit as $n to oo$, the right-hand side converges to $0$ since $integral_K abs(v(y))
  dif y$ is finite. Thus, $lim_(n to oo) (u convolve v)(x_n) = (u convolve v)(x)$, proving continuity.
]
Mollifiers provide a convenient method of constructing functions that allows us to approximate any $u
in L^1_loc (Omega)$ by a sequence of compactly supported, smooth functions.
#definition[Mollifiers][
  Let $J in C_c^oo (RR^n)$ be a nonnegative function satisfying
  + $J(x) = 0$ if $abs(x) >= 1$
  + $integral_(RR^n) J(x) dif x = 1$.
  If $epsilon > 0$, then $J_epsilon (x) := epsilon^(-n) J(x/epsilon) in C_c^oo (RR^n)$ is also
  nonnegative and satisfies
  + $J_epsilon (x) = 0$, if $abs(x) >= epsilon$
  + $integral_(RR^n) J_epsilon (x) dif x = 1$.
  $J_epsilon$ is called a _mollifier_, and the convolution $J_epsilon convolve u(x)$ is called
  _mollification_, if it exists.
]
#example[Standard mollifier][
  Define the standard bump function $ eta(x) := cases(
    exp(-1 / (1-abs(x)^2))"," & abs(x) < 1, 0","
    &"else."
  ) $
  The associated mollifiers are depicted in @fig:standard_mollifier.
  #figure()[
    #combinedMollifierPlots()
  ]<fig:standard_mollifier>
]

#lemma[#ref(<brezis_functional_2011>, supplement: "Theorem 4.22")][
  Let $f in L^p (RR^n)$ and $J_epsilon in C_c^oo (RR^n)$ be a sequence of mollifiers. Then,
  $ lim_(epsilon to 0) (J_epsilon convolve f) = f $ in $L^p (RR^n)$.
]
With the mollification being established, we are now ready to tackle the proof of
@lemma:fundamental_lemma_cov.
#proof[of @lemma:fundamental_lemma_cov][
  Let $g in L^oo (RR^n)$ be a function such that $supp(g)$ is a compact set contained in $Omega$.
  Set $g_n = J_(1/n) convolve g$, so that $g_n in C_c^oo (Omega) = cal(D)(Omega)$ provided $n$ is large enough. Therefore, by assumption, we have
  #numberedBlock[
    $
      integral_Omega w(x) g_n(x) dif x = 0 quad "for all large" n"."
    $<eq:fund_1>
  ]
  Since $g_n to g$ in $L^1(RR^n)$ (by the previous lemma), there is a subsequence, which we
  denote by $g_(n_j)$, such that $g_(n_j) to g$ a.e. on $RR^n$ (#ref(<brezis_functional_2011>, supplement: "Theorem 4.9").
  Moreover, by the properties of the convolution we have
  $
    norm(g_(n_j))_(L^oo (RR^n)) <= norm(g)_(L^oo (RR^n))"."
  $
  Passing to the limit in @eq:fund_1, the dominated convergence theorem yields
  #numberedBlock[
    $
      integral_Omega w(x) g(x) dif x = 0"."
    $<eq:fund_2>
  ]
  Now, let $K$ be an arbitrary compact set contained in $Omega$. We define the function $g$ as
  $
    g(x) = cases(
      "sign"(w(x)) quad & "for" x in K",",
      0 & "for" x in RR^n without K"."
    )
  $
  Since $g$ is bounded and has compact support in $Omega$, it is a valid choice. Substituting this $g$ into @eq:fund_2, we deduce that
  $
    integral_K abs(w(x)) dif x = 0","
  $
  and thus $w = 0$ a.e. on $K$. Since this holds for any compact $K subset.double Omega$, we conclude that $w = 0$ a.e. on $Omega$.
]
An immediate consequence of @lemma:fundamental_lemma_cov is the uniqueness of the weak derivative up
to sets of measure $0$.
#corollary[
  Let $Omega$ be a domain and $u in L^1_loc (Omega)$ such that there exists some $v_alpha in L^1_loc
  (Omega)$ with $D^alpha T_u = T_(v_alpha)$. Then, $v_alpha$ is unique up to sets of measure zero
  w.r.t. the Lebesgue measure $lambda$.
]
It is also worth noting, that the weak and classical derivatives are consistent, i.e. for any
differentiable function $u in C^(abs(alpha)) (Omega)$, the derivative $D^alpha u$ satisfies the
criteria of the weak derivative.
#corollary[Consistency with Classical Derivatives][
  If $u in C^abs(alpha)(Omega)$, classical integration by parts confirms that its classical partial
  derivative $D^alpha u$ satisfies the definition of the weak derivative.
  Thus, classical and weak derivatives coincide for sufficiently smooth functions.
]
We can now define Sobolev spaces, which was the goal of this report.
= Sobolev Spaces
Because weak derivatives are defined via integration and are uniquely determined only up to sets of measure zero,
the natural setting for their study is the framework of Lebesgue spaces.
Let us first recap some basic facts about $L^p$ spaces on a domain $Omega$.
#definition[$L^p (Omega)$-space][
  Let $emptyset != Omega subset.eq RR^n$ be a domain and $1 <= p < oo$. The space $L^p (Omega)$ is defined as the
  set of equivalence classes of Lebesgue-measurable functions $u$ on $Omega$ (where $u tilde v$ if $u = v$ a.e.) such that:
  $
    norm(u)_p = (integral_Omega abs(u(x))^p dif x)^(1/p) < oo
  $
  For $p = oo$, $L^infinity (Omega)$ is the space of equivalence classes of essentially bounded
  measurable functions, equipped with the norm $norm(u)_infinity = "ess sup"_(x in Omega) abs(u(x))$
  where $"ess sup"_(x in Omega) abs(u(x)) = inf {a >= 0: lambda ({x in Omega: abs(u(x)) > a }) = 0}$.
]

#theorem[@noauthor_lebesgue_2003, Completeness][
  Equipped with $norm(dot)_p$, $L^p (Omega)$ is a Banach space for $1 <= p <= infinity$.
]
#theorem[@noauthor_lebesgue_2003, Separability][
  $L^p (Omega)$ is separable, if $1 <= p < oo$.
]
#theorem[@noauthor_lebesgue_2003, Approximation by continuous functions][
  The space $C_c (Omega)$ is dense in $L^p (Omega)$ if $1 <= p < oo$.
]

We now have all the necessary components: a rigorous derivative for non-smooth functions and a space
to measure their integrability ($L^p$). We are finally ready to define the central object of this theory.

#definition[The Sobolev Norms][
  Let $m$ be a positive integer and $1 <= p <= infinity$. For $u in L^p (Omega)$ with $D^alpha u in
  L^p (Omega)$, $abs(alpha) <= m$, the Sobolev norm $norm(dot)_(m,p)$ is defined as:
  $
    norm(u)_(m,p) = (sum_(0 <= abs(alpha) <= m) norm(D^alpha u)_p^p)^(1/p) quad "if " 1 <= p < oo
  $
  and
  $
    norm(u)_(m,infinity) = max_(0 <= abs(alpha) <= m) norm(D^alpha u)_infinity quad "if " p = oo
  $
]

#definition[Sobolev Spaces][
  For any positive integer $m$ and $1 <= p <= infinity$, the vector spaces
  - $W^(m,p)(Omega) := {u in L^p (Omega) : D^alpha u in L^p (Omega) " for all " 0 <= abs(alpha) <= m}$
  - $H^(m,p) (Omega)$ given by the completion of ${u in C^m (Omega): norm(u)_(m,p) < oo}$ w.r.t.
    $norm(dot)_(m,p)$
  - $W_0^(m,p)(Omega) := overline(C_c^oo (Omega))^(W^(m,p)(Omega))$, i.e. closure of $C_c^oo (Omega)$ in $W^(m,p)
    (Omega)$

  equipped with the norm $norm(dot)_(m,p)$, are called Sobolev spaces.
]<def:sobolev_spaces>

#remark[
  Beppo Levi and Guido Fubini were the first to look into the concept of Sobolev spaces for the
  special case $p=2$. French mathematicians then called these spaces Beppo-Levi spaces. Beppo Levi,
  however, didn't like the "modern" way of doing mathematics and therefore objected to these spaces
  being named after him. The next choice was then Sobolev who did not object @naumann_remarks_2002.
]
#theorem[
  $W^(m,p) (Omega)$ is a Banach space.
]<thm:sobolev_banach>
For the proof of @thm:sobolev_banach we will need Hölders inequality.
#lemma[Hölder's inequality][
  Let $1 <= p <= oo$ and $p'$ such that $1/p + 1/p' = 1$. Then for all measurable functions $f: Omega
  to CC$ we have $ norm(f g)_1 <= norm(f)_p norm(g)_(p')"." $
]

#proof[of @thm:sobolev_banach][
  Let $(u_n)$ be a Cauchy sequence in $W^(m,p) (Omega)$. We have to show that there exists some $u in W^(m,p)
  (Omega)$ such that $norm(u_n - u)_(m,p) to 0$.

  By the definition of the Sobolev norm, for every multi-index $alpha$ with $0 <= abs(alpha) <= m$, the sequence $(D^alpha u_n)$ is a Cauchy sequence in $L^p (Omega)$. Note that this includes the case $abs(alpha) = 0$, which corresponds to the sequence $(u_n)$ itself.
  Therefore, by the completeness of $L^p (Omega)$, there exist limit functions $u_alpha in L^p (Omega)$ such that $D^alpha u_n to u_alpha$ in $L^p (Omega)$. We set $u := u_0$.

  Now, we still need to show that $u_alpha = D^alpha u$ in the sense of distributions.
  Since $L^p (Omega) subset.eq L^1_loc (Omega)$ we know that $u_n$ induces a distribution $T_(u_n)
  in cal(D)' (Omega)$. Therefore, for any $phi in cal(D) (Omega)$ we have
  $
    abs(T_(u_n) (phi) - T_u (phi)) <= integral_Omega abs(u_n (x) - u(x)) abs(phi(x)) dif x <=
    norm(phi)_(p') norm(u_n - u)_p
  $
  by Hölder's inequality for $p'$ such that $1/(p') + 1/p = 1$.
  Therefore, $T_(u_n) to T_u$. Analogously, since $D^alpha u_n to u_alpha$ in $L^p (Omega)$, we have $T_(D^alpha u_n) to T_(u_alpha)$.
  It follows that for all $phi in cal(D) (Omega)$
  $
    T_(u_alpha) (phi) = lim_(n to oo) T_(D^alpha u_n) (phi) = lim_(n to oo) (-1)^(abs(alpha)) T_(u_n)
    (D^alpha phi) = (-1)^(abs(alpha)) T_u (D^alpha phi)"."
  $
  Thus, $u_alpha = D^alpha u$ in the weak sense on $Omega$, meaning $u in W^(m,p) (Omega)$. Completeness
  follows from $lim_(n to oo) norm(u_n - u)_(m,p) = 0$, since $norm(D^alpha u_n - D^alpha u)_p to 0$ for all $0 <= abs(alpha) <= m$.
]
An immediate consequence of the completeness of $W^(m,p)$ we get the following statement relating
the spaces $H^(m,p)$ and $W^(m,p)$.
#corollary[
  $H^(m,p) (Omega) subset.eq W^(m,p) (Omega)$.
]<cor:H_subset_W>
#proof[
  Distributional and partial derivatives are equal whenever the latter exists and are continuous on
  $Omega$, therefore $S := {phi in C^m (Omega): norm(phi)_(m,p) < oo}$ is contained in $W^(m,p)
  (Omega)$.
  By completeness of $W^(m,p) (Omega)$, the identity $id: S to S$ extends to an isometric
  isomorphism between the closure of $S$ in $W^(m,p)$ and $H^(m,p)$, which is the completion of $S$
  w.r.t. $norm(dot)_(m,p)$. Then, $H^(m,p)(Omega)$ can be identified with the closure of $S$ in
  $W^(m,p)(Omega)$.
]
= Outlook
Having established in @cor:H_subset_W that $H^(m,p)(Omega) subset.eq W^(m,p)(Omega)$, it is only
natural to ask whether the converse also holds. That is, do the different definitions of Sobolev
spaces in @def:sobolev_spaces actually result in distinct spaces?

Historically, mathematicians actually treated them as distinct spaces for some time.
$H^(m,p)$ is built bottom-up by taking the completion of perfectly smooth functions,
while $W^(m,p)$ is defined top-down, starting with rough $L^p$ functions and simply demanding they
have weak derivatives.

The Meyers-Serrin theorem, famously titled "$H=W$", proves that $W^(m,p)(Omega) = H^(m,p)(Omega)$
does indeed hold @meyers_h_1964.
This result matters immensely for the modern theory of PDEs because it guarantees that any weakly
differentiable function, no matter how "rough," can be approximated by a sequence of perfectly smooth,
classical functions. This allows us to prove complex identities (like product rules or integration by parts)
for smooth functions where standard calculus applies, and then safely pass to the limit to show they
also hold for Sobolev functions.

The proof of the Meyers-Serrin theorem heavily relies on the local smoothing power of the mollifiers
introduced in this report, pairing them with a tool called "partitions of unity"
to glue those local approximations into a single, global smooth function.

#bibliography("sobolev-spaces.bib")
