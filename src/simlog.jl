using SimJulia
using DataFrames

"""
    SimLog(vars::Dict{AbstractString, Any}, measurements::Dict{AbstractString, Any})

create, initialize and return a new SimLog containing
access to variables and to measurements taken during simulation
"""
mutable struct SimLog
  vars::Any
  measurements::Any
end


"""
    logvar(name::AbstractString, value::Any)

create, initialize and return a new logging variable
"""
mutable struct logvar
  name::AbstractString
  value::Any
end


"""
    newlog()

create and return a new empty `SimLog`
"""
function newlog()
  SimLog(Dict(), Dict())
end

"""
    add2log(simlog, vars...)

add several `logvar` variables to a `SimLog`
and initialize the `measurements` Dict
"""
function add2log(simlog, vars...)
  if !haskey(simlog.measurements, " time")
    simlog.measurements[" time"] = []
  end
  for v in vars
    simlog.vars[v.name] = v
    simlog.measurements[v.name] = []
  end
end

"""
    lognow(sim::Simulation, simlog)

take actual "measurements" of all registered `logvar` variables
and add them to the `simlog.measurements` dictionary entries.
"""
function lognow(sim::Simulation, simlog)
  push!(simlog.measurements[" time"], now(sim))
  for v in keys(simlog.vars)
    push!(simlog.measurements[v], simlog.vars[v].value)
  end
end

"""
    logtick(sim::Simulation, simlog, tick)

log `logvar` variables registered in `simlog` every `tick`
simulation units. You have to start this as a process with
`@process logtick(sim, simlog, tick)`
"""
function logtick(sim::Simulation, simlog, tick)
  lognow(sim, simlog)
  while true
    yield(Timeout(sim, tick))
    lognow(sim, simlog)
  end
end

"""
vals(D::Dict)
auxiliary function: returns a Dict with values Int or Float or of String
"""
function vals(D::Dict)
  for i in keys(D)
    D[i] = try
      Int.(D[i])
    catch
      try
        float.(D[i])
      catch
        string.(D[i])
      end
    end
  end
  D
end

"""
    log2df(simlog)

transform the `SimLog` to a DataFrame and return it.
"""
function log2df(simlog)

  df = DataFrame(vals(simlog.measurements))
  rename!(df, Dict(Symbol(" time")=>:time))
end
