#
# implementation of jobs and operations
#


@enum WorkState planned active scheduled waiting inProgress done faulty

"""
    Op(type, duration::Number)

Create an operation.

# Arguments
- `type::Any`: planned server type on which the op will be processed
- `duration::Float64`: planned processing time
"""
mutable struct Op <: Work
    type::Any                       # planned server type, needed for scheduling
    duration::Float64               # planned duration for processing
    state::Int64                    # operation (Work) state
    server_name::AbstractString     # which server did the processing
    started::Float64                # start time
    finished::Float64               # finish time

    Op(type, duration::Number) = new(type, duration, Int(planned), "", 0, 0)
end

"""
    Job(name::AbstractString, id::Int64, op=Array{Op}[])

Create a job: a sequence of operations.

# Arguments
- `name::AbstractString`: name
- `id::Int64`: a (normally unique) identification number
- `op=Array{Op}[]`: a sequence of operations, must be set before scheduling
"""
mutable struct Job <: Work
    name::AbstractString            # job name
    id::Int64                       # job identification number
    state::Int64                    # job (Work) state
    duration::Float64               # duration of next operation
    started::Float64                # start time
    finished::Float64               # finish time
    ok::Bool                        # ok flag
    op::Array{Op}                   # sequence of operations
    index::Int64                    # index to current operation

    Job(name, id, op=Array{Op}[]) = new(name, id, 0, 0, 0, 0, false, op, 0)
end

"Set the state of a job or an operation."
function set!(w::Work, state::WorkState)
    w.state = Int(state)
end

"""
    nextOp!(job::Job, sim::Clock)::Op

Return the next operation of a job or Nothing if no operation is left.
Increment the job.index.

# Arguments
- `job::Job`: job
- `sim::Union{Clock,Factory}`: simulation variable
"""
function nextOp!(job::Job, sim::Union{Clock,Factory})
    job.index += 1
    if job.index == 1
        set!(job, inProgress)
        job.started = now(sim)
    elseif job.index > length(job.op)
        return Nothing
    else
    end
    set!(job.op[job.index], active)
    return job.op[job.index]
end

duration(job::Job) = job.op[job.index].duration

function finish!(job::Job, sim::Union{Clock,Factory})
    job.ok = all(i -> i == Int(done), [op.state for op ∈ job.op])
    set!(job, done)
    job.finished = now(sim)
end
