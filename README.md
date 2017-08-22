# PFlow.jl

### Simulation of Production Systems and Projects

`PFlow.jl` is a [`Julia`](https://julialang.org) library, which allows to
simulate the main physical characteristics of production systems and projects.
You can find the main assumptions by `PFlow` in [03 Simulation of Production Systems](http://localhost:8888/notebooks/docs/notebooks/03%20Simulation%20of%20Production%20Systems.ipynb).

`PFlow` takes a hybrid approach, generalizing only as much as needed and remaining
true to physical characteristics as much as possible. So implementation can
be without much overhead. It provides a model kit for basic entities of production
systems or projects like

- work units,
- orders,
- materials/products.

Those entities can be

- combined and used in an simulation application or
- collected and parametrized in lists (`.csv`-files) which are read by `PFlow` in
order to keep programming needs to a minimum.

Then `PFlow` contains utility functions to run simulations and to visualize,
document, store and compare the results. 

[`Julia`](https://julialang.org) (with [`SimJulia`](https://github.com/BenLauwens/SimJulia.jl))
is maturing and can provide for a really fast simulation library, capable –
together with `PFlow's` hybrid approach – to model and simulate even large systems
as in production, in automotive plants or in multiprojects.

### Status of Project (as of 08/2017)

`PFlow` is in early development. Things are coming together quite quickly and a
working prototype and some interesting results should be available in this
repository by September 2017.
