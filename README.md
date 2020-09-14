# ProcessFlows.jl

Process flows in service, manufacturing, logistics …

[![Build Status](https://travis-ci.com/pbayer/ProcessFlows.jl.svg?branch=master)](https://travis-ci.com/pbayer/ProcessFlows.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/pbayer/ProcessFlows.jl?svg=true)](https://ci.appveyor.com/project/pbayer/ProcessFlows-jl)
[![Coverage](https://codecov.io/gh/pbayer/ProcessFlows.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/pbayer/ProcessFlows.jl)
[![Coverage](https://coveralls.io/repos/github/pbayer/ProcessFlows.jl/badge.svg?branch=master)](https://coveralls.io/github/pbayer/ProcessFlows.jl?branch=master)

A rewrite of former `PFlow.jl` based on `DiscreteEvents.jl`. Please stay tuned.

## Process Flows

Processes in service, manufacturing, development, logistics, hospitals ... differ from common stochastic processes as modeled in queueing theory:

Each item (good, customer, job, patient ...) flowing through such systems has its own characteristics or constraints in terms of

- *routing:* where does it go, in which sequence,
- *composition:* what other items does its processing need,
- *service times:* how long does a process step take,
- *due times:* when has the work to be completed,
- *cost:* how much does it cost,
- *priority:* …

Often then there are typical characteristics for different types of SKUs, orders, products ...

Then there are system constraints like

- *capacity*
- *variation*
- *capability*
- *reliability*

We are interested in throughput, performance, buffer sizes, lead time, cost ...
