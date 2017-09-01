"""
Main module for PFlow.jl, a Julia simulator for production systems and projects
"""
module PFlow

using SimJulia, Plots

import DataStructures
import Base: length, isempty, start, next, done
import DataStructures: Queue, OrderedDict
import Distributions: Erlang, Exponential
import DataFrames: DataFrame, rename!, readtable, nrow, isna

export work, workunit, machine, worker, transport
export IDLE, WORKING, FAILURE, BLOCKED, OPEN, PROGRESS, DONE,
       PFQueue, Workunit, Job, Product, Planned
export Mps, Plan, Orders, Products,
       create_mps, scheduler, source, sink, start_scheduling
export readWorkunits, readOrders
export isempty, isfull, length, capacity, front, back, enqueue!,
       dequeue!, start, next, done
export mload

include("entities.jl")
include("queues.jl")
include("activities.jl")
include("viz.jl")
include("io.jl")
include("schedule.jl")

end
