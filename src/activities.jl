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
    @assert !isempty(wu.wip) "wip of $(wu.name) is empty"
    p = wu.wip[1]
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
    failure(sim::DES, task::Task, mtbf::Real)

interrupt a task with a FAILURE after rand(Exponential(mttr))
"""
function failure(sim::DES, task::Task, mtbf::Real)
    timer = 0.0
    while true
        try
            Δt = rand(Exponential(mtbf))
            ft = timer + Δt
            for i in 1:floor(Int, ft-timer)
                delayuntil(sim, timer+i)
            end
            delayuntil(sim, ft)
            timer = ft
            interrupttask(sim, task, SimException(FAILURE, timer))
        catch exc
            break
        end
    end
end

"""
    do_work(sim::DES, wu::Workunit)

auxiliary function for doing the work
"""
function do_work(sim::DES, wu::Workunit)
    job = currentjob(wu)
    wu.t0 = wu.time
    if iszero(job.op_time)
        job.op_time = opTime(wu.alpha, job.plan_time)
    end
    Δt = job.op_time*(1 - job.completion)
    delayuntil(sim, wu.time+Δt)
    wu.time += Δt
end

"""
    do_multitask(sim::DES, wu::Workunit)

take the current job for the product at the front of the wu.wip queue,
work on it for wu.timeslice, move it to the back and repeat doing
"""
function do_multitask(sim::DES, wu::Workunit, job::Job)
    job = currentjob(wu)
    ## THIS HAS YET TO BE IMPLEMENTED
end

"""
    work(sim::DES, wu::Workunit, workfunc::Function, log::Simlog)

let a Workunit work on its jobs, this has to be started as a process
on a Workunit variable.

# Arguments
- `sim::DES`: SimJulia DES variable
- `wu::Workunit`: characteristics of Workunit
- `workfunc::Function`: function describing the operation
"""
function work(sim::DES, wu::Workunit, workfunc::Function)

    function setstatus(newstatus)
        push!(wu.log, PFlog(wu.time, newstatus))
        status = newstatus
    end

    function getnewjob()
        (p, wu.time) = dequeue!(wu.input, wu.time)
        push!(wu.wip, p)
        p.jobs[p.pjob].status = PROGRESS
        p.jobs[p.pjob].start_time = wu.time
        call_scheduler()
    end

    function finishjob()
        if !isempty(wu.wip)
            p = pop!(wu.wip)
            p.jobs[p.pjob].status = DONE
            p.jobs[p.pjob].end_time = wu.time
            wu.time = enqueue!(wu.output, p, wu.time)
        end
        setstatus(IDLE)
        call_scheduler()
    end

    wu.time = sim.time
    if wu.mtbf > 0
        task = current_task()
        f = @async failure(sim, task, wu.mtbf)
        register(sim, f)
    end
    status = IDLE
    push!(wu.log, PFlog(wu.time, status))
    oldstatus = IDLE
    while true
        try
            if status == IDLE           # get a new job
                getnewjob()
                setstatus(WORKING)
            elseif status == BLOCKED      # output buffer is full
                finishjob()
            elseif status == WORKING
                workfunc(sim, wu)
                if isfull(wu.output) || wu.output.time > wu.time
                    setstatus(BLOCKED)
                else
                    finishjob()
                end
            elseif status == FAILURE      # request repair
                rt = repTime(wu)
                delayuntil(sim, wu.time + rt)
                wu.time += rt
                setstatus(oldstatus)
            else
                throw(ArgumentError(@sprintf("%s: %d status not defined", wu.name, status)))
            end
        catch exc
            if isa(exc, SimException)
                if exc.cause == FAILURE
                    wu.time = exc.time     # time sync
                    if status != FAILURE
                        oldstatus = status
                    end
                    if status == WORKING
                        job = currentjob(wu)
                        Δt = max(wu.time - wu.t0, 0)   # time worked into that job
                        job.completion += Δt/job.op_time
                    end
                    setstatus(FAILURE)
                elseif exc.cause == FINISHED
                    break
                else
                    rethrow(exc)
                end
            else
                rethrow(exc) # propagate exception
            end # if isa
        end # try, catch
    end # while
end


"""
    workunit(sim::DES, kind::Int64, name::String, description::String="",
             input::Int=1, wip::Int=1, output::Int=1,
             mtbf::Number=0, mttr::Number=0, alpha::Int=100,
             timeslice::Number=0)

create a new workunit, start a process on it and return it

# Arguments
- `sim::DES`: SimJulia `DES` variable
- `kind::Int64`: which kind of Workunit to create
- `name::String`: name of Machine (used for scheduling and logging)
- `description::String`: description, for informational purposes
- `input::Int=1`: how big is the input buffer
- `wip::Int=1`: how big is the internal wip buffer
- `output::Int=1`: how big is the output buffer
- `mtbf::Number=0:` mean time between failures (0: no failures)
- `mttr::Number=0:` mean time to repair
- `alpha::Int=100:` Erlang shape factor for calculating the variation of
                    work times (1: big, 100: small variation)
- `timeslice::Number=0:` length of timeslice for multitasking, 0: no multitasking
"""
function workunit(sim::DES, kind::Int64, workfunc, name::String,
                  description::String="", input::Int=1, wip::Int=1, output::Int=1,
                  mtbf::Number=0, mttr::Number=0, alpha::Int=100,
                  timeslice::Number=0)
    wu = Workunit(name, description, kind, PFQueue(name*"-IN", sim, input),
                  Products(), PFQueue(name*"-OUT", sim, output), alpha,
                  mtbf, mttr, timeslice, sim.time, sim.time, PFlog[])
    proc = @async work(sim, wu, workfunc)
    register(sim, proc)
    wu
end

"""
    machine(sim::DES, name::String; description::String="",
            input::Int=1, wip::Int=1, output::Int=1,
            mtbf::Number=0, mttr::Number=0, alpha::Int=100,
            timeslice::Number=0)

create a new machine, start a process on it and return it.
wrapper function for workunit.

# Arguments
see workunit
"""
function machine(sim::DES, name::String; description::String="",
                input::Int=1, wip::Int=1, output::Int=1,
                mtbf::Number=0, mttr::Number=0, alpha::Int=1,
                timeslice::Number=0)
    workunit(sim, MACHINE, do_work, name, description,
             input, wip, output, mtbf, mttr, alpha, timeslice)
end

"""
    worker(sim::DES, name::String; description::String="",
           mtbf::Number=0, mttr::Number=0,
           input::Int=1, wip::Int=1, output::Int=1, alpha::Int=1,
           timeslice::Number=0, multitasking::Bool=false)

create a new worker, start a process on it and return it
wrapper function for workunit.

# Arguments
see workunit
"""
function worker(sim::DES, name::String; description::String="",
                input::Int=1, wip::Int=1, output::Int=1,
                mtbf::Number=0, mttr::Number=0, alpha::Int=1,
                timeslice::Number=0, multitasking::Bool=false)
    workfunc = (multitasking ? do_multitask : do_work)
    workunit(sim, WORKER, workfunc, name, description, input, wip, output,
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
