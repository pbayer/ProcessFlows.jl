
function genjob()
    ops = [Op("op"*string(i), rand(1:5)) for i ∈ 1:rand(10:100)]
    no = abs(rand(Int))
    job = Job("job"*string(no), no, ops)
    job.started = sim.time
    return job
end

src = Source("mySource", :(genjob()), delay=:(rand(1:10)))
@test_warn "undefined transition" step!(src, src.state, Finish())
@test isempty(src.queue)
@test src.capacity == 10
snk = Sink("mySink")
@test_warn "undefined transition" step!(snk, snk.state, Finish())
@test isempty(snk.store)

Random.seed!(123)
sim = Clock()
@test_warn "undefined transition" start!(src)
init!(src, sim)
@test isa(src.sim, Clock)
@test src.state == Idle()
init!(snk, sim)
@test isa(snk.sim, Clock)
@test snk.state == Idle()

start!(src)
@test length(sim.events) == 1
@test src.state == Busy()

run!(sim, 100)
@test src.state == Full()
@test length(src.queue) == 10

function consumejob(delay=:(rand(1:5)))
    if !isempty(src)
        job = get!(src)
        job.finished = sim.time
        enter!(snk, job)
    else
        # nothing to do
    end
    event!(sim, :(consumejob($delay)), sim.time + eval(delay))
end

@test consumejob() ≈ 101 atol=1e-10
@test length(src.queue) == 9
@test !isempty(src)
run!(sim, 100)
@test length(src.queue) == 4
@test length(snk.store) == 26

# test 0 delay for source
src = Source("mySource", :(genjob()))
@test src.delay == 0
init!(src, sim)
start!(src)
@test length(src.queue) == 10
run!(sim, 100)
@test length(src.queue) == 10  # source remains always full
@test length(snk.store) == 51  # even if 25 more jobs were consumed
