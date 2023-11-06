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
    1:k == sort(unique(assignments)) || throw(ArgumentError("assignments vector is not of consecutive integer values"))
    
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


function gammaindex(
        assignments::Vector{<:Int},
        dist::Matrix{<:Real}
    )
    issymmetric(dist) || throw(ArgumentError("Distance Matrix is not symmetric"))
    
    n = length(assignments)
    n == size(dist)[1] || throw(DimensionMismatch("Distance Matrix and assignments dimension mismatch"))
    
    k = length(unique(assignments))
    1:k == sort(unique(assignments)) || throw(ArgumentError("assignments vector is not of consecutive integer values"))
    
    s_pluss = 0
    s_minus = 0
    for i = 1:n
        for j = i+1:n
            for p=1:n 
                for q=p+1:n
                    if assignments[p] == assignments[q]  && assignments[i] != assignments[j]
                        if dist[i,j] > dist[p,q]
                            s_pluss = s_pluss + 1 
                        elseif dist[i,j] < dist[p,q]
                            s_minus = s_minus + 1
                        end
                    end
                end
            end
        end
    end
    
    ΓI = (s_pluss - s_minus) / (s_pluss + s_minus)
    return ΓI     
end