# --------------------------------------------
# this file is part of PFlow.jl
# it implements the various activities in an order-based system.
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# date: 2017-07-29
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    transact(sim::Simulation, res, order, time, log=true)

let resource op transact on an order for a certain time
"""
function transact(sim::Simulation, res, order, time, log=true)
  if op.status == idle
    op.status = occupied
    op.order = order
    start = sim.now()
    t = calculate(time, op)
    result = Timeout(t | interrupt)
    while result == breakdown
      done = now(sim) - start
      op.status = breakdown
      t = calculate_repair_time()
      result = Timeout(t | interrupt)
      op.status = occupied
      result = Timeout(t | interrupt)
    end
  end
end

"""
    operate()
"""
function operate()
end

"""
    transport()
"""
function transport()
end

"""
    delay()
"""
function delay()
end

"""
    inspect()
"""
function inspect()
end

"""
    store()
"""
function store()
end
