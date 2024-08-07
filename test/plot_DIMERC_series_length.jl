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



bar!(
    replace(log10.(Gap_lengths),-Inf=>NaN), 
    label = "Gap lengths",
    fillrange = -.03*ones(n),
    fillalpha = .6,
    yticks = (
        [   
            log10.(1:9)...,
            log10.(10:10:90)...,
            log10.(100:100:900)...,
            log10.(1000:1000:3000)...
        ],[
            "1","2","3","4",
            ["" for i=1:5]...,
            "10","20","30","40",
            ["" for i=1:5]...,
            "100","200","300","400",
            ["" for i=1:5]...,
            "1000","2000","3000"
        ]),
    xticks = [1,10:10:274...],
    tick_direction = :out,
    bordercolor = :white,
    legend = :topright,
    linecolor=RGBA(0,0,0,.4)
    )



savefig(fig, savepath*"series_gaps_lengths.pdf")