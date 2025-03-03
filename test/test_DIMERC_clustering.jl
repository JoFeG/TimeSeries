using Clustering
using DelimitedFiles
using Base.Threads
using Random
using Statistics
using Measures
include("../src/DIMERC_utils.jl")

json = LoadDataSet_DIMERC_json()
Y = DIMERCseriesjson2matrix(json)

include("./test_DIMERC_dataset_zeros_handling.jl")

m, nn = size(YY)

#### Normalization
for k = 1:nn
    y = YY[:, k]
    a = minimum(y)
    b = maximum(y) - a 
    YY[:, k] = (y .- a) ./ b
end

#### Set false zeros to NaNs
YYnan = copy(YY)
for i = 1:m
    for k = 1:nn
        if indx_is_missing[i,k]==1
            YYnan[i,k] = NaN
        end
    end
end


#### DTWB distance matrix calculation
#=
include("../src/DTW_arrow.jl")
DIST_DTWB = zeros(nn, nn)
Threads.@threads for i = 1:nn-1
    for j = i+1:nn
        DIST_DTWB[i,j] = dtw_arrow(YYnan[:,i], YYnan[:,j], γt=2)[1]
        DIST_DTWB[j,i] = DIST_DTWB[i,j]
    end
    print(".")
end
writedlm("../data/dimerc/dist_mat_DTWB_YYclean.csv", DIST_DTWB, ',')
=#

#### DTWB distance matrix load
DIST_DTWB = readdlm("./data/dimerc/dist_mat_DTWB_YYclean.csv",',')
D = sqrt.(DIST_DTWB)

#### Kmedoids results
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


using TSne
using Plots

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


K_lim = 10

fig1 = plot(
    margin=20pt,
    size = (900,440), 
    grid = :x,
    xticks = 2:K_lim,
    xlabel = "Number of Clusters k",
    ylabel = "Index Value (DB & MS)"
    )


#=
for k = 2:K_lim
    plot!([k,k],[means_DB[k]-std_DB[k], means_DB[k]+std_DB[k]], color = 1, label = nothing)
    plot!([k,k],[means_MS[k]-std_MS[k], means_MS[k]+std_MS[k]], color = 2, label = nothing)
end
=#

plot!(
    2:K_lim, 
    means_DB[2:K_lim],
    color = 1,
    label = "Davies Bould Inindex (DB)"
)
scatter!(
    2:K_lim, 
    means_DB[2:K_lim],
    color = 1,
    label = nothing,
    markerstrokewidth = 0
)

plot!(
    2:K_lim, 
    means_MS[2:K_lim],
    color = 2,
    label = "Mean Silhouette Index (MS)"
)
scatter!(
    2:K_lim, 
    means_MS[2:K_lim],
    color = 2,
    label = nothing,
    markerstrokewidth = 0
)

plot!(
    twinx(),
    2:K_lim, 
    means_CH[2:K_lim],
    color = 3,
    label = "Calinski Harabasz Index (CH)",
    ylabel = "Index Value (CH)"
)
scatter!(
    twinx(),
    2:K_lim, 
    means_CH[2:K_lim],
    color = 3,
    label = nothing,
    markerstrokewidth = 0
)



k = 3
r = 3

#### Heatmap plot test

assig = Results[k,r].assignments
D_grouped = zeros(size(D))
sort = zeros(Int, size(assig))
let
    grouped_count = 0
    for i = 1:k
        for j = 1:nn    
            if assig[j] == i
                grouped_count = grouped_count + 1
                sort[j] = grouped_count
            end
        end
    end
end
    
for i = 1:nn
    for j = 1:nn
        D_grouped[sort[i], sort[j]] = D[i,j]
        D_grouped[sort[i], sort[j]] = D_grouped[sort[i], sort[j]]
    end
end

fig2 = plot(
        framestyle = :grid,
        ratio  = 1,
        size   = (600,600)
    )
heatmap!(D_grouped)

#### TSne plot test

Random.seed!(1234)
hatYYnan = tsne(D, 2, 50, 1000, 20.0)
fig3 = plot(
        framestyle = :box,
        ratio  = 1,
        size   = (600,600),
    )

scatter!(hatYYnan[:,1], hatYYnan[:,2], color=assig, label  = :none) 
# If tsne from D_grouped
# scatter!(hatYYnan[:,1], hatYYnan[:,2], color=[assig[sort.==i][1] for i = 1:nn]) 


savefig(fig1,"./figs/DIMERC_clust_eval.pdf")
savefig(fig2,"./figs/DIMERC_heatmap_k$(k)_r$(r).pdf")
savefig(fig3,"./figs/DIMERC_tsnemap_k$(k)_r$(r).pdf")
