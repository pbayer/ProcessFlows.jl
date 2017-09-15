using PFlow

function producer(sim::DES, name::String)
    mytime = sim.time
    n = rand(1:25)
    try
        for i in 1:n
            mytime += randn() + 5
            delayuntil(sim, mytime)
            println("Task:$name id:$(current_task()) nr:$i at $mytime")
        end
    catch exc
        println("Task:$name id:$(current_task()) exception:$exc at $(sim.time)")
        mytime = sim.time
    end
    println("Task:$name id:$(current_task()) finishes at $mytime")
end

srand(123)
sim = DES()
a = @async producer(sim, "A")
b = @async producer(sim, "B")
c = @async producer(sim, "C")
for t in [a,b,c]
    register(sim, t)
end
d = @async simulate(sim, 100)
sleep(1)
interrupttask(sim, a)
