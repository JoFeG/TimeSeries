include("../src/FREQ_utils.jl")
path = "./data/freq/raw/2023_set_n1/"

using DelimitedFiles
summary, header = readdlm("./data/freq/experiment_data_summary.csv", ',', header=true)

n = size(summary)[1]
m = 101

Y  = zeros(n,m)
P0 = zeros(n) 
for i = 1:n
    y, p0, t = SamplerRaw_FREQ(path * summary[i,1] * ".csv")
    P0[i] = p0
    Y[i,:] = y
end

using Plots
using Measures

fig = plot(
    margin = 20pt,
    size = (900,440), 
    grid = :y,
    xticks = 1:30,
    xlabel = "Time [seg]",
    ylabel = "Δf [Hz]"
)

for i = 1:n
    plot!(t,Y[i,:], label=false, color=1)
end