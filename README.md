# pflow

### Simulation of Production Systems and Projects

The goal of this repository is to provide software (in Julia/Python) which is able to simulate the main characteristics of production systems and projects:

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

of production systems or project organizations.

All this has to be achieved by simple parametrization and by means of lists of

- orders,
- machines/ressources,
- materials

which are the basis of production systems and orders or even projects usually handled by systems like SAP, ERP or project management software.

### Status of Project (as of 07/2017)

I did some simulations over the years for specific cases with different software systems like Simula, Modula-2, Vensim, Plantsim. 

I now evaluated my new generic approach with a ```Python``` programm. So I know this works and do have a preliminary proof of concept. Since the approach shall be able to simulate also medium to large systems it has to be able to run really fast. So – since [```Julia```](https://julialang.org) is maturing – I will (re-)implement it in Julia and a working prototype and some interesting results should be available in this repository by September 2017.
 