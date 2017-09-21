# PFlow.jl


## Simulation of product flow

`PFlow.jl` is a [`Julia`](https://julialang.org) library, able to
simulate the **product flow** in production, development and service systems.
Since **product** can mean different things, it can simulate production, project,
customer or even patient flow … even of large systems
as automotive plants, multiprojects or hospitals.

### Simple approach

``PFlow` uses Julia's coroutines and channels for discrete event simulation
and provides a model kit for basic entities of production systems like

- work units,
- orders/jobs,
- materials/products.

Those entities are collected and described in lists (`.csv`-files) which
are read by `PFlow` in order to keep programming needs to a minimum. Utility
functions allow to run simulations and to visualize, document, store and
compare results.

## Documentation

### Notebooks

These [`Jupyter`](http://jupyter.org/about.html) notebooks demonstrate `PFlow's`
simple framework for discrete event simulation: `delay` and `delayuntil`
combined with use of Julia's channels:

- [01 A Post Office](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/01%20A%20Post%20Office.ipynb)
shows a queueing simulation.
- [02 Goldratt's Dice Game](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/02%20Goldratt's%20Dice%20Game.ipynb)
shows a simulation of Goldratt's dice game, which is a very simplified production
line simulation.

Further notebooks show `PFlow's` assumptions and applications for simulations
of product flow systems:

- [03 Simulation of Production Systems](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/03%20Simulation%20of%20Production%20Systems.ipynb) describes the main assumptions.
- [04 Variation in Projects and Production](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/04%20Variation%20in%20Projects%20and%20Production.ipynb) describes, how `PFlow` treats variation.
- [05 Parametrization of Production Systems](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/05%20Parametrization%20of%20Production%20Systems.ipynb) describes, why it is possible to parametrize simulations of production systems and projects by simple lists.
- [06 Visualization of Product Flow](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/06%20Visualization%20of%20Product%20Flow.ipynb) is the 1st demonstration of the `PFlow` prototype in a notebook.
- [07 First PFlow benchmarks](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/07%20First%20PFlow%20benchmarks.ipynb) is the first benchmark of the `PFlow` prototype.
- [08 Intro to PFlow (Slides)](https://github.com/pbayer/PFlow.jl/blob/master/docs/notebooks/08%20Intro%20to%20PFlow%20(Slides).ipynb) is an Jupyter notebook with an slideshow, which can be viewed using [RISE](https://github.com/damianavila/RISE).

## Status of Project (as of 09/2017)

`PFlow` is in early development. Things are coming together quite quickly and a
working prototype and some interesting results should be available in this
repository by end of September 2017.
