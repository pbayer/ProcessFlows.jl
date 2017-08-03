using SimJulia
using Base.Test
using PFlow

function scheduler(sim::Simulation, log::Simlog, wu::Workunit, n::Int64=100)
  sched = Logvar("schedule", "")
  logvar2log(log, sched)
  for i ∈ 1:n
    job = Job("Job"*string(i), wu.name, randn()+5, OPEN, 1, "")
    yield(Put(wu.input.res, 1))
    enqueue!(wu.input, job)
    sched.value = job.name
    lognow(sim, log)
  end
  sched.value = ""
end

function delivery(sim::Simulation, log::Simlog, wu::Workunit)
  done = Logvar("done", "")
  logvar2log(log, done)
  while true
    yield(Get(wu.output.res))
    job = dequeue!(wu.output)
    done.value = job.name
    lognow(sim, log)
  end
end

sim = Simulation()
ml = newlog()
jl = newlog()
mm = machine(sim, ml, "test", 200, 10, 10)
@process scheduler(sim, jl, mm, 10)
@process delivery(sim, jl, mm)

run(sim, 200)
ml = log2df(ml)
jl = log2df(jl)
