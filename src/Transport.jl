#
# This has yet to be implemented as a state machine with routing ...
#

mutable struct Transport <: StateMachine
    name::AbstractString
    sim::Union{Number,Clock,Factory}
    state::State
    routing

    Transport(name::AbstractString) = new(name, 0, Undefined(), 0)
end

function transport!(from::Server, to::Server)
    # spend some time to fetch - yet to be implemented
    job = get!(from)
    # spend some time to deliver - yet to be implemented
    enter!(to, job, duration(job))
end
