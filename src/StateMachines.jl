#
# Define types for state machines
#

abstract type StateMachine end
abstract type State end
abstract type DEvent end
abstract type Work end

struct Undefined <: State end
struct Idle <: State end
struct Setup <: State end
struct Busy <: State end
struct Blocked <: State end
struct Halted <: State end
struct Empty <: State end
struct Ready <: State end
struct Full <: State end
struct Failed <: State end
struct Waiting <: State end
struct InProcess <: State end

"event `Init(info)` with some initialization info"
struct Init <: DEvent
    info::Any
end
"event `Enter(job)` with some job (jobs have a field job.duration)"
struct Enter <: DEvent
    job::Any
end
struct Load <: DEvent end
"event `Switch(to)` for task switching"
struct Switch <: DEvent
    to
end
"event for finishing Setup or Busy"
struct Finish <: DEvent end
"event for unloading a server"
struct Unload <: DEvent end
"event `Leave(job)` for prematurely leaving a buffer"
struct Leave <: DEvent
    job::Any
end
struct Get <: DEvent end
"event `Fail(ttr)` with ttr: time to repair"
struct Fail <: DEvent
    ttr::Float64
end
struct Repair <: DEvent end
"event `Call(from, info)` to a state machine with sender and some info."
struct Call <: DEvent
    from
    info
end
"event `Log(A::StateMachine,σ::DEvent,info)` for logging "
struct Log <: DEvent
    A::StateMachine
    σ::DEvent
    info::Any
end
"event for user interaction"
struct Step <: DEvent end
"event `Run(duration)` for user interaction"
struct Run <: DEvent
    duration::Float64
end
"event for user interaction"
struct Start <: DEvent end
"event for user interaction"
struct Stop <: DEvent end
"event for user interaction"
struct Resume <: DEvent end

"""
    step!(A::StateMachine, q::State, σ::DEvent)

transition function δ causing a state machine A in state q₁ at event σ
to take on a new state q₂.

For all specified transitions Δ: Q × Σ → P(Q) of A a `step!`-function has to
be implemented. For unspecified transitions a fallback step function is
called and a warning is generated.

# Arguments
- `A::StateMachine`: a state machine
- `q::State`: any state ∈ Q
- `σ::DEvent`: any discrete event ∈ Σ
"""
function step!(A::StateMachine, q::State, σ::DEvent)
    at = ""
    try
        if !isa(A.sim, Number)
            at = "at $(now(A.sim))"
        end
    catch
    end
    name = hasfield(typeof(A), :name) ? A.name : ""
    println(stderr, "Warning: undefined transition $at for ",
            "$name: step!(::$(typeof(A)), ::$(typeof(q)), ::$(typeof(σ)))")
end

"""
    step!(A::StateMachine, σ::DEvent)

Shortcut step! function for state machines with an internal state `A.state`.

This is generally safer to call than the long version and it calls also the
event logger.
"""
function step!(A::StateMachine, σ::DEvent)
    info = step!(A, A.state, σ)
    if hasfield(typeof(A), :sim) && hasfield(typeof(A.sim), :logger)
        step!(A.sim.logger, A.sim.logger.state, Log(A, σ, info))
    elseif  hasfield(typeof(A),:fab) &&
            hasfield(typeof(A.fab),:sim) && hasfield(typeof(A.fab.sim), :logger)
        step!(A.fab,sim.logger, A.fab.sim.logger.state, Log(A, σ, info))
    end
    return info
end

"generic initialization of a state machine"
function step!(A::StateMachine, ::Undefined, σ::Init)
    A.sim = σ.info
    A.state = Idle()
end

"generic shortcut initialization of a state machine"
init!(A::StateMachine, sim::StateMachine) = step!(A, A.state, Init(sim))

"generic shortcut for starting a state machine"
start!(A::StateMachine) = step!(A, A.state, Start())

"generic shortcut for run command"
run!(A::StateMachine) = step!(A, A.state, Run())

"generic entering an item into a state machine. Return a sequence number."
enter!(A::StateMachine, item) = step!(A, Enter(item))

"call `A` from `B` with a sender event `sev`."
call!(A::StateMachine, B::StateMachine, sev::DEvent) = step!(A, Call(B,sev))

get!(A::StateMachine) = step!(A, Get())
