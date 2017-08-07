# PFlow.jl

### Simulation of Production Systems and Projects

The goal of this repository is to provide software (in `Julia`), which simulates the main characteristics of production systems and projects:

- processing of orders
- through different resources
- in a predetermined sequence
- which take different and varying processing times and
- are prone to failures.

Sometimes several resources are available for doing a job, sometimes orders have to compete for resources. Sometimes components or other prerequisites are required in order to process orders. There are multiple dependencies which have to be simulated in order to get characteristics like

- utilization,
- throughput,
- cost

of production systems or project organizations.

All this has to be achieved by simple parametrization and by means of lists of

- orders,
- machines/resources,
- materials

which are the basis of production systems and orders or even projects usually handled by systems like SAP, ERP or project management software.

`Julia` (with `SimJulia`) is maturing and can provide for a really fast simulation library, capable to simulate also medium to large systems as in production, in automotive plants or in multiprojects.

### Status of Project (as of 08/2017)

PFlow is in early development. Things are coming together quite quickly and a working prototype and some interesting results should be available in this repository by September 2017.
