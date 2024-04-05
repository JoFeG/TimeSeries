using Clustering
using LinearAlgebra
using DelimitedFiles
using DataFrames

include("../src/ExpEval.jl") # repeat to reload 

ID = 57
df = ExpEval.LoadDataSumary()
TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true)

TEST_labels = ExpEval.relabelLabels(TEST_labels)
TRAIN_labels = ExpEval.relabelLabels(TRAIN_labels)

M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw")


k = 6
res_km = Clustering.kmedoids(M_TRAIN_dtw, k)

Clustering.varinfo(res_km.assignments,TRAIN_labels)


res_hc = Clustering.cutree(Clustering.hclust(M_TRAIN_dtw, linkage=:ward), k=k)

Clustering.varinfo(res_hc,TRAIN_labels)

