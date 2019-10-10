# DiscreteEvent.jl Manual

## Examples

## Introduction

Discrete Event Systems consist of **flows** from **unit** Aᵢ to Aⱼ. Units Aᵢ have finite sets of **states** Qᵢ and **transitions** Δᵢ, responding to **events** Σᵢ, taking some **time** to process them in order to assume final states Fᵢ which generate output. This becomes input σ ∈ Σⱼ to some other unit Aⱼ.

- a **clock** allows to schedule and dispatch events at specific times.
- **state machines**, e.g. A=(Q,Σ,Δ,q₀,F) describe  states and transitions on events.
- **flows** describe how items move and get transformed through systems (of state machines).

`DiscreteEvent.jl` defines some typical state machines used in systems like industry, service, hospitals … and can move items through them in order to model and simulate real world flows of jobs, orders, clients, patients … Uncertainties can be given to arrival, processing, failure, repair times … in order to study their impact on those systems.

## Types, Methods and Functions

### Simulation as Arrow of Time

In order to simulate discrete event systems we introduce a fictitious **clock** (`Clock()`) containing the simulation time, to which simulation **events** (`SimEvent`) can refer. The simulation time is implemented as a ℝ⁺ number line (`Float64`) and can mean some unit of time (day, hour, minute …), depending on the context. We assume that there are no really simultaneous events. So events are sorted and dispatched in timely sequence at least computing precision apart.

We schedule arbitrary Julia expressions as events with  <nobr>`event!(sim::Clock, ex::Expr, at::Float64)`</nobr> in order to be called later as we `step!` or `run!` through the simulation. If those expressions create further events, whole chains of events are generated, put in sequence and executed accordingly during simulation.

- `Clock(time::Number=0)`: creates a new simulation clock
- `event!(sim::Clock, expr::Expr, at::Float64)`: schedule an expression for execution at a given simulation time.
- `run!(sim::Clock, duration::Number)`: Run a simulation for a given duration. Call all scheduled events in that timeframe.
- `step!(sim::Clock)`: Take one simulation step, execute the next event.
- `now(sim::Clock)`: Return the current simulation time.

### Modeling Entities as State machines

Entities in discrete event systems respond to events and change their states accordingly. Therefore they can be modeled as automata or state machines.

The state machines implemented so far in `DiscreteEvent.jl` are all NFA's (Nondeterministic Finite Automata)

<p align=center>A = (Q,Σ,δ,q₀,F), where </p>

1. Q is a finite set of states (`State`).
2. Σ is a finite set of input symbols (`DEvent`).
3. δ is the transition function (`step!`).
4. q₀ ∈ Q is the start state (e.g. `Undefined`).
5. F ⊂ Q is the set of final states (e.g. `{Finished, Failed}`).

#### States (`State`)

Not all defined states Q = {q₁ … qᵣ} have to be implemented by a certain state machine Aᵢ.

- `Undefined`: A was just created.
- `Idle`: A is waiting for input.
- `Setup`: A is being setup.
- `Busy`: A is processing some input.
- `Blocked`: A has finished but cannot `Unload` its work.
- `Halted`: A is halted by user.
- `Empty`: A is empty.
- `Full`: A is full.
- `Failed`: A got a failure.
- `Waiting`: A is waiting.
- `InProcess`: A is being processed.

States have to be instantiated with `()` like `A.state = Idle().`

#### Discrete Events (`DEvent`)

Not all defined input symbols Σ (`DEvent`) must occur to each state machine Aᵢ:

- `Init(sim)`: initialization of A, changes A.state to `Idle`.
- `Enter(job,duration)`: a job enters A.
- `Load`: a job gets loaded into A.
- `Switch`: A must switch jobs.
- `Finish`: a job gets finished.
- `Unload`: a job gets unloaded to A's output buffer.
- `Leave`: a job leaves A prematurely.
- `Get`: A gets a new job into its input buffer.
- `Fail`: A gets a failure.
- `Repair`: A gets repaired.
- `Call`: A gets called.
- `Step`: user command, A should take its next step.
- `Run(duration)`: user command, A should run for a given duration.
- `Start`: user command.
- `Stop`: user command.
- `Resume`: user command.

They have to be instantiated with `()` like in `step!(A, Load())`. Sometimes they may carry information or jobs.

#### The Transition Function (`step!`)

Each type of state machine Aᵢ is characterized by a set of transition functions δ(qᵦ,σᵧ) changing A's state to some final state qᵩ ∈ F. Those are implemented as δ(A,qₓ,σᵧ) <nobr>(`step!(A::StateMachine, ::State, ::DEvent)`)</nobr> functions. Julia's multiple dispatch feature allows different instances (methods) of the `step!` function for different combinations of A, q and σ.

There is a shortcut call δ(A,σᵧ) <nobr>(`step!(A::StateMachine, σ::DEvent)`)</nobr>, since in `DiscreteEvent.jl` each state machine `A` carries its state as `A.state`. It is usually safer to call the shortcut version, but implementation has to use the long version in order to allow for multiple dispatch.

#### Implemented state Machines

There are different state machines `StateMachine` in `DiscreteEvent.jl`, which allow to model real world discrete flow systems and to perform simulations:

- `Clock`: the simulation engine
- `FIFOBuffer`: a First In First Out buffer
- `Source`: an entity for bringing jobs into a system
- `Server`: for processing jobs
- `Sink`: for storing finished jobs
- `Factory`: for describing a system of state machines
- `Scheduler`: for scheduling of jobs within factories und clusters
- `Transport`: for transporting jobs (not yet implemented)
- `Logger`: for logging transition data (not yet implemented)
- `Cluster`: for describing subsystems of state machines (not yet implemented)
- ``:


### Modeling Flows Through Systems

## Developer Documentation

### The Unreasonable Effectiveness of Multiple Dispatch

Two talks on JuliaCon 2019 inspired much the implementation of `DiscreteEvent.jl`:

1. Stefan Karpinski's The Unreasonable Effectiveness of Multiple Dispatch
2. Joshua Ballanco's Julia's Killer App(s): Implementing State Machines Simply using Multiple Dispatch

My previous experiences with modeling and simulation of discrete event systems showed models and code getting exponentially more complicated if I tried to generalize things, introduce new capabilities and scale up to larger systems. With Julia's multiple dispatch those tasks can be handled more easily. It forced me to think  harder about implementation. In summary the code became much simpler and more easily readable and testable while being able to handle more complexity.

As a final thought about this subject I assume that multiple dispatch in a programming language captures a central quality of nature. Namely we see everywhere similar or related systems, having alike states and transitions, interacting through common events. Multiple dispatch allows to express the similarity and the specificity of those systems and their interactions.  

### Developing Applications

1. If you call `event!(sim, expr::Expr, at)` inside a function or module, you have to consider that `expr` is later evaluated in the `Main` environment. So you have to interpolate your local functions or variables in `expr` by a prefix `$` like in this example:

 In <nobr>`event!(sim, :(step!($s, Finish())), time)`</nobr> a local variable `s` gets interpolated as you call `event!`.
