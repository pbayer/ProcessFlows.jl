# PFlow – ToDo

Since `PFlow` is in early development, there remains a lot to do in order to make
it fit for general use in simulation of production and project environments:

## `activities.jl`:

- implement **transport**
- implement **multitasking** (a central feature of projects)
- implement **batch processing**

## `schedule.jl`:

- create transport jobs only if the input queue of the target is not full
- implement **materials/products** (necessary for staged processes, where
  products branch or combine)

## Documentation

## Stats and visualization

- lead times
- workload
- workflow (network graph)
- resource constraints
