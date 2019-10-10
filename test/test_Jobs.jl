op = Op("test", 1)
@test typeof(op) == Op

job = Job("testjob1", abs(rand(Int)))
@test isempty(job.op)

ops = [Op("op"*string(i),i) for i ∈ 1:100]
job = Job("testjob1", abs(rand(Int)), ops)
@test length(job.op) == 100
for i ∈ 1:10
    j = rand(1:100)
    @test job.op[j].duration == j
end

@test WorkState(job.state) == planned
@test job.state == 0
set!(job, active)
@test WorkState(job.state) == active
@test job.state == 1
set!(job, scheduled)
@test WorkState(job.state) == scheduled
@test job.state == 2
set!(job, waiting)
@test WorkState(job.state) == waiting
@test job.state == 3
set!(job, inProgress)
@test WorkState(job.state) == inProgress
@test job.state == 4
set!(job, done)
@test WorkState(job.state) == done
@test job.state == 5
set!(job, faulty)
@test WorkState(job.state) == faulty
@test job.state == 6

sim = Clock()

for i ∈ 1:100
    sim.time = i
    op = nextOp!(job, sim)
    @test job.index == i
    @test op.duration == i
    @test duration(job) == i
    @test WorkState(op.state) == active
    set!(job.op[i], done)
end
@test job.started == 1
@test nextOp!(job, sim) == Nothing
@test job.index == 101
finish!(job, sim)
@test job.ok
@test WorkState(job.state) == done
@test job.finished == 100
