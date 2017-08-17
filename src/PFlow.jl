"""
Main module for PFlow.jl, a Julia simulator for production systems and projects
"""
module PFlow

using SimJulia, PyPlot

import DataStructures
import Base: length, isempty, start, next, done
import DataStructures: Queue, OrderedDict
import Distributions: Erlang, Exponential
import DataFrames: DataFrame, rename!, readtable, nrow, isna

export work, workunit, machine, worker, transport
export IDLE, WORKING, FAILURE, BLOCKED, OPEN, PROGRESS, DONE,
       PFQueue, Workunit, Job
export scheduler
export readWorkunits, readOrders
export isempty, isfull, length, capacity, front, back, enqueue!,
       dequeue!, start, next, done
export newlog, Simlog, Logvar, logvar2log, dict2log, lognow, logtick, log2df
export mload

include("simlog.jl")
include("entities.jl")
include("queues.jl")
include("activities.jl")
include("simviz.jl")
include("simio.jl")
include("schedule.jl")


end
