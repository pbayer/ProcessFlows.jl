# API (Application Interface)

## Discrete event simulation

`PFlow` contains some basic types and functions for writing generic discrete
event simulations using [Julia tasks](https://docs.julialang.org/en/stable/manual/control-flow/#man-tasks-1).

### Types

Only two types are necessary: an event source and a specific type of
exception (if you want to communicate errors to simulation tasks).

```@docs
DES
SimException
```

### Tasks and scheduling

Simulations are based on Julia tasks calling the
simulation event source with `delayuntil` or `delay` and otherwise coordinate
by using Julia [channels](https://docs.julialang.org/en/stable/manual/parallel-computing/#Channels-1)
or other [library functions for parallel computing](https://docs.julialang.org/en/stable/stdlib/parallel/#Tasks-and-Parallel-Computing-1).

```@docs
now
delayuntil
delay
```

### Startup

We must start a simulation, which generates a clock of simulation time and handles
simulation events, which were created by tasks calling `delay` or `delayuntil`.

```@docs
simulate
```

## Product flow systems

### Types

Types describe the typical entities of production systems.

```@docs
Workunit
Workunits
Job
Orders
Planned
Plan
Product
Products
```

### Constants

Constants are used to code for certain characteristics and statuses.

**Work unit types:**

```julia
const MACHINE = 1
const WORKER = 2
const TRANSPORT = 3
const INSPECTOR = 4
const STORE = 5
```

**Work unit statuses:**

```julia
const IDLE = 0
const WORKING = 1
const FAILURE = 2
const BLOCKED = 3
```

**Job/order statuses:**

```julia
const OPEN = 0
const PROGRESS = 1
const DONE = 4
const FINISHED = 5
```

### Scheduling

Most simulated scheduling of products is done internally. The user has
1. to create a master production schedule (mps),
2. define a `Products` buffer for finished goods and
3. start scheduling.
before calling `simulate`.

```@docs
create_mps
start_scheduling
```

### Reading Parameters

Product flow systems are parametrized by `.csv`-files. Providing both lists for
work units and for orders and reading them with those functions avoids a lot of
programming:

```@docs
readWorkunits
readOrders
```

### Tables

Simulation results can be viewed as tables.

```@docs
wulog
productlog
queuelog
loadtable
leadtimetable
```

### Graphs

Orders and simulation results can be transformed into directed graphs, which then can be
viewed with the [`LightGraphs`](https://github.com/JuliaGraphs/LightGraphs.jl) package.

```@docs
ordergraph
flowgraph
```

### Charts

Simulation results can be visualized as charts:

```@docs
loadtime
loadstep
loadbars
flow
leadtime
queuelen
```
