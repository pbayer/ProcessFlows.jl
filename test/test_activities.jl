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
        try
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

function delivering(sim::DES, wu::Workunit, dt::Number=0)
    timer = sim.time
    while true
        try
            if dt > 0
                Δt = rand(Exponential(dt))
                delayuntil(sim, timer + Δt)
                timer += Δt
            end
            (pro, timer) = dequeue!(wu.output, timer)
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
#@test sim.index == 130
println("1st test (WORKING) passed")

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
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
@test length(out) == 10 # ten products were produced
@test length(mm.log) == 20+1 # 20 times the machine changed status
#@test sim.index == 258
#@test round(maximum(mml[:time]), 2) == 141.2 # it took 142.2 units simulation time
#@test round(maximum(mml[:time]), 2) == 199.09 # after introduction of clock
println("$(length(out)) products delivered")
println("2nd test (IDLE + WORKING) passed")

sim = DES()
ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
out = Products()
srand(345)  # seed random number generator for reproducibility
mm = machine(sim, "test", input=1) # smaller input buffer
z = @async dummy(sched)
s = @async scheduling(sim, mm, 0, 10) # without delay
d = @async delivering(sim, mm, 12)    # starve output
register(sim, [s, d, z])
y = @async simulate(sim, 200)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
@test length(out) == 10 # ten products were produced
#@test length(mm.log) == 28
#@test sim.index == 214
#@test round(maximum(mml[:time]), 2) == 137.85 # it took 146.06 units simulation time
println("$(length(out)) products delivered")
println("3rd test (WORKING + BLOCKED) passed")

sim = DES()
ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
out = Products()
srand(567)  # seed random number generator for reproducibility
mm = machine(sim, "test", input=1) # smaller input buffer
z = @async dummy(sched)
s = @async scheduling(sim, mm, 8, 10) # starve input
d = @async delivering(sim, mm, 15)    # starve output
register(sim, [s, d, z])
y = @async simulate(sim, 200)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
@test length(out) == 10 # ten products were produced
#@test length(mm.log) == 27
#@test sim.index == 268
#@test round(maximum(mml[:time]), 2) == 167.90
println("$(length(out)) products delivered")
println("4th test (IDLE + WORKING + BLOCKED) passed")

sim = DES()
ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
out = Products()
srand(4711)  # seed random number generator for reproducibility
mm = machine(sim, "test", mtbf=25, mttr=5) # with failures
z = @async dummy(sched)
s = @async scheduling(sim, mm, 0, 10) # without delay
d = @async delivering(sim, mm, 0)    # without delay
register(sim, [s, d, z])
y = @async simulate(sim, 200)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
@test length(out) == 10 # ten products were produced
@test length(mm.log) == 32 # 32 times the machine changed status
@test sim.index == 258
@test round(maximum(mml[:time]), 2) == 196.74 # it took 196.74 units simulation time
println("$(length(out)) products delivered")
println("5th test (WORKING + FAILURE) passed")

sim = DES()
ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
out = Products()
srand(0815)  # seed random number generator for reproducibility
mm = machine(sim, "test", mtbf=50, mttr=5) # with failures
z = @async dummy(sched)
s = @async scheduling(sim, mm, 8, 20) # starve input
d = @async delivering(sim, mm, 8)    # starve output
register(sim, [s, d, z])
y = @async simulate(sim, 200)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
#@test length(out) == 10 # ten products were produced
#@test length(mm.log) == 32 # 32 times the machine changed status
#@test sim.index == 258
#@test round(maximum(mml[:time]), 2) == 196.74 # it took 196.74 units simulation time
println("$(length(out)) products delivered")
println("6th test (IDLE + WORKING + BLOCKED + FAILURE) passed")

sim = DES()
ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
out = Products()
srand(0815)  # seed random number generator for reproducibility
mm = machine(sim, "test", mtbf=50, mttr=5) # with failures
z = @async dummy(sched)
s = @async scheduling(sim, mm, 8, 200) # starve input
d = @async delivering(sim, mm, 8)    # starve output
register(sim, [s, d, z])
y = @async simulate(sim, 2000)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
#@test length(out) == 10 # ten products were produced
#@test length(mm.log) == 32 # 32 times the machine changed status
#@test sim.index == 258
#@test round(maximum(mml[:time]), 2) == 196.74 # it took 196.74 units simulation time
println("$(length(out)) products delivered")
println("7th test (IDLE + WORKING + BLOCKED + FAILURE for 2000 time units) passed\n")

sim = DES()
ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
out = Products()
srand(0815)  # seed random number generator for reproducibility
mm = machine(sim, "test", mtbf=50, mttr=5) # with failures
z = @async dummy(sched)
s = @async scheduling(sim, mm, 8, 2000) # starve input
d = @async delivering(sim, mm, 8)    # starve output
register(sim, [s, d, z])
y = @async simulate(sim, 22000)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
#@test length(out) == 10 # ten products were produced
#@test length(mm.log) == 32 # 32 times the machine changed status
#@test sim.index == 258
#@test round(maximum(mml[:time]), 2) == 196.74 # it took 196.74 units simulation time
println("$(length(out)) products delivered")
println("8th test (IDLE + WORKING + BLOCKED + FAILURE for 21.000 time units) passed\n")

sim = DES()
ml = Array{testlog, 1}()
jl = Array{testlog, 1}()
out = Products()
srand(0815)  # seed random number generator for reproducibility
mm = machine(sim, "test", mtbf=50, mttr=5) # with failures
z = @async dummy(sched)
s = @async scheduling(sim, mm, 8, 200000) # starve input
d = @async delivering(sim, mm, 8)    # starve output
register(sim, [s, d, z])
y = @async simulate(sim, 2200000)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
#@test length(out) == 10 # ten products were produced
#@test length(mm.log) == 32 # 32 times the machine changed status
#@test sim.index == 258
#@test round(maximum(mml[:time]), 2) == 196.74 # it took 196.74 units simulation time
println("$(length(out)) products delivered")
println("9th test (IDLE + WORKING + BLOCKED + FAILURE for 2.100.000 time units) passed\n")
