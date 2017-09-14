# --------------------------------------------
# Main module for PFlow.jl,
# a Julia simulator for production systems and projects
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

module PFlow

using SimJulia
using PyPlot, PyCall
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as mlines
using LightGraphs, GraphPlot

import DataStructures
import Base: length, isempty, start, next, done
import DataStructures: Queue, OrderedDict
import Distributions: Erlang, Exponential
import DataFrames: DataFrame, rename!, readtable, nrow, isna

export work, workunit, machine, worker, transport
export IDLE, WORKING, FAILURE, BLOCKED, OPEN, PROGRESS, DONE,
       PFQueue, Workunit, Job, Product, Planned, Plan, Orders, Products
export Mps, create_mps, scheduler, source, sink, start_scheduling
export readWorkunits, readOrders
export isempty, isfull, length, capacity, front, back, enqueue!,
       dequeue!, start, next, done
export wulog, productlog, queuelog, loadtable, leadtimetable
export loadtime, loadstep, loadbars, flow, leadtime, queuelen
export ordergraph, flowgraph

include("entities.jl")
include("queues.jl")
include("activities.jl")
include("eval.jl")
include("viz.jl")
include("io.jl")
include("schedule.jl")
include("graphs.jl")

end
