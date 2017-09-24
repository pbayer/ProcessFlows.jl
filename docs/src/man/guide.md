# Package Guide

## Installation

`PFlow` is a registered package **(not yet)** and so can be installed via:

```julia
Pkg.add("PFlow")
```

This package supports Julia `0.6`.

## Usage

`PFlow.jl` can be used in two ways:
- as a library containing elementary functions for writing generic discrete event
  simulations in Julia
- as an engine with specialized functions for discrete event simulations of
  product flow systems as in production, projects, service …

### Generic use for discrete event simulations

`Pflow.jl` uses [Julia tasks](https://docs.julialang.org/en/stable/manual/control-flow/#man-tasks-1)
for simulations, Julia functions which are started as tasks eg. with `@async myfunc(sim, ...)`
and can then use `PFlow's` simulation functions `delay(sim, time)` or `delayuntil(sim, time)`
in order to be suspended until a certain simulation time is reached.

Proprietary simulation tasks, using `PFlow` in this way, have
to care for exception handling or logging for themselves. They can use all
other [Julia coroutine functionality](https://docs.julialang.org/en/stable/manual/parallel-computing/#Scheduling-1)
and [library functions](https://docs.julialang.org/en/stable/stdlib/parallel/#Tasks-and-Parallel-Computing-1)
in order to coordinate and communicate with other tasks. You get the full Julia
stacktrace if an error occurs, which is good for development and debugging.

In order to use `PFlow's` simulation facilities, you have to
1. import first Pflow with `**using** PFlow`,
2. define a simulation variable with eg. `sim = DES()`,
3. write Julia functions importing the simulation variable as in `**function** myfunc(sim::DES, ...)`,
4. using the `PFlow` functions for relative `delay(sim, time)` or absolute `delayuntil(sim, time)`,
5. start and schedule the proprietary simulation functions as tasks with `**@async** myfunc(sim, ...)`,
6. get them running asynchronously with eg. `yield()` or better `sleep(0.1)` and then
7. start the simulation for a certain simulation time with `simulate(sim, time)`.

The `simulate` function then jumps from one discrete simulation time event to the next
and calls the client tasks, which suspended previously by calling `delay` or `delayuntil`.
Those give again control back to `simulate` by calling `delay`
and so on.

### Specific use for simulation of product flow systems

`PFlow` provides a model kit for basic entities of production systems like

- work units,
- orders/jobs,
- materials/products.

Those entities are collected and described in lists (`.csv`-files) which
are read by `PFlow` in order to keep programming needs to a minimum. Utility
functions allow to prepare the simulations and to visualize, document, store and
compare results.
