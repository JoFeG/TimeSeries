using Plots
using Statistics
using DataFrames
using CSV

dff = CSV.read("UCRA_clustering_indices.csv", DataFrame)
Indices_df = dff[
        (dff.ID .!= 15) .&
        (dff.ID .!= 27) .&
        (dff.ID .!= 101),
    :]


alg = ["kmed","hclu"]
index = ["ms","di","ga","db","ch"]
set = ["TRAIN", "TEST"]
dist = ["euc","dtw","euc_z","dtw_z"]

all_suc_rate_means = zeros(5)

for i = 1:5
    sum_i = 0
    for a = 1:2
        for s = 1:2
            for d = 1:4
                col = join([alg[a], index[i], set[s], dist[d]],"_")
                sum_i = sum_i + mean(Indices_df[!, col])
            end
        end
    end
    all_suc_rate_means[i] = sum_i / (2*2*4)
end
    
    


fig = plot(
    size = (620,440),
    grid = false
)

perm = sortperm(all_suc_rate_means, rev=true)
bar!(
    index[perm], 
    all_suc_rate_means[perm],
    label = false
)

savefig(fig, "figs/all_suc_rate_means.svg")