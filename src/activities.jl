# --------------------------------------------
# this file is part of PFlow.jl
# it implements the various activities
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    opTime(wu::Workunit, job::Job)

calculate the operation time of a job at a station
"""
function opTime(wu::Workunit, job::Job)
    μ = job.op_time / (2 * wu.alpha)
    job.op_time/2 + rand(Erlang(wu.alpha, μ))
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
#        println("scheduling new failure")
        Δt = rand(Exponential(mtbf))
#        println("failure after $(Δt)")
        yield(Timeout(sim, Δt))
        interrupt(proc, FAILURE)
    end
end

"""
    work(sim::Simulation, wu::Workunit, log=true)

let a Workunit work on its jobs
"""
function work(sim::Simulation, wu::Workunit, log::Simlog)

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
        job
    end

    function finishjob(wu::Workunit)
        job = dequeue!(wu.jobs)
        enqueue!(wu.output, job)
        setstatus(IDLE)
    end

    status = Logvar(wu.name, IDLE)
    logvar2log(log, status)
    t0 = 0.0
    t1 = 0.0
    Δt = 0.0
    oldstatus = IDLE
    job = Job("","",0.0,0,0,"")
    while true
        try
            if getstatus(IDLE)           # get a new job
                job = getnewjob(wu)
                setstatus(WORKING)
                Δt = opTime(wu, job)
                t0 = now(sim)
                t1 = 0.0
                yield(Timeout(sim, Δt))
                job.status = DONE
                if isfull(wu.output)
                    setstatus(BLOCKED)
                else
                    finishjob(wu)
                end
            elseif getstatus(BLOCKED)      # output buffer is full
                finishjob(wu)
            elseif getstatus(WORKING)      # return to work after failure
                Δt -= t1
                t0 = now(sim)
                @assert Δt > 0 "$(now(sim)): $(wu.name) Δt ≤ 0, Δt: $(Δt)"
                yield(Timeout(sim, Δt))
                job.status = DONE
                if isfull(wu.output)
                    setstatus(BLOCKED)
                else
                    finishjob(wu)
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
                    t1 += now(sim) - t0       # time worked into that job
                end
                setstatus(FAILURE)
            else
                rethrow(exc) # propagate exception
            end # if isa
        end # try, catch
    end # while
end

"""
    machine(sim::Simulation, log::Simlog, name::AbstractString;
            mtbf::Number=0, mttr::Number=0,
            input::Int=1, jobs::Int=1, output::Int=1, alpha::Int=100)

create a new machine, start a process on it and return it
"""
function machine(sim::Simulation, log::Simlog, name::AbstractString;
                 input::Int=1, jobs::Int=1, output::Int=1,
                 mtbf::Number=0, mttr::Number=0, alpha::Int=100)
    wu = Workunit(name, MACHINE,
                PFQueue(name*"-IN", Resource(sim, input), Queue(Job)),
                PFQueue(name*"-JOB", Resource(sim, jobs), Queue(Job)),
                PFQueue(name*"-OUT", Resource(sim, output), Queue(Job)),
                alpha, mtbf, mttr)
#    @assert length(wu.input.res) == 0 && isempty(wu.input.queue) "input queue not empty"
#    @assert length(wu.jobs.res) == 0 && isempty(wu.jobs.queue) "jobs queue not empty"
#    @assert length(wu.output.res) == 0 && isempty(wu.output.queue) "output queue not empty"
    proc = @process work(sim, wu, log)
    if mtbf > 0
        @process failure(sim, proc, mtbf)
    end
    wu
end

"""
    worker()
"""
function worker()
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
