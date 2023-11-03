using Clustering
using Plots
include("../src/ExpEval.jl")

ID = 6
df = ExpEval.LoadDataSumary()

# POR AHORA PARA LOS TRAIN SOLAMENTE! 

TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df, true);

M_TRAIN_dtw = ExpEval.load_distance_matrix(ID, df, "TRAIN", "dtw")
M_TRAIN_euc = ExpEval.load_distance_matrix(ID, df, "TRAIN", "euc")

TRAIN_assignments = ExpEval.relabelLabels(TRAIN_labels)

TRAIN_silhouettes_dtw = silhouettes(TRAIN_assignments, M_TRAIN_dtw)
I_ms_dtw = sum(TRAIN_silhouettes_dtw) / length(TRAIN_silhouettes_dtw)

TRAIN_silhouettes_euc = silhouettes(TRAIN_assignments, M_TRAIN_euc)
I_ms_euc = sum(TRAIN_silhouettes_euc) / length(TRAIN_silhouettes_euc)

println("I_ms_dtw = $I_ms_dtw")
println("I_ms_euc = $I_ms_euc")