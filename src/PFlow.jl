# --------------------------------------------
# Main module for PFlow.jl,
# a Julia simulator for production systems and projects
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

module PFlow

using PyPlot, PyCall
@pyimport matplotlib.patches as patch
@pyimport matplotlib.lines as mlines
using LightGraphs

import DataStructures
import Base: now
import DataStructures: PriorityQueue, peek
import Distributions: Erlang, Exponential
import DataFrames: DataFrame, rename!, readtable, nrow, isna

export Event, DES, delayuntil, delay, interrupttask, SimException,
       now, register, simulate
export work, workunit, machine, worker, transport
export IDLE, WORKING, FAILURE, BLOCKED, OPEN, PROGRESS, DONE,
       Workunit, Workunits, Job, Product, Planned, Plan, Orders, Products
export Mps, create_mps, scheduler, source, sink, start_scheduling
export readWorkunits, readOrders
export wulog, productlog, queuelog, loadtable, leadtimetable
export loadtime, loadstep, loadbars, flow, leadtime, queuelen
export ordergraph, flowgraph

include("sim.jl")
include("entities.jl")
include("activities.jl")
include("eval.jl")
include("viz.jl")
include("io.jl")
include("schedule.jl")
include("graphs.jl")

end
