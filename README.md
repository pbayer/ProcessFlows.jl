# PFlow.jl

### Simulation of Production Systems and Projects

`PFlow.jl` is a `Julia` library, which allows to simulate the main physical characteristics of production systems and projects:

- processing of orders
- in given sequences,
- taking different and varying processing times
- through different workunits,
- which are prone to failures.

Often several resources are available for doing a job, sometimes orders have to compete for certain resources. Sometimes components or other prerequisites are required in order to process orders. Sometimes there are physical or policy limits to buffer sizes. Multitasking may be required or restricted … There are **multiple constraints and dependencies** which have to be simulated in order to get system level characteristics like

- utilization,
- throughput,
- cost.

`PFlow` provides a model kit for basic entities of production systems or projects like

- work units,
- orders,
- materials

Those entities can be

- combined and used in an simulation application
- or collected and parametrized in lists (`csv`-files) and fed into `PFlow` in order to keep programming needs to a minimum.

`Julia` (with `SimJulia`) is maturing and can provide for a really fast simulation library, capable to model and simulate even large systems as in production, in automotive plants or in multiprojects.

### Status of Project (as of 08/2017)

PFlow is in early development. Things are coming together quite quickly and a working prototype and some interesting results should be available in this repository by September 2017.
