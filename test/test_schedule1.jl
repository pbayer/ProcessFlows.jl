using Base.Test, PFlow

println("starting test - non leved production")

d = readOrders("../models/MOD01_orders.csv")

plan1 = Planned(123,  7, 123000, "test1", "test1test1test1", "ORD01")
plan2 = Planned(456, 18, 456000, "test2", "test2test2test2", "ORD02")

srand(2345)  # seed random number generator for reproducibility
sim = DES()
wus = readWorkunits("../models/MOD01_workunits.csv", sim)
mps = create_mps([plan1, plan2], d)
out = Products()
start_scheduling(sim, wus, mps, out)
s = @async simulate(sim, 140)
sleep(1)
@test length(mps) == 0
@test length(out) == 25
println("test scheduling 25 leveled finished")
