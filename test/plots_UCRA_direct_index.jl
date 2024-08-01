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

index_name = ["Mean Silhouette" "Dunn Index" "Hubert's Gamma" "Davies-Bouldin" "Calinski-Harabasz"]
y_axis = [:identity, :log10, :identity, :log10, :log10]
y_lims = [(-.35,1.01), (0.0035,1.2), (-0.11,1.01), (0.015,11), (900,100000)]

for i in 1:5
    fig = plot(size = (2*120,2*220), grid = :y)
    fo_y = font(8, family="sans-serif")
    fo_x = font(12, family="sans-serif")
    violin!(
        ["euc" "dtw" "euc" "dtw"], 
        [direct_index[i,d,:] for d =1:4], 
        label = ["original" false "normalized" false],
        legend = :top,
        yguidefont = fo_y,
        title = index_name[i],
        ytickfont = fo_y,
        xtickfont = fo_x,
        color = [RGBA(.9,.9,.9,.5) RGBA(.9,.9,.9,.5) RGBA(.2,.2,.2,.5) RGBA(.2,.2,.2,.5)],
        yaxis = y_axis[i],
        ylims = y_lims[i]
    )
    savefig(fig, "figs/violin_$(index[i])_I.svg")
end

###########################################################################################

set = ["TRAIN", "TEST"]
index = ["ms","di","ga","db","ch"]
dist = ["euc" "dtw" "euc" "dtw"]


direct_index = zeros(5, 4, 65*2)

for i = 1:5
    for d = 1:2
        s=1
        direct_index[i, d, :] = cat([Indices_df[!, join([set[s], index[i], dist[d]],"_")], Indices_z_df[!, join([set[s], index[i], dist[d]],"_")]]..., dims=1)
    end
    for d = 3:4
        s=2
        direct_index[i, d, :] = cat([Indices_df[!, join([set[s], index[i], dist[d]],"_")], Indices_z_df[!, join([set[s], index[i], dist[d]],"_")]]..., dims=1)
    end
end

index_name = ["Mean Silhouette" "Dunn Index" "Hubert's Gamma" "Davies-Bouldin" "Calinski-Harabasz"]
y_axis = [:identity, :log10, :identity, :log10, :log10]
y_lims = [(-.35,1.01), (0.0035,1.2), (-0.11,1.01), (0.015,11), (900,100000)]

for i in 1:5
    fig = plot(size = (2*120,2*220), grid = :y)
    fo_y = font(8, family="sans-serif")
    fo_x = font(12, family="sans-serif")
    violin!(
        ["euc" "dtw" "euc" "dtw"], 
        [direct_index[i,d,:] for d =1:4], 
        label = ["TRAIN" false "TEST" false],
        legend = :top,
        yguidefont = fo_y,
        title = index_name[i],
        ytickfont = fo_y,
        xtickfont = fo_x,
        color = [RGBA(.9,.9,.9,.5) RGBA(.9,.9,.9,.5) RGBA(.2,.2,.2,.5) RGBA(.2,.2,.2,.5)],
        yaxis = y_axis[i],
        ylims = y_lims[i]
    )
    savefig(fig, "figs/violin_$(index[i])_II.svg")
end

for i = 1:5
    println("Index: $(index[i]):")
    for d = 1:2
        s=1
        println("$(set[s]) $(dist[d]) mean = $(mean(direct_index[i,d,:]))")
    end
    println("$(set[1]) mean = $(mean(direct_index[i,1:2,:]))")
    for d = 3:4
        s=2
        println("$(set[s]) $(dist[d]) mean = $(mean(direct_index[i,d,:]))")
    end
    println("$(set[2]) mean = $(mean(direct_index[i,3:4,:]))")
    println("------------------------------------------------------------------")
end
println()


rel_chan = zeros(5)
for i = 1:5
    println("Index: $(index[i]):")
    TRAIN_mean = mean(direct_index[i,1:2,:])
    TEST_mean = mean(direct_index[i,3:4,:])
    rel_chan[i] = (TEST_mean - TRAIN_mean)/TEST_mean
    println("relative change from TRAIN to TEST = $(rel_chan[i])")
end
println("All indices:")
println("relative change from TRAIN to TEST = $(mean(rel_chan))")
println()


TRAIN_pref = 0.5*(.8*mean((direct_index[[1,2,3,5],1,:]-direct_index[[1,2,3,5],3,:]).>0)+.2*mean((direct_index[4,1,:]-direct_index[4,3,:]).<0)) + 0.5*(.8*mean((direct_index[[1,2,3,5],2,:]-direct_index[[1,2,3,5],4,:]).>0)+.2*mean((direct_index[4,2,:]-direct_index[4,4,:]).<0))

println("TRAIN pref = $TRAIN_pref")