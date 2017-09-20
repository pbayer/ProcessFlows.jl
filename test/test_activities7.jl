println("test_activities7: idle + working + blocking + failing - 2e3 simulation time units\n")
include("test_activities.jl")

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
y = @async simulate(sim, 2500)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
@test length(out) == 200
@test length(mm.log) == 478
@test sim.index == 3918
@test round(maximum(mml[:time]), 2) == 2174.51 

println("7th test (IDLE + WORKING + BLOCKED + FAILURE for 2000 time units) passed\n")
