println("test_activities2: idle + working\n")
include("test_activities.jl")

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
@test sim.index == 262
@test round(maximum(mml[:time]), 2) == 154.86
println("2nd test (IDLE + WORKING) passed")
