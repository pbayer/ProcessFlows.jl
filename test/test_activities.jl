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
    timer = sim.time
    for i ∈ 1:n
        if dt > 0
            Δt = rand(Exponential(dt))
            delayuntil(sim, timer+Δt)
            timer += Δt
        end
        item = 123000+i
        job = Job(item, "Job"*string(i), [wu.name], randn()+5)
        pro = Product(123, item, "test", "testproduct", "testorder", [job])
        timer = enqueue!(wu.input, pro, timer)
        pro.start_time = timer
        push!(jl, testlog(timer, item))
    end
end

function delivering(sim::DES, wu::Workunit, dt::Number=0)
    timer = sim.time
    while true
        try
            if dt > 0
              delay(sim, rand(Exponential(dt)))
            end
            (pro, timer) = dequeue!(wu.output)
            push!(ml, testlog(timer, pro.item))
            pro.end_time = timer
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

ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
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
#jl = DataFrame(time=[l.time for l in jl], done=[l.value for l in jl])
#wl = DataFrame(time=[])
sleep(1)
@test all(x->(x.state == :done), [d, y, z, s]) # all tasks are finished
@test length(out) == 10 # ten products were produced
@test length(mm.log) == 20+1 # 20 times the machine changed status
@test sim.index == 50 # 50 simulation events took place (2 x 10 enqueue + 2 x 10 dequeue + 10 delayuntil)
println("1st test passed")

sim = DES()
ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
out = Products()
srand(2345)  # seed random number generator for reproducibility
mm = machine(sim, "test", input=1) # smaller input buffer
z = @async dummy(sched)
s = @async scheduling(sim, mm, 10, 10) # starve input
d = @async delivering(sim, mm, 0)      # without delay
register(sim, [s, d, z])
y = @async simulate(sim, 200)
yield()
#mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log])
sleep(1)
@test length(out) == 10 # ten products were produced
@test length(mm.log) == 20+1 # 20 times the machine changed status
@test sim.index == 50 # 50 simulation events took place 2 x (10 enqueue + 10 dequeue + 10 delayuntil)

println("2nd test passed")
