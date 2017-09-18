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
"""
function enqueue!(pq::PFQueue, p::Product, time::Float64=pq.env.time)::Float64
    put!(pq.queue, p)
    pq.time = max(time, pq.time)
    l = PFlog(pq.time, length(pq)) # log queue length
    push!(pq.log, l)
    pq.env.index +=1 # increase simulation index
    pq.time
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
"""
function dequeue!(pq::PFQueue, time::Float64=pq.env.time)
    p = take!(pq.queue)
    pq.time = max(pq.time, time)
    l = PFlog(pq.time, length(pq)) # log queue length
    push!(pq.log, l)
    pq.env.index +=1 # increase simulation index
    (p, pq.time)
end
