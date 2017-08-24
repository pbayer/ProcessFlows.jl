# --------------------------------------------
# this file is part of PFlow.jl
# it implements the file IO functions
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    readWorkunits(file::String, sim::Simulation, log::Simlog) :: Workunits

read the workunits from a .csv file, start the processes
and return a Dict of the workunits.
"""
function readWorkunits(file::String, sim::Simulation, log::Simlog) :: Workunits
    t = readtable(file)
    d = Workunits()
    for i ∈ 1:nrow(t)
        wu = workunit(sim, log, t[i,3], t[i,1], t[i,2], t[i,4], t[i,5], t[i,6],
                      t[i,8], t[i,9], t[i,7], t[i,10])
        d[t[i,1]] = wu
    end
    d
end

"""
    readOrders(file::String)

read the orders from a .csv file and return a Dict of the orders/jobs
"""
function readOrders(file::String) :: Orders
    t = readtable(file)
    d = Orders()
    for ord ∈ Set(t[:order])
        t1 = t[t[:order] .== ord, :]
        for i ∈ 1:nrow(t1)
            job = Job(0, t1[i,2], split(t1[i,3],","), t1[i,4], 0.0, 0.0,
                      OPEN, "", 0.0, 0.0,
                      t1[i,5], isna(t1[i,6]) ? "" : t1[i,6])
            if haskey(d, ord)
                push!(d[ord], job)
            else
                d[ord] = [job]
            end
        end
    end
    d
end
