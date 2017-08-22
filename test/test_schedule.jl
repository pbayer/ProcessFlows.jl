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

println("test create_mps finished")
