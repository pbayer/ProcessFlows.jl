#
# functions for defining physical structures of flow systems
#

"""
    Factory(name::AbstractString;
            source::Union{StateMachine, Number}=0,
            sink::Union{StateMachine, Number}=0,
            sched::Union{StateMachine, Number}=0,
            transp::Union{StateMachine, Number}=0)

Define a factory. A factory consists of a source, some servers (or clusters)
and a sink. Source, sink can be defined subsequently. Servers must be put into
the factory subsequently with `add!`.

# Arguments
- `name::AbstractString`: name
- `source::Union{StateMachine, Number}`: a source, which generates jobs
- `sink::Union{StateMachine, Number}`: a sink
- `sched::Union{StateMachine, Number}`: a scheduler
- `transp::Union{StateMachine, Number}`: a transport system
"""
mutable struct Factory <: StateMachine
    name::AbstractString
    "simulation variable"
    sim::Clock
    state::State
    "source, putting jobs into the Factory"
    source::Union{StateMachine, Number}
    "dictionary of servers or clusters"
    server::Dict{Any,StateMachine}
    "sink for finished jobs"
    sink::Union{StateMachine, Number}
    "scheduler for handling jobs"
    sched::Union{StateMachine, Number}
    "transport system"
    transp::Union{StateMachine, Number}

    Factory(name::AbstractString;
            source::Union{StateMachine, Number}=0,
            sink::Union{StateMachine, Number}=0,
            sched::Union{StateMachine, Number}=0,
            transp::Union{StateMachine, Number}=0) =
        new(name, Clock(), Undefined(), source, Dict{Any,StateMachine}(),
            sink, sched, transp)
end

"initialize all elements of the factory"
function init!(fab::Factory, sim::Clock)
    fab.sim = sim
    @assert isa(fab.source, Source) "$(fab.name) has no source!"
    @assert !isempty(fab.server) "$(fab.name) has no servers"
    @assert isa(fab.sink, Sink) "$(fab.name) has no sink!"
    @assert isa(fab.sched, Scheduler) "$(fab.name) has no scheduler!"
    init!(fab.source, fab)
    for s ∈ values(fab.server)
        init!(s, fab)
    end
    init!(fab.sink, fab)
    init!(fab.sched, fab)
    fab.state = Idle()
end

"""
    addserv!(fab::Factory, serv, key="")

add a server to a factory

# Arguments
- `fab::Factory`
- `serv::StateMachine`: server or cluster
- `key`: key under which the server or cluster will be found, if none is given,
  `serv.name` is used.
"""
function addserv!(fab::Factory, serv::StateMachine, key="")
    serv.sim=fab
    if isempty(key)
        fab.server[serv.name]=serv
    else
        fab.server[key]=serv
    end
end

"return a server from a factory or Nothing if not found"
getserv(fab::Factory, key) = get(fab.server, key, Nothing)

"return the simulation time of a factory"
now(fab::Factory) = fab.sim.time

function step!(fab::Factory, ::Idle, ::Start)
    fab.state = Ready()
    start!(fab.source)
end

function step!(fab::Factory, ::Ready, σ::Run)
    fab.state = Busy()
    run!(fab.sim, duration)
end

"Call event for a factory. Feed forward to scheduler."
step!(fab::Factory, ::Busy, σ::Call) = step!(fab.sched, fab.sched.state, σ)
