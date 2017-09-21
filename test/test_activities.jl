using Base.Test, PFlow, Distributions, DataFrames

struct testlog
    time::Float64
    value::Any
end

# take! the scheduling variable in order not to block clients
function dummy(s::Channel)
    while true
        try
            take!(s)
        catch exc
            if isa(exc, SimException)
                break
            else
                rethrow(exc)
            end
        end
    end
end

function scheduling(sim::DES, wu::Workunit, dt::Number=0, n::Int64=100)
    timer = sim.time
    for i ∈ 1:n
        try
            if dt > 0
                Δt = rand(Exponential(dt))
                delayuntil(sim, timer+Δt)
                timer += Δt
            end
            item = 123000+i
            job = Job(item, "Job"*string(i), [wu.name], randn()+5)
            pro = Product(123, item, "test", "testproduct", "testorder", [job])
            timer = enqueue!(wu.input, pro, timer)
            pro.start_time = timer
            push!(jl, testlog(timer, item))
        catch exc
            if isa(exc, SimException)
                if exc.cause == FINISHED
                    break
                else
                    rethrow(exc)
                end
            else
                rethrow(exc)
            end
        end
    end
end

function delivering(sim::DES, wu::Workunit, dt::Number=0)
    timer = sim.time
    pro = nothing
    while true
        try
            if dt > 0
                Δt = rand(Exponential(dt))
                delayuntil(sim, timer + Δt)
                timer += Δt
            end
            (pro, timer) = dequeue!(wu.output, timer)
            push!(ml, testlog(timer, pro.item))
            pro.end_time = timer
            push!(out, pro)
        catch exc
            if isa(exc, SimException)
                if exc.cause == FINISHED
                    break
                else
                    #rethrow(exc)
                    continue
                end
#            elseif isa(exc, ErrorException)
#                println("timer:$(round(timer, 2)) $exc")
#                (pro, timer) = dequeue!(wu.output, timer)
#                push!(ml, testlog(timer, pro.item))
#                pro.end_time = timer
#                push!(out, pro)
#                #continue
            else
                rethrow(exc)
            end
        end
    end
end
