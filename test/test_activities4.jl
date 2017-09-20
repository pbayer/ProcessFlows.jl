println("test_activities4: idle + working + blocking \n")
include("test_activities.jl")


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
@test length(mm.log) == 27
@test sim.index == 273
@test round(maximum(mml[:time]), 2) == 170.12
println("4th test (IDLE + WORKING + BLOCKED) passed")
