include("../src/ExpEval.jl")

using Plots
using Measures
using DelimitedFiles


ID = 55
df = ExpEval.LoadDataSumary()
TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);

Y = Array(TRAIN')

m , n = size(Y)



#=
#### Normalization
using Statistics
means = [mean(Y[:,i]) for i =1:n]
stds  = [std(Y[:,i]) for i =1:n]
for i = 1:n
    Y[:,i] = (Y[:,i] .- means[i]) / stds[i]
end
=#



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
D = sqrt.(ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw"))

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



#### Kmeans results
using Clustering
using Random

kclst = 20
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
        C_idx = ExpEval.bestMedoids(ones(Int, n), D)[1]
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




K_lim = 10

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


k = 7
r = 1
assig = Results[k,r].assignments




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
