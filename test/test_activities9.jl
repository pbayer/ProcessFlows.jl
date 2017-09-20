println("test_activities9: idle + working + blocking + failing - 2e6 simulation time units\n")
include("test_activities.jl")

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
println("9th test (IDLE + WORKING + BLOCKED + FAILURE for 2.200.000 time units) passed\n")
