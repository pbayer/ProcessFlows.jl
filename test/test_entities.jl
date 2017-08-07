using SimJulia, PFlow
import DataStructures: Queue

sim = Simulation()

p = PFQueue("test", Resource(sim, 1), Queue(Job))

j = Job("testjob", ["test1", "test2", "test3"], 5.0, 0.0, 0.0, 1, 1, "no target")

w = Workunit("testmachine", 1, p, p, p, 1, 0, 0, 0, 0.0)


println("Tests finished")
