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
currentjob(wu::Workunit) = front(wu.jobs)

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
    job.status = DONE
end

"""
    do_multitask(sim::Simulation, wu::Workunit)

take the job from the front of the wu.jobs queue, work on it for wu.timeslice,
move it to the back and repeat doing
"""
function do_multitask(sim::Simulation, wu::Workunit, job::Job)
    job = currentjob(wu)

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
        job = dequeue!(wu.input)
        enqueue!(wu.jobs, job)
        job.status = PROGRESS
    end

    function finishjob(wu::Workunit)
        job = dequeue!(wu.jobs)
        enqueue!(wu.output, job)
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
    machine(sim::Simulation, log::Simlog,
            name::AbstractString; description::AbstractString="",
            mtbf::Number=0, mttr::Number=0,
            input::Int=1, jobs::Int=1, output::Int=1, alpha::Int=100)

create a new machine, start a process on it and return it

# Arguments
- `sim::Simulation`: SimJulia `Simulation` variable
- `log::Simlog`: which `Simlog` to log information to
- `name::AbstractString`: name of Machine (used for scheduling and logging)
- `description::AbstractString`: description, for informational purposes
- `input::Int=1`: how big is the input buffer
- `jobs::Int=1`: how big is the internal buffer
- `output::Int=1`: how big is the output buffer
- `mtbf::Number=0:` mean time between failures (0: no failures)
- `mttr::Number=0:` mean time to repair
- `alpha::Int=100:` Erlang shape factor for calculating the variation of
                    work times (1: big, 100: small variation)
"""
function machine(sim::Simulation, log::Simlog,
                 name::AbstractString; description::AbstractString="",
                 input::Int=1, jobs::Int=1, output::Int=1,
                 mtbf::Number=0, mttr::Number=0, alpha::Int=100)
    wu = Workunit(name, description, MACHINE,
                PFQueue(name*"-IN", Resource(sim, input), Queue(Job)),
                PFQueue(name*"-JOB", Resource(sim, jobs), Queue(Job)),
                PFQueue(name*"-OUT", Resource(sim, output), Queue(Job)),
                alpha, mtbf, mttr, 0, 0.0)
    proc = @process work(sim, wu, do_work, log)
    if mtbf > 0
        @process failure(sim, proc, mtbf)
    end
    wu
end

"""
    worker(sim::Simulation, log::Simlog,
           name::AbstractString; description::AbstractString="",
           mtbf::Number=0, mttr::Number=0,
           input::Int=1, jobs::Int=1, output::Int=1, alpha::Int=100)

create a new worker, start a process on it and return it

# Arguments
- `sim::Simulation`: SimJulia `Simulation` variable
- `log::Simlog`: which `Simlog` to log information to
- `name::AbstractString`: name of Machine (used for scheduling and logging)
- `description::AbstractString`: description, for informational purposes
- `input::Int=1`: how big is the input buffer
- `jobs::Int=1`: how big is the internal buffer
- `output::Int=1`: how big is the output buffer
- `mtbf::Number=0:` mean time between failures (0: no failures)
- `mttr::Number=0:` mean time to repair
- `alpha::Int=1:` Erlang shape factor for calculating the variation of
                work times (1: big, 100: small variation)
"""
function worker(sim::Simulation, log::Simlog,
                name::AbstractString; description::AbstractString="",
                input::Int=1, jobs::Int=1, output::Int=1,
                mtbf::Number=0, mttr::Number=0, alpha::Int=1)
    wu = Workunit(name, description, WORKER,
                PFQueue(name*"-IN", Resource(sim, input), Queue(Job)),
                PFQueue(name*"-JOB", Resource(sim, jobs), Queue(Job)),
                PFQueue(name*"-OUT", Resource(sim, output), Queue(Job)),
                alpha, mtbf, mttr)
    proc = @process work(sim, wu, log)
    if mtbf > 0
        @process failure(sim, proc, mtbf)
    end
    wu
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
