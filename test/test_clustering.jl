using Clustering
using LinearAlgebra
using DelimitedFiles
using DataFrames

include("../src/ExpEval.jl") # repeat to reload 

ID = 18
df = ExpEval.LoadDataSumary()
TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true)

TEST_labels = ExpEval.relabelLabels(TEST_labels)
TRAIN_labels = ExpEval.relabelLabels(TRAIN_labels)

M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw")

res1 = Clustering.kmedoids(M_TRAIN_dtw, 6)

Clustering.varinfo(res1.assignments,TRAIN_labels)

