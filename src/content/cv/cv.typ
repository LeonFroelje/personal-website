// src/content/cv/cv.typ
#metadata((title: "CV")) <frontmatter>

#import "..//typst-lib/resume.typ": education, resume, two-col, workExperience

#show: resume.with(
  name: "Leon Frölje",
  email: link("mailto:Leon@Froelje.dev", "Leon@Froelje.dev"),
  github: link("https://github.com/LeonFroelje", "github.com/LeonFroelje"),
  workExperiences: (
    workExperience("10/2022–10/2023", "Tutor Applied Computer Science", "University Bremen", none, (
      "Object-oriented programming in Java",
      "Algorithms and data structures in Java",
    )),
    workExperience("08/2024–09/2025", "Working student", "State and University Library Bremen", none, (
      "Back- and frontend development for Pollux project",
    )),
    workExperience("02/2025-09/2026", "Working student", "University Bremen", none, (
      "LaTeX template creation for thesis",
      "Website maintenance in Typo3",
      "Python script for lecture scheduling and room assignment",
    )),
    workExperience("11/2025-09/2026", "Scientific Working student", "DFKI", "Bremen", (
      "Quantum computing research",
      "An Efficient Encoding for Subset Sum Problem
Exploiting QFT-Based Arithmetic Operators, IEEE Quantum Week 2026",
      "A Constraint-Preserving QAOA Approach to the
Flight Gate Assignment Problem",
    )),
  ),
  education: (
    education("10/2021-10/2024", "University Bremen", none, "Bachelor of Science in Mathematics", (
      "Project on optimal assignment of conference attendees to workshops",
      "Discretization of Geodesic flow on the modular surface using Lie groups",
      "Application subject computer science",
    )),
    education("10/2024-pending", "University Bremen", none, "Master of Science Mathematics", (
      "Specialization Analysis",
      "Master thesis on Kernel analog forecasting",
      "Application subject computer science",
    )),
  ),
)
#line(length: 100%, stroke: .5pt + rgb("#CCC"))
#two-col[
  = Miscellaneous
  - StugA Mathematics
  - Head of FBMI e.V.
  - Winner Bremen Big Data Challenge 2024
  - 2nd place Acroba Hackathon 2024
][
  = Skills
  - German, English
  - Python, JavaScript, Rust
  - Linux (Debian, Ubuntu, NixOS, Proxmox)
  - Docker
  - Terraform/OpenTofu
]
