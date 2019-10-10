println("===== Testing DiscreteEvent.jl =====")

using Test, DiscreteEvent, Random

println("... testing Buffer.jl ...")
include("test_Buffer.jl")
println("... testing Jobs.jl ...")
include("test_Jobs.jl")
println("... testing Clock.jl ...")
include("test_Clock.jl")
println("... testing Flow.jl ...")
include("test_Flow.jl")
println("... testing Factory.jl ...")
include("test_Factory.jl")
#println("... testing Server.jl ...")
#include("test_Server.jl")
#println("... testing Transport.jl ...")
#include("test_Transport.jl")
#println("... testing Scheduler.jl ...")
#include("test_Scheduler.jl")
#println("... testing Logging.jl ...")
#include("test_Logging.jl")

#println("... testing interaction ...")
