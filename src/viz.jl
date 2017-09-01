# --------------------------------------------
# this file is part of PFlow.jl
# it implements the visualization routines
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    load(wus::Workunits, w::Array{String, 1}=[])

draw a load step diagram of the work units
"""
function loadstep(wus::Workunits, w::Array{String,1})
    if length(w) == 0
        w = collect(keys(wus))
    end
    sort!(w)
    for i ∈ 1:length(w)
        wu = wus[w[i]]
        if length(wu.log) > 0
            t, s = wulog(wu)
            step(t, s, where="post", label=wu.name, lw=1)
        end
    end
    legend()
    xlabel("time")
    ylabel("status")
    title("Workload")
end

loadstep(wus::Workunits, w::String) = load(wus, [w])
loadstep(wus::Workunits) = load(wus, String[])

"""
    load(wus::Workunits, w::Array{String, 1}=[])

draw a load diagram of the work units over time
"""
function load(wus::Workunits, w::Array{String,1})
end

load(wus::Workunits, w::String) = load(wus, [w])
load(wus::Workunits) = load(wus, String[])

function flow()
end

function lead_time()
end

function queue_len()
end
