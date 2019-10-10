#
# state machine for an abstract server
#

"""
    Server(name::AbstractString;
            inbuf::Int64=1, outbuf::Int64=1,
            op_var::Union{Number, Expr}=1,
            tbf::Union{Number, Expr}=0, ttr::Union{Number, Expr}=0)

Create an abstract server (the record of a state machine).

# Arguments
- `name::AbstractString`: name
- `inbuf::Int64`: input buffer capacity (must be ≥ 1)
- `outbuf::Int64`: output buffer capacity (must be ≥ 1)
- `op_var::Union{Number, Expr}`: variation factor to operation times (default: 1)
- `tbf::Union{Number, Expr}`: time between failures (default Inf, no failures)
- `ttr::Union{Number, Expr}`: time to repair (default 0)
"""
mutable struct Server <: StateMachine
    name::AbstractString
    sim::Union{Clock, Factory, Number}
    state::State
    input::FIFOBuffer
    "tuple of job and job duration"
    work::Any
    output::FIFOBuffer
    "simulation time at beginning of current state"
    time::Float64
    "scheduled simulation time of next event"
    next::Float64
    "time between failures: number or expression provided by user"
    tbf::Union{Number, Expr}
    "time to repair: number or expression provided by user"
    ttr::Union{Number, Expr}
    "remaining operation time for current job"
    op_time::Float64
    "factor to job duration: number or expression provided by user"
    op_var::Union{Number, Expr}

    function Server(name::AbstractString;
                    inbuf::Int64=1, outbuf::Int64=1,
                    op_var::Union{Number, Expr}=1,
                    tbf::Union{Number, Expr}=Inf, ttr::Union{Number, Expr}=0)
        new(name, 0, Undefined(),
            FIFOBuffer(name*".input", inbuf), Nothing,
            FIFOBuffer(name*".output", outbuf),
            0.0, 0.0, tbf, ttr, 0.0, op_var)
    end
end

"return current simulation time"
now(s::Server) = now(s.sim)

"schedule next server failure"
function schedule_failure(s::Server)
    ttr = Core.eval(Main, s.ttr)
    tbf = Core.eval(Main, s.tbf)
    if tbf != Inf
        @assert tbf > 0 "tbf is not > 0"
        @assert ttf > 0 "ttr is not > 0"
        event!(s.fab.sim, :(step!($s, :Fail($ttr))), now(s) + tbf)
    end
end

"Server start"
step!(s::Server, ::Undefined, ::Start) = schedule_failure(s)

"A job enters the input buffer of a server."
function step!(s::Server, ::State, σ::Enter)
    @assert !full(s.input) "$s.name input buffer is full!"
    enqueue!(s.input, σ.job)
    if s.state == Idle()
        step(s, Load())
    end
end

"a server loads a job into his processing unit and begins to work"
function step!(s::Server, ::Idle, ::Load)
    if !isempty(s.input)
        wfull = isfull(s.input)
        s.work = dequeue!(s.input)
        s.state = Busy()
        s.time = now(s)
        s.op_time = s.work.duration * Core.eval(Main, s.op_var)  # set op_time
        s.next = event!(s.fab.sim, :(step!($s, Finish())), s.time + s.op_time)
        wfull ? step!(s.sim, Call(s, Load())) : return
    end
end

"a server finishes processing a job"
function step!(s::Server, ::Busy, ::Finish)
    s.op_time = 0.0
    step!(s, Unload())
end

"a server unloads a finished job into its output buffer"
function step!(s::Server, ::Union{Busy,Blocked}, σ::Unload)
    if isfull(s.output)
        s.state = Blocked()
    else
        enqueue!(s.output, s.work)
        s.work = Nothing
        s.state = Idle()
        call!(s.sim, s, σ)
        step!(s, Load())
    end
end

"A server removes a processed job from its output and returns it."
function step!(s::Server, ::State, ::Get)
    job = dequeue!(s.output)
    if s.state == Blocked()
        step!(s, Unload())
    end
    return job
end

"a busy server fails"
function step!(s::Server, ::Busy, σ::Fail)
    delete!(sim.events, s.next)             # delete scheduled finish event
    s.op_time -= now(s) - s.time    # save remaining op_time
    s.state = Failed()
    s.next = event!(s.fab.sim, :(step!($s, Repair())), now(s) + σ.ttr)
end

"""
    step!(s::Server, ::Failed, σ::Fail)

a failed server gets another failure.

If the new repairtime exceeds the remaining repairtime of the previous failure,
delete the scheduled Repair event and schedule a new one.
"""
function step!(s::Server, ::Failed, σ::Fail)
    if now(s.fab) + σ.ttr > s.next
        delete!(s.fab.sim.events, s.next)
        s.next = event!(s.fab.sim, :(step!($s, Repair())), now(s) + σ.ttr)
    end
end

"an idle or blocked server fails"
function step!(s::Server, ::Union{Idle, Blocked}, σ::Fail)
    s.state = Failed()
    s.next = event!(s.fab.sim, :(step!($s, Repair())), now(s) + σ.ttr)
end

"a failed server got repaired"
function step!(s::Server, ::Failed, ::Repair)        # Repair event
    schedule_failure()
    if s.work != Nothing
        if s.op_time > 0
            s.state = Busy()            # finish work
            s.time = s.fab.sim.time
            s.next = event!(s.fab.sim, :(step!($s, Finish())), s.time + s.op_time)
        else
            s.state = Blocked()         # set to Blocked and
            step!(s, Unload())  # try to unload
        end
    else
        s.state = Idle()
        step!(s, Load())        # try to load
    end
end

"Checks if a server is available to receive a job to its input buffer"
available(A::Server) =
    !(typeof(A.state) ∈ (Undefined, Fail, Setup)) & !isfull(A.input)

"Checks if a server is waiting for a job."
iswaiting(s::Server) = s.state == Idle()

"Return the number of items waiting or in process, -1 if server is not available"
function queue(s::Server)
    q = length(s.input.queue)
    p = s.work != Nothing ? 1 : 0
    return available(s) ? p + q : -1
end

"return lowest priority job in `A.output` or Nothing if empty."
get(A::Server) = isempty(A.output) ? Nothing : peek(A.output)[1]
