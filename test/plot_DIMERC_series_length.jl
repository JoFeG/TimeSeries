using Plots
using Measures
include("../src/DIMERC_utils.jl")
savepath = "figs/DIMERC_"


json = LoadDataSet_DIMERC_json()
Y = DIMERCseriesjson2matrix(json)

m, n = size(Y)

Lengths = [length(json[k].points) for k = 1:m]



fig = plot(
    margin=20pt,
    size = (2*600,2*220), 
    grid = :y,
    ylabel = "Number of points",
    xlabel = "Series"
    )

plot!(
    sort(Lengths), 
    label = "Series length",
    fillrange = zeros(n),
    fillalpha = 0.35
)

savefig(fig, savepath*"series_lengths.pdf")







Gap_lengths = zeros(m)

for k = 1:n
    count = 0
    for i = 1:m
        if Y[i,k] == 0
            count += 1
        else
            if count > 0
                Gap_lengths[count] += 1
            end
            count = 0
        end
    end
    if count > 0
        Gap_lengths[count] += 1
    end
end

fig = plot(
    margin=20pt,
    size = (2*600,2*220), 
    grid = :y,
    ylabel = "Number of gaps",
    xlabel = "Gap lengths"
    )

plot!(
    log10.(Gap_lengths .+ 1), 
    label = "Gap lengths",
    fillrange = zeros(n),
    fillalpha = 0.35
    )

savefig(fig, savepath*"series_gaps_lengths.pdf")