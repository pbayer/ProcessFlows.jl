# --------------------------------------------
# this file is part of PFlow.jl it implements
# the discrete event simulation functions
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

mutable struct Event
    time::Float64
    value::Int
    error::Bool
    channel::Channel
    task::Task
    function Event(time::Float64, value::Int=0, error::Bool=false)
        new(time, value, error, Channel(0), current_task())
    end
end

"""
    DES(starttime::Float64=0.0)

start an event source, which can be used to schedule tasks at simulated times
"""
mutable struct DES
    time::Float64
    sched::DataStructures.PriorityQueue{Int64, Float64}
    times::Dict{Float64, Int64}
    events::Dict{Int64, Array{Event,1}}
    request::Channel{Event}
    clients::Array{Task, 1}
    index::Int64

    function DES(starttime::Float64=0.0)
        new(starttime, PriorityQueue{Int64, Float64}(), Dict{Float64, Int64}(),
            Dict{Int64, Array{Event,1}}(), Channel{Event}(Inf), Task[], 0)
    end
end

now(sim::DES) = sim.time

"""
    delay(sim::DES, time::Float64; value::Int=0, error::Bool=false)

create a new simulation event, send a request and yield to the scheduler

# Arguments
- `sim::DES`: event source for simulation events
- `time::Float64`: time after sim.time, the condition is fulfilled
- `value::Int=0`: give the created event a value - needed to trigger an exception
- `error::Bool=false`: should an exception be raised
"""
function delay(sim::DES, time::Float64; value::Int=0, error::Bool=false)
    stime = sim.time + time
    ev = Event(stime, value, error)
    put!(sim.request, ev)
    take!(ev.channel)
end

"""
    register(sim::DES, client::Task)

register a task for a simulation. This is needed to proper startup and finish
and must be called before calling simulate.
"""
register(sim::DES, client::Task) = push!(sim.clients, client)

"""
    simulate(sim::DES, time::Number)

run a simulation for sim.time + time
"""
function simulate(sim::DES, time::Number)

    function schedule_event(ev)
        if haskey(sim.times, ev.time)
            push!(sim.events[sim.times[ev.time]], ev)
        else
            sim.index += 1
            sim.times[stime] = sim.index
            sim.sched[sim.index] = ev.time
            sim.events[sim.index] = [ ev ]
        end
    end

    # check
    function runnable()
        !isempty(sim.clients) && !isempty([1 for t in sim.clients if t.state ≠ :done])
    end

    sleep(0.001) # wait 1 ms
    stime = sim.time + time
    t = 0
    while t < stime # && runnable() # --> not working at the moment
        ev = take!(sim.request)
        schedule_event(ev)
        if isempty(sim.sched)
            break
        else
            (i, t) = DataStructures.peek(sim.sched)
#            println("next event at $t")
            if t >= stime
                println("next event time:$t ≥ stime")
                break
            end

            sim.time = t
            for ev ∈ sim.events[i]
#               println("yield to $(ev.task) at $(sim.time)")
                if ev.error
                    ev.task.exception = SimException(FAILURE)
                    # remove all future calls from schedule
                    yieldto(ev.task, ev.value)
                else
                    put!(ev.channel, ev.value)
                end
            end
            DataStructures.dequeue!(sim.sched)
            delete!(sim.times, t)
            delete!(sim.events, i)
        end # if isempty
    end # if while
    sim.time = stime
end
