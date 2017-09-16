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

const MACHINE = 0
const WORKER = 1
const TRANSPORT = 2
const INSPECTOR = 3
const STORE = 4

mutable struct PFlog{N<:Number}
    time::Float64
    status::N
end

mutable struct PFQueue
    name::String                # name
    env::DES                    # simulation environment
    queue::Channel              # queue of products
    log::Array{PFlog{Int}, 1}   # log of queue lengths over simulation time

    function PFQueue(name::String, env::DES, capacity::Int=1)
        new(name, env, Channel(capacity), PFlog[])
    end
end

mutable struct Job
    item::Int                   # which item the job belongs to
    job::String                 # name of the job
    wus::Array{String,1}        # workunits capable to do the job
    plan_time::Float64             # the planned execution time
    op_time::Float64               # internal: the scheduled execution time
    completion::Float64            # internal: the job's completion rate
    status::Int                 # the job's status
    wu::String                  # on which workunit is the job done
    start_time::Float64            # when was it started
    end_time::Float64              # when was it finished
    batch_size::Int             # batch size
    target::String              # name of target for transport jobs

    function Job(item::Int, job::String, wus::Array{String,1}, plan_time::Float64;
                 batch_size::Int=1, target::String="")
        new(item, job, wus, plan_time, 0.0, 0.0, 0, "", 0.0, 0.0, batch_size, target)
    end
end

Orders   = Dict{String, Array{Job,1}}

mutable struct Product
    code::Int                   # product code
    item::Int                   # item number - this must be unique !!
    name::String                # product name
    description::String         # descriptive string
    order::String               # order name
    jobs::Array{Job,1}          # sequence of jobs
    pjob::Int                   # pointer to job
    status::Int                 # processing status
    start_time::Float64            # when was it started
    end_time::Float64              # when was it finished

    function Product(code::Int, item::Int, name::String, description::String,
                     order::String, jobs::Array{Job,1})
        new(code, item, name, description, order, jobs, 1, OPEN, 0.0, 0.0)
    end
end

Products = Array{Product,1}

mutable struct Planned
    code::Int                   # product code
    demand::Int                 # how many products must be produced
    item_offset::Int            # offset for item numbering
    name::String                # product name
    description::String         # descriptive string
    order::String               # order name
end

Plan = Array{Planned, 1}

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
end

Workunits = Dict{String, Workunit}
