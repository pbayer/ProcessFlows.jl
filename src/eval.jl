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
    wulog(wu::Workunit)

return time and status of a work unit log
"""
function queuelog(qu::PFQueue)
end

function productlog()
end
