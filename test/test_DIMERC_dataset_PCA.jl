using LinearAlgebra
using Measures
using Plots
include("../src/DIMERC_utils.jl")
savepath = "figs/DIMERC_"

json = LoadDataSet_DIMERC_json()
Y = DIMERCseriesjson2matrix(json)

F = svd(Y)

fig = plot(
    margin=20pt,
    size = (2*600,2*220), 
    grid = :y
    )

##### Singular values plot

# scatter!(F.S)
# scatter!(log.(F.S))
# savefig(fig, savepath*"test.pdf")
# display(fig)

##### Projection to dimension k=2

k = 2
Σ = Diagonal(F.S)
T = Σ[1:k,1:k] * F.Vt[1:k,:]

m, n = size(Y)

norms = norm.(eachcol(Y))
colors = zeros(n)
for k = 1:n
    for c = 1:4
        norms[k] > c*5e5 ? colors[k] = c/4 : nothing
    end
end

fig = plot(
    margin=20pt,
    size = (600,600)
    )

scatter!(
    T[1,:],
    T[2,:],
    zcolor = colors, #ids_over_cap,
    marker = :x
)
#savefig(fig, savepath*"test.pdf")
#display(fig)



fig = plot(
    margin=20pt,
    size = (2*600,2*220), 
    grid = :y
    )

scatter!(sort(norm.(eachcol(Y))))
#savefig(fig, savepath*"test.pdf")
#display(fig)


#=

YY = Y[:,(norms.>1e2).&(norms.<1e3)]

FF = svd(YY)

fig = plot(
    margin=20pt,
    size = (2*600,2*220), 
    grid = :y
    ) 

scatter!(FF.S)
#savefig(fig, savepath*"test.pdf")
#display(fig)

Σ = Diagonal(FF.S)

k=2
TT = Σ[1:k,1:k] * FF.Vt[1:k,:]


fig = plot(
    margin=20pt,
    size = (600,600)
    )

scatter!(
    TT[1,:],
    TT[2,:],
    marker = :o,
    markersize = 1
)

display(fig)
=#