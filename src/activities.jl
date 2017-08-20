# --------------------------------------------
# this file is part of PFlow.jl
# it implements the various activities
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    currentjob(wu::Workunit)

give the current job for a workunit
"""
function currentjob(wu::Workunit)
    p = front(wu.wip)
    p.jobs[p.pjob]
end

"""
    opTime(wu::Workunit, job::Job)

calculate the operation time of a job at a station
"""
function opTime(alpha::Int64, plan::Real)
    μ = plan / (2 * alpha)
    plan/2 + rand(Erlang(alpha, μ))
end

"""
    repTime(wu:Workunit, alpha=1)

calculate a repairtime based on wu.mttr
"""
function repTime(wu::Workunit, alpha=1)
      μ = wu.mttr / (2 * alpha)
      wu.mttr/2 + rand(Erlang(alpha, μ))
end

"""
    failure(sim::Simulation, proc::Process, mttr::Real)

interrupt a process with a FAILURE after rand(Exponential(mttr))
"""
function failure(sim::Simulation, proc::Process, mtbf::Real)
    while true
        Δt = rand(Exponential(mtbf))
        yield(Timeout(sim, Δt))
        interrupt(proc, FAILURE)
    end
end

"""
    do_work(sim::Simulation, wu::Workunit)

auxiliary function for doing the work
"""
function do_work(sim::Simulation, wu::Workunit)
    job = currentjob(wu)
    wu.t0 = now(sim)
    if iszero(job.op_time)
        job.op_time = opTime(wu.alpha, job.plan_time)
    end
    Δt = job.op_time*(1 - job.completion)
    yield(Timeout(sim, Δt))
#    job.status = DONE -> finishjob
end

"""
    do_multitask(sim::Simulation, wu::Workunit)

take the current job for the product at the front of the wu.wip queue,
work on it for wu.timeslice, move it to the back and repeat doing
"""
function do_multitask(sim::Simulation, wu::Workunit, job::Job)
    job = currentjob(wu)
    ## THIS HAS YET TO BE IMPLEMENTED
end

"""
    work(sim::Simulation, wu::Workunit, workfunc::Function, log::Simlog)

let a Workunit work on its jobs, this has to be started as a process
on a Workunit variable.

# Arguments
- `sim::Simulation`: SimJulia Simulation variable
- `wu::Workunit`: characteristics of Workunit
- `log::Simlog`: which Log to log information to
"""
function work(sim::Simulation, wu::Workunit, workfunc::Function, log::Simlog)

    function setstatus(newstatus)
        lognow(sim, log)
        status.value = newstatus
        lognow(sim, log)
    end

    getstatus(s) = status.value == s

    function getnewjob(wu::Workunit)
        p = dequeue!(wu.input)
        enqueue!(wu.wip, p)
        p.job[p.pjob].status = PROGRESS
    end

    function finishjob(wu::Workunit)
        p = dequeue!(wu.wip)
        enqueue!(wu.output, p)
        p.job[p.pjob].status = DONE
        setstatus(IDLE)
    end

    status = Logvar(wu.name, IDLE)
    logvar2log(log, status)
    oldstatus = IDLE
    while true
        try
            if getstatus(IDLE)           # get a new job
                getnewjob(wu)
                setstatus(WORKING)
            elseif getstatus(BLOCKED)      # output buffer is full
                finishjob(wu)
            elseif getstatus(WORKING)
                workfunc(sim, wu)
                if !isfull(wu.output)
                    finishjob(wu)
                else
                    setstatus(BLOCKED)
                end
            elseif getstatus(FAILURE)      # request repair
                yield(Timeout(sim, repTime(wu)))
                setstatus(oldstatus)
            else
                throw(ArgumentError(@sprintf("%s: %d status.value not defined", wu.name, status.value)))
            end
        catch exc
            if isa(exc, SimJulia.InterruptException) && exc.cause == FAILURE
                if !getstatus(FAILURE)
                    oldstatus = status.value
                end
                if getstatus(WORKING)
                    job = currentjob(wu)
                    Δt = now(sim) - wu.t0   # time worked into that job
                    job.completion += Δt/job.op_time
                end
                setstatus(FAILURE)
            else
                rethrow(exc) # propagate exception
            end # if isa
        end # try, catch
    end # while
end



"""
    workunit(sim::Simulation, log::Simlog, kind::Int64,
             name::AbstractString, description::AbstractString="",
             input::Int=1, wip::Int=1, output::Int=1,
             mtbf::Number=0, mttr::Number=0, alpha::Int=100,
             timeslice::Number=0)

