# --------------------------------------------
# this file is part of PFlow.jl
# it implements the data structures
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# date: 2017-07-29
# --------------------------------------------
# license: MIT
# --------------------------------------------

const IDLE = 0
const WORKING = 1
const FAILURE = 2
const BLOCKED = 3

const OPEN = 0
const PROGRESS = 1
const DONE = 2

mutable struct PFQueue
  name::AbstractString
  res::Resource
  queue::Queue
end

mutable struct Station
  name::AbstractString
  task::Process
  res::Resource
  jobs::PFQueue
  input::PFQueue
  output::PFQueue
  status::Int64
  alpha::Int64               # Erlang scale parameter
end

mutable struct Job
  name::AbstractString
  station::Station
  op_time::Real
  status::Int64
  batch_size::Int64
  target::AbstractString     # name of target for transport jobs
end

mutable struct Order
  name::AbstractString
  seq::OrderedDict{AbstractString, Job}
end
