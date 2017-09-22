# --------------------------------------------
# this file is part of PFlow.jl
# it implements the data structures
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

const IDLE = 0
const OPEN = 0
const WORKING = 1
const PROGRESS = 1
const FAILURE = 2
const BLOCKED = 3
const DONE = 4
const FINISHED = 5

mstatus = ("idle", "working", "failure", "blocked")

const MACHINE = 1
const WORKER = 2
const TRANSPORT = 3
const INSPECTOR = 4
const STORE = 5

"""
    function Job(item::Int, job::String, wus::Array{String,1}, plan_time::Float64;
                 batch_size::Int=1, target::String="")

create a job

# Parameters
- `item::Int`: which item the job belongs to
- `job::String`: name of the job
- `wus::Array{String,1}`: workunits capable to do the job
- `plan_time::Float64`: the planned execution time
- `batch_size::Int=1`: batch size
- `target::String=""`: name of target for transport jobs
"""
mutable struct Job
    item::Int                   # which item the job belongs to
    job::String                 # name of the job
    wus::Array{String,1}        # workunits capable to do the job
    plan_time::Float64          # the planned execution time
    op_time::Float64            # internal: the scheduled execution time
    completion::Float64         # internal: the job's completion rate
    status::Int                 # the job's status
    wu::String                  # on which workunit is the job done
    start_time::Float64         # when was it started
    end_time::Float64           # when was it finished
    batch_size::Int             # batch size
    target::String              # name of target for transport jobs

    function Job(item::Int, job::String, wus::Array{String,1}, plan_time::Float64;
                 batch_size::Int=1, target::String="")
        new(item, job, wus, plan_time, 0.0, 0.0, 0, "", 0.0, 0.0, batch_size, target)
    end
end

"""
    Orders   = Dict{String, Array{Job,1}}

The Orders dictionary contains orders, which are described by a sequence of jobs.
"""
Orders   = Dict{String, Array{Job,1}}

"""
    Product(code::Int, item::Int, name::String, description::String,
                 order::String, jobs::Array{Job,1})

create a product

# Parameters
- `code::Int`: product code
- `item::Int`: item number - this is unique !!
- `name::String`: product name
- `description::String`: descriptive string
- `order::String`: order name
- `jobs::Array{Job,1}`: sequence of jobs
"""
mutable struct Product
    code::Int                   # product code
    item::Int                   # item number - this must be unique !!
    name::String                # product name
    description::String         # descriptive string
    order::String               # order name
    jobs::Array{Job,1}          # sequence of jobs
    pjob::Int                   # pointer to job
    status::Int                 # processing status
    start_time::Float64         # when was it started
    end_time::Float64           # when was it finished

    function Product(code::Int, item::Int, name::String, description::String,
                     order::String, jobs::Array{Job,1})
        new(code, item, name, description, order, jobs, 0, OPEN, 0.0, 0.0)
    end
end

"""
    Products = Array{Product,1}

This is a list or sequence of products. It can also be seen and handled as a
queue with functions such as `push!` or `shift!`.
"""
Products = Array{Product,1}

"""
    Planned(code::Int, demand::Int, item_offset::Int, name::String,
        description::String, order::String)

create a demand for a product

# Parameters
- `code::Int`: product code
- `demand::Int`: how many products must be produced
- `item_offset::Int`: offset for item numbering
- `name::String`: product name
- `description::String`: descriptive string
- `order::String`: order name
"""
mutable struct Planned
    code::Int                   # product code
    demand::Int                 # how many products must be produced
    item_offset::Int            # offset for item numbering
    name::String                # product name
    description::String         # descriptive string
    order::String               # order name
end

"""
    Plan = Array{Planned, 1}

create a production plan, containing of demands for different products.
"""
Plan = Array{Planned, 1}

"""
    PFlog(time::Float64, status::Number)

create a logging entry containing simulation time and status to log.
"""
mutable struct PFlog{N<:Number}
    time::Float64
    status::N
end

"""
    PFQueue(name::String, env::DES, capacity::Int=1)

create a buffer of products (or other items), which can be used by simulation
tasks for coordination.

# Parameters
- `name::String`: name
- `env::DES`: simulation environment
- `capacity::Int=1`: buffer/channel capacity
"""
mutable struct PFQueue
    name::String                # name
    env::DES                    # simulation environment
    queue::Channel              # queue of products
    time::Float64               # time of last queueing event
    backup::Any                 # backup storage for reference to last product
    log::Array{PFlog{Int}, 1}   # log of queue lengths over simulation time

    function PFQueue(name::String, env::DES, capacity::Int=1)
        new(name, env, Channel(capacity), 0.0, nothing, PFlog{Int}[])
    end
end

"""
    Workunit(name::String, description::String, kind::Int,
        input::PFQueue, wip::Products, output::PFQueue,
        alpha::Int, mtbf::Number, mttr::Number, timeslice::Number)

create a datastructure of a work unit's main parameters

# Parameters
- `name::String`: name
- `description::String`: descriptive string
- `kind::Int`: type of workunit
- `input::PFQueue`: input queue
- `wip::Products`: internal work in progress queue
- `output::PFQueue`: output queue
- `alpha::Int`: Erlang scale parameter
- `mtbf::Number`: mean time between failures
- `mttr::Number`: mean time to repair
- `timeslice::Number`: length of timeslice for multitasking
"""
mutable struct Workunit
    name::String                # name
    description::String         # descriptive string
    kind::Int                   # type of workunit
    input::PFQueue              # input queue
    wip::Products               # internal work in progress queue
    output::PFQueue             # output queue
    alpha::Int                  # Erlang scale parameter
    mtbf::Number                # mean time between failures
    mttr::Number                # mean time to repair
    timeslice::Number           # length of timeslice for multitasking
    time::Float64               # internal time of the Workunit
    t0::Float64                 # internal: storage of last start time
    log::Array{PFlog{Int}, 1}   # log of the stati over simulation time

    function Workunit(name::String, description::String, kind::Int,
                      input::PFQueue, wip::Products, output::PFQueue,
                      alpha::Int, mtbf::Number, mttr::Number, timeslice::Number)
        new(name, description, kind, input, wip, output, alpha,
            mtbf, mttr, timeslice, 0, 0, PFlog{Int}[])
    end
end

"""
    Workunits = Dict{String, Workunit}

a dictionary of workunits
"""
Workunits = Dict{String, Workunit}
