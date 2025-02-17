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


function gammaindex2(
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

    for c = 1:k
        c_indices = (1:n)[assignments .== c]
        n_c = length(c_indices)
        for p_c = 1:n_c
            p = c_indices[p_c]
            for q_c = p_c+1:n_c
                q = c_indices[q_c]
                for i = 1:n
                    for j = i+1:n
                        if assignments[i] != assignments[j]
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
    end
    
    ΓI = (s_pluss - s_minus) / (s_pluss + s_minus)
    return ΓI
end


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


## Only medoids implementation ready
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


## Only medoids implementation ready
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