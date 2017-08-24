# PFlow – ToDo

Since `PFlow` is in early development, there remains a lot to do in order to make
it fit for general use in simulation of production and project environments:

### core processing: `activities.jl`

- [ ] implement **transport**
- [ ] implement **multitasking** (a central feature of projects)
- [ ] implement **batch processing**
- [ ] implement **store**

### scheduling: `schedule.jl`:

- [ ] create transport jobs only if the input queue of the target is not full
- [ ] implement priority scheduling
- [ ] implement scheduling strategies (CONWIP, DBR and the like)

### Documentation

### Stats and visualization: `simviz.jl`

- [ ] lead times
- [ ] workload
- [ ] workflow (network graph)
- [ ] resource constraints

### Convenience

- [ ] `simlog.jl`: logging variable as `view`
- [ ] saving and loading simulation runs
