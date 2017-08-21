using SimJulia, PFlow
import DataStructures: Queue

sim = Simulation()

p = PFQueue("test", Resource(sim, 1), Queue(Product))

j = Job(456, "testjob", ["test1", "test2", "test3"], 5.0, 0.0, 0.0, 1, 1, "no target")

w = Workunit("test", "testmachine", 1, p, p, p, 1, 0, 0, 0, 0.0)

p = Product(123, 456, "pname", "pdescr", "oname", [j, j, j], 1, OPEN)

println("Tests finished")
