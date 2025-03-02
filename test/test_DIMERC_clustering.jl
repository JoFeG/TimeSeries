using Clustering
using DelimitedFiles
using Base.Threads
using Random
using Statistics
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


#### Kmedoids results
kclst = 20
repts = 10
Results = Array{KmedoidsResult}(undef, kclst, repts)
for k =1:kclst
    for r = 1:repts
        Random.seed!(r)
        Results[k,r] = kmedoids(DIST_DTWB, k)
        # print(Results[k,r].converged) # it does converge!
    end
end


using TSne
using Plots

#### Evaluation
include("../src/ExpEval.jl")
evals_DB = zeros(kclst,repts)
evals_CH = zeros(kclst,repts)
for k =1:kclst
    for r = 1:repts
        evals_DB[k,r] = ExpEval.daviesbouldinindex(Results[k,r].assignments, DIST_DTWB, medoids=Results[k,r].medoids)
        C_idx = ExpEval.bestMedoids(Results[k,r].assignments, DIST_DTWB)[1]
        evals_CH[k,r] = ExpEval.calinskiharabaszindex(
            Results[k,r].assignments, 
            DIST_DTWB, 
            medoids=Results[k,r].medoids, 
            c=C_idx)
    end
end


k = 2
r = 1

#### Heatmap plot test

assig = Results[k,r].assignments
DIST_DTWB_grouped = zeros(size(DIST_DTWB))
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
        DIST_DTWB_grouped[sort[i], sort[j]] = DIST_DTWB[i,j]
        DIST_DTWB_grouped[sort[i], sort[j]] = DIST_DTWB_grouped[sort[i], sort[j]]
    end
end

fig2 = plot(
        framestyle = :box,
        ratio  = 1,
        size   = (600,600)
    )
heatmap!(sqrt.(DIST_DTWB_grouped))

#### TSne plot test

Random.seed!(10)
hatYYnan = tsne(DIST_DTWB_grouped, 2, 50, 1000, 20.0)
fig3 = plot(
        framestyle = :box,
        ratio  = 1,
        size   = (600,600)
    )

scatter!(hatYYnan[:,1], hatYYnan[:,2], color=[assig[sort.==i][1] for i = 1:nn])

