using SimJulia
using Base.Test
using PFlow

function scheduler(sim::Simulation, wu::Workunit, n::Int64=100)
  for i ∈ 1:n
    job = Job("Job"*string(i), wu.name, randn()+5, OPEN, 1, "")
    yield(Put(wu.input.res, 1))
    enqueue!(wu.input, job)
  end
end

function delivery(sim::Simulation, wu::Workunit)
  while true
    yield(Get(wu.output.res))
    job = dequeue!(w.output)
    println(@sprintf("%0.2f: job %s is done", now(sim), job.name))
  end
end


sim = Simulation()
sl = newlog()
mm = machine(sim, sl, "test", 200, 10, 10)
@process scheduler(sim, mm, 10)
@process delivery(sim, mm)

run(sim, 200)
