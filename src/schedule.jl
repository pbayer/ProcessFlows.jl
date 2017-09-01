# --------------------------------------------
# this file is part of PFlow.jl
# it implements the scheduling
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

Plan     = Array{Planned, 1}
Products = Array{Product,1}
Orders   = Dict{String, Array{Job,1}}

sched    = Container{Int}


"""
    create_mps(plan::Plan, order::Orders) :: Products

return a master production schedule (MPS) for a production system.

# Arguments
- `plan::Plan`: array of planned product codes
- `order::Orders`: order dictionary
- `leveled::Bool=true`: should the MPS be Heijunka-leveled?
"""
function create_mps(plan::Plan, order::Orders, leveled::Bool=true) :: Products
    mps = Products()
    demand = [p.demand for p ∈ plan]
    if leveled
        mix = Int.(round.(demand./minimum(demand))) # calculate the mix
        index = [1 for i ∈ demand]                  # create an index for the orders
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
                                pl.order, jobs, 0, OPEN, 0.0, 0.0)
                    push!(mps, p)
                end
                index[i] = k + 1
            end # for
        end # while
    else
        for pl ∈ plan
            for j ∈ 1:pl.demand
                item = pl.item_offset+j
                jobs = deepcopy(order[pl.order])
                for job ∈ jobs
                    job.item = item
                end
                p = Product(pl.code, item, pl.name, pl.description,
                            pl.order, jobs, 0, OPEN, 0.0, 0.0)
                push!(mps, p)
            end
        end
    end
    mps
end

"""
    scheduler(sim::Simulation, wus::Workunits)

Cycle through all work units in `wus`, look for finished jobs (in `wu.output`)
and move them to the next free work unit.
"""
function scheduler(sim::Simulation, wus::Workunits)
    global sched
    while true
        for wu ∈ values(wus)
            while !isempty(wu.output)                  # look for ready products
                p = front(wu.output)                   # get first product
                if p.pjob < length(p.jobs)             # are there yet open jobs?
                    job = p.jobs[p.pjob+1]
                    nextw = ""
                    len = 1e6
                    for target ∈ job.wus               # look for possible targets
                        if !isfull(wus[target].input)  # get shortest input queue
                            if length(wus[target].input) < len
                                len = length(wus[target].input)
                                nextw = target
                            end
                        end
                    end
                    if nextw ≠ ""                      # found something
                        p = dequeue!(wu.output)
                        enqueue!(wus[nextw].input, p)
                        p.pjob += 1                    # set pointer to next job
                        p.jobs[p.pjob].wu = nextw      # trace workunit
                    else
                        break                          # cannot process further
                    end # if nextw
                else                                   # product has no open jobs
                    p = dequeue!(wu.output)
                    p.status = FINISHED
                    enqueue!(wus["OUT"].input, p)
                end
            end # if !isempty
        end # for wu
        yield(Release(sched))
    end # while true
end # function


"""
    source(sim::Simulation, wu::Workunit, mps::Products)

release products into a production system

# Arguments
- `sim::Simulation`: Simulation variable
- `wu::Workunit`: first workunit in `wus::Array{Workunit, 1}` which the
                  scheduler gets for operation. Here only `wu.output` is used.
- `mps::Products`: the products generated by `create_mps`
"""
function source(sim::Simulation, wu::Workunit, mps::Products)
    while length(mps) > 0
        p = shift!(mps)
        p.start_time = now(sim)
        enqueue!(wu.output, p)
        call_scheduler()
    end
end


"""
    sink(sim::Simulation, wu::Workunit, output::Products)

collect finished products from a production system

# Arguments
- `sim::Simulation`: Simulation variable
- `wu::Workunit`: **last** workunit in `wus::Workunits` which the
                  scheduler gets for operation. Here only `wu.input` is used.
- `output::Products`: the finished products, normally empty when
                      calling this procedure
"""
function sink(sim::Simulation, wu::Workunit, output::Products)
    while true
        p = dequeue!(wu.input)
        p.end_time = now(sim)
        push!(output, p)
    end
end

"""
    start_scheduling(sim::Simulation, wus::Workunits, mps::Products, output::Products)

get the MPS and a production system and start source, sink and scheduling
"""
function start_scheduling(sim::Simulation, wus::Workunits, mps::Products, output::Products)
    global sched = Resource(sim, 1)
    w1 = Workunit("IN", "Input", STORE,
                  PFQueue("DUMMY", Resource(sim, 1), Queue(Product), Array{PFlog{Int}, 1}[]),
                  PFQueue("DUMMY", Resource(sim, 1), Queue(Product), Array{PFlog{Int}, 1}[]),
                  PFQueue("INPUT", Resource(sim, 10), Queue(Product), Array{PFlog{Int}, 1}[]),
                  1000, 0, 0, 0, 0.0, Array{PFlog{Int}, 1}[])
    wus["IN"] = w1
    @process source(sim, w1, mps)
    w2 = Workunit("OUT", "Output", STORE,
                PFQueue("OUTPUT", Resource(sim, 10), Queue(Product), Array{PFlog{Int}, 1}[]),
                PFQueue("DUMMY", Resource(sim, 1), Queue(Product), Array{PFlog{Int}, 1}[]),
                PFQueue("DUMMY", Resource(sim, 10), Queue(Product), Array{PFlog{Int}, 1}[]),
                1000, 0, 0, 0, 0.0, Array{PFlog{Int}, 1}[])
    wus["OUT"] = w2
    @process sink(sim, w2, output)
    @process scheduler(sim, wus)
end


"""
    call_scheduler()

call the scheduler
"""
function call_scheduler()
    global sched
    yield(Request(sched))
end
