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
    value::Any
    error::Bool
    channel::Channel{Any}
    task::Task

    function Event(time::Float64, value::Any=time, error::Bool=false)
        new(time, value, error, Channel{Any}(0), current_task())
    end

    function Event(time::Int, value::Any=time, error::Bool=false)
        new(float(time), value, error, Channel{Any}(0), current_task())
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
    clients::Dict{Task, Array{Int64,1}}
    index::Int64

    function DES(starttime::Float64=0.0)
        new(starttime, PriorityQueue{Int64, Float64}(), Dict{Float64, Int64}(),
            Dict{Int64, Array{Event,1}}(), Channel{Event}(Inf),
            Dict{Task, Array{Int64,1}}(), 0)
    end
end

"""
    now(sim::DES)

return **central** sim.time. Individual tasks may hold their own time,
differing from it. They can or should synchronize with it from time to time.
"""
now(sim::DES) = sim.time


"""
    delayuntil(sim::DES, time::Number, value::Any=time, error::Bool=false)

create a new simulation event, send a request and wait for the scheduler

# Arguments
- `sim::DES`: event source for simulation events
- `time::Float64`: sim.time when we want to be rewoken
- `value::Int=0`: value, which should be returned at the event
- `error::Bool=false`: should an exception be raised
"""
function delayuntil(sim::DES, time::Number, value::Any=time, error::Bool=false)
    ev = Event(time, value, error)
    put!(sim.request, ev)
    take!(ev.channel)
end


"""
    delay(sim::DES, time::Float64; error::Bool=false)

create a new simulation event, send a request and yield to the scheduler

# Arguments
- `sim::DES`: event source for simulation events
- `time::Float64`: time after sim.time, the condition is fulfilled
- `error::Bool=false`: should an exception be raised
"""
delay(sim::DES, time::Number, error::Bool=false) = delayuntil(sim, sim.time + time, sim.time + time, error)

"""
    register(sim::DES, client::Task)

register a task for a simulation. This is needed to proper startup and finish
and must be called before calling simulate.
"""
function register(sim::DES, client::Task)
    sim.clients[client] = Int64[]
end

function register(sim::DES, clients::Array{Task,1})
    for c in clients
        register(sim, c)
    end
end

"""
    removetask(sim::DES, task::Task)

remove all scheduling entries for a task from sim
"""
function removetask(sim::DES, task::Task)
    for i ∈ sim.clients[task]
        if length(unique(sim.events[i])) ≤ 1 # only this task is scheduled for the event
            t = sim.sched[i]
            sim.sched[i] = 0
            DataStructures.dequeue!(sim.sched)
            delete!(sim.times, t)
            delete!(sim.events, i)
        else
            filter!(j->(j!=i), sim.events[i])
        end
    end
    empty!(sim.clients[task])
end

"""
    interrupttask(sim::DES, task::Task, exc::Exception=SimException(FAILURE), value::Any=sim.time)

interrupt a task with exception exc. Before remove all scheduling entries
for this task from sim.

# Arguments
- `sim::DES`: event source for simulation events
- `task::Task`: task
- `exc::Exception=SimException(FAILURE)`: exception to throw
"""
function interrupttask(sim::DES, task::Task, exc::Exception=SimException(FAILURE))
    removetask(sim, task)
    schedule(task, exc, error=true)
end


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
            sim.times[ev.time] = sim.index
            sim.sched[sim.index] = ev.time
            sim.events[sim.index] = [ ev ]
        end
        push!(sim.clients[ev.task], sim.index)
    end

    # check
    function runnable()
        !isempty(sim.clients) && !all(t->(t.state == :done), sim.clients)
    end

    sleep(0.001) # wait 1 ms
    stime = sim.time + time
    t = 0
    while t < stime # && runnable() # --> not working at the moment
        if isready(sim.request) || !isempty(sim.sched)
            while isready(sim.request) # if requests are available take them and proceed
                ev = take!(sim.request)
                schedule_event(ev)
            end
        else
            ev = take!(sim.request) # wait for requests
            schedule_event(ev)
        end
        if isempty(sim.sched)
            break
        else
            (i, t) = DataStructures.peek(sim.sched)
#            println("next event $i at $t")
            if t >= stime
                println("next event time:$t ≥ stime")
                break
            end

            sim.time = t
            for ev ∈ sim.events[i]
                if ev.error
                    interrupttask(sim, ev.task, SimException(FAILURE))
                else
                    filter!(x->x!=i, sim.clients[ev.task])
                    DataStructures.dequeue!(sim.sched)
                    delete!(sim.times, t)
                    delete!(sim.events, i)
                    put!(ev.channel, ev.value)
                end
            end
        end # if isempty
    end # if while
    sim.time = stime
end