create a new workunit, start a process on it and return it

# Arguments
- `sim::Simulation`: SimJulia `Simulation` variable
- `log::Simlog`: which `Simlog` to log information to
- `kind::Int64`: which kind of Workunit to create
- `name::AbstractString`: name of Machine (used for scheduling and logging)
- `description::AbstractString`: description, for informational purposes
- `input::Int=1`: how big is the input buffer
- `wip::Int=1`: how big is the internal wip buffer
- `output::Int=1`: how big is the output buffer
- `mtbf::Number=0:` mean time between failures (0: no failures)
- `mttr::Number=0:` mean time to repair
- `alpha::Int=100:` Erlang shape factor for calculating the variation of
                    work times (1: big, 100: small variation)
- `timeslice::Number=0:` length of timeslice for multitasking, 0: no multitasking
"""
function workunit(sim::Simulation, log::Simlog, kind::Int64,
                 name::AbstractString, description::AbstractString="",
                 input::Int=1, wip::Int=1, output::Int=1,
                 mtbf::Number=0, mttr::Number=0, alpha::Int=100,
                 timeslice::Number=0)
    wu = Workunit(name, description, kind,
                PFQueue(name*"-IN", Resource(sim, input), Queue(Product)),
                PFQueue(name*"-JOB", Resource(sim, wip), Queue(Product)),
                PFQueue(name*"-OUT", Resource(sim, output), Queue(Product)),
                alpha, mtbf, mttr, timeslice, 0.0)
    proc = @process work(sim, wu, do_work, log)
    if mtbf > 0
        @process failure(sim, proc, mtbf)
    end
    wu
end

"""
    machine(sim::Simulation, log::Simlog,
            name::AbstractString; description::AbstractString="",
            input::Int=1, wip::Int=1, output::Int=1,
            mtbf::Number=0, mttr::Number=0, alpha::Int=100,
            timeslice::Number=0)

create a new machine, start a process on it and return it

# Arguments
see workunit
"""
function machine(sim::Simulation, log::Simlog,
                name::AbstractString; description::AbstractString="",
                input::Int=1, wip::Int=1, output::Int=1,
                mtbf::Number=0, mttr::Number=0, alpha::Int=1,
                timeslice::Number=0)
    workunit(name, description, MACHINE,
             PFQueue(name*"-IN", Resource(sim, input), Queue(Product)),
             PFQueue(name*"-JOB", Resource(sim, jobs), Queue(Product)),
             PFQueue(name*"-OUT", Resource(sim, output), Queue(Product)),
             mtbf, mttr, alpha, timeslice)
end

"""
    worker(sim::Simulation, log::Simlog,
           name::AbstractString; description::AbstractString="",
           mtbf::Number=0, mttr::Number=0,
           input::Int=1, wip::Int=1, output::Int=1, alpha::Int=1,
           timeslice::Number=0)

create a new worker, start a process on it and return it

# Arguments
see workunit
"""
function worker(sim::Simulation, log::Simlog,
                name::AbstractString; description::AbstractString="",
                input::Int=1, wip::Int=1, output::Int=1,
                mtbf::Number=0, mttr::Number=0, alpha::Int=1,
                timeslice::Number=0)
    workunit(name, description, WORKER,
             PFQueue(name*"-IN", Resource(sim, input), Queue(Product)),
             PFQueue(name*"-JOB", Resource(sim, jobs), Queue(Product)),
             PFQueue(name*"-OUT", Resource(sim, output), Queue(Product)),
             mtbf, mttr, alpha, timeslice)
end

"""
    transport()
"""
function transport()
end

"""
    inspector()
"""
function inspector()
end

"""
    store()
"""
function store()
end
