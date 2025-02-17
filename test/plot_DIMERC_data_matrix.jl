using Plots
using Measures
include("../src/DIMERC_utils.jl")
savepath = "figs/DIMERC_"


json = LoadDataSet_DIMERC_json()
Y = DIMERCseriesjson2matrix(json)

m, n = size(Y)

fig = plot(
    margin=20pt,
    size = (2*250,2*400), 
    grid = :none,
    ylabel = "Week",
    xlabel = "Series"
    )

heatmap!(
    1:n,
    1:m,
    log.(Y),
    label = "Data Matrix"
)

savefig(fig, savepath*"data_matrix.pdf")
