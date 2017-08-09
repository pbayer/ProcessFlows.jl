# --------------------------------------------
# this file is part of PFlow.jl
# it implements the file IO functions
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

function readMachines(file::AbstractString)
    readtable(file)
end

function readOrders(file::AbstractString)
    readtable(file)
end
