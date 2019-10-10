#
# implement a FIFO Buffer, which can be left under some condition
#

"""
    FIFOBuffer(name, capacity=1)

Create a new FIFOBuffer with a capacity 1 ≤ c ≤ Inf.
"""
mutable struct FIFOBuffer <: StateMachine
    name::AbstractString
    state::State
    capacity::Int64
    "internal FIFO counter"
    counter::Int64
    "queue of stored items, each wich a sequence number"
    queue::PriorityQueue

    function FIFOBuffer(name, capacity=1)
        @assert capacity ≥ 1 "$name buffer capacity must be ≥ 1"
        new(name, Empty(), capacity, 0, PriorityQueue())
    end
end

isfull(b::FIFOBuffer) = b.state == Full()
isempty(b::FIFOBuffer) = b.state == Empty()

"an item or job enters a FIFOBuffer"
function step!(b::FIFOBuffer, ::Union{Empty,Ready}, σ::Enter)
    @assert !isfull(b) "$(b.name) buffer is full"
    b.counter += 1
    DataStructures.enqueue!(b.queue, σ.job, b.counter)
    if length(b.queue) ≥ b.capacity
        b.state = Full()
    else
        b.state = Ready()
    end
    return b.counter
end

"the first item or job is taken from a FIFOBuffer."
function step!(b::FIFOBuffer, ::Union{Ready,Full}, ::Get)
    item = DataStructures.dequeue!(b.queue)
    if isempty(b.queue)
        b.state = Empty()
    else
        b.state = Ready()
    end
    return item
end

"an item or job leaves a FIFOBuffer prematurely."
function step!(b::FIFOBuffer, ::Union{Ready,Full}, σ::Leave)
    job = σ.job
    try
        job = σ.job.name
    catch
    end
    @assert haskey(b.queue, σ.job) "item $job is not in buffer $(b.name)"
    delete!(b.queue, σ.job)
    if isempty(b.queue)
        b.state = Empty()
    else
        b.state = Ready()
    end
end

"Enqueue an item into a FIFO buffer. Return a sequence number."
enqueue!(b::FIFOBuffer, job) = step!(b, b.state, Enter(job))

"take the first in item from a FIFO buffer and return it"
dequeue!(b::FIFOBuffer) = step!(b, b.state, Get())

"leave a buffer prematurely (e.g. if waiting time is too long)"
leave!(b::FIFOBuffer, job) = step!(b, b.state, Leave(job))

"initialization of FIFOBuffers does and returns Nothing"
step!(::FIFOBuffer, ::State, ::Init) = Nothing

"initialization of FIFOBuffers does and returns Nothing"
init!(::FIFOBuffer) = Nothing
