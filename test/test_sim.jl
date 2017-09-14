using PFlow

function producer(sim::DES, name::String)
    n = rand(1:10)
    for i in 1:n
        Δt = randn() + 5
        delay(sim, Δt)
        println("Task:$name id:$(current_task()) nr:$i at $(now(sim))")
    end
    println("Task:$name id:$(current_task()) finishes at $(now(sim))")
end

srand(123)
sim = DES()
a = @async producer(sim, "A")
b = @async producer(sim, "B")
c = @async producer(sim, "C")
for t in [a,b,c]
    register(sim, t)
end
simulate(sim, 100)
