using DataFrames, PFlow

function printwu(w)
    println("$(w.name)")
    if w.kind < 4
        println("lastlog: status:$(w.log[end].status) time:$(w.log[end].time)")
        println("in:$(length(w.input.queue)) wip:$(length(w.wip.queue)) out:$(length(w.output.queue))")
    elseif w.name == "IN"
        println("out:$(length(w.output.queue))")
        for p in w.output.queue
            println("   item:$(p.item) start_time:$(p.start_time)")
        end
    elseif w.name == "OUT"
        println("in:$(length(w.input.queue))")
        for p in w.input.queue
            println("   item:$(p.item) end_time:$(p.end_time)")
        end
    else
    end
end

function printwus(wus)
    wn = [w for w in keys(wus) if !(w in ["IN", "OUT"])]
    sort!(wn)
    unshift!(wn, "IN")
    push!(wn, "OUT")
    for w in wn
        printwu(wus[w])
    end
end

function printprod(p)
    println("$(p.item) start_time:$(p.start_time) end_time:$(p.end_time)")
    for j in p.jobs
        println("   $(j.job) status:$(j.status) wu:$(j.wu) start_time:$(j.start_time) end_time:$(j.end_time)")
    end
end

function wuslog(wus)
    wn = [w for w in keys(wus) if !(w in ["IN", "OUT"])]
    time = Float64[] # time
    name = String[]  # wu name
    stat = Int64[]   # wu status
    for w in wn
        for l in wus[w].log
            push!(time, l.time)
            push!(name, w)
            push!(stat, l.status)
        end
    end
    d = DataFrame(time=time, name=name, status=stat)
    sort!(d, cols=[:time])
    d
end

function joblog(pr::Products)
    prodnr = Int64[]
    order = String[]
    item = Int64[]
    job = String[]
    status = Int64[]
    wu = String[]
    start_time = Float64[]
    end_time = Float64[]
    for (i, p) in enumerate(pr)
        for j in p.jobs
            push!(prodnr, i)
            push!(order, p.order)
            push!(item, p.item)
            push!(job, j.job)
            push!(status, j.status)
            push!(wu, j.wu)
            push!(start_time, j.start_time)
            push!(end_time, j.end_time)
        end
    end
    d = DataFrame(prodnr=prodnr, order=order, item=item, job=job,
                  status=status, wu=wu, start_time=start_time, end_time=end_time)
    sort!(d, cols=[:start_time, :end_time])
    d
end
