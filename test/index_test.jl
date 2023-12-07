using Clustering
using LinearAlgebra

include("test_start_script.jl")
TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df)

TEST_labels = ExpEval.relabelLabels(TEST_labels)
TRAIN_labels = ExpEval.relabelLabels(TRAIN_labels)

function bestMedois(
        assignments::Vector{<:Int},
        dist::Matrix{<:Real}
    )
    issymmetric(dist) || throw(ArgumentError("Distance Matrix is not symmetric"))
    
    n = length(assignments)
    n == size(dist)[1] || throw(DimensionMismatch("Distance Matrix and assignments dimension mismatch"))
    
    k = length(unique(assignments))
    1:k == sort(unique(assignments)) || throw(ArgumentError("assignments vector is not of consecutive integer values"))

    centers = zeros(Int,k)
    for i = 1:k
        members = (assignments .== i)
        id_k = (1:n)[members]
        dist_k = dist[members, members]
        id_c_k = argmin(vec(sum(dist_k, dims = 1)))
        centers[i] = id_k[id_c_k]
    end
    
    return centers
end

TEST_dist = ExpEval.load_distance_matrix(ID, df, "TEST", "euc")
centers = bestMedois(TEST_labels, TEST_dist)