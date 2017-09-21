# --------------------------------------------
# this file is part of PFlow.jl
# it implements the queueing
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

isfull(pq::PFQueue) = length(pq.queue.data) >= pq.queue.sz_max

isempty(pq::PFQueue) = length(pq.queue.data) == 0

capacity(pq::PFQueue) = pq.queue.sz_max

length(pq::PFQueue) = length(pq.queue.data)

front(pq::PFQueue) = pq.queue.data[1]

back(pq::PFQueue) = pq.queue.data[end]

"""
    enqueue!(pq::PFQueue, p::Product, time::Float64=pq.env.time)::Float64

put p into the pq.queue channel. If isfull(pq) wait.

# Arguments
- `pq::PFQueue`: buffer to which enqueue to
- `p::Product`: product to enqueue
- `time::Float64=pq.res.time`: time, at which a non-waiting enqueue occurs

# returns
- `time`: time at which the enqueueing takes place

# exception handling
Exceptions must be handled by the caller. In case of an exception the receiver
(dequeue!) gets an `ErrorException` and can take the missing product from pq.backup.
"""
function enqueue!(pq::PFQueue, p::Product, time::Float64=pq.env.time)::Float64
    if isready(pq.queue)
        pq.backup = fetch(pq.queue)
    else
        pq.backup = p
    end
    pq.time = max(time, pq.time)
    put!(pq.queue, p)
    pq.time = max(time, pq.time)
    l = PFlog(pq.time, length(pq)) # log queue length
    push!(pq.log, l)
    pq.env.index +=1 # increase simulation index
    return pq.time
end

"""
    dequeue!(pq::PFQueue, time::Float64=pq.env.time)

wait for something in the queue, remove it from its front and return it.

# Arguments
- `pq::PFQueue`: buffer from which to dequeue
- `time::Float64=pq.res.time`: time, at which a non-waiting dequeue occurs

# returns
(p, time)
- `p::Product`: dequeued product
- `pq.time`: time at which the dequeueing takes place

# exception handling
- `SimException`: deliver pq.backup from `enqueue!` with the propagated exception.
- `ErrorException`: if a pq.backup is present, deliver it, else propagate.
"""
function dequeue!(pq::PFQueue, time::Float64=pq.env.time)
    try
        p = take!(pq.queue)
        pq.time = max(pq.time, time)
        l = PFlog(pq.time, length(pq)) # log queue length
        push!(pq.log, l)
        pq.env.index +=1 # increase simulation index
        pq.backup = nothing
        return (p, pq.time)
    catch ex
        #println("dequeue at time:$(round(time, 2)), ex:$ex")
        if isa(ex, SimException)
            p = nothing
            if pq.backup != nothing
                p = pq.backup
                pq.time = max(ex.time, pq.time, time)
                l = PFlog(pq.time, length(pq)) # log queue length
                push!(pq.log, l)
                pq.env.index +=1 # increase simulation index
            end
            throw(SimException(ex.cause, pq.time, p))
        elseif isa(ex, ErrorException)
            if pq.backup != nothing
                pq.time = max(pq.time, time)
                l = PFlog(pq.time, length(pq)) # log queue length
                push!(pq.log, l)
                pq.env.index +=1 # increase simulation index
                return (pq.backup, pq.time)
            else
                rethrow(ex)
            end
        else
            rethrow(ex)
        end
    end
end
