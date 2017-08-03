"""
Main module for PFlow.jl, a Julia simulator for production systems and projects
"""
module PFlow

using SimJulia

import DataStructures
import Base: length, isempty, start, next, done
import DataStructures: Queue, OrderedDict
import Distributions: Erlang, Exponential
import DataFrames: DataFrame, rename!

export work, schedule_failure, machine, worker, transport, inspector, store
export IDLE, WORKING, FAILURE, BLOCKED, OPEN, PROGRESS, DONE,
       PFQueue, Workunit, Job, Order
export isempty, isfull, length, capacity, front, back, enqueue!,
       dequeue!, start, next, done
export newlog, Simlog, Logvar, logvar2log, dict2log, lognow, logtick, log2df

include("simlog.jl")
include("entities.jl")
include("queues.jl")
include("activities.jl")
#include("schedule.jl")


end
