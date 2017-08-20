using SimJulia, Base.Test, PFlow

d = readOrders("../models/MOD01_orders.csv")

@test length(d) == 2
@test length(d["ORD01"]) == 3
@test length(d["ORD02"]) == 4
@test d["ORD01"][1].order == "ORD01"
@test d["ORD01"][2].job == "JOB02"
@test d["ORD01"][2].wus == ["MC02", "MC03", "MC04"]
@test d["ORD02"][4].plan_time == 4.50
@test d["ORD02"][4].op_time == 0.00
@test d["ORD02"][4].completion == 0.00
@test d["ORD02"][4].status == 0
@test d["ORD02"][4].batch_size == 1
@test d["ORD02"][4].target == ""

sim = Simulation()
sl = newlog()
w = readWorkunits("../models/MOD01_workunits.csv", sim, sl)
@test length(w) == 5
@test typeof(w["MC01"].input) == PFlow.PFQueue
@test typeof(w["MC02"].jobs) == PFlow.PFQueue
@test typeof(w["MC03"].output) == PFlow.PFQueue
@test w["MC04"].alpha == 100
@test w["MC05"].mtbf == 500

println("test_simio.jl completed")
