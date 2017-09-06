# --------------------------------------------
# this file is part of PFlow.jl
# it implements the graph functions
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    ordergraph(ord::Orders)

return a Digraph built from a PFlow Orders dict
"""
function ordergraph(ord::Orders)
    ws = String[]              # create access to work units
    for o ∈ keys(ord)
        for j ∈ ord[o]
            append!(ws, j.wus)
        end
    end
    ws = collect(Set(ws))
    sort!(ws)
    unshift!(ws, "IN")
    push!(ws, "OUT")
    wu = Dict()
    for (i, v) ∈ enumerate(ws)
        wu[v] = i
    end

    G = DiGraph()
    add_vertices!(G, length(ws))
    for o ∈ keys(ord)
        sources = [ 1 ]
        for j ∈ ord[o]
            for t ∈ j.wus
                for s ∈ sources
                    add_edge!(G, s, wu[t])
                end
            end
            sources = [wu[w] for w ∈ j.wus]
        end
        for s ∈ sources
            add_edge!(G, s, length(ws))
        end
    end
    (G, ws)
end

"""
    flowgraph(pr::Products)

return a Digraph built from a PFlow Products array
"""
function flowgraph(pr::Products)
end
