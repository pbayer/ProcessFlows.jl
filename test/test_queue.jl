using Base.Test, PFlow

sim = DES()

j = Job(456, "testjob", ["test1", "test2", "test3"], 5.0, 0.0, 0.0, 1, "", 0.0, 0.0, 1, "no target")
q = PFQueue("Test", sim, 2)
p1 = Product(123, 456, "pname", "pdescr", "oname", [j, j, j], 1, OPEN, 0.0, 0.0)
p2 = Product(234, 789, "pname", "pdescr", "oname", [j, j, j], 1, OPEN, 0.0, 0.0)

@test length(q) == 0
@test isempty(q)
@test capacity(q) == 2
@test_throws BoundsError front(q)
@test_throws BoundsError back(q)

function producer(q::PFQueue)
    enqueue!(q, p1)
    sim.time =1
    enqueue!(q, p1)
    sim.time =2
    enqueue!(q, p2) # now queue full and consumer must dequeue
    sleep(0.001) # enforce sync
    sim.time =3
    enqueue!(q, p1)
    sleep(0.001) # enforce sync
    delayuntil(sim, 5)
    enqueue!(q, p1)
    sleep(0.001) # enforce sync
    delayuntil(sim, 10)
end

function consumer(q::PFQueue)
    while true
        try
            p = dequeue!(q)
            println("time:$(sim.time) got product:$(p.code), queuelen:$(length(q))")
        catch exc
            if isa(exc, SimException)
                println("time:$(sim.time) got error:$exc")
                break
            else
                rethrow(exc)
            end
        end
    end
end

p = @async producer(q)
c = @async consumer(q)
register(sim, [p, c])
s = @async simulate(sim, 6)
sleep(1)
yield(p) # still waiting
interrupttask(sim, c) # still waiting
sleep(0.001)

println("test_queue.jl passed")
