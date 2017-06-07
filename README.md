# FlowOp

### Simulation of Discrete Production Systems

The goal of this repository is to provide software (in Julia/Python) which is able to simulate the main characteristics of production systems:

- processing of orders
- through different ressources 
- in a predetermined sequence
- which take different and varying processing times and
- are prone to failures.

Sometimes several resources are available to process orders, sometimes orders have to compete for resources.

Sometimes components or other prerequistes are required in order to process orders.

So there are multiple dependencies which have to be simulated and be regarded in order to get the characteristics like

- utilization,
- throughput,
- cost

of production systems.

All this has to be achieved by simple parametrization and by means of lists of

- orders,
- machines,
- materials

which are the basis of production and projects similar to systems like SAP, ERP or project management software.

 