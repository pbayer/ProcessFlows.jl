using Documenter, PFlow

makedocs(
    modules = [PFlow],
    clean = false,
    format = :html,
    sitename = "PFlow.jl",
    authors = "Paul Bayer",
    analytics = "",
    linkcheck = !("skiplinks" in ARGS),
    pages = Any[ # Compat: `Any` for 0.4 compat
        "Home" => "index.md",
        "Manual" => Any[
            "Guide" => "man/guide.md",
            "Examples" => "man/examples.md",
        ],
        "Library" => "man/api.md"],
    html_prettyurls = true,
)

deploydocs(
    repo = "github.com/pbayer/PFlow.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)
