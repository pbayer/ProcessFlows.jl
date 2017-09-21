println("test_activities1: basic working\n")
include("test_activities.jl")


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
@test sim.index == 132
println("1st test (WORKING) passed")
