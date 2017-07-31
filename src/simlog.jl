# --------------------------------------------
# this file is part of PFlow.jl (could be included into SimJulia)
# it implements the logging
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# date: 2017-07-29
# --------------------------------------------
# license: MIT
# --------------------------------------------


"""
    SimLog(vars::Dict{AbstractString, Any}, measurements::Dict{AbstractString, Any})

create, initialize and return a new SimLog containing
access to variables and to measurements taken during simulation
"""
mutable struct SimLog
  vars
  redict
  prefix
  measurements
end


"""
    logvar(name::AbstractString, value::Union{AbstractString,Number})

create, initialize and return a new logging variable
"""
mutable struct logvar
  name::AbstractString
  value::Union{AbstractString,Number}
end


"""
    newlog()

create and return a new empty `SimLog`
"""
function newlog()
  SimLog(Dict(), Dict(), Dict(), Dict())
end

"""
    logvar2log(simlog, vars...)

add one or several `logvar` variables to a `SimLog`
and initialize the `measurements` Dict
"""
function logvar2log(simlog, vars...)
  if !haskey(simlog.measurements, " time")
    simlog.measurements[" time"] = []
  end
  for v in vars
    simlog.vars[v.name] = v
    simlog.measurements[v.name] = []
  end
end

"""
    dict2log(simlog, dicts...; prefix::AbstractString="", redict=Dict())

add the elements of one or several `Dicts` to a `Simlog`
and initialise the `measurements` Dict

# Arguments
- `simlog`: the log, the dict elements get added to
- `dict`: the dict, whose elements get added
- ''
- `prefix`: a string which gets prefixed to all logged keys
- `redict`: a dict containing renamings for dictionary keys,
  e.g. Dict(1=>"A", 2=>"B")

"""
function dict2log(simlog, dict; prefix::AbstractString="", redict=Dict())
  name = string(hash(dict))
  if !haskey(simlog.measurements, " time")
    simlog.measurements[" time"] = []
  end
  simlog.vars[name] = dict
  simlog.prefix[name] = prefix
  simlog.redict[name] = redict
  for k in keys(dict)
    n = haskey(redict, k) ? redict[k] : k
    n = prefix*string(n)
    simlog.measurements[n] = []
  end
end


"""
    lognow(sim::Simulation, simlog)

take actual "measurements" of all registered `logvar` variables
and add them to the `simlog.measurements` dictionary entries.
"""
function lognow(sim::Simulation, simlog)
  push!(simlog.measurements[" time"], now(sim))
  for v in keys(simlog.vars)                          # check all simlog vars
    if typeof(simlog.vars[v]) == logvar                       # is it a logvar?
      push!(simlog.measurements[v], simlog.vars[v].value)
    elseif typeof(try haskey(simlog.vars[v], 0) end) == Bool  # is it a dict?
      for k in keys(simlog.vars[v])
        n = haskey(simlog.redict[v], k) ? simlog.redict[v][k] : k
        n = simlog.prefix[v]*string(n)
        push!(simlog.measurements[n], simlog.vars[v][k])
      end
    else
      return
    end
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
