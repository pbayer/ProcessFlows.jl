tests = ["activities",
         "entities",
         "queues",
         "schedule",
         "simlog",
        ]

if length(ARGS) > 0
    tests = ARGS
end

for t in tests
    fp = joinpath(dirname(@__FILE__), "test_$t.jl")
    println("$fp ...")
    include(fp)
end
