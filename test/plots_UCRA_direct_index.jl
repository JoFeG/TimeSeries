using StatsPlots
using Statistics
using DataFrames
using CSV


dff = CSV.read("Indices_df.csv", DataFrame)
Indices_df = dff[
        (dff.ID .!= 15) .&
        (dff.ID .!= 27) .&
        (dff.ID .!= 101),
    :]
dff_z = CSV.read("IndicesZ_df.csv", DataFrame)
Indices_z_df = dff_z[
        (dff.ID .!= 15) .&
        (dff.ID .!= 27) .&
        (dff.ID .!= 101),
    :]


set = ["TRAIN", "TEST"]
index = ["ms","di","ga","db","ch"]
dist = ["euc" "dtw" "euc" "dtw"]


direct_index = zeros(5, 4, 65*2)

for i = 1:5
    for d = 1:2
        direct_index[i, d, :] = cat([Indices_df[!, join([set[s], index[i], dist[d]],"_")] for s=1:2]..., dims=1)
    end
    for d = 3:4
        direct_index[i, d, :] = cat([Indices_z_df[!, join([set[s], index[i], dist[d]],"_")] for s=1:2]..., dims=1)
    end
end

index_name = ["Mean Silhouette" "Dunn Index" "Hubert Gamma" "Davies-Bouldin" "Calinski-Harabasz"]

i=3

fig = plot(size = (310,220), grid = :y)
fo_y = font(8, family="sans-serif")
fo_x = font(12, family="sans-serif")
violin!(
    ["euc" "dtw" "euc" "dtw"], 
    [direct_index[i,d,:] for d =1:4], 
    label = ["original" false "normalized" false],
    legend = :top,
    yguidefont = fo_y,
    ylabel = index_name[i],
    ytickfont = fo_y,
    yrotation = 90,
    xtickfont = fo_x,
    color = [RGBA(.9,.9,.9,1) RGBA(.9,.9,.9,1) RGBA(.2,.2,.2,.5) RGBA(.2,.2,.2,.5)]
)

savefig(fig, "figs/test.svg")