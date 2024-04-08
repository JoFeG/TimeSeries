using StatsPlots
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
    
index_labels = ["MS","DI","HΓ","DB","CH"]


fig = plot(
    size = (310,220),
    grid = :y
)

fo_y = font(8, family="sans-serif")
fo_x = font(12, family="sans-serif")
perm = sortperm(all_suc_rate_means, rev=true)
bar!(
    index_labels[perm], 
    all_suc_rate_means[perm],
    label = false,
    yguidefont = fo_y,
    ylabel = "Proportion of success",
    ytickfont = fo_y,
    yrotation = 90,
    xtickfont = fo_x
)

savefig(fig, "figs/all_suc_rate_means.svg")

##################################################################

algs_suc_rate_means = zeros(5,2)

for i = 1:5
    sum_i1 = 0
    sum_i2 = 0
    for s = 1:2
        for d = 1:4
            col1 = join([alg[1], index[i], set[s], dist[d]],"_")
            sum_i1 = sum_i1 + mean(Indices_df[!, col1])
            col2 = join([alg[2], index[i], set[s], dist[d]],"_")
            sum_i2 = sum_i2 + mean(Indices_df[!, col2])
        end
    end
    algs_suc_rate_means[i,1] = sum_i1 / (2*4)
    algs_suc_rate_means[i,2] = sum_i2 / (2*4)
end

fig = plot(
    size = (310,220),
    grid = :y
)

fo_y = font(8, family="sans-serif")
fo_x = font(12, family="sans-serif")
perm = sortperm(algs_suc_rate_means[:,1], rev=true)
groupedbar!(
    index_labels[perm], 
    [algs_suc_rate_means[perm,1] algs_suc_rate_means[perm,2]],
    label = [alg[1] alg[2]],
    yguidefont = fo_y,
    ylabel = "Proportion of success",
    ytickfont = fo_y,
    yrotation = 90,
    xtickfont = fo_x
)

savefig(fig, "figs/algs_suc_rate_means.svg")

##################################################################

set_suc_rate_means = zeros(5,2)

for i = 1:5
    sum_i1 = 0
    sum_i2 = 0
    for a = 1:2
        for d = 1:4
            col1 = join([alg[a], index[i], set[1], dist[d]],"_")
            sum_i1 = sum_i1 + mean(Indices_df[!, col1])
            col2 = join([alg[a], index[i], set[2], dist[d]],"_")
            sum_i2 = sum_i2 + mean(Indices_df[!, col2])
        end
    end
    set_suc_rate_means[i,1] = sum_i1 / (2*4)
    set_suc_rate_means[i,2] = sum_i2 / (2*4)
end

fig = plot(
    size = (310,220),
    grid = :y
)

fo_y = font(8, family="sans-serif")
fo_x = font(12, family="sans-serif")
perm = sortperm(set_suc_rate_means[:,1], rev=true)
groupedbar!(
    index_labels[perm], 
    [set_suc_rate_means[perm,1] set_suc_rate_means[perm,2]],
    label = [set[1] set[2]],
    yguidefont = fo_y,
    ylabel = "Proportion of success",
    ytickfont = fo_y,
    yrotation = 90,
    xtickfont = fo_x
)

savefig(fig, "figs/set_suc_rate_means.svg")

