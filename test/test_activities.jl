using SimJulia, Base.Test, PFlow, Distributions

function scheduler(sim::Simulation, log::Simlog, wu::Workunit, delay::Number=0, n::Int64=100)
  sched = Logvar("schedule", "")
  logvar2log(log, sched)
  for i ∈ 1:n
    if delay > 0
      yield(Timeout(sim, rand(Exponential(delay))))
    end
    job = Job("Job"*string(i), wu.name, randn()+5, OPEN, 1, "")
    yield(Put(wu.input.res, 1))
    enqueue!(wu.input, job)
    sched.value = job.name
    lognow(sim, log)
  end
  sched.value = ""
end

function delivery(sim::Simulation, log::Simlog, wu::Workunit, delay::Number=0)
  done = Logvar("done", "")
  logvar2log(log, done)
  while true
    if delay > 0
      yield(Timeout(sim, rand(Exponential(delay))))
    end
    yield(Get(wu.output.res))
    job = dequeue!(wu.output)
    done.value = job.name
    lognow(sim, log)
  end
end

srand(1234)  # seed random number generator for reproducibility
sim = Simulation()
ml = newlog()
jl = newlog()
mm = machine(sim, ml, "test", 200, 10, 10)
@process scheduler(sim, jl, mm, 0., 10) # without delay
@process delivery(sim, jl, mm, 0.)      # without delay
run(sim, 200)
ml = log2df(ml)
jl = log2df(jl)

@test length(ml[:test]) == 40
@test length(jl[:done]) == 20
@test length(jl[jl[:done] .!= "", :done]) == 10 # ten jobs were finished
@test length(ml[ml[:test] .== 1, :test]) == 20 # twenty times the machine changed status
@test round(ml[:time][40], 4) == 50.9639
@test round(jl[:time][20], 4) == 50.9639

srand(2345)  # seed random number generator for reproducibility
sim = Simulation()
ml = newlog()
jl = newlog()
mm = machine(sim, ml, "test", 200, 10, 2) # smaller input buffer
@process scheduler(sim, jl, mm, 10, 10) # starve input
@process delivery(sim, jl, mm, 0)      # without delay
run(sim, 200)
ml = log2df(ml)
jl = log2df(jl)

@test length(ml[:test]) == 40
@test length(jl[:done]) == 20
@test length(Set(jl[:done])) == 11 # all ten jobs were finished
@test length(ml[ml[:test] .== 1, :test]) == 20 # twenty times the machine changed status
@test round(ml[:time][40], 4) == 124.5902
@test round(jl[:time][20], 4) == 124.5902

srand(3456)  # seed random number generator for reproducibility
sim = Simulation()
ml = newlog()
jl = newlog()
mm = machine(sim, ml, "test", 200, 10, 2) # smaller input buffer
@process scheduler(sim, jl, mm, 8, 10) # starve input
@process delivery(sim, jl, mm, 12)      # starve output
run(sim, 200)
ml = log2df(ml)
jl = log2df(jl)

@test length(ml[:test]) == 52
@test length(jl[:done]) == 20
@test length(Set(jl[:done])) == 11 # all ten jobs were finished
@test length(ml[ml[:test] .== 1, :test])/2 == 10 # ten times the machine got working
@test length(ml[:test][ml[:test] .== 3])/2 == 6  # six times the machine was blocked
@test round(ml[:time][52], 4) == 161.5983        # now the machine finished
@test round(jl[:time][20], 4) == 175.2269        # now the last job was delivered

println("Tests finshed")
