include("../src/FREQ_utils.jl")
path = "./data/freq/raw/2023_set_n1/"
using Plots
using Measures
using DelimitedFiles
summary, header = readdlm("./data/freq/experiment_data_summary.csv", ',', header=true)

n = size(summary)[1]
m = 101

Y  = zeros(m,n)
P0 = zeros(n) 
y, p0, t = SamplerRaw_FREQ(path * summary[1,1] * ".csv")
for i = 1:n
    y, p0, t = SamplerRaw_FREQ(path * summary[i,1] * ".csv")
    P0[i] = p0
    Y[:,i] = y
end

#=
#### Normalization
using Statistics
means = [mean(Y[:,i]) for i =1:n]
stds  = [std(Y[:,i]) for i =1:n]
for i = 1:n
    Y[:,i] = (Y[:,i] .- means[i]) / stds[i]
end
=#

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
D = sqrt.(D) 


#### DTW TSne plot index colors
using TSne
using Random
Random.seed!(100)
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

savefig(fig1,"./figs/FREQ_series_color_index.pdf")
savefig(fig2,"./figs/FREQ_pca_color_index.pdf")
savefig(fig3,"./figs/FREQ_tsne_color_index.pdf")

writedlm("./data/freq/FREQ_pca_2D_points.csv", T[1:2,:]', ',')
writedlm("./data/freq/FREQ_tsne_2D_points.csv", hatY[:,1:2], ',')


#### Kmeans results
using Clustering
using Random
using Statistics

kclst = 8
repts = 10
Results = Array{KmedoidsResult}(undef, kclst, repts)
for k =1:kclst
    for r = 1:repts
        Random.seed!(r)
        Results[k,r] = kmedoids(D, k)
        # print(Results[k,r].converged) # it does converge!
    end
end


#### Evaluation
include("../src/ExpEval.jl")
evals_DB = zeros(kclst,repts)
evals_CH = zeros(kclst,repts)
evals_MS = zeros(kclst,repts)


for k =1:kclst
    for r = 1:repts
        evals_DB[k,r] = ExpEval.daviesbouldinindex(Results[k,r].assignments, D, medoids=Results[k,r].medoids)
        C_idx = ExpEval.bestMedoids(Results[k,r].assignments, D)[1]
        evals_CH[k,r] = ExpEval.calinskiharabaszindex(
            Results[k,r].assignments, 
            D, 
            medoids=Results[k,r].medoids, 
            c=C_idx)
        k>1 ? evals_MS[k,r] = mean(silhouettes(Results[k,r].assignments, D)) : nothing        
    end
end
means_DB = [mean(evals_DB[k,:]) for k = 1:kclst]
means_CH = [mean(evals_CH[k,:]) for k = 1:kclst]
means_MS = [mean(evals_MS[k,:]) for k = 1:kclst]
std_DB = [std(evals_DB[k,:]) for k = 1:kclst]
std_CH = [std(evals_CH[k,:]) for k = 1:kclst]
std_MS = [std(evals_MS[k,:]) for k = 1:kclst]

best_DB = [minimum(evals_DB[k,:]) for k = 1:kclst]
best_CH = [maximum(evals_CH[k,:]) for k = 1:kclst]
best_MS = [maximum(evals_MS[k,:]) for k = 1:kclst]

best_index_DB = [argmin(evals_DB[k,:]) for k = 1:kclst]
best_index_CH = [argmax(evals_CH[k,:]) for k = 1:kclst]
best_index_MS = [argmax(evals_MS[k,:]) for k = 1:kclst]


K_lim = 8

fig4 = plot(
    margin=20pt,
    size = (900,440), 
    grid = :x,
    xticks = 2:K_lim,
    xlabel = "Number of Clusters k",
    ylabel = "Index Value (DB & MS)",
    legend = :topleft
    )


plot!(
    2:K_lim, 
    best_DB[2:K_lim],
    color = 1,
    label = "Davies Bould Inindex (DB)"
)
scatter!(
    2:K_lim, 
    best_DB[2:K_lim],
    color = 1,
    label = nothing,
    markerstrokewidth = 0
)

plot!(
    2:K_lim, 
    best_MS[2:K_lim],
    color = 2,
    label = "Mean Silhouette Index (MS)"
)
scatter!(
    2:K_lim, 
    best_MS[2:K_lim],
    color = 2,
    label = nothing,
    markerstrokewidth = 0
)

plot!(
    twinx(),
    2:K_lim, 
    best_CH[2:K_lim],
    color = 3,
    label = "Calinski Harabasz Index (CH)",
    ylabel = "Index Value (CH)"
)
scatter!(
    twinx(),
    2:K_lim, 
    best_CH[2:K_lim],
    color = 3,
    label = nothing,
    markerstrokewidth = 0
)


savefig(fig4,"./figs/FREQ_clust_eval.pdf")


for (k,r) in [(2,1),(3,6)]
    assig = Results[k,r].assignments

    ### Series plots assig colors
    fig5 = plot(
        size = (600,400), 
        grid = :y,
        xticks = 0:2:30,
        xlabel = "Time [seg]",
        ylabel = "Δf [Hz]"
    )

    for i = 1:n
        plot!(t,Y[:,i], label=false, color=assig[i])
    end



    #### PCA plot assig colors
    fig6 = plot(
        framestyle = :box,
        ratio  = 1,
        size = (400,400)
        )

    scatter!(
        T[1,:],
        T[2,:],
        color = assig,
        markerstrokewidth = 0,
        label = false,
        xlabel = "First Principal Component",
        ylabel = "Second Principal Component"
    )


    #### DTW TSne plot assig colors
    fig7 = plot(
        framestyle = :box,
        ratio  = 1,
        size = (400,400)
        )

    scatter!(
        hatY[:,1], 
        hatY[:,2],
        color = assig, 
        markerstrokewidth = 0,
        label = false,
        xlabel = "dim1",
        ylabel = "dim2"
        ) 

    #### Heatmap plot test
    D_grouped = zeros(size(D))
    sort = zeros(Int, size(assig))
    let
        grouped_count = 0
        for i = 1:k
            for j = 1:n    
                if assig[j] == i
                    grouped_count = grouped_count + 1
                    sort[j] = grouped_count
                end
            end
        end
    end

    for i = 1:n
        for j = 1:n
            D_grouped[sort[i], sort[j]] = D[i,j]
            D_grouped[sort[i], sort[j]] = D_grouped[sort[i], sort[j]]
        end
    end

    fig8 = plot(
            framestyle = :grid,
            ratio  = 1,
            size   = (400,400)
        )
    heatmap!(D_grouped)

    savefig(fig5,"./figs/FREQ_series_color_k$(k)_r$r.pdf")
    savefig(fig6,"./figs/FREQ_pca_color_k$(k)_r$r.pdf")
    savefig(fig7,"./figs/FREQ_tsne_color_k$(k)_r$r.pdf")
    savefig(fig8,"./figs/FREQ_heatmap_color_k$(k)_r$r.pdf")
    
    writedlm("./data/freq/FREQ_colors_k$(k)_r$r.csv", assig, ',')
end



############################### MODEL CLUSTERING ########################################

data_mod, header_mod = readdlm("./data/freq/models_experimet_results.csv", ',', header=true)

data_modB2 = data_mod[data_mod[:,4].=="B2",:]

X = zeros(3,23) 

for i = 1:size(data_modB2)[1]
    typeof(data_modB2[i,5])==Float64 ? nothing : data_modB2[i,5] = Inf
end

let
    i = 1
    for inst in unique(data_modB2[:,2])
        best_indx = argmin(data_modB2[data_modB2[:,2].==inst,5])
        X[:,i] = data_modB2[data_modB2[:,2].==inst,:][best_indx,10:12]
        i = i + 1
    end
end

clusterings = kmeans.(Ref(X), 2:6)
clustering_quality.(Ref(X), clusterings, quality_index = :silhouettes)

k=2
VI2 = Clustering.varinfo(clusterings[k-1].assignments,Results[k,1].assignments)
println("k = 2 --> VI = $VI2")


k=3
VI3 = Clustering.varinfo(clusterings[k-1].assignments,Results[k,6].assignments)
println("k = 3 --> VI = $VI3")
