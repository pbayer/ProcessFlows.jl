using SimJulia, Base.Test, PFlow

d = readOrders("../models/MOD01_orders.csv")

plan1 = Planned(123,  7, 123000, "test1", "test1test1test1", "ORD01")
plan2 = Planned(456, 18, 456000, "test2", "test2test2test2", "ORD02")

mps = create_mps([plan1, plan2], d)

@test length(mps) == 25

p123 = [p for p ∈ mps if p.code == 123]
@test length(p123) == 7

p456 = [p for p ∈ mps if p.code == 456]
@test length(p456) == 18

mps = create_mps([plan1, plan2], d, false) # not leveled

@test length(mps) == 25

println("test create_mps finished")

srand(2345)  # seed random number generator for reproducibility
sim = Simulation()
wus = readWorkunits("../models/MOD01_workunits.csv", sim)
mps = create_mps([plan1, plan2], d)
out = Products()
start_scheduling(sim, wus, mps, out)
run(sim, 250)

@test length(mps) == 0
@test length(out) == 25

println("test scheduling finished")
