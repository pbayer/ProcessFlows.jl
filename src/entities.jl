# --------------------------------------------
# this file is part of PFlow.jl
# it implements the data structures
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

const IDLE = 0
const WORKING = 1
const FAILURE = 2
const BLOCKED = 3

mstatus = ("idle", "working", "failure", "blocked")

const OPEN = 0
const PROGRESS = 1
const DONE = 2
const FINISHED = 2

const MACHINE = 0
const WORKER = 1
const TRANSPORT = 2
const INSPECTOR = 3
const STORE = 4

mutable struct PFQueue
    name::AbstractString        # name
    res::Resource               # sentinel
    queue::Queue                # queue of products
end

mutable struct Job
    item::Int                   # which item the job belongs to
    job::AbstractString         # name of the job
    wus::Array{String,1}        # workunits capable to do the job
    plan_time::Real             # the planned execution time
    op_time::Real               # internal: the scheduled execution time
    completion::Real            # internal: the job's completion rate
    status::Int                 # the job's status
    batch_size::Int             # batch size
    target::AbstractString      # name of target for transport jobs
end

mutable struct Workunit
    name::AbstractString        # name
    description::AbstractString # descriptive string
    kind::Int                   # type of workunit
    input::PFQueue              # input queue
    wip::PFQueue                # internal work in progress queue
    output::PFQueue             # output queue
    alpha::Int                  # Erlang scale parameter
    mtbf::Number                # mean time between failures
    mttr::Number                # mean time to repair
    timeslice::Number           # length of timeslice for multitasking
    t0::Real                    # internal: storage of last start time
end

mutable struct Product
    code::Int                   # product code
    item::Int                   # item number - this must be unique !!
    name::AbstractString        # product name
    description::AbstractString # descriptive string
    order::AbstractString       # order name
    jobs::Array{Job,1}          # sequence of jobs
    pjob::Int                   # pointer to job
    status::Int                 # processing status
end

mutable struct Planned
    code::Int                   # product code
    demand::Int                 # how many products must be produced
    item_offset::Int            # offset for item numbering
    name::AbstractString        # product name
    description::AbstractString # descriptive string
    order::AbstractString       # order name
end
