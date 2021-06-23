using LidCavityDriven
using Documenter

DocMeta.setdocmeta!(LidCavityDriven, :DocTestSetup, :(using LidCavityDriven); recursive=true)

makedocs(;
    modules=[LidCavityDriven],
    authors="Romain VELTZ",
    repo="https://github.com/rveltz/LidCavityDriven.jl/blob/{commit}{path}#{line}",
    sitename="LidCavityDriven.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://rveltz.github.io/LidCavityDriven.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/rveltz/LidCavityDriven.jl",
)
