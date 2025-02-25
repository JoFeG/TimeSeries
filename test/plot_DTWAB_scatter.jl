using Plots

# First do
# include("./test/test_DTWAB_random_missing_scatter.jl")


function matrices_to_scatter_points(M1, M2)
    if size(M1) != size(M2)
        println("Different sized matrices")
        return nothing
    end
    
    n = size(M1)[1]
    K = Int( n * (n - 1) / 2 )
    Px = zeros(K)
    Py = zeros(K)
    k = 1
    for i = 1:n-1
        for j = i+1:n
            Px[k] = M1[i,j]
            Py[k] = M2[i,j]
            k = k+1
        end
    end
    
    return Px, Py
end

fig = plot(
        framestyle = :box,
        ratio  = 1,
        size   = (500,500)
    )

Px, Py = matrices_to_scatter_points(M1,M0)
maxdist = max(maximum(Px),maximum(Py))
plot!([0,maxdist], [0,maxdist], label=nothing)

scatter!(Px, Py,  
        markersize = 2,
        markerstrokewidth = 0,
        markeralpha = .5,
        markercolor = :green,
        label = "DTW0 scatter"
    )


Px, Py = matrices_to_scatter_points(M1,MA)

scatter!(Px, Py,  
        markersize = 2,
        markerstrokewidth = 0,
        markeralpha = .5,
        markercolor = :black,
        label = "DTWA scatter"
    )

Px, Py = matrices_to_scatter_points(M1,MB)

scatter!(Px, Py,  
        markersize = 2,
        markerstrokewidth = 0,
        markeralpha = .5,
        markercolor = :red,
        label = "DTWB scatter"
    )


