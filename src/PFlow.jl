"""
Main module for PFlow.jl, a Julia simulator for production systems and projects
"""
module PFlow

using SimJulia

import Base: length, isempty, start, next, done
import DataStructures: Queue, OrderedDict, front, back, enqueue!, dequeue!
import Distributions: Erlang, Exponential

export task
export PFQueue, isempty, isfull, length, capacity, front, back, enqueue!,
       dequeue!, start, next, done
export newlog, logvar, logvar2log, dict2log, lognow, logtick, log2df

include("activities.jl")
include("entities.jl")
include("queues.jl")
#include("schedule.jl")
include("simlog.jl")


end
