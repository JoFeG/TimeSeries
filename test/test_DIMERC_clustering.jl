using Clustering
using DelimitedFiles
using Base.Threads
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

