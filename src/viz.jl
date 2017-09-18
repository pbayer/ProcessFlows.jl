# --------------------------------------------
# this file is part of PFlow.jl
# it implements the visualization routines
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    loadstep(wus::Workunits, w::Array{String, 1}=[])

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
loadstep(wus::Workunits) = loadstep(wus, String[])

"""
    loadtime(wus::Workunits, w::Array{String, 1}=[])

draw a load diagram of the work units over time
"""
function loadtime(wus::Workunits, w::Array{String,1})
    if length(w) == 0
        w = collect(keys(wus))
    end
    w = [i for i ∈ w if length(wus[i].log) > 0]
    sort!(w)
    colors = ("green", "red", "yellow")
    p1 = patch.Patch(color="green", label="working")
    p2 = patch.Patch(color="yellow", label="blocked")
    p3 = patch.Patch(color="red", label="failure")
    for i ∈ 1:length(w)
        wu = wus[w[i]]
        t, s = wulog(wu)
        bars = [(t[j], t[j+1]-t[j]) for j ∈ 1:(length(s)-1) if s[j] > 0]
        st = [s[j] for j ∈ 1:(length(s)-1) if s[j] > 0]
        col = [colors[j] for j ∈ st]
        broken_barh(bars, (i-0.4, 0.8), facecolors=col)
    end
    xlabel("time")
    yticks(1:length(w), w)
    (y1, y2) = ylim()
    ylim(0, y2)
    title("Workload")
    legend(loc=4, handles=[p1, p2, p3], ncol=3)
    grid(true)
end

loadtime(wus::Workunits, w::String) = loadtime(wus, [w])
loadtime(wus::Workunits) = loadtime(wus, String[])

"""
    loadbars(wus::Workunits, w::Array{String,1}, duration::Number=1)

draw a bar diagram of the workload

# Arguments
- `wus::Workunits`: work units
- `w::Array{String,1}`: name of work units to be shown
- `duration::Number=1`: if ≠ 1, ratios are shown
"""
function loadbars(wus::Workunits, w::Array{String,1}, duration::Number=1)
    t = loadtable(wus, duration)
    ind = 1:nrow(t)
    width = 0.4
    bar(ind, t[:working], width, color="green", label="working")
    bar(ind, t[:blocked], width, color="yellow", bottom=t[:working], label="blocked")
    bar(ind, t[:failure], width, color="red", bottom=t[:working]+t[:blocked], label="failure")
    title("Workload")
    xticks(ind, t[:workunit])
    legend(loc=9, ncol=3)
    grid(axis="y",ls=":")
end

loadbars(wus::Workunits, w::String, duration::Number=1) = loadbars(wus, [w], duration)
loadbars(wus::Workunits, duration::Number=1) = loadbars(wus, String[], duration)

"""
    flow(pr::Products, relative::Bool=false)

plot the flow of products through work units over time.

# Arguments
- `pr::Products`: list of Products
- `relative::Bool`: if `true`, the flow is plotted over leadtime
"""
function flow(pr::Products, wus::Workunits, relative::Bool=false)
    lt = leadtimetable(pr)
    ord = collect(Set(lt[:order]))            # prepare color codes for orders
    sort!(ord)
    colors = ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd",
              "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22", "#17becf"]
    lines = []
    cord = Dict()
    for (i, o) ∈ enumerate(ord)
        col = colors[mod(i, length(colors))]
        push!(lines, mlines.Line2D([], [], color=col, label=o))
        cord[o] = col
    end

    w = collect(keys(wus))                    # prepare indices for work units
    w = [i for i ∈ w if length(wus[i].log) > 0]
    sort!(w, rev=true)
    unshift!(w, "OUT")
    push!(w, "IN")
    wusi = Dict()
    for i ∈ 1:length(w)
        wusi[w[i]] = i
    end

    for p ∈ pr
        start = relative ? p.start_time : 0
        wu = Int[]
        t = Float64[]
        push!(t, p.start_time - start)
        push!(wu, wusi["IN"])
        for j ∈ p.jobs
            push!(t, j.start_time - start)
            push!(t, j.end_time - start)
            push!(wu, wusi[j.wu])
            push!(wu, wusi[j.wu])
        end
        push!(t, p.end_time - start)
        push!(wu, wusi["OUT"])

        plot(t, wu, color=cord[p.order], lw=1)
    end
    xlabel(relative ? "leadtime" : "time")
    yticks(1:length(w), w)
    title("Flow diagram " * (relative ? "(relative)" : "(absolute)"))
    legend(loc=1, handles=lines)
    grid(ls=":")
end

"""
    leadtime(pr::Products)

plot the leadtimes over the index of the products sorted by orders
"""
function leadtime(pr::Products)
    lt = leadtimetable(pr)
    ind = 1:nrow(lt)
    ord = Set(lt[:order])
    for o ∈ ord
        acc = lt[:order] .== o
        plot(ind[acc], lt[:leadtime][acc], label=o)
    end
    xlabel("index")
    ylabel("time")
    title("Leadtime")
    grid(ls=":")
    legend(loc=4)
end

function queuelen()
end
