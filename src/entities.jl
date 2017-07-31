# --------------------------------------------
# this file is part of PFlow.jl
# it implements the data structures
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# date: 2017-07-29
# --------------------------------------------
# license: MIT
# --------------------------------------------

mutable struct PFQueue
  name::AbstractString
  res::Resource
  queue::Queue
end

mutable struct transaction
  name::AbstractString
  res::Resource
  input::PFQueue
  output::PFQueue
  status::AbstractString
end
