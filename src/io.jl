# --------------------------------------------
# this file is part of PFlow.jl
# it implements the file IO functions
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    readWorkunits(file::String, sim::DES, log::Simlog) :: Workunits

read the workunits from a .csv file, start the processes
and return a Dict of the workunits.
"""
function readWorkunits(file::String, sim::DES) :: Workunits
    t = readtable(file)
    d = Workunits()
    for i ∈ 1:nrow(t)
        t[i,3]
        kind = t[i,3]
        wu = if kind == MACHINE
            machine(sim, t[i,1], description=t[i,2],
                    input=t[i,4], wip=t[i,5], output=t[i,6],
                    mtbf=t[i,8], mttr=t[i,9], alpha=t[i,7], timeslice=t[i,10])
        elseif kind == WORKER
            worker(sim, t[i,1], description=t[i,2],
                   input=t[i,4], wip=t[i,5], output=t[i,6],
                   mtbf=t[i,8], mttr=t[i,9], alpha=t[i,7],
                   timeslice=t[i,10], multitasking=(t[i,11] == 1))
        elseif kind == TRANSPORT
            error("TRANSPORT not yet implemented")
        elseif kind == INSPECTOR
            error("INSPECTOR not yet implemented")
        elseif kind == STORE
            error("STORE not yet implemented")
        else
            error("wrong type")
        end
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
            job = Job(0, t1[i,2], String.(split(t1[i,3],",")), t1[i,4],
                      batch_size=t1[i,5], target=isna(t1[i,6]) ? "" : t1[i,6])
            if haskey(d, ord)
                push!(d[ord], job)
            else
                d[ord] = [job]
            end
        end
    end
    d
end
