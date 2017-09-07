# PFlow – ToDo

Since `PFlow` is in early development, there remains a lot to do in order to make
it fit for general use in simulation of production and project environments:

### core processing: `activities.jl`

- [ ] (0.1) implement **transport**
- [ ] (0.1) implement **store**
- [ ] (0.2) implement **multitasking** (a central feature of projects)
- [ ] (0.2) implement **batch processing**

### scheduling: `schedule.jl`:

- [ ] (0.1) create transport jobs only if the input queue of the target is not full
- [ ] (0.2) implement priority scheduling
- [ ] (0.2) implement scheduling strategies (CONWIP, DBR and the like)
- [ ] (0.2) implement jobs, in which the sequence doesn't matter (eg. healthcare)

### Documentation

- [ ] (0.1) API Documentation
- [ ] (0.1) Outline
- [ ] (0.1) Examples

### Tables, stats and visualization: `eval.jl`, `viz.jl`, `graphs.jl`

- [ ] (0.1) queue lengths
- [ ] (0.1) waiting times
- [x] (0.1) lead times
- [x] (0.1) workload
- [x] (0.1) workflow
- [x] (0.2) order flow (network graph)
- [x] (0.2) product flow (network graph)
- [ ] (0.2) resource constraints

### Convenience

- [ ] (0.1) templates for simulation
- [ ] (0.1) saving and loading simulation runs

-------------------------
(0.1) to implement until the first release
