using Clustering
using LinearAlgebra

function dunnindex(
        assignments::Vector{<:Int},
        dist::Matrix{<:Real}
    )
    issymmetric(dist) || throw(ArgumentError("Distance Matrix is not symmetric"))
    
    n = length(assignments)
    n == size(dist)[1] || throw(DimensionMismatch("Distance Matrix and assignments dimension mismatch"))
    
    k = length(unique(assignments))
    1:k == unique(assignments) || throw(ArgumentError("assignments vector is not of consecutive integer values"))
    
    δ = Inf * ones(k,k)
    for i = 1:k
        for j = i+1:k
            D = dist[assignments .== i, assignments .==j]
            δ[i,j] = minimum(D)
        end
    end
    
    Δ = zeros(k)
    for i = 1:k
        D = dist[assignments .== i, assignments .==i]
        Δ[i] = maximum(D)
    end
    
    DI = minimum(δ) / maximum(Δ)
    return DI
end