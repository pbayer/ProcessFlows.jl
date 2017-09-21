println("test_activities6: idle + working + blocking + failing \n")
include("test_activities.jl")

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
y = @async simulate(sim, 300, finish=false)
yield()
sleep(1)
mml = DataFrame(time=[l.time for l in mm.log], status=[l.status for l in mm.log]);
@test length(out) == 20
@test length(mm.log) == 63
@test sim.index == 458
@test round(maximum(mml[:time]), 2) == 249.33

println("6th test (IDLE + WORKING + BLOCKED + FAILURE) passed")
