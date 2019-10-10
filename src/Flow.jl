#
# this implements a Source and a Sink, needed for a flow system
#

"""
    Source(name::AbstractString, gen::Expr;
           delay::Union{Number, Expr}=0, capacity::Int64=10)

Create a new source for producing jobs for a flow system.

# Arguments
- `name::AbstractString`
- `gen::Expr`: expression provided by user, that returns a job when called
- `delay::Union{Number, Expr}`: a number or expression for delay between calls
- `capacity::Int64`: capacity of source buffer
"""
mutable struct Source <: StateMachine
    name::AbstractString
    sim::Union{Number,Clock,Factory}
    state::State
    queue::Array
    capacity::Int64
    gen::Expr
    delay::Union{Number, Expr}

    function Source(name::AbstractString, gen::Expr;
                    delay::Union{Number, Expr}=0, capacity::Int64=10)
        new(name, 0, Undefined(), [], capacity, gen, delay)
    end
end

mutable struct Sink <: StateMachine
    name::AbstractString
    sim::Union{Number,Clock,Factory}
    state::State
    store::Array

    "Create a new Sink for storing finished jobs."
    Sink(name) = new(name, Clock(), Undefined(), [])
end

"A full source should create or load a new job."
function step!(s::Source, ::Full, ::Load)
    if s.delay != 0         # schedule next load event
        event!(s.sim, :(step!($s, $(s.state), Load())),
                now(s.sim) + Core.eval(Main, s.delay))
    end
end

"A busy source should create or load a new job."
function step!(s::Source, ::Busy, σ::Load)
    push!(s.queue, Core.eval(Main, s.gen))
    call!(s.sim, s, σ)
    if length(s.queue) < s.capacity
        if s.delay == 0     # call next load until s.queue is full
            step!(s, Load())
        else
            event!(s.sim, :(step!($s, $(s.state), Load())),
                    now(s.sim) + Core.eval(Main, s.delay))

        end
    else
        s.state = Full()
        step!(s, Load())
    end
end

"A client gets a job from from a source."
function step!(s::Source, ::State, ::Get)
    @assert !isempty(s.queue) "$s.name) is empty"
    job = popfirst!(s.queue)
    if s.state == Full()
        s.state = Busy()
        if s.delay == 0     # call next load event
            step!(s, Load())
        end
    end
    return job
end

"A source gets started."
function step!(s::Source, ::Idle, ::Start)
    s.state = Busy()
    step!(s, Load())
end

# Interface functions

"Start a source. This has to be called to get the flow started."
start!(s::Source) = step!(s, Start())

isempty(s::Source) = isempty(s.queue)

"Return the first item of a source, Nothing if it is empty"
get(s::Source) = isempty(s.queue) ? Nothing : s.queue[1]

"Return and remove an item from a source."
get!(s::Source) = step!(s, Get())

"Put a job into a Sink."
enter!(s::Sink, job) = push!(s.store, job)
