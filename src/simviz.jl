# --------------------------------------------
# this file is part of PFlow.jl
# it implements the visualization routines
# --------------------------------------------
# author: Paul Bayer, Paul.Bayer@gleichsam.de
# --------------------------------------------
# license: MIT
# --------------------------------------------

"""
    mload(ml::DataFrame, wu::Array{Symbol}=[])

draw a load diagram of the workstations in ml or of those specified in wu
"""
function mload(ml::DataFrame, wu::Array{Symbol}=[], loc=2)
  if length(wu) == 0
    wu = names(ml)
  end
  wu = wu[wu .!= :time]
  for m ∈ sort(wu)
    step(ml[:time], ml[m])
  end
  yticks(0:3, mstatus)
  xlabel("simulation time")
  legend(wu, loc=loc)
  title("Workstation load");
end
