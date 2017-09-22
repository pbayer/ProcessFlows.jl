# API (Application Interface)

## Discrete event simulation

### Main types

```@docs
Event
DES
SimException
```

### Functions for tasks and scheduling

```@docs
register
now
delayuntil
delay
interrupttask
```

### Starting a simulation

`simulate` starts a simulation clock and an event handler, which tasks can call
by `delay` or `delayuntil`.

```@docs
simulate
```

## Types and constants

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

Work unit types:

```julia
const MACHINE = 1
const WORKER = 2
const TRANSPORT = 3
const INSPECTOR = 4
const STORE = 5
```

Work unit status:

```julia
const IDLE = 0
const WORKING = 1
const FAILURE = 2
const BLOCKED = 3
```

Job/order status:

```julia
const OPEN = 0
const PROGRESS = 1
const DONE = 4
const FINISHED = 5
```

## Queueing

```@docs
PFQueue
isfull
isempty
capacity
length
front
back
enqueue!
dequeue!
```

## Working

```@docs
work
workunit
machine
worker
transport
```

## Scheduling
```@docs
Mps
create_mps
scheduler
source
sink
start_scheduling
sched
```

## Reading Parameters
```@docs
readWorkunits
readOrders
```

## Getting simulation results

### Tables
```@docs
wulog
productlog
queuelog
loadtable
leadtimetable
```

### Graphs
```@docs
ordergraph
flowgraph
```

### Charts
```@docs
loadtime
loadstep
loadbars
flow
leadtime
queuelen
```



export
export
export
export
