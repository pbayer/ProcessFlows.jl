println("test_activities5: working + failing\n")
include("test_activities.jl")


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
@test sim.index == 266
@test round(maximum(mml[:time]), 2) == 196.74 # it took 196.74 units simulation time

println("5th test (WORKING + FAILURE) passed")
