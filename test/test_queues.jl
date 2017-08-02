using SimJulia
using Base.Test
using PFlow

sim = Simulation()

import DataStructures.Queue

q = PFQueue("Test", Resource(sim, 2), Queue(Int64))

@test length(q) == 0
@test isempty(q)
@test_throws ArgumentError front(q)
@test_throws ArgumentError back(q)
@test length(sprint(dump,q)) >= 0

@test PFlow.capacity(q) == 2
enqueue!(q, 1)
enqueue!(q, 2)
@test front(q) == 1
@test back(q) == 2
@test isfull(q)
@test_throws ArgumentError enqueue!(q, 3)
@test dequeue!(q) == 1
@test length(q) == 1
@test dequeue!(q) == 2
@test isempty(q)
@test_throws ArgumentError dequeue!(q)

n = 10

q = PFQueue("Test", Resource(sim, n), Queue(Int64))
for i ∈ 1:n
  enqueue!(q, i)
  @test length(q) == i
  @test isempty(q) == false
  @test front(q) == 1
  @test back(q) == i
  if i < n
    @test isfull(q) == false
  else
    @test isfull(q)
  end

  cq = collect(q)
  @test cq == collect(1:i)
end
@test_throws ArgumentError enqueue!(q, 1)


for i ∈ 10:-1:1
  @test dequeue!(q) == 10-i+1
  @test length(q) == i-1
  @test isfull(q) == false
  if i > 1
    @test isempty(q) == false
  else
    @test isempty(q)
  end

  cq = collect(q)
  @test cq == collect(10-i+2:10)
end
@test_throws ArgumentError dequeue!(q)
