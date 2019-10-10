#
# implement a scheduler
#

mutable struct Scheduler <: StateMachine
    name::AbstractString
    sim::Union{Number,Clock,Factory}
    state::State

    Scheduler(name) = new(name, 0, Undefined())
end

function step!(A::Scheduler, ::Idle, σ::Call)
    if typeof(σ.sev) ∈ (Load, Unload)
        job = get(σ.from)
        if job != Nothing
            op = nextOp!(job)
            job.index += 1
            if op != Nothing
                set!(op.state, scheduled)
                transport!(caller, getserv(s.sim, op.type))
            else
                transport!(job, caller, s.sim.sink)
            end
        else
            println(stderr, "$(A.name): got called but no job from $(σ.from.name)")
        end
    else
        println(stderr, "$(A.name): got called with unknown source event ",
                "$(σ.from.name), $(typeof(σ.sev))")
    end
end
