# --------------------------------------------
# this file is part of PFlow.jl
# it implements the various activities in an order-based system.
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# date: 2017-07-29
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    opTime(wu::Workunit, job::Job)

calculate the operation time of a job at a station
"""
function opTime(wu::Workunit, job::Job)
  μ = job.op_time / (2 * wu.alpha)
  rand(Erlang(wu.alpha, μ))
end

"""
    repTime(wu:Workunit, alpha=1)

calculate a repairtime based on wu.mttr
"""
function repTime(wu::Workunit, alpha=1)
  μ = wu.mttr / (2 * alpha)
  rand(Erlang(alpha, μ))
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
    schedule_failure(sim::Simulation, proc::Process, mtbf::Real)

schedule a FAILURE for a Process
"""
function schedule_failure(sim::Simulation, proc::Process, mtbf::Real)
  @process failure(sim, proc, mtbf)
end

"""
    work(sim::Simulation, wu::Workunit, log=true)

let a Workunit work on its jobs
"""
function work(sim::Simulation, wu::Workunit, log::Simlog)

  function setstatus(status)
    wu.status = status
    lognow(sim, log)
  end

  t0 = 0.0
  t1 = 0.0
  oldstatus = IDLE
  while true
    try
      if wu.status == IDLE            # get a new job
        yield(Get(wu.input.res, 1))
        job = dequeue!(wu.input)
        enqueue!(wu.jobs, job)
        job.status = PROGRESS
        setstatus(WORKING)
        Δt = opTime(wu, job)
        t0 = now(sim)
        t1 = 0.0
        yield(Timeout(sim, Δt))
        job.status = DONE
        if isfull(wu.output)
          setstatus(BLOCKED)
        else
          dequeue!(wu.jobs)
          Put(wu.output.res, 1)
          enqueue!(wu.output, job)
          setstatus(IDLE)
        end
      elseif wu.status == BLOCKED      # output buffer is yet full
        yield(Put(wu.output.res, 1))
        dequeue!(wu.jobs)
        enqueue!(wu.output, job)
        setstatus(IDLE)
      elseif wu.status == WORKING      # return to work after failure
        Δt -= t1
        t0 = now(sim)
        yield(Timeout(sim, Δt))
        job.status = DONE
        if isfull(wu.output)
          setstatus(BLOCKED)
        else
          dequeue!(wu.jobs)
          Put(wu.output.res, 1)
          enqueue!(wu.output, job)
          setstatus(IDLE)
        end
      elseif wu.status == FAILURE      # request repair
        yield(Timeout(sim, repTime(wu)))
        setstatus(oldstatus)
      else
        throw(ArgumentError(@sprintf("%s: %d wu.status not defined", wu.name, wu.status)))
      end
    catch exc
      if isa(exc, SimJulia.InterruptException) && exc.cause == FAILURE
        if oldstatus != FAILURE
          oldstatus = wu.status
        end
        schedule_failure(sim, active_process(), wu.mtbf) # schedule next failure
        if wu.status == WORKING
          t1 += now(sim) - t0       # time worked into that job
        end
        setstatus(FAILURE)
      else
        throw(exc) # propagate exception
      end # if
    end # try, catch
  end # while
end

"""
    machine(sim::Simulation, log::Bool,
            name::AbstractString, mtbf::Number, mttr::Number,
            input::Int=1, jobs::Int=1, output::Int=1, alpha::Int=100)

create a new machine start a process on it and return it
"""
function machine(sim::Simulation, log::Simlog,
                 name::AbstractString, mtbf::Number, mttr::Number,
                 input::Int=1, jobs::Int=1, output::Int=1, alpha::Int=100)
  wu = Workunit(name, MACHINE,
                PFQueue(name*"-IN", Resource(sim, input), Queue(Job)),
                PFQueue(name*"-JOB", Resource(sim, jobs), Queue(Job)),
                PFQueue(name*"-OUT", Resource(sim, output), Queue(Job)),
                IDLE, alpha, mtbf, mttr)
  logvar2log(log, Logvar(name*".status", wu.status))
  @process work(sim, wu, log)
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
