## Today's course

- Intro to Julia
  - very quick overiew, explanations on demand
  - show how to use several common algorithms
- Perturbation
- Time Iteration (with/without improvements)
- Solve Ayiagari-style model

----

## Quick personal intro

- my job
  - teaching at ESCP/Ecole Polytechnique
  - research on inequality, monpol, international finance and
  - ...computational methods
- worked on various opensource projects:
  - interpolation.py (interpolation in python)
  - dolo.py/dolo.jl (language to describe optimization models)
  - dolark.py/dolark.jl (same for heterogenous agents)
  - tangentially: hark, quantecon, ...
- for today we will use "teaching" library NoLib

----


### Julia resources

- Many excellent online resources:

    - [Software Carpentry](https://software-carpentry.org/)
    - [QuantEcon](https://quantecon.org/news-item/need-for-speed-in-julia) from Tom Sargent and John Stachurski
    - [Julia manuals/tutorials](https://julialang.org/learning/)
    
- Opensource community is very welcoming:

    - ask on mailing lists or online chats (Julia users, quantecon, dynare, ...)
    - open issues (for instance against Dolo [https://github.com/EconForge/Dolo.jl/issues](https://github.com/EconForge/Dolo.jl/issues)
    - participating is also a great occasion to learn

----

### Installing Julia

- To get Julia on your laptop:
  1. install JuliaUp (it can keep several versions in parallel)
  2. install VSCode then install julia plugin
  3. to edit jupyter notebooks, install Julia package IJulia
- Online options:
  - github codespaces / gitpod
  - mybinder (requires Project.toml)

----

## Programming spirit

- ideal qualities of a programming language
  - easy (simple constructs and syntactic sugar)
  - elegant (concise, close to algorithmic/mathematical description)
  - optimizable (able to generate efficient machine code)
  - deep (a lot to learn ;-))
- Julia comes close in many directions
  - in great part due to its "type system" and multiple dispatch

----

## Optimization strategies

- optimization strategies with Julia
  - algorithmic improvements
  - efficient compilation
    - provide the compiler with enough information
    - optimize compilation steps
      - (julia->llvm->llvm-IR->CPU)
  - memory management
    - avoid memory allocations
  - vectorization / parallelization
    - target SSD operations, GPU, multiproc, ...
  - differentiable programming

----

## Why is memory management so important?

![](Memory-Access-vs-CPU-speed.png)

- in the julia community "memory allocation" means "heap allocation" 
  - it uses the equivalent of C's `memalloc`
- "stack allocated" variables are completely known by the compiler

----

## Optimization strategies (today)

- Today we will:
  - provide just enough type information to avoid performance hits
  - use some zero-cost abstractions to write more transparent/generic code
  - use autodiff when possible, fall back on finitediff when not
  - no more optimization...

---
