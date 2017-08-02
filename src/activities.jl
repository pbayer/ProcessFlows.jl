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
    opTime(st::Station, job::Job)

calculate the operation time of a job at a station
"""
function opTime(st::Station, job::Job)
  μ = job.op_time / (2 * st.alpha)
  rand(Erlang(st.alpha, μ))
end

function repTime(st::Station, alpha=1)
  μ = st.mttr / (2 * alpha)
  rand(Erlang(alpha, μ))
end

"""
    failure(sim::Simulation, proc::Process, mttr::Real)

schedule a FAILURE interrupt after rand(Exponential(mttr))
"""
function failure(sim::Simulation, proc::Process, mttr::Real)
  while true
    Δt = rand(Exponential(mttr))
    yield(Timeout(sim, Δt))
    interrupt(proc, FAILURE)
  end
end


"""
    task(sim::Simulation, st::Station, log=true)

let a station work on its jobs
"""
function task(sim::Simulation, st::Station, log=true)
  t0 = 0.0
  t1 = 0.0
  oldstatus = IDLE
  while true
    try
      if st.status == IDLE            # get a new job
        yield(Get(st.input.res, 1))
        job = dequeue!(st.input)
        enqueue!(st.jobs, job)
        job.status = PROGRESS
        st.status = WORKING
        Δt = opTime(st, job)
        t0 = now(sim)
        t1 = 0.0
        yield(Timeout(sim, Δt))
        job.status = DONE
        if isfull(st.output)
          st.status = BLOCKED
        else
          dequeue!(st.jobs)
          enqueue!(st.output, job)
        end
      elseif st.status == BLOCKED      # output buffer is full
        yield(Put(st.output.res, 1))
        dequeue!(st.jobs)
        enqueue!(st.output, job)
        st.status = IDLE
      elseif st.status == WORKING      # return to work after failure
        Δt -= t1
        t0 = now(sim)
        yield(Timeout(sim, Δt))
        job.status = DONE
        if isfull(st.output)
          st.status = BLOCKED
        else
          dequeue!(st.jobs)
          enqueue!(st.output, job)
        end
      elseif st.status == FAILURE      # request repair
        yield(Timeout(sim, repTime(st)))
        st.status = oldstatus
      else
        throw(ArgumentError(@sprintf("%s: %d st.status not defined", st.name, st.status)))
      end
    catch exc
      if isa(exc, SimJulia.InterruptException) && exc.cause == FAILURE
        oldstatus = st.status
        if st.status == IDLE
          st.status = FAILURE
        elseif st.status == WORKING
          t1 += now(sim) - t0       # time worked into that job
          st.status = FAILURE
        elseif st.status == FAILURE # yet another FAILURE
          continue
        elseif st.status == BLOCKED
          st.status = FAILURE
        else
          throw(ArgumentError(@sprintf("%s: %d st.status not defined", st.name, st.status)))
        end
      else
        throw(exc) # propagate exception
      end # if
    end # try, catch
  end # while
end


"""
    operate()
"""
function operate()
end

"""
    transport()
"""
function transport()
end

"""
    delay()
"""
function delay()
end

"""
    inspect()
"""
function inspect()
end

"""
    store()
"""
function store()
end
