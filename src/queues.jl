# --------------------------------------------
# this file is part of PFlow.jl
# it implements the queuing
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# date: 2017-07-29
# --------------------------------------------
# license: MIT
# --------------------------------------------

isempty(q::PFQueue) = isempty(q.queue)

"""
    isfull(q::PFQueue)

check, if a PFQueue is full
"""
function isfull(q::PFQueue)
  return length(q.queue) ≥ q.res.capacity
end

"""
    capacity(q::PFQueue)

return the maximum length of a PFQueue
"""
function capacity(q::PFQueue)
  return q.res.capacity
end

length(q::PFQueue) = length(q.queue)

front(q::PFQueue) = front(q.queue)
back(q::PFQueue) = back(q.queue)

"""
    enqueue!(q::PFQueue, x)

enqueue x at the end of q.queue and return q.queue
"""
function enqueue!(q::PFQueue, x)
  isfull(q) && throw(ArgumentError("PFQueue must not be full"))
  enqueue!(q.queue, x)
end

"""
    dequeue!(q::PFQueue)
Removes an element from the front of the queue `s` and returns it.
"""
dequeue!(q::PFQueue) = dequeue!(q.queue)

# Iterators

start(q::PFQueue) = start(q.queue)
next(q::PFQueue, x) = next(q.queue, x)
done(q::PFQueue, x) = done(q.queue, x)
