using LinearAlgebra
using Plots
using Statistics

include("../src/DIMERC_utils.jl")

json = LoadDataSet_DIMERC_json()
Y = DIMERCseriesjson2matrix(json)

include("./test_DIMERC_dataset_zeros_handling.jl")

m, nn = size(YY)

#=
X = norm.(eachcol(Y))
norms = sort(X, rev=true)

color = ((ids_over_max_gap + ids_over_max_tot) .!= 0) .+ 1
color = color[sortperm(X, rev=true)]

fig = plot(
    margin=20pt,
    size = (2*600,2*220), 
    grid = :y,
    ylabel = "Euclidean Norm",
    xlabel = "Series"
    )

bar!(log10.(norms),
    linecolor = nothing,
    color = color,
        yticks = (
        [   
            log10.(1:9)...,
            log10.(10:10:90)...,
            log10.(100:100:900)...,
            log10.(1000:1000:9000)...,
            log10.(10000:10000:90000)...,
            log10.(100000:100000:900000)...,
            log10.(1000000)
        ],[
            "1",
            ["" for i=1:8]...,
            "10",
            ["" for i=1:8]...,
            "100",
            ["" for i=1:8]...,
            "1000",
            ["" for i=1:8]...,
            "10000",
            ["" for i=1:8]...,
            "100000",
            ["" for i=1:8]...,
            "1000000"
        ]),
    label = "Series not excluded by zeros caps"
)

savefig(fig, "figs/DIMERC_data_norms.pdf")

=#

for k = 1:nn
    y = YY[:, k]
    a = minimum(y)
    b = maximum(y) - a 
    YY[:, k] = (y .- a) ./ b
end

#=
norms = sort(norm.(eachcol(YY)), rev=true)

fig = plot(
    margin=20pt,
    size = (2*600,2*220), 
    grid = :y,
    ylabel = "Euclidean Norm",
    xlabel = "Series"
    )

bar!(norms,
    linecolor = nothing,
    label = "Series not excluded by zeros caps"
)

savefig(fig, "figs/DIMERC_data_norms_after.pdf")
=#