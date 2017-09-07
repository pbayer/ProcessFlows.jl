# --------------------------------------------
# this file is part of PFlow.jl
# it implements the graph functions
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    ordergraph(ord::Orders, os::Array{String,1})

build a Digraph from a PFlow Orders dict

# Parameters
- `ord::Orders`: Orders dict
- `os::Array{String,1}`: names of selected orders, if empty all orders are taken

# Returns
(G, edgenames, weights) where
- `G::SimpleDiGraph{Int64}`: graph structure
- `edgenames::Array{String,1}`: workunit names for vertices
- `weights::Array{Int64,1}`: number of orders using the edges
"""
function ordergraph(ord::Orders, os::Array{String,1})
    if length(os) == 0
        os = keys(ord)
    end

    wus = String[]              # create access to work units
    for o ∈ os
        for j ∈ ord[o]
            append!(wus, j.wus)
        end
    end
    wus = collect(Set(wus))
    sort!(wus)
    unshift!(wus, "IN")
    push!(wus, "OUT")
    wu = Dict()
    for (i, v) ∈ enumerate(wus)
        wu[v] = i
    end
    wg = Dict()

    G = DiGraph()
    add_vertices!(G, length(wus))
    for o ∈ os
        sources = [ 1 ]
        for j ∈ ord[o]
            for t ∈ j.wus
                for s ∈ sources
                    res = add_edge!(G, s, wu[t])
                    res ? wg[s*1000000+wu[t]] = 1 : wg[s*1000000+wu[t]] += 1
                end
            end
            sources = [wu[w] for w ∈ j.wus]
        end
        for s ∈ sources
            res = add_edge!(G, s, length(wus))
            res ? wg[s*1000000+length(wus)] = 1 : wg[s*1000000+length(wus)] += 1
        end
    end
    weight = [wg[src(e)*1000000+dst(e)] for e ∈ edges(G)]
    (G, wus, weight)
end

ordergraph(ord::Orders, o::String) = ordergraph(ord, [ o ])
ordergraph(ord::Orders) = ordergraph(ord, String[])

"""
    flowgraph(pr::Products)

return a Digraph built from a PFlow Products array
"""
function flowgraph(pr::Products)
    ws = String[]              # create access to work units
    for p ∈ pr
        for j ∈ p.jobs
            push!(ws, j.wu)
        end
    end
    ws = collect(Set(ws))
    sort!(ws)
    unshift!(ws, "IN")
    push!(ws, "OUT")
    wuno = Dict()
    for (i, v) ∈ enumerate(ws)
        wuno[v] = i
    end
    wg = Dict()

    G = DiGraph()
    add_vertices!(G, length(ws))
    for p ∈ pr
        src = 1
        for j ∈ p.jobs
            dst = wuno[j.wu]
            res = add_edge!(G, src, dst)
            res ? wg[src*1000000+dst] = 1 : wg[src*1000000+dst] += 1
            src = dst
        end
        dst = length(ws)
        res = add_edge!(G, src, dst)
        res ? wg[src*1000000+dst] = 1 : wg[src*1000000+dst] += 1
    end
    weight = [wg[src(e)*1000000+dst(e)] for e ∈ edges(G)]
    (G, ws, weight)
end
