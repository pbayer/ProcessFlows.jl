# --------------------------------------------
# this file is part of PFlow.jl
# it implements the scheduling for an order based system
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

Plan   = Array{Planned, 1}
Mps    = Array{Product,1}
Orders = Dict{String, Array{Job,1}}

"""
    create_mps(plan::Plan, order::Orders) :: Mps

create a master production schedule (MPS) for a production system
"""
function create_mps(plan::Plan, order::Orders) :: Mps
    mps = Mps()
    demand = [p.demand for p ∈ plan]
    mix = Int.(round.(demand./minimum(demand)))
    index = [1 for i ∈ demand]
    while length(mps) < sum(demand)
        for i ∈ 1:length(plan)
            k = min(index[i]+mix[i]-1, demand[i])
            for j ∈ index[i]:k
                pl = plan[i]
                item = pl.item_offset+j
                jobs = deepcopy(order[pl.order])
                for job ∈ jobs
                    job.item = item
                end
                p = Product(pl.code, item, pl.name, pl.description,
                            pl.order, jobs, 0, OPEN)
                push!(mps, p)
            end
            index[i] = k + 1
        end # for
    end # while
    mps
end

"""
    scheduler(sim::Simulation,
              wus::Array{Workunit, 1},
              cycle::Number=1)

Cycle through all work units in `wus`, look for finished jobs (in `wu.output`)
and move them to the next free work unit.
"""
function scheduler(sim::Simulation,
                   wus::Array{Workunit, 1},
                   cycle::Number=1)
    while true
        for wu ∈ wus
            if !isempty(wu.output)             # look for finished products/jobs
                p = front(wu.output)           # get first product
                if p.pjob < length(p.jobs)
                    job = p.jobs[p.job+1]
                    nextw = ""
                    len = 1e6
                    while w ∈ job.wus          # look for possible targets
                        if !isfull(resources[w].input)    # get shortest input queue
                            if length(resources[w].input) < len
                                len = length(resources[w].input)
                                nextw = w
                            end
                        end
                    end
                    if nextw ≠ ""             # found something
                        enqueue!(resources[nextw].input, job)
                        p.pjob += 1           # set pointer to next job
                    end # if nextw
                else
                    p.status = FINISHED
                    enqueue!(resources["WAREHOUSE"].input, p)
                end
            end # if !isempty
        end # for wu
        yield(Timeout(sim, cycle))
    end # while true
end # function

"""
    source(sim::Simulation, products::Mps)

release products into a production system
"""
function source(sim::Simulation, products::Dict{UInt64, Array{Product,1}})
end

"""
    sink(sim::Simulation)

collect finished products from a production system
"""
function sink(sim::Simulation)
end

"""
    start_scheduling(sim::Simulation)

get the MPS and a production system and start source, sink and scheduling
"""
function start_scheduling(sim::Simulation)
end
