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
    enqueue!(pq::PFQueue, p::Product)

put p into the pq.queue channel. If isfull(pq) wait.
"""
function enqueue!(pq::PFQueue, p::Product)
    put!(pq.queue, p)
    l = PFlog(pq.env.time, length(pq)) # log queue length
    push!(pq.log, l)
    pq.env.index +=1 # increase simulation index
end

"""
    dequeue!(pq::PFQueue)
wait for something in the queue, remove it from its front and return it.
"""
function dequeue!(pq::PFQueue) :: Product
    p = take!(pq.queue)
    l = PFlog(pq.env.time, length(pq)) # log queue length
    push!(pq.log, l)
    pq.env.index +=1 # increase simulation index
    p
end
