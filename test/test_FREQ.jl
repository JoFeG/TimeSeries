include("../src/FREQ_utils.jl")
path = "./data/freq/raw/2023_set_n1/"
using Plots
using DelimitedFiles
summary, header = readdlm("./data/freq/experiment_data_summary.csv", ',', header=true)

n = size(summary)[1]
m = 101

Y  = zeros(m,n)
P0 = zeros(n) 
for i = 1:n
    y, p0, t = SamplerRaw_FREQ(path * summary[i,1] * ".csv")
    P0[i] = p0
    Y[:,i] = y
end



### Series plots index colors
fig1 = plot(
    size = (600,400), 
    grid = :y,
    xticks = 0:2:30,
    xlabel = "Time [seg]",
    ylabel = "Δf [Hz]"
)

for i = 1:n
    plot!(t,Y[:,i], label=false, color=i)
end



#### PCA plot index colors
using LinearAlgebra
F = svd(Y)
k = 2
Σ = Diagonal(F.S)
T = Σ[1:k,1:k] * F.Vt[1:k,:]

fig2 = plot(
    framestyle = :box,
    ratio  = 1,
    size = (400,400)
    )

scatter!(
    T[1,:],
    T[2,:],
    color = 1:n,
    markerstrokewidth = 0,
    label = false,
    xlabel = "First Principal Component",
    ylabel = "Second Principal Component"
)


#### DTW distance matrix calculation 

using DynamicAxisWarping
D = zeros(n, n)
Threads.@threads for i = 1:n-1
    for j = i+1:n
        D[i,j] = DynamicAxisWarping.dtw(Y[:,i], Y[:,j])[1]
        D[j,i] = D[i,j]
    end
end


#### DTW TSne plot index colors
using TSne
hatY = tsne(D, 2, 50, 1000, 20.0, distance=true)

fig3 = plot(
    framestyle = :box,
    ratio  = 1,
    size = (400,400)
    )

scatter!(
    hatY[:,1], 
    hatY[:,2],
    color = 1:n, 
    markerstrokewidth = 0,
    label = false,
    xlabel = "dim1",
    ylabel = "dim2"
    ) 
