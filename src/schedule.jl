# --------------------------------------------
# this file is part of PFlow.jl
# it implements the scheduling for an order based system
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# date: 2017-07-29
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    mps()

Master Production Schedule for an order based system
"""
function mps()
end

"""
    scheduler(sim::Simulation,
              resources::Array{Workunit, 1},
              orders::Dict{String, Array{Job,1}},
              cycle::Number=1)

Cycle through all work units in resources, look for finished jobs (in wu.output)
and move them to the next free work unit.
"""
function scheduler(sim::Simulation,
                   resources::Array{Workunit, 1},
                   orders::Dict{String, Array{Job,1}},
                   cycle::Number=1)
    while true
        for wu ∈ resources
            if !isempty(wu.output)         # look for finished jobs
                job = front(wu.output)
                orderkey = job.order
                order = orders[orderkey]   # get order
                while j ∈ order.jobs       # get first open job
                    if j.status == OPEN
                        job = j
                        break
                    end
                end
                target = ""
                len = 1e6
                while w ∈ job.wus          # look for possible targets
                    if !isfull(resources[w].input)    # get shortest input queue
                        if length(resources[w].input) < len
                            len = length(resources[w].input)
                            target = w
                        end
                    end
                end
                if target ≠ ""             # found something
                    enqueue!(resources[target].input, job)
                end # if target
            end # if !isempty
        end # for wu
        yield(Timeout(sim, cycle))
    end # while true
end # function
