using DataStructures

@test_throws AssertionError FIFOBuffer("test", 0)

b = FIFOBuffer("test")
@test b.capacity == 1
@test b.counter == 0
@test isa(b.queue, PriorityQueue)
@test length(b.queue) == 0
@test isempty(b)
@test !DiscreteEvent.isfull(b)
@test enqueue!(b, "a") == 1
@test_warn "undefined transition" enqueue!(b, "b")
@test isfull(b)
@test !isempty(b)
@test dequeue!(b) == "a"
@test isempty(b)

enter!(b, "a")
@test_throws AssertionError leave!(b, "c")
leave!(b, "a")
@test isempty(b)

b = FIFOBuffer("test", 100)

for i in 1:100
    enqueue!(b, "n"*string(i))
end

@test_warn "undefined transition" enqueue!(b, "toomuch")
@test isfull(b)

for i in 1:100
    dequeue!(b)
end

@test_warn "undefined transition" dequeue!(b)
@test isempty(b)

for i in 1:100
    enqueue!(b, "n"*string(i))
end

for i in 2:2:100
    leave!(b, "n"*string(i))
end

@test length(b.queue) == 50
@test b.state == Ready()

@test init!(b) == Nothing
