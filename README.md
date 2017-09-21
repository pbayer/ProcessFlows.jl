# PFlow.jl

## Notice

`PFlow.jl` now uses Julia's coroutine functionality. The functions for discrete
event simulation are in `src/sim.jl`. Queues in `src/queue.jl` are based on channels.

----------------------

## Simulation of product flow

`PFlow.jl` is a [`Julia`](https://julialang.org) library, able to
simulate the **product flow** in production, development and service systems.
Since **product** can mean different things, it can simulate production, project,
customer or even patient flow …

### Simple approach

`PFlow` provides a model kit for basic entities of production systems like

- work units,
- orders/jobs,
- materials/products.

Those entities are collected and described in lists (`.csv`-files) which
are read by `PFlow` in order to keep programming needs to a minimum.

`PFlow` contains utility functions to run simulations and to visualize,
document, store and compare the results.

[`Julia`](https://julialang.org) allows a really fast simulation library, capable –
together with `PFlow's` simple approach – to model and simulate even large systems
as automotive plants, multiprojects or hospitals.

## Documentation

### Notebooks

`PFlow` now uses Julia coroutines and provides a simple framework for discrete
event simulation. The first two notebooks demonstrate this for simple simulations:

- [01 A Post Office](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/01%20A%20Post%20Office.ipynb)
shows a queueing simulation.
- [02 Goldratt's Dice Game](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/02%20Goldratt's%20Dice%20Game.ipynb)
shows a simulation of Goldratt's dice game, which is a much simplified production
line simulation.

The other notebooks show assumptions and applications of `PFlow.jl` for simulation
of real product flow systems:

- [03 Simulation of Production Systems](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/03%20Simulation%20of%20Production%20Systems.ipynb) describes the main assumptions implemented in `Pflow`.
- [04 Variation in Projects and Production](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/04%20Variation%20in%20Projects%20and%20Production.ipynb) describes, how `PFlow` treats variation.
- [05 Parametrization of Production Systems](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/05%20Parametrization%20of%20Production%20Systems.ipynb) describes, why it is possible to parametrize simulations of
production systems and projects by simple lists.
- [06 Visualization of Product Flow](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/06%20Visualization%20of%20Product%20Flow.ipynb) is the 1st demonstration of the `PFlow` prototype in a notebook.
- [07 First PFlow benchmarks](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/07%20First%20PFlow%20benchmarks.ipynb) is the first benchmark of the `PFlow` prototype.

## Status of Project (as of 09/2017)

`PFlow` is in early development. Things are coming together quite quickly and a
working prototype and some interesting results should be available in this
repository by end of September 2017.
