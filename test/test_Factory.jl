sim = Clock()
fab = Factory("myfactory")
@test_throws AssertionError init!(fab, sim)
fab.source = Source("mySource", :(genjob()), delay=:(rand(1:10)))
@test_throws AssertionError init!(fab, sim)
addserv!(fab, Server("simpleServer"), 1)
@test_throws AssertionError init!(fab, sim)
fab.sink = Sink("mySink")
fab.sched = Scheduler("myScheduler")

init!(fab, sim)
@test fab.state == Idle()
@test fab.source.state == Idle()
@test fab.server[1].state == Idle()
@test fab.sink.state == Idle()
@test fab.sched.state == Idle()

@test getserv(fab, 1).name == "simpleServer"
@test getserv(fab, 2) == Nothing
@test now(fab) == 0
