using Clustering
using LinearAlgebra

include("test_start_script.jl");
TEST, TEST_labels, TRAIN, TRAIN_labels = ExpEval.LoadDataBase(ID, df)

TEST_labels = ExpEval.relabelLabels(TEST_labels)
TRAIN_labels = ExpEval.relabelLabels(TRAIN_labels)

function bestMedoids(
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
centers = bestMedoids(TEST_labels, TEST_dist)
c_idx = bestMedoids(ones(Int, length(TEST_labels)), TEST_dist)[1]

function daviesbouldinindex(
        assignments::Vector{<:Int},
        dist::Matrix{<:Real};
        medoids=[]
    )
    
    issymmetric(dist) || throw(ArgumentError("Distance Matrix is not symmetric"))
    
    n = length(assignments)
    n == size(dist)[1] || throw(DimensionMismatch("Distance Matrix and assignments dimension mismatch"))
    
    k = length(unique(assignments))
    1:k == sort(unique(assignments)) || throw(ArgumentError("assignments vector is not of consecutive integer values"))
    
    isempty(medoids) || k == length(medoids) || throw(ArgumentError("medoids indices length differnt from number of clusters"))
    isempty(medoids) || 1:k == assignments[medoids] || throw(ArgumentError("inconsistent assignment of medoids"))
    
    s = zeros(k)
    for i = 1:k
        si = 0
        for j = 1:n
            if assignments[medoids[i]] == j
                si = si + dist[medoids[i],j]
            end
        end

        s[i] = si / sum(assignments .== assignments[medoids[i]])
    end    
    
    R = [i==j ? 0 : (s[i]+s[j])/dist[medoids[i],medoids[j]] for i=1:k, j=1:k]
    
    DB = sum(vec(maximum(R, dims=2)))/k
    
    return DB
end

DB = daviesbouldinindex(TEST_labels, TEST_dist, medoids=centers)
    
function calinskiharabaszindex(
        assignments::Vector{<:Int},
        dist::Matrix{<:Real};
        medoids=[],
        c=[]
    )
    
    issymmetric(dist) || throw(ArgumentError("Distance Matrix is not symmetric"))
    
    n = length(assignments)
    n == size(dist)[1] || throw(DimensionMismatch("Distance Matrix and assignments dimension mismatch"))
    
    k = length(unique(assignments))
    1:k == sort(unique(assignments)) || throw(ArgumentError("assignments vector is not of consecutive integer values"))
    
    !(isempty(medoids)⊻isempty(c)) || throw(ArgumentError("both medoids and c indices need to be specified"))
    
    isempty(medoids) || k == length(medoids) || throw(ArgumentError("medoids indices length differnt from number of clusters"))
    isempty(medoids) || 1:k == assignments[medoids] || throw(ArgumentError("inconsistent assignment of medoids"))
    
    BGSS = 0
    WGSS = 0
    for i = 1:k
        BGSS = BGSS + sum(assignments .== assignments[medoids[i]]) * dist[medoids[i], c] ^ 2
        
        si2 = 0
        for j = 1:n
            if assignments[medoids[i]] == j
                si2 = si2 + dist[medoids[i],j] ^ 2
            end
        end
        WGSS = WGSS + si2
    end
    
    CH = (n-k) * BGSS / ((k-1) * WGSS)
    
    return CH
end

CH = calinskiharabaszindex(TEST_labels, TEST_dist, medoids=centers, c=c_idx)
