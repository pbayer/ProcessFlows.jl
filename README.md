# PFlow.jl

### Simulation of Production Systems and Projects

`PFlow.jl` is a [`Julia`](https://julialang.org) library, which can
simulate the main physical characteristics of production systems and projects.

My notebook [03 Simulation of Production Systems](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/03%20Simulation%20of%20Production%20Systems.ipynb) describes the main assumptions regarding production systems, which are implemented
in `Pflow`. In [04 Variation in Projects and Production](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/04%20Variation%20in%20Projects%20and%20Production.ipynb), I describe `PFlow's` treatment of variation.

`PFlow` takes a hybrid approach, generalizing only as much as needed and remaining
true to physical characteristics as much as possible. So the implementation can
be without much overhead. It provides a model kit for basic entities of production
systems or projects like

- work units,
- orders/jobs,
- materials/products.

Those entities can be

- combined and used in a simulation application or
- collected and parametrized in lists (`.csv`-files) which are read by `PFlow` in
order to keep programming needs to a minimum.

`PFlow` will contain utility functions to run simulations and to visualize,
document, store and compare the results.

[`Julia`](https://julialang.org) (with [`SimJulia`](https://github.com/BenLauwens/SimJulia.jl))
is maturing and can provide for a really fast simulation library, capable –
together with `PFlow's` hybrid approach – to model and simulate even large systems
as in production, in automotive plants or in multiprojects.

### Status of Project (as of 08/2017)

`PFlow` is in early development. Things are coming together quite quickly and a
working prototype and some interesting results should be available in this
repository by September 2017.
