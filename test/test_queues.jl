using SimJulia, Base.Test, PFlow
import DataStructures.Queue

sim = Simulation()

j = Job(456, "testjob", ["test1", "test2", "test3"], 5.0, 0.0, 0.0, 1, 1, "no target")
q = PFQueue("Test", Resource(sim, 2), Queue(Product))
p1 = Product(123, 456, "pname", "pdescr", "oname", [j, j, j], 1, OPEN)
p2 = Product(234, 789, "pname", "pdescr", "oname", [j, j, j], 1, OPEN)

@test length(q) == 0
@test isempty(q)
@test_throws ArgumentError front(q)
@test_throws ArgumentError back(q)
@test length(sprint(dump,q)) >= 0

@test PFlow.capacity(q) == 2

function testq1(sim::Simulation)
    enqueue!(q, p1)
    yield(Timeout(sim, 1))
    enqueue!(q, p2)
    yield(Timeout(sim, 1))
    @test_throws ArgumentError enqueue!(q, p2)
    @test front(q).item == 456
    @test back(q).item == 789
    @test isfull(q)
    yield(Timeout(sim, 1))
    @test dequeue!(q).code == 123
    @test length(q) == 1
    yield(Timeout(sim, 1))
    @test dequeue!(q).code == 234
    @test isempty(q)
    @test_throws ArgumentError dequeue!(q)
end

@process testq1(sim)
run(sim, 100)

println("testq1 finished!")

sim = Simulation()
n = 10
q = PFQueue("Test", Resource(sim, n), Queue(Product))

function testq2(sim::Simulation)
    for i ∈ 1:n
        p = Product(123, i, "pname", "pdescr", "oname", [j, j, j], 1, OPEN)
        enqueue!(q, p)
        @test length(q) == i
        @test isempty(q) == false
        @test front(q).item == 1
        @test back(q).item == i
        if i < n
            @test isfull(q) == false
        else
            @test isfull(q)
        end

        cq = [i.item for i ∈ collect(q)]
        @test cq == collect(1:i)
        yield(Timeout(sim, 1))
    end
    p = Product(123, n+1, "pname", "pdescr", "oname", [j, j, j], 1, OPEN)
    @test_throws ArgumentError enqueue!(q, p)


    for i ∈ 10:-1:1
      @test dequeue!(q).item == 10-i+1
      @test length(q) == i-1
      @test isfull(q) == false
      if i > 1
        @test isempty(q) == false
      else
        @test isempty(q)
      end

      cq = [i.item for i ∈ collect(q)]
      @test cq == collect(10-i+2:10)
      yield(Timeout(sim, 1))
    end
    @test_throws ArgumentError dequeue!(q)
end

@process testq2(sim)
run(sim, 100)

println("testq2 finished")
