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
    size = (2*310,2*220),
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
    xtickfont = fo_x,
    color = RGBA(.9,.9,.9,1)
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
    size = (2*310,2*220),
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
    xtickfont = fo_x,
    color = [RGBA(.9,.9,.9,1) RGBA(.75,.75,.75,1)]
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
    size = (2*310,2*220),
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
    xtickfont = fo_x,
    color = [RGBA(.9,.9,.9,1) RGBA(.75,.75,.75,1)]
)

savefig(fig, "figs/set_suc_rate_means.svg")

##################################################################

dist_suc_rate_means = zeros(5,4)

for i = 1:5
    sum_i1 = 0
    sum_i2 = 0
    sum_i3 = 0
    sum_i4 = 0
    for a = 1:2
        for s = 1:2
            col1 = join([alg[a], index[i], set[s], dist[1]],"_")
            sum_i1 = sum_i1 + mean(Indices_df[!, col1])
            col2 = join([alg[a], index[i], set[s], dist[2]],"_")
            sum_i2 = sum_i2 + mean(Indices_df[!, col2])
            col3 = join([alg[a], index[i], set[s], dist[3]],"_")
            sum_i3 = sum_i3 + mean(Indices_df[!, col1])
            col4 = join([alg[a], index[i], set[s], dist[4]],"_")
            sum_i4 = sum_i4 + mean(Indices_df[!, col2])
        end
    end
    dist_suc_rate_means[i,1] = sum_i1 / (2*2)
    dist_suc_rate_means[i,2] = sum_i2 / (2*2)
    dist_suc_rate_means[i,3] = sum_i3 / (2*2)
    dist_suc_rate_means[i,4] = sum_i4 / (2*2)
end

fig = plot(
    size = (2*310,2*220),
    grid = :y
)

fo_y = font(8, family="sans-serif")
fo_x = font(12, family="sans-serif")
perm = sortperm(dist_suc_rate_means[:,1], rev=true)
groupedbar!(
    index_labels[perm], 
    [dist_suc_rate_means[perm,1] dist_suc_rate_means[perm,2] dist_suc_rate_means[perm,3] dist_suc_rate_means[perm,4]],
    label = [dist[1] dist[2] dist[3] dist[4]],
    yguidefont = fo_y,
    ylabel = "Proportion of success",
    ytickfont = fo_y,
    yrotation = 90,
    xtickfont = fo_x,
    color = [RGBA(.9,.9,.9,1) RGBA(.75,.75,.75,1) RGBA(.6,.6,.6,1) RGBA(.45,.45,.45,1)]
)

savefig(fig, "figs/dist_suc_rate_means.svg")


##################################################################

length_suc_rate_means = zeros(5,4)

df1 = Indices_df[Indices_df[!,"Length"] .<= 100, :]
df2 = Indices_df[100 .< Indices_df[!,"Length"] .<= 250, :]
df3 = Indices_df[250 .< Indices_df[!,"Length"] .<= 500, :]
df4 = Indices_df[500 .< Indices_df[!,"Length"], :]
for i = 1:5
    sum_i1 = 0
    sum_i2 = 0
    sum_i3 = 0
    sum_i4 = 0
    for a = 1:2
        for s = 1:2
            for d = 1:4
                col1 = join([alg[a], index[i], set[s], dist[d]],"_")
                sum_i1 = sum_i1 + mean(df1[!, col1])
                col2 = join([alg[a], index[i], set[s], dist[d]],"_")
                sum_i2 = sum_i2 + mean(df2[!, col2])
                col3 = join([alg[a], index[i], set[s], dist[d]],"_")
                sum_i3 = sum_i3 + mean(df3[!, col1])
                col4 = join([alg[a], index[i], set[s], dist[d]],"_")
                sum_i4 = sum_i4 + mean(df4[!, col2])
            end
        end
    end
    length_suc_rate_means[i,1] = sum_i1 / (2*2*4)
    length_suc_rate_means[i,2] = sum_i2 / (2*2*4)
    length_suc_rate_means[i,3] = sum_i3 / (2*2*4)
    length_suc_rate_means[i,4] = sum_i4 / (2*2*4)
end

fig = plot(
    size = (2*310,2*220),
    grid = :y
)

fo_y = font(8, family="sans-serif")
fo_x = font(12, family="sans-serif")
perm = sortperm(length_suc_rate_means[:,1], rev=true)
groupedbar!(
    index_labels[perm], 
    [length_suc_rate_means[perm,1] length_suc_rate_means[perm,2] length_suc_rate_means[perm,3] length_suc_rate_means[perm,4]],
    label = ["1-100" "101-250" "251-500" "501-1000"],
    yguidefont = fo_y,
    ylabel = "Proportion of success",
    ytickfont = fo_y,
    yrotation = 90,
    xtickfont = fo_x,
    color = [RGBA(.9,.9,.9,1) RGBA(.75,.75,.75,1) RGBA(.6,.6,.6,1) RGBA(.45,.45,.45,1)]
)

savefig(fig, "figs/length_suc_rate_means.svg")

##################################################################

class_suc_rate_means = zeros(5,3)

df1 = Indices_df[Indices_df[!,"Class"] .<= 2, :]
df2 = Indices_df[2 .< Indices_df[!,"Class"] .<= 4, :]
df3 = Indices_df[4 .< Indices_df[!,"Class"], :]

for i = 1:5
    sum_i1 = 0
    sum_i2 = 0
    sum_i3 = 0
    for a = 1:2
        for s = 1:2
            for d = 1:4
                col1 = join([alg[a], index[i], set[s], dist[d]],"_")
                sum_i1 = sum_i1 + mean(df1[!, col1])
                col2 = join([alg[a], index[i], set[s], dist[d]],"_")
                sum_i2 = sum_i2 + mean(df2[!, col2])
                col3 = join([alg[a], index[i], set[s], dist[d]],"_")
                sum_i3 = sum_i3 + mean(df3[!, col1])
            end
        end
    end
    class_suc_rate_means[i,1] = sum_i1 / (2*2*4)
    class_suc_rate_means[i,2] = sum_i2 / (2*2*4)
    class_suc_rate_means[i,3] = sum_i3 / (2*2*4)
end

fig = plot(
    size = (2*310,2*220),
    grid = :y
)

fo_y = font(8, family="sans-serif")
fo_x = font(12, family="sans-serif")
perm = sortperm(class_suc_rate_means[:,1], rev=true)
groupedbar!(
    index_labels[perm], 
    [class_suc_rate_means[perm,1] class_suc_rate_means[perm,2] class_suc_rate_means[perm,3]],
    label = ["2" "3-4" "> 4"],
    yguidefont = fo_y,
    ylabel = "Proportion of success",
    ytickfont = fo_y,
    yrotation = 90,
    xtickfont = fo_x,
    color = [RGBA(.9,.9,.9,1) RGBA(.75,.75,.75,1) RGBA(.6,.6,.6,1)]
)

savefig(fig, "figs/class_suc_rate_means.svg")