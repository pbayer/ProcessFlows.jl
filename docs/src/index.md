# PFlow.jl

A package for simulating the **product flow** in production, development and service systems.

!!! note

    PFlow is in early development and not yet intended for public use.

## Package Features

- Basic functions for discrete event simulation using Julia coroutines (tasks).
- Easy parametrization of production systems and projects by lists (`csv`-files).
- Multiple flows through resources can be modeled.
- can simulate production, project, customer or even patient flow … even of large systems
as automotive plants, multiprojects or hospitals
- Workloads, lead times, queue lengths can be analyzed and visualized.

The [Package Guide](@ref) provides a tutorial explaining how to get started using `PFlow`.
Some examples of packages using `PFlow` can be found on the [Examples](@ref) page.
See the [Index](@ref main-index) for the complete list of documented functions and types.

## Manual Outline

```@contents
Pages = [
    "man/guide.md",
    "man/examples.md",
]
Depth = 1
```

## Library Outline

```@contents
Pages = ["man/api.md"]
```

### [Index](@id main-index)

```@index
Pages = ["man/api.md"]
```
