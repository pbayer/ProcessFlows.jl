println("test_activities8: idle + working + blocking + failing - 20e3 simulation time units\n")
include("test_activities.jl")

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
sleep(15)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
@test length(out) == 2000
@test length(mm.log) == 4721
@test sim.index == 36018
@test round(maximum(mml[:time]), 2) == 20705.18
println("8th test (IDLE + WORKING + BLOCKED + FAILURE for 22.000 time units) passed\n")
