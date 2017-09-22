# --------------------------------------------
# this file is part of PFlow.jl
# it implements the evaluation of results
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    wulog(wu::Workunit)

return time and status of a work unit log
"""
function wulog(wu::Workunit)
    time, status = Float64[], Int[]
    for l in wu.log
        push!(time, l.time)
        push!(status, l.status)
    end
    time, status
end

"""
    queuelog(wu::Workunit)

return time and status of a PFQueue log
"""
function queuelog(qu::PFQueue)
end

function productlog()
end

Base.sum(a::Array{Any, 1}) = 0

"""
    loadtable(wus::Workunits, duration::Number=0)

return a dataframe giving for each workunit the stati and their cumulative
duration. If `duration ≠ 1` ratios are calculated.
"""
function loadtable(wus::Workunits, duration::Number=1)
    w = collect(keys(wus))
    w = [i for i ∈ w if length(wus[i].log) > 0]
    sort!(w)
    d = Dict()
    d["d0"] = w
    d["d1"] = zeros(length(w))
    d["d2"] = zeros(length(w))
    d["d3"] = zeros(length(w))
    for i ∈ 1:length(w)
        wu = wus[w[i]]
        t, s = wulog(wu)
        Δt = diff(t)
        d["d1"][i] = sum([Δt[j] for j ∈ 1:length(Δt) if s[j] == 1]) / duration
        d["d2"][i] = sum([Δt[j] for j ∈ 1:length(Δt) if s[j] == 3]) / duration
        d["d3"][i] = sum([Δt[j] for j ∈ 1:length(Δt) if s[j] == 2]) / duration
    end
    df = DataFrame(d)
    rename!(df, Dict(:d0=>:workunit, :d1=>:working, :d2=>:blocked, :d3=>:failure))
end

"""
    leadtimetable(pr::Products)

return a dataframe, giving for each product the start_time, end_time and leadtime
"""
function leadtimetable(pr::Products)
    d = Dict()
    d["d1"] = [p.item for p ∈ pr]
    d["d2"] = [p.code for p ∈ pr]
    d["d3"] = [p.name for p ∈ pr]
    d["d4"] = [p.order for p ∈ pr]
    d["d5"] = [p.start_time for p ∈ pr]
    d["d6"] = [p.end_time for p ∈ pr]
    d["d7"] = d["d6"] - d["d5"]
    df = DataFrame(d)
    rename!(df, Dict(:d1=>:item, :d2=>:code, :d3=>:name, :d4=>:order,
                     :d5=>:starttime, :d6=>:endtime, :d7=>:leadtime))
end
