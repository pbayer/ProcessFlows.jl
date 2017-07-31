# --------------------------------------------
# this file is part of PFlow.jl
# it implements the queuing
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# date: 2017-07-29
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    isempty(q::Queue)::Bool

check, if a Queue is empty
"""
function isempty(q::Queue)::Bool
  isempty(q.queue)
end

"""
    isfull(q::Queue)::Bool

check, if a Queue is full
"""
function isfull(q::Queue)::Bool
  length(q.queue) ≥ q.res.capacity
end

"""
    length(q::Queue)::Int64

get the number of elements in Queue
"""
function length(q::Queue)
  length(q.queue)
end

"""
    pop!(q::Queue, item::Any)

remove an element from the back
"""
function pop!(q::Queue, item::Any)
  pop!(q.queue, item)
  Release(q.res)
end

"""
    unshift!(q::Queue, item::Any)

add an element to the front
"""
function unshift!(q::Queue, item::Any)
  if !isfull(q)
    unshift!(q.queue, item)
  else
    error("Queue is full")
  end
end

"""
    front(q::Queue)

get the element at the front
"""
function front(q::Queue)
  front(q.queue)
end

"""
    back(q::Queue)
get the element at the back
"""
function back(q::Queue)
  back(q.queue)
end
