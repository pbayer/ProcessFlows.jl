using Base.Test, PFlow, Distributions, DataFrames

struct testlog
    time::Float64
    value::Any
end

# take! the scheduling variable in order not to block clients
function dummy(s::Channel)
    while true
        try
            take!(s)
        catch exc
            if isa(exc, SimException)
                break
            else
                rethrow(exc)
            end
        end
    end
end

function scheduling(sim::DES, wu::Workunit, dt::Number=0, n::Int64=100)
  for i ∈ 1:n
    if dt > 0
      delay(sim, rand(Exponential(dt)))
    end
    item = 123000+i
    job = Job(item, "Job"*string(i), [wu.name], randn()+5)
    pro = Product(123, item, "test", "testproduct", "testorder", [job])
    enqueue!(wu.input, pro)
    push!(jl, testlog(sim.time, item))
  end
end

function delivering(sim::DES, wu::Workunit, dt::Number=0)
  while true
      try
        if dt > 0
          delay(sim, rand(Exponential(dt)))
        end
        pro = dequeue!(wu.output)
        push!(ml, testlog(sim.time, pro.item))
        push!(out, pro)
    catch exc
        if isa(exc, SimException)
            if exc.cause == FINISHED
                break
            else
                rethrow(exc)
            end
        else
            rethrow(exc)
        end
    end
  end
end

ml = testlog[]
jl = testlog[]
out = Products()
srand(1234)  # seed random number generator for reproducibility
sim = DES()
mm = machine(sim, "test", input=20)
z = @async dummy(sched)
s = @async scheduling(sim, mm, 0.0, 10)
d = @async delivering(sim, mm, 0.0)
register(sim, [s, d, z])
y = @async simulate(sim, 80, finish=true)
yield()
#ml = DataFrame(time=[l.time for l in ml], test=[l.value for l in ml])
#jl = DataFrame(time=[l.time for l in ml], done=[l.value for l in jl])
sleep(1)
@test all(x->(x.state == :done), [d, y, z, s]) # all tasks are finished
@test length(out) == 10 # ten products were produced
@test length(mm.log) == 20+1 # 20 times the machine changed status
@test sim.index == 50 # 50 simulation events took place (2 x 10 enqueue + 2 x 10 dequeue + 10 delayuntil)
println("1st test passed")
